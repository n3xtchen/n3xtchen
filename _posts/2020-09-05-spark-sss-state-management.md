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

状态管理从元数据打点（checkpoint）中解藕出来，不在是 tasks/jobs 的一部分；并且是异步的，同时支持增量持久化。（哈哈哈，真香，有木有？^_^）

让我们深入了解下  Spark 2 的状态管理机制。

Structured Streaming 只提供了一种状态存储的实现：基于 HDFS 的状态管理（其实，Databrick（商业）、Quole（开源）已经提供了基于 RocksDB 的实现，大家可以了解下）。


> 引用自：[State Management in Spark Structured Streaming](https://medium.com/@chandanbaranwal/state-management-in-spark-structured-streaming-aaa87b6c9d31)
