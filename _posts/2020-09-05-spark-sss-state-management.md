---
layout: post
title: "浅谈 Structured Streaming 状态管理"
description: ""
category: Spark
tags: []
---
{% include JB/setup %}


开头先看一下流计算处理的定义，即实时处理无边（unbounded）数据流（通俗说就是数据什么时候进入，什么时候处理？）

从数据角度看，流计算主要有两种处理方法：

- 无状态（Stateless）：每一个进入的记录独立于其他记录。不同记录间没有任何关系，他们可以独立处理和持久化。例如：`map`、`fliter`、静态数据 `join` 等等。
- 有状态（Stateful）：处理进入的记录依赖于之前记录处理的结果。因此，我们需要维护不同数据处理之间的中间信息。每一个进入的记录都可以读取和更新这个信息。我们把这个中间信息称作状态（State）。例如，独立键的计数聚合，去重等等。

### 流计算的状态

状态（State）在流计算是一个宽泛概念的词汇；继续之前，我们先明确下个定义。状态（State）字面意思就是“中间信息（Intermediate Information）”。

在流计算中，有两种中间状态（State）：

1. 过程状态：它是流计算的元数据（metadata）；追踪历史至今被处理的数据。在流的世界中，我称之为打点（checkpoint）或者保存数据的偏移（offset）。为了防止重启，升级或者任务失败，它需要容错（fault tolerance）。这个信息是任何高可靠流处理的基本，同时被无状态和状态处理需要。
2. 数据状态（正在被处理的）：这些中间数据源自数据（目前为止处理过的），它需要在记录之间维护。这个只在状态模式下，需要处理。

在流中，当我们谈论状态（State）的时候，它一般指的是数据的状态（即第二个，除非明确提到偏移或者过程状态）。

### 状态储存

为了维护状态流处理中的状态，我们需要状态存储器。它可以是内存（如 HashMap） 、文件系统（如 hdfs）、分布式数据库（如 Cassandra）亦或是嵌入式存储（如 RocksDb）。
状态存储的目的是为引擎读写提供可靠的地方。

稳重，我们将深度了解 Structured Streaming 中状态存储的内部实现机制。得益于这个实现，才能在驱动器或者执行器失败的情况下，Spark 可以可靠地将流恢复到失败之前的点。

虽然我们尽可能让它读起来简单易懂，一些 Spark 的基础支持还是需要了解。

### DStream/Spark Streaming 的状态管理

我们生活在一个不断进化的世界中。因为旧的东西不够好，导致有新的东西不断涌现。

> 引用自：[State Management in Spark Structured Streaming](https://medium.com/@chandanbaranwal/state-management-in-spark-structured-streaming-aaa87b6c9d31)
