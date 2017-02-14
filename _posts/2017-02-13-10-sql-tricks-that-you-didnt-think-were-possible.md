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



> 参考文献：[10 SQL Tricks That You Didn’t Think ](https://blog.jooq.org/2016/04/25/10-sql-tricks-that-you-didnt-think-were-possible/)	_posts/2017-02-13-10-sql-tricks-that-you-didnt-think-were-possible.md