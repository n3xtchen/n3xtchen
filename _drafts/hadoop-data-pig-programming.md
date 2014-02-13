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

    input   = LOAD 'data';

`input` 是载入 data 数据的关系（relation）名。关系名看起来想一个变量；实际上，
他们并不是。一旦创建，这个赋值是永久的。但是关系名只是一个别名（aliAS），它可以
被重复赋值，会覆盖之前的关系，例如：

    input   = LOAD 'data' AS (id, amount);
    input   = FILTER input BY amount > 0;

*关系（relation）名和字段（field）都必须字母打头，然后之后可以是数字，字母或
者下划线的任意组合。所有名称的字符必须符合 ASCII 标准。*

### 大小写敏感（Case Sensitivity）

Pig Latin 中的的*保留字（keywords）*是*大小写不敏感*的，例如， `LOAD` 等同于 `LOAD`；

但是，*关系和字段名是大小写敏感的；用户自定义的函数（UDF）也是大小写敏感的；*

### 注释（Comments）

+ 单行注释：`--`；
+ 多行注释：

    /\* 
       在这里注释
     \*/

### 输入（input）和输出（output）

开搞前，你必须知道如何输出和输出数据。

#### 载入（LOAD）

数据流的第一步就是指定你的输入。

    input   = LOAD '路径' [USING LoadFunction(args)];

##### 路径

    input   = LOAD 'HDFS 中的绝对路径';
    input   = LOAD './相对路径'；

Pig 默认是在你的 HDFS 的 Home 目录下，/users/youlogin，执行的；

    input   = LOAD '../pig_home/dataset';

它将在你的 Home 目录的上一级目录的 pig_home 目录中的 datASet 文件中查找数据
；当然让你改变你的目录位置，那所有的相对路径以那里作为基准。

Pig 还支持以 URL 路径来查找数据；

    input   = LOAD 'hdfs://nn.n3xt.com/data/examples/datASet'

除了指定文件路径，你还可以传入`目录`，这样 Pig 就会载入该目录的所有文件。

##### 加载函数（loading Function）

默认情况下，`LOAD` 使用默认的加载函数 `PigStorage` 在 HDFS 中的制表符分隔
（tab-delimited）的文件中寻找数据的；

实际上，你的大部分数据并不是以制表符分隔的，你也有可能载入 HDFS 之外的存储器
中的数据。Pig 允许你是用 `USING` 语句来指定载入函数，例如

    log = LOAD '/path/to/log' USING PigStorage(',');   
    -- 以逗号分隔的方式载入数据
    log = LOAD '/path/to/log' USING HBaseStorage(); -- 使用 HBase

Pig 有两个内建的加载函数，`PigStorage` 和 `TextLOADer`，来操作 HDFS 上的文件
，并支持 glob（载入匹配模式的文件和目录）。使用 glob，你可以读取在不同目录下
的多个文件，或者同一目录的部分文件。

Glob 匹配符：

+ ? ：任意单字符
+ \* ：0到多个字符
+ [abc] ：匹配其中的一个字符
+ [a-z] ：匹配任意一个小写字母
+ [^abd]    ：匹配任一不属于该字符集的字符
+ \    ：转移特殊富豪
+ {ab,cd}   ：匹配字符串集中的任意一个

##### 定义数据模式（Scheme）

`LOAD` 可以使用 `AS` 来指定你的数据模式：

    log = LOAD "path/to/log" AS (u_id, login_time); -- data 是关系名

> 模式的定义详见：()[]

#### 存储（STORE）

`LOAD` 的反向工作，语法如下：

    STORE data INTO `/path/to/storage` [USING storageFunction()];

几种用法的范例：

    -- 使用默认的 PigStorage 存储在 HDFS 上，并使用制表符分隔
    STORE processed INTO '/data/examples/processed';
    -- 使用 HBase 存储
    STORE processed INTO 'processed' USING HBaseStorage();
    -- 字段使用逗号分隔
    STORE processed INTO 'processed' USING PigStorage(',');

*Note*，上述的 processed 将会是一个文件夹，里面包含多个数据文件，而不是单个
文件。数据文件的个数取决于并行计算工作及它的工作并行程度。

