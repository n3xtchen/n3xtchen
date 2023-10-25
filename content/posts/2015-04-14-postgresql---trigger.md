---
categories:
- PostgreSQL
date: "2015-04-14T00:00:00Z"
description: ""
tags:
- database
title: PostgreSQL 触发器（Trigger）- 创建安全的自增主键
---

通常情况，常规的 **SQL** 事件（Event） 应该在普通行为的之前或之后被触发。这个行为可以是对插入的值的类型检查，可以是在插入前的格式化，或者是变更和删除数据之后对相关的表的数据修改。传统的处理方式是通过连接数据库的应用的编码层来做，而不是数据库软件本身。

为了减轻数据库和应用之间的交互负担，**PostgreSQL** 提供一种非标准的可编程拓展（即 触发器，本文在后续的阐述中使用 trigger 这个名词）。**Trigger** 定义一个函数在其他表操作的前后执行。

**Trigger** 可以影响如下几个表操作（即 event）：

* INSERT
* UPDATE
* DELETE

### 创建 Trigger

创建 **Trigger** 之前，我们需要执行的函数首先需要存在。**PostgreSQL** 支持多种语言的函数，如 **PL/pgSQL**。

函数一旦定义，我们就可以创建 **Trigger**。先看看创建语法： 

	CREATE TRIGGER name { BEFORE | AFTER | INSTEAD OF } { event [ OR event ... ] }
		ON tablename
		FOR EACH { ROW | STATEMENT }
		EXECUTE PROCEDURE functionname ( arguments )

* `BEFORE | AFTER | INSTEAD OF`:   事件之前,之后或者替代该事件操作；
* `event [OR event]`: 即前文提到的 CUD 操作，可以绑定多个事件，事件之间用 `OR` 隔开；
* `ROW | STATEMENT`:  `ROW` 对每行执行一次函数；`STETEMENT` 对每个执行语句执行一次；
* `EXECUTE PROCEDURE functionname ( arguments )`: 即调用的函数，即参数。

> 注意：只有超级用户或者数据库拥有者才能够创建 **Trigger**。

让我们幻想一个场景，就像 [PostgreSQL - 序列](http://n3xtchen.github.io/n3xtchen/postgresql/2015/04/10/postgresql---sequence/) 提到的，使用自增序列作为表的主键存在风险，我们可以使用 **Trigger** 来规避不确定的用户行为带来的问题。
首先建立一个测试表 `shipments`：

	pigdb=# CREATE SEQUENCE shipments_ship_id_seq
	pigdb-#                    MINVALUE 0;
	CREATE SEQUENCE
	pigdb=# CREATE TABLE shipments (
		id integer NOT NULL PRIMARY KEY,
		customer_id integer, 
		isbn text, 
		ship_date timestamp
		);
	CREATE TABLE

然后创建一个函数来完成自增的操作（后续的文章会详细阐述这一点，这里只是带过一下）：

	pigdb=# CREATE OR REPLACE FUNCTION insert_id() RETURNS trigger AS $$
	pigdb$# DECLARE
	pigdb$#   seq_id integer;	-- 声明一个变量，存储新的序列值
	pigdb$# BEGIN
	pigdb$#   SELECT INTO seq_id nextval('shipments_ship_id_seq'); -- 获取新序列值
	pigdb$#   NEW.id = seq_id;	-- 赋值给记录
	pigdb$#   return NEW;		-- 返回修改后的记录
	pigdb$# END;
	pigdb$# $$ LANGUAGE plpgsql VOLATILE;	-- 指定使用 PL/PGSQL 作为脚本语言
	CREATE FUNCTION

最后，我们开始创建 **Trigger**：

	pigdb=# CREATE TRIGGER insert_ship_id  BEFORE INSERT
	pigdb-# ON shipments
	pigdb-# FOR EACH ROW
	pigdb-# EXECUTE PROCEDURE insert_id();
	CREATE TRIGGER
	
