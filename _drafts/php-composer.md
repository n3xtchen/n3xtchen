---
layout: post
title: "PHP Composer - 依赖包管理器"
description: ""
category: php
tags: [php, dependency managerment]
---
{% include JB/setup %}

### 介绍

Composer 是 PHP 依赖包管理工具。它允许你声明你项目需要的依赖库，并为你安装它。

#### 依赖包管理

Composer 不是一个包管理器。是的，它处理包或者库，但是它在单个项目的基础上管理它，
并将他们安装在一个文件夹中（例如，vender）。默认他们不会全局安装任何东西。因此，
它是一个依赖管理器。

这个理念并不新鲜，Composer 是受到 Node 的 `npm` 和 Ruby 的 `bundler` 的启发而
创建的。但是它并不是唯一同类管理器工具。

Composer 解决了如下问题：

a) 你的项目需要多个库支持。
b) 一些库依赖另一个库。
c) 你需要声明你依赖的东西。
d) Composer 找出需要安装的包以及对应的版本，并且安装他。

#### 申明依赖

从你创建的项目开始，你需要一个库用来纪录日志。你决定使用 monolog。你需要创建一个
`composer.json` 来将它添加到你的项目中。

    # composer.json
    {
        "require":{
            "monolog/monolog": "1.2.*"
        }
    }

我们简单的声明我们的项目需要一些 monolog/monolog 的包，任何版本从 1.2 开始的。

#### 系统要求

Composer 要求 PHP 5.3.2 及以上的版本来运行。一些敏感的 php 配置和编译标签，并且
安装器会提示你任何不兼容的问题。

为了从源安装来代替简单的 zip 压缩包，你需要安装 git，svn 或者 hg（取决于包使用的
版本控制器）。

Composer 是跨平台的，他们努力使它在 Windows，Linux 和 OSX 上运行同样好。
