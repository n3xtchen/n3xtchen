---
layout: post
title: "PostgreSQL vs MySQL：取分组数据的前N条纪录"
description: ""
category: PostgreSQL
tags: [database, mysql]
---
{% include JB/setup %}

## 测试数据：

	+------+------+------------------+
	| cate | item | note             |
	+------+------+------------------+
	| a    |    2 | a的第二个值      |
	| a    |    1 | a的第一个值      |
	| a    |    3 | a的第三个值      |
	| b    |    1 | b的第一个值      |
	| b    |    3 | b的第三个值      |
	| b    |    2 | b的第二个值      |
	| b    |    4 | b的第四个值      |
	| b    |    5 | b的第五个值      |
	+------+------+------------------+

## 建表和准备数据

都是通用类型，所以 pgsql 和 mysql 的建表和插表的语句都一样：

	CREATE TABLE tbl ( cate  varchar(10), item  int, note varchar(20));
	INSERT INTO tbl VALUES
	    ('a', 2, 'a的第二个值'),
	    ('a', 1, 'a的第一个值'),
	    ('a', 3, 'a的第三个值'),
	    ('b', 1, 'b的第一个值'),
	    ('b', 3, 'b的第三个值'),
	    ('b', 2, 'b的第二个值'),
	    ('b', 4, 'b的第四个值'),
	    ('b', 5, 'b的第五个值');

## MySQL 的实现方式


	
###  取每个 cate item 最大/最小的那条记录

	mysql> SELECT a.* FROM tbl a WHERE item = (
	    -> SELECT MAX(item) FROM tbl WHERE cate = a.cate
	    -> ) ORDER BY a.cate;
	+------+------+------------------+
	| cate | item | note             |
	+------+------+------------------+
	| a    |    3 | a的第三个值      |
	| b    |    5 | b的第五个值      |
	+------+------+------------------+
	2 rows in set (0.01 sec)

### 按 cate 分组取最大/最小的两个(N个)item

	mysql> SELECT a.* FROM tbl a WHERE EXISTS (
	    -> SELECT COUNT(*) FROM tbl
	    -> WHERE cate = a.cate AND item < a.item HAVING COUNT(*) < 2
	    -> ) ORDER BY a.cate, a.item;
	+------+------+------------------+
	| cate | item | note             |
	+------+------+------------------+
	| a    |    1 | a的第一个值      |
	| a    |    2 | a的第二个值      |
	| b    |    1 | b的第一个值      |
	| b    |    2 | b的第二个值      |
	+------+------+------------------+
	4 rows in set (0.00 sec)

## PostgreSQL 的实现

###  取每个 cate item 最大/最小的那条记录

	# 那个分组的最最值的那条记录
	pigdb=# SELECT DISTINCT ON (cate) cate, item, note
	FROM T ORDER BY cate, item;
	 cate | item |    note
	------+------+-------------
	 a    |    1 | a的第一个值
	 b    |    1 | b的第一个值
	(2 rows)
	
	# 那个分组的最大值的那条记录
	pigdb=# SELECT DISTINCT ON (cate) cate, item, note
	FROM T ORDER BY cate, item DESC;
	 cate | item |    note
	------+------+-------------
	 a    |    3 | a的第三个值
	 b    |    5 | b的第五个值

### 按 cate 分组取最大/最小的两个(N个)item

	pigdb=# SELECT * FROM (
		SELECT T.*, (NTH_VALUE(ITEM, 3) OVER (
			PARTITION BY cate ORDER BY item)
		) fv
		FROM T
	)T1 WHERE fv is null;
	 cate | item |    note     | fv
	------+------+-------------+----
	 a    |    1 | a的第一个值 |
	 a    |    2 | a的第二个值 |
	 b    |    1 | b的第一个值 |
	 b    |    2 | b的第二个值 |

> 引用
> 
> 	* [mysql分组取每组前几条记录(排名) 附group by与order by的研究](http://www.jb51.net/article/31590.h]m)
> 	* [Postgresql 窗口函数](http://www.postgresql.org/docs/9.4/static/functions-window.html)
> 	* [How to select the first row in a group: SELECT DISTINCT ON in PostgreSQL](http://www.vertabelo.com/blog/technical-articles/postgresql-select-distinct-on)