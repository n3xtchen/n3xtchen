---
layout: post
title: "Hadoop 生态系统 - Knox Gateway"
tagline: "Hadoop 集群的单点安全访问级别"
description: ""
category: hadoop
tags: [hadoop, secure, auth]
---
{% include JB/setup %}

Know Gateway（简称 knox）是为 Hadoop 集群提供单点验证和访问。这个项目的目的是
为访问集群数据数据和执行工作（jobs）的用户，和控制和管理集群的运营商简化了
Hadoop 安全。Knox 作为服务运行，并为整个 Hadoop 集群服务。

### Knox 的优势

+ 提供外围（perimeter）安全使得 Hadoop 安全更容易部署
+ 支持身份验证和令牌（token）验证方案
+ 支持单一集群端点访问不同集群的数据和工作（job）
+ 支持企业和云验证管理环境的整合
+ 支持跨集群跨版本安全管理

### Know 的工作原理

Knox 只在提供外围安全，使其容易集成到现有的安全机制中。为 Hadoop 生态提供
安全是一个关键的社区项目。为了更有效以及成为社区的一部分，Knox 需要更紧密地
融合到 Hadoop 中。

目前，Hadoop 集群是作为独立服务的松散集合的形式呈现给用户的。由于每一个服务都
有各自的访问方法和安全控制，使得对用户访问 Hadoop 造成困难。Hadoop 的配置和
管理是很复杂的；因此很多 Hadoop 管理员被迫使不得不减慢 Hadoop 部署的进程或者
直接放弃安全了。

这个项目的目的就是为了覆盖当前所有存在的 Hadoop 生态相关的项目。另外，这个项目
的拓展性足以为（不改动源码的前提下）兼容未来的 Hadoop 开发组件。Knox 期望运行
在 DMZ 环境（无安全机制），这样它可以控制多个 Hadoop 服务的访问。这样，Hadoop
就可以在带有访问控制的防火墙（firewall）中安全运行了。安全认证组件将会是模块化
以及可拓展的，容易集成到现有的安全机制中。






