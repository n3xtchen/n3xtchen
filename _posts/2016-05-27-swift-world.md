---
layout: post
title: "Swift World - 基础入门"
description: ""
category: Swift
tags: [ios, Swift]
---
{% include JB/setup %}

作为 **Swift** 初学者（高手绕行），暂时让 **iOS** 和 **Mac Os**（洗完这篇文章的时候，Os X 已经更名了） 编程见鬼去；所以，一开始就不使用 `XCode` 作为演示工具，直接使用 **Swift** 的 REPL 来进行演示，让我们一起 focus 语言本身。

前提，你需要安装 **Xcode** (从 **App Store **中下载)以及它的 **Command-Line-Tools**, 这样你就可以直接打开终端：

	$ swift
	Welcome to Apple Swift version 2.2 (swiftlang-703.0.18.8 clang-703.0.30). Type :help for assistance.
	  1> print("Hello, world")
	Hello, world

这里我们可以看到，**Swift** 的当前版本为 **2.2**。

这样, 我们就可以开始探索我们的 **Swift World** 

## 什么是 Swift

Swift是一種支持多编程范式和編譯式的編程語言，是用來撰寫 **Mac OS**，**iOS** 和**Watch OS** 的语言之一，但是可能在不久的将来也可能作为 **Linux** 的界面开发程序。

## 语句（Statement）和注释（comment）

	  1> print("Statement")	// 这就是一条语句
	Statement
	
在 **Swift** 中，换行符代表一条语句的结束。当然和其他大多数语言一样，分号也可以用来表示一条语句的结束，而且当你想在一行中编写多个语句，那么分号将必不可少：

	  2> print("Hello"); print("World");
	Hello
	World	
	
你注意到第一条语句后面的双斜杠了吗？这就是注释（comment），双斜杠的意义就是告诉你，注释从这里开始，编译器将忽略后面到行末的内容。

作为个老猿，还是要唠叨下，良好的注释行为是程序员的美德之一。
 
## var 和 let
	 
`var`, 故名思意，会变化的量；该变量存储的值是可以变化：
	 
	1> var x = 1
	x: Int = 1
	2> x = 2
	3> x
	$R0: Int = 2
	
`let`, 与 `var` 相对立的，常量（constant），即不变化的量：

	4> let y = 3
	y: Int = 3
	5> y = 2	// 编译错误
	repl.swift:5:3: error: cannot assign to value: 'y' is a 'let' constant
	y = 2
	~ ^
	repl.swift:4:1: note: change 'let' to 'var' to make it mutable
	let y = 3
	^~~
	var
	
这里，我们还看到的 **Swift** 的错误提示还是很友好的，还给出了修改建议。

但你尝试修改常量的时候，编译器将无法通过。

## 数据类型

**Swift** 最吸引的的特点之一就是它的类型系统嘛！静态、強类型、类型推论；这意味着当你声明一个变量或常量时，它的类型在后续的操作中时不可以改变，否则将无法编译通过：

	  3> var x = 1
	x: Int = 1
	  4> x = "1"
	repl.swift:4:5: error: cannot assign value of type 'String' to type 'Int'
	x = "1"
	    ^~~
	    
## 变量声明 
	   
声明数据类型的格式：

	var|let 变量名 : 变量类型 [= 变量值]
	
来看一个实际的例子：

	var num : Int = 1
	
这里我们声明一个名为 `num` 的整型变量。

## 操作符（Operator）

作为程序，加减乘除是基本功能，那就像从算数操作符（Arithmetic operations）谈起：

	  1> 1 + 1
	$R0: Int = 2
	  2> 2 - 1
	$R1: Int = 1
	  3> 2 * 3
	$R2: Int = 6
	  4> 4 / 2
	$R3: Int = 2
	  5> 5 % 3
	$R4: Int = 2

太简单，不知道怎么解释，所以直接上代码。

