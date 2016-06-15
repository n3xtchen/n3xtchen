---
layout: post
title: "Scala 带着镣铐，仍然可以优雅的跳舞"
description: ""
category: Scala
tags: [jvm]
---
{% include JB/setup %}

作为一个初学者，经过一个月系统的系统学习，用惯了动态语言的我来说，**Scala** 编译器型语言的编程体验真的是太棒了。作为阶段性的总结，我将给出我对 **Scala** 最佳初体验的 Top 10：

## 1.在一些情况下，中缀(Infix)标记和后缀(Postfix)标记可省略

	1 + 2
	
这段语句大家再熟悉不过了，但是在 **Scala** 中，所有的表达式都是方法，实际上完整的写法，如下：

	1.+(2)
	
即，`+` 是整型对象（在 **Scala** 中所有东西都是对象）的一个方法，如果了解到这里，会不会觉得能写成之前的样子很神奇。这里是 **Scala** 一个特性：

* 如果一个对象有一个带有一个参数的方法， 它的中缀标记可以省略，在这里，点号和括号都可以省略。

类似的，如果一个方法没有参数表，你调用它的时候，可以它的后缀标记（即括号）可以省略：

	scala> 1 toString	// 1.toString()
	warning: there were 1 feature warning(s); re-run with -feature for details
	res2: String = 1
	
因为忽略后缀，有时候会让人很迷惑，方法？属性？傻傻分不清楚！所以在版本 **2.10** 之后，如果没有明确告诉编译器的话，会给出一个警告：

	scala> import scala.language.postfixOps
	scala> 1 toString
	res2: String = 1
	
警报解除，神奇吧？现在我们看一个复杂的例子：

	def isEven(n: Int) = (n % 2) == 0
	List(1, 2, 3, 4) filter isEven foreach println
	
看看简化过程

	1. List(1, 2, 3, 4).filter((i: Int) => isEven(i)).foreach((i: Int) => println(i))
	2. List(1, 2, 3, 4).filter(i => isEven(i)).foreach(i => println(i))
	3. List(1, 2, 3, 4).filter(isEven).foreach(println)
	4.List(1, 2, 3, 4) filter isEven foreach println