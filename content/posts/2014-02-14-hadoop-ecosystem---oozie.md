---
categories:
- Hadoop
date: "2014-02-14T00:00:00Z"
description: ""
tagline: 调度你的 Hadoop 集群工作（job）
tags:
- hadoop
- workflow
title: Hadoop 生态系统 - Oozie
---

Apache Oozie 是一个用来调度 Hadoop 工作的 Java 网页应用。Ozzie 可以将多个工作
组装成一个工作逻辑单位。它被整合到 Hadoop 栈中，可以用来创建 MapReduce，Pig，
Hive 和 Apache Sqoop 的工作。它还可以用来调度其他系统的工作，例如 Java 程序以
及 Shell 脚本。

Ozzie 的工作可以分为两种：

+ **Ozzie 工作流（Workflow）**是 DAG（Directed Acyclical Graphs，有向无环图，有向
图中一个点经过两种路线到达另一个点未必形成环，因此有向无环图未必能转化成树，
但任何有向树均为有向无环图。），用来指定执行动作的队列。工作流工作必须等待
+ **Ozzie 协调器（Coordinator）** 是一个周期性的 Oozie 工作流工作，它绑定了时间
和可利用的数据
+ **Oozie Bundle** 提供一种可以打包多个协调器和工作流的方法来管理这些工作的生命
周期

### Ozzie 的用途

Oozie 允许 Hadoop 管理员将复杂的数据转化分割成多个组件任务。这需要对复杂工作
进行更有力的控制，也要简化在预定间隔时间内重复的工作。

Oozie 帮助管理员从 Hadoop 投资中得到更多的回报。

### Ozzie 的工作原理

Oozie 工作流是一个有向无环形式动作的集合。控制节点定义工作排气，设定启动和结束工作
流的规则，可以通过决定，分叉以及加入节点来控制工作执行路径。动作节点出发任务的执行。

Oozie 绑定工作流动作，由 Hadoop MapReduce 执行他们。它允许 Oozie 均衡 Hadoop 其他
栈的能力，可以平衡负载，处理失败。

Oozie 可以通过回调和计票的方法来探测任务的完成。当 Oozie 启动一个任务时，它提供一个
唯一的回调 HTTP URL 给任务，因此当完成的时候会通知这个 URL 。如果任务在调用回调 URL
失败的话，Oozie 也轮询完成的任务。

在规定的时间间隔内运行 Oozie 工作流是很有必要的，但是需要协调不可预期的可用数据或
事件。在这种情况下，Oozie 协调器允许你以数据，事件或事件推断的形式对工作流执行触发器
模型化。工作流只会在这些断言满足的情况下启动。

Oozie 协调器还可以根据子工作流的输出来管理多个工作流。子工作流的输出成为下一个子工作
流的输入。这个链条称作为数据应用管道（data application pipline）。
