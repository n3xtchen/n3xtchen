---
layout: post
title: "PostgreSQL - 继承（inheritance）"
description: ""
category: PostreSQL
tags: [database, object-relation]
---
{% include JB/setup %}

**PostgreSQL** 支持高级的 **objdect-relational** 机制，继承。继承允许一张表继承一张（或多张）表的列属性，来建立 **parent-child** 关系。子表可以继承父表的字段以及约束，同时可以拥有自己的字段。

当执行一个父表查询的时候，这个查询可以获取来自本表和它的子表，也可以指定只查询本表。在子表中查询，则不会返回父表的数据。

###创建子表

通过使用 **INHERITES** 的建表语法来创建子表：

    CREATE TABLE childtable definition
        INHERITS ( parenttable [, ...] )

一张表可以继承多个父表，父表之间是有逗号隔开。现在，来看一个例子：

首先，我们创建一张表：

    pigdb> CREATE TABLE authors (
            id INTEGER NOT NULL PRIMARY KEY,
            last_name TEXT,
            first_name TEXT
            );
    CREATE TABLE
    Command Time: 0.157353878021
    Format Time: 1.81198120117e-05

然后，我们想创建一张叫 *distinguished_authors* , 只包含一个 *award* 字段，让它继承 *author* 表；

    pigdb> CREATE TABLE distinguish_authors ( awards text )
    INHERITS (authors);
    CREATE TABLE
    Command Time: 0.0200970172882
    Format Time: 1.81198120117e-05

现在我们来查看下子表的结构：

    pigdb> \d distinguish_authors;
    +------------+---------+-------------+
    | Column     | Type    | Modifiers   |
    |------------+---------+-------------|
    | id         | integer | not null    |
    | last_name  | text    |             |
    | first_name | text    |             |
    | awards     | text    |             |
    +------------+---------+-------------+
    Inherits: ('authors',),

    Command Time: 0.0306630134583
    Format Time: 0.000441074371338

### 使用

父子表共同的字段的关系并不仅仅是装饰用的。在 *distinguish_authors* 中插入数据，同样在 *authors* 是可见，但是只能看到共享的字段。如果你想要在查询父表的数据，忽略子表，可以使用 **ONLY** 关键字，现在我们来看看具体用法；

首先，我们先插入数据到 *distinguish_authors*:

	pigdb> INSERT INTO distinguish_authors
	VALUES (nextval('author_ids'), 'Simon', 'Neil', 'Pulitzer Prize');
	INSERT 0 1
	Command Time: 0.0186150074005
	Format Time: 1.59740447998e-05

现在，我们查看下效果：

	pigdb> SELECT * FROM distinguish_authors WHERE last_name='Simon';
	+------+-------------+--------------+----------------+
	|   id | last_name   | first_name   | awards         |
	|------+-------------+--------------+----------------|
	|    1 | Simon       | Neil         | Pulitzer Prize |
	+------+-------------+--------------+----------------+
	SELECT 1
	Command Time: 0.0188879966736
	Format Time: 0.00103807449341
	pigdb> SELECT * FROM authors WHERE last_name='Simon';
	+------+-------------+--------------+
	|   id | last_name   | first_name   |
	|------+-------------+--------------|
	|    1 | Simon       | Neil         |
	+------+-------------+--------------+
	SELECT 1
	Command Time: 0.0167798995972
	Format Time: 0.000402927398682


这两个查询语句中，我们可以看出子表的数据在父表中是可见；

	pigdb> SELECT * FROM ONLY authors WHERE last_name='Simon';
	+------+-------------+--------------+
	| id   | last_name   | first_name   |
	|------+-------------+--------------|
	+------+-------------+--------------+
	SELECT 0
	Command Time: 0.0306789875031
	Format Time: 0.000223875045776

在第三个查询语句中，在表名前指定了 **ONLY** 关键字时，这是只返回父表中满足条件的数据。这里需要理解一个概念：给子表插入数据的时候，并不是同时把数据中的共享字段插入到父表中，只是简单通过继承关系使子表的数据在父表可见。如果你指定了 **ONLY** 关键字，则查询不在从子表中获取数据。

另外需要注意的是，**由于继承表的本质原因，一些约束条件可能会被打破**；例如，声明一个唯一字段，可能在查询结果中2条相同的值。因此，在使用的继承的过程中，你要特别注意约束；因为他们在各自的表中没有违反约束条件；因此，如果你在查询父表的时候没有制定 **ONLY** 字段，那它可能会返回你非预期的结果。

### 更新继承表

如果修改子表的数据，将不会影响到父表的数据，这个很好理解；但是修改父表的数据的效果就没有那么显而易见了；**UPDATE** 和 **DELETE** 在父表中执行，默认情况下，不仅会影响父表的数据，同时也会修改子表中满足条件的数据。

	pigdb> UPDATE authors SET last_name='Chen' WHERE last_name='Simon';
	UPDATE 1
	Command Time: 0.0584959983826
	Format Time: 4.60147857666e-05
	pigdb> SELECT * FROM distinguish_authors;
	+------+-------------+--------------+----------------+
	|   id | last_name   | first_name   | awards         |
	|------+-------------+--------------+----------------|
	|    1 | Chen        | Neil         | Pulitzer Prize |
	+------+-------------+--------------+----------------+
	SELECT 1
	Command Time: 0.0330460071564
	Format Time: 0.00148916244507
	
为了防止这种层叠的副作用，你可以像查询那样处理，使用 **ONLY** 来处理：

	pigdb> UPDATE authors SET last_name='Chen' WHERE last_name='Geisel';
	UPDATE 1
	Command Time: 0.0163300037384
	Format Time: 1.69277191162e-05
	pigdb> UPDATE ONLY authors SET last_name='Chen' WHERE last_name='Geisel';
	UPDATE 0
	Command Time: 0.0319559574127
	Format Time: 2.121925354e-05
	pigdb> select * from distinguish_authors;
	+------+-------------+---------------+----------------+
	|   id | last_name   | first_name    | awards         |
	|------+-------------+---------------+----------------|
	|    1 | Chen        | Neil          | Pulitzer Prize |
	|    2 | Geisel      | Theodor Seuss | Pulitzer Prize |
	+------+-------------+---------------+----------------+
	SELECT 2
	Command Time: 0.000549077987671
	Format Time: 0.000324964523315
	
删除也是一样的：

	pigdb> DELETE FROM ONLY authors WHERE last_name='Geisel';
	DELETE 0
	Command Time: 0.00134491920471
	Format Time: 2.09808349609e-05
	
### 结语

**PostgreSQL** 是一门最接近编程语言的数据库，9.4 中引入的 NOSQL 的特性，糢糊了关系数据和非关系型数据的界面，增加特性的同时，并不考虑性能；希望越来越多的人加入进来。
