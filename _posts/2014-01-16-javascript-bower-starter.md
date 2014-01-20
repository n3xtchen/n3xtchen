---
layout: post
title: "Javascript Bower - 包管理工具 For UI/UE - Basic"
description: ""
category: javascript
tags: [javascript, package_manager]
---
{% include JB/setup %}

Bower， browser package manager（浏览器包管理器）, 不仅仅象 JAM 那样的 JS 
包管理器；也不仅仅象 RequireJS 那样的模块载入器；最大的区别就是它不仅仅是 JS
包管理器，还可以管理 HTML，CSS 以及图片。

不过再怎么强大，bower 也只是一个包管理器，他组合代码或者压缩代码，也不知道 
AMD 这样的模块系统。

### 安装 Bower

    $ npm install -g bower

> **这是我当前使用的 node 版本**

>       $ node -v
>       v0.10.24
>       $ bower -v
>       1.2.8

### 使用演示

#### 查询

    $ bower search backbone # 查询包名与 backbone 相匹配的包
    Search results:

        backbone git://github.com/jashkenas/backbone.git
        backbone-amd git://github.com/amdjs/backbone
        ... 省略

#### 安装，更新及卸载

    $ bower install backbone    # 安装
    $ tree -L 2
    .
    └── bower_components 
        └── backbone

    $ bower install jquery#1.7.0    # 可以制定版本
    $ bower install git://github.com/pivotal/jasmine.git    # 也可以制定 GH 的地址

    $ bower update  # 更新库
    $ bower uninstall jquery    # 卸载库

#### 其他命令

    $ bower list    # 查看安装的库

    $ bower lookup backbone # 查看库代码的地址
    backbone git://github.com/jashkenas/backbone.git

    $ bower info backbone
    bower cached        git://github.com/jashkenas/backbone.git#1.1.0
    bower validate      1.1.0 against git://github.com/jashkenas/backbone.git#*

    {
      name: 'backbone',
      homepage: 'https://github.com/jashkenas/backbone',
      version: '1.1.0'
    }

    Available versions:
        - 1.1.0
        - 1.0.0
        - 0.9.10
        ... 省略

安装之后，bower 会默认把文件备份一份到根目录的 .bower 文件中（~/.bower/）,这样可以加速
安装的库

    $ bower cache-clean # 清除缓存在 ~/.bower 中的包
    $ bower install <package-name> --offline    # 从缓存中寻找包并安装

### 使用 bower 构建你的项目（或库）

你应该在应用根目录创建 bower.json 来管理你项目的依赖；就想 npm 的
package.json 和 gem 的 Gemfile 那样，是非常有用的。

> *Note*: 在 bower 0.9.0 之前，包元数据文件称之为 `component.json`，而不是叫
`bower.json`。这样做的用意是为了避免和其他工具使用的配置文件名冲突。现在，
你仍然和是用 `component.json`，但是在将来版本会被彻底禁用。
：
使用如下命令来创建你的 `bower.json`：

    $ bower init

定义的选项如下：

+ name（必须）：包的名称
+ version：版本号
+ main［字符或者数组］：包的主要终结点（endpoints）
+ igore［数组］：在你安装包的时候，你想要 bower 忽略安装的文件路径列表
+ dependencies［哈希对象］：产品所依赖的包名
+ devDependencies［哈希对象］：开发时使用的依赖，可能是测试工具包
+ private［布尔］：如果你不希望你代码被公开，就设成 true

        {
          "name": "my-project",
          "version": "1.0.0",
          "main": "path/to/main.css",
          "ignore": [
              ".jshintrc",
              "**/*.txt"
          ],
          "dependencies": {
              "<name>": "<version>",    # 指定版本
              "<name>": "<folder>",     # 指定本地路径
              "<name>": "<package>"     # 指定 git 路径
            },
          "devDependencies": {
              "<test-framework-name>": "<version>"  #
            }
        }

定义好你的 bower.json，执行安装：

    $ bower install

你定义的依赖包将被安装在 bower_components。

### 结语

如果你看过其他的包管理工具，你可能会强加一些东西在 bower身上，尤其是缺乏了很多
包管理工具的特性。我也有同样的疑惑。当我深入了解了 bower 之后，
借用 Andrew Burgess 的话：

>   Bower 是比 Jam，Volo 和 Ender 更底层的组件。这些管理器可以借用它来
作为依赖包管理。

因此，如果你没使用过 bower，最好了解下它的命令，因为很多工具都是借助它来
构建起来。实际上，js 编程工具新贵 Yeoman 就是使用 bower 作为包管理器。如果你不
了解 Yeoman，接下来将会有专门的教程展示给大家。
的教程将会介绍到它

### 相关链接

+ [Andrew Burgess - Meet Bower](http://net.tutsplus.com/tutorials/tools-and-tips/meet-bower-a-package-manager-for-the-web/)
+ [bower 官网](http://bower.io)




