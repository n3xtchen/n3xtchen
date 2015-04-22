---
layout: post
title: "Python - 下划线（_）"
description: ""
category: Python
tags: [Python]
---
{% include JB/setup %}

这张帖子讨论 **Python** 的下划线的使用，讲解下它的大部分使用场景。

### 当个下划线（_）

有三个典型的场景：

1. 在解释器中：`_` 指向交互解释器绘画的最后一次执行语句的结果。最早是 **CPython** 的标准，后续其他的也跟进了。

		>>> _
		Traceback (most recent call last):
		  File "<stdin>", line 1, in <module>
		NameError: name '_' is not defined
		>>> 42
		>>> _
		42
		>>> 'alright!' if _ else ':('
		'alright!'
		>>> _
		'alright!'
	
2. 作为一个名称：跟前一个例子优点相关。`_` 作为一个占位符。它允许下一个人读你代码的时候知道，按惯例，它只是被分配，但是不使用它。例如，你也许不在乎循环计数器的实际值：

		n = 42
		for _ in range(n):
		    do_something()
		    
3. i18n: `_` 也可以作为一个函数来使用。这个场景下，它经常作为多国语言和本地语言的翻译查询。这个实际上源于 C 语言的惯例。例如，你看到 **Django** 中的翻译：

		from django.utils.translation import ugettext as _
		from django.http import HttpResponse
		
		def my_view(request):
		    output = _("Welcome to my site.")
		    return HttpResponse(output)

### 在名称之前的单下划线（例如 _varname）

一个名称前置下划线用来指明它被程序员私有化。它是一种惯例，下一个人使用（或者你自己）的时候，知道前置下划线的名称只供内部使用。看看，**Python** 文档中是怎么定义的：

	一个名称前置了下划线（如 _spam）应该被当作 **API** 中非公共的部分（无论他是函数，方法或者属性）。它都应该考虑一个具体的实现来改变。
	

		    
