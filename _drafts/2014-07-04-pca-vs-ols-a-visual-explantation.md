---
layout: post
title: "主成分分析（PCA） VS 最小二乘法（OLS）: 一个视觉化的解释"
description: ""
category: algorithm, R
tags: [R, PCA, OLS]
---
{% include JB/setup %}

> 原文来源: http://www.cerebralmastication.com/2010/09/principal-component-analysis-pca-vs-ordinary-least-squares-ols-a-visual-explination/

在 [stats.stackexchange.com](stats.stackexchange.com)（stackexchange 的统计学专栏） 上，一个有趣的 [关于主成分分析（PCA）](http://stats.stackexchange.com/questions/2691/making-sense-of-principal-component-analysis-eigenvectors-eigenvalues/2700#2700)的问题关注度在不断攀升。问题是“多亏了我的大学课程，我学会了算数，但是它到底是什么意思？”

在我的一生中，我难得的几次有感觉。我的大部分学习课程的重心是技术的实现，貌似缺乏了更重要的章节，"Why I give a shit?"(为什么我要在乎它？)。有一个很完美的例子来解释它：我经济学课上的数学定理将会了我如何手动算出乏味的[海森矩阵](http://zh.wikipedia.org/wiki/%E6%B5%B7%E6%A3%AE%E7%9F%A9%E9%98%B5)（在数学中，海森矩阵（Hessian matrix或Hessian）是一个自变量为向量的实值函数的二阶偏导数组成的方块矩阵），但是在我的生命中，我完全搞不懂为什么要算出这样的一个变态的公式。好吧，我只是在吐槽。后来，我发现海森矩阵可以在一些优化后是使用二次求导数（second derivative test ）来验证。我不再手工算出这些，而是使用了一些 R 包，并盲目地相信它被正确地编写地。

现在回到 PCA：当我读到地上述的统计学问题，我突然想起 8 月份 R 大会上 [Paul Teetor](http://quanttrader.info/public/)（一位定量分析专家，《R Cookbook》的作者）的演讲；他在金融届传播 R 语言，使用了图来展示 OLS 和 PCA 之间的不同。我做了些笔记，以便我回家能重新实现一次。如果你也想知道是什么造成了 OLS 和 PCA 之间的差异，那就打开你的 R 软件，一起求证它。

#### 你的自变量实验：




