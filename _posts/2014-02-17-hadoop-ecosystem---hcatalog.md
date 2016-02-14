---
layout: post
title: "Hadoop 生态系统 - HCatalog"
tagline: "将 Hive 的元数据共享给其他应用的数据表和存储管理服务"
description: ""
category: Hadoop
tags: [hadoop, hive, hcat]
---
{% include JB/setup %}

Apache HCatalog 是基于 Hadoop 之上的数据表和存储管理服务，让用户可以使用不同
的工具来（例如，Pig，MR 和 Hive）读写网格的数据。HCatalog 是以 HDFS 的数据关
系视图的形式来呈现给用户的，确保用户不需要关心数据的存储形式和存储方式。
HCatalog 可以以RCFile，文本文件或者制表符式的序列文件。它也提供 Rest 接口让
外部系统访问这些表的元数据。

### HCatalog 的功能

+ 利用表抽象，解放用户，使它们不用必须了解数据的存储位置和形式
+ 可以提示数据可用性
+ 提供可视化数据清洗和压缩工具

### HCatalog 的工作原理

HCatalog 支持任何 Hive SerDe（serializer-descerializer，序列和反序列）能处理
的形式的文件读写。默认，HCatalog 支持 RCFile，CSV，JSON 和序列文件格式。如果
你想要自定义格式，你需要提供输出格式，输出格式以及序列和反序列的方法。

HCatalog 是尽力在 Hive  源数据智商的，可以使用 Hive DDL 的组件。HCatalog 提
供读写接口给 Pig ，MR 使用，使用 Hive 的命令行接口来执行数据定义和元数据探索
命令。它也提供了 Rest 接口来允许外部工具访问 Hive DDL 操作，例如，`CREATE 
TABLE` 和 `DESCRIBE TABLE`。

HCatalog 展现了数据的关系视图。数据存储在表中，这些表存在数据库中。表可以以
一个或多个键进行分区。对于一个给予的键，将使用一个分区来存储包含一个共同键值
的所有行数据。

> *RCFile* 是Hive推出的一种专门面向列的数据格式。 它遵循“先按列划分，再垂直
划分”的设计理念。当查询过程中，针对它并不关心的列时，它会在IO上跳过这些列。
