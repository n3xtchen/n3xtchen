---
categories:
- PostgreSQL
date: "2015-04-10T00:00:00Z"
description: ""
tags:
- database
title: PostgreSQL - 序列（Sequence）
---

**PostgreSQL** 中的序列是一个数据库对象，本质上是一个自增器。因此，序列在其他同类型数据库软件中以 `autoincrment` 值的形式存在。在一张表需要非随机，唯一标实符的场景下，**Sequence** 非常有用。

**Sequence** 对象中包含当前值，和一些独特属性，例如如何递增（或者递减）。实际上，**Sequence** 是不能被直接访问到的；他们需要通过 **PostgreSQL** 中的相关函数来操作他们。

### 创建序列

看看创建的语法：

	CREATE SEQUENCE sequencename
		[ INCREMENT increment ]		-- 自增数，默认是 1
		[ MINVALUE minvalue ]		-- 最小值
		[ MAXVALUE maxvalue ]		-- 最大值
		[ START start ]				-- 设置起始值
		[ CACHE cache ]				-- 是否预先缓存
		[ CYCLE ]					-- 是否到达最大值的时候，重新返回到最小值
		
**Sequence** 使用的是整型数值，因此它的取值范围是 [-2147483647, 2147483647] 之间；现在我们创建一个简单的序列：

	pigdb> CREATE SEQUENCE shipments_ship_id_seq
                       MINVALUE 0;
	CREATE SEQUENCE
	
### 查看序列

**psql** 的 `\d` 命令输出一个数据库对象，包括 **Sequence**，表，视图和索引。你还可以使用 `\ds` 命令只查看当前数据库的所有序列。例如：

	pigdb-# \ds
	                 List of relations
	 Schema |         Name          |   Type   | Owner
	--------+-----------------------+----------+--------
	 public | author_ids            | sequence | ichexw
	 public | shipments_ship_id_seq | sequence | ichexw
	(2 rows)
	
**Sequence** 就像表和视图一样，拥有自己的结构，只不过它的结构是固定的:

	pigdb=# \d shipments_ship_id_seq
     Sequence "public.shipments_ship_id_seq"
    Column     |  Type   |         Value
	---------------+---------+-----------------------
	 sequence_name | name    | shipments_ship_id_seq
	 last_value    | bigint  | 0				
	 start_value   | bigint  | 0
	 increment_by  | bigint  | 1
	 max_value     | bigint  | 9223372036854775807
	 min_value     | bigint  | 0
	 cache_value   | bigint  | 1
	 log_cnt       | bigint  | 0
	 is_cycled     | boolean | f
	 is_called     | boolean | f	
	 

我们现在查询下 `shipments_ship_id_seq` 的 `last_value`（当前的序列值）和 `increment_by` (当 `nextval()` 被调用，当前值将会被增加)。

	pigdb=# SELECT last_value, increment_by FROM shipments_ship_id_seq;
	 last_value | increment_by
	------------+--------------
	          0 |            1
	(1 row)
	
由于序列刚刚被创建，因此 `last_value` 被设置成 0。

### 使用序列

我们需要知道的 **Sequence** 的函数使用：

* nextval('sequence_name'): 将当前值设置成递增后的值，并返回
* currval('sequence_name'): 返回当前值
* setval('sequence_name', n, b=true): 设置当前值；b 默认设置 true，下一次调用 nextval() 时，直接返回 n，如果设置 false，则返回 n+increment:

`nextval()` 函数要求一个序列名（必须由单引号包围）为第一个参数。 需要注意的是，当你第一次调用 `nextval()` 将会返回序列的初始值，即 START；因为他没有调用递增的方法。

	pigdb=# SELECT nextval('shipments_ship_id_seq');
	 nextval
	---------
	       0
	(1 row)
	
	pigdb=# SELECT nextval('shipments_ship_id_seq');
	 nextval
	---------
	       1
	(1 row)

