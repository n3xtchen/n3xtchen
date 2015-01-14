---
layout: post
title: "Pyramid - 一个文件实现 Todo 应用"
description: ""
category: Python
tags: [python, pyramid, microframework]
---
{% include JB/setup %}

此教程为你展示 **Pyramid** 开发 Web 应用的基本步骤。文章很短，使用尽可能少的代码实现一个待办事务（todo）应用。为了简洁，这里采用 **Pyramid** 的单文件应用模式来开发。

todo 应用将具有如下几个特点：

* 提供任务列表，插入和关闭任务界面
* 使用路由模式来映射 URLs 到对应的视图函数
* 使用 **Mako** 模版来渲染你的视图
* 使用 **SQLite** 作为你的后端数据库

## 准备工作

你需要的如下包：

* **Pyramid** 框架
* **mako** 模版扩展（add-on）

如果你没有，你可以通过 [**pip**](http://pip.readthedocs.org/en/latest/installing.html) 命令进行安装：

	pip install pyramid pyramid_mako

## 第一步 - 组织你的应用结构

我们将为我们的应用创建如下目录结构：

	tasks/
	├── static
	└── templates
	
## 第二步 - 配置你的应用

首先，我们将在 *tasks* 目录下创建一个 *tasks.py* 文件，并添加如下代码：

	import os
	import logging
	
	from pyramid.config import Configurator
	from pyramid.session import UnencryptedCookieSessionFactoryConfig
	
	from wsgiref.simple_server import make_server
		
然后，我们配置日志记录方式，并把当前目录设置项目根目录：

	logging.basicConfig()
	log = logging.getLogger(__file__)
	
	here = os.path.dirname(os.path.abspath(__file__))
		
最后，开始编写我们的应用主体（`__main__`）； 传递配置选项（`settings`）和会话工厂（`session_factory`）给 **Pyramid**，并创建和运行 **WSGI** 应用：

	if __name__ == '__main__':
	    # 配置选项设置
	    settings = {}
	    settings['reload_all'] = True
	    settings['debug_all'] = True
	    # 会话配置
	    session_factory = UnencryptedCookieSessionFactoryConfig('itsaseekreet')
	    # 配置
	    config = Configurator(settings=settings, session_factory=session_factory)
	    # 启动应用
	    app    = config.make_wsgi_app()
	    server = make_server('0.0.0.0', 8080, app)
	    server.serve_forever()	
		
> 关于 **Session**，详见[会话配置](http://docs.pylonsproject.org/docs/pyramid/en/latest/narr/sessions.html#using-the-default-session-factory)

现在，我们就有一个可以运行我们应用的基础项目架构，但我们还需要加入数据库，路由，视图和模版的支持。

## 第三步 - 数据库设计和应用初始化

为了让事情简单点，我们将使用 **SQLite** 数据库（因为它在大部分操作系统中都默认安装）。

我们任务的数据结构很简单：

1. `id`：记录的唯一标识
2. `name`：不超过 100 个字符的任务名
3. `close`：任务是否关闭

在 *tasks* 目录下添加一个文件，命名为 schema.sql，内容如下：

    /**
      建表和初始化数据
      */
	create table if not exists tasks (
	    id integer primary key autoincrement,
	    name char(100) not null,
	    closed bool not null
	);
	
	insert or ignore into tasks (id, name, closed) values (0, '开始 Pyramid', 0);
	insert or ignore into tasks (id, name, closed) values (1, '快速入门', 0);
	insert or ignore into tasks (id, name, closed) values (2, '来杯咖啡吧!', 0);
	
在上一步创建的 *tasks.py* 文件顶部引入库，内容如下：

	import sqlite3
	from pyramid.events import subscriber, \
		NewRequest, ApplicationCreated
	
为了让创建数据库的过程稍微简单点，我们将 **subscribe** 一个 **Pyramid** 事件来完成执行数据库创建和初始化。把该函数挂载到 `ApplicationCreated` 事件，每一次我们启动应用的时候，我们将会触发该函数。因此，我们数据库将会在应用启动之后被创建，必要时会被更新。
	
	@subscriber(ApplicationCreated)
	def application_created_subscriber(event):
	    log.warn('Initializing database...')
	    with open(os.path.join(here, 'schema.sql')) as f:
	        stmt = f.read()
	        settings = event.app.registry.settings
	        db = sqlite3.connect(settings['db'])
	        db.executescript(stmt)
	 	
我们还需要为我们应用设置数据库连接串。我们将提供一个连接对象作为应用请求的属性。关联 `NewRequest` 事件，当 **Pyramid** 请求开始的时候，我们将会初始化数据连接。你可以通过 `request.db` 来访问创建的数据库连接。在请求周期的最后使用 `request.add_finished_callback` 方法，来关闭数据库连接。

	@subscriber(NewRequest)
	def new_request_subscriber(event):
	    request = event.request
	    settings = request.registry.settings
	    request.db = sqlite3.connect(settings['db'])
	    request.add_finished_callback(close_db_connection)
	
	def close_db_connection(request):
	    request.db.close() 	
	
为了使这些代码可用，我们将要在配置中指定数据的位置和使用 `config.scan()` 确保我们的 `@subscriber` 装饰器在应用运行时被扫描到。

	if __name__ == '__main__':
	    ...
	    settings['db'] = os.path.join(here, 'tasks.db')
	    ...
	    config.scan()
	    ...
		
目前为止，我们已经为我们的应用添加了创建和访问数据机制。

> ### Pyramid 事件机制
> 事件（event ）存在于 **Pyramid** 应用的整个生命周期。大部分 **Pyramid** 应用不需要应用，但是它在某些场景下将很有用（就像我们这个例子一样，在应用启动的时候，初始化数据库）。
> 事件函数结构：
> 
>       def mysubscriber(event):
>            print(event)
>            
> 然后添加到配置中：
> 
>       config.add_subscriber(mysubscriber, NewRequest) 
>       # 将 `mysubscriber` 挂载到 `NewRequest` 事件中。
>
> 而本文使用的是装饰器进行挂载，使用如下事件：
> 
> * ApplicationCreated：应用创建时触发
> * NewRequest：新请求进入时触发
>
> 注意：使用装饰器，需要使用 `config.scan()` 来扫描挂载事件的函数。
> 详见：http://docs.pylonsproject.org/docs/pyramid/en/latest/narr/events.html

## 第四步 - View 函数的基本 Web 操作

开始这个步骤之前，我们需要了解关于 View 的尝试。为了实现一个 View，我们需要完成如下步骤：

1. 编写 View 函数
2. 将 View 函数登记到应用配置中
3. 使用路由（Route）将指定的 Url 模式映射到 View 函数中
4. 根据配置生成 wsgi 应用

看看，一个例子：

	from pyramid.response import Response
	from pyramid.view     import view_config
	from pyramid.config   import Configurator
	
	# 1. 编写 View 函数，route_name 用于路由匹配 URL 的（add_route） 
	@view_config(route_name='hello')
	def hello():
		return Response('<body>Visit <a href="/howdy">hello</a></body>')
	
	...	# 此处省略基础配置	
	config = Configurator(settings=settings)
    config.add_route('hello', '/')	# 3. 使用路由（Route）将指定的 Url 模式映射到 View 函数中
    config.scan()					# 2. 将 View 函数登记到应用配置中
    config.make_wsgi_app()			# 4. 根据配置生成 wsgi 应用
    
> 详见 http://docs.pylonsproject.org/docs/pyramid/en/latest/narr/viewconfig.html

现在，继续我们的应用。首先，我们先导入一些需要的库。

	...
	from pyramid.exceptions     import NotFound
	from pyramid.httpexceptions import HTTPFound
	from pyramid.view           import view_config
	...	

我们现在开始实现任务列表和任务的添加与关闭。

### 任务列表

使用这个视图用来展示所有未完成的任务实体。`view_config` 的可选参数 `renderder` 告诉视图返回的数据字典使用指定的模版文件来渲染。视图函数的返回值必须是字典。任务列表的视图从数据库中查询处未完成的任务，使用字典返回数据，提供给 *list.mako* 模版文件：

	@view_config(route_name='list', renderer='list.mako')
	def list_view(request):
	    rs = request.db.execute("select id, name from tasks where closed = 0")
	    tasks = [dict(id=row[0], name=row[1]) for row in rs.fetchall()]
	    return {'tasks': tasks}

### 新增任务

这个视图让用户创建新的任务。如果在表单中提供了一个 `name`，一个任务就创建。然后生成一个信息在接下来的请求中显示，用户的浏览器将被从定向到 `list_view` 中。如果没东西提供，将会产生一条提醒消息，在 `new_view` 中显示。

	@view_config(route_name='new', renderer='new.mako')
	def new_view(request):
	    if request.method == 'POST':		＃ 是否是 POST 请求
	        if request.POST.get('name'):	＃ Post 请求过来的 name 字段是否存在
	            request.db.execute(
	                'insert into tasks (name, closed) values (?, ?)',
	                [request.POST['name'], 0])
	            request.db.commit()
	            request.session.flash('New task was successfully added!')
	            # 重定向到 list 页面
	            return HTTPFound(location=request.route_url('list'))
	        else:
	            request.session.flash('Please enter a name for the task!')
	    return {}
	    
#### request 对象 

这里 view 函数 `new_view` 接受一个参数 `request`。`request` 对象是 WSGI 环境变量字典对象的 **Pyramid** 封装。下面是 `request` 一些常见的属性：

1. `req.method`

	请求方法, e.g., 'GET', 'POST'
2. `req.GET`	
	 	
 	查询字符串的字典
3. `req.POST`
	 
	请求体（request body）的字典。只有在请求方法是 `POST` 获取表单提交的时候可用。
4. `req.params`
	
	融合 `req.GET` 和 `req.POST` 字典。
5. `req.body`
	
	请求体的内容。它包含所有请求内容，以字符形式存储。当一个 POST 请求不是表单提交或者一个 PUT 请求时，它就变的很有用。你还可以通过 `req.body_file` 获取，它以文件形式存储。
6. `req.cookies`
	
	cookie 字典。
7. `req.headers`
	
	所有头信息的字典，大小写敏感。
8. `req.session`
	如果会话工厂被配置（回顾下第二部的会话配置，`session_factory`），这个属性就会返回当前用户的 session 对象；否则被调用的时候会抛出 `pyramid.exceptions.ConfigurationError` 异常。
	
另外我们还使用一个 `request` 的方法：

`route_url`：它根据 **Pyramid** 的路由生成与之对应的全路径 URL。先来看个例子：

	@view_config(route_name='hello')
	def hello():
		return Response('<body>Visit <a href="/howdy">hello</a></body>')
	
	@view_config(route_name='use_route_url')
	def use_route_url(request):
		return HTTPFound(location=**request.route_url('hello')**)
	
	...	
    config.add_route('hello', '/he/ll/o')
    
看看 `request.route_url('hello')`，这是实际上 `request.route_url` 根据 `config` 中路由中查找路由名为 `hello` 的 view 函数，然后找到它匹配的 url（`/he/ll/o`）并返回，这是它返回的是 *http://your.domain.com/he/ll/o*（*http://your.domain.com* 你应用所属的域名）
	
> 详见 http://docs.pylonsproject.org/projects/pyramid/en/1.0-branch/narr/webob.html
	
#### Flash Messages（信息）

闪存信息是一个简单的存储在会话中的消息队列。

闪存信息有两个主要用途：

1. 内部跳转后只显示一次状态信息
2. 使用通用代码来为单次显示记录日志，而不用定向到一个 HTML 模版。

用法如下：

	>>> request.session.flash('info message')
	>>> request.session.pop_flash()		# 我们将在模版文件中使用
	['info message']
	>>> request.session.pop_flash()
	[]	
> 详见 http://docs.pylonsproject.org/docs/pyramid/en/latest/narr/sessions.html#using-the-default-session-factory
	
### 关闭任务

	@view_config(route_name='close')
	def close_view(request):
	    task_id = int(request.matchdict['id'])
	    request.db.execute("update tasks set closed = ? where id = ?",
	                       (1, task_id))
	    request.db.commit()
	    request.session.flash('Task was successfully closed!')
	    return HTTPFound(location=request.route_url('list'))
		
### NotFound 视图

使用自己的模版自定义默认的 NotFound 页面。当一个 URL 找不到映射的 View 函数的时候，将会被定向到 NotFound 页面。这里，我们通过自己编写的 View 函数来覆盖框架自带的 404 页面。

	@view_config(context='pyramid.exceptions.NotFound', renderer='notfound.mako')
	def notfound_view(request):
	    request.response.status = '404 Not Found'	
### 添加路由

我们最后需要添加一些路由配置到应用高配置中，用来映射视图函数和 URL 之间的关系。

	    # routes setup
	    config.add_route('list', '/')
	    config.add_route('new', '/new')
	    config.add_route('close', '/close/{id}')

## 第五步 - 视图模版

视图可以工作，但是他们需要渲染成浏览器可以理解的语言：**HTML**。我们已经看到在我们的视图配置中接受一个 `renderer` 参数。我们将使用 **Pyramid** 框架常见模版引擎之一：**Mako Templates**。

我们夜间个使用 **Mako** 模版的继承机制。模版继承使得多个模版共用一套模版，易于前端布局的维护和保持一致。

我发现不错的 **Mako** 入门译文，看完它，你几乎可以掌握 Mako，[Python模板库Mako的语法](http://www.yeolar.com/note/2012/08/28/mako-syntax/)，这里不展开讲了。

### layout.mako

这个模版包含与其他模版共享的基本布局结构。在 `body` 标签中，我们定义一个块来显示应用发送的提醒信息，另一个用来显示使用 **Mako** 命令 `${next.body}` 继承这个主布局的页面内容。

	# -*- coding: utf-8 -*- 
	<!DOCTYPE html>  
	<html>
	<head>
		
	  <meta charset="utf-8">
	  <title>Pyramid Task's List Tutorial</title>
	  <meta name="author" content="Pylons Project">
	  <link rel="shortcut icon" href="/static/favicon.ico">
	  <link rel="stylesheet" href="/static/style.css">
	
	</head>
	
	<body>
	
	  % if request.session.peek_flash():
	  <div id="flash">
	    <% flash = request.session.pop_flash() %>
		% for message in flash:
		${message}<br>
		% endfor
	  </div>
	  % endif
	
	  <div id="page">
	    
	    ${next.body()}
	
	  </div>
	  
	</body>
	</html>
	
### list.mako

	# -*- coding: utf-8 -*- 
	<%inherit file="layout.mako"/>
	
	<h1>Task's List</h1>
	
	<ul id="tasks">
	% if tasks:
	  % for task in tasks:
	  <li>
	    <span class="name">${task['name']}</span>
	    <span class="actions">
	      [ <a href="${request.route_url('close', id=task['id'])}">close</a> ]
	    </span>
	  </li>
	  % endfor
	% else:
	  <li>There are no open tasks</li>
	% endif
	  <li class="last">
	    <a href="${request.route_url('new')}">Add a new task</a>
	  </li>
	</ul>
	
### new.mako

	# -*- coding: utf-8 -*- 
	<%inherit file="layout.mako"/>
	
	<h1>Add a new task</h1>
	
	<form action="${request.route_url('new')}" method="post">
	  <input type="text" maxlength="100" name="name">
	  <input type="submit" name="add" value="ADD" class="button">
	</form>

### notfound.mako

	# -*- coding: utf-8 -*- 
	<%inherit file="layout.mako"/>
	
	<div id="notfound">
	  <h1>404 - PAGE NOT FOUND</h1>
	  The page you're looking for isn't here.
	</div>

### 配置模版路径

为了视图可以通过模版名来找到相应的模版，我们现在需要指定模版的位置：

	...
	settings['mako.directories'] = os.path.join(here, 'templates')
	...
	# add mako templating
	config.include('pyramid_mako')
	...
	
## 第六步 － 添加样式

现在是时候为你的应用添加样式了。我们在 *static* 中新建一个名为 *style.css* 的文件，内容如下：

	body {
	  font-family: sans-serif;
	  font-size: 14px;
	  color: #3e4349;
	}
	
	h1, h2, h3, h4, h5, h6 {
	  font-family: Georgia;
	  color: #373839;
	}
	
	a {
	  color: #1b61d6;
	  text-decoration: none;
	}
	
	input {
	  font-size: 14px;
	  width: 400px;
	  border: 1px solid #bbbbbb;
	  padding: 5px;
	}
	
	.button {
	  font-size: 14px;
	  font-weight: bold;
	  width: auto;
	  background: #eeeeee;
	  padding: 5px 20px 5px 20px;
	  border: 1px solid #bbbbbb;
	  border-left: none;
	  border-right: none;
	}
	
	#flash, #notfound {
	  font-size: 16px;
	  width: 500px;
	  text-align: center;
	  background-color: #e1ecfe;
	  border-top: 2px solid #7a9eec;
	  border-bottom: 2px solid #7a9eec;
	  padding: 10px 20px 10px 20px;
	}
	
	#notfound {
	  background-color: #fbe3e4;
	  border-top: 2px solid #fbc2c4;
	  border-bottom: 2px solid #fbc2c4;
	  padding: 0 20px 30px 20px;
	}
	
	#tasks {
	  width: 500px;
	}
	
	#tasks li {
	  padding: 5px 0 5px 0;
	  border-bottom: 1px solid #bbbbbb;
	}
	
	#tasks li.last {
	  border-bottom: none;
	}
	
	#tasks .name {
	  width: 400px;
	  text-align: left;
	  display: inline-block;
	}
	
	#tasks .actions {
	  width: 80px;
	  text-align: right;
	  display: inline-block;
	}
	
