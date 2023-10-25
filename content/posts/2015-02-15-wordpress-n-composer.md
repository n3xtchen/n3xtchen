---
categories:
- PHP
date: "2015-02-15T00:00:00Z"
description: ""
tags:
- composer
- wordpress
title: 使用 composer 管理 wordpress 应用包依赖
---

这篇文章，我们将使用 **Composer** 来管理 **Wordpress Core**，插件以及主题。

当你考虑构建标准的 WP 站点的时候，关于依赖（Dependencies）的最简单例子就是插件。但是你需要意识到：**Wordpress 本身也是一个插件**。

首先，你得认识到 **Wordpress** 核心（Core）实际上是一个第三方库。这个概念对于你来说不好理解，是因为大部分 **Wordpress** 站点结构像下面这样的：

	index.php
	license.txt
	readme.html
	wp-activate.php
	wp-admin
	wp-blog-header.php
	wp-comments-post.php
	wp-config-sample.php
	wp-content
	wp-cron.php
	wp-includes
	wp-links-opml.php
	wp-load.php
	wp-login.php
	wp-mail.php
	wp-settings.php
	wp-signup.php
	wp-trackback.php
	xmlrpc.php
	
你应该很熟悉这样的文件夹结构吧。**Wordpress Core** 文件就在你的项目根目录下。*wp-content* 中包含的是应用层面的代码，比如主题和插件。这样的结构确实很难能让人想到 **Wordpress Core** 是一个第三方库，而我们一般都在 *wp-content* 目录下编写代码和安装第三方插件。

庆幸的是，大部人也认为这样做是不合理，应该把 **Wordpress** 放到他的子目录。因为我们很少去改动（实际上是不允许的，会导致升级问题）**Wordpress Core** 代码，像下面这样才合理：

	wp-content
	index.php
	wp
	wp-config.php
	
