---
layout: post
title: "你不知道的10个SQL杀手级特性"
description: ""
category: 
tags: []
---
{% include JB/setup %}

### 1. 一切都是表

这是最微不足道的技巧，甚至不算一个技巧，但是它却是你全面了解 SQL 的基础：一切都是表！但你看到下面一段语句：

	SELECT * FROM person
	
...你很快注意到表 person。很棒，他是一张表。但是你意识到这整个语句也是一张表吗？举个例子，你可以写：

	SELECT * FROM (
	  SELECT * FROM person
	) t
	
现在，你已经创建一张派生表（derived table）- 一张嵌套在 `FROM` 子句的 `SELECT` 语句。

虽然这功能微不足道，但是很优雅。你也可创建一张使用 `VALUES()` 的 ad-hoc 的内存表，在一些数据库中（如，PostgreSQL，SQL Server）

	SELECT * FROM (VALUES(1), (2), (3))) t(a)
	
以及她的简单输出：

	 a
	---
	 1
	 2
	 3
	
如果这个语法不知大，你可以把他转化成派生表，如，在 Oracle 中：

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

一切都是表。在 PostgreSQL 中，甚至连函数都是表：

	ichexw=# SELECT * FROM substring('abcde', 2, 3);
	 substring
	-----------
	 bcd
	(1 row)
	
如果你是个 JAVA 程序员，你可以使用 JAVA8 Stream API 来类比它。考虑下，下面的相同的概念
	
	TABLE：	Stream<Tuple<..>>
	SELECT:	map()
	DISTINCT:	distinct()
	JOIN:		flatMap()
	WHERE/HAVING:	filter()
	GROUP BY:	collect()
	ORDER BY:	sorted()
	UNION ALL:	concat()

使用 JAVA8 的过程中，“一切都是流”（至少在开始使用 Streams的时候）。不管你怎么转换流，比如使用 map() 和 filter()，结果的类型永远都是一个流

### 2. 使用递归SQL来生成数据

公用表表达式（Common Table Express，也叫 CTE）是 SQL 中声明变量的唯一方法（有别于 PostgreSQL 和 Sybase SQL 中的Window 语句）

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
	
使用一个简单的 `WITH` 语法，你可以指定一个table对象列表（记住：一切都是表），她们可以相互调用。

这个很容易理解。这使得 CTE 很有用，并且她们还允许递归这种逆天的特性！现在看看下面的 PostgreSQL 语句：

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
	
是不是很不错？看看注解，还是挺简单易用的。你定义了一个 CTE 实际上就是两个 `UNION ALL` 子查询

第一个 `UNION ALL` 子查询称之为 “种子行（SEED ROW）”。她初始化了递归。她可以在后续的递归中生成一个或多行。记住：一切都是表，因此我们的递归生成的也是表，而不是一个独立的行或值。

第二个 `UNION ALL` 子查询进行递归。如果你认真看，你会发现她是从 `t` 中检索数据的；例如 第二个子查询允许从我们声明的 CTE 中查询。递归。因此，她也能访问 CTE 中定义的 `v` 字段。

在我们的例子中，把 row(1) 作为递归的种子，然后进行 `v+1` 的递归。这个递归通过设置一个 `LIMIT 5` 来作为停止条件的（是不是很想 JAVA8 STREAM 中的潜在无限递归）。

Side note：图灵完备

递归 CTE 使 SQL:1999 具有图灵完备，她意味着任何其他语言都可以使用 SQL 来重写！（如果你足够疯狂的话）

下面是一个令人影响深刻的例子：


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

> 参考文献：[10 SQL Tricks That You Didn’t Think ](https://blog.jooq.org/2016/04/25/10-sql-tricks-that-you-didnt-think-were-possible/)	_posts/2017-02-13-10-sql-tricks-that-you-didnt-think-were-possible.md