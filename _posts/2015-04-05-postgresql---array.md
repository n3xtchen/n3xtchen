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
	
这个例子中，`books` 字段存储任何数量的书名数组。创建多维数据的方法也是类似的，唯一的区别就是有另一对方括号要紧跟在第一对的后面，就像前面的例子那样。

	pigdb> CREATE TABLE favorite_authors (
	employee_id INTEGER,
	author_and_titles TEXT[][]
	);
	CREATE TABLE
	
### 给数组追加数据

为了在一个字段插入多个值，**PostgreSQL** 引入了一个特殊的语法。这个语法允许你描述一个数组常量。这个数组常量有话括号，双引号和逗号组成，外层由单引号包裹着。双引号只有在字符数组的时候，需要用到，通用的模式：

	'{"text1",[...]}'	 -- 字符数组
	'{ numeric, [...]}'  -- 数字数组
	
这个语法模式演示如何使用字符和数字数组，但是每个数组必须定义单一数据类型（可以是任何的数据类型，boolean，date 或者是 time）。通常情况下，你使用单引号来描述非数组上下文的值，双引号用来数组中的值。

现在，我们插入数据：

	pigdb> INSERT INTO faviroute_book VALUES (102, E'{"The Hichhiker \'s GUIDE to he Galaxy"}');	-- 插入一个值的数组，注意这边的单引号需要转移，E - escape, 后续会单独讲解这块
	INSERT 0 1
	pigdb> INSERT INTO faviroute_book VALUES (103, '{"The Hobbit", "Kitten, Squared"}');	-- 插入多个值的数组
	INSERT 0 1  
	pigdb> SELECT * FROM faviroute_book;
	+---------------+------------------------------------------+
	|   employee_id | books                                    |
	|---------------+------------------------------------------|
	|           102 | [u"The Hichhiker 's GUIDE to he Galaxy"] |
	|           103 | [u'The Hobbit', u'Kitten, Squared']      |
	+---------------+------------------------------------------+
	
在插入单个值的时候，花括号还是需要的，这是因为数组常量本身也需要被当作字符串来解析，随后基于上下文解析成真正的数组。

多维数组的插入也是类似，看看例子：
	
	pigdb> INSERT INTO favorite_authors VALUES (102,
		'{ {"J.R.R. Tokeien", "The Silmarillion"}, {"Charless Dickness", "Great Expectations"} }'
	);
	INSERT 0 1
	pigdb> SELECT * FROM favorite_authors;
	+---------------+-------------------------------------------------------------------------------------------+
	|   employee_id | author_and_titles                                                                         |
	|---------------+-------------------------------------------------------------------------------------------|
	|           102 | [[u'J.R.R. Tokeien', u'The Silmarillion'], [u'Charless Dickness', u'Great Expectations']] |
	+---------------+-------------------------------------------------------------------------------------------+
	
### 查询数组

之前已经演示查询数组字段，它会返回整个数组。但是数组的最大用处实际是依赖于他的下标操作。

#### 数组下标（Subscripts）

下标的语法由方括号包围着整形数值；这个数值描述的是从左开始的位置距离。

不像大部分编程语言（比如 C），**PostgreSQL** 的下标是从 1 开始的，而不是 0；现在看个例子

	pigdb> SELECT books[1] FROM faviroute_book;
	+-------------------------------------+
	| books                               |
	|-------------------------------------|
	| The Hichhiker 's GUIDE to he Galaxy |
	| The Hobbit                          |
	+-------------------------------------+
	SELECT 2

注意到了吧，查询返回的值不包含话括号的双引号；这是因为单个文本值只需要作为文本常量返回，而不是一个数组；在看一条：

	pigdb> SELECT books[2] FROM faviroute_book;
	+-----------------+
	| books           |
	|-----------------|
	|                 |
	| Kitten, Squared |
	+-----------------+

如果筛选的的结果值被存在会返回空值。你可以使用 `IS NOT NULL` 的语法来过滤它：

	pigdb> SELECT books[2] FROM faviroute_book WHERE books[2] IS NOT NULL;
	+-----------------+
	| books           |
	|-----------------|
	| Kitten, Squared |
	+-----------------+