为了让你的静态文件可以被使用，我们修添加一个 “static view” 到你的应用配置中：

	...
	config.add_static_view('static', os.path.join(here, 'static'))
	...
	
## 第七步 - 运行你的应用

我们已经完成全部的步骤。运行它之前，我们先预览一遍我们的主程序 *tasks.py*：

	import os
	import logging
	import sqlite3
	
	from pyramid.config import Configurator
	from pyramid.events import NewRequest
	from pyramid.events import subscriber
	from pyramid.events import ApplicationCreated
	from pyramid.httpexceptions import HTTPFound
	from pyramid.session import UnencryptedCookieSessionFactoryConfig
	from pyramid.view import view_config
	
	from wsgiref.simple_server import make_server
	
	
	logging.basicConfig()
	log = logging.getLogger(__file__)
	
	here = os.path.dirname(os.path.abspath(__file__))
	
	
	# views
	@view_config(route_name='list', renderer='list.mako')
	def list_view(request):
	    rs = request.db.execute("select id, name from tasks where closed = 0")
	    tasks = [dict(id=row[0], name=row[1]) for row in rs.fetchall()]
	    return {'tasks': tasks}
	
	
	@view_config(route_name='new', renderer='new.mako')
	def new_view(request):
	    if request.method == 'POST':
	        if request.POST.get('name'):
	            request.db.execute(
	                'insert into tasks (name, closed) values (?, ?)',
	                [request.POST['name'], 0])
	            request.db.commit()
	            request.session.flash('New task was successfully added!')
	            return HTTPFound(location=request.route_url('list'))
	        else:
	            request.session.flash('Please enter a name for the task!')
	    return {}
	
	
	@view_config(route_name='close')
	def close_view(request):
	    task_id = int(request.matchdict['id'])
	    request.db.execute("update tasks set closed = ? where id = ?",
	                       (1, task_id))
	    request.db.commit()
	    request.session.flash('Task was successfully closed!')
	    return HTTPFound(location=request.route_url('list'))
	
	
	@view_config(context='pyramid.exceptions.NotFound', renderer='notfound.mako')
	def notfound_view(request):
	    request.response.status = '404 Not Found'
	    return {}
	
	
	# subscribers
	@subscriber(NewRequest)
	def new_request_subscriber(event):
	    request = event.request
	    settings = request.registry.settings
	    request.db = sqlite3.connect(settings['db'])
	    request.add_finished_callback(close_db_connection)
	
	def close_db_connection(request):
	    request.db.close()
	
	
	@subscriber(ApplicationCreated)
	def application_created_subscriber(event):
	    log.warn('Initializing database...')
	    with open(os.path.join(here, 'schema.sql')) as f:
	        stmt = f.read()
	        settings = event.app.registry.settings
	        db = sqlite3.connect(settings['db'])
	        db.executescript(stmt)
	        db.commit()
	
	
	if __name__ == '__main__':
	    # configuration settings
	    settings = {}
	    settings['reload_all'] = True
	    settings['debug_all'] = True
	    settings['mako.directories'] = os.path.join(here, 'templates')
	    settings['db'] = os.path.join(here, 'tasks.db')
	    # session factory
	    session_factory = UnencryptedCookieSessionFactoryConfig('itsaseekreet')
	    # configuration setup
	    config = Configurator(settings=settings, session_factory=session_factory)
	    # add mako templating
	    config.include('pyramid_mako')
	    # routes setup
	    config.add_route('list', '/')
	    config.add_route('new', '/new')
	    config.add_route('close', '/close/{id}')
	    # static view setup
	    config.add_static_view('static', os.path.join(here, 'static'))
	    # scan for @view_config and @subscriber decorators
	    config.scan()
	    # serve app
	    app = config.make_wsgi_app()
	    server = make_server('0.0.0.0', 8080, app)
	    server.serve_forever()
	    
我们执行它把：

	$ python tasks.py
	WARNING:tasks.py:Initializing database...
	
它默认监听 8080 端口

## 结语

本来只想翻译一下文章，突然发现过于介绍的简单，所以又加入了不少的东西。关于 **Pyramid** 的文章真的太少，中文的就更少了！本文跟着作者的思路，难以下笔，只能忍痛把它结掉，如果有任何问题或者建议，请赐教。下一篇将以完全我的视角来为大家介绍 **Pyramid** 的迷人特性。

> 参考 http://docs.pylonsproject.org/projects/pyramid-tutorials/en/latest/single_file_tasks/single_file_tasks.html
