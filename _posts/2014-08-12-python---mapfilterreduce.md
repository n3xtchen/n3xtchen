---
layout: post
title: "使用 python - 实现 Map，Filter 以及 Reduce"
description: ""
category: Python
tags: [Python]
---
{% include JB/setup %}

心血来潮，当我在构思**不定参数**文档的时候，想到了用 Map 作为例子，萌生我实现 MapReduce 机制的想法!

如果我不使用循环语句，我还能用什么？

毫无疑问，使用 **递归**！

### 实现 MAP


	def myMap(f, *args):
    	""" 实现 map 函数  """

    	def getEachArgs(f1, args):
        	""" 获取每一个参数表  """
        	if args==[]:
            	return []
        	else:
            	return [f1(args[0])] + getEachArgs(f1, args[1:])

    	if list(args)[0]==[]:
        	return []
    	else:
        	return [f(*(getEachArgs(lambda x: x[0], list(args))))] \
            	+ myMap(f, *(getEachArgs(lambda x: x[1:], list(args))))
            	
    >>> print myMap(lambda *args: (args), [1, 2], [3, 4])
    [(1, 3), (2, 4)]
    
本来想用尾递归来实现，不过遇到点问题，稍后调试好了，把代码贴出来

### 实现 FILTER

	def myFilter(func, seq):
		""" 实现 filter 函数  """
    	if seq == []:
        	return []
    	else:
        	return [seq[0]] if func(seq[0]) else [] + \
        		myFilter(func, seq[1:])

	>>> print myFilter(lambda x: x>=5, [1, 5, 10])
	[5, 10]
	
### 实现 REDUCE

这里使用尾递归的方式实现：

	def myReduce(func,seq,initial=0):
		""" 实现 reduce 函数  """
    	if(len(seq)==0):
        	return initial
    	return myReduce(func,seq[1:], func(initial, seq[0]))

	>>> print myReduce(lambda x,y: x+y, [1, 2, 4, 1])
	8
	
### 如果你使用 For 循环来实现，那代码将会变成什么样的呢？