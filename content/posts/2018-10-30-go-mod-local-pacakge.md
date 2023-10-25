---
categories:
- Go
date: "2018-10-30T00:00:00Z"
description: ""
tags:
- go
title: Go module 解决本地库依赖问题(更新中。。。)
---

作为伪用户，Go 可谓是当代最反现代的语言（是一种退化），就是有个好爹，吐槽几点：

* 函数不支持默认值
* 有限制的范型
* 不支持多肽
* 不支持重载
* 不支持关键字拓展

没得用，感觉大家都在滥用 `struct` 和 `intereface`，因为只有它能用，论坛上，简直就是万能的解决方案。

Go 程序员们，你们是带着镣铐在编程！

解决依赖上，让我头痛不已。最开始，我是使用 dep。至于为什么用？因为大家都在用。

老实说，还是简化了不少东西，它会自动识别代码中的依赖并提取，帮你安装。是的，作为解决外部依赖的方案，它是个合格的方案。

### 如果内部库的依赖怎么办？

不得不在吐槽下 Go 语言，你丫的，连相对路径依赖都没有，所以代码都要放在 GOPATH 下，文件的层级结构只能写死。 
也就是说你只能在 GOPATH 下开发，感觉我的 "人身自由" 都被限制了。整个人都不好了。

我可是一个崇尚自由的码农。

怎么办呢？

### GO module 横空出事（VGO）

Go 在 1.11 之后，就集成在 go tool 工具链中。如果仅仅是解决外部依赖上，VGO 除了不需要安装，和 DEP 没有太大得区别（其实我更喜欢 dep 这个名字，vgo 这名字太路人）。

dep 的两个文件：

    Gopkg.lock
    Gopkg.toml
    
vgo 的两个文件：

    go.mod
    go.sum

但是，但是 VGO 它支持导入内部库，也就是说，你的可以不必在 GOPATH 开发程序，在运行程序的时候，它帮你注入内部库。

先来看看怎么用！

首先，请确认的 Golang 语言的版本是 1.11 之后

我的版本是 go1.11.2

    ichexw in ~/Dev/go/learning → go version
    go version go1.11.2 darwin/amd64
    ichexw in ~/Dev/go/learning → cho \$GOPATH
    /Users/ichexw/Dev/go
    ichexw in ~/Dev/go/learning → echo \$GOROT
    /usr/local/Cellar/go/1.11.2/libexec/src/vgo-demo/lib
    
看看 go mod 的命令：

	ichexw in ~/Dev/go/learning → go help mod
	Go mod provides access to operations on modules.
	
	Note that support for modules is built into all the go commands,
	not just 'go mod'. For example, day-to-day adding, removing, upgrading,
	and downgrading of dependencies should be done using 'go get'.
	See 'go help modules' for an overview of module functionality.
	
	Usage:
	
		go mod <command> [arguments]
	
	The commands are:
	
		download    download modules to local cache
		edit        edit go.mod from tools or scripts
		graph       print module requirement graph
		init        initialize new module in current directory
		tidy        add missing and remove unused modules
		vendor      make vendored copy of dependencies
		verify      verify dependencies have expected content
		why         explain why packages or modules are needed
	
	Use "go help mod <command>" for more information about a command.


### Go Mod 初始化

	ichexw in ~/Dev/go/learning → mkdir vgo-demo
	ichexw in ~/Dev/go/learning → cd vgo-dem

#### 一、创建自己的库：

	ichexw in ~/Dev/go/learning/vgo-demo → cat lib/hello.go
	
	package lib
	
	import "fmt"
	
	func Hello() {
	    fmt.Print("Hello, Go!")
	}
    
### 二、创建 main.go 文件

    ichexw in ~/Dev/go/learning/vgo-demo → cat main.go
    package main

    import "vgo-demo/lib"
    
    func main() {
        lib.Hello()
    }

### 三、执行程序

    ichexw in ~/Dev/go/learning/vgo-demo > go run main.go
    main.go:3:8: cannot find package "vgo-demo/lib" in any of:
            /usr/local/Cellar/go/1.11.2/libexec/src/vgo-demo/lib (from \$GOROOT)
            /Users/ichexw/Dev/go/src/vgo-demo/lib (from \$GOPATH)
            
报错了，我们来分析下，错误信息告诉我们：main.go 文件的第三行出现错误，无法导入 "vgo-demo/lib"；我们分析下：

    # main.go
    import "vgo-demo/lib"
    
Go 编译器包查找的路径（优先级从下到上）是:

1. *$GOROOT/src*: 标准库所在的位置
2. *$GOPATH/src*: 工作目录

但是，我的项目并不在这两者之一；常规的做法，我把我的项目移到工作目录下：

	ichexw in ~/Dev/go/learning → cp -r vgo-de \$GOPATH/src/
	ichexw in ~/Dev/go/learning → cd \$GOPATH/src/vgo-demo
	ichexw in ~/Dev/go/src/vgo-demo → go run main.go
	Hello, Go!
    
这不是我想要，开发程序更多是分项目，而不是语种

	path/to/dev
	├── proj1
	│   ├── go
	│   └── python
	|   └── ...
	├── proj2
	│   ├── scala
	│   └── go
	|   └── ...
	└── ..
    

这个时候，GOPATH 该怎么设置呢？是不是很为难，而且内部依赖只被所在的项目使用，不存在跨项目调用，我可以这么做：

1. 开发某个项目的时候，手动设置 GOPATH 变量，但是这个也太挫了
2. 把 path/to/dev 设置成 GOPATH，这个我就。。。
  
**个人认为的最佳实践**：

- path/to/go/path/: 设置成 GOPATH，存取通用外部依赖的类库，以及自己开发的跨项目使用的通用类库
- path/to/dev/projN/go: 
  - 某个项目，自用的类库封装，通过 VGO 自行引用
  - 项目依赖的外部类库：vender 下

目录格式如下：

    path/to/gopath # 跨项目依赖类库/工具 
	path/to/projgo/ # 我的 go 项目
	├── main.go
	├── locallib1 # 当前类库1
	|   └── ...
	├── locallib2 # 当前类库2
	|   └── ...
    ├── ... # 其他文件/本地类库
	└── vender # 当前项目依赖的类库





