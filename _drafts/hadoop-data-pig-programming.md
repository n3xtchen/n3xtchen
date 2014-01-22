---
layout: post
title: "Data Pig - Pig Latin 基础"
description: ""
category: Hadoop
tags: [Hadoop, Pig]
---
{% include JB/setup %}

通过三个章节的铺垫，现在开始深入了解 Pig 专属语言的 Pig Latin；
再次强调下， *Pig Latin 是一门数据流语言（dataflow languag）*。

### 关系（relation）和字段（field）的命名

每一个操作步骤都会产生新的数据集，或者关系。举个例子，看下面的代码：

    input   = load 'data';

`input` 是载入 data 数据的关系（relation）名。关系名看起来想一个变量；实际上，
他们并不是。一旦创建，这个赋值是永久的。但是关系名只是一个别名（alias），它可以
被重复赋值，会覆盖之前的关系，例如：

    input   = load 'data' as (id, amount);
    input    = filter input by amount > 0;

*关系（relation）名和字段（field）都必须字母打头，然后之后可以是数字，字母或者
下划线的任意组合。所有名称的字符必须符合 ASCII 标准。*

### 大小写敏感（Case Sensitivity）

Pig Latin 中的的*保留字（keywords）*是*大小写不敏感*的，例如， `LOAD` 等同于 `load`；

但是，*关系和字段名是大小写敏感的；用户自定义的函数（UDF）也是大小写敏感的；*

### 注释（Comments）

+ 单行注释：`--`；
+ 多行注释：

    /* 
       在这里注释
     */

### 输入（input）和输出（output）

开搞前，你必须知道如何输出和输出数据。

#### Load

数据流的第一步就是指定你的输入。

    input   = load '路径' [using LoadFunction(args)];


##### 路径

    input   = load 'HDFS 中的绝对路径';
    input   = load './相对路径'；

Pig 默认是在你的 HDFS 的 Home 目录下，/users/youlogin，执行的；

    input   = load '../pig_home/dataset';

它将在你的 Home 目录的上一级目录的 pig_home 目录中的 dataset 文件中查找数据；
当然让你改变你的目录位置，那所有的相对路径以那里作为基准。

Pig 还支持以 URL 路径来查找数据；

    input   = load 'hdfs://nn.n3xt.com/data/examples/dataset'

除了指定文件路径，你还可以传入`目录`，这样 Pig 就会载入该目录的所有文件。

##### 加载函数（Loading Function）

默认情况下，`load` 使用默认的加载函数 `PigStorage` 在 HDFS 中的制表符分隔
（tab-delimited）的文件中寻找数据的；

实际上，你的大部分数据并不是以制表符分隔的，你也有可能载入 HDFS 之外的存储器中
的数据。Pig 允许你是用 `using` 语句来指定载入函数，例如

    log = load '/path/to/log' using PigStorage(',');   -- 以逗号分隔的方式载入数据
    log = load '/path/to/log' using HBaseStorage(); -- 使用 HBase

Pig 有两个内建的加载函数，`PigStorage` 和 `TextLoader`，来操作 HDFS 上的文件，并
支持 glob（载入匹配模式的文件和目录）。使用 glob，你可以读取在不同目录下的多个
文件，或者同一目录的部分文件。

Glob 匹配符：

+ ? ：任意单字符
+ * ：0到多个字符
+ [abc] ：匹配其中的一个字符
+ [a-z] ：匹配任意一个小写字母
+ [^abd]    ：匹配任一不属于该字符集的字符
+ \    ：转移特殊富豪
+ {ab,cd}   ：匹配字符串集中的任意一个

##### 定义数据模式（Scheme）

`load` 可以使用 `as` 来指定你的数据模式：

    log = load "path/to/log" as (u_id, login_time); -- data 是关系名

> 模式的定义详见：()[]

#### Store

`Load` 的反向工作，语法如下：

    store data into `/path/to/storage` [using storageFunction()];

几种用法的范例：

    -- 使用默认的 PigStorage 存储在 HDFS 上，并使用制表符分隔
    store processed into '/data/examples/processed';
    -- 使用 hbase 存储
    store processed into 'processed' using HBaseStorage();
    -- 字段使用逗号分隔
    store processed into 'processed' using PigStorage(',');

*Note*，上述的 processed 将会是一个文件夹，里面包含多个数据文件，而不是单个文件。
数据文件的个数取决于并行计算工作及它的工作并行程度。

#### Dump

大部分情况，你是要把处理完的数据存储起来；但是有时你需要在屏幕看结果。这个在调试
和构建模型的过程时非常有用；

    dump processed;

### 关系操作（Relational Operations）

关系操作是 Pig 操作数据的主要工具。它允许你通过排序，分组，连表，映射以及筛选来转
换你 你的数据。

#### foreach

`foreach` 可以使用表达式，并把它应用到数据管道中的每一条数据。从这个表达式中生成
新的数据并传递给下一个操作器。

    A   = load 'input' as (user:chararray, id:long, phone:chararray);
    B   = foreach A generate user, id;

##### foreach 中使用的表达式

foreach 支持表达式数组；最简单的就是常量和字段索引。常量我们已经在之前数据类型中
讨论过了。字段索引可以通过字段名或者位置。位置索引（Positional references）是使用
`$` 和从0开始的整数：

    prices = load 'NYSE_daily' as (exchange, symbol, date, open, high, low, close, volume, adj_close);
    gain = foreach prices generate close - open; 
    gain2 = foreach prices generate $6 - $3;

gain 和 gain2 中存储的数据是一样的。位置风格的索引在某种情况下是非常有用的，例如不确定数据结构的情况下。

字段集的操作：

    prices = load 'NYSE_daily' as (exchange, symbol, date, open, high, low, close, volume, adj_close);

    -- 截取数据字段从开头到 open 字段位置，包括 open
    beginning = foreach prices generate ..open; -- produces exchange, symbol, date, open 

    -- 截取数据字段从 open 字段和 close 字段之间的字段，包括 open 和 close
    middle = foreach prices generate open..close; -- produces open, high, low, close 

    -- 截取数据字段从 volumn 字段开始到结尾的位置，包括 volumn
    end = foreach prices generate volume..; -- produces volume, adj_close

另外，Pig 还支持标准的算数操作：

+ \+ 加
+ \- 减
+ \* 乘
+ /   除
+ % 取模
+ ?:    三元表达式

从复杂的数据结构中提取数据：

    -- Map 映射
    -- 如果在 Map 找不到相应的映射，则 null
    bball = load 'baseball' as (name:chararray, team:chararray, 
            position:bag{t:(p:chararray)}, bat:map[]);
    -- 在字段 bat 中寻找 batting_average 的值
    avg = foreach bball generate bat#'batting_average';

    -- 元组映射
    A = load 'input' as (t:tuple(x:int, y:int)); 
    B = foreach A generate t.x, t.$1;

    -- Bag 映射
    A = load 'input' as (b:bag{t:(x:int, y:int)}); 
    B = foreach A generate b.x;
    C = foreach A generate b.(x, y);    -- <=> b.x, b.y

元组和 Bag 是通过点号（.）来调用数据的，Map 则是使用井号（#）。









