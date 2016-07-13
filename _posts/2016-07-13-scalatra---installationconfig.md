---
layout: post
title: "Scalatra: 安装端口配置"
description: ""
category: Scala
tags: [scalatra]
---
{% include JB/setup %}

发现对于新手来说，配置都挺蛋疼，所以还是写一篇博客备忘下。

### 我的环境

* Ubuntu Linux 16.04-64bit
* Java 1.7.0_80
* Scala 2.10.4
* sbt 0.13.7
* Gitter8 0.6.8
* scalatra_version 2.4.1

### 第一步：安装 Gitter8

**Gitter8** （后面简称 **G8**）是用来生成发布在 **github** 中的项目模版的命令行工具，即脚手架（Skeleton）。它由 **Scala** 实现，通过 **sbt** 运行，但是可以用于任何用途。

安装 **G8** 之前需要安装 **Conscript**：

	$ curl https://raw.githubusercontent.com/foundweekends/conscript/master/setup.sh | sh
	
确保安装完，把执行路径添加到 `path` 中，这边安装的默认路径是： `~/.conscript`。

> Conscript 项目地址： https://github.com/foundweekends/conscript

现在正是安装 **G8**：

	$ cs foundweekends/giter8
	
### 第二步：安装 Scalatra

	$ g8 scalatra/scalatra-sbt
	organization [com.example]:
	name [My Scalatra Web App]:
	version [0.1.0-SNAPSHOT]:
	servlet_name [MyScalatraServlet]:
	package [com.example.app]:
	scala_version [2.11.8]: 2.10.4
	sbt_version [0.13.11]: 0.13.7
	scalatra_version [2.4.1]:
	
	Template applied in ./my-scalatra-web-app
	
### 第三步：配置端口和开关服务器

#### 修改端口

由于 **Scalatra** 默认使用的端口号是 `8080`，而这个端口（这个端口挺常见的，很用 app 都是用它，发生冲突也稀疏寻常）已经被我的其它应用占用了，所以我要修改，首先先看看生成的目录结构：

	.
	├── project
	│   ├── build.properties
	│   ├── build.scala
	│   └── plugins.sbt
	├── README.md
	├── sbt
	└── src
	    ├── main
	    │   ├── resources
	    │   │   └── logback.xml
	    │   ├── scala
	    │   │   ├── com
	    │   │   │   └── example
	    │   │   │       └── app
	    │   │   │           ├── MyScalatraServlet.scala
	    │   │   │           └── MyScalatraWebAppStack.scala
	    │   │   └── ScalatraBootstrap.scala
	    │   └── webapp
	    │       └── WEB-INF
	    │           ├── templates
	    │           │   ├── layouts
	    │           │   │   └── default.jade
	    │           │   └── views
	    │           │       └── hello-scalate.jade
	    │           └── web.xml
	    └── test
	        └── scala
	            └── com
	                └── example
	                    └── app
	                        └── MyScalatraServletSpec.scala
	                        
这些都是由 **G8** 生成的，现在我们要修改 `project/build.scala`，首先要引入两个包，我是追加到第 8 行后：

	8: import com.earldouglas.xwp.JettyPlugin.autoImport._
	9: import com.earldouglas.xwp.ContainerPlugin.autoImport._

然后，修改默认端口，如果已经插入上述两个包则你可以追加到第 48 行：	48: },	// 后面都好需要我们添加
	49: containerPort in Jetty := 8090  // 改变端口
	
#### 开启和关闭服务器

	$ sbt
	[info] Loading project definition from /tmp/my-scalatra-web-app/project
	[info] Updating {file:/tmp/my-scalatra-web-app/project/}my-scalatra-web-app-build...
	[info] Resolving org.fusesource.jansi#jansi;1.4 ...
	[info] Done updating.
	[info] Compiling 1 Scala source to /tmp/my-scalatra-web-app/project/target/scala-2.10/sbt-0.13/classes...
	[info] Set current project to My Scalatra Web App (in build file:/tmp/my-scalatra-web-app/)
	> jetty:start		// 启动服务器
	[warn] Scala version was updated by one of library dependencies:
	[warn]  * org.scala-lang:scala-library:(2.10.0, 2.10.4, 2.10.3) -> 2.10.6
	[warn] To force scalaVersion, add the following:
	[warn]  ivyScala := ivyScala.value map { _.copy(overrideScalaVersion = true) }
	[warn] Run 'evicted' to see detailed eviction warnings
	[info] Compiling Templates in Template Directory: /tmp/my-scalatra-web-app/src/main/webapp/WEB-INF/templates
	...
	2016-07-13 21:05:15.173:INFO:oejs.ServerConnector:main: Started ServerConnector@516368e1{HTTP/1.1}{0.0.0.0:8090}
	// 上一行，你就可以看到你使用的端口号
	2016-07-13 21:05:15.173:INFO:oejs.Server:main: Started @4245ms
	> jetty:stop	// 关闭服务器
	[info] waiting for server to shut down...
	[success] Total time: 0 s, completed 2016-7-13 21:06:34
	
#### 如何持续编译？

如果你在开发过程中，尤其在调试的时候，如果代码修改后可以自动编译并重启服务，不很方便吗？

	$ sbt
	...
	> ~jetty:start
	...
	[info] starting server ...
	[success] Total time: 0 s, completed 2016-7-13 20:28:22
	1. Waiting for source changes... (press enter to interrupt)

这个功能是不是很人性化。

。。。终于可以愉快地开始开发 **Scalatra**。
	
	