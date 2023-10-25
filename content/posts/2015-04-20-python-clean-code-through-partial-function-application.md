---
categories:
- Python
date: "2015-04-20T00:00:00Z"
description: ""
tags:
- Python
- functional
title: Python - 偏函数应用让你的代码看起来更简洁
---

偏函数应用（Partial Function Application）听起来名字就很吸引人；它的作用是在函数调用前，预先固定参数的方法。它的机制有点粗糙，学术的解释有点古板，但是它很有用。如果你的函数需要 `x` 和 `y` 两个参数，实现把 `x` 参数固定了，后续调用只需要传入 `y` 即可，来看一个例子：

	# -*- coding: utf-8 -*-
	
	import functools
	
	def adder(x, y):
	    return x + y
	
	# 执行它
	assert adder(1, 1) == 2
	assert adder(5, 5) == 10
	assert adder(6, 2) == 8
	
	# 把 y 的参数固定
	add_five = functools.partial(adder, y=5)
	
	# 现在 加上 5
	# x =1, y =5
	assert add_five(1) == 6
	# x =5, y =5
	assert add_five(5) == 10
	# x =2, y =5
	assert add_five(2) == 7
	
坦白说，这个例子并没什么用处，但也不是一无是处。至少它很好展示了偏函数应用的用法。但是并没有告诉你为什么要用它，或者哪里能使用它。当你开始使用函数开始编写程序的时候，你很难从这个例子来想象他的使用场景。

这就是我为什么写这篇博客原因。我想要尝试不一样的方式。因为其他人已经把偏函数应用的实现机制都写烂了，我将跳过这个部分，旨在阐述它的应用场景。我们通过案例学习；每个案例的讲解都会通过逐步重构来有效应用偏函数。

### 案例1 - 重构特定领域表达式

我经常使用编写任务匹配的应用；如追踪 URL，查找制定循环，在日志文件中寻找模式。这类的任务，会慢慢变的臃肿，最终会失去控制。

导致这个问题的罪魁祸首就是正则表达式。没有任何的警惕，给予足够的时间，和不断增多的 “呃，你还能找到。。。” 方式请求，它很快就让你陷入不可维护代码的深坑。比如：

	for text in lines:
        if re.search(‘[a-zA-Z]\=’, text):
            some_action(text)
        elif re.search(‘[a-zA-Z]\s\=’, text):
            some_other_action(text)
        else:
            some_default_action()
	     
