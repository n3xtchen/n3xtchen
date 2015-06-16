---
layout: post
title: "PHP：浅谈函数式编程（一）"
description: ""
category: 
tags: []
---
{% include JB/setup %}

思考一下这个程序的输出结果

	<?php
    $languages = array('php','python','scala');
    
    foreach ($languages as &$lang)
        $lang = strtoupper($lang);
        
    foreach ($languages as $lang) {
    	// notice NO reference here!
        echo $lang."\n";
    }
    ?>

答案是：

    PHP
    PYTHON
    PYTHON

哈哈，不错的一道面试题目！这里很明显，我想讲的就是副作用。

作为 FP 的鼓吹者，我今天从黑 `foreach` 开始讲起（Sorry，`foreach` ^_^）。

	<?php
    $languages = array('php','python','scala');
    
    array_map(function (&$lang) {
        $lang = strtoupper($lang);
    }, $languages);
        
    foreach ($languages as $lang) {
        echo $lang."\n";
    }
    ?>
        
使用 **map** 的结果是才是你预期的，因为 `array_map` 遵循函数式编程的特性，无副作用！如果想知道**map** 算法的实现，参考 [使用 python - 实现 Map，Filter 以及 Reduce](http://n3xtchen.github.io/n3xtchen/python/2014/08/12/python---mapfilterreduce/)，其中揽括了 **MapReduce** 和 **Filter** 的递归实现！

所有的循环都可以通过递归来实现。

> ### 函数式编程特点－没有"副作用"
> 
> 所谓"副作用"（side effect），指的是函数内部与外部互动（最典型的情况，就是修改全局变量的值），产生运算以外的其他结果。函数式编程强调没有"副作用"，意味着函数要保持独立，**所有功能就是返回一个新的值，没有其他行为，尤其是不得修改外部变量的值。**

上面的那个例子是违反函数编程特性，虽然避免的副作用，但是它修改了变量的状态，应该这样：

	<?php
    $languages = array_map(function ($lang) {
        $lang = strtoupper($lang);
    }, array('php','python','scala'));
        
    foreach ($languages as $lang) {
        echo $lang."\n";
    }
    ?>

> ### 函数式编程特点－不修改状态
> 
>上一点已经提到，函数式编程只是返回新的值，不修改系统变量。因此，不修改变量，也是它的一个重要特点。
在其他类型的语言中，变量往往用来保存"状态"（state）。不修改变量，意味着状态不能保存在变量中。函数式编程使用参数保存状态，最好的例子就是递归。下面的代码是一个将字符串逆序排列的函数，它演示了不同的参数如何决定了运算所处的"状态"。

看到第二个例子中的 `array_map` 的第一个参数，他就是传说中的匿名函数，顾名思义，就是声明一个没有名称的函数，可能一些同学会比较陌生。我们稍微介绍下：

### 匿名函数（Lambda）

在计算机编程中，**匿名函数**（英语：anonymous function）是指一类无需定义标识符（函数名）的函数或子程序，普遍存在于多种编程语言中。（来源于 Wikipedia）

先从简单的开始，先来看看匿名函数。

来看个简单的例子：

	<?php
	# hi_lambda.php
    $hi_lambda = function ($name) {
        echo "Hello, $name!";
    };

    $hi_lambda('n3xtchen');		# 打印 Hello,  n3xtchen!
    ?>
    
不过和其他语言的匿名函数相比，可能就会觉得 **PHP** 太丑了，下面 **javascript** 的实现

	(function(name){
	  console.log('Hello,'+name+'!');
	})('n3xtchen');
	
	// $ node hi_lambda.js
	// Hello,n3xtchen!
    
现在，看一下匿名函数在类中的使用：

	<?php
	class LambdaClass
	{
	    public $value = '2015';
	
	    public function foo()
	    {
	        echo "foo is called\n";
	    }
	
	    public function run()
	    {
	        $access_attr = function () {
	        	＃ 类中的匿名函数可以访问类本身
	            return $this->value;
	        };
	        $res = $access_attr();
	        echo "$res\n";
	        $this->foo();
	    }
	}
	
	$test = new LambdaClass();
	$test->run();
	# 打印: 
	# 	2015
	# 	foo is called	
	?>

> **注意**：
> 
> 在类内定义的匿名函数式可以用 `$this` 来访问类的成员变量和方法；但是只有 **PHP5.4** 以后的版本才支持。
>
> 这样子真的方便了很多，我们公司现在使用的 5.3，想在匿名函数中调用本类，还用使用 `use`，可蛋疼了。

讲完了匿名函数就不得不讲讲闭包了

### 闭包（Closure）

在计算机科学中，**闭包**（Closure）是词法闭包（Lexical Closure）的简称，是引用了自由变量的函数。这个被引用的自由变量将和这个函数一同存在，即使已经离开了创造它的环境也不例外。所以，有另一种说法认为闭包是由函数和与其相关的引用环境组合而成的实体。闭包在运行时可以有多个实例，不同的引用环境和相同的函数组合可以产生不同的实例。(来自维基)

先来看一个例子
	
	<?php
	$bind = 3;
	
	$closure = function ($arg) use ($bind) {
	    return $arg + $bind;
	};
	
	var_dump($closure(4));
	
	?>

如上面的例子，我们用关键字 `use` 来捆绑变量。**PHP 中的捆绑默认是前期绑定(early binding)**。这意味着匿名函数接受到的值是函数定义时该变量的值。**我们也可以用引用来传递变量，并以此来实现后期绑定(late binding)**。看看下面的例子:

	<?php
	$time = "morning!\n";
	
	$late_binding = function() use (&$time) {
	    echo "good $time";
	};
	
	$func();
	$time = "afternoon!\n";
	$func();
	
	?>

> ### PHP.NET 中匿名函数定义
> 中文：匿名函数（Anonymous functions），也叫闭包函数（Closures），允许 临时创建一个没有指定名称的函数。最经常用作回调函数（callback）参数的值。当然，也有其它应用的情况。
> 
> 之所以引用维基，是因为本人认为 **PHP** 官方的描述是有误，匿名函数和闭包属于不同概念，而维基说的描述更为准确，**闭包是由函数和与其相关的引用环境组合而成的实体**。

### 函数式编程特点－函数是"第一等公民"

所谓"第一等公民"（first class），指的是函数与其他数据类型一样，处于平等地位，可以赋值给其他变量，也可以作为参数，传入另一个函数，或者作为别的函数的返回值。

### 函数式编程特点－高阶函数（Higher Order Function）

**高阶函数**：所谓高阶函数就是函数当参数，把传入的函数做一个封装，然后返回这个封装函数。现象上就是函数传进传出，就像面向对象编程，对象满天飞一样。

在函数中把 **匿名函数返回**，并且调用它:

	<?php
	function return_func() {
	    return function () {
	        echo "返回一个函数！";
	    };
	}
	
	$get_return_func = return_func();
	$get_return_func();
	
	?>

把匿名函数 **当做参数传递**，并且调用它:

	function callFunc( $func ) {
	    $func('some string');
	}
	
	$printStrFunc = function ($str) {
	    echo $str;
	};
	
	$printStrFunc();

### 函数式编程特点－偏函数应用

**偏函数应用** 指的是固化函数的一个或一些参数，从而产生一个新的函数。

	<?php
    function log($level, $message)
    {
        echo "$level : $message";
    }

    log("Warning", "this is one warning message");
    log("Error", "this is one error message");
    
    ?>

使用和匿名函数和偏函数应用改写下：

	<?php
    $logWarning = function ($message) { log("Warning", $message); };
    $logError   = function ($message) { log("Error", $message); }

    $logWarning("this is one warning message");
    $logError("this is one error message");
    
    ?>
    
虽然现在粗看，没有任何好处，反而代码更多了。这里说说偏函数应用的两个好处：

1. 当你多次调用一个函数的时候，发现很多参数都是固定的，那你可以考虑使用偏函数；
2. 你会不会发现固定参数之后，给新函数一个更可读的名称，让你更容易维护他；

现在看一个例子：



 
   
### 函数式编程特点－函数加里化

**函数加里化（Currying）** 指的是将一个具有多个参数的函数，转换成能够通过一系列的函数链式调用，其中每一个函数都只有一个参数。

    function sum3($x, $y, $z)
    {
        return $x + $y + $z;
    }
    
    function curried_sum3($x)
    {
        return function ($y) use ($x) {
            return function ($z) use ($x, $y) {
                return sum3 ($x, $y, $z);
            };
        };
    }
    
    $f1 =  curried_sum3(1);
    $f2 = $f1(2);
    $result = $f2(3);
  
偏函数和Currying有什么用？主要就是从能一个通用函数得到更特定的函数。有一些编程经验的，一定都手工写过偏函数应用吧。
Currying提供了另外一种实现方式。这种方式在函数式编程中更常见。函数式编程思想，不仅在Lisp这样的函数式编程语言中，在更多的语言中也得到了实现和发展，像Python，Javascript乃至C#这样的命令式语言(imperative language)。所以有机会不妨考虑下使用Currying，能否更好地解决问题。

### 递归和尾递归

在计算机科学里，尾调用是指一个函数里的最后一个动作是一个函数调用的情形：即这个调用的返回值直接被当前函数返回的情形。这种情形下称该调用位置为尾位置。若这个函数在尾位置调用本身（或是一个尾调用本身的其他函数等等），则称这种情况为尾递归，是递归的一种特殊情形。尾调用不一定是递归调用，但是尾递归特别有用，也比较容易实现。

	function factorial($n)
	{
		if($n == 0) {
	        return 1;
	    }   
	    return factorial($n-1) * $n; 
	}
	 
	var_dump(factorial(100));

即便代码能正常运行，只要我们不断增大参数，程序迟早会报错：

	Fatal error:  Allowed memory size of … bytes exhausted

为什么呢？简单点说就是递归造成了栈溢出。按照之前的思路，我们可以试下用尾递归来消除递归对栈的影响，提高程序的效率。

	function factorial($n, $acc)
	{
	    if($n == 0) {
	        return $acc;
	    }
	    return factorial($n-1, $acc * $n);
	}
	
	var_dump(factorial(100, 1));

XDebug同样报错，并且程序的执行时间并没有明显变化。

	Fatal error: Maximum function nesting level of '100' reached, aborting!

PHP如何消除递归

	function factorial($n, $accumulator = 1) {
	    if ($n == 0) {
	        return $accumulator;
	    }
	
	    return function() use($n, $accumulator) {
	        return factorial($n - 1, $accumulator * $n);
	    };
	}
	
	function trampoline($callback, $params) {
	    $result = call_user_func_array($callback, $params);
	
	    while (is_callable($result)) {
	        $result = $result();
	    }
	
	    return $result;
	}
	
	var_dump(trampoline('factorial', array(100)));

现在XDebug不再警报效率问题了。

注意到trampoline()函数没？简单点说就是利用高阶函数消除递归。

还有很多别的方法可以用来规避递归引起的栈溢出问题，比如说Python中可以通过装饰器和异常来消灭尾调用，让人有一种别有洞天的感觉。
        
> 参考： 

> * [PHP中的函数式编程](http://ashitaka.me/2014/03/12/functional-programming-in-php/)
> * [DrupalCon Review: Functional Programming](http://drupal.cocomore.com/blog/drupalcon-review-functional-programming)
> * [阮一峰的网络日志-函数式编程初](http://www.ruanyifeng.com/blog/2012/04/functional_programming.html)
> * [Functional Progamming With Python](http://kachayev.github.io/talks/uapycon2012/)
> * [CoolShell-函数式编程](http://coolshell.cn/articles/10822.html)
> * 匿名函数和闭包
> 	* [深入理解PHP之匿名函数](http://www.laruence.com/2010/06/20/1602.html)
> 	* [PHP闭包（Closure）初探](http://www.cnblogs.com/melonblog/archive/2013/05/01/3052611.html)
> 	* [谈PHP 闭包特性在实际应用中的问题](http://www.phpv.net/html/1703.html)(GOOD)
> * 偏函数应用和函数加里化
> 	* [Currying vs. Partial Application](http://allthingsphp.blogspot.com/2012/02/currying-vs-partial-application.html)(GOOD)
> 	* [Currying in PHP](http://kingfisher.nfshost.com/sw/curry2/)(GOOD)
> 	* [Request for Comments: Currying](https://wiki.php.net/rfc/currying)
> 	* [matteosister/php-curry](https://github.com/matteosister/php-curry/blob/master/tests/Cypress/Curry/functions_test.php)
> 	* [偏函数应用(Partial Application）和函数柯里化(Currying)](http://www.cnblogs.com/cypine/p/3258552.html)
> * 递归和尾递归
> 	* [漫谈递归：PHP里的尾递归及其优化](http://www.nowamagic.net/librarys/veda/detail/2334)(GOOD)
> 	* [尾调用](http://zh.wikipedia.org/wiki/%E5%B0%BE%E8%B0%83%E7%94%A8)
> 	* [说说尾递归](http://www.cnblogs.com/catch/p/3495450.html)



    
