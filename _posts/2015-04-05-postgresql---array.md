---
layout: post
title: "PostgreSQL - 数组(Array)"
description: ""
category: postgresql
tags: [database, nosql]
---
{% include JB/setup %}

**PostgreSQL** 可以通过一种数据结构在独立字段中存储非原子的值。这个数据结构就是我们今天要谈的数组（Array），它本身不是一种数据类型，而是任何数据类型的一种拓展。

### 创建一个数组字段

在 `CREATE TABLE` 或 `ALTER` 语句中需要声明成数组的字段类型后面追加上方括号，这样就可以创建一个数组字段。

现在来看个例子，声明一个一维数组：

	single_array type[]
	
可以将多个方括号追加在类型的后面，就可以声明一个多维数组，可以在数组中存储数组：

	multi_array type[][]
	
理论上说，可以在方括号中插入一个整数 n 来声明一个定长（fixed-length）的数组。但是在 **PostgreSQL** 7.1.x 之后，这个限制非强制的，实际上定长数组和非定长数组之间没有实际的不同。

接下来是一个创建包含数组的表：

	pigdb> CREATE TABLE faviroute_book (
	employee_id INTEGER,
	books TEXT[]
	);
	CREATE TABLE
	Command Time: 0.0552659034729
	Format Time: 2.09808349609e-05
	
这个例子中，`books` 字段存储任何数量的书名数组。创建多维数据的方法也是类似的，唯一的区别就是有另一对方括号要紧跟在第一对的后面，就像前面的例子那样。

	pigdb> CREATE TABLE favorite_authors (
	employee_id INTEGER,
	author_and_titles TEXT[][]
	);
	CREATE TABLE
	Command Time: 0.0201489925385
	Format Time: 2.21729278564e-05
	
### 给数组追加数据

为了在一个字段插入多个值，**PostgreSQL** 引入了一个特殊的语法。这个语法允许你描述一个数组常量。这个数组常量有话括号，双引号和逗号组成，外层由单引号包裹着。双引号只有在字符数组的时候，需要用到，通用的模式：

	'{"text1",[...]}'	 -- 字符数组
	'{ numeric, [...]}'  -- 数字数组
	
这个语法模式演示如何使用字符和数字数组，但是每个数组必须定义单一数据类型（可以是任何的数据类型，boolean，date 或者是 time）。通常情况下，你使用单引号来描述非数组上下文的值，双引号用来数组中的值。

现在，我们给