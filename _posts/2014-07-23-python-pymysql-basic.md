---
layout: post
title: "Python - PyMySQL 初探"
description: ""
category: Python
tags: [python, mysql]
---
{% include JB/setup %}

PyMySQL 是由纯 Python 实现的 MySQL 客户端库；他的目标是为了作为 MySQLdb 的替代品，可以在 CPython，PyPy，IronPython 和 Jython 上运行。

虽然由 C 实现的 MySQLdb 速度要快，但是 很遗憾 MySQLdb 是阻塞的，而 PyMySQL 和 gevent 可以很好地解决 MySQL 阻塞地问题。（我还发现另一个纯 Python 实现的 MySQL 库 - mysql-connector(MySQL 官方提供的) 同样也可以解决这个问题，有空再介绍）。

进入正题，开始介绍：

### 安装 PyMySQL

* 使用 Pip 安装

	pip install PyMySQL
	
* 从源码安装

	1. 从 https://pypi.python.org/pypi/PyMySQL 下载安装包
	2. 解压到指定的路径，
	3. 在命令行模式下进入安装目录，执行 `python setup.py install` 命令
	
### 使用 PyMySQL

### 导入模块

	In [1]: import pymysql
	
### 连接数据库

	In [2]: conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', passwd='', db='test')
	In [7]: c = conn.cursor()
	
### 执行查询

为了演示 PyMySQL 的多种数据类型的操作，创建一个拥有所有类型的表。

#### 1. 创建表

		In [8]: c.execute("create table test_datatypes (b bit, i int, 
		....: l bigint, f real, s varchar(32), u varchar(32), bb blob, 
		....: d date, dt datetime, ts timestamp, td time, t time, st datetime)")
		Out[8]: 0
	
#### 2. 插入数据

		In [10]: import datetime, time

		In [11]: v = (True, -3, 123456789012, 5.7, "hello'\" world", 
		....: u"Espa\xc3\xb1ol", "binary\x00data".encode(conn.charset), 
		....: datetime.date(1988,2,2), datetime.datetime.now(), 
		....: datetime.timedelta(5,6), datetime.time(16,32), time.localtime())

		In [12]: c.execute("insert into test_datatypes (b,i,l,f,s,u,bb,d,dt,td,t,st) values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", v)
	Out[12]: 1
	
#### 3. 查询数据(fetchOne)

	    In [13]: c.execute("select b,i,l,f,s,u,bb,d,dt,td,t,st from test_datatypes")
	    Out[13]: 1

	    In [14]: r = c.fetchone()   # 查询一条记录

	    In [15]: r
	    Out[15]: 
	    ('\x01',
 	    -3,
 	    123456789012,
 	    5.7,
 	    'hello\'" world',
 	    'Espa\xc3\xb1ol',
 	    'binary\x00data',
 	    datetime.date(1988, 2, 2),
 	    datetime.datetime(2014, 7, 25, 1, 46, 6),
 	    datetime.timedelta(5, 6),
 	    datetime.timedelta(0, 59520),
 	    datetime.datetime(2014, 7, 25, 1, 46, 6))
 	
#### 4. 删除数据

	    In [23]: c.execute("delete from test_datatypes")
	    Out[23]: 1

	
#### 5. 查询多条数据（fetchAll）

	    In [19]: c.execute("insert into test_datatypes (i, l) values (2,4), (6,8), 	(10,12)")
	    Out[19]: 3

	    In [20]: c.execute("select l from test_datatypes where i in %s order by i", 	((2,6),))
	    Out[20]: 2

	    In [21]: r = c.fetchall()

	    In [22]: r
	    Out[22]: ((4,), (8,))
	
#### 6. 删除表

	    In [16]: c.execute("drop table test_datatypes")
	    Out[16]: 0

#### 7. 批量插入数据(BulkInsert)

	    In [24]: c.execute(
   	    ....: """CREATE TABLE bulkinsert
   	    ....: (
   	    ....: id int(11),
   	    ....: name char(20),
   	    ....: age int,
   	    ....: height int,
   	    ....: PRIMARY KEY (id)
   	    ....: )
   	    ....: """)
	    Out[24]: 0

	    In [25]: data = [(0, "bob", 21, 123), (1, "jim", 56, 45), (2, "fred", 100, 180)]

	    In [28]: c.executemany("insert into bulkinsert (id, name, age, height) values (%s,%s,%s,%s)", data)
	    Out[28]: 3
	
好迟了，就写到这里了，由于 PyMySQL 的文档非常匮乏，于是萌生了写这篇教程的想法。还会继续更新。

Good Night！欢迎多多提 Bug！

