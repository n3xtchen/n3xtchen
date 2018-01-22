---
layout: post
title: "理解特征工程 - 连续型（）数值特征"
description: ""
category: ml
tags: []
---
{% include JB/setup %}

## 介绍

**Money makes the world go round（金钱驱动整个世界运转）**，无论你同不同意，有些时候你无法忽视它。在数字革命的时代，**Data makes the world go round（数据驱动整个世界运转）** 这句话更准确。事实上，无论数据的规模大小，数据已经成为企业、公司和组织的首要（first class）资产。一个智能系统，无论其复杂性，都需要强大的数据支撑。智能系统的核心，我拥有一个多个基于机器学习、深度学习或者统计方法的算法来消费数据，收集知识，并在一段时间内提供智能洞见（Insight）。算法本身很幼稚，不能适用于原始数据。因此，从原始数据中提取有意义的特征是非常重要的，特闷可以被算法理解并消费。

## 标准机器学习任务管道

任何一个智能系统基本上都包含一个点对点的管道，从摄取原始数据，利用数据处理技术来清洗（wrangle），处理和工程化从这些数据中提取有意义的特征和属性。然后，我们时常利用如统计模型或者机器学习模型来模型化这些特征，然后根据需要解决的问题，部署该模型。如下展示的是是基于 [CRISP-DM](https://en.wikipedia.org/wiki/Cross-industry_standard_process_for_data_mining)  工业处理模型标准的机器学习管道

![机器学习管道](https://cdn-images-1.medium.com/max/1600/1*2T5rbjOBGVFdSvtlhCqlNg.png)

直接在原始数据之上建立模型是很蛮干的，因为我们不可能得到想要的结果和指标，算法也不会智能到自动从原始特征中提取有意义的特征（）。