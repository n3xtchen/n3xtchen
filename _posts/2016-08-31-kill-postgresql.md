---
layout: post
title: "如何查找和杀掉 PostgreSQL 中长时间运行的查询"
description: ""
category: PostgreSQL
tags: [dba]
---
{% include JB/setup %}

长时间运行的查询会影响整体数据库的性能，它们可能停留在一些后台进程中。尤其当遇上表锁的时候，就更蛋疼了，于是有了下面的文章。

我们可以使用下面语句来查询长时间的运行的查询：

	db_guard=# SELECT
	db_guard-#   pid,
	db_guard-#   now() - pg_stat_activity.query_start AS duration,
	db_guard-#   query,
	db_guard-#   state
	db_guard-# FROM pg_stat_activity
	db_guard-# WHERE now() - pg_stat_activity.query_start > interval '5 minutes';
	 pid | duration | query               | state
	-----+----------+---------------------+-------
	(1 rows)
	30036| 300      | select * from ..... |  idle in transaction

这里的 `pid` 就是系统中的进程 ID。

如果它的状态是 `idle`，那你就不用 care，但是活动状态下查询还是会对性能产生影响的。
	
下面撤销该查询：
	
	db_guard=# SELECT pg_cancel_backend(30036);	
然后，我们可能需要花些时间等待它停下来。

如果发现程序卡住，那我们只能祭出杀手锏（**杀伤力过大，慎用！**）：

	db_guard=# SELECT pg_terminate_backend(30036);
	
为什么我们一步到位呢？ 因为 `pg_cancel_backend` 比 `pg_terminate_backend` 更安全，就好和使用 `kill` 和 `kill -9` 的区别，给它时间善后，避免直接中断导致数据丢失或损坏。

> ### SA 的处理方式
> 
> 既然之前提到了系统进程，我这边提供另一种方式关闭方式
> 	
> 首先，我们从进程查看一下：
> 
> 	$ ps -ef | grep 30036                                                                                                                                             
> 	root     24780  5448  0 10:42 pts/5     00:00:00 grep postgres                                                                                                                                                                                 
> 	postgres 30036  8535  0 Aug08 ?      00:10:13 postgres: admin db_guard 10.xx.xxx.xx(26289) idle in transaction
> 	
> 这里还提供了登陆的用户(`admin`)，数据库(`db_guard`)，客户机的IP(`10.xx.xxx.xx`)，以及查询状态(`idle in transaction`)
> 
> 现在开始料理：
> 
> 	$ kill 30036	
> 	
> 如果不灵，只能强杀了：
> 
> 	$ kill -9 30036

	

	