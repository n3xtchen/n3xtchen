---
layout: post
title: "Data Pig - Pig 简介"
description: "Pig Eat Data"
category: Hadoop
tags: [Hadoop, Pig]
---
{% include JB/setup %}

### 什么是 Pig?

Pig 提供了一个引擎在 Hadoop 集群上并行执行数据流。他包含一个语言，Pig Latin，
用来表达这些数据流。Pig Latin 可以执行一些传统的数据的操作（join, sort, filter
等等），同时也能让用户开发自自己的函数用来读，处理和写数据。

### Hello, MapReduce

这边使用简单的单词计数程序演示 MapReduce。例子中，map 读取文本的每一行；然后拆成
一个词；shuffle 使用这些单词作为 key，并哈希化后传递给 reducers；reduce 将会汇总
起来计算它们出现的频度。这里有有一首打油诗 《Mary Had a Little Lamb》:

> Mary had a little lamb

> its fleece was white as a snow

> and everywhere that Mary went

> the lamb was sure to go

假设每一行发给不同的 map 任务。实际上，每一个 map 任务都会分配比这多的多的数据；
只是为了便于举例。

一旦 map 阶段完成，shuffle 阶段将会把相同的单词手机到相同的 reducer。这个例子，我
们假设有两个 reducers：所有单词分成两个：A-L 和 M-Z。每一个单词都将输出汇总个数。

Pig 使用 MapReduce 执行所有的数据处理。它把用户编写的 Pig Latin 脚本编译成一系列
一个或多个 MapReduce 构成的数据流，然后执行它。

    -- 载入名为 mary.txt 的文件
    -- 把每一行命名为 line
    my_input = load 'mary.txt' as (line)

    -- TOKENIZE 将一行拆分成单词
    -- flatten 将会获取 TOKENIZE 返回的集合，并为每个单词产生一条记录，并把他命名
    -- 为word
    words = foreach my_input generate flatten(TOKENIZE(line)) as word;

    -- 现在按每一个单词分组
    grpd = group words by word

    -- 计数
    cntd = foreach grpd generate group, COUNT(words);

    -- 打印结果
    dump cntd

当使用 Pig 时，我们不需要关心 map，shuffle 和 reduce。他将会分解操作到合适的任务中。

### Pig Latin，一个并行的数据流语言

Pig Latin 是一个数据流语言。这意味着它允许用户描述数据应该怎么被读取，处理，然后
存储。这些数据流可以是线性的，就象上一个例子；它也可能很复杂，包含多个输入源连接
，根据不同的操作输出给不同的输出源。为了精确（数学），Pig Latin 脚本可以被描述为
有向非循环图（DAG），边缘是数据流，节点是操作。

这意味着 Pig Latin 看起来和大部分语言不一样。在 Pig 中，没有 if, 没有 for。因为
传统的过程式或对象式编程都是控制流式的，而数据流是程序的副作用。 相反，Pig Latin
集中数据流。

#### 对比查询和数据流语言

大部分人都认为 Pig Latin 是 SQL 的过程式版本。虽然他们很相似，但是还是有很多不同
的。SQL 是允许用户描述他们想要的答案，而不是描述如何作答；而 Pig Latin 是需要用户
描述如何处理输入的信息。

另一个不同是SQL是面向回答问题的。当用户想要同时做几个数据操作时，他们必须分开写查
询语句，将结果存在临时表中，或用子查询。然而，很多 SQL 用户发现子查询很迷惑忍，而
且难以合适地编写。

Pig 是将一长串的数据操作在脑中设计，因此他们不需要在倒置的写数据管道或者担心存储
数据到临时的表中。

假设一个案例，用户想要为一张表基于一个键分组，然后和第二张表连接查询。因为连接查
询发生在分组查询之后的，它必须被表达为子查询，或者两个查询（使用临时表存储中间结
果）。

SQL 实现:

    CREATE TEMP TABLE t1 AS
    SELECT customer, sum(purchase) AS total_purchases
    FROM transations
    GROUP BY customer;

    SELECT customer, total_purchases, zipcode
    FROM t1, customer_profile
    WHERE t1.customer = customer_profile.customer;

Pig 实现:

    -- 载入 transactions 文件，以用户分组，汇总他的付款
    txns = load 'transactions' as (customer, purchase);
    grouped = group txns by customer;
    total   = foreach grouped generate group, SUM(txns.purchase) as tp;
    -- 载入 customer_profile 文件
    profile = load 'customer_profile' as (customer, zipcode);
    -- 连接分组汇总后的交易记录和用户档案数据
    answear = join total by group, profile by customer;
    -- 把结果写到屏幕上
    dump answear;

