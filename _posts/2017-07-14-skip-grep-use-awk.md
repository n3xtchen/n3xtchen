---
layout: post
title: ""
description: "跳过 GREP，使用 AWK"
category: BASH
tags: [bash]
---
{% include JB/setup %}

多年来，我发现肯多人使用下面的模型进行过滤映射（filter-map）:

	ichexw $ [生成数据] | grep something | awk '{print $2}'
	
但是，可以缩写成：

	ichexw $ [生成数据] | awk '/something/'
	
它隐含着打印匹配的正则表达式。

为什么我喜欢这么做呢？

有如下四个原因：

* 更少的输入
* 更少的进程
* `awk` 默认使用现代的正则表式，就像 `grep -E`
* 配合其他 awk 命令使用

### “grep -v” 也是可以的

`awk` 可以模拟 `grep` 的反向选择的，但是不是个好主意：

	ichexw $ [生成数据] | awk '/something/ {next} 1'
	
* 这样子很丑
* 比 `grep` 命令长
* 这到底是干什么用的，完全看不懂 -- 这需要对 `awk` 命令更深入的了解.

当然，你还可以这么做：

	ichexw $ [生成数据] | awk '! /something/'
	
这样看起来就好多了。

> 引用自：[SKIP grep, use AWK](http://blog.jpalardy.com/posts/skip-grep-use-awk/)