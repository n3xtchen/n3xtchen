---
layout: post
title: "Scala - 学习笔记"
description: ""
category: scala
tags: [scala, learning ]
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

