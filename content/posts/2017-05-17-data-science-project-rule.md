---
categories:
- data_analytics
date: "2017-05-17T00:00:00Z"
description: ""
tags:
- spark
- python
- scala
- java
title: 数据挖掘-探讨工程项目结构
---

### 目录结构

	├── LICENSE
	├── Makefile           <- 流程工具
	├── README.md          <- 开发者使用的顶级文档
	│
	├── data
	│   ├── external       <- 来自第三方的数据
	│   ├── interim        <- 被转化过的中间结果
	│   ├── processed      <- 最后用于模型的数据集
	│   └── raw            <- 原始不可变的数据输出
	│
	├── docs               <- 默认是 Sphinx 项目
	│
	├── models             <- 训练和序列化模型，模型预测或者模型总结
	│
	├── notebooks          <- Jupyter notebooks.
	│                         命名规则：数字，创建者首字母和描述，并以 `-` 隔开
	│                         e.g. `1.0-cw-initial-data-exploration`.
	│
	├── references         <- 数据字典，手册以及所有其他探索资料
	│
	├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
	│   └── figures        <- 存放用于报表的图表文件
	│
	├── requirements.txt   <- 依赖包文件
	├── src                <- 存储源码的目录
	│   ├── __init__.py    <- 使 src 编程一个 python 模块
	│   ├── data           <- 下载或生成数据的脚本
	│   │   └── make_dataset.py
	│   │
	│   ├── features       <- 将原始数据转化成模型特征的脚本
	│   │   └── build_features.py
	│   │
	│   ├── models         <- 训练模型的脚本
	│   │   ├── predict_model.py
	│   │   └── train_model.py
	│   │
	│   └── visualization  <- 创建探索的结果可视化脚本
	│       └── visualize.py
	│
	└── tox.ini            <- 用于运行 tox 的配置文件
	
	
### 数据是不可变的

不要编辑你的原始数据，不要手动，更不要存在 excel 中。不要覆盖原始数据。不要保存多个版本的原始数据。保持原始数据不可变。你写的代码应该通过管道把原始数据导向最终分析。你不用每次为了一些图标而运行所有步骤，当时任何人都可以只通过 `src` 和 *data/raw* 中的数据，重新生成最后的产品。

然而，如果数据不可变，它同样不需要保存在版本控制中。因此，默认，数据目录应该包含一个 `.gitignore` 文件。如果你的数据量小，而且很少变化，你也许可以把它放到版本控制了。如果一个文件超过 50M，github 会警告，拒绝超过 100M 的文件提交。还有其他保存／同步数据的选择，例如 AWS S3（s3cmd）,GLFS,Git Annex 和 dat。目前，我们使用 S3 bucket 和 使用 aws cli 来从服务器同步数据。

> 引用自 [Cookiecutter Data Science](https://drivendata.github.io/cookiecutter-data-science/)