---
layout: post
title: "你不知道的10个SQL杀手级特性"
description: ""
category: 
tags: []
---
{% include JB/setup %}

TLDR;

### 1. 一切都是表

这是最微不足道的技巧，甚至不算一个技巧，但是它却是你全面了解 **SQL** 的基础：一切都是表！但你看到下面一段语句：

	SELECT * FROM person
	
...你很快注意到表 person。很棒，他是一张表。但是你意识到这整个语句也是一张表吗？举个例子，你可以写：

	SELECT * FROM (
	  SELECT * FROM person
	) t
	
现在，你已经创建一张派生表（derived table）- 一张嵌套在 `FROM` 子句的 `SELECT` 语句。

虽然这功能微不足道，但是很优雅。你也可创建一张使用 `VALUES()` 的 ad-hoc 的内存表，在一些数据库中（如，**PostgreSQL**，**SQL Server**）

	SELECT * FROM (VALUES(1), (2), (3))) t(a)
	
以及她的简单输出：

	 a
	---
	 1
	 2
	 3
	
如果这个语法不知大，你可以把他转化成派生表，如，在 **Oracle** 中：

	SELECT * FROM (
		SELECT 1 AS a FROM DUAL UINION ALL
		SELECT 2 AS a FROM DUAL UINION ALL
		SELECT 3 AS a FROM DUAL
	)
	
正如你所看到的， `VALUES()` 和派生表实际上都是一样的东西，从概念上讲。让我们重温下插入语句，两种方法：

	-- SQL Server, PostgreSQL, some others:
	INSERT INTO my_table(a) VALUES (1), (2), (3);
	
	-- Oracle, many others:
	INSERT INTO my_table(a)
		SELECT 1 AS a FROM DUAL UINION ALL
		SELECT 2 AS a FROM DUAL UINION ALL
		SELECT 3 AS a FROM DUAL
		
SQL 中，一切都是表。当你插入数据到表，你并不是在插入独立的行。你实际上插入的是一张表。大部分人经常只在表冲插入一张一行的表，因此意识不到。

一切都是表。在 **PostgreSQL** 中，甚至连函数都是表：

	ichexw=# SELECT * FROM substring('abcde', 2, 3);
	 substring
	-----------
	 bcd
	(1 row)
	
如果你是个 **JAVA** 程序员，你可以使用 **JAVA8** Stream API 来类比它。考虑下，下面的相同的概念
	
	TABLE：	Stream<Tuple<..>>
	SELECT:	map()
	DISTINCT:	distinct()
	JOIN:		flatMap()
	WHERE/HAVING:	filter()
	GROUP BY:	collect()
	ORDER BY:	sorted()
	UNION ALL:	concat()

使用 **JAVA8** 的过程中，“一切都是流”（至少在开始使用 Streams 的时候）。不管你怎么转换流，比如使用 `map()` 和 `filter()`，结果的类型永远都是一个流

### 2. 使用递归SQL来生成数据

公用表表达式（Common Table Express，也叫 **CTE**）是 **SQL** 中声明变量的唯一方法（有别于 **PostgreSQL** 和 **Sybase SQL** 中的 Window 语句）

她是一个强大的概念。异常强大。看看下面的语句：

	ichexw=# WITH
	  t1(v1, v2) AS (SELECT 1, 2),
	  t2(w1, w2) AS (
	    SELECT v1 * 2, v2 * 2
	    FROM t1
	  )
	SELECT *
	FROM t1, t2;
	 v1 | v2 | w1 | w2
	----+----+----+----
	  1 |  2 |  2 |  4
	(1 row)
	
使用一个简单的 `WITH` 语法，你可以指定一个 Table 对象列表（记住：一切都是表），她们可以相互调用。

这个很容易理解。这使得 **CTE** 很有用，并且她们还允许递归这种逆天的特性！现在看看下面的 **PostgreSQL** 语句：

	ichexw=# WITH RECURSIVE t(v) AS (
	  SELECT 1     -- Seed Row
	  UNION ALL
	  SELECT v + 1 -- Recursion
	  FROM t
	)
	SELECT v
	FROM t
	LIMIT 5;
	 v
	---
	 1
	 2
	 3
	 4
	 5
	(5 rows)
	
是不是很不错？看看注解，还是挺简单易用的。你定义了一个 **CTE** 实际上就是两个 `UNION ALL` 子查询

第一个 `UNION ALL` 子查询称之为 “种子行（SEED ROW）”。她初始化了递归。她可以在后续的递归中生成一个或多行。记住：一切都是表，因此我们的递归生成的也是表，而不是一个独立的行或值。

第二个 `UNION ALL` 子查询进行递归。如果你认真看，你会发现她是从 `t` 中检索数据的；例如 第二个子查询允许从我们声明的 **CTE** 中查询。递归。因此，她也能访问 CTE 中定义的 `v` 字段。

在我们的例子中，把 row(1) 作为递归的种子，然后进行 `v+1` 的递归。这个递归通过设置一个 `LIMIT 5` 来作为停止条件的（是不是很很像 JAVA8 STREAM 中的潜在无限递归）。

#### Side note：图灵完备

递归 CTE 使 SQL:1999 具有图灵完备，她意味着任何其他语言都可以使用 SQL 来重写！（如果你足够疯狂的话）

