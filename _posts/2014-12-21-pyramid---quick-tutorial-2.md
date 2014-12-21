---
layout: post
title: "pyramid 快速入门 - (2)使用 Package 开发"
description: ""
category: Python
tags: [python, pyramid]
---
{% include JB/setup %}

## 02. **Python** **Pyramid** 应用包

> 原文见 [quick_tutorial-package](http://docs.pylonsproject.org/projects/pyramid/en/latest/quick_tutorial/package.html)

大部分现代的 **Python** 项目都使用 **Python** 包（**package**）作为开发工具，**Pyramid** 也能很好的利用这一工具。这个章节，我们将构建一个迷你的 **Python** 包来实现上一个章节的 *Hello World* 应用。

### 知识背景

**Python** 开发者可以将模块和文件集合打包到一个命名空间单元中（我们称之为 **Package**）。如果一个目录存在于 `sys.path` 中，并且其中包含一个名叫 *__init__.py* 的特殊文件，那这个目录就会被当作一个 **Python** 包（**Package**，后续都用这个名称来指代包）。

我们可以把自己的应用封装成供后续安装的 **Package**，通过一种工具链（**toolchain**，**Python** 使用的通用工具叫做 **setuptools**，，虽然相对较为混乱，但是已经在不断的完善中。 ）来安装，前提是你需要编写一个 *setup.py* 文件来控制安装流程。为了不让你抓狂，整个章节将会为围绕这个主题进行讲解。接下来的教程，你将学到：

* 我们将为后续的每一个步骤创建一个文件夹作为 **setuptool** 项目
* 这个项目将会包含一个 `setup.py`，它将把 **setuptool** 的工程特性到目录中
* 这个项目中，我们将会使用 *__init__.py* 把教程的子目录封装成 **Package**
* 我们可以使用 `python setup.py develop` 在开发模式下安装我们的项目

接下来：

* 你将在 **Package** 中进行开发
* 这个包将会是 **setuptool** 项目的一部分

### 目标

* 创建一个带 *__init__.py* 的 **Python** 包目录
* 编写 *setup.py* 生成一个最小的 **Python** 项目
* 开发者模式下安装我们的教程目录

### 步骤

1. 为这个章节，腾个空间，创建一个目录：

		$ cd ..; mkdir package; cd package
	 
2. 创建 *package/setup.py* 文件，并输入如下内容：

		from setuptools import setup
		
		requires = [
		    'pyramid',
		]
		
		setup(name='tutorial',
		      install_requires=requires,
		)
		
3. 安装新的项目开始进行开发，然后创建一个目录用来保存实际代码：
	
		$ $VENV/bin/python setup.py develop
		$ mkdir tutorial

4. 在 *package/tutorial/__init__.py* 中输入如下：
		
		# package
		
5. 在 *package/tutorial/app.py* 中输入如下：
		
		from wsgiref.simple_server import make_server
		from pyramid.config import Configurator
		from pyramid.response import Response
		
		
		def hello_world(request):
		    print ('Incoming request')
		    return Response('<body><h1>Hello World!</h1></body>')
		
		
		if __name__ == '__main__':
		    config = Configurator()
		    config.add_route('hello', '/')
		    config.add_view(hello_world, route_name='hello')
		    app = config.make_wsgi_app()
		    server = make_server('0.0.0.0', 6543, app)
		    server.serve_forever()
		    
6. 运行 **WSGI** 应用：
		
		$ $VENV/bin/python tutorial/app.py
		
7. 打开浏览器访问你的应用

### 分析

**Python** **Package** 为我们提供了一个良好可组织的开发环境单元。通过 *setup.py* 安装的 **Python** 项目为我们提供了一个 **setuptool** 的特性（这个 case 中，我们使用本地开发模式的特性）。

在这个章节中，我们得到一个名为 *tutorial* 的 **Python** 包。在接下来的章节中，我们都将使用这个名称，避免不必要的重复输入。

在 *tutorial* 上，我们还需要一个文件来负责项目的封装和打包。这里，我们所需要的就是 *setup.py* 。

其他东西都和我们这个应用中一样。我们只是简单地使用一个 *setup.py* 来制作一个 **Python ** **Package**，并使用开发者模式安装它。

注意：我们运行应用的方式有点儿冠以。除非我们是在写教程，尝试了解程序执行的每一个步骤，否则我们不会这么做。直接在一个 **Package** 中运行它的模块不是一个好主意。