**Sequence** 一般作为表的唯一标识符字段的默认值使用（这是序列的最常见的场景）；看个例子：

	pigdb=# CREATE TABLE shipments (id integer DEFAULT nextval('shipments_ship_id_seq') PRIMARY KEY,
	customer_id integer, isbn text, ship_date timestamp);
	CREATE TABLE
	pigdb=# \d shipments
	                                        Table "public.shipments"
	   Column    |            Type             |                          Modifiers
	-------------+-----------------------------+-------------------------------------------------------------
	 id          | integer                     | not null default nextval('shipments_ship_id_seq'::regclass)
	 customer_id | integer                     |
	 isbn        | text                        |
	 ship_date   | timestamp without time zone |
	Indexes:
	    "shipments_pkey" PRIMARY KEY, btree (id)
	    
这张表中的 `id` 字段的默认值将被设置成 `shipments_ship_id_seq` 的 `nextval()` 值。如果插入值的时候，没有指定 `id` 的值，将会自动选择 `nextval('shipments_ship_id_seq')` 的值。

> 注意：
> 	id 字段的默认值并不是强制使用的。用户仍然可以手动插入值，这样潜在地造成与未来的序列值冲突的风险。这个可以通过 **trigger** 来防止这个问题，后续将详细介绍。

为了防止同一个序列同时被多个被多个用户访问导致错误，序列的当前值与 session 关联。两个用户可能在两个不同的会话访问同一个序列，但是调用 `currval()` 时，只会返回同一会话下的当前值。

现在看看 `curval()` 的简单用法：

	pigdb=# INSERT INTO shipments (customer_id, isbn, ship_date)
	VALUES (221, '0394800753', 'now');
	INSERT 0 1
	pigdb=# SELECT * FROM shipments WHERE id = currval('shipments_ship_id_seq');
	 id | customer_id |    isbn    |         ship_date
	----+-------------+------------+----------------------------
	  2 |         221 | 0394800753 | 2015-04-12 00:38:07.298688
	(1 row)

另外，一个序列也可以通过 `setval()` 将 `last_value` 设置成任意值（必须在序列的取值范围内）。这个要求一个序列名（必须由单引号包围着）作为第一个参数，以及要设置的最后值作为第二个参数；看几个例子：

	pigdb=# SELECT setval('shipments_ship_id_seq', 1010);
	 setval
	--------
	   1010
	(1 row)
	
	pigdb=# SELECT nextval('shipments_ship_id_seq');
	 nextval
	---------
	    1011
	(1 row)
	
前文中，我们还提到了 `setval()` 的第三个参数；现在把它设置成 `false`，验证下效果：
	
	pigdb=# SELECT setval('shipments_ship_id_seq', 1010, false);
	 setval
	--------
	   1010
	(1 row)
	
	pigdb=# SELECT nextval('shipments_ship_id_seq');
	 nextval
	---------
	    1010
	(1 row)

当第三个参数设置成 false 的时候，就像重新创建序列时，第一次调用的时候，只是初始化 `last_val`，不会调用递增函数。

### 删除序列

你可以使用：
	
	DROP SEQUENCE seq_name[, ...]
	
来删除一个或者多个序列。命令中的 `seq_name` 是序列名，不须被引号包围；如果是多个序列，可以使用逗号隔开。

现在我们试一下这个命令：

	pigdb=# DROP SEQUENCE shipments_ship_id_seq;
	ERROR:  cannot drop sequence shipments_ship_id_seq because other objects depend on it
	DETAIL:  default for table shipments column id depends on sequence shipments_ship_id_seq
	HINT:  Use DROP ... CASCADE to drop the dependent objects too.

这里报错了，由于该序列被其他对象引用，因此无法直接删除，除非你使用 `DROP ... CASCADE`。

我们可以使用下面的语句来查看的序列是否被数据库中的其他对象引用，：

	pigdb=# SELECT p.relname, a.adsrc FROM pg_class p
	JOIN pg_attrdef a on (p.relfilenode = a.adrelid)
	WHERE a.adsrc ~ 'shipments_ship_id_seq';
	  relname  |                   adsrc
	-----------+--------------------------------------------
	 shipments | nextval('shipments_ship_id_seq'::regclass)
	(1 row)

这里检查到 `shipments_ship_id_seq` 序列被 `shipments` 引用。你可以把这个序列名替换成任何一个你像查看的序列；或者不添加任何条件查看当前数据库中所有序列的引用。

现在我们成功地执行一次序列删除：

	pigdb=# DROP TABLE shipments;
	DROP TABLE
	pigdb=# DROP SEQUENCE shipments_ship_id_seq;
	DROP SEQUENCE
	


	