下面可能在很多博客经常看到的一个令人影响深刻的例子：曼德博集合（The Mandelbrot Set）, e.g. 比如在 on [http://explainextended.com/2013/12/31/happy-new-year-5/](http://explainextended.com/2013/12/31/happy-new-year-5/)


	ichexw=# WITH RECURSIVE q(r, i, rx, ix, g) AS (
	SELECT r::DOUBLE PRECISION * 0.02, i::DOUBLE PRECISION * 0.02,
	    .0::DOUBLE PRECISION      , .0::DOUBLE PRECISION, 0
	FROM generate_series(-60, 20) r, generate_series(-50, 50) i
	UNION ALL
	SELECT r, i, CASE WHEN abs(rx * rx + ix * ix) <= 2 THEN rx * rx - ix * ix END + r,
	           CASE WHEN abs(rx * rx + ix * ix) <= 2 THEN 2 * rx * ix END + i, g + 1
	FROM q
	WHERE rx IS NOT NULL AND g < 99
	)
	SELECT array_to_string(array_agg(s ORDER BY r), '')
	FROM (
	SELECT i, r, substring(' .:-=+*#%@', max(g) / 10 + 1, 1) s
	FROM q
	GROUP BY i, r
	) q
	GROUP BY i
	ORDER BY i;
	finance=# WITH RECURSIVE q(r, i, rx, ix, g) AS (
	SELECT r::DOUBLE PRECISION * 0.02, i::DOUBLE PRECISION * 0.02,
	    .0::DOUBLE PRECISION      , .0::DOUBLE PRECISION, 0
	FROM generate_series(-60, 20) r, generate_series(-50, 50) i
	UNION ALL
	SELECT r, i, CASE WHEN abs(rx * rx + ix * ix) <= 2 THEN rx * rx - ix * ix END + r,
	           CASE WHEN abs(rx * rx + ix * ix) <= 2 THEN 2 * rx * ix END + i, g + 1
	FROM q
	WHERE rx IS NOT NULL AND g < 99
	)
	SELECT array_to_string(array_agg(s ORDER BY r), '')
	FROM (
	SELECT i, r, substring(' .:-=+*#%@', max(g) / 10 + 1, 1) s
	FROM q
	GROUP BY i, r
	) q
	GROUP BY i
	ORDER BY i;
	----------------------------------------------------------------------------------
	                                                     ..... ..@
	                                                     ..:..:.
	                                                      .....
	                                                      ..:..
	                                                      ..:..
	                                                     ..-:..
	                                                 .....=@#+:
	                                                ....:.=@@=.....
	                                               :.-..+@*@*::..:.
	                                               ..:-@@@@@@@@:.:-.
	                                                ..@@@@@@@@@+%..
	                                                ..@@@@@@@@@@-..
	                                                :-*@@@@@@@@@:-:
	                                               ..:@@@@@@@@@@@..
	                                              ...*@@@@@@@@@@:..
	                                   .        ......-@@@@@@@@@....               .
	                                .....    ..:.......=@@@@@@@-........:          ..
	                              .-.:-.......==..*.=.::-@@@@@:::.:.@..*-.         =.
	                              ...=...=...::+%.@:@@@@@@@@@@@@@+*#=.=:+-.      ..-
	                              .:.:=::*....@@@@@@@@@@@@@@@@@@@@@@@@=@@.....::...:.
	                              ...*@@@@=.@:@@@@@@@@@@@@@@@@@@@@@@@@@@=.=....:...::.
	                               .::@@@@@:-@@@@@@@@@@@@@@@@@@@@@@@@@@@@:@..-:@=*:::.
	                               .-@@@@@-@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.=@@@@=..:
	                               ...@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:@@@@@:..
	                              ....:-*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@::
	                             .....@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-..
	                           .....@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-:...
	                          .--:+.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@...
	                          .==@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-..
	                          ..+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-#.
	                          ...=+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..
	                          -.=-@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..:
	                         .*%:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:@-
	  .    ..:...           ..-@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	 ..............        ....-@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@=
	 .--.-.....-=.:..........::@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..
	 ..=:-....=@+..=.........@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:.
	 .:+@@::@==@-*:%:+.......:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
	 ::@@@-@@@@@@@@@-:=.....:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:
	 .:@@@@@@@@@@@@@@@=:.....%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	 .:@@@@@@@@@@@@@@@@@-...:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:-
	 :@@@@@@@@@@@@@@@@@@@-..%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
	 %@@@@@@@@@@@@@@@@@@@-..-@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
	 @@@@@@@@@@@@@@@@@@@@@::+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+
	 @@@@@@@@@@@@@@@@@@@@@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..
	 @@@@@@@@@@@@@@@@@@@@@@-@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-
	 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
	 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..
	 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.
	:

被 shock 到了吧？

### 3. 运行中汇总计算器

在 **Microsoft Excel** 中，你会简单地计算前两个（或后续）的值之和（或差），然后使用有用的十字光标在整个电子表格中拖动该公式。
您通过电子表格“运行”该总计。一个运行中的总计。

在 SQL 的世界中，最好的方法就是使用窗口函数（Window Function）。

窗口函数是一个很强大的概念-首先，她表面上看不那么好理解，但实际上真的很简单：

> 窗口函数是相对于由SELECT转换的当前行的行的子集上的聚合/排名

就这么简单，^_^

它本质上意味着窗口函数可以对当前行“之上”或“之下”的行执行计算。不像常规的聚合和分组，它们不会转换行，这使它们非常有用。

语法可以归纳如下：

	function(...) OVER (
	  PARTITION BY ...
	  ORDER BY ...
	  ROWS BETWEEN ... AND ...
	)
	
一次，我有各种排序函数（我们将在后面一一解释这些函数），仅接着是 `OVER()` 分句，她指定了窗口，定义如下：

* `PARTITION`: 只有与当前行在同一分区中的行才会被视为该窗口
* `ORDER`: 我们可以给筛选出来的窗口进行排序
* `ROWS`（或 `RANGE`）帧定义：窗口可以被限制为“之前”和“之后”的固定量的行。

这就是窗口函数的全部。

现在，我们来看看，她如何为我们实现运行中的总计？下面是数据

| ID   | VALUE_DATE | AMOUNT |    BALANCE |
|------|------------|--------|------------|
| 9997 | 2014-03-18 |  99.17 |   19985.81 |
| 9981 | 2014-03-16 |  71.44 |   19886.64 |
| 9979 | 2014-03-16 | -94.60 |   19815.20 |
| 9977 | 2014-03-16 |  -6.96 |   19909.80 |
| 9971 | 2014-03-15 | -65.95 |   19916.76 |

我们假设 BALANCE 就是我们想要计算的总计。

直观地，我们可以立即看出规律（看加重符号,加上符号）

