---
layout: post
title: "从 array_map 开始：对 Functional Programming 的思考"
description: ""
category: 
tags: []
---
{% include JB/setup %}

思考一下这个程序的输出结果

	$languages = array('php','python','scala');
	
	foreach ($languages as &$lang)
	    $lang = strtoupper($lang);
	    
	foreach ($languages as $lang) // notice NO reference here!
	    echo $lang."\n";

答案是：

	PHP
	PYTHON
	PYTHON

哈哈，不错的一道面试题目！这里很明显，我想讲的就是副作用。

作为 FP 的鼓吹者，我今天从黑 **foreach** 开始讲起（Sorry，foreach ^_^）。

	$languages = array('php','python','scala');
	
	array_map(function(&$lang) {
	    $lang = strtoupper($lang);
	}, $languages);
	    
	foreach ($languages as $lang)
	    echo $lang."\n";
	    
使用 **map** 的结果是才是你预期的，因为 `array_map` 遵循函数式编程的特性，无副作用！如果想知道**map** 算法的实现，你可以参考写的 []()，其中揽括了 MapReduce 和 Filter 的递归实现！

任何的循环都可以通过递归来实现。

> ### 函数式编程特点－没有"副作用"
> 所谓"副作用"（side effect），指的是函数内部与外部互动（最典型的情况，就是修改全局变量的值），产> 生运算以外的其他结果。函数式编程强调没有"副作用"，意味着函数要保持独立，**所有功能就是返回一个新的值，没有其他行为，尤其是不得修改外部变量的值。**

上面的那个例子是违反函数编程特性，虽然避免的副作用，但是它修改了变量的状态，应该这样：

	$languages = array_map(function($lang) {
	    $lang = strtoupper($lang);
	}, array('php','python','scala'));
	    
	foreach ($languages as $lang)
	    echo $lang."\n";

> ### 函数式编程特点－不修改状态
>上一点已经提到，函数式编程只是返回新的值，不修改系统变量。因此，不修改变量，也是它的一个重要特点。
在其他类型的语言中，变量往往用来保存"状态"（state）。不修改变量，意味着状态不能保存在变量中。函数式编程使用参数保存状态，最好的例子就是递归。下面的代码是一个将字符串逆序排列的函数，它演示了不同的参数如何决定了运算所处的"状态"。

看到第二个例子中的 `array_map` 的第一个参数，他就是传说中的匿名函数，顾名思义，就是声明一个没有名称的函数，可能一些同学会比较陌生。我们稍微介绍下：

### 匿名函数

在计算机编程中，匿名函数（英语：anonymous function）是指一类无需定义标识符（函数名）的函数或子程序，普遍存在于多种编程语言中。（来源 wikipedia）

> ### PHP.NET 中匿名函数定义
> 中文：匿名函数（Anonymous functions），也叫闭包函数（closures），允许 临时创建一个没有指定名称的函数。最经常用作回调函数（callback）参数的值。当然，也有其它应用的情况。
> 
> 英文：Anonymous functions, also known as closures, allow the creation of functions which have no specified name. They are most useful as the value of callback parameters, but they have many other uses.
> 
> 之所以引用维基，是因为本人认为 **PHP** 官方的描述有误，匿名函数和闭包属于不同概念，而维基说的描述更为准确，**闭包是由函数和与其相关的引用环境组合而成的实体**。

来看个简单的例子：

	function add($a, $b)
	{
		return $a + $b;
	}
	
	echo add(1, 2);
	
匿名函数的等价实现：

	$add = function($a, $b) {
		return $a + $b;
	};
	
	echo $add(1, 2);

为什么要聊匿名函数？现在先看一下，FP 的一个特性

> ### 函数式编程特点－函数是"第一等公民"
> 
> 所谓"第一等公民"（first class），指的是函数与其他数据类型一样，处于平等地位，可以赋值给其他变量，也可以作为参数，传入另一个函数，或者作为别的函数的返回值。

由于匿名函数的实现，使得 **PHP** 更加容易将函数作为一样来传递。

谈到匿名函数，就不得不谈一谈闭包了。

### 闭包和延迟加载

在计算机科学中，闭包（Closure）是词法闭包（Lexical Closure）的简称，是引用了自由变量的函数。这个被引用的自由变量将和这个函数一同存在，即使已经离开了创造它的环境也不例外。所以，有另一种说法认为闭包是由函数和与其相关的引用环境组合而成的实体。闭包在运行时可以有多个实例，不同的引用环境和相同的函数组合可以产生不同的实例。

	$closure = function($a, $b) {
		return function() use ($a, $b) {
			return $a+$b;
		};
	};
	
	$adder = $closure(1, 5);
	$result = $adder();

### 偏函数应用

	$add5 = function(b) use ($add) {
		return $add(5, b);
	};

### 递归和尾递归

### Map, Reduce && Filter 的简单用法

Mapper:

	$result = array();
	foreach ($data as $row) {
		$reuslt[] = $row[0];
	}
	
	$result = array_map(function($row) {
		return $row[0];
	}, $data);
	
Reducer:

	$sum = 0;
	foreach ($data as $row) {
		$sum += $row[0];
	}
	
	$sum = array_reduce($data, function($tmp, $row) {
		return $tmp+$row[0];
	}, 0);
	
Filter:

	$result = array();
	foreach ($data as $row) {
		if ($row > 0) $result[] = $row;
	}
	
	$result = array_filter($data, function($row) {
		return $row[0] > 0;
	});
	
	
> 参考： 
> 
> 	* [阮一峰的网络日志-函数式编程初探](http://www.ruanyifeng.com/blog/2012/04/functional_programming.html)
> 	* [Functional Progamming With Python](http://kachayev.github.io/talks/uapycon2012/#/14)
> 	* [DrupalCon Review: Functional Programming](http://drupal.cocomore.com/blog/drupalcon-review-functional-programming)
	