#### DUMP 输出

大部分情况，你是要把处理完的数据存储起来；但是有时你需要在屏幕看结果。这个在
调试和构建模型的过程时非常有用；

    DUMP processed;

> ### 关系操作（Relational Operations）
> 
> 关系操作是 Pig 操作数据的主要工具。它允许你通过排序，分组，连表，映射以及i> 筛选来转换你的数据。

### 循环 FOREACH

`FOREACH` 可以使用表达式，并把它应用到数据管道中的每一条数据。从这个表达式中
生成新的数据并传递给下一个操作器。

    A   = LOAD 'input' AS (user:chararray, id:long, phone:chararray);
    B   = FOREACH A GENERATE user, id;

#### FOREACH 中使用的表达式

FOREACH 支持表达式数组；最简单的就是常量和字段索引。常量我们已经在之前数据类
型中讨论过了。字段索引可以通过字段名或者位置。位置索引（Positional 
references）是使用 `$` 和从0开始的整数：

    prices = LOAD 'NYSE_daily' AS (exchange, symbol, date, open, 
            high, low, close, volume, adj_close);
    gain = FOREACH prices GENERATE close - open; 
    gain2 = FOREACH prices GENERATE $6 - $3;

gain 和 gain2 中存储的数据是一样的。位置风格的索引在某种情况下是非常有用的，
例如不确定数据结构的情况下。

字段集的操作：

    prices = LOAD 'NYSE_daily' AS (exchange, symbol, date, open, 
            high, low, close, volume, adj_close);

    -- 截取数据字段从开头到 open 字段位置，包括 open
    beginning = FOREACH prices GENERATE ..open; 
    -- produces exchange, symbol, date, open 

    -- 截取数据字段从 open 字段和 close 字段之间的字段，包括 open 和 close
    middle = FOREACH prices GENERATE open..close; 
    -- produces open, high, low, close 

    -- 截取数据字段从 volumn 字段开始到结尾的位置，包括 volumn
    end = FOREACH prices GENERATE volume..; 
    -- produces volume, adj_close

另外，Pig 还支持标准的算数操作：

+ \+ 加
+ \- 减
+ \* 乘
+ /   除
+ % 取模
+ ?:    三元表达式，三元表达式应该使用括号包围起来

*Note:* 三元表达式的返回值的类型必须相同；如果条件返回空，结果也将是空：

    1 == 1 ? 1 : 'yo'   -- 这将会报错，
    NULL == 2 ? 2 : 4   -- 结果将会返回 NULL

从复杂的数据结构中提取数据：

    -- Map 映射
    -- 如果在 Map 找不到相应的映射，则 NULL
    bball = LOAD 'bASeball' AS (name:chararray, team:chararray, 
            position:bag{t:(p:chararray)}, bat:map[]);
    -- 在字段 bat 中寻找 batting_average 的值
    avg = FOREACH bball GENERATE bat#'batting_average';

    -- 元组映射
    A = LOAD 'input' AS (t:tuple(x:int, y:int)); 
    B = FOREACH A GENERATE t.x, t.$1;

    -- Bag 映射
    A = LOAD 'input' AS (b:bag{t:(x:int, y:int)}); 
    B = FOREACH A GENERATE b.x;
    C = FOREACH A GENERATE b.(x, y);
    -- <=> b.x, b.y

元组和 Bag 是通过点号（.）来调用数据的，Map 则是使用井号（#）。

#### FOREACH 中的用户自定义函数（UDF）

UDFs 可以在 FOREACH 中定义。这里我们称之为求值函数（eval funcs）。因为他们是
freach 语句的一部分，所以 UDFs 每次只能处理一条记录和产生一条输出。例如，如
下的 UPPER 函数来处理每条记录：

    -- FOREACH_udf.pig
    divs    = LOAD 'data/names' AS (name);
    upper   = FOREACH divs GENERATE name, UPPER(name);
    DUMP upper;

UDFs 可以接受 * 作为参数，表示传入的的一整条记录。

具体 UDF 用法和相关函数我们将在后面的专题介绍，这里一笔带过。

#### FOREACH 的字段命名