| ID   | VALUE_DATE | AMOUNT |    BALANCE |
|------|------------|--------|------------|
| 9997 | 2014-03-18 |  **-(99.17)** |   **+19985.81** |
| 9981 | 2014-03-16 |  **-(71.44)** |   19886.64 |
| 9979 | 2014-03-16 | **-(-94.60)** |   19815.20 |
| 9977 | 2014-03-16 |  -6.96 |   **=19909.80** |
| 9971 | 2014-03-15 | -65.95 |   19916.76 |

因此，我们可以使用下面伪 SQL 语句来表达任何的任何余额：

	当前的月 - SUM(进出款项金额) OVER (
	  "当前行之上的所有行"
	)
	
实际的 SQL 可以写成这样：

	SUM(t.amount) OVER (
	  PARTITION BY t.account_id 
	  ORDER BY     t.value_date DESC, t.id DESC
	  ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
	)
	
解释如下：

* 分区可以计算每一个银行账户的汇总，而不是全部数据的
* 汇总之前，排序保证交易在分区内是有序的
* `ROWS` 分句讲只考虑分区内之前的行（给定的排序）的汇总

所有这些都将发生在内存中的数据集已经由您在FROM .. WHERE等子句中选择，因此非常快。

### 中场休息

在我们介绍其他技巧之前，大家思考下：我们已经看到了

* （递归）Common Table Expressions(公共表表达式,CTE)
* 窗口函数

她们都有共同的特征：

* 很棒
* 异常强大
* 声明式
* SQL 标准的一部分
* 在大部分关系型数据库可用(除了 MySQL)
* 非常重要构件

