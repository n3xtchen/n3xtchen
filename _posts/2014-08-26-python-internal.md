---
layout: post
title: "如何探索 Python？"
description: ""
category: Python
tags: [Python]
---
{% include JB/setup %}

当我们学习很多东西的时候，大家都很想了解它的底层具体发生的事情。比如，“真的“ 和 ”为什么” 这些词经常会存在对话中 —— “当我运行一个列表，实际发生了什么？”，“为什么函数调用需要考虑成本？”。如果看完下面的部分，你就知道我有多喜欢挖掘 Python 的底层，并且我永远喜欢和别人分享这些。

## 为什么要深挖底层？

首先，不要以为了解 Python 的底层，就可以成为好的 Python 开发。很多你学习的东西并不能帮护你编写更好的代码。底层结构非常的特别，也很似是而非 —— 为什么只在 Python 底层止步呢？你能知道一些 C，会更完美，如 C 编译器，汇编语言，……

换句话说，我认为你应该更加了解 Python —— 她有时会帮助你写出更好的 Python，如果你想贡献代码，这也会为你打好基础；更重要的是，她真的很有趣。

## 安装

首选你得先有一个 Python，会看这篇文章的人，应该都有环境了。

##  策略

### 1. 自然主义
Peter Seibel 有一个很好的关于[读代码的博客](http://www.gigamonkeys.com/code-reading/)。他认为“读”并不是与代码最好的交互方式 —— 相反，他们解剖他。

### 2. 科学

我是假说学的大粉丝 —— 调试驱动，这个思想也可以用于探索 Python。我觉得你不应该坐下来随便读几段代码。相反，你要带着问题和假设进入代码库。没意见事情你都需要抱着怀疑的态度，猜测它如何实现，最后验证或者驳斥你的假设。

### 3. 向导式的探索

按照一步一步的指导，以不断的调试和理解代码。推荐大家看一下 [Amy Hanlon 的博客](http://mathamy.com/import-accio-bootstrapping-python-grammar.html)（其中讲到如何修改 Python 内置函数的语句）和 [Eli Bendersky 的博客](http://eli.thegreenplace.net/2010/06/30/python-internals-adding-a-new-statement-to-python/)（其中讲到如何添加自己的方法在 Python 内置函数中）；这样我们可以轻易地追踪代码，了解代码具体实现和运行轨迹。（接下来也会翻译这两篇文章）

### 4. 推荐你最喜欢的模块实现

如果你读到觉得实现很棒的模块，你应该毫不客气地推荐给大家。如果你已经有自己觉得很棒的实现，你可以 @我（[@n3xtm3](http://weibo.com/loocyrev/)）。下面 akaptur 推荐的两个模块：

1. timeit in Lib/timeit.py
2. namedtuple in Lib/collections.py

### 5. 写博客和演讲

你学到那些有趣的东西了吗？把它写下来并分享它，或者在本地社区交流会中演讲它！你可能感觉到其他人已经知道你所知道的一切，没什么好分享的，但是相信我，这不是真的，你所分享总会帮助到别人的，总有人不懂的。

### 6. 重构

当你阅读代码实现之前，你可以尝试按自己理解先实现一个。这样可以加深你的印象。

## 工具

### 1. Ack

我之前使用 `grep` 搜索 CPython 代码库，但是它真的非常慢。后来我使用 ack 后就喜欢上它了。

如果你是 Mac 用户，使用  Homebrew，你可以用 `brew install ack` 安装它；你只需要简单地 `ack 你想要查找地字段`，Ack 会输出非常棒地结果。 

### 2. timeit

运行时间和效率问题是使用上文提到 “科学“ 策略最好地方。你可能会有疑问 “X 和 Y，哪一个更快？”例如，想要证明两个赋值语句（一个两个赋值语句和一个元组赋值方式）哪一个快？我首先猜测元组赋值（tuple-unpacking）是更慢，因为多了一个解包地步骤。让我们来验证它。

	n3xtchen$ python -m timeit "x = 1; y = 2"
	10000000 loops, best of 3: 0.0323 usec per loop
	n3xtchen$ python -m timeit "x, y = 1, 2"
	10000000 loops, best of 3: 0.036 usec per loop

猜对了。

身边地很多人都喜欢使用 IPython。Ipython 可以使用 pip 安装，而且它安装非常简单。在 IPython REPL 模式中，你可以使用 `%timeit`  来计时。关于时间还有一个问题 —— 上述例子只是为了加深你的理解，除非你真的有性能问题。

	In [1]: %timeit x = 1; y = 2;
	10000000 loops, best of 3: 33.3 ns per loop

	In [2]: %timeit x, y = 1, 2
	10000000 loops, best of 3: 38.9 ns per loop

### 3. 解剖

Python 编译成字节码，用于 Python 虚拟机的代码中间表现。你使用 `dis` 模块，有时可以很清晰看到它的执行，非常的有趣的。

	In [1]: def one():
   	...:     x = 1
   	...:     y = 2
   	...:     
	
	In [2]: def two():
   	...:     x, y = 1, 2
   	...:     
	
	In [3]: import dis
	
	In [4]: dis.dis(one)
  	2			0 LOAD_CONST              1 (1)
              	3 STORE_FAST              0 (x)

  	3          6 LOAD_CONST               2 (2)
               9 STORE_FAST               1 (y)
              12 LOAD_CONST               0 (None)
              15 RETURN_VALUE        

	In [5]: dis.dis(two)
  	2          0 LOAD_CONST               3 ((1, 2))
               3 UNPACK_SEQUENCE          2
               6 STORE_FAST               0 (x)
               9 STORE_FAST               1 (y)
              12 LOAD_CONST               0 (None)
              15 RETURN_VALUE 
              
变量的实现在 `Python/ceval.c`，你可以去看下。

### 4. Inspect/cinspect

你应该有经常使用 `inspect`，来查看任何你好奇的源代码实现：

	In [11]: import inspect

	In [12]: import collections

	In [13]: print inspect.getsource(collections.namedtuple)
	def namedtuple(typename, field_names, verbose=False, rename=False):
    	"""Returns a new subclass of tuple with named fields.
		...
		
然而，`inspect` 只能查看使用 Python 编写的源代码，有时可能会很迷惑：

	In [14]: print inspect.getsource(collections.defaultdict)
	---------------------------------------------------------------------------
	IOError                                   Traceback (most recent call last)
	<ipython-input-14-71c51c86f80e> in <module>()
	...

为了解决这个问题， Puneeth Chaganti 编写一个 `cinspect` 来拓展 `inspect`，可以用来查看 C 实现的部分。

## 开始你的探索 PYTHON 世界的征程把

CPython 是非常巨大的代码库，你想要为它建立一个心智模型需要花费很长的时间。现在下载源码，到处看看，如果对某一个东西感兴趣，可以花上 5 到 10 分钟探索它。日积月累，你就会变得更快，更严谨，处理流程更简单。

如果你有更好的探索 Python 的测试，请让我知道！


> 参考
>
>	* [Getting Started With Python Internals](http://akaptur.github.io/blog/2014/08/03/getting-started-with-python-internals/)


















