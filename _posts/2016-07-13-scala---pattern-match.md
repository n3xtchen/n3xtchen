---
layout: post
title: "Scala - 只谈模式匹配"
description: ""
category: Scala
tags: []
---
{% include JB/setup %}

	1: val bools = Seq(true, false)
	2: for (bool in bools) {
	3:	 	bool match {
	4:			case true => println("真的")
	5:			case false => println("假的")
	6:		}
	7: }
	
这个就是我们所说的模式匹配；看起来很像 C 风格，但是不一样，尤其要记住：`=>`，我经常把它写成 `:`。

现在讲第一个特性：**需要处理对每个匹配规矩**。

怎么说？我们把第 5 行注释掉，编译下：

	<console>:12: warning: match may not be exhaustive.
	It would fail on the following input: false
	                bool match {
	                ^
	真的
	scala.MatchError: false (of class java.lang.Boolean)
	  at .<init>(<console>:11)
	  at .<clinit>(<console>)
	  ...
	  
这个警告告诉我们，没有穷尽匹配，意思就是要我们处理所有可能被匹配的可能；说明 **Scala** 是相当严谨的。


### 匹配值，类型以及变量：


	for {
		x <- Seq(1, 2, 2.7, "one", "two", 'four
	} {
		val str = x match {
		    case 1          => "int 1"
		    case _: Int     => "other int: "+x
		    case _: Double  => "a double: "+x
		    case "one"      => "string one"
		    case _: String  => "other string: "+x
		    case _          => "unexpected value: " + x
		  }
		  println(str)
	}

下面是输出：
	
	int 1
	other int: 2
	a double 2.7
	string one
	other string: two
	unexpected value: 'four

这个很简单，自己领悟下就好。下面讲一个难点，如果要匹配一个变量的值的话，你怎么做：

	1: def checkY(y: Int) {
	2:		for {
	3:			x <- Seq(99, 100, 101)
	4:		} {
	5:			val str = x match {
	6:				case y => "found Y"
	7:				case i: Int => "int:" + i
	8:			}
	9:			println(str)
	10:		}
	11:}
	checkY(100)
	
下面是输出：

	<console>:12: warning: patterns after a variable pattern cannot match (SLS 8.1.1)
	If you intended to match against parameter y of method checkY, you must use	
	# 我加的：如果你你想要匹配参数 y 的值，你必须使用反引号
	backticks, like: case `y` =>
	             case y => "found y!"
	                  ^
	<console>:13: warning: unreachable code due to variable pattern 'y' on line 12
	             case i: Int => "int: "+i
	                                   ^
	<console>:13: warning: unreachable code
	             case i: Int => "int: "+i
	                                   ^
	checkY: (y: Int)Unit
	found y!
	found y!
	found y!
	
如果是初学者，这个坑肯定躺过。这里又要夸一下 **Scala** 智能了，报错的信息非常有参考价值。编译器已经猜到你的意图了(认真看我的错误注释)。

> ### 注意：
> 在 `case` 语句中，小写字符开头的词会被假设一个新变量名，存储提取出来的值。为了引用之前定义的变量，你需要用反引号。相反，如果一个单词首字母大写，**Scala** 会把它当作一种类型名。

你只需要将第6行的 `y` 替换成 **\`y\`** 即可。

你在运行一次你的程序：

	int: 99
	found y!
	int: 101
	
最后，我们还可以在一个 `case` 语句匹配多个。为了避免重复，我们可以使用 `or` 或者 `｜`:

	for {
		x <- Seq(1, 2, 2.7, "one", "two", 'four)
	} {
		val str = x match {
			case _: Int | _: Double => "a number:" + x	# 注意看这一行
			case "one" => "string one"
			case _: String => "other string: " + x
			case _ => "unexpected value: " + x
		}
		println(str)
	}
	
### 匹配 Seq

首先，`Seq` ，`List`， `Vector` 都是 Seq 的子类，仅有它们可以使用此类模式匹配

	val nonEmptySeq    = Seq(1, 2, 3, 4, 5)
	val emptySeq       = Seq.empty[Int]	# 空 Seq
	val nonEmptyList   = List(1, 2, 3, 4, 5)	val emptyList      = Nil	# 空列表
	val nonEmptyVector = Vector(1, 2, 3, 4, 5)	val emptyVector    = Vector.empty[Int]	# 空向量
	val nonEmptyMap    = Map("one" -> 1, "two" -> 2, "three" -> 3)	val emptyMap       = Map.empty[String,Int]
	
	def seqToString[T](seq: Seq[T]): String = seq match {	  case head +: tail => s"$head +: " + seqToString(tail)	  case Nil => "Nil"
	}
	
	for (seq <- Seq(	   
		nonEmptySeq, emptySeq, nonEmptyList, emptyList,
		nonEmptyVector, emptyVector, nonEmptyMap.toSeq,
		emptyMap.toSeq)) {
	  println(seqToString(seq))
	}

需要注意的是，对于 `Map 类型`，我们需要使用 `toSeq`，因为它不是 `Seq` 的子类。
下面是输出：
	
	1 +: 2 +: 3 +: 4 +: 5 +: Nil
	Nil1 +: 2 +: 3 +: 4 +: 5 +: Nil
	Nil
	1 +: 2 +: 3 +: 4 +: 5 +: Nil
	Nil
	(one,1) +: (two,2) +: (three,3) +: Nil
	Nil

 直接看代码就好了。

### 元组匹配

	val langs = Seq(
	  ("Scala",   "Martin", "Odersky"),
	  ("Clojure", "Rich",   "Hickey"),
	  ("Lisp",    "John",   "McCarthy"))
	
	for (tuple <- langs) {
	  tuple match {
	    case ("Scala", _, _) => println("Found Scala")                   // 
	    case (lang, first, last) =>                                      // 
	      println(s"Found other language: $lang ($first, $last)")
	  }
	}
	
### 在 `case` 中使用 Guards


	for (i <- Seq(1,2,3,4)) {
	  i match {
	    case _ if i%2 == 0 => println(s"even: $i")	    case _             => println(s"odd:  $i")	  }
	}

下面是输出：	

	odd:  1
	even: 2
	odd:  3
	even: 4

### case class 匹配	

	case class Address(street: String, city: String, country: String)
	case class Person(name: String, age: Int, address: Address)
	
	val alice   = Person("Alice",   25, Address("1 Scala Lane", "Chicago", "USA"))
	val bob     = Person("Bob",     29, Address("2 Java Ave.",  "Miami",   "USA"))
	val charlie = Person("Charlie", 32, Address("3 Python Ct.", "Boston",  "USA"))
	
	for (person <- Seq(alice, bob, charlie)) {
	  person match {
	    case Person("Alice", 25, Address(_, "Chicago", _) => println("Hi Alice!")
	    case Person("Bob", 29, Address("2 Java Ave.", "Miami", "USA")) =>
	      println("Hi Bob!")
	    case Person(name, age, _) =>
	      println(s"Who are you, $age year-old person named $name?")
	  }
	} 

这是输出:	

	Hi Alice!
	Hi Bob!
	Who are you, 32 year-old person named Charlie?

### 正则表达式匹配

	val BookExtractorRE = """Book: title=([^,]+),\s+author=(.+)""".r
	
	val item = "Book: title=Programming Scala Second Edition, author=Dean Wampler"
	
	println(item match {
	  case BookExtractorRE(title, author) =>
		 println(s"""Book "$title", written by $author""")
	  case entry => println(s"Unrecognized entry: $entry")
	})

输出:
	
	Book "Programming Scala Second Edition", written by Dean Wampler

