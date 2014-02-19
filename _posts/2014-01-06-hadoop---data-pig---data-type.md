---
layout: post
title: "Data Pig - 数据类型和数据结构"
description: ""
category: Hadoop
tags: [hadoop, pig, schema]
---
{% include JB/setup %}

Pig 数据类型主要分为两种类型：标量（Scalar）类型，它只包含单一的值；复合（Complex）类型，它可以包含多个值，可以是不同类型。

### 标量类型（Scalar Type）

Pig 的标量类型和其他语言的类似，都是简单的类型。除了 byteArray 之外，其他的都可以
在 java.lang 类中找到相对应的类型，这样使得 UDF（用户定制函数）更容易构建：

#### 整型 int

整数。Ints 在 Java 中对应的类是 Java.lang.Integer；4位有符号整型；表达形式为整数
，例如 42；

#### 长整型 long

长整数。Longs 在 Java 中对应的类是 Java.lang.Long；8位有符号的整型；表达形式为
整数＋L后缀，例如 500000000L；

#### 浮点型 float

浮点型数字。Floats 在 Java 中对应的类是 Java.lang.Float；4位字节；表达形式为
浮点数＋f 后缀，例如 3.14f；或者指数表达形式，例如 6.022e23f;

#### 双精度浮点型 double

双精度点型数字。Doubles 在 Java 中对应的类是 Java.lang.Double；4位字节；表达形式
为浮点数，例如 3.1415926；或者指数表达形式，例如 6.022e-34;

> ##### 注释
> 你可以在 http:gi/java.sun.com/docs/books/jls/ third_edition/html/typesValues.html#4.2.3.
> 网站上找到浮点型和双精度浮点型的取值范围。注意，因为是浮点数，所以在一些计算
> 时会导致精度缺失；如果需要保持精度，你应该使用 int 或者 float。

#### 字符数组 chararray

字符串或字符数组。Chararray 在 Java 中对应的类是 Java.lang.String。它的表达形式
是由单引号包围的字符串字画量，例如 'fred'。除了标准的字符和符号字符外，我们需要
使用反斜杠来转移部分特殊字符，比如, tab `\t`，换行符 `\n`。Unicode 字符使用
`\u` 前缀 ＋ 四位16进制的Unicode值；例如，`ctrl-A` 表达为 `\u0001`；

#### 字节数组 bytearray

一个大型2进制对象或者字节数组。Bytearrays 在 Java 中对应的类是 DataByteArray；
没有办法指定一个字节数组常量。

### 复合（Complex）类型

Pig 有三种复合数据类型：maps，tuples 和 bags。所有的这些类型都可以包含在其它的
符合类型中。因此，可能存在 map 类型的值中包含一个 bag，而这个 bag 中还包含了一个
元组。

#### Map

Pig 的 Map 数据是指字符串到数据元素的映射（Mapping），它的元素可以是任何 Pig 类型
，包括复合类型。字符串被称为键（Key），被用来作为索引来帮助查找元素。

因为 Pig 不知道值的类型，所以他将会假设值是一个字节码（Bytearray）。然而，实际的
值可能会有所不同。如果你知道它的实际类型，你就可以转换（Cast）它。如果你不对他做
类型转换，Pig 将会根据你的使用方法来作出最佳的假设。如果值不是 bytearray， Pig将
在运行时对他进行处理。

默认，Pig 没有要求 Map 中的各个值必须是同种类型。如果 map 中有姓名和年龄的话，也
是合法的。从 Pig 0.9 开始，Map 数据类型中的各个值必须是同种类型的；这是很有用，就
可以减轻系统的负担，不用遍历每一个元素。

Map 常量使用方括号［bracket］来界定该类型的，哈希键值，键值之间使用井号隔开，键值
对之间使用逗号（comma）隔开；例如，['name'#'bob','age'#55] 将会创建一个有两个键的
 map；第一个值是一个字符串，第二个值是一个整型。

#### 元组 Tuple

元组是一个可调整长度，有序的数据集合。元组包含多个字段（fields）；每个字段包含一
个数据元素；每一个字段可以是任何类型，不需要保持同种类型。元组类比 SQL 中的行。
还有元组是有序的，所以可以通过位置来取相应的值。元组可以，但不是必须，关联一个
模式（schema），用来描述各个字段的类型，还可以为字段提供一个名称，来方便取值。
这样使得允许用户检查元组的数据，通过字段名索引相应字段。

元组常量使用圆括号（paranthese）来指定，每个字段之间使用逗号（comma）隔开；例如，
('meo', 27)。

#### Bag

Bag 是一种无序元组的组合。因为他无序，所以他不能通过位子索引元素。和元组一样，它\
可以但不是必须有有一个模式（schema）来关联它。

Bag 常量使用花括号（braces），其中的元组（tuple）使用逗号（comma）隔开。例如，\
{('meo', 27), ('cm', 29), ('jl', 26)}。

Pig 用户通常会注意到，Pig 没有提供列表（list）和 set 类型。它可能是因为可以使用\
bag 来模拟一个 set，通过使用一个元素的元组来分装。虽然做法有点傻，但是它生效。

Bag 是 Pig 类型中，不需要受 内存限制的。你后面将会看到，因为他用来存储分组后的\
集合，所以 bag 可能很大。如果必要，Pig 可以把 bag 存储在磁盘中，只有 bag 中的\
部分存储在内存中。bag 到大小限制是可用的磁盘空间。

> ### Pig 数据的内存要求

> 在之前的章节，我都会提到每个类型存储的大小。这就是告诉你这个值占用多少内存。而\
> 不是告诉你存储这个值的对象的到校。Pig 使用 Java 对象内部呈现这些值；所以还需要\
> 多余的空间来存储它。这个多出来的空间取决于你使用的 JVM，但是通常占用 8 个字节\
> 。最糟糕的是字符串（chararray），因为 Java 字符串中的每个字符占用两个字节。
>
> 因此，如果你要计算 Pig 处理数据需要的存储量，不要计算硬盘中的字节数，而是算你\
> 需要的内存。硬盘和内存的乘积关系依赖你的数据，是否被压缩，还有你的磁盘格式等\
> 等。作为参考，存储在内存的一倍数据量，就需要四倍的磁盘空间（未压缩的）。

#### Nulls

Pig 的数据类型可以是空值（null）。任何类型的数据都可以为空。Pig 空值的概念和 SQL\
中的相同，但是完全不同与 C，Java，Python 等等语言的空值。Pig 中的空值意味着位置\
。可能由于数据丢失，处理时发生错误等等原因。在大部分过程（procedural）语言中，\
当未被设定或者未指向相应的地址或对象时被称作空。这样的差异导致 Pig 处理空值的方\
式差异很大。

不象 SQL，Pig 没有限制（constraints）的概念。根据 null 的定义，这意味着任何数据\
元素可以永远是空。这个需要在你编写 Pig 脚本时，需要牢记的。

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

### Enjoy It!!!
