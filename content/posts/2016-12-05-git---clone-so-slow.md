---
categories:
- Git
date: "2016-12-05T00:00:00Z"
description: ""
tags: []
title: Git - 拉取（Git Clone）代码太慢了
---

有时候，我需要从 **Github** 上克隆一个超级大的代码项目，我发现获取的数据超级慢（Kb/s）。

对于快速克隆，我有两个诀窍：

* 杀掉命令，重试一边。这么做几次后，看看是不是会的到一个快一点的连接。这个在大部分情况下，是有效的。
* 先获取最新修改版本，然后获取剩下的：

		ichexw → git clone --depth=1 git@github.com:n3xtchen/hello-world.git
		ichexw → cd hello-world
		ichexw → git fetch --unshallow

> 参考： [Slow speed on git clone](https://codeyarns.com/2016/01/12/slow-speed-on-git-clone/)