现在我们查看下表结构：

	pigdb=# \d shipments
	                                        Table "public.shipments"
	   Column    |            Type             |            Modifiers
	-------------+-----------------------------+--------------------------------
	 id          | integer                     | not nul
	 customer_id | integer                     |
	 isbn        | text                        |
	 ship_date   | timestamp without time zone |
	Indexes:
	    "shipments_pkey" PRIMARY KEY, btree (id)
	Triggers:
	    insert_ship_id BEFORE INSERT ON shipments FOR EACH ROW EXECUTE PROCEDURE insert_id()

可以看到，这个表上已经挂载到 **Trigger**，现在我插入几个数据看看：

	pigdb=# SELECT * FROM shipments;
	 id | customer_id |    isbn    |         ship_date
	----+-------------+------------+----------------------------
	  2 |         221 | 0394800753 | 2015-04-15 14:12:55.744302
	(1 row)
	
我们不需要指定 `id`，现在我们试试指定了主键 `id` 后会有什么效果？
	
	pigdb=# INSERT INTO shipments (id, customer_id, isbn, ship_date)
	VALUES (4 ,221, '0394800753', 'now');
	INSERT 0 1
	pigdb=# SELECT * FROM shipments;
	 id | customer_id |    isbn    |         ship_date
	----+-------------+------------+----------------------------
	  2 |         221 | 0394800753 | 2015-04-15 14:12:55.744302
	  3 |         221 | 0394800753 | 2015-04-15 14:13:24.810759
	(2 rows)	    

输出结果很明显，不论你指定还是不指定主键 `id`，插入的数据都不会受到影响，返回都是序列的下一个值。

### 查看 Trigger

**Trigger** 是存储在 `pg_trigger` 表中的，我们查看下它的结构：

	pigdb=# \d pg_trigger
	       Table "pg_catalog.pg_trigger"
	     Column     |     Type     | Modifiers
	----------------+--------------+-----------
	 tgrelid        | oid          | not null
	 tgname         | name         | not null
	 tgfoid         | oid          | not null
	 tgtype         | smallint     | not null
	 tgenabled      | "char"       | not null
	 tgisinternal   | boolean      | not null
	 tgconstrrelid  | oid          | not null
	 tgconstrindid  | oid          | not null
	 tgconstraint   | oid          | not null
	 tgdeferrable   | boolean      | not null
	 tginitdeferred | boolean      | not null
	 tgnargs        | smallint     | not null
	 tgattr         | int2vector   | not null
	 tgargs         | bytea        |
	 tgqual         | pg_node_tree |
	Indexes:
	    "pg_trigger_oid_index" UNIQUE, btree (oid)
	    "pg_trigger_tgrelid_tgname_index" UNIQUE, btree (tgrelid, tgname)
	    "pg_trigger_tgconstraint_index" btree (tgconstraint)

### 删除 Trigger

删除 **Trigger** 就更简单：

	pigdb=# DROP TRIGGER insert_ship_id ON shipments;
	DROP TRIGGER
	ON (tgrelid = relfilenode)
	WHERE tgname = 'insert_ship_id ';
	
删除之前，你还可以查看下要删的 **Trigger** 相关联的对象有哪些：

	pigdb=# SELECT relname FROM pg_class
	INNER JOIN pg_trigger ON (tgrelid = relfilenode)
	WHERE tgname = 'insert_ship_id';
	  relname
	-----------
	 shipments
	(1 row)

`tgname` 就是所要查询的 **Trigger** 名称。还有给需要注意的就是，当 **Trigger** 使用的函数被重建时，**Trigger** 也需要重建才能生效。

### 结语

**Trigger** 是对 **PostgreSQL** 约束（**Contraints**）的补充，可以配合 **PL** 语法进行输入值的复杂验证，或者屏蔽某些用户的误操作（如上述例子中，自增主键的实现）。另外，很多人从 **PostgreSQL** 转到 **MySQL**，都很怀恋 Replace 语法的简便；**PostgreSQL** 虽然不直接支持，但是可以通过 **Trigger** 和 **PL/pgSQL** 实现，后续的涉及 PL 语法的时候，将详细阐述该实现。


         
         