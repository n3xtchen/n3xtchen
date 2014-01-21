---
layout: post
title: "Javascript Bower - 发布自己的 bower 库"
tagline: "包管理工具 For UI/UE"
description: ""
category: javascript
tags: [javascript, package_manager]
---
{% include JB/setup %}

让我们开始建立一个属于自己的超级简单的 bower 自定义库。它将会是一个无意义的
包，但是它将设计创建的每一个步骤。

### 一. 创建你的 bower.json

首先创建一个项目目录，命名为 next。

然后在目录下创建 bower.json，类似如下：

    {
      "name": "demo",
      "version": "1.0.0",
      "authors": [
        "n3xtchen <echenwen@gmail.com>"
      ],
      "main": {
          "demo": "./demo.js"
      },
      "dependencies"  : {         
          "jquery":   "1.10.*"    
      }
      "license": "MIT"
    }

这是我使用 `bower init` 命令创建和修改的，除了 `main` 之外，其他属性应该都
很熟悉。（不熟悉请见 [上一个教程]({% post_url 2014-01-16-javascript-bower-starter %})）

`main` 属性应该是你主程序脚本的路径，如果有多个程序脚本，应该使用数组。实际
上，该属性的实际用法官方也未确认；但是有一个建议，它应该是一个对象，相关代码
的特征名为键名，值是相关代码路径的字符串；如果包含多个文件（每种文件类型只能
有一个，例如还可以有一个 .html，.css 文件），使用数组。

    ...
    "main": {
      “modal”: [“lib/modal.js, “css/modal.css”],
      “carrousel”: [“lib/carrousel.js”, “css/carrousel.css”]
    },
    ...

### 二. 创建你 git 版本库

初始化 git，上传上一步骤创建的 bower.json

    $ git init
    $ git add bower.json
    $ git commit -m '添加 bower.json'
    $ bower install

现在，我们编写 demo.js：

    function sayHi() {
        alert('Hello, World!');
    }

现在我们把它推送到 github 上：

    $ git add demo.js
    $ git commit -m '添加 demo.js'

接着，我们需要添加 git 的语义化版本标签：

    $ git tag -a 1.0.0 -m 'demo v1.0.0'

最后，我们把它上传到 github 上。

### 三. 登记你的 bower 库

    $ bower register packageName git://your/git/url.git

当然，我们不会真的把这个库登记到 bower 上。但是，bower 也可以安装本地的包。
我所要做的的就是模拟一个 Github，创建这个源的 bare 克隆：

    $ git clone --bare path/to/demo path/to/demo.git

现在我们就可以通过这个源的地址来安装自定义的库了：

    $ bower install path/to/sayHi.git

安装的过程中，它的相关依赖也会被安装。

> #### 小结
> 
> 发布你的库需要下述条件：
> 
> + 在主目录必须有有效的 mainifest JSON文件（就是 bower.json）;
> + 应该使用 Git 的语义化版本标签；
> + 你的包必须上传到 Github 上；
> 
> 然后使用如下命令：
> 
>     bower regiter <my_package-name> <git-endpoint>

#### 享受你的自定义 bower 库！

