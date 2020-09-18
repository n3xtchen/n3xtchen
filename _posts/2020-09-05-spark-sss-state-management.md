---
layout: post
title: "Spark 流计算状态管理进化史"
description: ""
category: Spark
tags: []
---
{% include JB/setup %}

开头先看一下流计算处理的定义，即实时处理无边（unbounded）数据流（通俗说就是数据什么时候进入，什么时候处理？）

从数据角度看，流计算主要有两种处理方法：

- 无状态（Stateless）：每一个进入的记录独立于其他记录。不同记录间没有任何关系，他们可以独立处理和持久化。例如：`map`、`fliter`、静态数据 `join` 等等。
- 有状态（Stateful）：处理进入的记录依赖于之前记录处理的结果。因此，我们需要维护不同数据处理之间的中间信息。每一个进入的记录都可以读取和更新这个信息。我们把这个中间信息称作状态（State）。例如，独立键的计数聚合，去重等等。

### 状态的定义

状态（State）在流计算是一个宽泛概念的词汇；继续之前，我们先明确下个定义。状态（State）字面意思就是“中间信息（Intermediate Information）”。

在流计算中，有两种中间状态（State）：

1. 过程状态：它是流计算的元数据（metadata）；追踪历史至今被处理的数据。在流的世界中，我们称之为打点（checkpoint）或者保存数据的偏移（offset）。为了防止重启，升级或者任务失败，它需要容错（fault tolerance）。这个信息是任何高可靠流处理的基本，同时被无状态和状态处理需要。
2. 数据状态（正在被处理的）：这些中间数据源自数据（目前为止处理过的），它需要在记录之间维护。这个只在 Stateful 模式下，需要处理。

在流中，当我们谈论状态（State）的时候，它一般指的是数据的状态（即第二个，除非明确提到偏移或者过程状态）。

### 状态储存的选择

为了维护流处理中的状态，我们需要个存储器介质，可以是五花八门，这里归纳下常用的几种：
- 内存，如HashMap 
- 文件系统，如 hdfs
- 分布式数据库，如 Cassandra
- 嵌入式存储，最流行的单属 Facebook 的RocksDb

状态存储的目的稳定可靠是关键，效率也是比不可少。这流计算的历史中，都是围绕着稳定和高效进行迭代进化的。

接下来，我们要进入正题了，介绍下 Spark 中几种状态处理和存储的机制。

### 第一代：DStream/Spark Streaming 的状态管理

在 Spark Streaming 或者 Structured Streaming 的 DStream 中，每一个微批处理都会在 checkpoint 元数据中单独维护；当每个批处理的结束的时候，同步（synchronous）完成状态额维护，即使该微批处理没有任何状态操作。
状态没有进行增量持久化，每一次都是全量状态的镜像，导致必要的系列化和持久化。

总结成如下几点：

- 状态的存储不是增量的，会产生不必要的序列化和 IO，随着状态数据越大，问题越严重；
- 状态处理是同步的（synchronous），和每一个 Spark Rdd task/jobs 捆版在一起，并且是处理接触后完成，这样导致不必要的延迟和开销；

我们生活在一个不断进化的世界中。因为旧的东西不够好，导致有新的东西不断涌现，取而代之。

### 第二代：Structured Streaming 的状态管理

Structured Streaming （Spark 的第二代基于 SQL 的流计算）的出现除了带来更多的新特性，同时解决了上代遗留下来的坑（状态管理就是其中之一）。

状态管理从元数据打点（checkpoint）中解藕出来，不在是 tasks/jobs 的一部分；并且是异步的，同时支持增量持久化。（哈哈哈，真香，有木有？）

让我们深入了解下  Spark 2 的状态管理机制。

Structured Streaming 只提供了一种状态存储的实现：基于 HDFS 的状态管理（其实，Databrick（商业）、Quole（开源）已经提供了基于 RocksDB 的实现，大家可以了解下）。

- 每一个聚合的 RDD 在各自 executor 内存中会有一个版本化键值存储结构（内存中的 HashMaop），它是以键值字典的方式存储状态数据的。这个存储是唯一的：checkpointPath + operatorId + partitionId
    - checkpointPath：流查询的打点路径
    - operatorId：流查询中的每一个聚合操作（如 groupBy）内部会被分配一个整型值
    - partitionId：聚合操作之后会生成聚合 RDD 分区 ID
