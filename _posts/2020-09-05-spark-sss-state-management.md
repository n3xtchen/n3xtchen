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


> 引用自：[State Management in Spark Structured Streaming](https://medium.com/@chandanbaranwal/state-management-in-spark-structured-streaming-aaa87b6c9d31)
