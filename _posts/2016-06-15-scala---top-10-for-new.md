---
layout: post
title: "Scala 新手眼中的十个有趣特性"
description: ""
category: Scala
tags: [jvm]
---
{% include JB/setup %}

TL;DR

作为一个初学者，经过一个月系统的系统学习，用惯了动态语言的我来说，**Scala** 编译器型语言的编程体验真的是太棒了。作为阶段性的总结，我将给出我对 **Scala** 最佳初体验的 Top 10：

## 漂亮的操作系统调用方式

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

## 简便的类声明：

**Java** 党可以看过来，不论是 IDE 和文本编辑器党，代码中到处充斥着大量的 `setter` 和 `getter`：

	// src/main/java/progscala2/basicoop/JPerson.java
	package progscala2.basicoop;
	
	public class JPerson {
	  private String name;
	  private int    age;
	
	  public JPerson(String name, int age) {
	    this.name = name;
	    this.age  = age;
	  }
	
	  public void   setName(String name) { this.name = name; }
	  public String getName()            { return this.name; }
	
	  public void setAge(int age) { this.age = age;  }
	  public int  getAge()        { return this.age; }
	}
	
看看，**Scala** 可以这么写：

	class Person(var name: String, var age: Int)
	
有没有像流泪的感觉，哈哈，That is it！如果想要覆盖某些 `setter` 和 `getter`，只要类声明中，覆盖相应方法即可。

有 `var`，自然有 `val`，如果你的对象属性都是不可变，那还可以使用如下声明：

	case class Person(name: String, age: Int)
	 
会不会很心动啊？^_^

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

## 类型擦除和 `implicit`

	scala> :paste
	object M {
	  def m(seq: Seq[Int]): Unit = println(s"Seq[Int]: $seq")
	  def m(seq: Seq[String]): Unit = println(s"Seq[String]: $seq")
	}
	<ctrl-d>
	<console>:8: error: double definition:
	method m:(seq: Seq[String])Unit and
	method m:(seq: Seq[Int])Unit at line 7
	have same type after erasure: (seq: Seq)Unit
	       def m(seq: Seq[String]): Unit = println(s"Seq[String]: $seq")

由于历史原因，**JVM** `忘记了` 参数化类型的参数类型。例如例子中的 `Seq[Int]` 和 `Seq[String]`，**JVM** 看到的只是 `Seq`，而附加的参数类型对于 JVM 来说是不可见，这就是传说中的**类型擦除**。于是乎，从 **JVM** 的视角来看，代码是这样子的：

	object M {
	  // 两者都是接受一个 Seq 参数，返回Unit
	  def m(seq: Seq): Unit = println(s"Seq[Int]: $seq")
	  def m(seq: Seq): Unit = println(s"Seq[String]: $seq")
	}
	
这不就报错了吗？重复定义方法。那怎么办呢？（**JAVA** 语言的痛点之一）Scala 给你提供一种比较优雅的解决方案，使用隐式转换：

	scala> :paste
	object M {
		implicit object IntMarker 
		implicit object StringMarker
		
		// 对于 JVM 来说是，接受 Seq 参数和 IntMarker.type 型 i 参数，
		// 返回 Unit
		def m(seq: Seq[Int])(implicit i: IntMarker.type): Unit =
    println(s"Seq[Int]: $seq")

		// 对于 JVM 来说是，接受 Seq 参数和 StringMarker.type 型 i 参数，
		// 返回 Unit
		// 
		def m(seq: Seq[String])(implicit s: StringMarker.type): Unit =
    println(s"Seq[String]: $seq")
	}
	<ctrl-d>
	scala> import M._
	scala> m(List(1,2,3))	// 在调用的时候，忽略隐式类型
	scala> m(List("one", "two", "three"))
	
## 异常捕捉与 `Scalaz`

先来看看，异常捕捉语句：

	try {
		source = Some(Source.fromFile(fileName))
		val size = source.get.getLines.size
		println(s"file $fileName has $size lines")
	} catch {
		case NonFatal(ex) => println(s"Non fatal exception! $ex")
	} finally {
      for (s <- source) {
        println(s"Closing $fileName...")
        s.close
      }
	}
	
这里是打开文件的操作，并且计算行数；`NonFatal` 非致命错误，如内存不足之类的非致命错误，将会被抛掉。`finnaly` 操作结束后，关闭文件。这是 **Scala** 模式匹配的又一大应用场景，你会发现倒是都是模式匹配：
		 
		 case NonFatal(ex) => ...
		 
