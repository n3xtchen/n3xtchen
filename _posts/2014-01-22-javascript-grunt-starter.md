---
layout: post
title: "Javascript Grunt - 快速入门"
tagline: "JS的项目构建工具之－任务运行器"
description: ""
category: javascript
tags: [javascript, grunt]
---
{% include JB/setup %}

如果你正在进行一个 JS 项目，你可能会有一堆的日常工作要做。那有哪些需要做呢？

+ 合并代码
+ 执行 JSHint 验收你的代码
+ 执行测试
+ 压缩代码

当然你还有很多备选的工具来完成这些，当时如果能够使用同一的工具完成上述的工作，
你应该不会拒绝把？

这就是 Grunt 存在的价值；它拥有一堆的内建任务来完成这些，你还可以创建自己的插件
来拓展基本功能。

### 安装 Grunt

    $ npm install -g grunt-cli

> **这是我当前使用的 node 版本**

>       $ node -v
>       v0.10.24
>       $ grunt --version
>       grunt-cli v0.1.11
>       grunt v0.4.2

#### 准备工作（项目脚手架）

标准的设置需要在你的项目目录中添加两个文件：package.json（管理 npm 库）和
Gruntfile（文件名为 Gruntfile.js，用来配置和定义 grunt 任务）。

Package.json 的格式大致如下：

    {
      "name": "my-project-name",
      "version": "0.1.0",
      "devDependencies": {
          "grunt": "~0.4.2",
          "grunt-contrib-jshint": "~0.6.3",
          "grunt-contrib-nodeunit": "~0.2.0",
          "grunt-contrib-uglify": "~0.2.2"
        }
    }

`devDependencies` 用来指定要依赖的 npm 库；你可以使用 `npm init` 创建。

Gruntfile.js 的范例：

    module.exports = function(grunt) {

      // Project configuration.
      grunt.initConfig({
      pkg: grunt.file.readJSON('package.json'),
        uglify: {
          options: {
            banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
          },
          build: {
            src: 'src/<%= pkg.name %>.js',
            dest: 'build/<%= pkg.name %>.min.js'
          }
        }
      });
      
      // Load the plugin that provides the "uglify" task.
      grunt.loadNpmTasks('grunt-contrib-uglify');
      
      // Default task(s).
      grunt.registerTask('default', ['uglify']);

    };

在号称 JS 最强大项目自动化管理工具的 Grunt 面前，如果你还使用手动创建，
那就弱爆了。

首先，安装项目脚手架（Scaffolding）工具：

    $ npm install -g grunt-init
    $ grunt-init --version
    grunt-init v0.2.1
    grunt v0.4.2

