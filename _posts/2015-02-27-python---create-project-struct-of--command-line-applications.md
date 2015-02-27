---
layout: post
title: "Python 命令行应用 - 创建项目结构"
description: ""
category: Python 
tags: [command-line]
---
{% include JB/setup %}

我喜欢使用 **Python** 创建命令行应用，它写起来比 **Bash** 脚本更有逻辑直观。

**Python** 有很多库提供给你解析命令行参数和运行其它 **Shell** 命令，同时你还能充分利用强大的面向对象语言的优势；你还可以使用 **Python** 的单元测试来帮助你检验和注释你的应用。

你可以在 [github](https://github.com/mrako/python-example-project) 找到这个教程的 demo。

## 结构化你的应用

从我的经验来看，Python最好的目录结构就是将可执行脚本放到 *bin* 目录中，你的项目放到项目名目录下。这样，你可以分离你的核心功能，保持可复用性。这也是其它类型应用的创建标准规则。

在 *project* 目录下，你应该使用 *main.py* 作为应用的主要访问入口。你的通用函数应该放到 *lib* 目录下，测试脚本放在 *tests* 目录下。结构如下：

	├── README.md
	├── bin
	│   ├── project
	│   └── project.bat
	└── project
	    ├── lib
	    ├── main.py
	    └── tests

你的应用可以这样执行：

	$ bin/project <parameters>
	
## 分离参数，shell 命令和功能函数

和所有面相对象编程一样，你应该遵循 [关注点分离（SoC）原则](http://zh.wikipedia.org/wiki/%E5%85%B3%E6%B3%A8%E7%82%B9%E5%88%86%E7%A6%BB)。由于用 **Python** 读取命令行参数，处理选项和执行其他 **Shell** 命令是在它方便了，导致时常忽略了这个原则。

### 解析命令行参数

创建一个定义和收集命令行参数的类。**Python** 提供了 [argparse](https://docs.python.org/2/library/argparse.html#module-argparse)(原教程使用的旧库 optparse，目前已经被 **Python 2.7** 弃用)，这样你可以非常容易定义配置和行为(介绍 `ArgumentParser` 的基础用法)：

    from argparse import ArgumentParser

    usage = 'bin/project'
    self.parser = ArgumentParser(usage=usage)
    self.parser.add_argument('-x',
        '--example',
        default='example-value',
        dest='example',
        help='An example option')

现在你已经创建了一个解释器，它通过执行 `bin/project -x <target value>` 或者 `bin/project --example <target value>`，读取目标值到 `example` 变量中。

### 执行其他 Shell 命令

如果你需要创建一个依赖于其他 **Shell** 命令的应用的时候，你应该从它的类中把命令抽离出来。这样，你的核心功能可以在不同环境下被复用，你也更容易收集外部代码产生的日志，错误和异常。我推荐你使用 **Python** 的 `subprocess` 来执行外部命令。

创建一个类用来处理进程执行和异常（见 [process-class](https://github.com/mrako/python-example-project/blob/master/project/lib/process.py)）。

### 核心功能

在 *project/lib/project.py* 中，你可以实现核心功能。由于这是个例子，我只包含接受参数，并通过 `Process-class` 执行 `date` 命令（见 [porject.py](https://github.com/mrako/python-example-project/blob/master/project/lib/project.py)）。

### 运行

从 *bin/project* 可执行文件中调用你项目的 *maim.py*

	#!/bin/bash
	
	BINPATH=`dirname $0`
	python "$BINPATH/../project/main.py" $@

不要忘了为它设置可执行权限：

	$ chmod 755 bin/project
	
在 *main.py* 中收集命令行参数值和运行你的应用。

	import sys
	
	from lib import Project
	from lib import Options
	
	if __name__ == '__main__':
	    options = Options()
	    opts, args = options.parse(sys.argv[1:])
	    v = Project(opts)
	
	    print v.date()
	    
你现在可以执行你的应用了：

	$ bin/project <arguments>
	
## 测试

介于文章的主题，这里我不再强调测试的重要性。简单扼要的说，单元测试可以引导你的开发，验证功能，执行应用的行为。

把测试添加到 *project/tests* 目录中。我推荐使用 `nose` 来运行你的测试。

### 测试命令行参数

	import unittest
	
	from lib import Options
	
	class TestCommandLineArguments(unittest.TestCase):
	    def setUp(self):
	        self.options = Options()
	
	    def test_defaults_options_are_set(self):
	        opts, args = self.options.parse()
	        self.assertEquals(opts.example, 'example-value')

### 运行测试

	$ nosetests
	.....
	Ran 5 tests in 0.054s
	
	OK

> 引用自 https://coderwall.com/p/lt2kew/python-creating-your-project-structure