如果每条异常的处理语句只是单条的话，**Scala** 写起来应该会挺爽的。

### Java 的 `throws` 和 Scala 的 `Try`

先来看看 `Java` 的：

	...
	public function m() throws Exception1, Exception2... {
		...
	}
	...
	

这就是 `JAVA` 的 **Checked Exception**(有人翻译成受检的异常)。大概的原理就是通过方法签名的方式来指明该函数可能会抛出的异常。当初的学 JAVA 的时候，这个特点还是满有趣，但是后来新发明的语言鲜有这种特性（我学过的语言中，仅有 JAVA）。

按照规范，也到这类函数，你就要使用 `try` 来处理：

	try {	... }
	catch(Exception) { ... }
	
在Java 应用程序中，异常处理机制为：抛出异常，捕捉异常。

> 参考：[Java 里的异常(Exception)详解](http://nvd11.blog.163.com/blog/static/20001831220142104229680/)

而 **Scala** 可以返回异常:
	
	def addInts2(s1: String, s2: String): Either[NumberFormatException,Int]= 
	try {
		Right(s1.toInt + s2.toInt)
	} catch {
		case nfe: NumberFormatException => Left(nfe) 
	}
	
	scala> println(addInts2("1", "2"))
	Right(3)
	
	scala> println(addInts2("1", "x"))
	Left(java.lang.NumberFormatException: For input string: "x")
	
这样，他不会直接抛出错误，当然，如果想要使用该函数，最好要明确来处理 `left` 和 `right` 类型:
	
	addInts2("x", "1") match {
		case Left(msg) => println(msg)
		case Rigth(n) => n	
	}
	
或者你也可以直接忽视异常：

	for (n  <- addInts2("x", "1").rigth) {
		n
	}

愚认为，相对于 `throws` 直接抛出错误，`scala` 的实现体验更好，而且不用一直写 `try catch`。

如果不想声明异常类型，那你可以使用 `Try` 对象，用法如下：

	import scala.util.{ Try, Success, Failure }
	
	def positive(i: Int): Try[Int] = Try {
	  assert (i > 0, s"nonpositive number $i")
	  i
	}
	
这样，你只需要定义你正确返回结果的类型，而异常不需要特殊定义。如果更完整的定义，你可以这样：

	def positive(i: Int): Try[Int] =
	  if (i > 0) Success(i)
	  else Failure(new AssertionError("assertion failed"))

这里的 `Failure` 是一个 `Throwable` 对象。这样子有方便了不少。

### Scalaz 验证

在传统的异常处理，无法一次性汇总运行过程中的错误。如果我们在做表单验证的时候，我们就需要考虑到这个场景。而传统的做法就是通过一层层 `try ... catch ...`，把错误追加到一个列表中来实现，而 `scalaz` 中提供一个适用于这个场景的封装，直接看例子吧：

	import scalaz._, std.AllInstances._
	
	/* 验证用户名，非空和只包含字母 */
	def validName(key: String, name: String):
	    Validation[List[String], List[(String,Any)]] = {
	  val n = name.trim  // remove whitespace
	  if (n.length > 0 && n.matches("""^\p{Alpha}$""")) Success(List(key -> n))
	  else Failure(List(s"Invalid $key <$n>"))
	} 
	
	/* 验证数字，并且大于0 */
	def positive(key: String, n: String):
	    Validation[List[String], List[(String,Any)]] = {
	  try {
	    val i = n.toInt
	    if (i > 0) Success(List(key -> i))
	    else Failure(List(s"Invalid $key $i"))
	  } catch {
	    case _: java.lang.NumberFormatException =>
	      Failure(List(s"$n is not an integer"))
	  }
	}
	
	/* 验证表单 */
	def validateForm(firstName: String, lastName: String, age: String):
	    Validation[List[String], List[(String,Any)]] = {
	  validName("first-name", firstName) +++ validName("last-name", lastName) +++
	    positive("age", age)
	}
	
	validateForm("Dean", "Wampler", "29")
	validateForm("", "Wampler", "0")
	// Returns: Failure(List(Invalid first-name <>, Invalid age 0))
	//告知你名字和年龄填写有误
	validateForm("Dean", "", "0") 
	// Returns: Failure(List(Invalid last-name <>, Invalid age 0)) 
	// 告知你姓氏和年龄填写有误
	validateForm("D e a n", "", "29")
	// Returns: Failure(List(Invalid first-name <D e a n>, Invalid last-name <>)) 
	// 告知你名字和姓氏填写错误

这方式还不错吧？

就到这里就结束了，写着写着，就写这么多了，赶紧收住。

