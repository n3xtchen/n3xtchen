---
layout: post
title: "Scala ERROR: No ClassTag available for A"
description: ""
category: Scala
tags: [metaclass]
---
{% include JB/setup %}

今天写代码，遇到了莫名其妙的错误：

	scala> def list2Arr[A](list: List[A]) = list.toArray
	<console>:21: error: No ClassTag available for A
	       def list2Arr[A](list: List[A]) = list.toArray
	                                             ^
于是，我 Google 了下，大致的方案下面这样
	
	scala> import scala.reflect.ClassTag
	import scala.reflect.ClassTag	
	scala> def list2Arr[A: ClassTag](list: List[A]) = list.toArray
	list2Arr: [A](list: List[A])(implicit evidence$1: scala.reflect.ClassTag[A])Array[A]

`ClassTag[T]` 保存了被泛型擦除后的原始类型 `T`，在运行可以正确取到。
	
简单分析了下错误：

	scala> List(1).toArray
	   def toArray[B >: Int](implicit evidence$1: scala.reflect.ClassTag[B]): Array[B]
	
`toArray` 定义的形变（Variance，`[B >: Int]`）运行时，类型在传递过程中丢失了自身的特性；第一段代码，在运行的使用范型是，A 就是传递的类型，而它运行被擦除了，导致后续的函数无法获取：

	[B >: A]
	                                          

> 参考文献：
> 
> * [Scala型变](http://www.jianshu.com/p/fa0c67fe1bc6)
> * [Scala中Manifest、ClassTag、TypeTag的学习](https://my.oschina.net/cloudcoder/blog/856106)
> * [Overcoming type erasure in Scala](https://medium.com/byte-code/overcoming-type-erasure-in-scala-8f2422070d20)
> * [scala的类与类型](http://blog.csdn.net/wsscy2004/article/details/38440247)
> * [TypeTags and Manifests](http://docs.scala-lang.org/overviews/reflection/typetags-manifests.html)
> * [Scala：什么是TypeTag,我如何使用它？](http://codeday.me/bug/20170221/3835.html)
> * [Scala中TypeTags和Manifests的用法](http://www.jianshu.com/p/44410b15d3fc)
> * [scala类型系统：19) Manifest与TypeTag](http://hongjiang.info/scala-type-system-manifest-vs-typetag/)
> * [Scala 的那些奇怪的符号 （一）：“<:” 和 “>:” 作用及用法](http://blog.csdn.net/i6448038/article/details/52061287)