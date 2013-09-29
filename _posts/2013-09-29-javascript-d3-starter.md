---
layout: post
title: "Javascript D3 - Starter"
description: ""
category: javascript
tags: [javascript, d3, beginner, lesson]
---
{% include JB/setup %}

### 什么是 *D3.js*

*D3.js* (D3或Data-Driven Documents）是一个用动态图形显示数据的**JavaScript**库，一个数据可视化的工具。兼容**W3C**标准，并且利用广泛实现的**SVG**，**JavaScript**，和**CSS**标准。)

### 安装 *D3.js*

#### 下载

    wget http://d3js.org/d3.v3.zip  # 当前的版本 v3

压缩包包含的文件：

    Archive:  d3.v3.zip
        inflating: LICENSE                 
        inflating: d3.v3.js                
        inflating: d3.v3.min.js 

#### 应用的基本目录结构

    ├── index.html
    └── lib
        ├── LICENSE
        ├── d3.v3.js
        └── d3.v3.min.js

#### **Html**模版

    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <title>D3 页面模版</title>
            <script type="text/javascript" src="lib/d3.v3.js"></script>
        </head>
        <body>
            <script type="text/javascript">
            // 漂亮的D3代码将会这里
            </script>
        </body>
    </html>

#### 设置网页服务器

有时，你可以在你的浏览器浏览本地的**HTML**文档。但是，一些浏览器考虑到安全问题，限制通过 **javascript** 访问本地的文件。这意味这如果你的 *D3* 代码尝试从外部数据文件（例如 CSV 或者 JSON）获取数据，它就会失败。这不是 *D3* 的错；这是浏览器的特征，为了防止载入第三方不可信的网站的JS。

综上各种原因，通过网页服服务器加载你的页面将更可靠。

好消息就是让你的本地服务器运行起来非常简单。这里提供了一些方法：

##### 带 **Python** 的命令行(Terminal)

1. 打开你的命令行
2. 通过命令行，定位到你想要提供页面服务的目录（文件夹）。例如，如果你的项目文件夹位于桌面，你可以输入： `cd ~/Desktop/app-dir`
3. 在终端中，键入 `python -m SimpleHTTPServer 8888 &`

这样，你就可以在 [http://127.0.0.1:8888](http://127.0.0.1:8888)

##### MAMP(Mac Os), WAMP(Windows) 和 LAMP(Linux)

针对你的系统，下载 **AMP** 服务器软件; 它包括 Apache（服务器软件）, MySQL（数据库软件 和 PHP（网页脚本语言）。(详细参照 各自的安装文档)


