---
layout: post
title: "数据挖掘-探讨工程项目结构"
description: ""
category:  data_analytics
tags: [spark, python, scala, java]
---
{% include JB/setup %}

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