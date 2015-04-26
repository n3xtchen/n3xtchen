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

### 匿名函数

我们看看 第二个例子中的 `array_map` 的第一个参数，他就是传说中的匿名函数，顾名思义，就是声明一个没有名称的函数，



来看个简单的例子：

	function add($a, $b)
	{
		return $a + $b;
	}
	
	echo add(1, 2);
	
匿名函数形式：

	$add = function($a, $b) {
		return $a + $b;
	};
	
	echo $add(1, 2);

### 闭包和延迟加载

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

### Map, Reduce && Filter

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
	
	