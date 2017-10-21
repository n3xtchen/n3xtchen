---
layout: post
title: "Spark - 机器学习入门"
description: ""
category: Spark
tags: [scala]
---
{% include JB/setup %}



这一两年非常火的主题就是机器学习 - 与计算统计密切相关的跨学科领域，让我们的计算机学会不被明确编程下进行自动化工作。

研究表明，在数据分析领域，机器学习被广泛的使用 - 从贷款风险评估到自动驾驶技术。

在接下来的文章中，我将把 **MLlib**（**Spark** 的机器学习）介绍给大家。

在阅读之前，还有一点很重要 - 本文旨在介绍库的使用，而不是机器学和统计学背后的概念和理论。因此，需要读者对这些主题有基本的概念；同时还需要 **Spark** 的基础知识。

本文基于 **Apache** **Spark** 2.X 的 **API**，它引入了新的 **DataFrame** （和旧的 ** RDD** 有较大区别）。使用 **DataFrame** 的好处之一就是使用起来比 RDD 更简单，更友好。诚然， **RDD** 将仍然可以使用，但是已经处在维护模式（它将不再进行新功能开发；当 **DataFrame** 成熟足以取代 **RDD**，它将被弃用）。

### MLlib 介绍

**MLlib** （Machine Learning Library 的缩写）是 **Apache** **Spark** 下的机器学习库，在解决机器学习问题方面提供极好的拓展性和易用性。目前，**MLlib** 使用 **Breeze** 解决线性代数问题。

该库包含了很多的特性，我现在做个简短介绍。每一个特征都会在后续的章节中进行深入探讨。

#### 功能

##### 算法

* 回归（Regression）
  * 线性回归（Linear）
  * 广义线性回归（Generalized Linear）
  * 决策树（Decision Tree）
  * 随机森林（Random Forest）
  * 梯度提升树（Gradient-boosted Tree）
  * Survival
  * Isotonic
* 分类（Classification）
  * 逻辑回归（Logistic，二分类和多酚类）
  * 决策树（Decision Tree）
  * 随机森林（Random Forest）
  * 梯度提升树（Gradient-boosted Tree）
  * 多层反馈（Multilayer Perceptron）
  * 支持向量机（Linear support vector machine）
  * One-vs-All
  * 朴素贝叶斯（Naive Bayes）
* 聚类（Clustering）
  * K-means
  * 隐含狄利克雷分布（LDA）
  * Bisecting K-means
  * 高斯混合模型（Gaussian Mixture Model）
* 协同过滤（Collaborative Filtering）

##### 特征工程（Featurization）

* 特征提取
* 转换
* 降维（Dimensionality reduction）
* 筛选（Selection）

##### 管道（Pipelines）

* 组合管道（Composing Pipelines）
* 构建、评估和调优（Tuning）机器学习管道

##### 持久化（Persistence）

* 保存算法，模型和管道到持久化存储器，以备后续使用
* 从持久化存储器载入算法、模型和管道

##### 实用工具（Utilities）

* 线性代数（Linear algebra）
* 统计
* 数据处理
* 其他

### DataFrame

正如前面提到的，**DataFrame** 是 **Spark** 2.X 新引入的特性，用来取代旧的 **RDD**。**DataFrame** 是 **Spark** 的一种数据集（简单的说，一个分布式，强类型的数据集合，在 **Spark** 1.6 的时候接口初次被引入），由字段（Column，以变量形式呈现）组成。

它的概念和 **关系数据库** 中的 **表** 或者 **R**/**Python** 的 **DataFrame** 一样，但是进行了一系列的优化。

#### 独特性

那么相较于 **RDD**， **DataFrame** 的主要卖点和优势是什么呢？

* ​



> 译自 https://blog.scalac.io/scala-spark-ml.html