Pig 可以对每个字段的类型进行推断，但是它不能对这些字段的名称进行推断。

如果只是对字段的简单映射（Projection），Pig 会保持之前的名称：

    divs    = 'data/names' AS (name);
    name    = FOREACH divs GENERATE name;
    DESCRIBE name;   
    
    -- 返回：name:{name: chararray}
    -- `DESCRIBE` 可以打印数据结构 

但是使用任何表达式应用在普通的映射之上的话，Pig 就无法给这个字段命名了，如果
你没有明确制定名称，这个字段将无名称，只能通过位置参数来访问（例如，$0）;
你可以使用 AS 来命名该字段：

    divs    = LOAD 'data/names' AS (name);
    name    = FOREACH divs GENERATE name AS key, UPPER(name);
    DESCRIBE name;   
    
    -- 返回：name:{key: chararray, chararray}

### 筛选（Filter）

`FILTER` 允许你从数据管道中选择你想要的记录；它包含一个断言，如果断言为真，
则传入管道中，反之被抛弃。

断言（predicates）可以包含: ==、 !=、 >、 >=、 < 以及 <=。这些对比表达式可以
用在任何基础数据类型中。== 和 != 还可以用在 map 和tuple 数据类型上。如果将
他们用在两个 tuple 上，那这两个元组必须是模式相同或者无模式的。相等操作不可
以用在 bag 类型上。

Pig Latin 也和大部分语言一样，操作符拥有优先等级，算术（arithnetic）操作符
优先于相等运算符。因此，x+y == a+b <=> (x+y) == (a+b).

    --  filter_basic.pig
    lang_age = LOAD 'data/progLang_age' AS (progLang:chararray, birthd  ay:int);

    ancient = FILTER lang_age BY birthday < 1980;
    DUMP ancient;
    -- 筛选出开发起始时间在 1980 之前的程序语言

    对于字符串，你可以使用关键字 `matches` 和正则表达式来正则匹配：

    FILTER data_pineline BY [NOT] field_name MATCHES '正则写在这'；

例子：

    -- filter_chararray.pig
    lang_age = LOAD 'data/progLang_age' AS (progLang:chararray, 
            birthday:int);
    InitialP = FILTER lang_age BY progLang MATCHES 'P.*';
    DUMP InitialP;
    
    -- 筛选出语言名称以 P 打头的程序语言

*Note:* Pig 使用 Java 的正则表达式的格式。他是全匹配的，不想 perl 那样的部分
匹配。例如，如果你想要查找字段包含 prog 的字符，表达式必须写成 `.*prog.*`，
而不是 `prog`；后者只能匹配到 prog 这个字符串。

你还可以使用布尔操作符（AND、OR 和 NOT）来组合多个断言；另外这三个的优先级
如下：
    NOT > AND > OR

它遵循短环布尔操作，就是如果表达式提前别断言为 false 它将不会继续执行下去
，而是直接返回。

*Note:* NULL 遵循 SQL 逻辑，空值代表非真和假，空值不会和任何正则表达式匹配成
功。

### 分组（Group）

`GROUP` 语句将拥有相同健的数据汇总在一块。如果你学习过 SQL，对这个概念再熟悉
不过了，但是 Pig 的分组操作和 SQL 存在本质上的区别，这个是你必须注意的。在
SQL 中，`GROUP BY` 语句创建分组，直接传递给一个或多个聚合（Aggregate）函数。
在 Pig 中，分组和聚合没有必然的联系；它的分组更纯粹：它的工作就是将数据分组
，并存储在 bag 中。如果你需要聚合，你可以这么操作：

    -- group_basic.pig
    rock_stars   = LOAD 'data/RockNRollHallOfFrame'
        USING PigStorage(',')
        AS (joined_year:int, band_name:chararray);
    
    grpd    = GROUP rock_stars BY joined_year;
    cnt = FOREACH grpd GENERATE group, COUNT(rock_stars);
    
    DUMP cnt;

    -- 每个摇滚名人堂年度被评上的乐队个数

