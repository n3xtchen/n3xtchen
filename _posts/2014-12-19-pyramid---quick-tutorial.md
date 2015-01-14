---
layout: post
title: "Pyramid 快速入门 - (1)单文件应用"
description: ""
category: Python
tags: [python, pyramid, mvc]
---
{% include JB/setup %}


## 前奏：从脚手架快速开始你的项目

> 原文见： [quick_tutorial - scaffolds](http://docs.pylonsproject.org/projects/pyramid/en/latest/quick_tutorial/scaffolds.html)

### 知识背景

这个章节将会涵盖很多内容，一次一个主题，从零开始构建。尽管是暖场，但是我们也会把它做到尽可能的美观。

和其他 Web 开发框架一样， **Pyramid** 提供了很多 *Scaffolds* （脚手架）工具，例如生成可执行的 **Python**，模版（*template*）以及 **CSS** 代码等等。我们开始前，我们将会使用内建的 *scaffold* 生成一个 **Pyramid** 应用。

### 目标

* 使用 **Pyramid** 的 `pcreate` 命令下查看可用的脚手架，以及创建一个新的项目
* 创建一个 **Pyramid** 应用，并在浏览器中访问

### 步骤

1. **Pyramid** 的 `pcreate` 命令可以查看可用的脚手架：
		
		$ pcreate --list
		Available scaffolds:
  			alchemy:  Pyramid SQLAlchemy project using url dispatch
  			starter:  Pyramid starter project
  			zodb:     Pyramid ZODB project using traversal
		
2. 告诉 `pcreate` 使用 `starter` 脚手架来创建我们的应用：
	
		$ pcreate --scaffold starter scaffolds
	 	
3. 指定开发者模式喜下安装你的项目：
	
		$ cd scaffolds
		$ python setup.py develop
	 
4. 通过指定配置文件来启动我们的应用：

		$ pserver development.ini --reload
		Starting subprocess with file monitor
		Starting server in PID 80798.
		serving on http://0.0.0.0:6543

5. 在浏览器中访问 [http://localhost:6543](http://localhost:6543)

### 分析

和从零开始构建不同的是，`pcreate` 使得创建一个 **Pyramid** 应用变得非常简单。**Pyramid** 自带了一些 *scaffold*s；并且还可以通过插件包的形式安装更多的 **Pyramid** 的 *scaffold*s。

`pserver` 是 **Pyramid** 的应用启动器，独立于你的具体业务逻辑代码之外。一旦安装了 **Pyramid**，`pserver` 就已经躺在你的 *bin* 目录下了。这个程序是一个 **Python** 模块。它需要传递一个配置文件给它（本章节中，是 *development.ini*）

## 01: 单文件应用

> 原文见： [quick_tutorial-hello_world](http://docs.pylonsproject.org/projects/pyramid/en/latest/quick_tutorial/hello_world.html)

快速创建 **Pyramid** 应用的最简单方式是什么？单文件模块。没有 **Python** 模块，没有 *setup.py*，没有其他重型代码。

### 知识背景

近年来，微框架已经大行其道了。**Microframework** 只是一个营销术语，而不是技术术语。他们的开销很低：他们做的很少，你只要关心的就是你自己的代码。

可以像单文件模块的微框架那样被使用使得 **Pyramid** 很特别。你可以只编写一个 **Python** 文件，直接执行它。同时，**Pyramid** 也提供了让它拓展成更大应用的解决方案。

**Python** 有一个叫做 **WSGI** 的标准，它定义了 **Python** Web 应用如何与标准的服务器兼容，获取传入的请求和返回响应。大部分现在的 **Python** Web 框架都遵循 **MVC** （模块-视图-控制）的应用模式，模块中的的数据有一个视图与外部系统进行交互。

本章节，我们将短暂一瞥 **WSGI** 服务器应用，请求，响应以及视图（Views）。

### 目标

* 得到一个可以运行的简单 **Pyramid** Web 应用
* 为了后续的可扩展性，使用尽可能易于理解的底层
* 初次接触 WSGI 应用，请求，视图和响应

### 步骤

1. 确认你的环境已经按要求安装完毕

2. 从创建你的工作区开始（*~/projects/pyramid_quick_tutorial*），这一步我们将创建一个目录：
		
		$ mkdir hello_world; cd hello_world
		
3. 把如下代码拷贝到 *hello_world/app.py*：

		1. from wsgiref.simple_server import make_server
		2. from pyramid.config import Configurator
		3. from pyramid.response import Response
		4.
		5.
		6. def hello_world(request):
		7.     print('Incoming request')
		8.     return Response('<body><h1>Hello World!</h1></body>')
		9.
		10.
		11.if __name__ == '__main__':
		12.    config = Configurator()
		13.    config.add_route('hello', '/')
		14.    config.add_view(hello_world, route_name='hello')
		15.    app = config.make_wsgi_app()
		16.    server = make_server('0.0.0.0', 6543, app)
		17.    server.serve_forever()
		
4. 运行应用：

		$ $VENV/bin/python app.py

5. 在浏览器中访问

### 分析

首次使用 **Python** 吗？如果是，那模块中的一些行需要别解释：

1. 第 11 行. `if __name__ == 'main__'`：意思就是 “在命令行执行时，从这里开始”；但该文件作为模块导入的时候，将不会被执行。
2. 第 12-14 行. 使用 **Pyramid** 的配置器将特定的 **URL** 路由到特定的 *view* 代码中。
3. 第 6-8 行. 实现发起响应的 *view* 脚本。
4. 第 15-17 行. 使用 **HTTP** 服务器来启动 **WSGI** 应用。

例子所示，配置器在 **Pyramid** 开发过程中扮演着核心位置。通过应用配置把一个个松散耦合（loosely-coupled） 部分串联成一个应用，这就是 **Pyramid** 的核心思想。我们将在接下来的章节中不断的重温这个思想。

