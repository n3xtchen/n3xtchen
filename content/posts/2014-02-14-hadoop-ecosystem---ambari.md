---
categories:
- Hadoop
date: "2014-02-14T00:00:00Z"
description: ""
tagline: 提供 Hadoop 集群配置，管理和监控的框架
tags:
- hadoop
- installation
title: Hadoop 生态系统 - Ambari
---

Apache Ambari 提供了 Hadoop 集群的配置，管理和监控，100%的开源框架；它包括操作
工具的集合，以及强大的 API 接口来隐藏 Hadoop 的复杂度，简化集群操作。

### Ambari 的功能

+ 配置 Hadoop 集群
    无论你的集群规模多大，服务器的部署和维护都可以使用 Ambari 简化。Ambari 
    提供直观的 Web 界面，使你能更加简单的对 Hadoop 所有服务和核心组件 进行配置
    和测试

+ 管理 Hadoop 集群
    Ambari 提供简化集群管理的工具。Web 界面允许你启动/停止/测试 Hadoop 服务，
    改变配置和管理集群的持续的增长

    ![configure](http://hortonworks.com/wp-content/uploads/2013/01/ambari-hdfs.jpg)

+ 监控 Hadoop 集群
    深度了解集群的健康状态。Ambari 预先配置监控 Hadoop 服务的警告，以及使用简单
    WEB 界面对集群操作数据可视化展示

    ![monitor](http://hortonworks.com/wp-content/uploads/2013/01/ambari-metrics.jpg)

+ 整合 Hadoop 到其他应用
    Ambari 提供 Rest 接口使得它能和现有工具整合，例如 MS Center，Teradata Viewpiont。
    Ambari 还可以利用标准的技术和协议，例如 Nagios 和 Ganglia，来进行深度定制。

    ![integeration](http://hortonworks.com/wp-content/uploads/2013/02/ambari-jobs-swim-dag.jpeg)

### Ambari 的工作原理

Hadoop 集群的部署和持续的管理可能是一个非常复杂的任务，尤其是拥有成千上万台的
主机。Ambari 提供一种简单的控制，来查看，更新和管理 Hadoop 服务生命周期；
只要特征如下：

+ 向导式跨服务器 Hadoop 服务的安装
+ 对 Hadoop 服务和组件进行粗力度配置
+ 使用 Ganglia 进行指标收集，Nagios 进行系统提醒
+ 高级的工作诊断和故障检修工具
+ 强大的 Rest 接口来定制和整合企业系统
+ 集群热图
