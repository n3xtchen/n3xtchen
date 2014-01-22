---
layout: post
title: "Data Pig - 模式（Schema）"
description: ""
category: Hadoop
tags: [Hadoop, Pig]
---
{% include JB/setup %}

### 模式（Schema）

Pig 对数据的模式保持很宽松的态度。这是 Pig eat anyting 哲学导致的结果。如果你的\
数据模式可用，Pig 将会在错误检查或者优化的时候，使用它。但是，如果无模式，Pig \
仍然可以处理数据，它可以基于脚本来判断他的类型。首先，我们会寻找与 Pig 交互\
的模式；然后，我们会检查 Pig 处理模式未提供部分的处理方式。

最简单的方式就是直接明确告诉 Pig 处理数据的模式：

    dividends   = load 'NYSE_dividends' as
        (exchange:chararray, sybol:chararray, date:chararray, dividend: float);

这样，Pig 期待你的数据有四个字段。如果多了，多余的部分切割掉；少了使用 null 补齐
。

你也可以不指定模式，这些类型都会被默认当作 bytearray：

    dividends   = load 'NYSE_dividends' as
        (exhange, sybol, date, dividends);

模式的运行时声明是很棒的。对于用户来说，操作数据时不用先把它载入到元数据系统
是很方便的。这意味着，如果你只要前几个字段，你只要声明这几个字段就好了。

但是，在产品系统，每天每小时运行相同的数据，你就会有一些大问题。第一，
无论你数据什么事变动，你都必须改变你的 Pig 脚本。第二，即使在 5 列的数据工作
良好，但是如果有 100 列的时候是很痛苦的。为了定位这些问题，Pig 提供了其他的
方式来载入模式；

如果你使用的载入函数已经知道数据的模式，函数将会和 Pig 沟通。（载入函数定义
Pig 读取数据的方式；）