### 位运算（bitwise operations）


	let initialBits: UInt8 = 0b00001111
	let invertedBits = ~initialBits  // equals 11110000
	
	let firstSixBits: UInt8 = 0b11111100
	let lastSixBits: UInt8  = 0b00111111
	let middleFourBits = firstSixBits & lastSixBits  // equals 00111100
	
	let someBits: UInt8 = 0b10110010
	let moreBits: UInt8 = 0b01011110
	let combinedbits = someBits | moreBits  // equals 11111110
	
	let firstBits: UInt8 = 0b00010100
	let otherBits: UInt8 = 0b00000101
	let outputBits = firstBits ^ otherBits  // equals 00010001
	
	let shiftBits: UInt8 = 4   // 00000100 in binary
	shiftBits << 1             // 00001000
	shiftBits << 2             // 00010000
	shiftBits << 5             // 10000000
	shiftBits << 6             // 00000000
	shiftBits >> 2             // 00000001

### 对比表达式（comparison operators）：

	1 == 1	// true
	2 ~= 1	// true
	1 < 2	// true
	2 <= 2	// true
	3 > 2	// true
	3 >= 4	// false
	

### 逻辑表达式

	var zhen : Bool = true
	var jia : Bool = false
	zhen && zhen // 真 与 真 ＝> true
	zhen && jia  // 真 与 假 => false
	jia && jia  // 假 与 假  => false
	jia && zhen // 假 与 真  => false
	zhen || jia // 真 或 假  => true
	jia || zhen // 假 或 真  => true
	!zhen       // 非 真     => false
	!jia        // 非 假     => true

### 范围(Range)

先来看几个例子：
	
	  1> for index in 1...5 {
	  2.     print("\(index) times 5 is \(index * 5)")
	  3. }
	1 times 5 is 5
	2 times 5 is 10
	3 times 5 is 15
	4 times 5 is 20
	5 times 5 is 25
	  4> let names = ["Anna", "Alex", "Brian", "Jack"]
	names: [String] = 4 values {
	  [0] = "Anna"
	  [1] = "Alex"
	  [2] = "Brian"
	  [3] = "Jack"
	}
	  5> let count = names.count
	count: Int = 4
	  6> for i in 0..<count {
	  7.     print("Person \(i + 1) is called \(names[i])")
	  8. }
	Person 1 is called Anna
	Person 2 is called Alex
	Person 3 is called Brian
	Person 4 is called Jack
	
总结下：

* `a...b`: `a` 与 `b` 的区间内，包含 `a` 和 `b`
* `a..<b`: `a` 与 `b` 的区间内，包含 `a`, 但不包含 `b`，我在想这可能是作者为了方便操作数组而设计
	    
## 内置的数据类型

每一个变量，每一个常量，都需要一个类型。所以我们先从基础数据类型入手，同时介绍这些类型的实例方法（instance method），全局方法（global method）以及操作符。


### 数字（Number）

`Int` 和 `Double` 是 **Swift** 最主要的数值类型；另外你还可以使用 **C** 和 **Object-C** 的数值类型。

	  1> Int.min
	$R0: Int = -9223372036854775808
	  2> Int.max
	$R1: Int = 9223372036854775807
	  3> let x = 10
	x: Int = 10
	  1> let pi = 3.14159
	pi: Double = 3.1415899999999999
	  2> let anotherPi = 3 + 0.14159
	anotherPi: Double = 3.1415899999999999

整型的取值范围在 `Int.min` 和 `Int.max` 之间。

在 **Swift** 中，你可以使用多种形式来编写整型：

	  1> let decimalInteger = 17
	decimalInteger: Int = 17
	  2> let binaryInteger = 0b10001	// 17 的二进制形式
	binaryInteger: Int = 17
	  3> let octalInteger = 0o21	// 17 的八进制形式
	octalInteger: Int = 17
	  4> let hexadecimalInteger = 0x11	// 17 的十六进制形式
	hexadecimalInteger: Int = 17

对于十进制的来说，可以使用如下方式来表示科学计数：

* 3e2: 3 x 10的2次方, 即 300
* 3e-2: 3 x 10的-2次方, 即 0.03
* 1.25e2: 1.25 x 102, 即 125.0
* 1.25e-2: 1.25 x 10-2, 即 0.0125

