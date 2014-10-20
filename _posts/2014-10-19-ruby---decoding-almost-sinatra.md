---
layout: post
title: "Ruby - 解读 Almost Sinatra"
description: ""
category: Ruby 
tags: [Ruby, sinatra]
---
{% include JB/setup %}

> Science! true daughter of Old Time thou art! <Br />
> Who alterest all things with thy peering eyes.  <Br />
> Why preyest thou thus upon the poet's heart, <Br />
> Vulture, whose wings are dull realities?
> 
> — Edgar Allen Poe

在 2010 年，[Konstantin Haase](https://github.com/rkh)，Sinatra 的首席开发，使用 Ruby 中所有混淆的代码精简技巧，编写了一个他所能写的最小的 web 框架。它就是后来的 [Almost Sinatra](https://github.com/rkh/almost-sinatra)，一个与 Sinatra 相互兼容的框架，代码仅有 `999 B` ，总共 6 行。
	
它是一个令人印象深刻的壮举；下面是 **Almost Sinatra** 的全部代码：
	
	%w.rack tilt date INT TERM..map{|l|trap(l){$r.stop}rescue require l};$u=Date;$z=($u.new.year + 145).abs;puts "== Almost Sinatra/No Version has taken the stage on #$z for development with backup from Webrick"
	$n=Module.new{extend Rack;a,D,S,q=Rack::Builder.new,Object.method(:define_method),/@@ *([^\n]+)\n(((?!@@)[^\n]*\n)*)/m
	%w[get post put delete].map{|m|D.(m){|u,&b|a.map(u){run->(e){[200,{"Content-Type"=>"text/html"},[a.instance_eval(&b)]]}}}}
	Tilt.mappings.map{|k,v|D.(k){|n,*o|$t||=(h=$u._jisx0301("hash, please");File.read(caller[0][/^[^:]+/]).scan(S){|a,b|h[a]=b};h);v[0].new(*o){n=="#{n}"?n:$t[n.to_s]}.render(a,o[0].try(:[],:locals)||{})}}
	%w[set enable disable configure helpers use register].map{|m|D.(m){|*_,&b|b.try :[]}};END{Rack::Handler.get("webrick").run(a,Port:$z){|s|$r=s}}
	%w[params session].map{|m|D.(m){q.send m}};a.use Rack::Session::Cookie;a.use Rack::Lock;D.(:before){|&b|a.use Rack::Config,&b};before{|e|q=Rack::Request.new e;q.params.dup.map{|k,v|params[k.to_sym]=v}}}
	
出于对探索黑暗语言艺术的渴望，我认为我应该一句一句弄透 **Almost Sinatra**，弄清楚 Konstantin 使用的相关技术。我希望这么做的同时不“驱散彩虹（unweaving the rainbow）”，不摧毁象征主义诗歌般、深奥而富有意义的代码所蕴含的美感；通俗点讲，就是既要尊重他的艺术工作，又要对代码斟言酌句。

## 设置

事不宜迟，让我们从脚本的第一个语句开始：

    %w.rack tilt date INT TERM..map{|l|trap(l){$r.stop}rescue require l};

这里已经有些语法相当的陌生，尤其对于 **Ruby** 新手来说；因此，让我们重新格式化它们，使其表述得稍微清楚一点：

	%w{rack tilt date INT TERM}.map do |l|
	  trap(l) do
	    $r.stop
	  end rescue require l
	end	

这是节省空间（space-saving）的基本技巧之一：你可以使用 `%w` 来创建一个字符数组；可以写成我们最常见的样子：

	["rack", "tilt", "date", "INT", "TERM"]

… 也可以写成这样：

	%w{rack tilt date INT TERM}
	
你可以使用任何你喜欢的字符作为分隔符（delimiters）；Konstantin 使用了 `.`，不过我们一般会使用各式各样的括号（如 `[]`，`()`，`{}`）来包围数组。

这里还展示了另一个技巧就是循环（loops）的复用。两个事情需要在脚本的开始实现：第一，**Almost Sinatra** 的依赖（Dependencies）需要被载入（`require`）；第二，你需要告诉 Ruby 要捕捉（trap）的信号（signals）。我们的程序需要不做两种信号：一个是 `SIGINT`（当你在终端执行 `CTRL` + `C` 时，信号将被发送。），另一个是 `SIGTERM`（进程被杀死的时候，信号将被发送。）。

这需要两步来完成：遍历依赖，并载入（`require`）；遍历要捕捉的信号，并传递给 `trap` 方法。但是当空格都是一种奢侈的情况下，两次循环同样很奢侈。

因此，我们见识了如下技巧：脚本把 `"rake"`，`"tilt"` 和 `"date"` （它们都不是信号）传递给捕捉器（trap）。如果我们把不是信号的对象传递给 `trap` 会发生什么？我们使用 REPL 查看下：

	2.1.1 :001 > trap("rack") {}
	ArgumentError: unsupported signal SIGrack
	from (irb):1:in `trap'
	
数组中的前三个元素都会触发 `ArgumentError` 异常。`rescue`， 当使用它来修饰这一行的时候，将会恢复所有的异常；因此，为了代替捕捉信号，脚本通过 `rescue` 调用 `require` 来加载它们。Bingo：一个循环完成两个目的。

`trap` 中的实际句柄（handler）将会明确地中止服务。后续，我们将会讨论 `$r` 到底是什么；当它被确切创建之前：还有很长的路，先走在说：

	$u=Date;
	
An even simpler statement for number two, but an important concept: here, a constant that’s used multiple times in the script is assigned to a one-letter variable. Although this seems like it might be a waste, the characters are made up if it’s even used once or twice more — or even quicker, if the constant has a particularly long name.
这个语句再简单不过，但是这里有一个很重要的概念：将一个常量被赋予一个单字符变量中，后续将会被使用多次。虽然它看起来像多余的，如果它只被使用一次或两次 －甚至更多次，如果一个常量有特别长的名字，那字符数就被省下来了。

	$z=($u.new.year + 145).abs;

这里是个有趣的技术。`$z` 用来作  **Sinatra** 的端口号；具体实现是，`Date.new.year` 被调用（它永远返回 `-4712`，年的默认值）；加上 145，就是 －4567；最后，符号将会被 `abs` 忽略，剩下的 `4567` - Sinatra 默认的端口。

当然，它和下面的语句效果是相同：

	$z=4567

貌似这样精简加以[被拒绝](https://github.com/rkh/almost-sinatra/commit/2d5d38b4349231e2c9eb7238137f06bced59c1c2)了，舌头长在别人身上（爱怎么讲就怎么讲），原因是不鼓励使用魔法数字（[magic numbers](http://c2.com/cgi/wiki?MagicNumber)）； it seems that sometimes even the principles of Golf can play second fiddle to the church of DRY.似乎有时高尔夫法则也可以像 DRY 的教堂法则那样影响开发。

	puts "== Almost Sinatra/No Version has taken the stage on #$z for development with backup from Webrick"

一个简单的 `puts` 语句，它也包含一个精简技巧：如果你想要访问标记的变量（全局变量以 `$` 开头，以及实例变量以 `@` 开头），你不需要在插入操作中使用花括号。下面是常见的用法：

	@foo = "bar"
	$foo = "bar"
	puts "@foo is #{@foo} and $foo is #{$foo}"

也可以写成：

	@foo = "bar"
	$foo = "bar"
	puts "@foo is #@foo and $foo is #$foo"
	
为了节省关键的两个字符，牺牲了可读性。

## 主逻辑

	$n=Module.new
	
第一行结束了，大部分用于配置；现在我们将接触到大量的逻辑（logic）。定义一个包含 Sinatra 相关的功能的模块（module）。

	extend Rack;
	
Rack 被混合（Mix）到这个模块中；这样你就可以不用使用命名空间来调用 Rack 中的方法；接着使用 `Rack::Builder` 来创建应用，它提供 `map` 方法（使用它作为 Sinatra 路由的一种节省空间做法）。

	a,D,S,q=Rack::Builder.new,Object.method(:define_method),/@@ *([^\n]+)\n(((?!@@)[^\n]*\n)*)/m

在这个批量赋值的语句中包含了很多东西；但是如果它们分开来的话，就简单很多。

首先，初始化一个 `Rack::Builder` 新实例被初始化，并赋给 `a`：

	a = Rack::Builder.new
	
（`a` 就是 `app`。）

然后，创建一个快捷方式。这个脚本后续将动态定义多个方法，因此，使用  `D` 作为 `define_method` 的别名后续将会节省一堆的字符：

	D = Object.method(:define_method)
	
严格来说，由于 Ruby 不允许我们把函数作为值来传递，因此它是被设置成 `define_method` 的[方法对象](http://ruby-doc.org/core-2.0.0/Object.html#method-i-method)（method object）;但是在实际上，它们很相似的。这个快捷方式定义之后，`D.call(*) {}` 就等同于 `define_method(*) {}`。

最后，S 被设置成用来解析 Sinatra 内置模版的需要的正则表达式：

	S = /@@ *([^\n]+)\n(((?!@@)[^\n]*\n)*)/m
	
## 处理请求

	%w[get post put delete].map{|m|D.(m){|u,&b|a.map(u){run->(e){[200,{"Content-Type"=>"text/html"},[a.instance_eval(&b)]]}}}}
	
这里我们开始看到看起来像 “Sinatra” 的元素了：这个代码块（block）创建了一个全局方法，定义了路由（比如，`get “／foo” do`，等等）。让我们格式化它，加上一些别名，以及重命名一些单字符名变量，我们就能看得更清楚点：

	%w{get post put delete}.map do |method|
	  define_method(method) do |path, &block|
	    a.map(path) do
	      run ->(e) { [200, {"Content-Type" => "text/html"}, [a.instance_eval(&block)]] }
	    end
	    
现在看起来更简单点了。对于每一个 HTTP 请求方法（使用 `map` 而不是 `each`，因为可以省一个字符），一个全局方法 —— 都会带一个路径作为他们的第一参数，然后是一个代码块（block）。这些方法使用 `define_method` 快捷方式来定义；除了用 `D.("method_name")` 取代 `D.call("method_name")`， 被使用 —— 因为他的代码更短短，其他不值得一提。你实际上还可以更短，因为`[]` 是 `call` 的别名，可以使用 `D["method_name"]`。

被调用的时候，它将会使用 `Rack::Builder` 的 `map` 方法创建一个方法，追加一个新的路由（route）到 Rack app 中（用来匹配路径）。当被执行的时候，这个句柄将会设定响应状态为 200（“ok”），内容类型是 HTML ，以及代码块返回值的响应体（response body）（使用 `instance_eval` 来关联应用的上下文）。

这个基本上和原生的 Sinatra app 的实现方式一样。

## 解析模版

	Tilt.mappings.map{|k,v|D.(k){|n,*o|$t||=(h=$u._jisx0301("hash, please");File.read(caller[0][/^[^:]+/]).scan(S){|a,b|h[a]=b};h);v[0].new(*o){n=="#{n}"?n:$t[n.to_s]}.render(a,o[0].try(:[],:locals)||{})}}

接下来的一行全部都是关于模版的（templates）；它允许你调用，例如，`haml :foo`，将有一个 foo.haml 的模版作为响应体被渲染（render）。

同样，赋予变量更有意义的名称，令复杂的代码更容易被理解。先从头两句开始：

	Tilt.mappings.map{|k,v|D.(k){|n,*o|$
	
我们可以改写成：

	Tilt.mappings.map do |template_type, constant|
  		define_method(template_type) do |n, *o|
  		
Tilt 是一个用来解析许多不同模版语言的库；常规的 **Sinatra** 也使用它。

对于每一种 Titl 支持的模版语言，这个代码定义一个全局方法（例如，叫做 `erb` 或者 `haml`）。这个方法像下面这样使用：

	$t||=(h=$u._jisx0301("hash, please");File.read(caller[0][/^[^:]+/]).scan(S){|a,b|h[a]=b};h);v[0].new(*o){n=="#{n}"?n:$t[n.to_s]}.render(a,o[0].try(:[],:locals)||{})
	
这个代码的第一部分从当前文件提取内联模版（inline templates），追加到一个哈希数组中。

有趣的事，不像你所想的，使用 `{}` 创建空哈希数组，而是：

	Date._jisx0301("hash, please")
	
`_jisx0301` 是 `Date` 类的半私有（semi-private）方法，它期望一个 JIS X 0301-2002 格式的字符串 —— 在日本使用的一个标准。如果被给予，它将返回所给日期的年，月，日组成的哈希数组；但是如果输入不规范，它将返回一个空哈希数组。因此，传递 “hash, please” 给它可能是生成空哈希数组最诡异的做法之一了 —— 这是另一个和端口号生成代码一样有趣的笑话，还能让代码的最终容量那么笑就足够令人敬佩了。

下一步，提取调用 Sinatra 的代码中的内联模版。我们不能使用 `__FILE__` 来获取实际的执行文件名，因为所指向的文件和调用 **Sinatra** 方法的文件是不同的；同样，也不能使用 `$0`（它指向被执行的脚本）。

因此，它使用了 `caller(0)` 来查看调用栈（call stack）中最新的文件实体，解析出文件名。然后，使用正则表达式扫描（`scan`）提取出所有的内联模版（inline templates）并追加到 `h` 哈希数组中，被记忆在 `$t` 中；这个记忆意味着解析将在一次性执行，而不是每次都被解析。

扩展它，使用更清晰的变量名，下面是我们重写后的：

	$templates ||= begin
	  templates = {}
	  File.read(caller[0][/^[^:]+/]).scan(S) do |template_name, template|
	    templates[template_name] = template
	  end
	  templates
	end
	

接下来，得到解析好的模版：

	v[0].new(*o){n=="#{n}"?n:$t[n.to_s]}.render(a,o[0].try(:[],:locals)||{})

Tilt 允许你指定一种模版类型 —— “erb”，比如 —— 取回需要初始化解析这些模版的类。这个类在 `$v[0]` 中；它被初始化，一个包含模版数据的代码块（block）传递给它。渲染（render）方法将被调用，作为解析好的值传递给应用，任何本地变量被赋值和传递给它（如果没有本地变量，那就传递控哈希数组给它）。

下面这个就相对不太有趣了。

	%w[set enable disable configure helpers use register].map{|m|D.(m){|*_,&b|b.try :[]}};
	
这里定义更多的全局方法；目前为止，我们都在使用 `D.(m)`。但是你可能注意到了，这些方法实际上都是一样的，处理执行传递给它的代码外，什么都不做；这个意味着他们实际上没有什么差别：

	configure do
	  enable :sessions
	end

等同于：

	helpers do
	  enable :sessions
	end

这个和 **sinatra** 实际实现是不同的，但是提供了足够的兼容性。但这也意味着你不能在 **Almost Sinatra** 中的 `configure` 中修改环境变量 —— 就这点代码了，你也不能要求太多了！

	END{Rack::Handler.get("webrick").run(a,Port:$z){|s|$r=s}}

上面是 `END` 代码块（block），这是为了让代码更少而不不使用标准的 `at_exit`；这个的作用是启动 web 服务器。我们看到把服务器实例赋给 `$r` 变量，就是我们在第一行 `trap` 语句看到的那个变量。

 其中使用一些精简技巧：`run` 的第二个参数是一个数组，其中的花括号被省略（完全有效，也确实相当常见）以及 Ruby 1.9 数组语法被使用，这里 `Port: $z` 等同于 `:Port => $z`。
 
	%w[params session].map{|m|D.(m){q.send m}};

定义了 `params` 和 `session` 方法，并被传递给 `q`（它的定义在后面，被设置成请求对象）。你也许已经注意到了，回到第二行，我们看到不对称的赋值语句，4 个变量只有 3 个被赋值：

	a,D,S,q=Rack::Builder.new,Object.method(:define_method),/@@ *([^\n]+)\n(((?!@@)[^\n]*\n)*)/m

这个效果等同于把 `nil` 赋值给 `q`（变量定义了，而不分配任何值给它）。It allows you to scope a variable in two characters, rather than the minimum of three or four you’d need to assign an actual value to it. 它允许你用两个字符界定一个变量，而不是需要最少也要 3 到 4 个字符来给他分配一个实际值。

	a.use Rack::Session::Cookie;a.use Rack::Lock;

**Sinatr**a 引用了 Rack 回话的 `Cookie `，并使用 `Rack::Lock` 来同步请求。

	D.(:before){|&b|a.use Rack::Config,&b};b

定义一个 `before` 方法将逻辑委托给 `Rack::Builder`，调用 `use` 来载入中间件（middleware）。

然后他使用这个 `before` 句柄载入他自己的中间件（middleware）：

	before{|e|q=Rack::Request.new e;q.params.dup.map{|k,v|params[k.to_sym]=v}}}

将新建请求（Request）对象，并分配给 `q`，然后将参数中的键转变成变量（symbol）。

代码到这里就结束了；实际上，你需要 `END` 代码块（block）重新调用服务；但是如果没有后续的脚本，`END` 将会被自动触发启动服务，这样代码又节省了！

That's it；我们的 **Almost Sinatra** 之旅已经结束。我不知道对你是否有帮助，但是我学习了不少东西。我学会如何使用 `Rack::Builder`；动态绑定循环来精简代码；调用方法对象来减少 `method.()` 和 `method.call` 的代码；以及 `"#$foo"` 等同于 `"#{$foo}"`；等等。

但是，不仅仅是学些这些技巧。**Almost Sinatra** 的 Github 页面的开篇：

> Until programmers stop acting like obfuscation is morally hazardous, they’re not artists, just kids who don’t want their food to touch.
>
> 认为混淆是罪恶的程序员不能称为艺术家，仅仅是不许他人动自己食物的小孩罢了。（摘自 [ruby-china](https://ruby-china.org/topics/16166)）

通过阅读这个代码和解构它，我也深有此感触。混沌有时是一种美德：间接影射常常比直率的语句更加强大。但是最重要的是：它真的很有乐趣！

> 译自 https://robm.me.uk/2013/12/13/decoding-almost-sinatra.html

