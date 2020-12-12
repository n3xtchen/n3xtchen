---
layout: post
title: "提高 Scala 代码的可读性（For Spark）"
description: ""
category: Scala
tags: [Spark]
---
{% include JB/setup %}

**Jupyter** 和 **Apache Zeppelin*** 是一个数据处理体验比较好的地方。不幸的是，notebooks 的特点决定了他不擅长组织代码，包括去耦合（decomposition）和可读性。我们要将代码复制到 IDE 上，然后编译成 JAR，但是效果不是很好。接下来，我们将会讲如何在 IDE 中编写可读性更高的代码。

### 1. 编写基础代码

这是一个简单的例子：
1. 下载杂货店数据文件
1. 过滤出水果
1. 格式化名称
1. 统计每一个水果的数量


    val spark = SparkSession
        .builder
        .appName("MyAwesomeApp")
        .master("local[*]")
        .getOrCreate()

    import spark.implicits._

    val groceries = spark.read
        .option("inferSchema", "true")
        .option("header", "true")
        .csv("some-data.csv")

    val sumOfFruits = groceries
        .filter($"type" === "fruit")
        .withColumn("normalized_name", lower($"name"))
        .groupBy("normalized_name")
        .agg(
            sum(($"quantity")).as("sum")
        )

    val fruits = groceries.filter($"type" === "fruit")

    val normalizedFruits = fruits.withColumn("normalized_name", lower($"name"))

    val sumOfFruits = normalizedFruits
        .groupBy("normalized_name")
        .agg(
            sum(($"quantity")).as("sum")
        )

    sumOfFruits.show()


### 2. 提取方法

创建方法和每一步业务关联，如果你使用的是 IDE，从选中的代码中创建方法应该很简单。

    def main(args: Array[String]) {
        val spark = SparkSession
            .builder
            .appName("MyAwesomeApp")
            .master("local[*]")
            .getOrCreate()

        import spark.implicits._

        val groceries: DataFrame = getGroceries
        val fruits: Dataset[Row] = filterFruits(groceries)
        val normalizedFruits: DataFrame = withNormalizedName(fruits)
        val sumOfFruits: DataFrame = sumByNormalizedName(normalizedFruits)

        sumOfFruits.show()
    }

    private def sumByNormalizedName(normalizedFruits: DataFrame) = {
        val sumOfFruits = normalizedFruits
            .groupBy("normalized_name")
            .agg(
                sum(($"quantity")).as("sum")
            )
        sumOfFruits
    }

    private def withNormalizedName(fruits: Dataset[Row]) = {
        val normalizedFruits = fruits.withColumn("normalized_name", lower($"name"))
        normalizedFruits
    }

    private def filterFruits(groceries: DataFrame) = {
        val fruits = groceries.filter($"type" === "fruit")
        fruits
    }

    private def getGroceries: DataFrame = {
        val groceries = spark.read
            .option("inferSchema","true")
            .option("header","true")
            .csv("some-data.csv")
        groceries
    }

main 函数的代码已经更可读了吧。。。但是这个代码无法执行。我们需要在有些方法中使用 `SparkSession` 和 `spark.implicits._` 。但是这些值没在方法的作用于内。


    private def getGroceries: DataFrame = {
        val groceries = spark.read
            .option("inferSchema","true")
            .option("header","true")
            .csv("some-data.csv")
        groceries
    }

### 2. 无尽的 SparSession

我们可以通过传参的方式来解决这个问题。但是，这种方法不够优雅，而且蛋疼。我们还需要每次都要导入 `spark.implicits._`。但是程序员毕竟还是懒惰的。

    private def sumByNormalizedName(normalizedFruits: DataFrame, spark: SparkSession) = {
        import spark.implicits._
        val sumOfFruits = normalizedFruits
            .groupBy("normalized_name")
            .agg(
                sum(($"quantity")).as("sum")
            )
        sumOfFruits
    }

    private def withNormalizedName(fruits: Dataset[Row], spark: SparkSession) = {
        import spark.implicits._
        val normalizedFruits = fruits.withColumn("normalized_name", lower($"name"))
        normalizedFruits
    }

    private def filterFruits(groceries: DataFrame, spark: SparkSession) = {
        import spark.implicits._
        val fruits = groceries.filter($"type" === "fruit")
        fruits
    }

    private def getGroceries(spark: SparkSession): DataFrame  = {
        val groceries = spark.read
            .option("inferSchema","true")
            .option("header","true")
            .csv("some-data.csv")
        groceries
    }

### 3. 封装你的 SparkSession

