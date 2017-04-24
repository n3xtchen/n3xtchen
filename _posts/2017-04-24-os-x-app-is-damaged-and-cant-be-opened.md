---
layout: post
title: "OS X 下安装未验证第三方开发的APP 方法"
description: ""
category: OsX
tags: [osx]
---
{% include JB/setup %}

我尝试打开一个不是从 App Store 下载的应用，系统会报错：

	“App” is damaged and can’t be opened. You should move it to the Trash.
	
解决方法：

打开终端：

	$ sudo spctl --master-disable