如果一定要从这个文章中得出什么结论的话，那就是你绝对应该知道现代的SQL这两个重要构件。为什么？可以从这个 [站点中](https://modern-sql.com/) 中得到答案。

### 4. 寻找连续无间隔的最长子序列

很多应用或者网站为了刺激用户活跃留存，对连续登录的用户进行奖励。比如，StackOverflow 的徽章：

* Enthusianst: 连续30天访问每天都访问的用户
* Fanatic：连续100天访问每天都访问的用户

那我们如何计算这些徽章呢？这些徽章用来奖励给连续使用他们平台指定天数的用户。不管婚礼或者结婚纪念日，你也必须登录，否则计数就会归0。

正如我们所使用的是声明式编程，我不需要当心维护任何状态和内存计数。我们想要使用在线分析 SQL 的形式表达她。例如，看看这些数据（测试数据生成方法见附录-1）：

	n3xt-test=# SELECT login_time FROM user_login WHERE id = :user_id;
	     login_time
	---------------------
	 2017-02-17 16:00:00
	 2017-02-16 20:00:00
	 2017-02-16 03:00:00
	 2017-02-15 21:00:00
	 2017-02-15 20:00:00
	 2017-02-14 01:00:00
	 2017-02-12 09:00:00
	 2017-02-11 00:00:00
	 2017-02-10 20:00:00
	 2017-02-10 10:00:00
	 2017-02-09 20:00:00
	 2017-02-09 05:00:00
	 2017-02-08 19:00:00
	(13 rows)
  
一点帮助都没有。让我们从时间戳中去掉小时，并去重。这很简单：

	n3xt-test=# SELECT DISTINCT CAST(login_time AS DATE) login_date FROM user_login WHERE id = :user_id;
	 login_date
	------------
	 2017-02-17
	 2017-02-16
	 2017-02-15
	 2017-02-14
	 2017-02-12
	 2017-02-11
	 2017-02-10
	 2017-02-09
	 2017-02-08
	(9 rows)

就是现在，使用我们已经学过的窗口函数，让我们给每一个日期加上简单的行数：

	n3xt-test=# SELECT
	    login_date,
	    row_number() OVER (ORDER BY login_date)
	FROM login_date;
	 login_date | row_number
	------------+------------
	 2017-02-08 |          1
	 2017-02-09 |          2
	 2017-02-10 |          3
	 2017-02-11 |          4
	 2017-02-12 |          5
	 2017-02-14 |          6
	 2017-02-15 |          7
	 2017-02-16 |          8
	 2017-02-17 |          9
	(9 rows)

接下来仍然很简单。看看发生了什么，如果不单独选择这些值，我们减去它们？

	n3xt-test=# SELECT
	    login_date,
	    (row_number() OVER (ORDER BY login_date)),
	    login_date - (row_number() OVER (ORDER BY login_date))::INT grp
	FROM login_date;
	 login_date | row_number |    grp
	------------+------------+------------
	 2017-02-08 |          1 | 2017-02-07
	 2017-02-09 |          2 | 2017-02-07
	 2017-02-10 |          3 | 2017-02-07
	 2017-02-11 |          4 | 2017-02-07
	 2017-02-12 |          5 | 2017-02-07
	 2017-02-14 |          6 | 2017-02-08
	 2017-02-15 |          7 | 2017-02-08
	 2017-02-16 |          8 | 2017-02-08
	 2017-02-17 |          9 | 2017-02-08
	(9 rows)

上述这些简单例子来说明了：

1. `ROW_NUMBER()` 不言而喻，不会有间隔。
2. 然而我们的数据有

因此，我们把不连续有间隔的时间序列减去一个连续的整数序列，得到的新的日期相同的时间处在同一个连续日期：

	n3xt-test=# SELECT
	  min(login_date), max(login_date),
	  max(login_date) -
	  min(login_date) + 1 AS length
	FROM login_date_groups
	GROUP BY grp
	ORDER BY length DESC;
	    min     |    max     | length
	------------+------------+--------
	 2017-02-08 | 2017-02-12 |      5
	 2017-02-14 | 2017-02-17 |      4
	(2 rows)
	
下面是完整的查询语句：

	1 WITH login_date AS (
	2     SELECT DISTINCT CAST(login_time AS DATE) login_date
	3     FROM user_login
	4     WHERE id = 1
	5 ), login_date_groups AS (
	6     SELECT
	7         login_date,
	8         (row_number() OVER (ORDER BY login_date)),
	9         login_date - (row_number() OVER (ORDER BY login_date))::INT grp
	10     FROM login_date
	11 )
	12 SELECT
	13   min(login_date), max(login_date),
	14   max(login_date) -
	15   min(login_date) + 1 AS length
	16 FROM login_date_groups
	17 GROUP BY grp
	18 ORDER BY length DESC;

### 5. 寻找序列长度

上一个例子，我们已经提取连续值的序列。很简单，我们几乎滥用了整数连续队列。倘若序列的定义不够直观，？看看接下来的数据，**LENGTH** 是我们想计算的每一个序列的长度：

 id | amount | length
----+--------+--------
 20 |  13.97 |      3
 19 |  21.13 |      3
 18 |  84.72 |      3
 17 | -18.91 |      2
 16 | -65.99 |      2
 15 |  18.07 |      1
 14 | -52.68 |      1
 13 |  16.87 |      1
 12 | -56.76 |      2
 11 | -94.72 |      2
 10 |  95.46 |      1
  9 | -52.45 |      1

是的，你的猜测是正确，这个是收支方向（`SIGN(AMOUNT)`）相同根据订单ID排序生成的连续序列，看下格式化后的数据：

 id | amount | length
----+--------+--------
 20 | +13.97 |      3
 19 | +21.13 |      3
 18 | +84.72 |      3
 17 | -18.91 |      2
 16 | -65.99 |      2
 15 | +18.07 |      1
 14 | -52.68 |      1
 13 | +16.87 |      1
 12 | -56.76 |      2
 11 | -94.72 |      2
 10 | +95.46 |      1
  9 | -52.45 |      1

那我们要怎么做？太简单，首先去除所有的噪音，加入行数

	n3xt-test=# SELECT
	  id, amount,
	  sign(amount) AS sign,
	  row_number()
	    OVER (ORDER BY id DESC) AS rn
	FROM orders;
	 id | amount | sign | rn
	----+--------+------+----
	 20 |  13.97 |    1 |  1
	 19 |  21.13 |    1 |  2
	 18 |  84.72 |    1 |  3
	 17 | -18.91 |   -1 |  4
	 16 | -65.99 |   -1 |  5
	 15 |  18.07 |    1 |  6
	 14 | -52.68 |   -1 |  7
	 13 |  16.87 |    1 |  8
	 12 | -56.76 |   -1 |  9

下一个目标是生成下面这样的表：

 id | amount | sign | rn | lo | hi
----+--------+------+----+----+----
 20 |  13.97 |    1 |  1 |  1 |
 19 |  21.13 |    1 |  2 |    |
 18 |  84.72 |    1 |  3 |    |  3
 17 | -18.91 |   -1 |  4 |  4 |
 16 | -65.99 |   -1 |  5 |    |  5
 15 |  18.07 |    1 |  6 |  6 |  6
 14 | -52.68 |   -1 |  7 |  7 |  7
 13 |  16.87 |    1 |  8 |  8 |  8
 12 | -56.76 |   -1 |  9 |  9 |
 11 | -94.72 |   -1 | 10 |    | 10
 10 |  95.46 |    1 | 11 | 11 | 11

在这个表中，我想复制行数到一个子系列的起始行（下界）的 *LO* 字段，和结束行（上界）的 *HI* 字段中。为了这个，我们需要使用两个魔法函数 `LEAD()` 和 `LAG()`：

* `LEAD()`：当前行的下 n 行
* `LAG()`：当前行的上 n 行

		n3xt-test=# SELECT
		  lag(v) OVER (ORDER BY v),
		  v,
		  lead(v) OVER (ORDER BY v)
		FROM (
		  VALUES (1), (2), (3), (4)
		) t(v);
		 lag | v | lead
		-----+---+------
		     | 1 |    2
		   1 | 2 |    3
		   2 | 3 |    4
		   3 | 4 |
		(4 rows)
	
很神奇有木有？记住，在窗口函数内，你可以对 **和当前相关的行的子集** 进行排行或者聚合。在 `LEAD()` 和 `LAG()` 的例子中，我们访问当前行相关的行，重要指定偏离位置，是很容易的。在很多场景中时很有用的。

继续我的 *LO* 和 *HGIH* 例子：

	SELECT
	  trx.*,
	  CASE WHEN lag(sign)
	       OVER (ORDER BY id DESC) != sign
	       THEN rn END AS lo,
	  CASE WHEN lead(sign)
	       OVER (ORDER BY id DESC) != sign
	       THEN rn END AS hi
	FROM trx;
	
通过与上一行（`lag()`）对比 *sign* 字段，如果他们符号相反，我们把当前的行数复制到 *LO* 字段，因为这是我们序列的下界。

然后通过与下一行（`lead()`）对比 *sign* 字段，如果他们符号相反，我们把当前的行数复制到 *LO* 字段，因为这是我们序列的上界。

最后，我们需要处理讨厌的空值（`NULL`）：

	SELECT -- With NULL handling...
	  trx.*,
	  CASE WHEN coalesce(lag(sign)
	       OVER (ORDER BY id DESC), 0) != sign
	       THEN rn END AS lo,
	  CASE WHEN coalesce(lead(sign)
	       OVER (ORDER BY id DESC), 0) != sign
	       THEN rn END AS hi
	FROM trx;

下一步，我们想要 *LO* 和 *HI* 出现在我们的所有行中。

| id | amount | sign | rn | lo | hi
|----|--------|------|----|----|----
| 20 |  13.97 |    1 |  1 |  1 |  3
| 19 |  21.13 |    1 |  2 |  1 |  3
| 18 |  84.72 |    1 |  3 |  1 |  3
| 17 | -18.91 |   -1 |  4 |  4 |  5
| 16 | -65.99 |   -1 |  5 |  4 |  5
| 15 |  18.07 |    1 |  6 |  6 |  6
| 14 | -52.68 |   -1 |  7 |  7 |  7
| 13 |  16.87 |    1 |  8 |  8 |  8
| 12 | -56.76 |   -1 |  9 |  9 | 10
| 11 | -94.72 |   -1 | 10 |  9 | 10
| 10 |  95.46 |    1 | 11 | 11 | 11

我们所使用的特性至少在 Redshift，Sybase SQL，DB2 以及 Oracle 中都可用。我们使用 `IGNORE NULLS` 语句：

	SELECT 
	  trx.*,
	  last_value (lo) IGNORE NULLS OVER (
	    ORDER BY id DESC 
	    ROWS BETWEEN UNBOUNDED PRECEDING 
	    AND CURRENT ROW) AS lo,
	  first_value(hi) IGNORE NULLS OVER (
	    ORDER BY id DESC 
	    ROWS BETWEEN CURRENT ROW 
	    AND UNBOUNDED FOLLOWING) AS hi
	FROM trx

很多关键字！但是本质往往是相同的。在任何给定的当前行，我们寻找之前的值（previous values，`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`），但是忽略所有的空值。从之前的之中，我们获取最后的值，和我们的新 *LO* 值。换句话说，我们获取向前最接近当前行（closest preceding）的 *LO* 值。

*HI* 也是同理。在任何给定的当前行，我们寻找随后的值（subsequent values，`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`），但是忽略所有的空值。从之前的之中，我们获取最后的值，和我们的新 *HI* 值。换句话说，我们获取向后最接近当前行（closest following）的 *HI* 值。

	SELECT -- With NULL handling...
	  trx.*,
	  coalesce(last_value (lo) IGNORE NULLS OVER (
	    ORDER BY id DESC 
	    ROWS BETWEEN UNBOUNDED PRECEDING 
	    AND CURRENT ROW), rn) AS lo,
	  coalesce(first_value(hi) IGNORE NULLS OVER (
	    ORDER BY id DESC 
	    ROWS BETWEEN CURRENT ROW 
	    AND UNBOUNDED FOLLOWING), rn) AS hi
	FROM trx

最后，我们只是做一个微不足道的最后一步，记住处理 **off-by-1** 错误：

	SELECT
	  trx.*,
	  1 + hi - lo AS length
	FROM trx

这个是我们最后的结果：


| id | amount | sign | rn | lo | hi | length
|----|--------|------|----|----|----|--------
| 20 |  13.97 |    1 |  1 |  1 |  3 |      3
| 19 |  21.13 |    1 |  2 |  1 |  3 |      3
| 18 |  84.72 |    1 |  3 |  1 |  3 |      3
| 17 | -18.91 |   -1 |  4 |  4 |  5 |      2
| 16 | -65.99 |   -1 |  5 |  4 |  5 |      2
| 15 |  18.07 |    1 |  6 |  6 |  6 |      1
| 14 | -52.68 |   -1 |  7 |  7 |  7 |      1
| 13 |  16.87 |    1 |  8 |  8 |  8 |      1
| 12 | -56.76 |   -1 |  9 |  9 | 10 |      2
| 11 | -94.72 |   -1 | 10 |  9 | 10 |      2
| 10 |  95.46 |    1 | 11 | 11 | 11 |      1


下面是完整版的查询：

	WITH 
	  trx1(id, amount, sign, rn) AS (
	    SELECT id, amount, sign(amount), row_number() OVER (ORDER BY id DESC)
	    FROM trx
	  ),
	  trx2(id, amount, sign, rn, lo, hi) AS (
	    SELECT trx1.*,
	    CASE WHEN coalesce(lag(sign) OVER (ORDER BY id DESC), 0) != sign 
	         THEN rn END,
	    CASE WHEN coalesce(lead(sign) OVER (ORDER BY id DESC), 0) != sign 
	         THEN rn END
	    FROM trx1
	  )
	SELECT 
	  trx2.*, 1
	  - last_value (lo) IGNORE NULLS OVER (ORDER BY id DESC 
	    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
	  + first_value(hi) IGNORE NULLS OVER (ORDER BY id DESC 
	    ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
	FROM trx2
	
由于 **PostgreSQL** 没有 `IGNORE NULLS ` 语句，所以我在给出一个实现：

	WITH trx AS (
	  SELECT
	    id, amount,
	    sign(amount) AS sign,
	    row_number()
	      OVER (ORDER BY id DESC) AS rn
	  FROM orders
	), trx1 AS (
	  SELECT
	    trx.*,
	    CASE WHEN coalesce(lag(sign)
	         OVER (ORDER BY id DESC), 0) != sign
	         THEN rn END AS lo,
	    CASE WHEN coalesce(lead(sign)
	         OVER (ORDER BY id DESC), 0) != sign
	         THEN rn END AS hi
	  FROM trx
	), trx2 AS (
	 SELECT -- 数据对齐
	    trx1.*,
	    sum(case when lo is null then 0 else 1 end) over (order by id desc) as lo_partition
	 FROM trx1
	)
	SELECT
	  trx2.id, trx2.amount, trx2.sign, trx2.rn,
	  max(trx2.lo) OVER (PARTITION BY trx2.lo_partition) lo,
	  max(trx2.hi) OVER (PARTITION BY trx2.lo_partition) hi,
	  max(trx2.hi) OVER (PARTITION BY trx2.lo_partition) -
	  max(trx2.lo) OVER (PARTITION BY trx2.lo_partition) + 1 length
	FROM trx2;

### 6. 子集和問題（The subset sum problem with SQL）

什么是子集和问题？这里进行了有趣的解释：

[https://xkcd.com/287](https://xkcd.com/287)

还是维基百科上乏味的解释：

[子集和问题[编辑]](https://zh.wikipedia.org/wiki/%E5%AD%90%E9%9B%86%E5%92%8C%E5%95%8F%E9%A1%8C
)

本质上，对每一个的求和。。。

| ID | TOTAL |
|----|-------|
|  1 | 25150 |
|  2 | 19800 |
|  3 | 27511 |

我想要尽可能地从这些组合项中找到“最好”的和：

| ID   |  ITEM |
|------|-------|
|    1 |  7120 |
|    2 |  8150 |
|    3 |  8255 |
|    4 |  9051 |
|    5 |  1220 |
|    6 | 12515 |
|    7 | 13555 |
|    8 |  5221 |
|    9 |   812 |
|   10 |  6562 |

如果你心算够好的话，你可以直接得出最佳的和：

| TOTAL |  BEST | CALCULATION
|-------|-------|--------------------------------
| 25150 | 25133 | 7120 + 8150 + 9051 + 812
| 19800 | 19768 | 1220 + 12515 + 5221 + 812
| 27511 | 27488 | 8150 + 8255 + 9051 + 1220 + 812

使用 SQL 怎么处理呢？简单，只需要使用创建一个 CTE，枚举出 2的n次方种汇总，并找到最接近的一个：

	-- All the possible 2N sums
	WITH sums(sum, max_id, calc) AS (...)
	 
	-- Find the best sum per “TOTAL”
	SELECT
	  totals.total,
	  something_something(total - sum) AS best,
	  something_something(total - sum) AS calc
	FROM draw_the_rest_of_the_*bleep*_owl

如果你读到这里，说明我们是真朋友^_^：

不要担心，方法并没有想象中那么难:

	n3xt-test=# WITH ASSIGN(ID, ASSIGN_AMT) AS (
	              SELECT 1, 25150
	    UNION ALL SELECT 2, 19800
	    UNION ALL SELECT 3, 27511
	), VALS (ID, WORK_AMT) AS (
	              SELECT 1 , 7120
	    UNION ALL SELECT 2 , 8150
	    UNION ALL SELECT 3 , 8255
	    UNION ALL SELECT 4 , 9051
	    UNION ALL SELECT 5 , 1220
	    UNION ALL SELECT 6 , 12515
	    UNION ALL SELECT 7 , 13555
	    UNION ALL SELECT 8 , 5221
	    UNION ALL SELECT 9 , 812
	    UNION ALL SELECT 10, 6562
	), SUMS (ID, WORK_AMT, SUBSET_SUM) AS (
	    SELECT
	        VALS.*,
	        SUM (WORK_AMT) OVER (ORDER BY ID)
	    FROM
	        VALS
	)
	SELECT ASSIGN.ID, ASSIGN.ASSIGN_AMT, SUBSET_SUM
	FROM ASSIGN JOIN SUMS
	ON ABS (ASSIGN_AMT - SUBSET_SUM) <= ALL (
	    SELECT ABS (ASSIGN_AMT - SUBSET_SUM) FROM SUMS
	);
	 id | assign_amt | subset_sum
	----+------------+------------
	  1 |      25150 |      23525
	  2 |      19800 |      23525
	  3 |      27511 |      23525
	(3 rows)
	
### 7. 覆盖运行中的汇总

之前，我们已经知道怎么使用窗口函数计算“一般的”运行中汇总。很简单。现在，如果我们想要覆盖运行中的汇总，使得她永远大于0？基本上，我们星耀计算这个：

| DATE       | AMOUNT | TOTAL |
|------------|--------|-------|
| 2012-01-01 |    800 |   800 |
| 2012-02-01 |   1900 |  2700 |
| 2012-03-01 |   1750 |  4450 |
| 2012-04-01 | -20000 |     0 |
| 2012-05-01 |    900 |   900 |
| 2012-06-01 |   3900 |  4800 |
| 2012-07-01 |  -2600 |  2200 |
| 2012-08-01 |  -2600 |     0 |
| 2012-09-01 |   2100 |  2100 |
| 2012-10-01 |  -2400 |     0 |
| 2012-11-01 |   1100 |  1100 |
| 2012-12-01 |   1300 |  2400 |

当一笔很大支出 -20000 被剪去，我将其归0即可，而不是显示世纪的 -15550。看我的注释就明白了：

| DATE       | AMOUNT | TOTAL | Total 的公式
|------------|--------|-------|---------------------
| 2012-01-01 |    800 |   800 | **GREATEST(0,    800)**
| 2012-02-01 |   1900 |  2700 | **GREATEST(0,   2700)**
| 2012-03-01 |   1750 |  4450 | **GREATEST(0,   4450)**
| 2012-04-01 | -20000 |     0 | **GREATEST(0, -15550)**
| 2012-05-01 |    900 |   900 | **GREATEST(0,    900)**
| 2012-06-01 |   3900 |  4800 | **GREATEST(0,   4800)**
| 2012-07-01 |  -2600 |  2200 | **GREATEST(0,   2200)**
| 2012-08-01 |  -2600 |     0 | **GREATEST(0,   -400)**
| 2012-09-01 |   2100 |  2100 | **GREATEST(0,   2100)**
| 2012-10-01 |  -2400 |     0 | **GREATEST(0,   -300)**
| 2012-11-01 |   1100 |  1100 | **GREATEST(0,   1100)**
| 2012-12-01 |   1300 |  2400 | **GREATEST(0,   2400)**

我们怎么做呢？窗口函数和递归CTE都是可以实现，看到这里大家估计也已经视觉疲劳了，我们换个新法子？但是这个法子只有 **Oracle**，vendor-specific SQL。

将会非常的惊艳，只需要在任何报表的后面加上 `MODEL`：

	SELECT ... FROM some_table

	-- 放在任何表后面	 
	MODEL ...
	
然后你就可以直接在 **SQL** 语句中实现电子表格的逻辑，和 **Excel** 一样。

下面是接下来三个语句将非常实用和广泛的使用

	MODEL
	  -- 维度
	  DIMENSION BY ...
	   
	  -- 报表字段
	  MEASURES ...
	   
	  -- 公司
	  RULES ...
	  
稍微解释下：

* `DIMENSION BY`：指定电子表格的维度。不像 **Excel**，你可以在 **Oracle** 中指定任意数量的维度，而不是2个。
* `MEASURES`：可用的值。不像 Excel ，在单元格中可以使用元祖，而不是单一的值。
* `RULES`：每一个单元格的公式。不像 Excel，这个公式集中放在这里，而不是在每一个单元格中。

使得 `MODEL` 使用起来比 **Excel** 难一些，但是功能更强大，如果你敢用。下面给一个小 demo：

	SELECT *
	FROM (
	  SELECT date, amount, 0 AS total
	  FROM amounts
	)
	MODEL 
	  DIMENSION BY (row_number() OVER (ORDER BY date) AS rn)
	  MEASURES (date, amount, total)
	  RULES (
	    total[any] = greatest(0,
	    coalesce(total[cv(rn) - 1], 0) + amount[cv(rn)])
	  )

### 8. 时间序列模式识别（Time Series Pattern Recognition）

如果你对诈骗识别或者其他运行实时大数据的领域感兴趣，时间模式识别这个名词对你来说将不会太陌生。

如果我们重温 **5. 寻找序列长度** 的章节，将会想在我们时间序列的复杂事件（**Event**）上生成触发器（**Trigger**）：

|   ID | VALUE_DATE |  AMOUNT | LEN | TRIGGER
|------|------------|---------|-----|--------
| 9997 | 2014-03-18 | + 99.17 |   1 |
| 9981 | 2014-03-16 | - 71.44 |   4 |
| 9979 | 2014-03-16 | - 94.60 |   4 |      x
| 9977 | 2014-03-16 | -  6.96 |   4 |
| 9971 | 2014-03-15 | - 65.95 |   4 |
| 9964 | 2014-03-15 | + 15.13 |   3 |
| 9962 | 2014-03-15 | + 17.47 |   3 |
| 9960 | 2014-03-15 | +  3.55 |   3 |
| 9959 | 2014-03-14 | - 32.00 |   1 |

触发器的规则是：

> 如果某个事件连续发生3次，则触发该触发器（**Trigger**）。

也和之前的 `MODEL` 语句类似，我们能做的就是使用 **Oracle 12c** 语法：

	SELECT ... FROM some_table	 
	MATCH_RECOGNIZE (...) 
	
`MATCH_RECOGNIZE` 的最简单的应用包括以下子句：

	SELECT *
	FROM series
	MATCH_RECOGNIZE (
	  -- 模式匹配在这个顺序下完成
	  ORDER BY ...
	 
	  -- 用来匹配的字段
	  MEASURES ...
	 
	  -- 每一次匹配后返回行的配置
	  ALL ROWS PER MATCH
	 
	  -- 匹配事件的正则表达式
	  PATTERN (...)
	 
	  -- 事件的定义
	  DEFINE ...
	) 
	
这个听起来太疯狂了。现在看一个实际的例子：

	SELECT *
	FROM series
	MATCH_RECOGNIZE (
	  ORDER BY id
	  MEASURES classifier() AS trg
	  ALL ROWS PER MATCH
	  PATTERN (S (R X R+)?)
	  DEFINE
	    R AS sign(R.amount) = prev(sign(R.amount)),
	    X AS sign(X.amount) = prev(sign(X.amount))
	) 

我们做了什么？

* 根据 *ID* 排序
* 然后我们指定我们想要的值作为结果。 我们需要 `MEASURE` 触发器（**Trigger**），它被定义为分类器，即我们将在模式中使用的文字。 此外，我们想要匹配的所有行。
* 我们指定类正则表达式模式。这个模式是一个 *S* 事件（**Event**）定义开始，接着 *R* 时间定义重复。如果全部模式匹配，我们会的得到 *SRXR*，*SRXRR* 或 *SRXRRR*，例如， X 将会在序列长度大于 4 的第三个位置北标记
* 最后，我们定义 *R* 和 *X* 成同一个事件（**Event**），即当前行和上一行的 `SIGN(AMOUNT)` 相同时触发。我们没有定义 *S*，他可以是任何的其他行。

这个查询会产生下面魔法般的输出：

|   ID | VALUE_DATE |  AMOUNT | TRG |
|------|------------|---------|-----|
| 9997 | 2014-03-18 | + 99.17 |   S |
| 9981 | 2014-03-16 | - 71.44 |   R |
| 9979 | 2014-03-16 | - 94.60 |   X |
| 9977 | 2014-03-16 | -  6.96 |   R |
| 9971 | 2014-03-15 | - 65.95 |   S |
| 9964 | 2014-03-15 | + 15.13 |   S |
| 9962 | 2014-03-15 | + 17.47 |   S |
| 9960 | 2014-03-15 | +  3.55 |   S |
| 9959 | 2014-03-14 | - 32.00 |   S |

我们可以看到一个 *X* 在我们的事件（**Event**）系统。这个就是实际上我们想要的。在一系列长度大于3的事件（相同符号）的第三次重复时触发。

Boom！

实际上，我们根本不 Care *S* 和 *R* 事件（**Event**），只需要像这样去掉就好：

	SELECT
	  id, value_date, amount, 
	  CASE trg WHEN 'X' THEN 'X' END trg
	FROM series
	MATCH_RECOGNIZE (
	  ORDER BY id
	  MEASURES classifier() AS trg
	  ALL ROWS PER MATCH
	  PATTERN (S (R X R+)?)
	  DEFINE
	    R AS sign(R.amount) = prev(sign(R.amount)),
	    X AS sign(X.amount) = prev(sign(X.amount))
	) 

最后的结果如下：

|   ID | VALUE_DATE |  AMOUNT | TRG |
|------|------------|---------|-----|
| 9997 | 2014-03-18 | + 99.17 |     |
| 9981 | 2014-03-16 | - 71.44 |     |
| 9979 | 2014-03-16 | - 94.60 |   X |
| 9977 | 2014-03-16 | -  6.96 |     |
| 9971 | 2014-03-15 | - 65.95 |     |
| 9964 | 2014-03-15 | + 15.13 |     |
| 9962 | 2014-03-15 | + 17.47 |     |
| 9960 | 2014-03-15 | +  3.55 |     |
| 9959 | 2014-03-14 | - 32.00 |     |

感谢， **ORACLE**！

另外别要期待我继续介绍 **Oracle** 白皮书（如果你在使用 **Oracle 12c**, 那强烈建议看一下她的[文档](http://www.oracle.com/ocom/groups/public/@otn/documents/webcontent/1965433.pdf)）的其他特性了。

### 9. 数据表行列转换（Pivoting and Unpivoting）

如果你已经读到这里，接下来的内容都太简单了，和大家过一下：

这是我们的数据，**主演**，**电影名**以及**电影评级**：

| NAME      | TITLE           | RATING |
|-----------|-----------------|--------|
| A. GRANT  | ANNIE IDENTITY  | G      |
| A. GRANT  | DISCIPLE MOTHER | PG     |
| A. GRANT  | GLORY TRACY     | PG-13  |
| A. HUDSON | LEGEND JEDI     | PG     |
| A. CRONYN | IRON MOON       | PG     |
| A. CRONYN | LADY STAGE      | PG     |
| B. WALKEN | SIEGE MADRE     | R      |

我们想要转换成：

| NAME      | NC-17 |  PG |   G | PG-13 |   R |
|-----------|-------|-----|-----|-------|-----|
| A. GRANT  |     3 |   6 |   5 |     3 |   1 |
| A. HUDSON |    12 |   4 |   7 |     9 |   2 |
| A. CRONYN |     6 |   9 |   2 |     6 |   4 |
| B. WALKEN |     8 |   8 |   4 |     7 |   3 |
| B. WILLIS |     5 |   5 |  14 |     3 |   6 |
| C. DENCH  |     6 |   4 |   5 |     4 |   5 |
| C. NEESON |     3 |   8 |   4 |     7 |   3 |

如果是用过 **Excel** 的 **透视表** 的可以略过接下来的两段解释。

大家注意到了，我可以根据演员进行分组，然后把该演员每个评级分组下的电影数量**转化成列（PIVOTING）**。不以关系的形式显示，（例如，每组一行），我们把所有的组都转换成列。之所以可以这么做，是因为我们实现知道所有可能出现的分组。

**列转行（Unpivoting）** 则是相反的操作。

| NAME      | RATING | COUNT |
|-----------|--------|-------|
| A. GRANT  | NC-17  |     3 |
| A. GRANT  | PG     |     6 |
| A. GRANT  | G      |     5 |
| A. GRANT  | PG-13  |     3 |
| A. GRANT  | R      |     6 |
| A. HUDSON | NC-17  |    12 |
| A. HUDSON | PG     |     4 |

这个实际上很简单。下面是 PostgreSQL 的实现：

	SELECT
	  first_name, last_name,
	  count(*) FILTER (WHERE rating = 'NC-17') AS "NC-17",
	  count(*) FILTER (WHERE rating = 'PG'   ) AS "PG",
	  count(*) FILTER (WHERE rating = 'G'    ) AS "G",
	  count(*) FILTER (WHERE rating = 'PG-13') AS "PG-13",
	  count(*) FILTER (WHERE rating = 'R'    ) AS "R"
	FROM actor AS a
	JOIN film_actor AS fa USING (actor_id)
	JOIN film AS f USING (film_id)
	GROUP BY actor_id

我们可以向聚合函数附加一个简单的 `FILTER` 子句，以便只计算相关的数据。

在其他数据库下，我们可以这么做：

	SELECT
	  first_name, last_name,
	  count(CASE rating WHEN 'NC-17' THEN 1 END) AS "NC-17",
	  count(CASE rating WHEN 'PG'    THEN 1 END) AS "PG",
	  count(CASE rating WHEN 'G'     THEN 1 END) AS "G",
	  count(CASE rating WHEN 'PG-13' THEN 1 END) AS "PG-13",
	  count(CASE rating WHEN 'R'     THEN 1 END) AS "R"
	FROM actor AS a
	JOIN film_actor AS fa USING (actor_id)
	JOIN film AS f USING (film_id)
	GROUP BY actor_id
	
现在，如果你在使用 **SQL Server** 或者 **Oracle** 的话，你还可以使用内建的 `PIVOT` 或 `UNPIVOT` 语句，就像 `MODEL` 和 `MATCH_RECOGNIZE` 一样，在一个表的后面添加新的关键词就好：

	-- 行转列
	SELECT something, something
	FROM some_table
	PIVOT (
	  count(*) FOR rating IN (
	    'NC-17' AS "NC-17", 
	    'PG'    AS "PG", 
	    'G'     AS "G", 
	    'PG-13' AS "PG-13", 
	    'R'     AS "R"
	  )
	)
	 
	-- 列转行
	SELECT something, something
	FROM some_table
	UNPIVOT (
	  count    FOR rating IN (
	    "NC-17" AS 'NC-17', 
	    "PG"    AS 'PG', 
	    "G"     AS 'G', 
	    "PG-13" AS 'PG-13', 
	    "R"     AS 'R'
	  )
	)

### 附录-1: 随机生成用户登录行为:

	  1 CREATE TABLE user_login AS
	  2 WITH RECURSIVE users(id) AS (
	  3     SELECT 1
	  4     UNION ALL
	  5     SELECT id + 1
	  6     FROM users WHERE id <= 20
	  7 )
	  8 SELECT u.id,  login_time.login_time
	  9 FROM
	 10 (SELECT id FROM users) u,
	 11 LATERAL(
	 12     SELECT login_date.*, login_time.*
	 13     FROM
	 14     (SELECT date(generate_series(now() - '10 days'::INTERVAL, now(), '1 day')) login_date, (random()*6)::int login_per_day) login_date,
	 15     LATERAL(
	 16         SELECT * FROM
	 17         generate_series(login_date.login_date, login_date.login_date + '1 days'::INTERVAL, '1 hour') login_time
	 18         ORDER BY random() LIMIT login_date.login_per_day
	 19     ) login_time
	 20 ) login_time
	 21 ORDER BY login_time DESC;
	 
### 附录-2: 生成订单数据：

	1 CREATE TABLE orders AS
	2 SELECT *, round((100-random()*200)::NUMERIC, 2) amount
	3 FROM generate_series(1, 20) id;



> 参考文献：[10 SQL Tricks That You Didn’t Think ](https://blog.jooq.org/2016/04/25/10-sql-tricks-that-you-didnt-think-were-possible/)	_posts/2017-02-13-10-sql-tricks-that-you-didnt-think-were-possible.md