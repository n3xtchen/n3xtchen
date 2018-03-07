---
layout: post
title: "Spark ML: 创建你自己的算法模型和管道"
description: ""
category: Scala
tags: [spark, ml]
---
{% include JB/setup %}

**Spark ML Pipeline** 有各种各样的算法同时，你可能发现自己也需要不离开 **Pipeline** 模型也可以使用额外的函数；在 **Spark MLlib** 中，就不是个事 —— 你可以使用 **RDD** 转换器实现自己的算法。至于 **Spark ML Pipeline** ，同样的方法也可用，但是我们失去了 **Pipeline** 优雅的整合方式，包括自动运行元算法（**meta-algorithms**，对其他算法进行组合的方式），例如参数交叉验证（**cross-validation parameter search**）。在这篇文章中，将使用 **word count** 示例作为入门课程，来演示 **Spark ML Pipeline Model** 类编写（做算法的哥么永远无法摆脱 **word count** 示例，^_^）。 

如果你想把你自实现的算法添加到 **Spark Pipeline** 中，则需要实现 `Estimator` 或 `Transformer`（它们都是 **PipelineStage** 接口的实现）。对于不要求训练的算法，你只要实现 `Transformer` 接口；至于需要训练的算法，同时还需要实现 `Estimator` 接口，你的实现都需要 `org.apache.spark.ml` 包下。你还需要注意训练不仅限于复杂的机器学习模型；`MinMaxScaler` 也需要训练来决定范围。如果他们需要训练，那么他们必须实现 `Estimator` 而不是 `Transform`。

> ##### 注意
>
> 直接使用 `PipelineStage` 将无法奏效，因为 `Pipeline` 内部使用的是反射，而它假定所有的阶段（Stages）不是 `Estimator`  就是 `Transformer`。

除了 `transform` 和 `fit` 之外，所有的 **Pipeline Stage(管道阶段)** 还需要提供 `transformSchema` 和 `copy` 构造器或实现一个类（`copy` 用于给当前阶段制作副本，它会将新指定参数合并进来，也可以被叫做  `defaultCopy`，除非你的类有特殊的构造函数 ）

在 **Pipeline Stage** 的开始或者副本委派阶段，`transformSchema` 必须根据任何参数集和输入模式产生你的 **Pipeline Stage** 所期待的输出。大部分 **Pipeline Stage** 简单的加入新的字段；除非需要，一般不会丢弃之前的字段，但是有时会导致比下游需要的包含更多数据，这样会导致性能问题。如果你发现在你的 **Pipeline** 这是个问题，你可以创建你自己的 **Stage** 来去除不必要的字段。

```scala
class HardCodedWordCountStage(override val uid: String) extends Transformer {
  def this() = this(Identifiable.randomUID("hardcodedwordcount"))

  def copy(extra: ParamMap): HardCodedWordCountStage = {
  	defaultCopy(extra)  
  }
```

除了生成输出的模式，`transformSchema` 函数应该验证输入模式是否符合这个 **Stage**（例如，输入的字段是否是预期类型）。

这里也是你执行 **Stage** 参数验证的地方。

一个简单的 `transformSchema` ，输入字符串，输出向量，正如如下所示（字段名都是硬编码）：

```scala
override def transformSchema(schema: StructType): StructType = {
     // Check that the input type is a string
    val idx = schema.fieldIndex("happy_pandas")
    val field = schema.fields(idx)
    if (field.dataType != StringType) {
      throw new Exception(s"Input type ${field.dataType} did not match input type StringType")
    }
    // Add the return field
    schema.add(StructField("happy_panda_counts", IntegerType, false))
  }
```

不需要训练的算法只要使用 `Transformer` 接口就可以轻易实现了。由于是一个简单的 **Pipeline Stage**，我们可以实现一个简单的转换器，输入字符串返回字数。

```scala
 def transform(df: Dataset[_]): DataFrame = {
    val wordcount = udf { in: String => in.split(" ").size }
    df.select(col("*"),
      wordcount(df.col("happy_pandas")).as("happy_panda_counts"))
  }
```

为了充分利用 **Pipeline** 接口，您需要使用 **params（参数）** 接口使您的管道阶段可配置。

**params** 接口都是公有的，然而不幸的是，**Spark** 内部常用的默认参数是私有的，因此你会得到一份很多重复代码。除了允许用户指定值之外，参数也可以包含一些基本的验证逻辑（e.g. 正则化参数必须是非负数）。最常用的两个常数就是输入字段和输出字段。

字符参数外，其他的类型也可以使用，包括停用词的字符串列表。

