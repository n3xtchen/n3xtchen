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

这里的 `case` 子句中的 `y` 意味着匹配任何东西，把它赋值给新的变量 `y`，此 Y 非彼 Y。

你只需要将第6行的 `y` 替换成 **\`y\`** 即可。

你在运行一次你的程序：

	int: 99
	found y!
	int: 101