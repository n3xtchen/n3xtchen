---
categories:
- PHP
date: "2013-09-27T00:00:00Z"
description: ""
tags:
- php
- slim
- beginner
- lesson
title: PHP 苗条(Slim)的框架 - 第一部分
---
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

应用代码如下：

    # app.php 
    <?php
        require __DIR__.'/vendor/autoload.php'; // 使用 Composer 安装的方法
        $app = new \Slim\Slim();
        $app->get('/hello/:name', function ($name) {
            echo "Hello, $name";
        });
        $app->run();
    ?>

这里假设您使用的是 **Apache**，并且应用的目录重写模块打开，重写规则如下：（稍后我们将为你详细介绍 **Apache/Nginx** 重写规则）

    # .htaccess
    RewriteEngine On
    RewriteBase / # 代码所在 webroot 内的相对路径, 这里是在 webroot 目录内

    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{QUEST_FILENAME} !-f
    RewriteRule ^ index.php [QSA,L]

我们访问 [http:127.0.0.1/hello/slim](http:127.0.0.1/hello/slim)，浏览器中将打印 `Hello, Slim`


