---
layout: post
title: "Sinatra, Go!"
description: ""
category: ruby
tags: [ruby, senatra, beginning]
---
{% include JB/setup %}

### Sinatra 是什么？

Sinatra 是一个用于创建网页应用的专用领域语言(DSL)；它优雅地封装最简洁的 Web 
应用开发库。

它不会对应用要求太多，具体两个部分：

+ 它要求使用 Ruby 编写。
+ 它需要 Url 来路由。

使用 Sinatra，你可以编写简单的特设应用，构建成熟的大型应用同样很简单。

你可以使用各种 Rubygems 或者其他 Ruby 可用的库。

当你进行实验，构建程序模型设计(mock-ups)或者快速构建程序接口，Sinatra 绝对会
让你印象深刻的。

它不是标准的 MVC 框架，可以直接绑定特定 URL 到相关的 Ruby 代码，并返回输出给
响应(Response)。但是不建议这么做，无论如何，为了编写简洁，组织良好的应用：应
分离视图和应用代码。

> #### 我的环境
>       $ ruby --version
>       ruby 2.0.0p247 (2013-06-27 revision 41674) [x86_64-darwin13.0.0]
>       $ gem --version
>       2.0.3

### 安装 *Sinatra*

    $ gem install sinatra
    Fetching: rack-1.5.2.gem (100%)    
    Successfully installed rack-1.5.2
    Fetching: tilt-1.4.1.gem (100%)
    Successfully installed tilt-1.4.1
    Fetching: sinatra-1.4.4.gem (100%)
    Successfully installed sinatra-1.4.4
    Parsing documentation for tilt-1.4.1
    Installing ri documentation for tilt-1.4.1
    Parsing documentation for sinatra-1.4.4
    Installing ri documentation for sinatra-1.4.4

sinatra 依赖 Rack 包。

Sinatra 支持很多不同的模版引擎(它内部使用 Tilt 库来支持每一个模版引擎)。从经
验来看，你应该安装你需要的模版引擎。Sinatra 开发团队建议使用 ERB(它默认包含
在 Ruby 中)，或者安装 HAML 作为你首个模版语言。

    $ gem instal haml

### Hello *Sinatra*

    # hello.rb
    require 'sinatra'

    get '/' do
      'Hello world!'
    end

运行 *Sinatra*, 并浏览 http://localhost:4567。

    $ ruby hello.rb

Sinatra 魔术

你已经了解了如何安装，和写了一个简单的 Hello World 的应用。在接下来的内容中
，你将进入 Sinatra 顺风之旅，熟悉它的各种特性。

### 路由（Routes）

路由的时候，Sinatra 异常灵活；它的本质是一个 HTTP 方法，使用正则表达式来匹配
请求的 URL。四个基本的 HTTP 请求方法：

+ GET
+ POST
+ PUT
+ DELETE

路由是你应用的精髓，他们就像一张地图，在你的应用中导航你的用户。

它也可以构建 Restful 网络服务，使用非常明确的方式。

    # 
    # Short description for blogApi.rb
    # 博客接口程序
    # 
    # @package blogApi
    # @author n3xtchen <echenwen@gmail.com>
    # @version 0.1
    # @created in 2013-11-09 23:26

    get '/posts' do
        # 获取博客清单
    end

    get '/post/:id' do
        # 获取一篇博客
        @post = Post.find(param[:id])
        # 使用 param 获取请求的参数
    end

    post '/post' do
        # 创建一条博客
    end

    put '/post/:id' do
        # 更新以存在的博客
    end

    delete '/post/:id' do
        # 删除博客
    end

从这个例子中，你可能会觉得 Sinatra 的路由很容易掌握。别小看人，Sinatra 可以
用路由做更漂亮惊喜的事情。需要你更深层次地学习，本章不详细阐述。

### 过滤器(Filters)

Sinatra 通过过滤器提供一种方式来操纵应用请求链。

过滤器定义了两个有用的方法，`before` 和 `after`，他们都在请求的上下文中执行
，而且能改变请求和响应，并可选接受请求的 URL 匹配模式来执行。

#### before

`before` 方法中定义的代码将在每次请求被处理之前被执行

    before do
        Post.connect unless Post.connected?
    end

    get '/post/:id' do
        # 获取一篇博客
        @post = Post.find(param[:id])
        # 使用 param 获取请求的参数
    end

在这个例子中，请求时将事先连接 Post 数据库。

#### after

`after` 方法中定义的代码将在每次请求被处理之后被执行。

    after do
        Post.disconnect
    end

#### 模式匹配

过滤器可选带一个正则表达式匹配请求的 URI, 只有匹配的 URL 才会出发。

    after '/admin/*' do
       authenticate!
    end

### 自带处理函数(Handlers)

他们是 Sinatra 的顶级方法，用来处理通用的 HTTP 路由；例如，`halting`，
`passing`。

    get '/' do
        redirect someurl  # 重定向
    end

