---
layout: post
title: "函数式编程 && Python - 第一部分"
description: ""
category: Python
tags: [python, Funcitonal Programming]
---
{% include JB/setup %}

### 关于函数式

* Imperative Programming 指令式编程（C/C++，Java）
* Declarative Programming 声明式编程）
	* **Functional programming** 函数式编程（Haskel， Scheme，OCaml）
	* Logic programming 逻辑编程（Prolog，Clojure.core.logic）
	
* IP = 通过执行改变程序状态的语句进行计算
* FP = 使用数学函数计算求值，避免状态和改变数据

#### FP 的特性：

* Avoid State 避免状态
* Immutable data 不可变的数据
* First Class Functon：函数是第一类型
* High Ordered Function 高阶函数
* Pure Function 纯函数
* Recursion，Tail Recursion 递归，尾递归
* 惰性求值
* Partial Function Application(偏函数)和 Currying(函数加里化)
* 迭代器，队列，模式匹配。。。

#### 命令行执行风格

##### 指令式

	$ ./program1
	$ ./program2 --param1=1
	$ ./program3
	
##### 函数式(Pipeline)
	
	$ ./program1 | ./program2 --param1=1 | ./program3
	

### 简单的例子

计算部分无效字符串的数据计算：
	
	"28+32+++32++39"
	
#### 指令式

Imperative Style ＝ 执行动作，从初始状态转变成结果

	expr, res = "28+32+++32++39", 0
	for t in expr.split("+"):
    	if t != "":
        	res += int(t)
	print res
	
执行路径：

	"28+32+++32++39", 0
	"28", 0
	"32", 28
	"", 60
	"", 60
	"32", 60
	"", 92
	"39", 92
	131
	
#### 函数式

Functional Style = 应用转换和组合

	from operator import add
	expr = "28+32+++32++39"
	print reduce(add, map(int, filter(bool, expr.split("+"))))

执行路径：

	"28+32+++32++39"
	["28","32","","","32","","39"]	# split
	["28","32","32","39"]	# filter
	[28,32,32,39]	# int
	131	# reduce

#### MAP/REDUCE/FILTER 

* 可读性 VS 简洁
* 技术面 VS 操作物质
* 代码复用（热拔插）

### 函数式编程－函数是第一类型和高阶函数

#### 第一类型

换句话说，你的函数可以像变量一样来使用！

它可以作为变量：

	add = lambda a,b: a + b

它也可以作为函数的返回值
	
	def calculations(a, b):
    	def add():
        	return a + b

    return a, b, add
    
#### 高阶函数（High Ordered Function）

在数学和计算机科学中，高阶函数是至少满足下列一个条件的函数:

* 接受一个或多个函数作为输入，即作为参数
* 输出一个函数，即作为返回值

在数学中它们也叫做运算符或范式函数。微积分中的导数就是常见的例子，因为它映射一个函数到另一个函数。
例如:函数f(x) = x2;函数f(x)的导数为2x;2x也为一个函数，所以导数是高阶函数。

作为参数传递给函数：

	map(lambda x: x^2, [1,2,3,4,5])
	
作为返回值

	def speak(topic):
    	print "My speach is " + topic

	def timer(fn):
    	def inner(*args, **kwargs):
        	t = time()
        	fn(*args, **kwargs)
        	print "took {time}".format(time=time()-t)

    	return inner

	speaker = timer(speak)
	speaker("FP with Python")
	
	# 好可以这么用
	@timer
	def speak(topic):
    	print "My speach is " + topic	
    
	speak("FP with Python")


> 你可能对第一类型和高阶函数感觉到迷糊，下面是 StackOverflow 的答案：
> 
> 第一类型和高阶函数的区别 http://stackoverflow.com/questions/10141124/any-difference-between-first-class-function-and-high-order-function
> 看完估计还是很晕，不过

### 纯函数（Pure Function）

#### PURE

	def is_interesting(topic):
    	return topic.contains("FP")

#### NOT PURE

	def speak(topic):
    	print topic

#### PURE？？

	def set_talk(speaker, topic):
    	speaker["talk"] = topic
    	return speaker

### 纯函数是何方神圣？

**纯函数**（Pure Function）是这样一种函数——输入输出数据流全是显式（Explicit）的。

显式（Explicit）的意思是，函数与外界交换数据只有一个唯一渠道——参数和返回值；函数从函数外部接受的所有输入信息都通过参数传递到该函数内部；函数输出到函数外部的所有信息都通过返回值传递到该函数外部。

#### 有什么好处？

纯函数的好处主要有几点：

* 无状态。线程安全。不需要线程同步。
* 纯函数相互调用组装起来的函数，还是纯函数。
* 应用程序或者运行环境（Runtime）可以对纯函数的运算结果进行缓存，运算加快速度。

使用 stackoverflow 的例子：

	for (int i = 0; i < 1000; i++){
    	printf("%d", pureFun(10));
	}

