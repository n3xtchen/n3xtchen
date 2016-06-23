---
layout: post
title: "Scala 新手眼中的十种美妙特性"
description: ""
category: Scala
tags: [jvm]
---
{% include JB/setup %}

TL;DR

作为一个初学者，经过一个月系统的系统学习，用惯了动态语言的我来说，**Scala** 编译器型语言的编程体验真的是太棒了。作为阶段性的总结，我将给出我对 **Scala** 最佳初体验的 Top 10：

## 漂亮的操作系统调用 DSL

**Scala** 2.9里也提供类似功能：新增加了package: `scala.sys` 及`scala.sys.process`, 这些代码最初由**SBT**(a simple build tool for Scala)项目贡献，主要用于简化与操作系统进程的交互与调用。现在看看用法：

	scala> import scala.language.postfixOps
	import scala.language.postfixOps
	
	scala> import scala.sys.process._
	import scala.sys.process._
	
	scala> "java -version" !
	java version "1.7.0_80"
	Java(TM) SE Runtime Environment (build 1.7.0_80-b15)
	Java HotSpot(TM) 64-Bit Server VM (build 24.80-b11, mixed mode)
	res2: Int = 0

当你引入 `scala.sys.process` 后，**scala** 会为你给字符串或数组动态注入 `!` 方法，来调用系统命令
	
这是我见过调用 shell 最爽最优雅的一个，不是吗？现在看个复杂点的例子，爬取一个页面：
	
	scala> import java.io.File
	import java.io.File
	
	scala> import java.net.URL
	import java.net.URL
	
	scala> new URL("http://www.scala-lang.org/") #> new File("scala-lang.html") !
	res4: Int = 0
	
这里我们又学到一个新的操作符 `#>`，结果重定向。这条命令等价于如下 **Bash**

	$ curl "http://www.scala-lang.org/ > scala-lang.html
	
看看结果:
	
	scala> "ls" !
	...
	scala-lang.html
	...
	res6: Int = 0

> 参考: http://www.scala-lang.org/api/rc2/scala/sys/process/package.html

## 管道（Pipeline）

	scala> import scala.language.implicitConversions
	import scala.language.implicitConversions
	
	scala> object Pipeline {
	     |   implicit class toPiped[V](value:V) {
	     |     def |>[R] (f : V => R) = f(value)
	     |   }
	     | }
	defined module Pipeline
	
	scala> import Pipeline._
	import Pipeline._
	
	scala> 1 |> ((i:Int)=> i*10)
	res3: Int = 10
	
这样就可以将，函数 A 返回的值作为后面函数参数，一条链式调用看起来是那么的优雅（你觉得呢？）。
	
短短几行的代码，足以让你领教到 **隐式转化**（implicit）的威力吧！因为这个话题比较大，就不在这里阐述了。

## 使用 `{...}` 替代 `(...)` 的语法糖

声明一个多参数表函数，如下

	scala> def m[A](s: A)(f: A=> String) = f(s)
	m: [A](s: A)(f: A => String)String

你可以这样调用它：

	scala> m(100)(i => s"$i + $i")
	res2: String = 100 + 100

你可以使用 `{...}` 替代 `(...)` 的语法糖，就可以把上面改写成下面的模式

	scala> m(100){ i => s"$i + $i" }
	res3: String = 100 + 100

竟然可以如此优雅优雅地调用函数，看起来就像标准的块代码（像 `if` 和 `for` 表达式）

## 创建自己的字符解释器

	import scala.util.parsing.json._
	
	object Interpolators {
	  implicit class jsonForStringContext(val sc: StringContext) {
	    def json(values: Any*): JSONObject = {
			val keyRE = """^[\s{,]*(\S+):\s*""".r
			val keys = sc.parts map {
				case keyRE(key) => key
				case str => str
			}
			val kvs = keys zip values
			JSONObject(kvs.toMap)
		}
	  }
	}
	
	import Interpolators._
	
	val name = "Dean Wampler"
	val book = "Programming Scala, Second Edition"
	
	val jsonobj = json"{name: $name, book: $book}" 
	println(jsonobj)
	
哈哈，有意思吧！

## 在大部分情况下，中缀(Infix)标记和后缀(Postfix)标记可省略

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

## 密封类型（Sealed）强制其子类只能定义在同一个文件中

`seals` 关键字可以用在 `class` 和 `trait` 上。

