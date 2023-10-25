---
categories:
- PostgreSQL
date: "2016-12-07T00:00:00Z"
description: ""
tags:
- sql
title: PostgreSQL 的 For Each 语句 - Lateral 联表
---

`LATERAL` 的用途，可以是 `SELECT` 中的结果作为条件，并把查询的结果，直接引用到 `SELECT` 子句中，先来看一个语句:

	select 
	  variety,
	  (select "close"
	   from prices b 
	   where a.variety=b.variety
	   order by cur_date limit 1
	  ) -- 嵌套 select 的子查询
	from prices a 
	group by variety;
	
这个语句用来查询每一个商品的最新报价，`SELECT` 中的子查询，我们称之为嵌套 SELECT 子查询（sub-queries in select）。

`LATERAL` 关键词可以在前缀一个 `SELECT FROM` 子项. 这能让 `SELECT` 子项在 `FROM` 项出现之前就引用到 `FROM` 项中的列. (没有 `LATERAL` 的话, 每一个 `SELECT` 子项彼此都是独立的，因此不能够对其它的 `FROM` 项进行交叉引用.)

一、 使用 `LATERAL` 获取分组的TopN

1. 建立测试表：

		CREATE TABLE test (
			username TEXT,
			some_ts timestamptz,
			random_value INT4
		);
		
2. 生成测试数据

		INSERT INTO test (username, some_ts, random_value)
		SELECT
		    'user #' || cast(floor(random() * 10) as int4),
		    now() - '1 year'::INTERVAL * random(),
		    cast(random() * 100000000 as INT4)
		FROM
		    generate_series(1,2000000);
		    
3. 查询每个用户最近五条的随机值
		
		select x.* from (select t.username
			from test t
         	group by t.username order by username
		) as t1, LATERAL(
			select t.* from test t where
  			t.username=t1.username order by t.some_ts desc limit 5
  		) as x;
