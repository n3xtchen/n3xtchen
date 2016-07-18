---
layout: post
title: "py.test - 常见的命令"
description: ""
category: Python
tags: [test]
---
{% include JB/setup %}

发现每次使用 **py.test** 的时候，总是记不住它的命令，每次都得查一遍文档，所以写这篇博客备忘下。

### 指定测试范围

	py.test test_mod.py   # 运行这个文件下的所有测试
	py.test somepath      # 运行这个路径下的所有测试文件
	py.test -k stringexpr # 只测试与 stringexpr 匹配的测试
	py.test test_mod.py::test_func  # 测试指定测试文件下的测试函数
	py.test test_mod.py::TestClass::test_method  # 测试指定测试文件下的指定测试类的测试方法
	py.test --pyargs pkg	＃ 测试 pkg 文件夹下所有的测试
	
#### `py.test -k` 详解

	py.test -k "method_a or method_b"	
	
测试类或函数包含 `method_a` 或 `method_b` 中的测试将被运行

	py.test -k "SomeClass and no method_a"
	
测试类名包含 `SomeClass`，并且该测试类中包含 `method_a` 将被跳过 

### 获取程序输出

	py.test -s	# = capature=no，将不捕获输出，直接打印
