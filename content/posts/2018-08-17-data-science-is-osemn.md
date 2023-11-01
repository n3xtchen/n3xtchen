---
categories:
- DATA-Science
date: "2018-08-17T00:00:00Z"
description: ""
tags:
- ml
title: '数据的一生: OSEMN 数据科学流水线方法'
---

很久以前，有一个男孩，他名字叫数据。穷其一生，他一直在尝试理解生命的意义。我的价值是什么？我能对这个世界找成什么影响？我来自哪里？这些问题一直萦绕在他的脑海中；幸运的是，纯粹运气，数据最后找到了一个方法，并通过了一次伟大的变革。

这一切都始于数据在他遇到一个奇怪但有趣的管道（Pipe）时走下行。管道的一端是入口，另一个端是出口。这个管道也可以使用 5 个字符来标记：“O.S.E.M.N”。好奇心使然，他决定进入管道。长故事短说……进入的是数据，出来的是洞见（Insight）。

## 数据科学就是 OSEMN

作为有抱负的数据科学家，你有机会磨练你的巫师和侦探的力量。在巫师的一面，我的意思是指拥有预测的能力。在侦探的一面，你可以找到数据的未知模式和趋势。

理解数据科学管道的标准工作流是通往业务理解和问题解决的关键步骤。我发现一个非常简单的首字母缩写来概括数据科学管道。那就是 O.S.E.M.N。

请记住：本文将简要介绍对典型数据科学管道中的预期的高级概述。从构建业务问题来创建可操作的见解。不要当心，很好理解的！

## OSEMN 管道

* O(Obtain): 获取数据
* S(Scrub): 清洗你的数据
* E(Explore): 探索/可视化数据，帮助我们寻找模式和趋势
* M(Model): 为你的数据构建模型，将赋予我们预测的巫师魔力
* N(iNterpret): 解释我们的数据

## 业务问题

开始 OSEMN 管道之前，最至关重要的一步，以及我们必须考虑了的一点，理解我们尝试解决的问题。

问你自己：

* 我们如何把数据转化成现金？
* 我可以使用这些数据产生多大的影响？
* 我们的模型带来怎么样的商业价值？
* 什么能帮助我们节省成本？
* 有哪些可以事情让我们的业务更有效地开展？

理解这个基础概念将让你走的更远，让你向数据科学家（我并不是，但是坚信能）迈出一大步。尽管如此，不管你预测的模型效果有多好，不管有多少数据，不管你的管道有多 OSEMN…**你的方案和可操作洞见只能很好地适用于你要解决的问题。**

> "出色的数据科学有赖于你对数据提出的问题而不仅仅是数据清洗和分析" —— Riley Newman

## 获取数据

作为数据科学家，没有数据寸步难行。根据经验，在你获取数据时候，有些事情你必须考虑。你必须鉴定你所拥有的所有数据（可能来源于网络、外部或内部数据库）。你必须把数据抽取（extract）成可用的数据结构（.csv，json，xml 等等）

### 技能要求

* 数据库管理: MySQL/PostgreSQL/MongDB
* 关系数据库查询技术
* 提取无结构的数据：文本，视频，音频以及文档
* 分布式存储：Hadoop，Apache Spark/Flink

## 清洗数据

管道的这个阶段通常是最耗费时间和精力的。因为结果和机器学习的输出只和你的输出强相关。俗话说，龙生龙凤生凤，老鼠生的孩子会打洞。同样也适用于数据科学，输入模型的数据质量越好，噪音越小，输出模型的性能指标通常就越好。

### 目标

* 检查数据：了解您正在使用的每一个特镇，识别错误，缺失值和损坏记录
* 清洗数据：丢弃、替换以及填补缺失值

### 技能要求

* 脚本语言：Python/R/SAS
* 数据清洗工具：Python Panda/R
* 分布式处理：Hadoop/MapReduce/Spark

> "准备充分的人已经把战打了一半" —— Miguel de Cervantes

## 探索（探索性数据分析）

现在进入探索阶段，我们尝试了解数据的模式和价值。我们将使用不同类型的可视化和统计测试来支撑我们的发现。

### 技能要求