然而，他们各自设计的场景是不同的。SQL 是为关系数据库设计的，他存储的数据需要范式
化（normalized），模式（schema）以及适当的限制（constraints）是强制的。Pig 是为
Hadoop 设计的，有时它的模式是未知或者反常的。他可能不能被适当的现实，很少被范式化
。

一个关于人类语言和文化的例子可能会帮助你理解这些。我的妻子和我一起去法国一段时间
了。我平时很少说法语。但因为英语是贸易通用语言（也可能是因为美国和英国喜欢到法
国度假的缘故吧，^_^），所以在法国使用英语并没有障碍。相反，我的妻子经常说发育。她
经常有朋友来玩。她可以和这些人沟通。他可以理解法语不仅仅限于旅游用语。她在法国的
经历肯定要比我深刻多了，因为他会说本地语言。

SQL 是数据处理世界中的英语。他有很多优雅的特性，而且很多工具都了解他，因此他的入
门门槛非常低。而我们要使 Pig Latin 成为并行数据处理系统（例如，Hadoop）中的当地语
言。他可能学习曲线有点抖，但是它让我们更能利用 Hadoop 的本身优点。

### Pig 与 MapReduce 的区别

Pig 提供给用户在 MapReduce 之上的优势。Pig Latin 提供了所有标准的数据操作，例如
Join，filter，group by，order by，union 等等。MapReduce 提供的只是 group by 的操作
（他是实现是 shuffle ＋ reduce），他提供的 Order by 操作是简介利用 group 来实现的
。 Filter 和 展示勉强使用 Map 来实现。而且其他操作，尤其是 join，是不被提供的，必
须用户自己实现。

Pig 提供了一些复杂完整数据操作的实现方法。例如，由于数据集中的每个键的记录很少被分
发，被发到 reducers 的数据经常被扭曲。也就是说，一个reducer获取的数据可能是其他
reducer 的 10倍甚至更多。Pig 的 join 和 order by 操作就是为了解决这个问题的，来
均衡各个 reducers。但是，Pig 中的实现和 MapReduce 的实现是同样耗时的。

在 MapReduce 中，Map 和 Reduce 中的数据处理对于系统来说是很不透明的。这意味着
MapReduce 没有机会优化和检查用户的代码。相反，Pig可以分析 Pig Latin，理解用户描述
的数据流。这样就可以尽早地做错误检查（例如用户尝试把字符串添加到整型中）和代码优化
（例如 两个分组操作是否能合并）。

MapReduce 没有类型系统。这是有意而为之的，这样给了用户足够的灵活来使用他们自己的
数据类型和序列化工作。但是负面的影响就是很大程度上限制了系统检查用户代码错误的能力
。

所有的这些观点都证明了 Pig Latin  在编写和维护上都比使用 JAVA 编写的 MapReduce 耗
费更低的成本。在一个科学非常不严谨的实验中，我同时用 Pig Latin 和 MapReduce 编写
了同样的操作。代码如下

    -- 载入 users  文件，包含两个字段：name，age
    Users   = load 'users' as (name, age);
    -- 筛选用户年龄为 18岁到25岁 之间
    Fltrd   = filter Users by age >= 18 and age <= 25;
    -- 载入 pages 文件，也包含两个字段：user，url
    Page   = load 'pages' as (user, url);
    -- 连接 Fltrd(name) 和 Page(user) 数据
    Jnd = join Fltrd by name, Page by user;
    -- 以 url 来分组
    Grpd    = group Jnd by url;
    -- 汇总各个 url 的用户数
    Smmd    = foreach Grpd generate group, COUNT(Jnd) as clicks;
    -- 以 clicks 降序排列
    Srtd    = order Smmd by clicks desc;
    -- 取前五条
    Top5    = limit Srtd 5;
    -- 并将结果存储到 top5sites 文件中
    store Top5 into 'top5sites';

在 Pig Latin 中，使用了 9 行代码，大概花了 15分钟的时间来编写和调试。同样的在 
MapReduce 中实现大概需要 170 行的代码，并发了 4 个小时让他正常运行。Pig Latin 将
更加的抑郁维护，对于未来开发者来说更容易理解和修改代码。

当然，如果在算法开发上来说，Pig Latin 并不擅长。假设被给予足够的开发时间，一个好
的工程师永远能写出在通用系统运行性能良好的代码。对于非通用算法或者性能极端敏感的
开发， MapReduce 仍然是最好的选择。那同样的情况下，使用 JAVA 和 其他脚本语言（
例如，Python）又有什么区别呢？Java 更加强大，但是由于相对比较底层，他需要更长的开
发周期。因此，开发需要针对不同的工作选择不同的工具。

### Pig 的适用范围

以我个人经验而言，Pig 的使用场景大致有三个：传统的 ETL 数据管道（Data Pipeline），
原始数据(Row Data)研究，和迭代处理。

