---
categories:
- Hadoop
date: "2014-02-14T00:00:00Z"
description: ""
tagline: 可靠的协调分布式进程的开源服务器
tags:
- hadoop
title: Hadoop 生态系统 - ZooKeeper
---

Apache ZooKeeper 为 Hadoop 集群提供操作服务。它提供了一个分布配置服务，一个同步
服务和一个命名注册表。分布式程序是使用 ZooKeeper 存储和调节重要配置信息的更新。

### ZooKeeper 的功能

ZooKeeper 提供一个非常简单的接口和服务。关键功能如下：

+ 快速：ZooKeeper 在读多谢少的工作场景下异常快。理想的读写比率是 10:1
+ 可靠：ZooKeeper 在一个服务器主机集群间同步，服务器可以相互识别。只要指定数量
的服务器可用，ZooKeeper 服务就可用。不会有单点失败。
+ 简单：ZooKeeper 维护标准层级的名称空间，类似于文件和目录
+ 有序：服务维护所有交易的记录，它可以用于高级抽象，例如同步通信原语（synchronization primitives）

> *同步通信原语*：当一个进程调用一个send原语时，在消息开始发送后，发送进程便
处于阻塞状态，直至消息完全发送完毕，send原语的后继语句才能继续执行。

### ZooKeeper 的工作原理

ZooKeeper 允许通过一个数据寄存器的共享层次名称空间，在分布式进程之间相互协调，
被成为 znodes。每一个 znode 根据路径辨别（路径使用斜杆 “/" 分割）。除了根目录，
每一个 znode 有一个父节点，如果它有子节点则不能删除。

它非常像普通的文件系统，但是 ZooKeeper 通过冗余服务提供卓越的可靠。一个服务在多台
机子间同步，各自维护一分数据树的内存镜像和交易日志。客户端连接单独的 ZooKeeper 
服务器和保持 TCP 连接。

这样的架构允许 ZooKeeper 提供最低冗余的高穿透力和可用性，但是 ZooKeeper 能管理
的数据大小收到内存的限制。
