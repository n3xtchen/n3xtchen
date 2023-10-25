---
categories:
- PostgreSQL
date: "2016-04-24T00:00:00Z"
description: ""
tags:
- database
- json
title: PostgreSQL - 9.5 会成为你的下一个 JSON 数据库?
---

TL;DR: 是的，但这不是一个好的问题。

就在一年前，我们提出问题 *“Is PostgreSQL Your Next JSON Database...”*。现在，随着 **PostgreSQL-9.5** 的发布，是时候验证下 **Betteridge's law** 是否仍然有效。因此，我们一起来探讨下各个版本的 **PostgreSQL** 对 **JSONB** 的改进。

**PostgreSQL** 的 **JSON** 史可以追溯到 **9.2**。

### JSON in 9.2

原始的 **JSON** 数据类型在 **PostgreSQL-9.2** 中强势引入，但实际上只是一个被标记为 **JSON** 类型的文本字段，通过解析器来处理。在 **9.2** 中，你只能对 JSON 中进行简单的存取；其他的任何事情都只能使用 **PL** 语言来处理。在一些场景下是很有用的，但是。。。你还需要更多的功能。

为了说明，假设我们有如下 **JSON** 数据：

	{
	  "title": "The Shawshank Redemption",
	  "num_votes": 1566874,
	  "rating": 9.3,
	  "year": "1994",
	  "type": "feature",
	  "can_rate": true,
	  "tconst": "tt0111161",
	  "image": {
	    "url": "http://ia.media-imdb.com/images/M/MV5BODU4MjU4NjIwNl5BMl5BanBnXkFtZTgwMDU2MjEyMDE@._V1_.jpg",
	    "width": 933,
	    "height": 1388
	  }
	}

首先，创建一张表：

	CREATE TABLE filmsjson (id BIGSERIAL PRIMARY KEY, data JSON);
	
然后像这样插入数据：
	
	n3xt_pg=# INSERT INTO filmsjson (data) VALUES ('{
		"title": "The Shawshank Redemption",
		"num_votes": 1566874,
		"rating": 9.3,
		"year": "1994",
		"type": "feature",
		"can_rate": true,
		"tconst": "tt0111161",
		"image": {
			"url": "http://ia.media-imdb.com/images/M/MV5BODU4MjU4NjIwNl5BMl5BanBnXkFtZTgwMDU2MjEyMDE@._V1_.jpg",
			"width": 933,
			"height": 1388
		}
	}');
	INSERT 0 1
	n3xt_pg=# select * from filmsjson
	postgres-# ;
	id |                                                    data
	---+-------------------------------------------------------------------------------------------------------------
	1  | {"title": "The Shawshank Redemption",                                                                      +
 	   |   "num_votes": 1566874,                                                                                    +
   	   |   "rating": 9.3,                                                                                           +
 	   |   "year": "1994",                                                                                          +
 	   |   "type": "feature",                                                                                       +
	   |   "can_rate": true,                                                                                        +
	   |   "tconst": "tt0111161",                                                                                   +
	   |   "image": {                                                                                               +
	   |     "url": "http://ia.media-imdb.com/images/M/MV5BODU4MjU4NjIwNl5BMl5BanBnXkFtZTgwMDU2MjEyMDE@._V1_.jpg",  +
	   |     "width": 933,                                                                                          +
 	   |     "height": 1388                                                                                         +
  	   |   }                                                                                                        +
	   | }
	(1 row)

我们的能做很受限。注意到了吗？空格和换行都会被保留。这个在后面很重要。。。

### 接着到 9.3

**PostgreSQL-9.3** 有了新的解析器，操作符可以用于提取 **JSON** 数据中的值。他们中使用率最高的就是 `->` ，可以赋予整型，提取数组中的值；或者一个字符串，提取 **JSON** 对象成员；`->>` 也一样，不过他返回的是文本。我们还可以使用  `#>` 和 `＃>>` 来指定路径来获取数据。

接着，我们之前的表，我们可以进一步操作 JSON，做如下查询：

	n3xt_pg=# select data->'title' from filmsjson;
	          ?column?
	----------------------------
	 "The Shawshank Redemption"
	(1 row)
	n3xt_pg=# select data#>'{image,width}' from filmsjson;
	 ?column?
	----------
	 933
	(1 row)

路径实际上就是一个 key 列表来遍历 **JSON** 文档的。不要以为花括号只是用来展示 **JSON** 的 —— 他实际上是一个数组的字画量，在 **PostgreSQL** 中解释成 `text[]`。这个意味和下面的查询等价：

	n3xt_pg=# select data#>ARRAY['image', 'width'] from filmsjson;
	 ?column?
	----------
	 933
	(1 row)
	