分组的数据在 Pig 中是如何呈现的呢？让我们 `DESCRIBE` 下吧！

    -- 这是上述 grpd 的结构
    grpd: {group: int,rock_stars: {(joined_year: int,band_name: chararray)}}
    -- group 存储的是键，这里是获奖年度，
    -- 后面是拥有该键的所有记录组成的元组

你可以将分组的数据存储起来，以备后面处理：

    STORE grpd INTO 'data/by_year';

用过 SQL 的都知道，有时候不仅仅只对一个键来分组：

    -- group_multi.pig
    artists = LOAD 'data/RockNRollHallOfFrameSidemen'
        USING PigStorage(',')
        AS (year:int, name:chararray, instrument:chararray);  5
    multi_grpd    = GROUP artists BY (year, instrument);

    DUMP multi_grpd;

     -- 按照使用乐器和入选年限对摇滚默默奉献奖进行分组


*Note:* 组合键是使用元组来呈现。

你还可以有使用 `ALL` 将所有记录组合起来：

    -- group_all.pig
    artists = LOAD 'data/RockNRollHallOfFrameMultipleInductees'
        USING PigStorage(',');

    grpd_all    = GROUP artists ALL;

    cnt = FOREACH grpd_all GENERATE COUNT(artists);

    DUMP cnt;
    -- 这就是 ALL 的其中一个用于，聚合计算出记录条数

由于根据键来分组数据，你经常会得到不对称的结果。那是因为你无法决定每个键最终
分配到数据的条数给相应 reducer。例如，你有一分网页链接索引，你需要对他们的
域名分组。像 sohu.com 这样类型的门户网站的实际数量肯定要比大部分网站的多好几
个 量级。这样，sohu.com 这个键的 reducer 获得的数据远比其他的要多很多。由于
你的 MapReduce 工作需要你的所有的 reducer 都完成之后才能结束，这样数据分配不
均大大地降低了处理效率。而且有时，一个 reducer 也不可能管理那么多的数据。

Pig 为了解决这样的不均衡提供很多种方式。Hadoop 的联结器（Combiner）就是其中
一种方式，这里不具体阐述。虽然它并不能完全的均衡，总有限制它的边界就可以了。
因为 Mapper 的数量可能成千上万，即使 reducer 得到不均衡的记录，如果每个 
reducer 的数据足够小,那它就能快速的处理它，就不会被阻塞。

不幸的是，并不是所有的计算都可以使用 combiner。线性相关的计算能很好的适应
combiner。
<!--
能将计算步骤分解的，例如 sum
，就是所谓的可分配的（代数的分配律）。这些都能很好的适应 combiner。能分解成
初始化，中间步骤
和结束的计算的计算，被我们称为代数。计数就是一个例子，出事步骤是计数，中
间和结束步骤都是汇总。Distributive 就是代数相关的一种特性，它的初始化，中间
和最终步骤都是相同的。会话分析（Session Analysis），用来追踪用户行为，就是
非代数相关的计算，因为你开始分析的时候必须把所有的记录按照时间戳排序。
-->

Pig 的操作符和内置 UDF 都尽可能使用 combiner。由于 reduce 的不均衡，它在早期
聚合时大量的减少了数据的传输以及读写，因此大大提高的性能。UDF 可以通过应用
代数相关的接口（Algebraic Interface）来指定什么使用调用 combiner。后续将详细
说明。

### 排序（ORDER BY）

ORDER 语句将会产生你输出的数据的总排序。总排序（Total Order）意味着不仅仅在
各自的分区中排序，必须保证在第N个分区的所有记录都比第N-1个分区的顺序大。当
你的数据存储在 HDFS 中，每个分区都是一个文件，这意味将会按顺序输出数据。

ORDER 的语法和 GROUP 类似，

    -- order_basic.pig
    rock_stars  = LOAD 'data/RockNRollHallOfFrameInductees'
        USING PigStorage(',')
        AS (joined_year:int, band_name:chararray);

    -- 按照入选年度正序（不指定，默认为 ASC）排列
    by_year = ORDER rock_stars BY joined_year;
    
    -- 数据结构
    DESCRIBE by_year;   
    -- 结果：by_year: {joined_year: int,band_name: chararray}

    DUMP by_year;

和 GROUP 一样，它也支持多键排序：
















