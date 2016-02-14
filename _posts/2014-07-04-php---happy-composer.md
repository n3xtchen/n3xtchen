---
layout: post
title: "做一个快乐的 PHP Composer"
description: ""
category: PHP
tags: [php, composer]
---
{% include JB/setup %}

在 Web 的发展史上， PHP，Python 和 Ruby 几乎是同时出现的，PHP 以其简单的语法，较低的入门门槛，得到了广泛的传播，也是各大与排行榜单前十的常客。与 PHP 发展迅速所不相对称的是，在包管理方面发展非常缓慢，不象 node 的 npm 和 ruby 的 bundler，幸亏有了 composer 的出现，很大程度上改变这样的局势，虽然发展相对还是不够完善，但是它的存在，为 PHP 的持续流行提供了强有力的推动力。有了 Composer，你可以：

a. 你有一个依赖N多库的项目。
b. 这些库中一些又依赖于其他的库。
c. 你声明你所依赖的库。
d. Composer找出哪些包的哪个版本将会被安装，然后安装它们（也就是把它们下载到你的项目中）。

你从此不再放在各种依赖问题，而且大部分主流的 PHP 框架和工具库都已经入住 composer 的官方资源库 [packgagist](packagist.org)（你也可以把你的项目开源到 packagist 上面）。

### 安装你的 composer：

	$ curl -sS https://getcomposer.org/installer | php
	$ sudo mv composer.phar /usr/local/bin/composer	// windows 你可以设置 PATH 使得 composer 全局能访问

下面是一个让你的快乐和让你程序很好工作的小技巧。

### 1. 用 composer init 开始你的程序

composer 包含一个用 init 命令创建一个 composer.json 文件的过程：

	$ mkdir happy_composer & cd happy_composer
	$ composer init
	Package name (<vendor>/<name>) [ichexw/happy_composer]: ichexw/happy_composer
	Description []: 描述你的应用
	Author [n3xtchen <echenwen@gmail.com>]: Next Chen <echenwen@gmail.com>
	Minimum Stability []: dev
	License []: GPL-2.0
	
	Define your dependencies.

	Would you like to define your dependencies (require) interactively [yes]? no
	Would you like to define your dev dependencies (require-dev) interactively 	[yes]? no

	{
  	  "name": "ichexw/happy_composer",
  	  "description": "描述你的应用",
  	  "license": "GPL-2.0",
  	  "authors": [
          {
          	  "name": "Next Chen",
          	  "email": "echenwen@gmail.com"
          }
      ],
      "minimum-stability": "dev",
      "require": {

      }
    }

	Do you confirm generation [yes]? yes

### 2. 声明依赖关系

使用 require 命令安装你程序的依赖包。越来越多的 composer 的包可以满足你的开发需求，除了一部分旧的模块需要 pecl 来安装你的包。
	
	$ composer require monolog/monolog
	Please provide a version constraint for the monolog/monolog requirement: 1.0.*

这是 monolog 将会安装在你的项目根目录的 vendor 目录下，并将包声明记录到 composer.json 中：

	  "require": {
        "monolog/monolog": "1.0.*"
      }
      
并生成一个 composer.lock，锁定项目的特定版本，防止误更新带来项目的不稳定。

### 3. 自动加载（AutoLoad）

Composer 里面自带 PSR-0 自动加载机制，在项目里面加入下面一行代码：

	include_once 'path/to/vendor/autoload.php'; 
	
就可以直接使用 composer 安装的模块了。

### 4. 创建测试目录：

	$ mkdir Tests
	$ cat phpunit.xml
	<?xml version="1.0" encoding="UTF-8"?>

	<phpunit backupGlobals="false"
    		backupStaticAttributes="false"
    		colors="true"
    		convertErrorsToExceptions="true"
    		convertNoticesToExceptions="true"
    		convertWarningsToExceptions="true"
    		processIsolation="false"
    		stopOnFailure="false"
    		syntaxCheck="false"
    		bootstrap="vendor/autoload.php"
    	>
    	<!-- 注意指定 boostrap 的路径，不然单元测试将无法引用 compsoser 引用的包 -->
    	<testsuites>
        	<testsuite name="PHP Jawbone-Up ">
            	<directory>./Tests/</directory>
            	<!-- 只是测试目录 -->
        	</testsuite>
    	</testsuites>

    	<filter>
        	<whitelist>
            	<directory>./</directory>
            	<exclude>
            		<!-- 指定测试不覆盖的代码 -->
                	<directory>./vendor</directory>
                	<directory>./Tests</directory>
            	</exclude>
        	</whitelist>
    	</filter>
	</phpunit>
	
如果你还没有安装 phpunit 的，也可以使用 composer 来安装；对于 phpunit 这类全局的组建，你可以进行系统级的安装：

	composer global require "phpunit/phpunit=4.1.*"
	
请确保 path 变量中包含有 ~/.composer/vendor/bin/；这样你就可以直接使用 phpunit 了。

### 结语

由于受到 《[快乐Node程序员的10个习惯](http://www.kuqin.com/shuoit/20140630/340906.html)》 启发，于是决定写下了这些，希望能对大家有所帮助，顺便宣传下 composer。