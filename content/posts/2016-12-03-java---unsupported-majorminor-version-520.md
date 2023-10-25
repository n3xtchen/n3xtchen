---
categories:
- Java
date: "2016-12-03T00:00:00Z"
description: ""
tags:
- java
- scala
title: Java 版本不兼容 - Unsupported major.minor version 52.0
---

如果在编译代码的时候出现：

	XX: Unsupported major.minor version 52.0

说明的使用的 JDK 版本不兼容，52.0 代表就是对应的 Java 版本，下面是常见 java 版本对应的 Code：

* J2SE 8 = 52
* J2SE 7 = 51
* J2SE 6.0 = 50
* J2SE 5.0 = 49
* JDK 1.4 = 48
* JDK 1.3 = 47
* JDK 1.2 = 46
* JDK 1.1 = 45

这时，你需要做的就是下载安装指定版本，并配置你的环境到该版本，重新编译的代码，这是就能够成功编译了。

> 参考自
> 	
> 1. [Unsupported major.minor version 52.0 [duplicate]](http://stackoverflow.com/questions/22489398/unsupported-major-minor-version-52-0)
> 2. [Java_class_file](https://en.wikipedia.org/wiki/Java_class_file)
