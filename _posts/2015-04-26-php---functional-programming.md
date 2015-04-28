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

### 匿名函数（Lambda）

> Wikipedia 上的定义
>
> 在计算机编程中，**匿名函数**（英语：anonymous function）是指一类无需定义标识符（函数名）的函数或子程序，普遍存在于多种编程语言中。

先从简单的开始，先来看看匿名函数。

来看个简单的例子：

    $func = function ($a){
        echo $a;
    };

    $func('n3xtchen');
    
这个例子定义了一个输出指定字符串的匿名函数。

	class Someclass
	{
	    public $value = '2015';
	
	    public function foo()
	    {
	        echo "foo is called\n";
	    }
	
	    public function run()
	    {
	        $func = function () {
	            return $this->value;
	        };
	        $res = $func();
	        echo $res . "\n";
	        $this->foo();
	    }
	}
	
	$test = new Someclass();
	$test->run();

可以看到类内定义的匿名函数式可以用$this来访问类的成员变量和方法。这个特性在PHP5.4以后的版本都支持。

为什么要聊匿名函数？现在先看一下，FP 的一个特性

> ### 函数式编程特点－函数是"第一等公民"
> 
> 所谓"第一等公民"（first class），指的是函数与其他数据类型一样，处于平等地位，可以赋值给其他变量，也可以作为参数，传入另一个函数，或者作为别的函数的返回值。

匿名函数式使得这个特性得到实现，看看高阶函数，一眼便知

### 高阶函数（Higher Order Function）

高阶函数：所谓高阶函数就是函数当参数，把传入的函数做一个封装，然后返回这个封装函数。现象上就是函数传进传出，就像面向对象对象满天飞一样。

在函数中把**匿名函数返回**，并且调用它:

	function getPrintStrFunc() {
	    $func = function( $str ) {
	        echo $str;
	    };
	    return $func;
	}
	
	$printStrFunc = getPrintStrFunc();
	$printStrFunc( 'some string' );

把匿名函数**当做参数传递**，并且调用它:

	function callFunc( $func ) {
	    $func( 'some string' );
	}
	
	$printStrFunc = function( $str ) {
	    echo $str;
	};
	callFunc( $printStrFunc );
	
讲完了匿名函数就不得不讲讲闭包了

### 闭包（Closure）

> Wikipedia 上的定义
>
> 在计算机科学中，**闭包**（Closure）是词法闭包（Lexical Closure）的简称，是引用了自由变量的函数。这个被引用的自由变量将和这个函数一同存在，即使已经离开了创造它的环境也不例外。所以，有另一种说法认为闭包是由函数和与其相关的引用环境组合而成的实体。闭包在运行时可以有多个实例，不同的引用环境和相同的函数组合可以产生不同的实例。

> ### PHP.NET 中匿名函数定义
> 中文：匿名函数（Anonymous functions），也叫闭包函数（Closures），允许 临时创建一个没有指定名称的函数。最经常用作回调函数（callback）参数的值。当然，也有其它应用的情况。
> 
> 英文：Anonymous functions, also known as closures, allow the creation of functions which have no specified name. They are most useful as the value of callback parameters, but they have many other uses.
> 
> 之所以引用维基，是因为本人认为 **PHP** 官方的描述有误，匿名函数和闭包属于不同概念，而维基说的描述更为准确，**闭包是由函数和与其相关的引用环境组合而成的实体**。

先来看一个例子

    $bind = 3;
    $closure = function ($arg) use($bind){
        return $arg + $bind;
    };
    echo $closure(4);

如上面的例子，我们用关键字 `use` 来捆绑变量。**PHP 中的捆绑默认是前期绑定(early binding)**。这意味着匿名函数接受到的值是函数定义时该变量的值。**我们也可以用引用来传递变量，并以此来实现后期绑定(late binding)**。看看下面的例子:

	$time = "morning!\n";
	
	$func = function() use(&$time){
	    echo "good " . $time;
	};
	
	$func();
	
	$time = "afternoon!\n";
	$func();

### 偏函数应用和函数加里化

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
> * [深入理解PHP之匿名函数](http://www.laruence.com/2010/06/20/1602.html)
> * [PHP闭包（Closure）初探](http://www.cnblogs.com/melonblog/archive/2013/05/01/3052611.html)
> * [PHP中的函数式编程](http://ashitaka.me/2014/03/12/functional-programming-in-php/)
> * [谈PHP 闭包特性在实际应用中的问题](http://www.phpv.net/html/1703.html)
> * [DrupalCon Review: Functional Programming](http://drupal.cocomore.com/blog/drupalcon-review-functional-programming)
> * [阮一峰的网络日志-函数式编程初](http://www.ruanyifeng.com/blog/2012/04/functional_programming.html)
> * [Functional Progamming With Python](http://kachayev.github.io/talks/uapycon2012/)
> * [CoolShell-函数式编程](http://coolshell.cn/articles/10822.html)

    
