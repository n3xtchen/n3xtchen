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

模式的运行时声明是很好的习惯。对于用户来说，操作数据时不用先把它载入到元数据系统
是很方便的。这意味着，如果你只要前几个字段，你只要声明这几个字段就好了。

但是，在产品系统，每天每小时运行相同的数据，你就会有一些大问题。第一，
无论你数据什么事变动，你都必须改变你的 Pig 脚本。第二，即使在 5 列的数据工作
良好，但是如果有 100 列的时候是很痛苦的。为了定位这些问题，Pig 提供了其他的
方式来载入模式；

如果你使用的载入函数已经知道数据的模式，函数将会和 Pig 沟通。（载入函数定义
Pig 读取数据的方式；）载入函数可能已经知道数据的模式，如果这些数据存储在元数据源
，例如 HCatalog；或者数据本身就存储着模式，例如 JSON。在这种情况，你不用在载入
数据的时候声明模式。不过你还是需要使用名称命名字段，因为在做错误检查的时候，
PIg 将会从载入函数获取模式：

    mdata = load 'mydata' using HCatLoader();
    cleansed    = filter mdata by name is not null;
    ...

如果出现你指定的模式和 loader 返回不一致，Pig 将会以loader 返回的模式为准。例如，
如果你指定一个字段为 long 类型，但是 loader 告诉你它是 int 类型，Pig 将会对它转化
成 int 类型。然而，如果它不能将你给的模式转化成适合 loader 的时候，它将会报错。

还有一种情况，你和载入函数都没有告诉该数据的结构。你可以使用位置编号来索引字段，
它是从 0 开始。语法之前已经说过了：`$n`，这里 n 是非负整数。Pig 默认把它当作
bytearray 类型，从你的实际操作，推断它的类型。

    --no_schema.pig
    daily = load 'NYSE_daily';
    calcs = foreach daily generate $7 / 1000, $3 * 100.0, SUBSTRING($0, 0, 1), $6 - $3;

在表达式中：

+ $7 / 1000 : 很容易推断出第八个位置的数据类型可以是任何能转化哼整数的类型
+ $3 * 100.0：第3个位置的数据类型应该是浮点型
+ SUBSTRING($0, 0, 1)：能进行字符操作就很容易推断出她是 chararray 类型
+ $6 - $3：`-` 在 Pig 中只能用于数值运算

这样，Pig 就能很容易和安全地推断出他们实际的类型。当然，Pig 并不是完全智能的：

    --no_schema_filter
    daily = load 'NYSE_daily';
    fltrd = filter daily by $6 > $3;

`>` 对于数值，字符，字节类型都有效，因此 Pig 不能做出准确的判断。这时，都默认当作
字节类型处理。

还有一种使 Pig 失去判断力的情况：

    --unintended_walks.pig
    player = load 'baseball' as (name:chararray, team:chararray,
            pos:bag{t:(p:chararray)}, bat:map[]);
    unintended = foreach player generate bat#'base_on_balls' - bat#'ibbs';

因为 map 中的值可以是任何类型，Pig 不知道 bat#'base_on_balls' 和 bat#'ibbs' 到底
是什么类型。基于该字段的用法，Pig 将假设该字段是 doubles 类型。但是，实际上它是
 int 类型。

 另外还有一种情况，当有模式的数据和无模式的数据进行联表，产生的结果的模式将会全丢失：

    --no_schema_join.pig
    divs = load 'NYSE_dividends' as (exchange, stock_symbol, date, dividends); 
    daily = load 'NYSE_daily';
    jnd = join divs by stock_symbol, daily by $1;

这个例子中，Pig 不知道 daily 的模式，所以它就理解 divs 和 daily 联表后的数据模式了。


