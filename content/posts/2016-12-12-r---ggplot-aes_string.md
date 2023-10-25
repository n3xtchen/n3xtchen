---
categories:
- R
date: "2016-12-12T00:00:00Z"
description: ""
tags:
- ggplot2
title: GGplot2 - 参数化与 aes_string
---

我们先来看一段代码：

	library(ggplot2)
	set.seed(100)
	d.sub <- diamonds[sample(nrow(diamonds), 500),]
	ggplot(data=d.sub, aes(x=carat,y=price)) + 
		geom_point()
	
这是一段非常简单的 ggplot 绘图代码，是绘制的数据是钻石。当时如果我们想看钻石其他参数之间的关系，比如切面与价格，需要修改：

	aes(x=cut, y=price)
	
粗看没什么问题，只是这么简单，但是如果你实现了一个模型，里面的特征特别多，你总不会每次想看其他特征，都要修改代码，这显然不科学，所以我们以传参的形式，把上面的代码改成如下：

	# filename: demo.R
	# Usage: Rscript demo.R "cut:x" "price:y"
	library(ggplot2)
	set.seed(100)
	d.sub <- diamonds[sample(nrow(diamonds), 500),]

	args <- commandArgs(T)

	x = args[1]
	y =  args[2]

	ggplot(data=d.sub, aes_string(x=x,y=y))+
	  geom_point()
	  
你注意到了吗？我使用 `aes_string` 替换 `aes`。因为 `Rscript` 传入的参数是字符串，我们要使用字符串映射变量。我可以在终端查看下 `aes_string` 的帮助文档：

	> library("ggplot2")
	> ?aes_string	
	...此处省去无数行...
	Examples:
	
	     # Three ways of generating the same aesthetics
	     aes(mpg, wt, col = cyl)
	     aes_(quote(mpg), quote(wt), col = quote(cyl))
	     aes_(~mpg, ~wt, col = ~cyl)
	     aes_string("mpg", "wt", col = "cyl")
	     
这几种形式是等价，但是如果我们想要参数化，只能使用 `aes_string`。

> ### aes_string 的坑（变量名包含操作符或者语法符号）
> 在使用过程成，如果你的变量名字符串不符合变量命名规则就会出现问题，如
> 
> 		> ggplot(data=d.sub, aes_string(x="cut",y="price(元)"))
> 		Error in eval(expr, envir, enclos) : 没有"price"这个函数
> 
> 比如出现操作符或者语法符号都会报类似的错误，怎么办呢？
> 
> 		> ggplot(data=d.sub, aes_string(x="cut",y="`price(元)`"))
> 
> 你只需要在字符两边添加反引号就好了。

今天就是为了备忘这个坑，写了一堆东西。^_^，希望对大家有用！


	
	