---
layout: post
title: "Swift 趣味编程"
description: ""
category: swift
tags: [swift]
---
{% include JB/setup %}

> 译自: [Fun with Swift](http://joearms.github.io/2016/01/04/fun-with-swift.html?utm_source=hackernewsletter&utm_medium=email&utm_term=fav#experiment0)

我不知道怎么开始。它可以追溯到我的上一个火鸡节休假，甚至更早之前。

我在对自己说：“我将尝试使用 emacs 和 swift REPL 做一个图形界面“ － 我开始 Google （），并在 [Swift from the command line](https://forums.developer.apple.com/thread/5137) 发现一些令我吃惊的东西。“jen” 给出了些代码，如下图：

	#!/usr/bin/swift  
	
	import WebKit  
	let application = NSApplication.sharedApplication()  
	application.setActivationPolicy(NSApplicationActivationPolicy.Regular)  
	let window = NSWindow(contentRect: NSMakeRect(0, 0, 960, 720),
	                      styleMask: NSTitledWindowMask | NSClosableWindowMask |
	                                 NSMiniaturizableWindowMask,
	                      backing: .Buffered, `defer`: false)  
	window.center()  
	window.title = "Minimal Swift WebKit Browser"  
	window.makeKeyAndOrderFront(window)  
	class WindowDelegate: NSObject, NSWindowDelegate {  
	    func windowWillClose(notification: NSNotification) {  
	        NSApplication.sharedApplication().terminate(0)  
	    }  
	}  
	let windowDelegate = WindowDelegate()  
	window.delegate = windowDelegate  
	class ApplicationDelegate: NSObject, NSApplicationDelegate {  
	    var _window: NSWindow  
	    init(window: NSWindow) {  
	        self._window = window  
	    }  
	    func applicationDidFinishLaunching(notification: NSNotification) {  
	        let webView = WebView(frame: self._window.contentView!.frame)  
	        self._window.contentView!.addSubview(webView)  
	        webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: "https://forums.developer.apple.com/thread/5137")!))  
	    }  
	}  
	let applicationDelegate = ApplicationDelegate(window: window)  
	application.delegate = applicationDelegate  
	application.activateIgnoringOtherApps(true)  
	application.run() 
	
我目光停留在一个名叫 **browser.swift** 文件上，并在命令行上执行了 `swift browser.swift`, 并弹出窗口：

	![browser image](http://joearms.github.io/images/browser.png)

后面，我发现和 [http://practicalswift.com/](http://practicalswift.com/) 的更多解释中代码很相似。

我的第一个反应就是 “天啦－Swift 也许可以用”，并且我被深深吸引了。我曾经读到过 **Swift** 是一种函数式编程语言，它再次打动了我。

在我的下一周中，我发现 **Swift** 并不是纯函数式编程，但是整体上比 **Object-C** 好太多了。首先，他有 RELPL，我可以脱离我讨厌的 **Xcode** 进行编程。 我使用喔嘴亲爱的老朋友 **emacs**（它的命令已经牢记在我心中了）。

## 在美好的老时光，我们是如何编写图形界面的？

很久很久以前，**GUI** 只是一个带着一些按钮和文本的窗口而已。当你点一按钮的时候，文本发生改变。在古代，我们很容易被逗乐。

写一个创建 **GUI** 的程序真的很简单。我写一写代码，像下面这样：

	window = make_window(Width, Height, Title)
	b1 = make_button(window, X, Y, Width, Ht, Label)
	e1 = make_entry(window, X, Y, Width, Ht)
	l1 = make_label(window, X, Y, Width, Ht)
	b1.onclick = function
	                X = read(e1)
	                write(l1, X)
	             end
	
我使用最喜欢的编辑，把它保存在一个名叫 *my_gui.bas* 的文件中，并说出咒语：

	> basic my_gui.bas
	
然后，我的妻子，孩子，猫猫狗狗以及所有的邻居都为这魔法般的 **GUI** 欢欣雀跃。

我已经调用了这个程序，所有我们要做的就是算出对象中的位置和标签，然后把它写到代码中。

时光飞逝，现在的工具被设计成辅助编写遮掩过的代码，因为计算这该死的小按钮的坐标太困难了。只需要拖拽洁面就可以计算出坐标，我们可以为用户提供各种各样的挂件库－不仅仅是按钮和文本实体，而是滑块或者时间选择挂架，以及只有上帝才是他们做什么的选择器。

用来编写 **GUI** 的语言也变得异常复杂，操作挂件的可用函数不计其数，甚至没人可以全部记住他们。

因此我们开发一个一体化的 IDEs，隐藏成千上万个的命令，并提供成百上千的挂件，帮助用户构建令人惊奇的闪亮界面。

但是工具变得原来越臃肿到不稳定的地步，并且新手几分钟就能构建界面的简单方式从此就消失了。

我是个怀旧的程序员。我喜欢去了解我写的每一行代码。我喜欢在文本编写程序和研究它的输出。

> 这一次，我尝试使用 **Swift** 构建一个老式界面

构建 GUI 的所有代码必须在一个单一的 **Swift** 文件中，这样我们可以在终端启动它。我只使用 **Apple** 的 **Swift** 编译器，**Emacs** 和 **Make**。

我是 **Swift** 和 **Cocoa** 的新手－我在文章中问了一些问题，我希望你们中谁都到可以解答下这些问题。所有的源码都在线上，因此你可以给我推送请求（pull request）或者在文章底部评论。

另一个目的就是简化或者精华程序，如果你想要删除一些你觉得无关紧要的代码，或者添加解释，请告诉我。

简洁的表达不是首要目的－如果冗长的代码比异常简洁的代码更清晰的话，我偏向于冗长。这个目的就是清晰透明正确的代码和编码模式更容易拓展和再生产。

为了帮助你导航，你可以直接跳到相应的代码中，或者通读全文：

## 第一部分 - 基本函数

* [实验1 - 不是真的窗口]()
* [实验2 - 一个最小的窗口]()
* [实验3 - 一个指定大小和标题的窗口]()
* [实验4 - 一个带按钮的窗口]()
* [实验5 - 一个带文本字段的窗口]()
* [实验6 - 一个图片窗口]()

## 第二部分 - 抽象

* [参数命名的官样文章（gobbledygook）]()
* [整合他们]()

## 第三部分 - 理念

* [像函数式编程语言一样使用 Swift]()
* [我为什么使用文本而不是 XCode]()
* [参考文献]()

程序已将在 **OS X Yosemite** 系统下 **XCode 7.2** 和 **Swift 2.1** 测试通过。

美衣个程序都是一个单文件，如 `experiment1.swift`，`experiment2.swift` 等等。

源码可以在[这里](https://github.com/joearms/joearms.github.com/_posts/swift)找到 。

## 运行和编译例子

在终端中运行的命令：

	swift experiment<K>.swift
	
编译例子的命令：

	switftc -o experiment<K> experiment<K>.swift
	
将以生成一个叫 `experiment<K>` 可执行的文件