```scala
class ConfigurableWordCount(override val uid: String) extends Transformer {
  final val inputCol= new Param[String](this, "inputCol", "The input column")
  final val outputCol = new Param[String](this, "outputCol", "The output column")

 ; def setInputCol(value: String): this.type = set(inputCol, value)

  def setOutputCol(value: String): this.type = set(outputCol, value)

  def this() = this(Identifiable.randomUID("configurablewordcount"))

  def copy(extra: ParamMap): HardCodedWordCountStage = {
    defaultCopy(extra)
  }

  override def transformSchema(schema: StructType): StructType = {
    // Check that the input type is a string
    val idx = schema.fieldIndex($(inputCol))
    val field = schema.fields(idx)
    if (field.dataType != StringType) {
      throw new Exception(s"Input type ${field.dataType} did not match input type StringType")
    }
    // Add the return field
    schema.add(StructField($(outputCol), IntegerType, false))
  }

  def transform(df: Dataset[_]): DataFrame = {
    val wordcount = udf { in: String => in.split(" ").size }
    df.select(col("*"), wordcount(df.col($(inputCol))).as($(outputCol)))
  }
}

```

需要训练的算法则需要实现 `Estimator` 接口 —— 尽管对于许多算法，`org.apache.spark.ml.Predictor` 或 `org.apache.spark.ml.classificationClassifier` 助手类更容易实现。`Estimator` 和 `Transformer` 最本质的不同：除了直接表达对输入的转换之外，还要有一个训练步骤（ `train` 函数的形式）。一个字符索引（String Indexer）是一个你可以实现的最简单评估器（`Estimator`），虽然他已经在 **Spark** 中实现了，但是仍然不影响它成为一个演示 `Estimator` 接口使用的好例子。

```scala
trait SimpleIndexerParams extends Params {
  final val inputCol= new Param[String](this, "inputCol", "The input column")
  final val outputCol = new Param[String](this, "outputCol", "The output column")
}

class SimpleIndexer(override val uid: String) extends Estimator[SimpleIndexerModel] with SimpleIndexerParams {

  def setInputCol(value: String) = set(inputCol, value)

  def setOutputCol(value: String) = set(outputCol, value)

  def this() = this(Identifiable.randomUID("simpleindexer"))

  override def copy(extra: ParamMap): SimpleIndexer = {
    defaultCopy(extra)
  }

  override def transformSchema(schema: StructType): StructType = {
    // Check that the input type is a string
    val idx = schema.fieldIndex($(inputCol))
    val field = schema.fields(idx)
    if (field.dataType != StringType) {
      throw new Exception(s"Input type ${field.dataType} did not match input type StringType")
    }
    // Add the return field
    schema.add(StructField($(outputCol), IntegerType, false))
  }

  override def fit(dataset: Dataset[_]): SimpleIndexerModel = {
    import dataset.sparkSession.implicits._
    val words = dataset.select(dataset($(inputCol)).as[String]).distinct
      .collect()
    new SimpleIndexerModel(uid, words)
 ; }
}

class SimpleIndexerModel(
  override val uid: String, words: Array[String]) extends Model[SimpleIndexerModel] with SimpleIndexerParams {

  override def copy(extra: ParamMap): SimpleIndexerModel = {
    defaultCopy(extra)
  }

  private val labelToIndex: Map[String, Double] = words.zipWithIndex.
    map{case (x, y) => (x, y.toDouble)}.toMap

  override def transformSchema(schema: StructType): StructType = {
    // Check that the input type is a string
    val idx = schema.fieldIndex($(inputCol))
    val field = schema.fields(idx)
    if (field.dataType != StringType) {
      throw new Exception(s"Input type ${field.dataType} did not match input type StringType")
    }
    // Add the return field
    schema.add(StructField($(outputCol), IntegerType, false))
  }

  override def transform(dataset: Dataset[_]): DataFrame = {
    val indexer = udf { label: String => labelToIndex(label) }
    dataset.select(col("*"),
      indexer(dataset($(inputCol)).cast(StringType)).as($(outputCol)))
  }
}
```

如果你实现一个迭代算法（iterative algorithm），你可能需要考虑自动缓存输入数据（如果它没有被缓存），或者允许用户指定持久化登记。

 `Predictor` 接口添加三个最常用的参数（输入和输出字段）： **标签字段（Label）** 和**特征字段（Featuire）**和预测字段——为我们提供自动处理模式的转换器（schema transformation）。

`Classifier` 接口也做了同样的事情，除了他还添加了一个 `rawPredictionColumn` 字段和提供工具来侦测分类的个数，并将输入的 `DataFrame`  转化成 `LabeledPoint` 的 `RDD`（这使得封装遗留 **MLlib** 分类算法更加容易）。

如果你要实现一个回归或者聚类接口，没有公有基础接口使用，因此你需要使用普通的 `Estimator` 接口。

