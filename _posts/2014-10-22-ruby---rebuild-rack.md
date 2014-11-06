---
layout: post
title: "Ruby - 重构 Rack"
description: ""
category: ruby
tags: [ruby]
---
{% include JB/setup %}

## 前言

**Rack**，**Ruby** 的 **GEM**，是所有 **Ruby** 网页编程相关项目中公认最流行的底层框架了。你的框架可以不断的改变，但是不管你怎么换，你仍然需要使用 **Rack**。**Rack** 之所以如此流行和经久不衰来源是它的灵活特性。作为服务器和 Web 应用之间的中间人角色，**Rack** 只要求你遵循极少的标准，就能得到大量的中间件（Middlewares）支持。在 **Ruby** 的世界了， 它在解构标准方面拥有最大的成就。

对了，今天的主角就是它了，但是不是教你怎么使用它，而是克隆的它。我将一步一步通过用例来克隆一个 **Gem**。这样你即可以熟悉 **Gem** 的工作方式（我也将使用同样的类名和方法名），还可以拥有自己的版本。

**Rack** 经典的 **Hello World** （这里命名为 `config.ru`）：

	run Proc.new { |env| ['200, {'Content-Type' => 'text/html'}, ['hello world]] }
	
现在你执行 `rakeup config.ru`，并使用你的浏览器查看 *localhost:9292*。看似无用，但是 **Rails**，**Sinatra** 以及其他基于 **Rack** 的 Web 应用就是这样在 **Rack** 的基础上，一步步构建起来的。

## 从头开始

因此，现在我将要创建一个属于自己的 **Rack**，它可以做的就是上面 Hello World 的事情。首先，我们需要一个需求清单：

1. 拥有可以接受一个 *.ru* 文件的 `rackup` 命令
2. 在本地启动服务
3. 每个请求都会启动来自我们 *.ru* 文件中的进程
4. 有一个很 cool 的 **Gem** 名

明显，上面最重要的就是第四点，^_^。我将要把我们的 **Rack** 克隆命名为 **Plank**，它听起来比 **Rack** 还要轻量。好的，名字解决了，感觉挺高大上吧，嘻嘻。接下来，Coding！

## 设置

首先，创建一个名为 *plank* 的目录，在其中创建两个字目录，分别为 *bin* 和 *lib*：

	$ mkdir plank
	$ cd plank
	$ mkdir bin lib

现在创建我们的测试文件。**Rack** 使用 `ru` 作为扩展名，但是 **Plank** 更好，他使用 `.pu` 作为扩展名：

	$ touch test.pu
	
