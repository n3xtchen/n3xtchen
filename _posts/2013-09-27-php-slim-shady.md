---
layout: post
title: "PHP 苗条(Slim)的框架 - 第一部分"
description: ""
category: php 
tags: [php, slim, beginner, lesson]
---
{% include JB/setup %}
### 我叫 *Slim*

*Slim* 是一个 **PHP** 微框架，它帮助我们快速的编写简单而且强大的网络应用和借口。

#### 特性
* 强大的路由（Router）
    * 标准和可定制的 HTTP 请求方式
    * 路由参数可使用通配符和条件
    * 重定向，停止以及传递
    * 路由中间件
* 自定义模版（Template）
* 消息
* 使用 AES-256 加密的安全 cookies
* HTTP 缓存
* 自定义日志 
* 错误处理和调试
* 中间件和钩子架构
* 简单的配置

#### 系统要求
     PHP 5.3.0 以上

### 安装

#### Mac OS(with homebrew)
    $ brew tap josegonzalez/php
    $ brew install PHP53    # 如果你未安装 homebrew-php 的话
    $ brew install composer
    $ cat composer.json # 创建和这个内容相同
        {
            "require": {
                    "slim/slim": "2.*"
                }
        }
    $ composer install

#### 手动安装
    $ wget https://github.com/codeguy/Slim/zipball/master
    $ unzip master app_name

### Hello, Slim