现在，我们来操作下多维数组：

	pigdb> SELECT 
		author_and_titles[1][1] AS author, 
		author_and_titles[1][2] AS title 
	FROM favorite_authors;
	+----------------+------------------+
	| author         | title            |
	|----------------+------------------|
	| J.R.R. Tokeien | The Silmarillion |
	+----------------+------------------+
	SELECT 1
	
#### 数组切片（Slices）

**PostgreSQL** 同样支持数组的切片操作；原理和下标操作类似，只是它返回制定范围段的值。切片的语法由一对整形数字，被冒号隔开，被方括号包围；例如 `[2:5]` 返回的是，数组的第二，第三，第四和第五的值，以数组形式返回：

	pigdb> INSERT INTO faviroute_book VALUES (104, '{"The Hobbit", "Kitten, Squared", "Practical PostgreSQL"}');	-- 为了掩饰效果，插入一条数组
	INSERT 0 1
	pigdb> SELECT * FROM faviroute_book;
	+---------------+--------------------------------------------------------------+
	|   employee_id | books                                                        |
	|---------------+--------------------------------------------------------------|
	|           102 | [u"The Hichhiker 's GUIDE to he Galaxy"]                     |
	|           103 | [u'The Hobbit', u'Kitten, Squared']                          |
	|           104 | [u'The Hobbit', u'Kitten, Squared', u'Practical PostgreSQL'] |
	+---------------+--------------------------------------------------------------+
	SELECT 3
	pigdb> SELECT books[1:2] FROM faviroute_book;
	+------------------------------------------+
	| books                                    |
	|------------------------------------------|
	| [u"The Hichhiker 's GUIDE to he Galaxy"] |
	| [u'The Hobbit', u'Kitten, Squared']      |
	| [u'The Hobbit', u'Kitten, Squared']      |
	+------------------------------------------+
	SELECT 3
	
而多维数组在切片方面有点不可预期，因此不推荐在多维数组使用切片操作。

#### 数组维度（Dimensions）

有些时候，我们需要知道数组中存储值的数量，你可以使用 `array_dims()` 函数；它接受一个数组参数，返回的字符串的格式和切片语法相同，描述有点拗口，不多说，看看例子就知道了：

	pigdb> SELECT array_dims(books) FROM faviroute_book;
	+--------------+
	| array_dims   |
	|--------------|
	| [1:1]        |
	| [1:2]        |
	| [1:3]        |
	+--------------+
	SELECT 3

### 更新数组

数组更新的方式有三种：

* 整体变更：修改整个字段
* 切片变更：修改某个范围的值
* 元素变更：修改单个元素的值

**PostgreSQL** 对数组的更新操作没有限制，我们通过几个简单的例子就可以一窥究竟了；

	pigdb> UPDATE faviroute_book SET 
		books=E'{"The Hichhiker\'s GUIDE to he Galaxy"}' 
	WHERE employee_id = 102;	-- 整体变更
	UPDATE 1
	pigdb> UPDATE faviroute_book SET 
		books[2:3]='{"Kitten, Squared", "Practical PostgreSQL-2014"}' 
	WHERE employee_id = 104;	-- 切片变更
	UPDATE 1
	pigdb> UPDATE faviroute_book SET 
		books[1]=E'{"There and Back Again: AHobbit\'s Holiday"}' 
	WHERE employee_id = 103;	-- 元素变更
	UPDATE 1
	pigdb> SELECT * FROM faviroute_book;
	+---------------+-----------------------------------------------------------------------+
	|   employee_id | books                                                                 |
	|---------------+-----------------------------------------------------------------------|
	|           102 | [u"The Hichhiker's GUIDE to he Galaxy"]                               |
	|           104 | [u'The Hobbit', u'Kitten, Squared', u'Practical PostgreSQL-2014']     |
	|           103 | [u'{"There and Back Again: AHobbit\'s Holiday"}', u'Kitten, Squared'] |
	+---------------+-----------------------------------------------------------------------+
	SELECT 3


> 字符转义
> http://stackoverflow.com/questions/19812597/postgresql-string-escaping-settings
> http://blog.163.com/digoal@126/blog/static/163877040201342185210972/
