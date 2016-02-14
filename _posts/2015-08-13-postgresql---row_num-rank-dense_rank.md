---
layout: post
title: "Postgresql - ROW_NUM(), RANK() 和 DENSE_RANK() 的区别"
description: ""
category: PostgreSQL
tags: [database]
---
{% include JB/setup %}

	pigdb=# WITH T(CateID, ID)
	     AS (SELECT 1,1 UNION ALL
	         SELECT 1,1 UNION ALL
	         SELECT 1,1 UNION ALL
	         SELECT 1,2)
	SELECT *,
	       RANK() OVER(PARTITION BY CateID ORDER BY ID) ,
	       ROW_NUMBER() OVER(PARTITION BY CateID ORDER BY ID),
	       DENSE_RANK() OVER(PARTITION BY CateID ORDER BY ID)
	FROM   T;
	 cateid | id | rank | row_number | dense_rank
	--------+----+------+------------+------------
	      1 |  1 |    1 |          1 |          1
	      1 |  1 |    1 |          2 |          1
	      1 |  1 |    1 |          3 |          1
	      1 |  2 |    4 |          4 |          2
	(4 rows)