* Python: Numpy/Matplotlib/Pandas/Scipy
* R: GGplot2/Dplyr
* 推论统计：在**统计**学中，研究如何根据样本数据去推断总体数量特征的方法。 它是在对样本数据进行描述的基础上，对**统计**总体的未知数量特征做出以概率形式表述的推断。
* 实验设计
* 数据可视化

**提示**：在分析的过程中，会产生 **蜘蛛感官**  带来的刺痛；即有意识（故意）地去发现奇怪的模式和趋势。

> 蜘蛛感官：在《蜘蛛侠》中，男主角Peter是因為被一只轉基因的蜘蛛咬傷後，擁有非凡超能力，特異功能，並且也擁有了“蜘蛛感官”，他能感受到周圍存在的潛在危險，即使蜘蛛俠在行俠仗義時，在車輛快速行駛過程馬路上，任然可以躲避被車撞到的危險 。

**设计考虑**：大部分情况就是直接进行可视化。 这都是关于最终用户的解释。 专注于您的受众。

## 模型（机器学习）

现在进入大家感兴趣的环节。模型在统计学意义上是通用的规则。你可以把机器学习作为你工具集中的一个工具。你可以使用各种各样的算法来达到不同商业目的。你的特征越好，你的预测能力就越强。在清洗数据和寻找重要特征之后，使用模型作为预测工具将强化你的业务决策力。

**预测力的一个例子**：其中一个很棒例子就在在沃尔玛供应链中。沃尔玛可以预测飓风季节，在他们某个商场将会卖光他们的草莓流行挞。通过数据挖掘，他们的数据显示：飓风来临前的大部分畅销单品都是流行挞。听起来很疯狂，这是一个真实的故事，并提出了不低估预测分析能力的观点。

### 目标

* 深度分析：使用预测模型/算法
* 评估和优化模型

### 技能要求

* 机器学习：监督/无监督算法
* 评估方法
* 机器学习算法库：Python(Sci-kit)/R(CARET)
* 线性代数和多元微积分

## 解释（讲述数据故事）

这是故事时间！管道最重要的步骤是理解和学习如何解释你的发现。讲故事是关键，不要低估它的作用。它将余人对接，说服他们和帮助他们。

在故事讲述过程中，情感是关键的驱动力。人们不会奇迹般地马上理解的的发现。产生影响的最佳方式就是通过情感讲故事。作为人类，很大程度受情绪影响。如果你能让你受众感同身受，那一切将在你的掌握中。当你在呈现数据的时候，牢记心理学的重要。了解你的受众，并和他们产生链接的艺术就是数据故事的最佳中的一份。

强化说故事能力的最佳实践就是不断排练。

### 目标

* 验证你的业务洞见：回顾到业务问题
* 可视化你的发现：保持简单和优先级驱动
* 讲述一个清洗可行的故事：与非技术受众进行有效地沟通

### 技能要求

* 业务领域知识
* 数据可视化工具：Tableau/D3JS/Matplotlib/GGplot/Seaborn
* 沟通：展示/讲述 和 报告/写作

## 更新模型

不要担心的故事无止境。线上的模型，需要进行周期行的更新，频率依赖于你获取新数据的频率。假设你是亚马逊的数据科学家，你为客户推出了一项新功能，购买“鞋功能”。 你是旧模型没有这个，现在你必须更新包含此功能的模型。 如果没有，您的模型会随着时间的推移而降级，并且性能不会很好，从而使您的业务也会降级。 新功能的引入将通过不同的变化或可能与其他功能的相关性来改变模型性能。

## 结语

实际上，你遇到的大部分问题都是工程问题。即便你拥有机器学习大神的所有资源，产生的最大影响都来源于伟大的特征，而不是牛逼的机器学习算法。因此，基本方法论：

1. 确保你的管道是扎实地端对端
2. 从一个合理的目标出发
3. 直观理解你的数据（可视化）
4. 确保你的管道持续坚固（通过更新）

希望这些方法能够创造更多的价值（造福于企业），或者让很多人在很长的一段时间内感到 Happy（造福于用户）。

因此，下一次如果有人问你什么是数据科学。大胆地告诉他们：

“数据科学就是 OSEMN”