虽然加入了很多功能函数，但是仍然很受限。它不允许复杂的查询，不能在特殊类型使用索引，而且只能创建新的 **JSON** 元素。另外，最严重的问题就是每次查询都要对文本字段进行实时解析，这样做相当的低效。

### 切到 9.4

**PostgreSQL-9.4** 引入了新的 **JSON** 类型是 **JSONB**。**JSONB** 是 **JSON** 的二进制编码版本，它高效地存储着键值。这意味着所有的空格都会被删除。缺点就是你不能在同级创建重复的 key(不知道这个实际场景是什么？？？)，你会失去文档的格式。但是这个牺牲是值得的，因为任何东西都变得更高效了，不再需要实时解析。它同时也拖慢了插入的速度，因为要等解析完成为止。现在来看看它们的不同，首先创建一个 **JSONB** 表，插入演示数据：

	n3xt_pg=# CREATE TABLE filmsjsonb (id BIGSERIAL PRIMARY KEY, data JSONB);
	CREATE TABLE
	n3xt_pg=# SELECT * from filmsjsonb;
	 id |                                                                                                                                                 data
	----+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	  1 | {"type": "feature", "year": "1994", "image": {"url": "http://ia.media-imdb.com/images/M/MV5BODU4MjU4NjIwNl5BMl5BanBnXkFtZTgwMDU2MjEyMDE@._V1_.jpg", "width": 933, "height": 1388}, "title": "The Shawshank Redemption", "rating": 9.3, "tconst": "tt0111161", "can_rate": true, "num_votes": 1566874}
	(1 row)

是的，长度非常宽。所有的空格和换行都被替换成一个空格。

虽然它们拥有很多相同的特性，但是最大的区别就是：**JSONB** 没有创建函数。在 **9.4** 中，**JSON** 数据类型有一堆的创建函数：`json_build_object()`, `json_build_array()` 和 `json_object()`,也可以转化成 JSONB（`::jsonb`）类型。它同时也反应了 PostgreSQL 开发者的使用的逻辑 —— **JSON** 为了准确存储，**JSONB** 为的是快速，高效的查询。因此 **JSON** 和 **JSONB** 都有 `->`, `->>`, `#>` 和 `#>>` 操作符，而 **JSONB** 还有有包含和存在操作符 `@>`, `<@`, `?`, `?|` 和 `&?`。

存在是用来检查 key 是否存在，因此我们首先检查下我们演示数据中是否存在 `rating` 字段：

	n3xt_pg=# select data->'title' from filmsjsonb where data ? 'rating';
	          ?column?
	----------------------------
	 "The Shawshank Redemption"
	(1 row)

但是数据中 `url` 不在最外层，所以无法检索到 ：

	n3xt_pg=# select data->'title' from filmsjsonb where data ? 'url';
	 ?column?
	----------
	(0 rows)

但是我们可以这样子做：

	n3xt_pg=# select data->'title' from filmsjsonb where data->'image' ? 'url';
	          ?column?
	----------------------------
	 "The Shawshank Redemption"
	(1 row)
	
`?|` 和 `?&` 对 `?` 的功能进行扩展了:

	n3xt_pg=# select data->'title' from filmsjsonb where data ?| '{"image", "rat"}';	-- 相当于 data ? 'image' or data ? 'rate'
	          ?column?
	----------------------------
	 "The Shawshank Redemption"
	(1 row)
	
	n3xt_pg=# select data->'title' from filmsjsonb where data ?& '{"image", "rat"}';	-- 相当于 data ? 'image' and data ? 'rate'
	 ?column?
	----------
	(0 rows)
	
	n3xt_pg=# select data->'title' from filmsjsonb where data ?& '{"image", "rating"}';
	          ?column?
	----------------------------
	 "The Shawshank Redemption"
	(1 row)
	
`?` 仅用来检查 key 存在，那么 `@>` 和 `<@` 可以检查子串的功能。

	n3xt_pg=# select '{"a":1, "b":2}'::jsonb @> '{"b":2}'::jsonb;
	 ?column?
	----------
	 t
	(1 row)
	
	n3xt_pg=# select '{"b":2}'::jsonb <@ '{"a":1, "b":2}'::jsonb;
	 ?column?
	----------
	 t
	(1 row)
	
**9.4** 同样也带来了 **GIN** 索引类型，它覆盖所有 **JSONB** 文段中的字段。你还可以创建带 `json_path_ops` 的 **GIN** 索引类型，它更快，更小，但是只能用于 `@>` 包含操作符，用来检查子串很有用。