- 版本基本等同于批次 ID，它的值就是批次 ID；
- 第一个之外的每一个微批，一个分区会有一个从预处理器的 HashMap （同一分区的最后一个微批次）中拷贝的新的 HashMap。新的更新会作用在当前最新批次/版本上。微批处理结束后更新的 HashMap 将作为下一个微批的基础，这样不断重复的执行下去；
- 同样，一个微批处理的一个分区，会有一个文件来记录微批处理的变更。这个文件称之为版本化的 delta 文件。它只包含相关分区的特定批次的状态变更。因此会有很每个批次和分区相同数量的 delta 文件。它已唯一的路径创建：checkpoint路径/state/operatorId/partitionId/${版本}.delta
- 分区任务计划在 executor 上执行，在该执行程序中存在与以前的 microBatch 相同的分区的 HashMap。这个是有 Driver 决定的，在 executor 上保存有关于状态存储的足量数据；
- 在微批处理的任务中，键的变更异步执行的，并且具有事务，同时会输出版本化的 delta 文件；
- 关于状态管理的其他操作（如快照，清楚、删除，文件的管理等等）在 executor 的隔离守护线程（称之为 MaintenanceTask）中异步完成的。一个 executor 一个线程；
- 如果任务成功了，输出流将会关闭，版本 Delta 文件将会提交并持久化到文件系统（如HDFS）中。内存中版本化的 HashMap会被加到提交过 HashMap 列表中，该分区的版本号会加1。新的版本ID将会在该分区的下一个批次中使用；
- 如果分区任务失败了，相关内存中 HashMap 会被抛弃，delta 文件输出流会被切削。这样，不会有任何的变化会在内存或者文件中被记录。整个任务将会重试；
- 就像之前说的，每一个 executor 都有一个独立线程（MaintanenceTask），他会在等间隔时长（默认 60 秒）执行，为每个分区完成的状态进行异步地快照，将最新的版本 HashMap 持久化到磁盘中（文件名：version.snapshot，路径:checkpointLocation/state/operatorId/partitionId/${version}.snapshot）。
一次没几个批次，就有一个分区的快照文件被这个线程创建，代表该版本的完整状态。这个线程会删掉比这个版本旧的 delta和快照文件；
- 注意：相同的 executor 不会有多线程来把状态写到delta文件中。但是在特定场景（如果推测执行）下可以有多个 execuotrs 同时将同一个状态载入到内存中。这个意味着只能有一个线程写内存中的 HashMap，但是可以有不同 executor 的多个线程写到同一个delta文件中。

### 当前实现的优点和缺点

如大家所知，软件开发没有银弹。每一种设计都有他们的优缺点。

优点：
- 更强拓展性的抽象和接口。基于数据库或者外部存储的状态存储可以自行实现，如现在流行的 RocksDB 取代内存的方式已经在付费版的 Spark 中得到实现，
- 不向早期的 DStream，不低效，以及没有和 executor 任务强绑定
- 增量状态的 checkpoint

缺点：
- 默认的状态存储占用的 executor 内存来存储 HashMap。executor 任务的内存没有和状态存储隔离开。当运行任务、状态数据成倍增长，超过可用的 executor 内存时，将会导致垃圾回收（GC），甚至内存溢出；
- 每一个 executor 只有单线程负责镜像和状态数据清理。对于大规模状态和单 executor 拥有过多分区的时候，这个线程将会不堪重负，可能会导致延迟。

### 和其他流系统对比

如果不和其他的流计算框架对比，这篇文章显得不完整。像 Flink，Samza 和 Kafka Stream 这样的开源流计算框架使用 RocksDB 来应对状态存储的内存限制。RocksDB 解决了内存问题，但是在节点失败的时候没有容错性。

Kafka Streams 和 Samza 使用 RocksDB 作为无限制的本地存储。对于容错，Samza 和 KafkaStream 都依赖于 Kafka，使用同样的方式。他们为每一个更新写变更日志到内部的 Kafka 主题，他会不断的压缩，最终变成单个快照日志文件，其中保存状态数据中的所有键值。防止失败和重启，RocksDB 会从这个 Kafka 主题中恢复数据。

Flink 则使用另一种方式，为了容错使用独立的快照策略，代替像 Kafka 这样外部系统。Flink 会定时快照 RocksDB 的数据，并拷贝到可靠的文件系统中（如HDFS）。防止失败，RocksDB 会从最新的快照还原。最后一次快照和失败之间将会存在一些数据将不会固化到快照中。为了还原，Flink 将从快照的时间点开始处理数据，保证未考虑的数据会被重新处理。记住，只有像 Kafka Kinesis 这类可回放的数据源才能实现这些。

Storm/Storm Triden 依赖外部的存储（如 Cassandra/Redis）作为状态管理，来解决可依赖额容错，但是规模化后会影响性能。外部存储会大量的网络调用，将会对流处理增加延迟。这就是为什么大部分流系统使用嵌入式本地存储。


### 结语

对比旧的 DStream 实现，Structured Streaming 当前状态管理的实现已经有很大的进步。他解决的早期的问题，是一个很成熟的设计。为了和其他流系统一较高下，就需要一个稳定的状态存储的实现。




> 引用自：[State Management in Spark Structured Streaming](https://medium.com/@chandanbaranwal/state-management-in-spark-structured-streaming-aaa87b6c9d31)
