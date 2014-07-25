---
layout: post
title: "Python 测试驱动开发 - TDD初阶"
description: ""
category: python
tags: [python, doctest, unittest2, nose, coverage]
---
{% include JB/setup %}

老是把 TDD 挂在嘴边，周边的人也不为之所动，终于下决心整理下文档，也顺便重温下学过的知识。

我们将会提到两种 Python 的测试方式：doctest 和 unittest，还涵盖了测试覆盖率评定的库 nose 和 coverage

### 准备你的要使用的工具

前提是你的环境至少 Python 2.7 以上，这里假定你已经安装了 pip (如果你没有的话，可以参照 [pip](http://pip.readthedocs.org/en/latest/installing.html#install-pip) 自行安装)；

doctest 是一个 Python 原生自带的标准模块，因此不需要安装；

安装 Unittest2:

	$ pip install unittest2
	
安装 nose 和 coverage

	$ pip install nose
	$ pip install coverage
	
### 先从简单的 Doctest 开始

Doctest 是 Python 中最简单的测试工具；他们主要有三个好处：

1. 帮助注释如何使用该方法或函数
2. 如果你变更你的接口，它将提醒你更新你的 docstring
3. 进行简单的测试的同时也不会打断你工作

值得一提的是， doctest 并不打算成为一个完整功能的单元测试框架。他们的哲学就是为每一个公共的方法使用一两个例子注释说明，然后 move on；但是需要提醒的是不要使用完整的测试来污染你的文档，而且 doctest 也会很慢。

先来看一个简单的例子：

	# filename: module_demo.py
	def add(arg):
    	""" 
    	Perform an int type-conversion on arg and add 4

    	Example
    	-------

    	>>> add('12')
    	16
    	"""
    	return int(arg)+4
 
	if __name__=='__main__':
    	import doctest
    	doctest.testmod()

通过在底部包含 `doctest.testmod()` ，简单的运行它：
	
	$ python module_demo.py
	$
	
No news is good news;(没有新闻就是最好的新闻)，如果 doctest 通过测试，你将看不到任何信息。

让我们改下返回值来演示下 doctest 测试失败的输出（将 16 改称 14），执行的结构如下：

	$ python module_demo.py 
	**********************************************************************
	File "module_demo.py", line 21, in __main__.add
	Failed example:
    	add('12')
	Expected:
    	16
	Got:
    	14
	**********************************************************************
	1 items had failures:
   	1 of   1 in __main__.add
	***Test Failed*** 1 failures.

让我们还原成通过测试的值，然后接下来学习 uinttest

### 使用 unittest2

unittest 会执行名称包含 `test` 的类／方法，整体上必须符合下面两个标准：

* 类必须继承 unittest.TestCase；
* 类和方法必须在它的名称上包含 `test` 字样；

使用 unittest2 的规则：

* 每个测试用例的测试应该重点放在少数代码中，避免测试太多代码，因为一个用例很难覆盖一个复杂的类
* 每个测试之间必须是相互独立（因为 set-up/tear-down 在执行每一个用例都会被触发）
* 失败不能阻塞不相关测试的运行

需要测试的项目

* 类／方法的输入
	* 标准值
	* 极值测试（Cornor Case）
	* 上面情形的组合
* 负面测试（Nagative Tests）
	* 错误的类型
	* 错别字（Typos）／操作失误（fat-fingers）／大脑短路（brain-fart）的条件
	* 预期的错误条件
* 日志
* API 的一致性
	* 迭代测试某类的子类，确保预期的方法可访问

#### 一个简单的 unitest2 的例子

第一个例子，我们将抛出几个测试用例

	#! /usr/bin/env python
	# -*- coding: utf-8 -*-
	# filename: test_demo.py

	# 载入 unittest 库
	try:
 	   import unittest2 as unittest
	except ImportError:
	    import unittest

	# 导入要测试的目标代码
	import module_demo
	add = module_demo.add

	# 名称必须包含 test, 必须继承 unittest.TestCase
	class test_Add_Args(unittest.TestCase):
    	""" 
    	test arguments sent to add()
    	"""

    	def test_inputs(self):
        	self.assertEqual(add(12), 16) 
        	self.assertEqual(add(12.0), 16) 
        	self.assertEqual(add('12.0'), 16) 
        	self.assertEqual(add('-12.0'), -8) 
        	self.assertEqual(add(-12.0), -8) 

	if __name__ == '__main__':
    	unittest.main()

当你执行它的时候，程序将会报错

	$ python test_demo.py 
	E
	======================================================================
	ERROR: test_inputs (__main__.test_Add_Args)
	----------------------------------------------------------------------
	Traceback (most recent call last):
  	File "test_demo.py", line 24, in test_inputs
    	self.assertEqual(add('12.0'), 16)
  	File "/Users/ichexw/Dev/python/TDD/module_demo.py", line 24, in add
    	return int(arg)+4
	ValueError: invalid literal for int() with base 10: '12.0'

	----------------------------------------------------------------------
	Ran 1 test in 0.001s

	FAILED (errors=1)

我们刚捕获了我们的第一个 bug；我不能预料到 `int('12.0')` 的问题，因此我们需要修改 `add()` 为 `return int(float(arg))+4。修改后，我们再次执行它：

	$ python test_demo.py
	.
	----------------------------------------------------------------------
	Ran 1 test in 0.000s

	OK
	
### 整合 Doctest 和 Unittest2

假设你想要让 doctest 和 unittest2 一块执行：

* 我们仍然继续执行 simple_test.py 模块的方法
* 同时还需要测试在定义在 module_demo.py 中的 doctest
* 我们把下面的代码整合到 test_demo.py (即放在执行 unittests 的代码中)：

代码如下：

	#! /usr/bin/env python
	# -*- coding: utf-8 -*-
	# filename: test_demo.py

	# 载入 unittest 库
	try:
 	   import unittest2 as unittest
	except ImportError:
	    import unittest

	# 导入要测试的目标代码
	import module_demo
	import doctest

	def load_tests(loader, tests, ignore):
    	"""Run doctests from this.py"""
    	tests.addTests(doctest.DocTestSuite(module_demo))
    	return tests
	
	add = module_demo.add

	# 名称必须包含 test, 必须继承 unittest.TestCase
	class test_Add_Args(unittest.TestCase):
    	""" 
    	test arguments sent to add()
    	"""

    	def test_inputs(self):
        	self.assertEqual(add(12), 16) 
        	self.assertEqual(add(12.0), 16) 
        	self.assertEqual(add('12.0'), 16) 
        	self.assertEqual(add('-12.0'), -8) 
        	self.assertEqual(add(-12.0), -8) 

	if __name__ == '__main__':
    	unittest.main()

现在，我们的 doctests 和 unittests 将整合在一块运行。

### 查看代码覆盖率

如果你使用 nose 插件，那 coverage 可以为你代码的覆盖率测试生成一些漂亮的报告。

	$ coverage erase
	$ nosetests --with-coverage module_test
	.
	Name          Stmts   Miss  Cover   Missing
	-------------------------------------------
	module_demo       6      2    67%   26-27
	----------------------------------------------------------------------
	Ran 1 test in 0.017s

	OK
	
67% 的覆盖率太低了，所以我们需要修复它。通过分析代码，我们发现 coverage 把我们的 doctest 运行器当成 module_demo 的一部分。幸运的是，coverage 提供了一种方式来解决这类问题。我们只需要 if 语句后面添加 `# pragma: no cover`:

	if __name__=='__main__': # pragma: no cover
		import doctest
		doctest.testmod()
		
然后我们再次运行测试，100％ 的覆盖率 ^_^：

	$ nosetests --with-coverage module_demo

	Name          Stmts   Miss  Cover   Missing
	-------------------------------------------
	module_demo       3      0   100%   
	----------------------------------------------------------------------
	Ran 0 tests in 0.000s

	OK

### 结语

单元测试的工具越来越多，让测试驱动开发（TDD）变得更加的简便！但是由于大部分开发人员对测试不是很重要，甚至被作为额外无用的工作量！在长期的迭代开发过程中，有效的单元测试帮助我们的团队规避很多风险，把更安全地使用和修改过去写过的库或代码！所以思维的转变非常重要，在今后，我会分享更多的测试驱动开发的内容，希望对大家能有所帮助。


> 引用 http://bucksnort.pennington.net/blog/post/python-unittest2-doctest/，