因此，你可以使用 **9.4** 创建，检索和索引 **JSON**/**JSONB** 数据。同时，也失去对了修改 **JSON** 类型数据的能力。你还可以把 **JSON** 数据传递给 **PLv8** 或者 **PLPerl** 脚本处理。因此，这些东西已经接近一个完整服务的 **JSON** 文档处理环境，但是远远还不够。 

### 进入 9.5

**PostgreSQL-9.5** 引入了处理 **JSON** 的新能力：修改和操作 **JSONB** 数据。先来看看 `jsonb_pretty()` 函数，打印更可读的 **JSON**：

	n3xt_pg=# select jsonb_pretty('{"a":3,"b":2}'::jsonb);
	 jsonb_pretty
	--------------
	 {           +
	     "a": 3, +
	     "b": 2  +
	 }
	(1 row)

#### 开删

最简单的修改莫过于删除了。为了这个，**9.5** 引入了 `-` 和 `#-` 操作符。`-` 后面带上 key，代表删除 JSON 的这个 key（如果是数组，则是跟着一个整型索引）。现在，我们来试验下：

	n3xt_pg=# select jsonb_pretty(data) from filmsjsonb;
	                                                 jsonb_pretty
	---------------------------------------------------------------------------------------------------------------
	 {                                                                                                            +
	     "type": "feature",                                                                                       +
	     "year": "1994",                                                                                          +
	     "image": {                                                                                               +
	         "url": "http://ia.media-imdb.com/images/M/MV5BODU4MjU4NjIwNl5BMl5BanBnXkFtZTgwMDU2MjEyMDE@._V1_.jpg",+
	         "width": 933,                                                                                        +
	         "height": 1388                                                                                       +
	     },                                                                                                       +
	     "title": "The Shawshank Redemption",                                                                     +
	     "rating": 9.3,                                                                                           +
	     "tconst": "tt0111161",                                                                                   +
	     "can_rate": true,                                                                                        +
	     "num_votes": 1566874                                                                                     +
	 }
	(1 row)
	
	n3xt_pg=# update filmsjsonb set data=data-'rating';
	UPDATE 1
	
`#-` 以路径作为索引。

	n3xt_pg=# update filmsjsonb set data=data#-'{image,width}';
	UPDATE 1
	n3xt_pg=#  update filmsjsonb set data=data#-'{image,height}';
	UPDATE 1
	n3xt_pg=# select jsonb_pretty(data) from filmsjsonb;
	                                                 jsonb_pretty
	--------------------------------------------------------------------------------------------------------------
	 {                                                                                                           +
	     "type": "feature",                                                                                      +
	     "year": "1994",                                                                                         +
	     "image": {                                                                                              +
	         "url": "http://ia.media-imdb.com/images/M/MV5BODU4MjU4NjIwNl5BMl5BanBnXkFtZTgwMDU2MjEyMDE@._V1_.jpg"+
	     },                                                                                                      +
	     "title": "The Shawshank Redemption",                                                                    +
	     "tconst": "tt0111161",                                                                                  +
	     "can_rate": true,                                                                                       +
	     "num_votes": 1566874                                                                                    +
	 }
	(1 row)
	
上一个例子中，需要执行2次，会不会觉得很蛋疼呢？还好，**PostgreSQL** 提供了一个简便的方法来处理：

n3xt_pg=# update filmsjsonb set data#-'{image,height}'#-'{image,width}';  
UPDATE 1

你不仅可以在删除数据时使用，你还可以在输出中使用这些函数（pipeline 的思想，是不是很有同感！）：

	n3xt_pg=# select jsonb_pretty(data#-'{image,height}'#-'{image,width}') from  
	 filmsjsonb where id=1;
	                                                 jsonb_pretty                                                 
	--------------------------------------------------------------------------------------------------------------
	 {                                                                                                           +
	     "type": "feature",                                                                                      +
	     "year": "1994",                                                                                         +
	     "image": {                                                                                              +
	         "url": "http://ia.media-imdb.com/images/M/MV5BODU4MjU4NjIwNl5BMl5BanBnXkFtZTgwMDU2MjEyMDE@._V1_.jpg"+
	     },                                                                                                      +
	    .... 
	    
#### 合并

另一个重要的数据操作就是合并操作 `||`；它合并两个 **JSONB** 对象。它只能合并顶级的 key，如果两边都存在，它会选择右边那个。这意味着你也可以使用它作为一个更新机制（Replace）。开始，现在想要给我们的电影数据添加两个 key，并赋予初始值：

	n3xt_pg=# update filmsjsonb set data=data || '{"can_rate":false,"num_votes":0,"revote":true }';
	UPDATE 1
	n3xt_pg=# select jsonb_pretty(data) from filmsjsonb;
	                                                 jsonb_pretty
	--------------------------------------------------------------------------------------------------------------
	 {                                                                                                           +
	     "type": "feature",                                                                                      +
	     "year": "1994",                                                                                         +
	     "image": {                                                                                              +
	         "url": "http://ia.media-imdb.com/images/M/MV5BODU4MjU4NjIwNl5BMl5BanBnXkFtZTgwMDU2MjEyMDE@._V1_.jpg"+
	     },                                                                                                      +
	     "title": "The Shawshank Redemption",                                                                    +
	     "revote": true,                                                                                         +
	     "tconst": "tt0111161",                                                                                  +
	     "can_rate": false,                                                                                      +
	     "num_votes": 0                                                                                          +
	 }
	(1 row)
	
它通常用于合并 **JSONB** 数据。如果使用它来更新一个 key，那似乎就有点 overkill；所以接下里我们将要看到杀手级的函数：

#### jsonb_set 来帮你

`jsonb_set` 就是设计用来更新单一 key 值的。直接看例子吧：

	n3xt_pg=# update filmsjsonb SET data = jsonb_set(data,'{"image","width"}',to_jsonb(1024)) where id=1;
	UPDATE 1
	
它把 `image.width` 的值修改成 1024。`jsonb_set` 的参数很简单：第一个就是你要修改的 JSONB 数据类型字段；第二个是一个文本数组，用来指定修改的路径；第三个参数是要替换值（可以是 **JSON**）。如果给的路径不存在，`json_set()` 默认会创建他；如果想要禁用这个行为，那就把第四个参数设置成 `false`。

现在我们想为图片添加版权属性：

	n3xt_pg=# update filmsjsonb SET data = jsonb_set(data,'{"image","quality"}','{"copyright":"company X","registered":true}');
	UPDATE 1
	n3xt_pg=# select jsonb_pretty(data) from filmsjsonb;
	                                                 jsonb_pretty
	---------------------------------------------------------------------------------------------------------------
	 {                                                                                                            +
	     "type": "feature",                                                                                       +
	     "year": "1994",                                                                                          +
	     "image": {                                                                                               +
	         "url": "http://ia.media-imdb.com/images/M/MV5BODU4MjU4NjIwNl5BMl5BanBnXkFtZTgwMDU2MjEyMDE@._V1_.jpg",+
	         "width": 1024,                                                                                       +
	         "quality": {                                                                                         +
	             "copyright": "company X",                                                                        +
	             "registered": true                                                                               +
	         }                                                                                                    +
	     },                                                                                                       +
	     "title": "The Shawshank Redemption",                                                                     +
	     "revote": true,                                                                                          +
	     "tconst": "tt0111161",                                                                                   +
	     "can_rate": false,                                                                                       +
	     "num_votes": 0                                                                                           +
	 }
	(1 row)
	
`jsonb_set()` 可能是 **9.5** 版本关于 **JSONB** 的最重要更新了。他为我们提供修改 **JSONB** 数据的方法。另外需要记住的是，我们的例子只是使用简单的值；它还支持子查询。

### 思考

所有的这些造就了 **PostgreSQL** 今日的有趣地位。**9.5** 对 **PostgreSQL** 的 **JSON** 的加强，意味着你可以使用 **PostgreSQL** 作为 **JSON** 数据库；它足够快，功能强大。你所需要的就是使用不同角度的思考。

例如，很多 **JSON** 数据库没有相对简洁的 API 或者客户端库可用。这里，**PosgreSQL** 有自己的领域语言，**SQL**，来操作 **JSON**；它能和 **SQL** 一起爆发出强大的力量。这意味着你仍然需要学习 **SQL**，不幸的是，很多人希望把它作为 **NoSQL** 数据库使用。

你可以使用 **PostgreSQL** 创建复杂的 **JSON**/**JSONB** 文档。但是如果你这么做的话，你可能需要思考下你是否能更好地使用它。如果文档的复杂度（比如嵌套的 **JSON**）来源于文档之间的关系，那么关系型模型可能是解决数据缠绕的更好选择。关系型数据模型还有个好处，就是避免了数据重复（三范式）。

**PostgreSQL** 对 **JSON** 的完美支持消除了关系型环境中处理 **JSON** 数据的障碍，添加更多易用的，内建的有效函数和操作符来操作 JSONB 数据库。

**PostgreSQL-9.5** 不是你的下一个 **JSON** 数据库，但他是一个带着完整 **JSON** 存储方案的关系型数据库。强化 **JSON** 处理的同时，还做了其他的不少改进，如 upsert，skip locked 以及更好的表随机等等。

它可能不是你的下一个 **JSON** 数据库，但是 **PostgreSQL** 将会是下一个你可以同时用于处理关系型和 **JSON** 数据的数据库。

> 译自 [Could PostgreSQL 9.5 be your next JSON database?](https://compose.io/articles/could-postgresql-9-5-be-your-next-json-database/)