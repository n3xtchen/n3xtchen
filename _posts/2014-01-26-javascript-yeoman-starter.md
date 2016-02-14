---
layout: post
title: "Javascript Yeoman - 快速入门"
tagline: "JS 项目自动化工作流工具"
description: ""
category: Javascript
tags: [javascript, grunt, bower, yo]
---
{% include JB/setup %}

### Yeoman 是什么？

这个问题问的很好；它不是东西，下面这位就是 Yeoman;

    $ yo webapp

        _-----_
       |       |
       |--(o)--|   .--------------------------.
      `---------´  |    Welcome to Yeoman,    |
       ( _´U`_ )   |   ladies and gentlemen!  |
       /___A___\   '__________________________'
        |  ~  |
      __'.___.'__
    ´   `  |° ´ Y `

    Out of the box I include HTML5 Boilerplate, jQuery, and a Gruntfile.js to build your app.
    [?] What more would you like? (Press <space> to select)
        ⬢ Sass with Compass
       ❯⬢ Bootstrap
        ⬢ Modernizr

        create Gruntfile.js
        create package.json
        ...

    I'm all done. Running bower install & npm install for you to install the required dependencies. If this fails, try running the command yourself.
        ...

正如大家所看到的，他戴着一顶高帽，住在你的电脑里，并且等待你告诉他你要创建什
么样的应用。举一个简单的例子，像下面这样创建一个 Web 应用：

会不会觉得很神奇啊？

我们所要所的就是告诉他你要什么？感觉想在吃西餐的感觉，有木有？召唤 Yeoman，
Yeoman 提供菜单，然后我们选择，最后就等着“上菜”就好了。

无厘头之后，接下来正式向大家推荐 Yeoman。


### Yeoman 三兄弟

我们的工作流使用三个工具来改善你的需求，提高开发的满足感。他们分别是
*yo* （脚手架工具），*grunt*（构建工具），*bower*（包管理工具）。

#### yo

yo 是跨平台的命令，根据你指定的模版生成一个新的应用，编写 Grunt 配置，推送
相关的任务以及 Bower 依赖的建立。

    $ yo webapp

> #### 生成器
>
> 实际上，webapp 是一个独立的插件（众多生成器的一种）。Yeoman 可以识别其他的
> generator-___ 的Node 模块，例如 Backbone，Angular，以及无数你命名的生成器。

#### Grunt

Grunt 是 一个基于 JS 的任务运行器。和 yo 一样，它也提供基础的函数接口，允许
社区为它开发插件（或任务）来帮忙完成共同的事情。当你使用 `yo webapp` 的时候
，Grunt 和一些附带的任务将会一起被被安装。

    $ grunt [task_name]

task_name 就是你在 Gruntfile.js 中定义的任务，如果你使用 web_app 的模版，那
你默认就会添加 sever（在开发环境运行你的站点），build（组合和压缩代码）以及
test（执行 QUnit 测试）这些目录；如果你不指定任务名，那 grunt 就会执行 
Gruntfile.js 中的所有任务。

> 具体介绍请见 [Javascript Grunt - 快速入门]({% post_url 2014-01-22-javascript-grunt-starter %})

#### Bower

没人喜欢去 Github 或者开发网站上下载一个 Javascript 工具的压缩包把。就和 npm
一样，通过简单的命令 bower 就能帮你把想要的 Javascript 库下到你机子上。

    $ bower install jquery

Bower 就会把 jquery 库下载到你的项目目录中的 bower_components 中。

> 具体介绍请见 [Javascript Bower - 快速入门]({% post_url 2014-01-16-javascript-bower-starter %})

### Yeoman 安装

Yeoman 并不是默认预装在你的系统中 。你需要通过 NPM 安装他；首先要确认你已经
安装了 Node.js，Git 以及可选的 Ruby 和Compass（如果你打算使用的话）。

    $ npm install -g yo

如果你没有安装 Grunt 和 Bower，它会自动为你安装。

> **这是我当前使用的 node 版本**

>       $ node -v
>       v0.10.24
>       $ yo -v
>       1.1.2
>       $ grunt --version
>       grunt-cli v0.1.11
>       $ bower -v
>       1.2.8

你可以使用 yo 生成多种应用，但是前提是你需要安装相应插件来完成它。例如，之
前使用 webapp，你需要事先安装它：

    $ npm install -g generator-webapp

这样才可以使用 `yo webapp` 来生成你的应用。你可以通过 npm 来安装其他生成器
；例如，安装 Backbone 生成器：

    $ npm install -g generator-backbone

你可以通过调用 yo 帮助命令查看你的安装的安装器：

    $ yo -h
    Usage: yo GENERATOR [args] [options]

    ...

    Please choose a generator below.


    Backbone
      ...
      backbone:app
      ...

    Mocha
      mocha:app

    Webapp
      webapp:app

mocha 是默认安装的，我除了安装了 webapp 之外还安装了 backbone 生成器。

一切都准备好了，可以开始享受你的 yeoman！

### 一个标准的应用

前提，你已经安装了 webapp 的生成器。

生成应用：

    $ yo webapp

查看构建的目录：

    .
    ├── Gruntfile.js    # GRUNT 认为配置文件
    ├── app # 存放你未编译和压缩的源代码
    │   ├── 404.html
    │   ├── bower_components
    │   ├── favicon.ico
    │   ├── images
    │   ├── index.html  # 未压缩的主页
    │   ├── robots.txt
    │   ├── scripts # 存放 JS 脚本
    │   └── styles  # 存放 CSS 文件
    ├── bower.json  # bower 依赖库配置文件
    ├── node_modules
    │   ├── grunt
    │   ├── grunt-autoprefixer
    │   └── ...
    ├── package.json    # Npm 依赖库配置文件
    └── test    # 测试目录
        ├── bower.json
        ├── bower_components
        ├── index.html
        └── spec

现在看看 yeoman 为你预先定义的 Grunt 任务：

+ *build*：将 app 中的代码进行编译，合并和压缩，并输出到 dist 目录中；
+ *server*：在浏览器中运行你的代码；
+ *test*：测试你的代码，webapp 使用的默认测试框架是 mocha；

实际上，每一个任务都是有多个自任务构成的；例如， build 需要 concat（合并代
码），cssmin（压缩 css 文件），uglify（压缩 js 脚本，copy:dist（优化后的代
码拷贝到dist目录中）等等多个子任务来帮助它完成这个目标。

### 结语

上述对 Yeoman 进行了简单的介绍，让大家对它有一个初步的认识，后续我将会使用
例子来帮助大家更快上手

Enjoy It！