然后，安装模版；模版的默认目录是在`~/.grunt-init/`中（windows 是在 `%USERPROFILE%\.grunt-init\` ）。例如，安装 grunt-init-jquery 模版：

    $ git clone https://github.com/gruntjs/grunt-init-jquery.git ~/.grunt-init/jquery

最后，使用模版初始化项目：

    $ grunt-init TEMPLATE   # 默认在 ~/.grunt-init/ 目录下查找
    $ grunt-init /path/to/TEMPLATE  # 也可以指定路径

下面是官方的 grunt-init 的模版：

+ [grunt-init-commonjs](https://github.com/gruntjs/grunt-init-commonjs)：创建 common 模块，包括 Nodeunit 单元测试；
+ [grunt-init-gruntfile](https://github.com/gruntjs/grunt-init-gruntfile)：基本的 Gruntfile 模版；
+ [grunt-init-gruntplugin](https://github.com/gruntjs/grunt-init-gruntplugin)：创建 grunt 测试，包括 Nodeunit 单元测试；
+ [grunt-init-jquery](https://github.com/gruntjs/grunt-init-jquery)：创建 jquery 插件，包含 QUnit 单元；
+ [grunt-init-node](https://github.com/gruntjs/grunt-init-node)：创建 node 模块，包括 Nodeunit 单元测试；

> *Note*，此教程默认上述模版已经安装

>        $ grunt-init -h
>        ...
>        Available templates
>        commonjs  Create a commonjs module, including Nodeunit unit tests.       
>        gruntfile  Create a basic Gruntfile.                                      
>        gruntplugin  Create a Grunt plugin, including Nodeunit unit tests.          
>        jquery  Create a jQuery plugin, including QUnit unit tests.            
>        node  Create a Node.js module, including Nodeunit unit tests. 
>        ...

### 开始你的 Grunt 之旅

正如你所知的，grunt 是命令行工具；因此，这个教程假设你使用命令工具进行接下来的学习；

#### 创建项目目录

首先创建一个项目样本目录，grunt-tut，进入该目录：

    $ cd /path/to/grunt-tut

#### 初始化项目

`grunt-init` 需要你填写初始化项目需要的一些信息，同时它也提供默认值（即括号
中的值）。现在只是演示，所有一路 `enter` 就好

    $ grunt-init jquery
    ...
    Please answer the following:
    [?] Project name (grunt-tut) 
    [?] Project title (Grunt Tut) 
    [?] Description (The best jQuery plugin ever.) 
    [?] Version (0.1.0) 
    [?] Project git repository (git://github.com/xxxx/grunt-tut.git) 
    [?] Project homepage (https://github.com/xxxx/grunt-tut) 
    [?] Project issues tracker (https://github.com/xxxx/grunt-tut/issues) 
    [?] Licenses (MIT) 
    [?] Author name (n3xtchen) 
    [?] Author email (xxx@example.com) 
    [?] Author url (none) 
    [?] Required jQuery version (*) 
    [?] Do you need to make any changes to the above before continuing? (y/N) N

    ...

    Initialized from template "jquery".
    $ npm install

初始化成功后，你将会看到 grunt 创建项目的基本文件目录：

    $ tree -L 2 # 安装后的目录结构
    .
    ├── CONTRIBUTING.md
    ├── Gruntfile.js
    ├── LICENSE-MIT
    ├── README.md
    ├── grunt-tut.jquery.json
    ├── libs
    │   ├── jquery
    │   ├── jquery-loader.js
    │   └── qunit
    ├── node_modules
    │   ├── grunt
    │   ├── grunt-contrib-clean
    │   ├── grunt-contrib-concat
    │   ├── grunt-contrib-jshint
    │   ├── grunt-contrib-qunit
    │   ├── grunt-contrib-uglify
    │   └── grunt-contrib-watch
    ├── package.json
    ├── src
    │   └── grunt-tut.js
    └── test
        ├── grunt-tut.html
            └── grunt-tut_test.js

正如你所看到的，它给了我们一个好的开始：不仅仅有插件文件（src/jquer.demo.js)
，同时还写了 QUnit 测试（test/jquery.demo_test.js），还有已经写好的任务的
Gruntfile.js。

现在我们可以执行 `grunt` 后将会的到下面的结果:

    $ grunt
    Running "jshint:gruntfile" (jshint) task
    >> 1 file lint free.

    Running "jshint:src" (jshint) task
    >> 1 file lint free.

    Running "jshint:test" (jshint) task
    >> 1 file lint free.

    Running "qunit:files" (qunit) task
    Testing test/grunt-tut.html ....OK
    >> 5 assertions passed (37ms)

    Running "clean:files" (clean) task

    Running "concat:dist" (concat) task
    File "dist/grunt-tut.js" created.

    Running "uglify:dist" (uglify) task
    File "dist/grunt-tut.min.js" created.

    Done, without errors.

这里，我需要特别说明的就是 Qunit 测试。常规的 QUnit 应该是能在浏览器中运行。
然而 `grunt qunit` 测试为了能在命令行中运行，采用 `PhantomJS` (终端的浏览器)。
如果你的测试失败了，后续的任务将会被终止。

下面，grunt jquery 模版的默认任务列表：

+ grunt lint：代码质量检查
+ grunt qunit：执行 QUnit 测试
+ grunt concat：把你的所有代码都合并一个新的文件中，并保存在 dist 文件夹中
+ grunt min：压缩合并后的代码

具体任务实现代码请看你 path/to/grunt_tut/Gruntfile.js。

### Enjoy Grunt！后续的文章将会深入剖析了 GruntJS。
