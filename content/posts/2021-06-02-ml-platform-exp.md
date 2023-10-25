---
date: "2021-06-02T00:00:00Z"
description: ""
tags: []
title: ml platform exp
draft: true
---


你的数据科学家生产伟大的模型，但是只有模型应用在生产环境的使用，他们才能产生价值。如何让数据科学家轻松就能传递价值呢？

很多从事 ML 的公司同时也在投资 ML 平台，让数据科学家更快速地传递价值。这些平台


## 通用 ML 平台组件

从高维度看，


- 特征仓库：一个用来存储流批特征的服务，对外提供批处理和实施特征。一个特征仓库通常支持低延迟服务，同时允许跨团队贡献和访问特征。
- 工作流编排服务：模型训练工作通常以 DAG 图的方式呈现，需要一个工具来编排任务的执行。DAG 从简单 2 步 DAG（训练 -> 验证）到复杂结构（提供超参数优化和多模型）。我不想把模型训练pipeline 封装成一个组件，因为通常都是由平台负责编排，模型训练交给数据科学家
- 模型注册服务：训练好的模型存储在这里。模型的元数据（训练集、超参数、性能指标等等）将被记录。一般是一个UI，让用户检查自己的模型
- 模型推理服务：这个系统从模型注册服务获取模型，从特征仓库获取特征，输出他们的预测。
- 模型质量监控：一旦被部署，一个模型生命将开始。为了确保过着有目的的生活，你需要监控在线性能。监控系统一般把指标返回给模型注册服务，并链接告警系统


> 引用
> https://towardsdatascience.com/lessons-on-ml-platforms-from-netflix-doordash-spotify-and-more-f455400115c7
> https://eugeneyan.com/writing/feature-stores/
> https://doordash.engineering/2020/11/19/building-a-gigascale-ml-feature-store-with-redis/
> https://farmi.medium.com/ml-feature-stores-a-casual-tour-fc45a25b446a
> https://farmi.medium.com/ml-feature-stores-a-casual-tour-30a93e16d213
> https://farmi.medium.com/ml-feature-stores-a-casual-tour-3-3-877557792c43