第一个作用如题，举个栗子，**Scala** 源码中 `List` 的实现用到 `sealed` 关键字:

	scala> class NewList extends List
	<console>:7: error: illegal inheritance from sealed class List
	       class NewList extends List
	       
这样子，妈妈再也不用担心我的类被人滥用。

如果就这么个功能，怎么能称得上 Top 10 呢？在看一个黑魔法：

	scala> sealed abstract class Drawing
	defined class Drawing
	
	scala> case class Point(x: Int, y: Int) extends Drawing
	defined class Point
	
	scala> case class Circle(p: Point, r: Int) extends Drawing
	defined class Circle
	
	scala> case class Cylinder(c: Circle, h: Int) extends Drawing
	defined class Cylinder

如果你如之前，少写了其中一個案例：

	scala> def what(d: Drawing) = d match {
	     |     case Point(_, _)    => "點"
	     |     case Cylinder(_, _) => "柱"
	     | }
	<console>:14: warning: match may not be exhaustive.
	It would fail on the following input: Circle(_, _)
	       def what(d: Drawing) = d match {
	                              ^
	what: (d: Drawing)String

编译器在告訴你，有些模式的类型你沒有列在 `match` 運算式的案例串（Case sequence）之中。你必须每個都列出來才可以：
	
	scala> def what(d: Drawing) = d match {
	     |     case Point(_, _)    => "點"
	     |     case Circle(_, _)   => "圓"
	     |     case Cylinder(_, _) => "柱"
	     | }
	what: (d: Drawing)String
	
有時候，你使用別人密封過的案例类别，但也許你真的只想比对其中几個案例类型，如果不想要编译器饶人的警告，则可以在最后使用万用字元模式（`_`），例如：
	
	scala> def what(d: Drawing) = d match {
	     |     case Point(_, _)    => "點"
	     |     case Cylinder(_, _) => "柱"
	     |     case _              => "" // 作你想作的事，或者丟出例外
	     | }
	what: (d: Drawing)String
	
如果你真心不想要使用万用字元作额外处理，那么还可以可以使用 `@unchecked` 标注來告訴编译器住嘴：
	
	scala> def what(d: Drawing) = (d: @unchecked) match {
	     |     case Point(_, _)    => "點"
	     |     case Cylinder(_, _) => "柱"
	     | }
	what: (d: Drawing)String
	
> 参考：http://openhome.cc/Gossip/Scala/SealedClass.html

## 有趣的权限控制 `private[]`

`protected` 或 `private` 這表示权限限制到 `x` 的范围。
	
	class Some {
	    private val x = 10
	    def doSome(s: Some) = s.x + x
	}

对于大多数语言，访问控制就严格无非就这两种。在 **Scala** 中，可以更加严格，让 `x` 完全无法透过实例存取，则可以使用 `private[this]`，這表示私有化至 `this` 实例本身才可以存取，也就是所謂物件私有（Object-private），例如以下就通不過编译了：
	
	class Some {
	    private[this] val x = 10
	    def doSome(s: Some) = s.x + x  // 编译错误
	}
	
作为入门，就知道这里就可以了，可以跳到下一个话题了！

如果你看过 **Spark**（一个分布式计算框架）的源码，会发现这样的权限控制符，所以这个还是有必要搞清楚的。
	
如果能看懂下面这段代码，那你对 `Scala` 的访问控制算是了解了：

	package scopeA {
	  class Class1 {
	    private[scopeA]   val scopeA_privateField = 1
	    protected[scopeA] val scopeA_protectedField = 2
	    private[Class1]   val class1_privateField = 3
	    protected[Class1] val class1_protectedField = 4
	    private[this]     val this_privateField = 5
	    protected[this]   val this_protectedField = 6
	  }
	
	  class Class2 extends Class1 {
	    val field1 = scopeA_privateField
	    val field2 = scopeA_protectedField
	    val field3 = class1_privateField     // ERROR
	    val field4 = class1_protectedField
	    val field5 = this_privateField       // ERROR
	    val field6 = this_protectedField
	  }
	}
	
	package scopeB {
	  class Class2B extends scopeA.Class1 {
	    val field1 = scopeA_privateField     // ERROR
	    val field2 = scopeA_protectedField
	    val field3 = class1_privateField     // ERROR
	    val field4 = class1_protectedField
	    val field5 = this_privateField       // ERROR
	    val field6 = this_protectedField
	  }
	}

不懂也没关系，后面会花一个大篇幅来讲这块内容。

## 传名函数(Call By Name)

## 异常捕捉

##