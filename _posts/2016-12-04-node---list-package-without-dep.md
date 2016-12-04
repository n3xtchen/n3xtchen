---
layout: post
title: "Node - 查看自己安装的包"
description: ""
category: Node 
tags: [npm]
---
{% include JB/setup %}

如果以为只是简简单单的 `npm list -g` ，那你就 too young too simple。

发现查看 **Node** 的时候，都是一溜一大串的列表，这些信息感觉一点用都没有，和 **ES** 回调地狱一般，哪个 Package 不依赖几个包，而安装的时候却不取引用其他包装过的依赖，

看看我的安装的包，我只装了 `http-server`，但是查看我的安装包名，天啦，居然有 **289** 行

	➜ ichexw ~ npm list -g | wc -l
	289

这些信息对于我们来说，大部分情况是没用，那我们怎么查看我手动安装的，而不包含它们自行安装的依赖：

	➜ ichexw ~ npm list -g --depth 0
	/usr/local/lib
	├── http-server@0.9.0
	└── npm@3.10.9

这是是不是大部分想要看的呢？如果是，你就把它收下吧，我肯定会常用这个命令的。

> 引用自 [StackOverflow - How to list npm user-installed packages?](http://stackoverflow.com/questions/17937960/how-to-list-npm-user-installed-packages)