在 *test.pu* 中，我们需要和 **Plank** 交互，就像 **Rack** 一样：

	run Proc.new { |env| ['200, {'Content-Type' => 'text/html'}, ['Hello World'] }

## Plankup

完成上述步骤，我们得到了创建好的 **Plank** 模版（boilerplate）。我们的终极目标就是像 **Rack** 一样，调用 `plankup test.ru`；然后很神奇地在我们的本地运行服务器。但是我们该先从哪里下手呢？我们先从 `plankup` 命令开始吧，因为他是我们直接接触到。下面是 *bin/plankup* 的代码：

	#!/usr/bin/env ruby

	Plank::Server.start

第一行是告诉  **shell** 使用 **Ruby** 来执行接下来脚本。**Plank** 作为我们项目的命名空间。`Server.start` 帮助我们与底层命令实现交互。写到这里，接下来相信大家就知道要做什么了。这是目前我们仅有的信息，不过已经足够继续了。那就开始实现 `Server` 吧！

## Plankup::Server

遵循 **Ruby** 的打包标准，*lib* 作为我们脚本的存放目录。如果你读过 **Rack** 的脚本，你可能注意到这个目录里面有很多文件。幸运的事，**Plank** 只需要实现里面的一个 100 行的文件，同样也是最核心的部分。因此，在 *lib* 目录中，创建一个 *plank.rb* 文件：

	touch lib/plank.rb
	
现在我们可以开始编写真正的 **Ruby** 脚本了。正如我们所知，`Plank` 将是我们最顶级的命名空间，因此先写：

	module Plank
	end

`Plank::Server` 呢？它应该是一个类（Class）或者一个模块（Module）。好的，我现在猜测 `Plank::Server` 应该是一个对象，理由是它需要被初始化并拥有生命周期；因此让我们为它编写一个类（Class），里面包含一个 `start` 的方法：

	module Plank
	  class Server
	    def self.start
	    end
	  end
	end

现在，类方法 `start` 只是一个空方法，我们要做的就是实现它！

## Server.start

那么 `Server.start` 实际做什么的呢？我们已经决定 Server 是一个类（Class），因此初始化实例是很合理的也是必要的步骤：

	 def self.start
	   new
	 end
	 
好的，没有任何功能。但是它是一个好的开端。我们现在知道 `start` 是一个工厂（Factory）方法；将会创建一个 Server 对象。然而，这还不够。如果我们只想要一个对象实例的话，那我们可以调用 `Plank::Server.new`。`start` 暗含一些其他的功能，比如启动一个服务。因此，启动什么呢？一个对象还是类？因为只有对象启动，所以我们假设使用 `Server` 对象调用 `start`：

	def self.start
	  new.start
	end

好的，我们到这一步了。但是我们缺少了两样东西：其中一个是 `server.start` 的实现；另一个是获取 `test.pu` 的索引。Huh？当我们执行 `plankup test.pu`，我们只是作为命令行参数传递它。目前 `.start` 的实现还没涉及到参数，因此这部分我们添加它：

	def self.start
	  new(ARGV).start
	end
	
> `ARGV`，它是系统全局变量，保存所有从命令行传递过来的参数。在我们的例子中，`ARGV` 是一个一维数组，`['test.pu']`。

## Apps 和 Options

在分解代码之前，让我们先停下来，想一想我们的 `Server` 对象需要启动哪些东西？当我们运行 `rail s` 的时候，为了运行你的 App，你将启动一个服务。对于任何一个服务都是这样的；我们的 `Plank::Server` 也不例外。首先，我们需要运行一个 App。如果你回想起来了，我们已经写好了一个可以执行的 **Plank** 应用。它就是 `test.pu` 中的 `Proc`。一个服务器应该还需要一些基本的配置：端口（Port）、主机（Host）、环境变量等等。

好的！我们服务器只需要识别要运行的应用和设置一些配置选项；这些配置就像下面那样配置成常量：

	class Server
	   PORT = "9292"
	   HOST = "localhost"
	   ENVIRONMENT = "development"
	   ...
	 end
	 
我们不希望在其他地方重新配置这些常量，因此我们将在初始化 `Server` 时，传入到 `@options` 数组中，并设置成默认值：

	class Server
	  ...
	  def initialize
	    @options = default_options
	  end
	  ... 
	
	  private

      def default_options
        {
          environment: ENVIRONMENT,
          Port: PORT,
          Host: HOST,
        }
      end

现在轮到 App 了。我们知道我们的 App 是 `ARGV` 中的引用，至少有一个文件名。因此，为了调用 `Proc`，我们需要把文件中的内容转化成服务器能识别的变量。这个听起来好像有很多工作要做，更重要的是，它听起来不像是 `Server` 所要承担的职责，例如解析业务逻辑。作为替代，我们创建一个 `Builder` 类来处理我们的应用。它可以灵活地选择不同的方式，根据不同配置来创建应用，而不会改变 `Server` 类。在我们的 *plank.rb*，添加 1 个类：

	 module Plank
	   ...
	   class Builder
	   end
	 end
	
让我们给 `Server` 中添加一些方法，以便他能调用 `Builder` 来处理传入的 *test.pu*：
	
	 module Plank
	   class Server
	     ...
	     def initialize(args)
	       ...
	       @options[:config] = args[0]
	       @app = build_app
	     end
	
	     private
	     ....
	     
	     def build_app
	       Plank::Builder.parse_file(@options[:config])
	     end
	   end
	 end

首先我们把 `@options` 数组的 `:config` 中设置成有命令行传入的文件名；然后服务器调用它的私有方法 `.build_app` 来间接触发 `Builder`。

`Builder` 对我们来说，是一个工厂类；它接受我们传给它的文件作为参数，处理后返回一个可运行的 App 。为了实现这个，我们需要一个类方法。就叫 `parse_file` 。我们所需要做的就是把文件名（*test.ru*）发送给 `Builder`。

	module Plank
		
      ...

	  class Builder
	    def self.parse_file(file)
	      cfg_file = File.read(file)
	      new_from_string(cfg_file)
	    end
	  
	    def self.new_from_string(builder_script)
	      eval "Plank::Builder.new {\n" + builder_script + "\n}.to_app"
	    end
	  end
	end

这边跳的有点快，这里让我解释下。`Builder.parse_file` 很容易实现。读取一个文件的内容，到一个变量 `cfg_file` 中；然后传递给 `Builder.new_from_string`，一个工厂方法运行一些怪异的 Ruby 代码，它的作用是执行 `test.pu` 中的代码。需要的注意的，`eval` 是一个很取巧的做法，可能会造成安全漏洞，但是在我们的例子中，它可以很好将文本转化成 **Ruby** 代码。

记住，我们的 *test.pu* 只有一行：

	run Proc.new { |env| ['200, {'Content-Type' => 'text/html'}, ['hello world]] }

现在我们把它作为 `block` 发送给 `Builder.new`；这是我们所希望的。这行代码构建了两个组件，分别是 `run` 和 `Proc`。`run` 是作为一个方法被我们的 `Builder` 类调用。通过调用 `run`，我们把 `Proc` 赋值给一个实例变量 `@app`，最后使用 `.to_app`  返回`@app`。了解了吗？它解释起来很长，但是实现起来很简单：

	class Builder
	  ...
	  def initialize(&block)
	    instance_eval(&block) if block_given?
	  end
	
	  def run(app)
	    @run = app
	  end
	
	  def to_app
	    @run
	  end
	end

为什么我们需要 `instance_eval`？由于他允许我们根据实例对象的上下文，`block` 才可以访问到 `Builder.run`。如果我们直接执行 `block.call`，它将会报错，告知 `run` 未定义，因为 `block` 和 Builder 不在同一个作用域。 

## Server's server

现在我们的 Server 对象实例有了可执行的 `@app` 和相关配置信息（如端口和主机名）。我们几乎完成。剩下的就是启动服务的实现。如果你看到我们的 `Server.start` 方法，我们实例化的最后有个 `.start`，说明这个方法负责启动 **Plank**，不要搞混了，这是实例变量，不是我们之前实现的类变量，同名但是不同的两个变量。让我们实现它：

	module Plank
	  class Server
	  ...
	    def start
	      server.run @app, @options
	    end
	
	    private
	
	    ...
	    def server
	      @server ||= Plank::Handler.default
	    end
	  end
	end

所有的这些代码看起来有点突兀，不过相信我，它奏效。`Server` 识别到一个服务，并且负责运行传入的 App 和配置。 `@Server` 本来是个空变量，现在把 `Plank::Handler` 赋给它。记住，我们只要 **Plank 和真正的网页服务器（ 如 **WebRick**，**Thin** 或者 **Mongrel** ）交互。为了根据用户选择服务器脚本的不同偏好，我们将要创建一个 **Plank** 的 `Server` 的抽象层（`Plank::Handler`），使后端服务成变成一个组件是很有意义的，可以很容易被切换：

	module Plank
	  ...
	  module Handler
	    def self.default
	    end
	  end
	  ...
	end
	
`Handler` 是一个模块；我们不会直接和 `Handler` 类交互，只是和我们的服务器的特定实现进行交互（如 **Thin**，**WebRick** 等等）。明显，`Module.default` 还没完成。现在，我们需要挑选默认的服务器。这里我选择 **thin**，理由是它简单易于使用，而且配置比 WebRick 简单很多。如果你真的了解 Thin，你基本上可以使用任何东西，你怎么设置，Plank 就可以使用。

	module Plank
	  ...
	  module Hanlder
	    def self.default
	      Plank::Handler::Thin
	    end
	
	    class Thin
	
	    end
	  end
	end 

你可能会问为什么 `module.default` 不直接调用我们 **Thin** 类的方法。虽然有点绕，但是我们的 `Plank::Server` 对象只需要我们类实例的名称。好的，我们的 Thin 类 真的很瘦，所以我们首先充实它：

	module Plank
	  ...
      module Handler
        ...
	    class Thin
	      def self.run(app, options={})
	        host = options[:Host]
	        port = options[:Port]
	        args = [host, port, app, options]
	        server = ::Thin::Server.new(*args)
	        server.start
	      end
	    end
      end
	end

`Thin.run` 简单组织一些输入，然后初始化成 `Thin::Server` 实例。需要使用前导 `::`，它会先寻找 `Thin` GEM 包，而不是我们自己创建的 `thin` 类。我们几乎已经完成了，还有两件事件需要扫尾下：
1 确认你的机子已经安装了 `thin`，并添加 `require` 在你的代码头部；

        require 'thin'
        module Plank
        ...

2.确认你在你的 *bin/planup* 文件包含 *plank.rb*： 

        #! /usr/bin/env ruby
        
        require_relative '../lib/plank'
        ...

在你的命令行运行 `./bin/plankup test.pu`，打开浏览器 *http://localhost:9292/*，见证奇迹的时候。。。

## 结语

我希望在这个博客中，你可以理解 Rack 的运行原理。用了不到 100 行的代码中，我实现了一个最简陋的 **Rack**。**Rack** 本身除了 `run` 外还有其他丰富的接口，因此尝试增加一些 **Rack** 特性到 Rack 中，比如路由，守护进程，以及其他在 Rack 文档中列举的特性。本人来说，深挖 **Rack** 的同时激起了我对 **Thin** 的兴趣。

这里提供给[源码](https://github.com/n3xtchen/n3xtchen/blob/master/plank)，和丰富的注释，如果你的无法正常运行，可以对比下！

> 参考 http://www.kavinder.com/blog/2014-10-10-rebuild-a-gem-rack/

