---
categories:
- Python
date: "2013-10-03T00:00:00Z"
description: ""
tags:
- python
- mongo
- module
- 模块
title: Python Mongo 模块 - Pymongo
---

### 连接服务器

    >>> from pymongo import MongoClient
    >>> client = MongoClient('127.0.0.1', 27017)    // 方法 A
    >>> client = MongoClient('mongodb://localhost:27017/')  // 方法 B

### 进入数据库

    >>> db  = client.test_database  // 方法 A
    >>> db  = client['test_database']   // 方法 B

### 进入集合（Collection）

集合（Collection）是存储在 MongoDB 数据库中的文档组合，可以把它当作关系数据
库中的表。

    >>> collection = db.test_collection 
    // 也可以采用数据调用，和数据访问两种方式一致

>   还有一点要注意，集合和数据库在 MongoDB 中创建是懒惰的 - 实际上，上述的操作都没有在 MongoDB 中产生影响。集合和数据库只有在第一个文档被插入时才会被创
建。

### 文档（Document）

数据在 MongoDB 中是使用 JSON 风格的文档来呈现的。在 PyMongo 中，我们使用字典
（Dictionary）来呈现文档的。作为例子，我们使用如下字典来呈现一条博客：

    >>> import datetime
    >>> post    = {"author": "n3xtchen",
    ...             "text" : "My first blog post!"
    ...             "data" : datatime.datetime.utcnow()}

>   注意，文档可以包含 Python 原生的类型（例如 `datetime.datetime` 实例）；
他们会自动与相应的 BSON类型相互转化。

### 插入一个文档

    >>> posts   = db.posts
    >>> post_id = posts.insert(post)
    >>> post_id
    ObjectId('...')

当创建文档时，`"_id"` 会自动被加入，如果文档中没有包含的话。`"_id"` 的值必须
是在一个集合中必须是唯一的。`insert()` 会返回插入的 `"_id"`的。

插入第一个文档后，`posts` 集合实际上已经在服务器上被创建了。我们可以通过下面
方法来罗列我们数据库的所有集合来验证这一点：

    >>> db.collection_name()
    [u'system.indexes', u'posts']

>   注意： `system.indexes` 集合是一个特殊的内部集合，它是自动被创建的。

### 使用 `find_one()` 来获取一条文档

在 MOngoDB 中最基本的查询方式就是 `find_one()`。这种方式返回一个符合查询的文
档（或者如果没有匹配的话返回 `None`）。当你只想要一条匹配的文档或者你只对第
一条感兴趣的时候，这个命令很有用。

    >>> post.fine_one()
    {u'data': datetime.datetime(...), u'text': u'My first blog post!' ...}

匹配的结果就是我们之前插入的那一条

`find_one()` 也支持指定元素的查询

    >>> post.fine_one({"author": "n3xtchen"})
    {u'data': datetime.datetime(...), u'text': u'My first blog post!' ...}

### 通过 ObjectId 查询

我们也可以 `_id` 来查询 post。

    >>> post_id
    ObjectId(...)
    >>> posts.find_one({"_id": post_id})
    {u'data': datetime.datetime(...), u'text': u'My first blog post!' ...}

注意，ObjectId 和字符串不同

    >>> post_id_as_str str(post_id)
    >>> posts.find_one({"_id": post_id_as_str}) # No result

在网页应用中，我会从请求的URL中获取一个 ObjectId 来查询匹配的文档是非常寻常
的事情，所以，如何从传递过来的字符串转化成 ObjectID 是非常必要的：

    from bson.objectid import ObjectId
    def get(post_id):
        document = cliemt.db.collection.find_one({'_id': ObjectId(post_id)})

### Unicode 字符串

你可能注意到我们之前存储的是常规的 Python 字符串和从服务器返回的看起来不一样
（e.g. u'Mike' 代替 'Mike'）。

MongoDB 存储数据使用的 BSON 类型。BSON 字符串是通过 UTF-8 编码的，因此 
PyMongo 必须保证存储的任何字符串只包含有效的 UTF-8 数据。常规的字符串
（<type 'str'>）会被验证然后被存储而不被改变。Unicode 字符串
（<type 'unicode'>）会首先被 UTF-8 编码。而会出现上述（u'Mike' 代替 
'Mike'）是因为 PyMongo 会把每一个 BSON 字符串转化成 Python 的 unicode字符串
，而不是常规字符串。

### 大批量插入（Bulk Inserts）

为了使查询更有意思，让我插入多一些的文档。

    >>> new_posts = [{"author": "Mike",
    ...               "text": "Another post!",
    ...               "tags": ["bulk", "insert"],
    ...               "date": datetime.datetime(2009, 11, 12, 11, 14)},
    ...              {"author": "Eliot",
    ...               "title": "MongoDB is fun",
    ...               "text": "and pretty easy too!",
    ...               "date": datetime.datetime(2009, 11, 10, 10, 45)}]
    >>> posts.insert(new_posts)
    [ObjectId('...'), ObjectId('...')]

这个例子有些有趣的东西我们需要注意：
+ 返回的是两个 ObjectId
+ new_posts 的形状和之前的不一样 - 有一个没有 `tags` 字段，和我们加入了一个
新的字段 `title`。是因为 MongoDB 是 schema-free（无模式的）。

### 查询多个文档

为了获取多个文档作为结果的查询，我们使用 `find()` 方法。`find() 返回一个指针
（cursor）实例。

    >>> for post in posts.find():
    ...     post
    {u'date': datetime.datetime(...), u'text': u'My first blog post!', u'_id': ObjectId('...'), u'author': u'Mike', u'tags': [u'mongodb', u'python', u'pymongo']}
    {u'date': datetime.datetime(2009, 11, 12, 11, 14), u'text': u'Another post!', u'_id': ObjectId('...'), u'author': u'Mike', u'tags': [u'bulk', u'insert']}
    {u'date': datetime.datetime(2009, 11, 10, 10, 45), u'text': u'and pretty easy too!', u'_id': ObjectId('...'), u'author': u'Eliot', u'title': u'MongoDB is fun'}

### 计数

如果我们只想知道有多少个文档匹配，我们可以使用 `count()` 操作。

    >>> posts.count()
    3

    >>> posts.find({"author": "Mike"}).count()
    2

### 索引

为了使查询更快，我们可以添加组合索引在 `"date"` 和 `"author"` 上。我们使用
`explain()` 方法来获取关于查询性能的信息

    >>> posts.find({"date": {"$lt": d}}).sort("author").explain()["cursor"]
    u'BasicCursor'
    >>> posts.find({"date": {"$lt": d}}).sort("author").explain()["nscanned"]
    3

我们可以看出查询使用的使 BasicCursor 和检索了所有的三个文档。现在我们加上组
合索引，查看相同的信息：


    import pymongo import ASCENDING, DESCENDING
    >>> posts.create_index([("date", DESCENDING), ("author", ASCENDING)])
    u'date_-1_author_1'
    >>> posts.find({"date": {"$lt": d}}).sort("author").explain()["cursor"]
    u'BtreeCursor date_-1_author_1'
    >>> posts.find({"date": {"$lt": d}}).sort("author").explain()["nscanned"]
    2

现在我们使用的使 BTreeCursor 索引和只检索了两个匹配的文档。