最大的使用场景要属数据管道了。最常用的例子就是在入库前，分析访问日志，净化数据和对
数据的预处理。 这种情况，数据载入网格中，使用 Pig 清理来自各个点的脏数据。它也可以
用于将 Web 日志与用户数据库数据库连表，以至于可以将用户 cookie 和用户信息相互关联。

另一个 Pig 数据管道的例子就是使用 Pig 进行离线计算。使用 Pig 检索用户的网页交互，
将用户分割成不同的群体。然后，根据不同的属性，产生相应的数据模型，来预测如何促进
用户的访问。这样就可以预测，哪一类广告能更能促进用户，哪一类故事更能促进用户回访。

传统来看，即席查询（ad-hoc queries）比如 SQL，它就可以很好的完成这一类工作。然而，
对于原始数据的研究，一些用户更喜欢使用 Pig Latin。因为 Pig 可以处理未知模式，不完整，
甚至不可理的数据，因为它能更容易管理嵌套的工具，因此，研究员更喜欢使用 Pig 来处理未
清理和载入数据仓库的数据。处理大数据的研究员经常使用 Perl 或者 Python 这类脚本语言
来完成他们的处理。有这些技术背景的用户更喜欢 Pig 的 数据流风格而不是 SQL 的声明查询
的风格。

建立迭代处理模型的用户也正在转向使用 Pig。考虑到新网站需要追踪所有的新故事的访问情况。
在这个图谱中，每一个新故事（story）都是一个节点（node），连接线（edges）用来指明两个
故事之间（story）的关系。例如，所有关于即将到来的选举的故事被联系在一块。每隔5分钟，
都会有新的故事进入，数据处理引擎必须将这些都整合进图谱来。一些故事是新的，一些是更新
新故事的，一些是替代存在的故事的。一些数据操作需要在整个故事图谱中操作的。例如，一个
处理行为标记模型的处理需要将用户信息与整个故事图谱进行关联。每5分钟重新进行整体连表
是不可能，因为在合理硬件情况下，是不可能在 5分钟内处理完它的。但是，模型创建者只在
每日一次更新他们模型，因为这样意味着失去一整天的机会点。

为了解决这些问题，他可能首先在常规的基础上做一次所有的图谱关联，例如，每天。然后，
每五分钟做一次对新数据的关联，这些结果会合并到整个图谱关联产生的结果中。这个合并需要
几点注意，因为每五分钟的数据包含了在整个图谱中插入，更新和删除。这种合并可以使用
Pig Latin 可以并且很合理地进行表达。

把之前说的都归纳到一点就是 Pig（象 MapReduce）是面向数据批处理的。如果需要处理海量的
数据，Pig 是很好的选择。但是，它要求读一个文件的所有记录，并按一定顺序来输出结果。对于
需要写单一或者数据一小部分，或者按随机顺序查找许多不同记录的操作，Pig 就不适用了。

### Pig 哲学

#### Pigs 吃一切可以吃的东西

Pig 可以处理的数据不管是不是元数据。它可以操作关联的，内嵌的，或者无结构的数据。并且
它可以通过简单拓展来操作任何形式的数据。

#### Pigs 无处不在

Pig 更像并行数据操作世界的一种语言。他并不是绑定给某一特定并行框架。首先，它可以用于
Hadoop，但我们不仅仅希望只用于 Hadoop。

#### Pigs 是家畜

Pig 被设计成可以简单地被用户控制和修改。

它允许与用户代码整合，目前，它支持用户定义字段转换方法，用户定义的聚合操作以及用户定义
的条件。这些方法可以直接使用 Java 或者可以编译成 java 代码的脚本语言来编写。Pig 还支持
用户提供的数据载入和存储的方法。他支持通过它的 stream 命令在外部调用，以及通过 MapReduce
命令来操作它。他还允许用户在一些特定环境提供自定义分区或者设置 rduce 层次。

Pig 可以通过重新安排一些操作来优化性能。也很容易关掉他们。

#### 飞猪在天

Pig 可以快速的处理数据。我们总是要提高它的性能，不会加入一些使它变重的功能。


> ### Pig 名称的由来

> “它为什么叫做 Pig？” 这个问题被问道的很频繁。人们也想知道 Pig 是不是一个宏语言。它不是。
整个故事是这样的；这个项目的研究人员最初只是简单地称它为 “Language”。最终，还是要给它取
个名字。一个研究人员突发奇想想出了 Pig 这个名称，起初大家都不接受。但是它出奇地好记而且容易
拼写。然而一部分人认为听起来难以出口甚至联想到愚蠢，他们为我们提供一个有趣的命名，例如，
Pig Latin 是语言， Grunt 是shell脚本，和 Piggybank 是 类 CPan 的分享资源库。
