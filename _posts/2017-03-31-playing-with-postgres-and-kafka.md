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

### kafkacat 和 librdkafka

[kafkacat](https://github.com/edenhill/kafkacat) 是由 [librdkafka](https://github.com/edenhill/librdkafka) 库的作者开发的另一个工具，功能用一句话概括：像 `cat` 命令那样在 **Kafka** 的 **Broker** 中生产和消费数据。

#### 生成数据到 Kafka Broker

造模拟数据发送给 **Kafka** 的 **Broker**

	# 随机文本
	randtext() {cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1}
	while (true) ;
	  do
	    for i in $(seq 1 50)  
	      do echo "$(uuidgen);$(randtext)"
	     done  | kafkacat -P -b localhost:9092 -qe -K ';' -t PGSHARD
	     sleep 10
	  done
	  
`-K` 定义了界定符，`-t` 定义想要把数据发送的主题。默认，这个主题已经创建了 3 个分区（0-2），允许我们并行从不同的频道消费数据。

生产数据给 Broker 时，Keys 不是强制要求的；并不是每一个场景都需要，你可以无视它。

#### 在Postgres实例中使用和生成

通常语法和下面差不多：

	COPY main(group_id,payload)
	  FROM PROGRAM
	  'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD  -X group.id=1  -o beginning  -p 0 | awk ''{print "P0\t" $0 }'' ';

awk 不是被严格要求的，它只是为了展示该功能的灵活。使用 `-J` 选项时，输出将会被打印成 json 格式，包含所有的消息信息，包括分区，键值和信息。

-c 选项将会限制数据的行数。COPY 命令也是具有事务的，这意味着处理的数据行数越多，事务越巨大，提交的时间也会受影响。

#### 增量消费主题

从头开始消费主体分区，并设置 100 个文档的限制时很容易的：

	bin/psql -p7777 -Upostgres master <<EOF
	COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD  -X group.id=1  -o beginning  -p 0 | awk ''{print "P0\t" \$0 }'' ';
	COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD  -X group.id=1  -o beginning  -p 1 | awk ''{print "P1\t" \$0 }'' ';
	COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD  -X group.id=1  -o beginning  -p 2 | awk ''{print "P2\t" \$0 }'' ';
	EOF

然后使用 `stored`，为了每次只消费消费者在所在组未使用过的数据：

	bin/psql -p7777 -Upostgres master <<EOF
	COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD  -X group.id=1  -o stored  -p 0 | awk ''{print "P0\t" \$0 }'' ';
	COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD  -X group.id=1  -o stored  -p 1 | awk ''{print "P1\t" \$0 }'' ';
	COPY main(group_id,payload) FROM PROGRAM 'kafkacat -C -b localhost:9092 -c100 -qeJ -t PGSHARD  -X group.id=1  -o stored  -p 2 | awk ''{print "P2\t" \$0 }'' ';
	EOF

每一个 `COPY` 命令都是并行执行的，使得这种方式足够灵活，易于拓展到集群。

并不是绝对的一致性，一旦偏移量被消费了，将在 Broker 被标记；如果在 Postgres 端事务失败会导致潜在的数据丢失。

#### 在Postgres实例中生成消息

同样的方式也可以消费变更，用法和生产数据给 Broker 一样。这使得通过从 broker 消费原始数据进行微聚合时，超级有用。

下面的例子展示了如何使用超简单的聚合查询，并以 json 的格式回吐给 broker：

	master=# COPY (select row_to_json(row(now() ,group_id , count(*))) from main group by group_id)
	         TO PROGRAM 'kafkacat -P -b localhost:9092 -qe  -t AGGREGATIONS';
	COPY 3
	
如果你有一堆的服务器，想要通过 key 查询主体内容，你可以这么做：

	COPY (select inet_server_addr() || ';', row_to_json(row(now() ,group_id , count(*))) from main group by group_id)
	   TO PROGRAM 'kafkacat -P -K '';'' -b localhost:9092 -qe  -t AGGREGATIONS';
	   
发布的数据想这样（不带 key 的）：

	➜  PG10 kafkacat -C -b localhost:9092 -qeJ -t AGGREGATIONS -X group.id=1  -o beginning
	{"topic":"AGGREGATIONS","partition":0,"offset":0,"key":"","payload":"{\"f1\":\"2017-02-24T12:34:13.711732-03:00\",\"f2\":\"P1\",\"f3\":172}"}
	{"topic":"AGGREGATIONS","partition":0,"offset":1,"key":"","payload":"{\"f1\":\"2017-02-24T12:34:13.711732-03:00\",\"f2\":\"P0\",\"f3\":140}"}
	{"topic":"AGGREGATIONS","partition":0,"offset":2,"key":"","payload":"{\"f1\":\"2017-02-24T12:34:13.711732-03:00\",\"f2\":\"P2\",\"f3\":155}"}

带 key 的：

	{"topic":"AGGREGATIONS","partition":0,"offset":3,"key":"127.0.0.1/32","payload":"\t{\"f1\":\"2017-02-24T12:40:39.017644-03:00\",\"f2\":\"P1\",\"f3\":733}"}
	{"topic":"AGGREGATIONS","partition":0,"offset":4,"key":"127.0.0.1/32","payload":"\t{\"f1\":\"2017-02-24T12:40:39.017644-03:00\",\"f2\":\"P0\",\"f3\":994}"}
	{"topic":"AGGREGATIONS","partition":0,"offset":5,"key":"127.0.0.1/32","payload":"\t{\"f1\":\"2017-02-24T12:40:39.017644-03:00\",\"f2\":\"P2\",\"f3\":716}"}

#### 基础的主题操作

如果你是 Kafka 新手，接下来讲的一些命令将会帮助你，快速上手。

启动相关服务

	bin/zookeeper-server-start.sh config/zookeeper.properties 2> zookeper.log &
	bin/kafka-server-start.sh config/server.properties 2> kafka.log &
	
创建主题：

	bin/kafka-topics.sh --list --zookeeper localhost:2181
	bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 3 --topic PGSHARD
	bin/kafka-topics.sh --delete  --zookeeper localhost:2181 --topic PGSHARD
	bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic AGGREGATIONS
	bin/kafka-topics.sh --delete  --zookeeper localhost:2181 --topic AGGREGATIONS
	
**注意：**你需要在 *server.properties* 文件中设置 `delete.topic.enable=true` 选项，来激活删除主题操作

> 引用自：[Playing with Postgres and Kafka.](http://www.3manuek.com/kafkacatandcopypg)