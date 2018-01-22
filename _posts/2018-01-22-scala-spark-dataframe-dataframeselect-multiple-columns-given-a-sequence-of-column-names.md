---
layout: post
title: "Scala Spark DataFrame: dataFrame.select 传入可变参数的方法"
description: ""
category: Scala
tags: [Spark]
---
{% include JB/setup %}

今天遇到个简单的错误，在这里与大家分享下。

测试脚本如下：

```
import org.apache.spark.sql.{SparkSession, DataFrame}
val spark = sparkSesssion.builder.getOrCreate()
import spark.implicits._

val foo = Seq((1, 2, 3), (3, 4, 5)).toDF("a", "b", "c")
val selectFields = Seq("a", "c")
foo.select(selectFields: _*).show
```

本来很简单的东西，结果报错了！

```
[error] /path/to/your.scala:XX: overloaded method value select with alternatives:
[error][U1](c1: org.apache.spark.sql.TypedColumn[org.apache.spark.sql.Row,U1])org.apache.spark.sql.Dataset[U1] <and>
[error]   (col: String,cols: String*)org.apache.spark.sql.DataFrame <and>
[error]   (cols: org.apache.spark.sql.Column*)org.apache.spark.sql.DataFrame
[error]  cannot be applied to (Array[String])
[error]     df.select(colNames).toDF(fieldNames: _*)
[error]        ^
[error] one error found
[error] (compile:compileIncremental) Compilation failed
```

好死不死，没有认真看报错信息或者看接口文档，调到我怀疑人生。

其实很简单的， 是 `DataFrame.select` 的封装如此，在认真看看报错信息：

```
[error]   (col: String,cols: String*)org.apache.spark.sql.DataFrame <and>
[error]   (cols: org.apache.spark.sql.Column*)org.apache.spark.sql.DataFrame
```

为什么会分装成这样。。。针对传入的是字符，必须是 `(col="字符", cols=Seq("字符列表"): _*)`

所以正确的代码是

```
import org.apache.spark.sql.{SparkSession, DataFrame}
val spark = sparkSesssion.builder.getOrCreate()
import spark.implicits._

val foo = Seq((1, 2, 3), (3, 4, 5)).toDF("a", "b", "c")
val selectFields = Seq("a", "c")

// 如果传入的是字符串序列
foo.select(selectFields.head, selectFields.tail: _*).show

// 如果字符序列转化成 DataFrame.col，就可以直接传可变参数
foo.select(selectFields.map(fool.col(_)): _*).show
```

再次吐槽下，为什么对字符串序列和列序列不用同一种封装。。。