使用纯函数，编译器可以知道只需要执行 pureFun(10)，仅需一次，而不是 1000次，然后读入缓存。对于复杂的函数，性能可想而知。。。

### SO，函数还是纯的好！

* 可以使用 [pmap](https://docs.python.org/2/library/multiprocessing.html)
* 更少的 BUG
* 更容易测试
* 最大程度复用

### 我们能避免轮询吗？- 递归

	>>> name = None
	>>> while name is None:
	...    name = raw_input()
	...    if len(name) < 2:
	...        name = None

#### 使用递归调用

	def get_name():
    	name = raw_input()
    	return name if len(name) >= 2 else get_name()
    
递归最大的好处就简化代码，他可以把一个复杂的问题用很简单的代码描述出来。注意：递归的精髓是描述问题，而这正是函数式编程的精髓。
    	
** Note **: Python 对递归次数有限制的，当递归次数超过1000次的时候，就会抛出“RuntimeError: maximum recursion depth exceeded”异常。
    	
### 函数式编程－尾(递归)调用

在计算机科学里，尾调用是指一个函数里的最后一个动作是一个函数调用的情形：即这个调用的返回值直接被当前函数返回的情形。

我们知道递归的害处，那就是如果递归很深的话，栈受不了，并会导致性能大幅度下降。所以，我们使用尾递归优化技术——每次递归时都会重用栈，这样一来能够提升性能，当然，这需要语言或编译器的支持。

#### ERLANG

	fib(N) -> fib(0,1,N).
	fib(_,S,1) -> S;
	fib(F,S,N) -> fib(S,F+S,N-1).   
	
#### PYTHON

Sorry，Python 目前不支持这一特性，下面代码演示，Python 对尾递归算法的实现

	def tailrecsum(x, running_total=0):
  		if x == 0:
    		return running_total
  		else:
    		return tailrecsum(x - 1, running_total + x)

** Note **: 这只是个算法实现，由于 Python 本身不支持为尾递归，而且实际测试结果中，写成尾递归的方式会比会比普通方式占用多那么多内存，所以应该在实际的代码使用尾递归，后续将会专门的章节介绍。

### 惰性求值（Lazy Evaluation）

它的目的是要最小化计算机要做的工作。

先来看个例子：

	for num in range(1, 20):
    	yield num

我们动用了Python的关键字 yield，这个关键字主要是返回一个Generator，yield 是一个类似 return 的关键字，只是这个函数返回的是个Generator-生成器。所谓生成器的意思是，yield返回的是一个可迭代的对象，并没有真正的执行函数。也就是说，只有其返回的迭代对象被真正迭代时，yield函数才会正真的运行，运行到yield语句时就会停住，然后等下一次的迭代。（这个是个比较诡异的关键字）这就是lazy evluation。

惰性求值有显著的优化潜力。惰性编译器看函数式代码就像数学家面对代数表达式——可以消去一部分而完全不去运行它，重新调整代码段以求更高的效率，甚至重整代码以降低出错，所有确定性优化（guaranteeing optimizations）不会破坏代码。这是严格用形式原语描述程序的巨大优势——代码固守着数学定律并可以数学的方式进行推理。

考虑一个 Fibonacci 数列，显然我们无法在有限的时间内计算出或在有限的内存里保存一个无穷列表。在严格语言如 Java 中，只能定义一个能返回 Fibonacci 数列中特定成员的 Fibonacci 函数，在 Haskell 中，我们对其进一步抽象并定义一个关于 Fibonacci 数的无穷列表，因为作为一个惰性的语言，只有列表中实际被用到的部分才会被求值。这使得可以抽象出很多问题并从一个更高的层次重新审视他们（例如，我们可以在一个无穷列表上使用表处理函数）。

### 函数式编程－偏函数应用（Partial Function Application）

> 通过**固定函数的一个或多个参数**，生成一个新的更少元数函数。

固定参数是偏函数应用的函数。

   def log(level, message):
   		print level + ": " + message   

   log("Warning", "this is one warning message")
   log("Error", "this is one error message")

   def logWarning(message):
       log("Warning", message)
    
   def logError(message):
       log("Error", message)
    
   logWarning("this is one warning message")
   logError("this is one error message")

上面的函数实现，相信代码都不会陌生把，`logWarning` 和 `logError` 就叫做函数应用。

在 Python 中可以借助 functools 模块来完成偏函数应用，而不用手工编写代码。

看看 Demo：

	>>> from functools import partial
	>>> a = lambda x, y, z: x+y+z
	>>> bind_x = partial(a, 1)
	>>> bind_x(2, 3)
	6 
	
上述例子我们可以使用简单类型λ演算来表示

	papply : λ(f, x). λy. f (x, y)
	
	
### 函数式编程－加里化（Currying）

> 是一种将带多个参数的函数转化成每次传入一个参数的函数链调用

**Currying**：因为是美国数理逻辑学家哈斯凯尔·加里(Haskell Curry)发明了这种函数使用技巧，所以这样用法就以他的名字命名为Currying，中文翻译为“加里化”。

先看一个简单的例子：

	def hiCurry(x):
		return lambda z: lambda y: x + y + z
		
	>>> hiCurry(1)(2)(3)
	6
	
上述例子我们可以使用简单类型λ演算来表示

	curry: λx. λy. λz. (x+y+z)

#### 常规的函数

	def simple_sum(a, b):
    	return sum(range(a, b+1))

	>>> simple_sum(1, 10)
	55
	
	def square_sum(a, b):
    return sum(map(lambda x: x**2, range(a,b+1)))

	>>> square_sum(1,10)
	385
	
#### 使用 Currying

	def fsum(f):
    	def apply(a, b):
        	return sum(map(f, range(a,b+1)))
    	return apply

	log_sum = fsum(math.log)
	square_sum = fsum(lambda x: x**2)
	simple_sum = fsum(int) ## fsum(lambda x: x)
	
	>>> fsum(lambda x: x*2)(1, 10)
	110
	>>> import functools
	>>> fsum(functools.partial(operator.mul, 2))(1, 10)
	110
	
#### 使用闭包封装一个通用 Currying 的函数(来源 Cookbook)

	def currying(f, *a, **kw):
    	def curried(*more_a, **more_kw):
        	return f(*(a+more_a), **dict(kw, **more_kw))
    	return curried
    	
    >>> a = lambda a, b, c: a+b+c
    >>> fillA = currying(a, 1)
    >>> fillB = currying(fillA, 2)
    >>> fillC = currying(fillC, 3)
    >>> fillC()
    6

#### 标准库中利用 Currying 技术：

	>>> from operator import itemgetter
	>>> itemgetter(3)([1,2,3,4,5])
	4

	>>> from operator import attrgetter as attr
	>>> class Speaker(object):
	...     def __init__(self, name):
	...         self.name = "[name] " + name
	... 
	>>> alexey = Speaker("Alexey")
	>>> attr("name")(alexey)
	'[name] Alexey'

	>>> from operator import methodcaller

	>>> methodcaller("__str__")([1,2,3,4,5])
	'[1, 2, 3, 4, 5]'
	>>> methodcaller("keys")(dict(name="Alexey", topic="FP"))
	['topic', 'name']

	>>> values_extractor = methodcaller("values")
	>>> values_extractor(dict(name="Alexey", topic="FP"))
	['FP', 'Alexey']

	>>> methodcaller("count", 1)([1,1,1,2,2]) 
	>>> # same as [1,1,1,2,2].count(1)
	3
	
### 程序就要小而美

#### BAD
 
	>>> ss = ["UA", "PyCon", "2012"]
	>>> reduce(lambda acc, s: acc + len(s), ss, 0)
	11

#### NOT BAD...

	>>> ss = ["UA", "PyCon", "2012"]
	>>> reduce(lambda l,r: l+r, map(lambda s: len(s), ss))
	11

#### GOOD

	>>> ss = ["UA", "PyCon", "2012"]
	>>> reduce(operator.add, map(len, ss))
	11

### 结语

系统地总结下自己对函数式编程的理解，没想到，收获颇丰！千万不要被外界评论给吓倒，绝对是一门有意思的学问。

发现通过小小一个篇幅的博客，根本无法把函数式编程的全部概念都讲清楚，只能慢慢来了，越深挖，内容也多，来日方长，只能慢慢来了，就怕大脑不够用！已经被忽悠去学习 λ 演算！

FP 哪里是编程，骨子里就是透着都是数学公式。

### 未完待续

> 参考：
> 
> 	* [FUNCTIONAL PROGRAMMING WITH PYTHON](http://ua.pycon.org/static/talks/kachayev/#/)
> 	* [Pure Function](http://en.wikipedia.org/wiki/Pure_function)
>	* [CoolShell 函数式编程](http://coolshell.cn/articles/10822.html)
>	* [函数副作用](http://zh.wikipedia.org/wiki/%E5%87%BD%E6%95%B0%E5%89%AF%E4%BD%9C%E7%94%A8#.E7.BA.AF.E5.87.BD.E6.95.B0)
> 	* [Higher-order function and First-class object](http://www.webdevelopmentmachine.com/blog/%E9%AB%98%E9%98%B6%E5%87%BD%E6%95%B0%E4%B8%8E%E7%AC%AC%E4%B8%80%E5%9E%8B_higher-order-function-and-first-class-object/)
> 	* [函数式编程里的惰性求值](http://www.nowamagic.net/academy/detail/1220550)
> 	* [函数加里化(Currying)和偏函数应用(Partial Application)的比较](http://www.vaikan.com/currying-partial-application/)
> 	* [Currying in Python](http://mtomassoli.wordpress.com/2012/03/18/currying-in-python/)
> 	* [Recipe 16.4. Associating Parameters with a Function (Currying)](http://blog.csdn.net/kingofark/article/details/1144461)