接着进一步该井，将 **Wordpress** 作为 **Git** 子模块。[WordPress-Skeleton](https://github.com/markjaquith/WordPress-Skeleton) 就是一个例子。你的文件结构同上，但是 *wp/* 文件夹不是你的代码库的一部分，因为它是独立的子模块。

如果你读过 [Git 子模块也不是处理依赖的好方法](http://somethingsinistral.net/blog/git-submodules-are-probably-not-the-answer/) ，这就是为什么我们选用 **composer** 的原因了。

> Git 子模块请参见： [Git 工具 - 子模块](http://git-scm.com/book/zh/v1/Git-%E5%B7%A5%E5%85%B7-%E5%AD%90%E6%A8%A1%E5%9D%97)

常规的 **Composer** 包只会被安装在 *vendor/* 中，你不能为每个包选择不同的安装目录。

当然也有可以变通的方法，否则这篇博客就不存在了。

## 配置 composer.json

在讨论变通方法之前，先看看实例：
	
	{
	  "repositories": [
	    {
	      "type": "package",
	      "package": {
	        "name": "wordpress",
	        "type": "webroot",
	        "version": "3.8",
	        "dist": {
	          "type": "zip",
	          "url": "https://github.com/WordPress/WordPress/archive/3.8.zip"
	        },
	        "require" : {
	          "fancyguy/webroot-installer": "1.0.0"
	        }
	      }
	    }
	  ],
	  "require": {
	    "php": ">=5.3.0",
	    "wordpress": "3.8",
	    "fancyguy/webroot-installer": "1.0.0"
	  },
	  "extra": {
	    "webroot-dir": "wp",
	    "webroot-package": "wordpress"
	  }
	}

知道 **Packagist** 吗？他是 **PHP** 插件源代码库。每一个包需要自己的源代码库。因此，如果你需要的库不在 **Packagist** 中怎么办呢？哈哈，你可以自定义源。

由于 **Wordpress** 还不是一个正式的 **Composer** 包，我们需要自定义一个源:

	"repositories": [
	   {
	     "type": "package",
	     "package": {
	       "name": "wordpress",
	       "type": "webroot",
	       "version": "3.8",
	       "dist": {
	         "type": "zip",
	         "url": "https://github.com/WordPress/WordPress/archive/3.8.zip"
	       },
	       "require" : {
	         "fancyguy/webroot-installer": "1.0.0"
	       }
	     }
	   }
	]
	
上面这段 **Json** 自定义一个代码库。这就是使用 **Composer** 引入外部项目最灵活的方式了，你不需要给被引入的包编写 *composer.json*。还有另外一个小技巧，**webroot-installer**；它是一个自定义安装器，让我们可以为任何包定义安装路径。自定义安装需要在包类型中指定才能生效，在我们的源配置中也有用到。

另外你需要注意的是：

	"extra": {
	   "webroot-dir": "wp",
	   "webroot-package": "wordpress"
	 }
	 
我们想要把名叫 **Wordpress** 的包安装在 *wp* 目录下；这个就是我们上述配置中实际完成的工作。

## 安装

现在我们已经有了一个可用的 *composer.json* 的文件，然后我们要做的就是安装它。我们需要执行 `composer install`：

	Loading composer repositories with package information
	Installing dependencies (including require-dev)
	  - Installing fancyguy/webroot-installer (1.0.0)
	    Downloading: 100%
	
	  - Installing wordpress (3.8)
	    Downloading: 100%
	
	Writing lock file
	Generating autoload files
	
然后产生的文件如下：

	composer.json  composer.lock  vendor  wp
	
这时，我按照[将WordPress安装在网站子目录](http://www.wopus.org/wordpress-deepin/tech/95.html) 的步骤完成设置，修改 *wp-content* 目录路径。完成后，我们的目录结构如下所示：

	├── composer.json
	├── composer.lock
	├── index.php
	├── vendor
	├── wp
	├── wp-config.php
	└── wp-content

## 更多关于包的安装

我之前说过的，“所有的包都会被安装到 *vendor/* 目录下，并你不能改变它“，这实际上是一个谎言；因为我使用了自定义安装器改变了包的安装路径。好吧，还是有多种方式改变你的安装目录路径。但是只有包引入了 **composer-installers** 才能用。（记住，**Wordpress Core** 实现它，因为它没有一个 *composer.json* 文件）。

**composer-installers** 为一个包指定它的类型和自定义的安装目录。他们已经包含了一些我们需要的类型：

	* wordpress-plugin => wp-content/plugins/{$name}/
	* wordpress-theme => wp-content/themes/{$name}/
	* wordpress-muplugin => wp-content/mu-plugins/{$name}/

因此，任何带有 `wordpress-plugin` 的类型的包都会默认被安装到 *wp-content/plugins/{$name}/* 目录中。

### 插件(Plugins)

因此，我们已经安装好了 **Wordpress**，现在我们想安装一些插件。多亏了有 **composer-installers**，我们可以把他们安装到正确的位置，不是吗？

是的，但是插件需要有一个 *composer.josn*，引入 **composer-installers**，并且它们包的类型要设置正确。明显，目前这样的包不是很多。我们为你找一个，[wordpress-monolog](https://packagist.org/packages/fancyguy/wordpress-monolog)。

让我们把它添加到我们的 *composer.josn* 中：

	"require": {
	   "php": ">=5.3.0",
	   "wordpress": "3.8",
	   "fancyguy/webroot-installer": "1.0.0",
	   "fancyguy/wordpress-monolog": "dev-master"
	 }
	 
然后我们执行 `composer update`，你将会看到 wordpress-monolog 被安装到 *wp-content/plugins/wordpress-monolog*。

## WordPress Packagist

幸运的是，有一个叫做 [wpackagist](http://wpackagist.org/)（由 http://outlandish.com/ 维护），里面的包都针对 wordpress 优化过的插件包。

	这个站点提供了支持 Composer 的 WordPress 插件库镜像。
	
基本上，它们保存了所有的 WordPress 插件，并加上了 *composer.josn*，包含 *composer-installers*，并且指定为 wordpress-plugin 包类型。

它的用法也简单：

1. 把源添加到你的 *composer.josn* 中
2. 添加你想要的插件到 `require` 中，使用 **wpackagist** 作为 *vendor* 名
3. 然后执行 `composer update`
4. 插件将会安装到 *wp-content/plugins/* 中。

添加几个插件后，我们的 *composer.josn* 最终会变成这样：

	{
	  "repositories": [
	    {
	      "type": "composer",
	      "url": "http://wpackagist.org"
	    },
	    {
	      "type": "package",
	      "package": {
	        "name": "wordpress",
	        "type": "webroot",
	        "version": "3.8",
	        "dist": {
	          "type": "zip",
	          "url": "https://github.com/WordPress/WordPress/archive/3.8.zip"
	        },
	        "require": {
	          "fancyguy/webroot-installer": "1.0.0"
	        }
	      }
	    }
	  ],
	  "require": {
	    "php": ">=5.3.0",
	    "wordpress": "3.8",
	    "fancyguy/webroot-installer": "1.0.0",
	    "fancyguy/wordpress-monolog": "dev-master",
	    "wpackagist/advanced-custom-fields": "*",
	    "wpackagist/posts-to-posts": "1.4.x"
	  },
	  "extra": {
	    "webroot-dir": "wp",
	    "webroot-package": "wordpress"
	  }
	}

## 结语

混沌代码布局，现在总算抽离开了。看起来舒服多了，难道不是吗？至少对于我来说，是的！

> http://roots.io/using-composer-with-wordpress/
	
