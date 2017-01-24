---
layout: post
title: "Spark 实现简单移动平均值（SMA） - 窗口函数（Window Function）"
description: ""
category: Spark
tags: [scala, java]
---
{% include JB/setup %}

### 什么是简单移动平均值

简单移动平均（英语：Simple Moving Average，SMA）是某变数之前n个数值的未作加权算术平均。例如，收市价的10日简单移动平均指之前10日收市价的平均数。

### 直接看例子吧

    val df = List(
      ("站点1", "2017-01-01", 50),
      ("站点1", "2017-01-02", 45),
      ("站点1", "2017-01-03", 55),
      ("站点2", "2017-01-01", 25),
      ("站点2", "2017-01-02", 29),
      ("站点2", "2017-01-03", 27)
    ).toDF("site", "date", "user_cnt")
	
	import org.apache.spark.sql.expressions.Window
	import org.apache.spark.sql.functions._
	
    val wSpec = Window.partitionBy("site")
      .orderBy("date")
      .rowsBetween(-1, 1)
		
这个 window spec 中，数据根据用户(customer)来分去。每一个用户数据根据时间排序。然后，窗口定义从 -1(前一行)到 1(后一行)	，每一个滑动的窗口总用有3行

    df.withColumn("movingAvg",
      avg(df("user_cnt")).over(wSpec)).show()
							 
这段代码添加了一个新列，movingAvg，在滑动的窗口中使用了均值函数：

	+----+------------+--------+---------+
	|site|       date|user_cnt|movingAvg|
	+----+------------+--------+---------+
	| 站点1|2017-01-01|      50|     47.5|
	| 站点1|2017-01-02|      45|     50.0|
	| 站点1|2017-01-03|      55|     50.0|
	| 站点2|2017-01-01|      25|     27.0|
	| 站点2|2017-01-02|      29|     27.0|
	| 站点2|2017-01-03|      27|     28.0|
	+----+----------+--------+---------+

### 窗口函数和窗口特征定义

正如上述例子中，窗口函数主要包含两个部分：

1. 指定窗口特征（wSpec）
	1. "partitionyBY" 定义数据如何分组；在上面的例子中，他是用户
	2. "orderBy" 定义分组中的排序
	3. "rowsBetween" 定义窗口的大小 		
2. 指定窗口函数函数
	你可以使用 [org.apache.spark.sql.functions](https://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.functions$) 的“聚合函数（Aggregate Functions）”和”窗口函数（Window Functions）“类别下的函数

### 累计汇总

    val wSpec = Window.partitionBy("site")
      .orderBy("date")
      .rowsBetween(Long.MinValue, 0)
    df.withColumn("cumSum",
      sum(df("user_cnt")).over(wSpec)).show()

`.rowsBetween(Long.MinValue, 0)` ：窗口的大小是按照排序从最小值到当前行

	+----+----------+--------+------+
	|site|      date|user_cnt|cumSum|
	+----+----------+--------+------+
	| 站点1|2017-01-01|      50|    50|
	| 站点1|2017-01-02|      45|    95|
	| 站点1|2017-01-03|      55|   150|
	| 站点2|2017-01-01|      25|    25|
	| 站点2|2017-01-02|      29|    54|
	| 站点2|2017-01-03|      27|    81|
	+----+----------+--------+------+

### 前一行数据

    val wSpec = Window.partitionBy("site")
      .orderBy("date")
    df.withColumn("prevUserCnt",
      lag(df("user_cnt"), 1).over(wSpec)).show()
							 
`lag(field, n)`: 就是取从当前字段往前第n个值，这里是取前一行的值

	+----+----------+--------+-----------+
	|site|      date|user_cnt|prevUserCnt|
	+----+----------+--------+-----------+
	| 站点1|2017-01-01|      50|       null|
	| 站点1|2017-01-02|      45|         50|
	| 站点1|2017-01-03|      55|         45|
	| 站点2|2017-01-01|      25|       null|
	| 站点2|2017-01-02|      29|         25|
	| 站点2|2017-01-03|      27|         29|
	+----+----------+--------+-----------+

如果计算环比的时候，是不是特别有用啊？！

在介绍几个常用的行数：

* first/last(): 提取这个分组特定排序的第一个最后一个，在获取用户退出的时候，你可能会用到
* lag/lead(field, n): lead 就是 lag 相反的操作，这个用于做数据回测特别用，结果回推条件

### 排名
	
    val wSpec = Window.partitionBy("site")
      .orderBy("date")
    df.withColumn("rank",
      rank().over(wSpec)).show()
      
这个数据在提取每个分组的前n项时特别有用，省了不少麻烦。
	
	+----+----------+--------+----+
	|site|      date|user_cnt|rank|
	+----+----------+--------+----+
	| 站点1|2017-01-01|      50|   1|
	| 站点1|2017-01-02|      45|   2|
	| 站点1|2017-01-03|      55|   3|
	| 站点2|2017-01-01|      25|   1|
	| 站点2|2017-01-02|      29|   2|
	| 站点2|2017-01-03|      27|   3|
	+----+----------+--------+----+
	

		