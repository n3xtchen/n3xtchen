---
layout: post
title: "PHP CodeSniffer - 规范你的PHP代码"
description: ""
category: PHP
tags: [PHP, Tools]
---
{% include JB/setup %}

- 风格一致性使你的代码更加专业；相同项目的风格不一致（更坏的，是在同一个文件多个
编码风格）不仅看起来很邋遢，更纵容了将来的不严谨风格的产生；

- 当编码风格符合统一标准，错误的代码也很容易察觉；

- 对于后续的维护人员来说，也更容易调试，修复错误已经拓展功能；

- 维护不一致代码的时候，有时开发者将会重新格式化代码来适应他们。这样会造成代码库
的大范围变动；如果将来造成问题，使用差异化对比工具将无法通过对比代码来排除 Bug。

如果你出现上述问题，那么 PHP_CodeSniffer 就是你的绝佳选择之一，尤其对于 PHP 开发者来说。

### 安装你的 PHP_CodeSniffer（注意，PHP 5.1.2 骨灰级的开发者请绕行） 

使用 PERA 是最简单的安装方式，首先请确认你已经安装了 PEAR：

    pear install PHP_CodeSniffer

使用 `pear config-get php_dir` 查找 PEAR 的目录，然后创建 
"/PHP/CodeSniffer/Standards" 目录（用来存放标准规则的）；

也可以使用新潮的安装工具 Composer（不知道，你就 OUT了！） 来安装）：

    composer global require 'squizlabs/php_codesniffer=*'

确保 ~/.composer/vendor/bin/ 这个路径在你的全局 PATH 中。

如果执行下述命令，说明你成功了；

    $ phpcs --version
    PHP_CodeSniffer version 1.5.1 (stable) by Squiz (http://www.squiz.net)

定制代码规范的存放目录：~/.composer/vendor/squizlabs/php_codesniffer/CodeSniffer/Standards

> #### PHP_CodeSniffer 源

> Pear：[http://pear.php.net/package/PHP_CodeSniffer](http://pear.php.net/package/PHP_CodeSniffer)

> GitHub（非官方）：[https://github.com/squizlabs/PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)

### 开始用 PHP_CodeSniffer

    phpcs file/to/sniff

或者指定你想要支持的标准，可以这么用：

    phpcs --standard=build/phpcs/Joomla path/to/file/or/folder

> 详尽的文档请见：[docs](http://pear.php.net/package/PHP_CodeSniffer/docs)

### 通用的 PHP 代码规范（重点哦）

下面中文版的规范：

+ [PSR-0](http://n3xtchen.github.io/n3xtchen/php/2014/01/05/php-fig---psr-0/)
+ [PSR-1](http://n3xtchen.github.io/n3xtchen/php/2014/01/05/php-fig---psr-1/)
+ [PSR-2](http://n3xtchen.github.io/n3xtchen/php/2014/01/05/php-fig---psr-2/)
+ [PSR-3](http://n3xtchen.github.io/n3xtchen/php/2014/01/05/php-fig---psr-3/)
+ [PSR-4](http://n3xtchen.github.io/n3xtchen/php/2014/01/05/php-fig---psr-4/)

由于 PHP 权威的项目支持，个人认为及其有可能发展成为 PHP 的业界的规范；
加入该标准的项目：

+ Composer
+ Doctrine
+ Drupal
+ Laravel
+ PEAR
+ Propel
+ Symfony2
+ Yii framework
+ Zend Framework 2
+ 。。。

> 详见：[FIG](http://www.php-fig.org/)

#### 安装 PSR-0，PSR-1，PSR-2 规则

下载地址：[Standards](https://github.com/squizlabs/PHP_CodeSniffer/tree/master/CodeSniffer/Standards)

如果，你使用 Xampp，把 PSR-1 的规则解压到 \xampp\php\PEAR\PHP\CodeSniffer\Standards\PSR 
(其他名称也可以)，IDE 会识别到；

### IDE 整合

虽然使用终端命令是最高效的方式，但是可能你需要更好的使用体验，即使是 Linux 大牛。

幸运的是，Eclipse，Netbean 和 PHPStorm 都有相关的插件支持，因此任何代码标准冲突
都可以和普通一样被展示。

#### Netbeans

1. 打开 NetBeans；
2. 进入 Tool => Plugins => Download ，然后点击 Plugin；
3. 搜索选中载入的 phpmdnb 文件，确认安装；
4. 进入 Tool 标签页 => Options => PHP , 名称为 PHPCodeSniffer；
5. 你需要设置 phpcs.bat 到路径所在：
    + Unix，使用 /usr/bin/phpcs（你可以使用 which 命令查找 phpcs 的路径）;
    + Xampp 中，你可以在 PHP 的根目录内找到该文件；
6. Standard 类型选择 PSR 来；
7. 现在，你点击测试 Settings 来检查配置，单击 OK 来完成安装；
8. 打开任务窗口（Window => Tasks）来检测代码；
9. 大部分时间使用任务（只有在编辑文件，或者创建自己的过滤器会现实错误）。

#### Eclipse（未测试）

安装非常简单，遵循通常的操作：

1. Help => Install new Software...
2. 填入网址： http://www.phpsrc.org/eclipse/pti/
3. 选择想要的工具
4. 重启

你现在就能使用通用的标准如 PEAR 和 ZEND 等等来检查代码规范；

使用自己的规范，所做的就是制定他们位置，然后激活它就可以：

1. Window => Preferences
2. PHP Tools => PHP CodeSniffer

Happy Sniffing!
