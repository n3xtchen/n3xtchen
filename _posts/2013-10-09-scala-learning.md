---
layout: post
zitle: "Scala - 学习笔记"
description: ""
category: scala
rags: [scala, learning ]
---
{% include JB/setup %}

最好的学习 Scala 的方式取决于你的知识量以及你学习偏好。目前市面上有各种各样
的资源，包括书本，教程，联系课程，课件以及学习用的交互编译器。很多人采用的方
式是看书和动手编写调试例子相结合。另外，你还可以选择教程或者使用在线材料。

随着你对 Scala 学习深入，你将会发现有更多进阶的材料以及非常友好的 Scala 社区
可 以帮助你。他们极具分享精神，以及欢迎新手。他们写了很多对新手有帮助的教程
，回复寻求帮助的邮件或者在一些论坛和个人博客分享新技术，先进的概念或者工具。

### 新手 Scala

对于新手来说，你可能会发现很大一部分材料都要求你掌握一些编程经验的基础上。这
里有两个有用的资源推荐给编程新手，它将直接带你进入 Scala 世界：

* Coursera 上的在线课程 Scala 函数编程准则（Functional Programming 
Principles in Scala）。他是由 Scala 的创始人 Martin Odersky 教授的，它使用传
统大学的教授方式来讲解函数编程的基础。你将会通过解决编程任务来学习 Scala。 

* Kojo 是一个交互学习环境，它使用 Scala 探索数学，艺术，音乐，动画以及游戏
。

### Scala Basic

#### 启动解释器

    $ sbt console

#### 表达式(expressions)

    scala>  1 + 1
    res0: Int = 2

#### 变量(variables) 与 常量(Values)

    scala> var name = "Steve"   # 顾名思义，存储在其中的数据是可以改变的
    scala> val name = "Jobs"    # 不可变的

#### 函数(functions)

    scala> def sayHi(name: String): String = "HI, " + name
    sayHi: (name: String)String

    scala> sayHi("N3xtchen")
    res2: String = HI, N3xtchen

    # 如果你函数中包含多行表达式,使用花括号({})
    scala> def sayHi(name: String): Int = {
        | println("Hi, " + name)
        | 1
        | }

    scala> sayHi("Steve")
    Hi, Steve
    res6: Int = 1

    # 匿名函数
    scala> val addOne = (x:Int) => x + 1    # 将匿名函数覆盖给常量，便于调用
    addOne: Int => Int = <function1>

    scala> addOne(1)
    res5: Int = 2

##### 偏函数应用(partially application)

偏函数应用是找一个函数，固定其中的几个参数值，从而得到一个新的函数。

    scala> def add(x: Int, y: Int) = x + y
    add: (x: Int, y: Int)Int

    scala> val xAdd = add(1, _:Int)
    xAdd: Int => Int = <function1>

    scala> xAdd(2)
    res7: Int = 3

> Scala 在不同场景下使用下划线代表不同的应用。但你可以把他当作当作无名的魔法
匹配符。在上述例子中, _当作参数占位符;

##### 加里化函数(Curried functions)

函数加里化是一种使用匿名单参数函数来实现多参数函数的方法。

    scala> def multiply(x: Int)(y: Int): Int = x * y
    multiply: (x: Int)(y: Int)Int

    scala> multiply(2)(3)
    res8: Int = 6

    scala> val double = multiply(2)_
    double: Int => Int = <function1>

    scala> double(3)
    res9: Int = 6

##### 可变参数(Variable lenth arguments)

    scala> def upperAll(args: String*) = {
         | args.map{arg=>arg.toUpperCase}
         | }
    upperAll: (args: String*)Seq[String]

    scala> upperAll("Hello", "World")
    res1: Seq[String] = ArrayBuffer(HELLO, WORLD)

#### 类(Classes)

    scala> class Calculator {
        |   val brand: String = "C"
        |   def add(x: Int, y: Int): Int = x+y
        | }
    defined class Calculator

    scala> val calc = new Calculator
    calc: Calculator = Calculator@22ddcabb

    scala> calc.brand
    res0: String = C

    scala> calc.add(1,1)
    res1: Int = 2

##### 构造器(Constructor)

构造器不是一个特殊的方法，他只是定义在类函数外部的代码。(我们可以理解成初始化
时，把本身作为函数调用，对象内方法只是声明，自然不会被调用)。

    scala> class Calculator(brand: String) {
         |   val color: String = if (brand == "TI") {
         |     "blue"
         |   } else if (brand == "HP") {
         |     "black"
         |   } else {
         |     "white"
         |   }
         | 
         |   def add(x: Int, y: Int): Int = x+y
         | }
    defined class Calculator
    scala> val calc = new Calculator("HP")
    calc: Calculator = Calculator@1e64cc4d

    scala> calc.color
    res0: String = black

> #####Aside: 函数和方法
> 函数和方法大体上是可以相互替换的。由于函数和方法很类似，你可以不记得你调用的
> 是一个函数还是方法。当你纠结函数和方法的区别的时候，你可能会很迷惑。

>       scala> class C {
>           |  var acc = 0
>           |  def method = { acc +=1 }
>           |  val func = { () => acc +=1 }
>           | }
>       defined class C
>       
>       scala> val c =new C
>       c: C = C@82f9028
>       
>       scala> c.method
>       
>       scala> c.acc
>       res3: Int = 1
>       
>       scala> c.func
>       res4: () => Unit = <function0>
>       
>       scala> c.acc
>       res5: Int = 1
>       
>       scala> c.func()
>       
>       scala> c.acc
>       res7: Int = 2)

> 你可以不使用括号来调用函数，但是调用方法时就必须使用，你可能以为自己知道 Scala
> 函数是如何工作的，但是我并不怎么认为。但是都使用括号时呢？你也许把它当作函数，但
> 实际上是一个方法。

> 实际上，既然你对函数和方法的概念很模糊，但是你让人能利用 Scala 做很多很棒的事情。
> 如果你是新手，你可能应该读一下[他们区别的解释](http://www.google.com.hk/search?q=difference+scala+function+method),
> 你可能会和他们遇到同样的麻烦。这并不意味你将会很困难使用 Scala。由于它们之间的区
> 别太微小，不得不去剖析语言的底层来解释它。
