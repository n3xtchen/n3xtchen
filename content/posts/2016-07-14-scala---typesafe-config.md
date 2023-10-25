---
categories:
- Scala
date: "2016-07-14T00:00:00Z"
description: ""
tags: []
title: Scala - 使用 typesafe.config 管理你的配置文件
---

为了统一管理配置项，我在真是操碎了心啊。现在我分享下这两天的研究成果。

首先先介绍下 `typesafe.config`，**Scala** 语言下一个流行的**配置管理库**，由 **Lightend**（前身是 **typesafe**，**Scala** 编程语言的发明者）公司开发的。所以它的流行自然就不言而喻了。它的项目地址：[https://github.com/typesafehub/config](https://github.com/typesafehub/config)。

### 安装和使用 typesafe.config

在你的 sbt 依赖中添加如下：

	braryDependencies += "com.typesafe" % "config" % "1.3.0"
	
这个版本你需要关注，如果你的 `Java 1.6 `及以下，其版本就是 `1.2.1`；`1.3.0` 则是为 **java 8** 构建的

下面是演示代码：

	import com.typesafe.config.ConfigFactory
	
	val conf = ConfigFactory.load();
	int bar1 = conf.getInt("foo.bar");
	Config foo = conf.getConfig("foo");
	int bar2 = foo.getInt("bar");

	
在这里，我就不对用法进行详细介绍，自行 google 或者看官方 API（它的 [README.md](https://github.com/typesafehub/config/blob/master/README.md) 将的已经足够详细了）。

### 可选的覆盖配置方案

这几天我一直思考一个问题：在不同环境下，如何能够自动切换配置，而减少上线和调试成本，降低配置错误带来的风险。目前有如下几个方案：

#### Java System Properties

**Java** 系统属性，通过 `-D` 标签传递给命令行来达到覆盖配置的目的：

	java -Dsys_args=value com.cyou.fz.config
	
如果需要的覆盖的参数占少数，那么这个方式是一个不错的方案，但是配置一多就蛋碎了一地，举个例子：

	java -Ddb1=0.0.0.0/db -Ddb1_pass=u -Ddb1_pass \
		-Ddb2=0.0.0.0/db -Ddb2_pass=u -Ddb2_pass \
		-Ddb3=0.0.0.0/db -Ddb3_pass=u -Ddb3_pass \
		-Ddb4=0.0.0.0/db -Ddb3_pass=u -Ddb4_pass \
		com.cyou.fz.config
		
用这种方式来传递多个数据配置，是不是很蛋疼啊；总结下优缺点：

优点：

* 需要传递命令行 flag，操作起来简便

缺点：

* 如果需要覆盖的配置数量多（个人认为，超过 5 个就不适用了）

#### 使用环境变量

现在来看看我们的 HOCON 配置：

	app {
	 db {
	  host = localhost	// 默认参数
	  host = ${?DB_PORT_3306_TCP_ADDR}	// 环境变量 DB_PORT_3306_TCP_ADDR 有设置，将会替换 host 的值
	  port = "3306"
	  port = ${?DB_PORT_3306_TCP_PORT}
	 }
	}
	
就不过多解释了，自己看注释。

#### HOCON 中使用 include 

首先我们将系统配置以文件形式存储和统一管理，下面是的数据库连接串管理：

	# 生产环境数据库配置
	# 路径 /usr/local/etc/db.conf
	db {
		jdbcUrl = "jdbc:mysql://0.0.0.0:3306/MyDatabase"
		user = "dba"
		pass = "pass"
	}
	
	
这时，你只需要在你的 `resoures` 中的配置文件引入我们公用的配置：

	# src/main/scala/resources/application.conf
	include "/usr/local/etc/db.conf"
	
测试下：

	scala> val conf = ConfigFactory.load();
	Iconf: com.typesafe.config.Config = ... 
	scala> conf.getString("db.jdbcUrl")
	res0: String = jdbc:mysql://0.0.0.0:3306/MyDatabase
	
这样子，你就可以在的开发环境，测试环境的同一个路径下配置自己的数据连接，就很方便。

另外，另外你觉得路径太长太丑，你也可以使用：

	include classpaht("db.conf")
	
你要把你的配置文件追加到 `classpath` 中，这边，我需要这么操作：

	export CLASSPATH = /usr/local/etc/:$CLASSPATH
	
这样，测试结果同上。

你还可以通过 web 服务，来统一管理配置，那么你就可以直接试用 Url 引入配置：

	include url("http://0.0.0.0/db.conf")

### 结语

这里，提供了三种配置管理的方法，任君挑选。个人更偏向于最后一种；第一种的弊端已经讲过了，置于第二种，如果没有线上环境变量的配置权限，就无法操作了。最后一种，你只要有目录的操作权限，就可以轻松部署了。
	