```scala
// Simple Bernouli Naive Bayes classifier - no sanity checks for brevity
// Example only - not for production use.
class SimpleNaiveBayes(val uid: String)
    extends Classifier[Vector, SimpleNaiveBayes, SimpleNaiveBayesModel] {

  def this() = this(Identifiable.randomUID("simple-naive-bayes"))

  override def train(ds: Dataset[_]): SimpleNaiveBayesModel = {
    import ds.sparkSession.implicits._
    ds.cache()
    // Note: you can use getNumClasses and extractLabeledPoints to get an RDD instead
    // Using the RDD approach is common when integrating with legacy machine learning code
    // or iterative algorithms which can create large query plans.
    // Here we use Datasets since neither of those apply.

    // Compute the number of documents
    val numDocs = ds.count
    // Get the number of classes.
    // Note this estimator assumes they start at 0 and go to numClasses
    val numClasses = getNumClasses(ds)
    // Get the number of features by peaking at the first row
    val numFeatures: Integer = ds.select(col($(featuresCol))).head
      .get(0).asInstanceOf[Vector].size
    // Determine the number of records for each class
    val groupedByLabel = ds.select(col($(labelCol)).as[Double]).groupByKey(x => x)
    val classCounts = groupedByLabel.agg(count("*").as[Long])
      .sort(col("value")).collect().toMap
    // Select the labels and features so we can more easily map over them.
    // Note: we do this as a DataFrame using the untyped API because the Vector
    // UDT is no longer public.
    val df = ds.select(col($(labelCol)).cast(DoubleType), col($(featuresCol)))
    // Figure out the non-zero frequency of each feature for each label and
    // output label index pairs using a case clas to make it easier to work with.
    val labelCounts: Dataset[LabeledToken] = df.flatMap {
      case Row(label: Double, features: Vector) =>
        features.toArray.zip(Stream from 1)
          .filter{vIdx => vIdx._2 == 1.0}
          .map{case (v, idx) => LabeledToken(label, idx)}
    }
    // Use the typed Dataset aggregation API to count the number of non-zero
    // features for each label-feature index.
    val aggregatedCounts: Array[((Double, Integer), Long)] = labelCounts
      .groupByKey(x => (x.label, x.index))
      .agg(count("*").as[Long]).collect()

    val theta = Array.fill(numClasses)(new Array[Double](numFeatures))

    // Compute the denominator for the general prioirs
    val piLogDenom = math.log(numDocs + numClasses)
    // Compute the priors for each class
    val pi = classCounts.map{case(_, cc) =>
      math.log(cc.toDouble) - piLogDenom }.toArray

    // For each label/feature update the probabilities
    aggregatedCounts.foreach{case ((label, featureIndex), count) =>
      // log of number of documents for this label + 2.0 (smoothing)
      val thetaLogDenom = math.log(
        classCounts.get(label).map(_.toDouble).getOrElse(0.0) + 2.0)
      theta(label.toInt)(featureIndex) = math.log(count + 1.0) - thetaLogDenom
    }
    // Unpersist now that we are done computing everything
    ds.unpersist()
    // Construct a model
    new SimpleNaiveBayesModel(uid, numClasses, numFeatures, Vectors.dense(pi),
      new DenseMatrix(numClasses, theta(0).length, theta.flatten, true))
  }

  override def copy(extra: ParamMap) = {
    defaultCopy(extra)
  }
}

// Simplified Naive Bayes Model
case class SimpleNaiveBayesModel(
  override val uid: String,
  override val numClasses: Int,
  override val numFeatures: Int,
  val pi: Vector,
  val theta: DenseMatrix) extends
    ClassificationModel[Vector, SimpleNaiveBayesModel] {

  override def copy(extra: ParamMap) = {
    defaultCopy(extra)
  }

  // We have to do some tricks here because we are using Spark's
  // Vector/DenseMatrix calculations - but for your own model don't feel
  // limited to Spark's native ones.
  val negThetaArray = theta.values.map(v => math.log(1.0 - math.exp(v)))
  val negTheta = new DenseMatrix(numClasses, numFeatures, negThetaArray, true)
  val thetaMinusNegThetaArray = theta.values.zip(negThetaArray)
    .map{case (v, nv) => v - nv}
  val thetaMinusNegTheta = new DenseMatrix(
    numClasses, numFeatures, thetaMinusNegThetaArray, true)
  val onesVec = Vectors.dense(Array.fill(theta.numCols)(1.0))
  val negThetaSum: Array[Double] = negTheta.multiply(onesVec).toArray

  // Here is the prediciton functionality you need to implement - for ClassificationModels
  // transform automatically wraps this - but if you might benefit from broadcasting your model or
  // other optimizations you can also override transform.
  def predictRaw(features: Vector): Vector = {
    // Toy implementation - use BLAS or similar instead
    // the summing of the three vectors but the functionality isn't exposed.
    Vectors.dense(thetaMinusNegTheta.multiply(features).toArray.zip(pi.toArray)
      .map{case (x, y) => x + y}.zip(negThetaSum).map{case (x, y) => x + y}
      )
  }
}
```

> ##### 注意
>
> 如果你知识简单的修改现有的算法，你可以拓展它（伪装成 `org.apache.spark` 项目 ）。

现在你已经学会如何拓展 **Spark ML Pipeline** 的 **API**。如果你迷失了，有一个好的参考就是 **Spark** 的算法实现。——虽然它有时使用内部的 **API**，但是大部分地方他们都是实现公有接口（如你想要的方式）。

> * [Extend Spark ML for your own model/transformer types](https://www.oreilly.com/learning/extend-spark-ml-for-your-own-modeltransformer-types)