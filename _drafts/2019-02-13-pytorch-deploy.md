---
layout: post
title:  "Pytorch 生产部署"
date:   2019-02-13 13:15:10 +0800
category: "deep_learning"
tags: ["pytorch"]
---

在我们训练完我们的分类器之后，我们就可以进行推断。我们可以在本地或者云上完成这个，也有很多选择（AWS，Paperspace，Google Cloud 等等）。接下来，我们将在本地完成部署（不涉及 GPU 训练）。

## 环境介绍

- Ubuntu 18.04.2 LTS
- conda3 4.6.3

## 创建环境，安装依赖

	ichexw at n3xtchen-Studio -> conda create --name dl-torch python=3.7
	(dl-torch) ichexw at n3xtchen-Studio -> conda install -c pytorch pytorch-cpu torchvision-cpu
	(dl-torch) ichexw at n3xtchen-Studio -> conda install -c fastai fastai
    (dl-torch) ichexw at n3xtchen-Studio -> conda install -c anaconda flask
    
## 创建一个 Flask 应用

先看看目录结构：

	pytorch-app
	├── server # 载入模型和运行模型服务
	└── settings.py# 配置文件，便于后续灵活配置
	
	0 directories, 2 files
    
下面是 *pytorch-app/settings.py* 的演示例子。后面将在 server.py 导入该配置：

	# 设置数据存放目录
	data_dir = 'data'​
	# 模型链接
	MODEL_URL = 'https://my-server/path/to/model.pth' # example weights​
	# Flask 对外暴露的端口
	PORT = 8080
    
接下来就是 *pytorch-app/server.py*，首先导入配置和设置：


    # flask_app/server.py

    import logging
	logging.basicConfig(level=logging.INFO, format="%(asctime)s - $(name)s - $(levelname)s - $(message)s")
    logger = logging.getLogger(__name__)
    
	# import libraries
    logger.info('导入库。。。')
    from flask import Flask, request, jsonify
	import logging
	import random
	import time
	​
	from PIL import Image
	import requests, os
	from io import BytesIO
	​
	# import fastai stuff
	from fastai import *
	from fastai.vision import *
	import fastai
	​
	# import settings
	from settings import * # import 
	​
	logger.info('done!')






    
    logger.info('setting up the directories and the model structure...')