你可能需要使用会话(session)，你只需要在你的应用上添加如下配置即可：

    enable :sessions

你也能使用基于 session 的 cookie

    get '/' do
        session['counter'] ||= 0
        session['counter'] += 1
        "You've hit this page #{session['counter']} times!" 
    end

如果使用得当，这些函数将非常好用，可能最大通用使用难过就是请求参数(param)，
它让你通过请求对象访问传入的参数，或者生成你的路由模式。

#### 模版(Templates, 更新中)

Sinatra 是建立在一个极其强大的模版引擎(Tilt)之上的。
<!--Which, is designed to be
a “thin interface” for frameworks that want to support multiple template 
engines.-->

Tilt 的一些其他全明星特征：

<!--
+ Custom template evaluation scopes / bindings
+ Ability to pass locals to template evaluation
+ Support for passing a block to template evaluation for “yield”
-->
+ 追踪错误的文件和错误的行数
+ 模版文件缓存和重载

并且他支持目前最好的引擎，例如 HAML，Less CSS 和 coffee-script。

作为入门，建议是 erb，因为它是默认包含在 Ruby 中。视图默认是在根目录的 
`views` 目录下。。

你可能将在你的路由文件中看到：

    get '/' do
        erb :index  
        # 输出 erb 解析过的 views/index.erb
    end

另一个默认惯例是布局(layout)，它默认是在 /views/layout.tmpl_prefix 模版文件
。在 erb 的例子中，你的布局模版就是 /views/layout.erb :

    <html>
        <head>..</head>
        <body>
            <%= yield %>
        </body>
    </html>

### 辅助方法(Helper)

辅助方法是用来存储封装可复用代码片段的方法。

    helpers do
        def bar(name)
            "#{name}bar"
        end
    end

    get '/:name' do
        bar(params[:name])
    end

### 模块(Models)

#### DataMapper

如果你还没有它，你首先摇通过 gem 安装它，然后确认在你的应用包含它。从
`setup` 开始：

    require 'rubygems'
    require 'data_mapper'

    # 载入程序所在目录下 blog.db 的 sqlite 数据库
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

    class Post
        include DataMapper::Resource
        property :id, Serial
        property :body, Text
        property :created_at, DateTime
    end

    # 当你定义完所有的 models 之后，调用他
    DataMapper.finalize

    # 自动创建 post 表
    Post.auto_upgrade!

执行上述程序需要安装如下软件包：

    $ gem install datamapper
    $ gem install dm-sqlite-adapter

执行程序：

    $ ruby db.rb 
    $ sqlite3 blog.db 
    SQLite version 3.7.13 2012-07-17 17:46:21
    Enter ".help" for instructions
    Enter SQL statements terminated with a ";"
    sqlite> .tables
    posts
    sqlite> .schema posts
    CREATE TABLE "posts" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "body" TEXT, "created_at" TIMESTAMP);
    sqlite> .quit

这里我们创建了文件名为 blog.db 的 sqlite 数据库，并创建了 posts 的表。

#### 简单博客网站

    # 
    # Short description for blogApi.rb
    # 博客网站
    # 
    # @package blogApi
    # @author n3xtchen <echenwen@gmail.com>
    # @version 0.1
    # @created in 2013-11-09 23:26
    require 'rubygems'
    require 'data_mapper'
    require 'sinatra'
    
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db")
    
    class Post
        include DataMapper::Resource
        property :id, Serial
        property :body, Text
        property :created_at, DateTime
    end
    
    DataMapper.finalize
    Post.auto_upgrade!

    # 这是控制器
    get '/' do
        @post = Post.all(:order => [:id.desc], :limit => 20)
        erb :index
    end

最后，我们为它创建一个视图：

    <% @posts.each do |post| %>
        <h3><%= post.title %></h3>
    <% end %>

### 中间件(Middleware)

Sinatra 建立在 Rack(Ruby 用于网页框架的最小标准接口) 之上。对于应用开发者，
Rack 最有意思的能力之一的是支持中间件(middleware) - 组件在服务器和你监控或
者操纵 Http 请求/响应的应用之间提供各种通用功能。

Sinatra 提供原生方法使得创建 Rack 中间件管道变得很方便。

    require 'sinatra'
    require 'my_custom_middleware'

    use Rack::Lint
    use MyCustomMiddleware

    get '/hello' do
        "hello  World"
    end

#### Rack HTTP 基本验证

`use` 语义和那些定义在 `Rack::Builder` DSL一样(更经常用来 rackup 文件上)。例
如，use方法 接受多个/可变的参数：

    use Rack::Auth::Basic do |username, password|
        username == 'admin' && password == 'secret'
    end

Rack 拥有各种各样的标准中间件，它们主要用于记录日志，debug，路由，验证以及会
话操作。Sinatra 会基于配置自动使用各种这样的组件，因此不需要你明确地使用它。

### 测试

I am comming Soon!

### It's Over
