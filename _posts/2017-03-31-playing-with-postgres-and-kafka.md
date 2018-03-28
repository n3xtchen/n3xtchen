---
layout: post
title: "让 Postgres 和 Kafka 一起玩耍"
description: ""
category: PostgreSQL
tags: [pgsql, kafka]
---
{% include JB/setup %}

### Apache Kafka 和 Postgres: 处理事务和报表能力

**Apache Kafka** 是目前主流的分布式流处理平台，用于数据处理和信息一致保证。她允许你集中数据流，完成多种目的。我突然对 [Mozilla 的数据管道](https://robertovitillo.com/2017/01/23/an-overview-of-mozillas-data-pipeline/) 实现感兴趣，尤其是其中展示了 **Kafka** 作为流的入口。

[Postgres Bottled Water](https://www.confluent.io/blog/bottled-water-real-time-integration-of-postgresql-and-kafka/) 是另一种方式。在这个场景下，**Postgres** 实例作为生产者，**Broker** 接受流，并定向到其他平台。她的优势就是拥有结合先进的 SQL 特性 的 **Postgres** 的 **ACID** 能力。将它作为一个拓展，还可以和其他特性一起运行。

**Postgres 9.6** 的 `COPY` 工具（[详见文档](http://paquier.xyz/postgresql-2/postgres-9-6-feature-highlight-copy-dml-statements/)）还可以执行命令行来操作数据IO，这样就可以消费和生产数据给 Broker。

### 开始之前的准备

测试环境的相关参数：

* 系统： **Ubuntu 16.04.2 LTS**
* JAVA 版本：**openjdk version "1.8.0_121"**, 下面提供 Ubuntu/Debian 下的安装方法:
	* `apt-get -y install default-jre default-jdk`
* Kafka 版本：**kafka 3.2**（confluent 官方，scala：2.11）
	* 安装教程详见 [基础的 Kafka 操作](#基础的 Kafka 操作)

### kafkacat 和 librdkafka

[kafkacat](https://github.com/edenhill/kafkacat) 是由 [librdkafka](https://github.com/edenhill/librdkafka) 库的作者开发的另一个工具，功能用一句话概括：像 `cat` 命令那样在 **Kafka** 的 **Broker** 中生产和消费数据。

Ubuntu/Debian 安装命令如下：

	ichexw$ sudo apt-get install kafkacat

#### 生成数据到 Kafka Broker

造模拟数据发送给 **Kafka** 的 **Broker**；**Bash** 脚本如下：

	# 随机文本
	function randtext() {
		cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
	}
	while (true); do
		# 每 10s 升成 50 个随机序列
		for i in $(seq 1 50)  
			do echo "$(uuidgen);$(randtext)"
		done | kafkacat -P -b localhost:9092 -qe -K ';' -t PGSHARD
		sleep 10
	done

**温馨小提示**：如果 `uuidgen` 在你环境下找不到，你需要自行安装 **uuid-runtime**，这里提供 Ubuntu/Debian 下的安装方法:

>	ichexw$ `apt-get install uuid-runtime`

kafkacat 使用的参数：	
 
* `-P`: 生产者模式；对应的 `-C`，就是消费者模式
* `-b <brokers,..>`: 这个就是 **Broker** 的地址
* `-qe`: 两条命令合并
	* `-q` 静默状态
	* `-e` 最后一条发送成功后推出
* `-K <delim>`: 定义了界定符
* `-t <topic>`: 定义想要把数据发送的 **Topic**。

默认，这个 **Topic** 已经创建了 3 个分区（0-2），允许我们并行从不同的频道消费数据。

生产数据给 **Broker** 时，Keys 不是强制要求的；并不是每一个场景都需要，你可以无视它。
 
#### 在Postgres实例中使用和生成

通常语法和下面差不多：

	kafka_db=# COPY main(group_id,payload) 
	  FROM PROGRAM
	  'kafkacat -C -b localhost:9092 -o beginning -c100 -qeJ -t PGSHARD -p 0 |
	   awk ''{print "P0\t" $0 }''';

`awk` 不是被强制要求的，它只是为了展示该功能的灵活。

kafkacat 使用的参数：	

* `-J`: 输出将会被打印成 json 格式，包含所有的消息信息，包括分区，键值和信息。
* `-o <offset>`: 提取数据的提取偏移量
	* 常量：beginning 从头开始；end 从尾部开始；stored 后面会接受
	* 整型: 绝对位置
	* -整型: 从尾部开始相对位置 	
* `-c <cnt>`: 将会限制数据的行数。COPY 命令也是具有事务的，这意味着处理的数据行数越多，事务越巨大，提交的时间也会受影响。

**Postgres** 的 `COPY` 命令： 
	
	COPY table_name [ ( column_name [, ...] ) ]
	  FROM { 'filename' | PROGRAM 'command' | STDIN }
	 
命令解释： 
	  
* filename: 要导入的文件名，直接从文件导入数据
* command: 命令，从读取命令的输出定向给数据表
* STDIN: 输入

#### 增量消费主题

从头开始消费 **Topic** 分区，并设置 100 个文档的限制：

	ichexw$ psql -Upostgres kafka_db <<EOF
	  COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD -o beginning  -p 0 | awk ''{print "P0\t" \$0 }'' ';
	  COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD -o beginning  -p 1 | awk ''{print "P1\t" \$0 }'' ';
	  COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD -o beginning  -p 2 | awk ''{print "P2\t" \$0 }'' ';
	EOF

然后使用 `stored`，为了每次只消费在所在分区未使用过的数据：

	ichexw$ psql -Un3xtchen kafka_db <<EOF
	  COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD -o stored  -p 0 | awk ''{print "P0\t" \$0 }'' ';
	  COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD -o stored  -p 1 | awk ''{print "P1\t" \$0 }'' ';
	  COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD -o stored  -p 2 | awk ''{print "P2\t" \$0 }'' ';
	EOF
	
每一个 `COPY` 命令都是并行执行的，使得这种方式足够灵活，易于拓展到集群。

**注意**：并不是绝对的一致性，一旦偏移量被消费了，将在 Broker 被标记；如果在 **Postgres** 端事务失败会导致潜在的数据丢失。

#### 在 Postgres 实例中生成消息

同样的方式也可以消费数据，用法和生产数据给 **Broker** 一样。这使得通过从 **Broker** 消费原始数据进行微聚合时，超级有用。

下面的例子展示了如何使用超简单的聚合查询，并以 **json** 格式回吐给 **Broker**：

	kafka_db=# COPY (select row_to_json(row(now() ,group_id , count(*))) from main group by group_id) TO PROGRAM 'kafkacat -P -b localhost:9092 -qe -t AGGREGATIONS';
	COPY 3
	
如果你有一堆的服务器，想要通过 key 查询主体内容，你可以这么做：

	kafka_db=# COPY (select inet_server_addr() || ';', row_to_json(row(now() ,group_id , count(*))) from main group by group_id)
	   TO PROGRAM 'kafkacat -P -K '';'' -b localhost:9092 -qe  -t AGGREGATIONS';

现在查看信息：

	ichexw$ kafkacat -C -b localhost:9092 -qeJ -t AGGREGATIONS -o beginning
	
注意看输出的区别
	   
不带 key 的：

	{"topic":"AGGREGATIONS","partition":0,"offset":0,"key":"","payload":"{\"f1\":\"2017-04-05T07:50:52.148631+00:00\",\"f2\":\"P0\",\"f3\":100}"}
	{"topic":"AGGREGATIONS","partition":0,"offset":1,"key":"","payload":"\\N\t{\"f1\":\"2017-04-05T07:51:10.004637+00:00\",\"f2\":\"P0\",\"f3\":100}"}

带 key 的：

	{"topic":"AGGREGATIONS","partition":0,"offset":0,"key":"127.0.0.1/32","payload":"{\"f1\":\"2017-04-05T07:50:52.148631+00:00\",\"f2\":\"P0\",\"f3\":100}"}
	{"topic":"AGGREGATIONS","partition":0,"offset":1,"key":"127.0.0.1/32","payload":"\\N\t{\"f1\":\"2017-04-05T07:51:10.004637+00:00\",\"f2\":\"P0\",\"f3\":100}"}

#### 基础的 Kafka 操作

如果你是 Kafka 新手，接下来讲的一些命令将会帮助你，快速上手。

下载并解压包 kafka：

	ichexw$ wget -P path/to/dowload/directory http://packages.confluent.io/archive/4.0/confluent-oss-4.0.0-2.11.tar.gz
	# -P 下载文件存储的地址，我使用 /usr/loca/src/
	ichexw$ cd path/to/dowload/directory
	ichexw$ tar -xzvf confluent-oss-4.0.0-2.11.tar.gz
	ichexw$ mv confluent-4.0.0 /path/to/install/directory/
	# /path/to/install/directory/: kafka 的安装目录，我使用的是 /usr/local/

启动相关服务：

	ichexw$ bin/zookeeper-server-start etc/kafka/zookeeper.properties 2> zookeper.log &
	ichexw$ bin/kafka-server-start etc/kafka/server.properties 2> kafka.log &
	
创建主题（Tipics）：

	ichexw$ bin/kafka-topics --list --zookeeper localhost:2181
	ichexw$ bin/kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 3 --topic PGSHARD
	# 创建名为 PGSHARD, 3 个分区, 一个副本的主题
	ichexw$ bin/kafka-topics --delete  --zookeeper localhost:2181 --topic PGSHARD
	# 删除分区
	ichexw$ bin/kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic AGGREGATIONS
	ichexw$ bin/kafka-topics --delete  --zookeeper localhost:2181 --topic AGGREGATIONS
	
**注意：**你需要在 *server.properties*（默认在 **kafka** 安装文件夹的 */etc/kafka* 中） 文件中设置 `delete.topic.enable=true` 选项，来激活删除主题操作

> 引用自：[Playing with Postgres and Kafka.](http://www.3manuek.com/kafkacatandcopypg)