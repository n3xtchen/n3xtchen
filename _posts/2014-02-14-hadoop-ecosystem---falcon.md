---
layout: post
title: "Hadoop 生态系统 - falcon"
tagline: "Hadoop 集群的数据处理管理框架"
description: ""
category: Hadoop
tags: [hadoop, data]
---
{% include JB/setup %}

Apache Falcon 是 Hadoop 的数据管理框架和管道处理框架。它能自动采集（ingest），
管道（pipelines），灾难恢复和数据保留用例。用户可以依赖 Falcon 来取代复杂的
数据和管道处理的硬编码，它可以对这些函数复用最大，以及保证 Hadoop 的跨应用
之间的数据一致性。

### Falcon 的特点

Falcon 通过引入用户处理的高层次抽象，简化了数据处理管道的开发和管理。它提供
通用的开箱即用的数据管理服务，提取数据处理应用中的复杂代码，简化数据移动的
配置和编排，灾难恢复以及数据保留工作流。如下是 falcon 的关键特性：

+ 数据复制处理：Falcon 为了灾难恢复和多集群数据的数据挖掘需要在不同集群之间
同步复制 HDFS 文件和 Hive 表。
+ 数据生命周期管理：Falcon 管理数据驱逐（eviction）政策。
+ 数据沿袭（Lineage）和可追溯幸：Falcon E-R 关系使用户可以查看粗粒度数据沿袭
+ 流程协调和调度：Falcon 自动管理后来的数据处理和重试的复杂逻辑
+ 声明式数据处理编程：Falcon 引入高级数据抽象（集群，Feeds 和处理）把业务
逻辑从应用逻辑中抽出，在建立处理管道时最大化复用和保持数据的一致性
+ 均衡存在的 Hadoop 服务：Falcon 使用现有的 Hadoop 服务（例如 Oozie）能
更透明协调和调度数据工作流

> *数据沿袭（Lineage）*：由数据转换服务 (DTS) 与 Meta Data Services 一起使用
的信息，记录每块数据的包执行和数据转换的历史。)

### Falcon 工作原理

Falcon 作为 Hadoop 集群的一部分，以独立的服务运行。

![struct](http://hortonworks.com/wp-content/uploads/2013/09/falcon-architecture-1024x645.png =491x310)

用户使用命令行或 Rest 接口创建实例特征（entity specifications）并提交给 
Falcon。Falcon 通过 Hadoop 工作流调度器将实例特征转化成重复的动作。
所有的函数和工作状态管理需求授权给调度器。默认，Falcon 使用 Oozie 作为
调度器。

![workflow](http://hortonworks.com/wp-content/uploads/2013/09/falcon-userflow-1024x533.png =491x256)

#### 实体（entities）

![entities](http://hortonworks.com/wp-content/uploads/2013/09/falcon-entities-1024x487.png =491x234)

+ 集群（Cluster）：呈现接口给 Hadoop 集群
+ Feed：定义数据集（例如 HDFS 文件 或者 Hive 表）的 location，复制调度和
保留方案
+ 进程：消费 Feed 和处理 Feeds

### Falcon In Action: 同步

所有的企业对话在某点上都涉及数据同步。从简单的 “我要多份数据副本”向 “我需要
阶段的，中间结果和展示结果在不同的集群之间同步，并且具有失效备援（failover）
的功能（即当某台机子出现故障了，有另一台机子接手原失效系统的动作）... 并且
每一个数据集都有不同的保留时间。“

典型的例子就是解决定制的应用的问题，它是耗时的，易错的（error-prone）和面临
长期维护的挑战。使用 Falcon，你可以避免定制代码的问题，是用简单的声明语言来
表达处理管道和同步机制。

在下面场景中，阶段数据通过一系列处理提供给 BI 使用。用户希望同步数据到第二个
集群（防止集群停工的时候，用来失效备援）。但是第二个集群的容量要比第一集群小
很多，因此只能数据被同步。

Falcon 来拯救你。你只要使用 Falcon 定义数据集和处理流程，Falcon 将在指定的时间
同步数据到第二集群中。Falcon 将编排处理和调度同步时间。结果：在第一集群出现问题
被迫下线的时候，关键的阶段和呈现数据已经存储在第二集群上了。

![Alt text](http://hortonworks.com/wp-content/uploads/2013/09/falcon-example-replication.png =491x321)
