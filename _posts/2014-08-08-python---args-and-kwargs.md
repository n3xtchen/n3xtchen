---
layout: post
title: "Python 优雅的使用参数 - 可变参数（*args & **kwargs)"
description: ""
category: Python
tags: [Python]
---
{% include JB/setup %}

### 写在前面的话

传递参数的行为对于现在编程语言来说，再寻常不过的概念

> 参数（英语：parameter）是使用通用变量来建立函数和变量之间关系（当这种关系很难用方程来阐述时）的一个数量。 - 来自 wikipedia

<!--	
这是最简单的传参行为了，一个函数可以定义任意个参数，每个参数间用逗号分割，用这种方式定义的函数在调用的的时候也必须在函数名后的小括号里提供个数相等的值（实际参数），而且顺序必须相同，也就是说在这种调用方式中，形参和实参的个数必须一致，而且必须一一对应，也就是说第一个形参对应这第一个实参。

简而言之，就是这样的参数定义，要求在函数调用的时候，实际的参数的个数和顺序都要求和函数的参数定义保持一致，否则会报错
	
	>>> func(1)
	TypeError: func() takes exactly 2 arguments (1 given)
	
在某些场景中，你需要对某些参数设定默认值，这时你可以这么做：

	def func(a, b=1):
		print a+b
		
	>>> func(1)
	2
	
	>>> func(1, 2)
	3
	
到目前为止，上述的两种参数定义方式几乎满足大部分的需求，接下我就是我今天向大家介绍的黑魔法 - **不定参数的使用**。

-->

先来看一个例子：

	# 来源于 https://docs.python.org/2/library/itertools.html
	def chain(*iterables):
    	for it in iterables:
        	for element in it:
            	yield element
            	 
大家可能注意到 `*iterables` 了，对了，就是他， **不定参数**。

	>>> from itertool import chain
	>>> chan([1,2], [2, 3])				# 你可以这么用
	[1, 2, 2, 3]
	>>> chan([1,2], [2, 3], [4, 5])		# 你还可以这么用
	[1, 2, 2, 3, 4, 5]
	>>> chan([1,2], [2, 3], [4, 5])		# 你也可以这么用
	[1, 2, 2, 3, 4, 5]
	...	// 随心所欲的加参数
	
很神奇把，(^_^)v，来讲讲枯燥的概念把！

可能很多人用了几年的 Python 都没真正使用过可变参数，就比如我，为了学写通用模块，就会对它有需求；或许你经常看 Python 模块库代码，会发现很多函数的参数定义，都会跟上 `*args` 和 `**kwargs`（不定参数的另一种形式，后面会讲到）。

> 在计算机程序设计，一个可变参数函数是指一个函数拥有不定引数，即是它接受一个可变量目的参数。 - 来自 wikipedia

通俗的说就是，函数可以处理不同数量的参数。

在我看来，几乎80%的使用可变参数列表的场景，都可以使用数组和字典来解决。但是使用可变参数列表的函数可以提供一种数组和字典无法提供的东西：**优雅**。

### *args

	def argsFunc(a, *args):
		print a
		print args
		
	>>> argsFunc(1, 2, 3, 4)
	1
	(2, 3, 4)

`argsFunc` 中匹配完定义好的参数，**剩余的参数以元组的形式存储在 args**（args 名称你可以自行定义），因此在上述程序中只要你传入不小于 1 个参数，该函数都会接受，当然你也可以直接定义只接受可变参数，你就可以自由传递你的参数:

	def argsFunc(*my_args):
		print my_args
		
	>>> argsFunc(1, 2, 3, 4)
	(1, 2, 3, 4)
	>>> argsFunc()
	()

很简单把，现在来将另一个种不定参数形式
	
### **kwargs

形参名前加两个*表示，参数在函数内部将被存放在以形式名为标识符的 `dictionary` 中，这时调用函数的方法则需要采用 `arg1=value1,arg2=value2` 这样的形式。

为了区分，我把 **\*args** 称作为数组参数，**\**kwargs** 称作为字典参数

	>>> def a(**x):print x
	>>> a(x=1,y=2,z=3)
	{'y': 2, 'x': 1, 'z': 3} #存放在字典中
	
不过，有个需要注意，采用 **kwargs 传递参数的时候，你不能传递数组参数

	>>> a(1,2,3) #这种调用则报错
	Traceback (most recent call last):
  		File "<stdin>", line 1, in <module>
	TypeError: a() takes exactly 0 arguments (3 given)
	
同样很简单，但是我们什么时候可以用到他呢？

	import mysql.connector  
	
	db_conf = {
		user='xx',
		password='yy', 
		host='xxx.xxx.xxx.xxx',
		database='zz'
	}
	
	cnx = mysql.connector.connect(
		user=db_conf['user'],
		password=db_conf['password'], 
		host=db_conf['host'],
		database=db_conf['database']
		)
	...
		
相比，使用 Mysql Python 库时候，经常看到这个样子的代码，`db_conf` 一般都从配置文件读取，这是优雅的不定字典参数就派上用途了！

	import mysql.connector  
	
	db_conf = {
		user='xx',
		password='yy', 
		host='xxx.xxx.xxx.xxx',
		database='zz'
	}
	
	cnx = mysql.connector.connect(**db_conf)
	...
	
怎样，是不是顺眼多了，代码也省了不少！^_^

今天就到这里了，很早就开始写这一篇了，不想像网路上的大部分博客，只是写一个使用文档类型的教程，看完就忘了。

适当的考虑应用场景，希望能印象深刻。学会，就尽可能的使用它；再优雅的概念，不用也是百搭。

### The End

> 参考
> 	* [Python中函数的参数定义和可变参数](http://blog.csdn.net/feisan/article/details/1729905)
> 	* [Python函数中定义参数的四种方式](http://blog.linuxeye.com/329.html)
> 	* [wiki - 参数](http://zh.wikipedia.org/wiki/%E5%8F%82%E6%95%B0)
> 	* [【C/C++ 语法备忘】4、可变参数列表](http://blog.csdn.net/ronintao/article/details/10070485)
