---
layout: post
title: "Scale - [warn] Class java.time.Duration not found"
description: ""
category: Scala 
tags: [sbt]
---
{% include JB/setup %}


如果你遇上如下错误：

	[info]   Compilation completed in 16.154 s
	[warn] Class java.time.Duration not found - continuing with a stub.
	[warn] Class java.time.Duration not found - continuing with a stub.
	[warn] there were 2 feature warning(s); re-run with -feature for details
	[warn] three warnings found
	[warn] Multiple main classes detected.  Run 'show discoveredMainClasses' to see the list
	
说明你的依赖缺失了，我使用的是 **sbt**， 在依赖列表中添加如下依赖

	"org.joda" % "joda-convert" % "1.2"
	
现在他就不再报错了。


> 参考自： [class-broken-error-with-joda-time-using-scala](http://stackoverflow.com/questions/13856266/class-broken-error-with-joda-time-using-scala)