当我们需要快速实现的时候，这样看起来没什么问题。然后，几周之后再来看这段代码，我已经看不懂这代码中正则表达式的含义了。因此，是时候开始重构了。第一步就是拨出不合理的部分，利用良好命名的函数来替换我们的正则表达式：
	
	def is_grouped_together(text):
        return re.search("[a-zA-Z]\s\=", text)
	
	def is_spaced_apart(text):
        return re.search(“[a-zA-Z]\s\=”, text) 
	
	def and_so_on(text):
        return re.search(“pattern_188364625", text)
	
	for text in lines:
        if is_grouped_together(text):
            some_action(text)
        elif is_spaced_apart(text):
            some_other_action(text)
        else:
            some_default_action()
	     
这个看起来好多了，对于我来说。实际上，在每个模块里只做了一件事情。然而，这个实际包含了无数的搜索路由；因此，在完成这次重构的之前，需要对函数进行微妙的调整。我们重构他的时候只有一到两个帮助函数，一旦你拥有一堆的函数，那看起来就没现在这么好了。

这个问题的核心是所有的这些小函数只是为我的正则表达式提供一个可读的名称而已，但是目前的实现使得当前模块变的杂乱。实际的工作都在 `re.search` 上。我的所想要的是基于领域的版本。幸运的是，偏函数应用帮我做到这个：

	def my_search_method():
        is_spaced_apart = partial(re.search, '[a-zA-Z]\s\=')
        is_grouped_together = partial(re.search, '[a-zA-Z]\=')
        ...

        for text in lines:
            if is_grouped_together(text):
                some_action(text)
            elif is_spaced_apart(text):
                some_other_action(text)
            else:
                some_default_action()

现在我们得到一个很好的描述和可读性的代码。我们使用偏函数应用的预填充来处理 `re.search`，使我们获得了一个针对我们领域具有描述性的控制结构，由于他们的定义很密集，这两个方法都是两个查询函数，我把它们封装到一个函数体内，避免污染当前模块的命名空间。

### 案例2 - 使用偏函数构建伪对象继承

关于偏函数应用简洁代码的最好方法之一，就是创建一个简单的伪对象继承结构，但是不附带明确的子类模版。当你有一个对象，需要通过不同的参数来定制它的行为，那偏函数应用就变得很有用。

先看一段丑陋的代码：

	def do_complicated_thing(request, slug):
        if not request.is_ajax() or not request.method == 'POST':
            return HttpResponse(json.dumps({'error': 'Invalid Request'}, content_type="application/json", status=400)

        if not _has_required_params(request):
            return HttpResponse(
                json.dumps({'error': 'Missing required param(s): {0}'.format(_get_missing(request)),
                content_type="application/json", 
                status=400)
            )
        try:
            _object = Object.objects.get(slug=slug)
        except Object.DoesNotExist:
            return HttpResponse(json.dumps({'error': 'No Object matching x found'}, content_type="application/json", status=400)
        else:
            result = do_a_bunch_of_stuff(_object)
            if result: 
                HttpResponse(json.dumps({'success': 'successfully did thing!'}, content_type="application/json", status=200)   
            else: 
                return HttpResponse(json.dumps({'error': 'Bugger!'}, content_type="application/json", status=400)    
	      
这个是我用来处理一些异步请求的代码。虽然看过去不是非常的可怕，但是真的厌恶其中一些东西。首先，每一个 `HttpResponse` 实例都使用同一个 `content_type`。接着，我们的实际响应数据都要通过 `json.dumps()` 来处理。最后，大部分的 `status_code` 都是相同的，只有一个例外。总的来说，最大的问题时，很多东西出现在密度这么大的代码中，只有很小的一部分与代码的实际意图相关。它隐藏在整个执行流程里。

因此，带着这些问题，我又开始重构。我想要一个结构，让我们通过关联上下文的方式展示我的当前任务。简而言之，就是我想要 `HttpResponse` 映射流程中的实际操作。我想用它来描述 Json 响应。

#### 第一步－没有 partial 的偏函数应用
	
	JsonResponse = lambda content, *args, **kwargs: HttpResponse(
        json.dumps(content),
        content_type="application/json",
        *args, **kwargs
	)
	
这一步有点不同，我们没有使用 `functools.partial` 来实现偏函数应用。是因为我们需要用 `json.dumps()` 处理 `content`，而 `functools.partial` 不好实现。不过，原理还是相同的。我们都是进行参数预填充。

#### 重构

	def do_complicated_thing(request, slug):
        if not request.is_ajax() or not request.method == 'POST':
            return JsonResponse({'error': 'Invalid Request'}, status=400)

        if not _has_required_params(request):
            return JsonResponse({'error': 'Missing required param(s): {0}'.format(_get_missing(request)), status=400)
        try:
            _object = Object.objects.get(slug=slug)
        except Object.DoesNotExist:
            return JsonResponse({'error': 'No Object matching x found'}, status=400)
        else:
            result = do_a_bunch_of_stuff(_object)
            if result: 
                JsonResponse({'success': 'successfully did thing!'}, status=200)   
            else: 
                return JsonResponse({'error': 'Bugger!'}, status=400)
          
简洁多了吧！我使用新创建的 `JsonResponse` 替代所有的 `HttpResponse`。现在我们不仅有很好描述的调用格式，还多亏了把 `json.dumps()` 抽离出来，我们现在可以传递一个字典作为参数，使得接口更加的简洁。虽然已经很好了，但是我们可以继续进一步更有趣的优化。现在我们可以通过纯函数式的实现，创建小型的伪类继承关系！让我们编写一些可能产生的响应类型。

    JsonResponse = lambda content, *args, **kwargs: HttpResponse(
        json.dumps(content),
        content_type="application/json",
        *args, **kwargs
	)
	
	JsonOKResponse         = functools.partial(JsonResponse, status=200)
	JsonCreatedResponse    = functools.partial(JsonResponse, status=201)
	JsonBadRequestResponse = functools.partial(JsonResponse, status=400)
	JsonNotAllowedResponse = functools.partial(JsonResponse, status=405)
	
注意，这些偏函数建立在我们之前的基础上。他是一个偏函数应用的偏函数应用。下面是我们的伪类继承关系：

	HttpResponse 
	   | 
	   |-- JsonResponse 
	           | 
	           | - JsonBadRequestResponse 
	           | - JsonOKResponse
	           | - JsonCreatedResponse
	           | - JsonOKResponse

#### 最后的重构

	def do_complicated_thing(request, slug):
        if not request.is_ajax() or not request.method == 'POST':
            return JsonBadRequestResponse({'error': 'Invalid Request'})

        if not _has_required_params(request):
            return JsonBadRequestResponse({'error': 'Missing required param(s): {0}'.format(_get_missing(request)))
        try:
            _object = Object.objects.get(slug=slug)
        except Object.DoesNotExist:
            return JsonBadRequestResponse({'error': 'No Object matching x found'})
        else:
            result = do_a_bunch_of_stuff(_object)
            if result: 
                JsonOKResponse({'success': 'successfully did thing!'})   
            else: 
                return JsonBadRequestResponse({'error': 'Bugger!'})

就这样了。一组简单的描述工具都内置了通过偏应用程序编写的基本对象。

### 结语

偏函数应用；奇特的名字；简单的想法。作为函数式编程最重要的概念之一，偏函数应用通过固定参数的方式使得代码更加可读，调用更加简便了。永远告别冗长的参数表。当你一次又一次的使用它的时候，即使很简单绑定参数的方式也会带来很大的可读性差异。

> 参考：[Cleaner Code Through Partial Function Application](http://chriskiehl.com/article/Cleaner-coding-through-partially-applied-functions/)