我们提供一种稍稍不同的 `SparkSession` 访问方式，这样代码就更简洁了。

    package org.nextchen.demo.base

    import org.apache.spark.sql.SparkSession

    trait SparkJob {
        val spark: SparkSession = SparkSession
            .builder
            .appName("SomeApp")
            .master("local[*]")

    }

    object SparkJob extends SparkJob {}

现在，我们可以在应用中引入 `SparkJob` 和 `spark.implicits._`。这样，代码看起来好多了。我们也可以复用它。

    import org.apache.spark.sql._
    import org.apache.spark.sql.functions._
    import org.nextchen.demo.base.SparkJob
    import org.nextchen.demo.base.spark.implicits._

    object NiceApp {
        val spark = SparkJob.spark

        def main(args: Array[String]) = {
            val groceries: DataFrame = getGroceries
            val fruits: Dataset[Row] = filterFruits(groceries)
            val normalizedFruits: DataFrame = addNormalizedNameColumn(fruits)
            val sumOfFruits: DataFrame = sumByNormalizedName(normalizedFruits)
            sumOfFruits.show()
        }

        private def sumByNormalizedName(normalizedFruits: DataFrame) = {
            val sumOfFruits = normalizedFruits
                .groupBy("normalized_name")
                .agg(
                    sum(($"quantity")).as("sum")
                )
            sumOfFruits
        }

        private def addNormalizedNameColumn(fruits: Dataset[Row]) = {
            val normalizedFruits = fruits.withColumn("normalized_name", lower($"name"))
            normalizedFruits
        }

        private def filterFruits(groceries: DataFrame) = {
            val fruits = groceries.filter($"type" === "fruit")
            fruits
        }

        private def getGroceries: DataFrame = {
            val groceries = spark.read
                .option("inferSchema", "true")
                .option("header", "true")
                .csv("some-data.csv")
            groceries
        }
    }

### 4. 隐式类（Implicit class）

如果你深入使用过动态类型语言（如 Python、Ruby）的话，应该对 **猴子布丁（Monkey Patch）** 的概念不会陌生，你可以动态为存在的类型添加方法，而不用改变它。隐式类就是 Scala 的猴子布丁，C# 的 Extension Method 也是类似的概念。不理解没关系，看看例子：


    val numberA = 1
    val numberB = 2
    val sum = sum(numberA, numberB)
    ...
    def sum(Int numberA, Int numberB): Int = {
        return numberA + numberB
    }

我们可以写成

    val numberA = 1
    val numberB = 2
    val sum = numberA.add(numberB)
    ...
    implicit class MyInt(numberA: Int) {
        def add(numberB: Int) = numberA + numberB
    }

调用的时候，可读性的巨大差别一目了然：

    sum(A, sum(B, sum(C,sum(D,...))))
    // VS
    A.add(B).add(C).add(D)...
    // scala 可以忽略点号，可以写成
    A add B add C add C

下面是利用隐式转换重新组织的代码：

    package org.nextchen.demo.extensions

    import org.apache.spark.sql._
    import org.apache.spark.sql.functions._
    import org.nextchen.demo.base.SparkJob.spark.implicits._

    object GroceryDataFrameExtensions {
        implicit class RichDataFrame(df: DataFrame) {
            def sumByNormalizedName: DataFrame = {
                val sumOfFruits = df
                    .groupBy("normalized_name")
                    .agg(
                        sum(($"quantity")).as("sum")
                    )
                sumOfFruits
            }

            def addNormalizedNameColumn: DataFrame = {
                val normalizedFruits = df.withColumn("normalized_name", lower($"name"))
                normalizedFruits
            }

            def filterFruits: DataFrame = {
                val fruits = df.filter($"type" === "fruit")
                fruits
            }
        }

    }

将代码逻辑移到了另一个对象中，这代码读起来就像读散文，不是吗？

    package org.nextchen.demo

    import org.apache.spark.sql.DataFrame
    import pl.wiadrodanych.demo.NiceApp.spark
    import pl.wiadrodanych.demo.extensions.GroceryDataFrameExtensions._

    object CoolApp {
        def main(args: Array[String]) = {
            val result = getGroceries
                .filterFruits
                .addNormalizedNameColumn
                .sumByNormalizedName

            result.show
        }

        private def getGroceries: DataFrame = {
            val groceries = spark.read
            .option("inferSchema", "true")
            .option("header", "true")
            .csv("some-data.csv")
            groceries
        }
    }

回头看一下我们的需求：

1. 下载杂货店数据（getGroceries）
1. 过滤水果（filterFruits）
1. 格式化名称（addNormalizedNameColumn）
1. 统计每一个水果的数量（sumByNormalizedName）

看出来吧，代码即文档，^_^。

友情提醒：隐式转换虽好，不可滥用。不是最佳实践，请慎用！请慎用！请慎用！不然对代码维护造成灾难。