还可以使用千分位：

	  8> let oneMillion = 1_000_000
	oneMillion: Int = 1000000

对于十六进制的来说，可以使用如下方式来表示：

* 0xFp2: 15 x 2的2次方, 即 60.0
* 0xFp-2: 15 x 2的-2次方, 即 3.75

> https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-ID309

### 字符串（String）

在 **Swift** 中，字符串是有双引号包裹的字画量。

	  1> let greeting = "hello"
	greeting: String = "hello"
	  2> let greeting_2 = 'hello'
	repl.swift:2:18: error: single-quoted string literal found, use '"'
	let greeting_2 = 'hello'
	                 ^~~~~~~
	                 "hello"
	                 
在很多其他语言中，字符串可以使用单双引号包裹；但是，在 **Swift** 中不行，只能用双引号，双引号，双引号。

另外，**Swift** 的字符串使用的 **Unicode**；作为最先进的语言，怎么可能不用 **Unicode**，现在还有很多语言默认采用的是 ASCII，对非英语国家来说，多痛苦啊！

	  2> let checkmark = "\u{21DA}"	// /u{}
	checkmark: String = "⇚"
	
反斜杆（`\`）作为转移符，意思是说接下来的一个字符将被特殊处理：举几个栗子：

* \n: 代表换行
* \t: 代表制表符
* \": 转移双引号，不至于被当作字符串的结尾。
* \\: 转移自己，如果你想打印个反斜杠的话

#### 字符串插值（string interpolation）

先看一个栗子：

	  3> let n = 5
	n: Int = 5
	  4> let s = "U hava \(n) widgets."
	s: String = "U hava 5 widgets."
	
`\(var_name)` 这样就可以把 `var_name` 这个值替换到字符串中了，即使这个变量不是字符串类型的。

当然了，插值不仅仅只是变量，还可以是表达式，方法调用等等：
	  5> let m = 6
	m: Int = 6
	  6> let s = "U hava \(n+m) widgets."
	s: String = "U hava 11 widgets."

另外，在 **Swift 2.0** 插值中可以使用双引号（在旧版中是不允许的）：

	  7> let s = "U hava \(greeting + "n3xtchen") widgets."
	s: String = "U hava hellon3xtchen widgets."
	
#### 字符串合并

最简单的方式，就是使用 `+`：

	  1> let s = "Hello"
	s: String = "Hello"
	  2> let s2 = "World"
	s2: String = "World"
	  3> let greeting =  s + s2
	greeting: String = "HelloWorld"
	
使用 `+=` 追加字符串：

	  1> var s = "Hello "
	s: String = "Hello "
	  2> let s2 = "World"
	s2: String = "World"
	  3> s += s2
	  4> s
	$R0: String = "Hello World"
	  5> let exclamationMark: Character = "!"
	exclamationMark: Character = "!"
	  6> s.append(exclamationMark)
	  7> s
	$R1: String = "Hello World!"
		
注意，`append` 方法的参数只能是字符型，不能是字符串。

#### 索引或下标(subscript)

这个是我感觉最蛋疼的API，好端端的整型不用，用什么结构体索引。。。既然入坑，也要讲讲：

	s[下标]	// 这里的下标是一个专门的结构体，不能使用整型

首先是下标操作：

	  1> let s = "hey you!!"
	x: String = "hey you!!" 
	  2> s.startIndex
	$R1: Index = {
	  _base = {
	    _position = 0	// 这个就是当前的位置
	    _core = {
	      _baseAddress = 0x00000001004fe620 __lldb_expr_1.x : Swift.String + 32
	      _countAndFlags = 9	// 这个是下标的总长度
	      _owner = nil
	    }
	  }
	  _lengthUTF16 = 1
	}
	  3> s.endIndex	// 字符串的最后一个字符的索引好
	$R2: Index = {
	  _base = {
	    _position = 9	// 注意这里
	    _core = {
	      _baseAddress = 0x00000001004fe620 __lldb_expr_1.x : Swift.String + 32
	      _countAndFlags = 9
	      _owner = nil
	    }
	  }
	  _lengthUTF16 = 0
	}
		
字符串的索引都是这样的结构，只是其中的 `_position` 和`core._countAndFlags` 发生的变化，表示偏移量，下面是字符串索引的相关函数:
	
* successor(): successor, 下一任，故名思义，当前索引的后一个
* predecessor()：predecessor，前任，当前索引的前一个
* advancedBy(n)：从当前索引向后 n 个字符

它们本身也是返回索引的结构。

栗子时间：

	  1> let s = "hey you!!"
	s: String = "hey you!!"
	  2> s[s.startIndex]
	$R0: Character = "h"
	  3> s[s.endIndex]
	fatal error: Can't form a Character from an empty String
	Execution interrupted. Enter code to recover and continue.
	Enter LLDB commands to investigate (type :help for assistance.)
	  4> s[s.endIndex.predecessor()]
	$R1: Character = "!"
	  5> s[s.startIndex.advancedBy(3)]
	$R2: Character = " "
	  6> s[s.endIndex.predecessor().predecessor()]
	$R3: Character = "!"

虽然设计有点蛋疼，但是也挺好理解的。

#### 插入和删除

	  1> var welcome = "hello"
	welcome: String = "hello"

在尾部追加一个感叹号：	

	  2> welcome.insert("!", atIndex: welcome.endIndex)
	  3> welcome
	$R0: String = "hello!"

在尾部的感叹号前插入 ` there` 字符：
	
	  4> welcome.insertContentsOf(" there".characters, at: welcome.endIndex.predecessor())
	  5> welcome
	$R1: String = "hello there!"

删除最后一个字符:	

	  6> welcome.removeAtIndex(welcome.endIndex.predecessor())
	$R2: Character = "!"
	  7> welcome
	$R3: String = "hello there"
	
范围删除：	
	
	  8> let range = welcome.endIndex.advancedBy(-6)..<welcome.endIndex
	range: Range<Index> = {
	  startIndex = {
	    _base = {
	      _position = 5
		  ...
	  }
	  endIndex = {
	    _base = {
	      _position = 11
		  ...
	  }
	}
	  9> welcome.removeRange(range)
	 10> welcome
	$R4: String = "hello"
	
`..<` 这个表达式大家应该还有印象吧？不记得的，见操作符的部分。
	
字符操作方法有点多，这里做一个小结：

* 在某个位置插入字符串
	* `s.insert("要插入的的字符串", atIndex: /* 这里插入的位置，字符索引 */)`
	* `s.insertContentsOf(/* 这里是一个字符数组 */, at: /* 这里插入的位置，字符索引 */)`
* 删除一个字符:
	* `s.removeAtIndex(/* 这里插入的位置，字符索引 */)`
* 删除字符串: 
	* `s.removeRange(/* 这里插入的位置，字符索引范围 */)`
* 在尾部追加字符串：
	* `s.append(c: Character)`
	* `s.appendContentsOf(/* 字符串或者字符数组 */)` 
* 替换:	
	* `s.replaceRange(/* 这里插入的位置，字符索引范围 */, with: /* 字符串或者字符数组 */)`

#### 字符串对比

	  1> welcome == "Hello World!"
	$R1: Bool = true
	  2> welcome.hasPrefix("Hel")	// 前缀匹配
	$R2: Bool = true
	  3> welcome.hasSuffix("orld!")	// 后缀匹配
	$R3: Bool = true
	  4> welcome.characters.contains("e")	// 包含某个字母
	$R4: Bool = true

### 布尔型（Bool）

首先来看看布尔型的对象类型（实际上是个 struct），它只有两个值：`true` 和 `false`。

	var selected : Bool = true

至于用法，在表达式的部分已经讲了，不记得可以回头看下。

## 结余

这是我的第一个 **Swift** 分享。为了让初学者更容易看懂，写的挺纠结的，希望大家看起来不揪心就好，^_^。


	

