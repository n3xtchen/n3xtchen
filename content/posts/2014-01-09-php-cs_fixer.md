---
categories:
- PHP
date: "2014-01-09T00:00:00Z"
description: ""
tags:
- PHP
- PSR
- Tools
title: PHP PHP-CS_Fixer - 使用 PSR 格式化你的代码
---

- 如果你已经使用了 PHP_CodeSniffer 来检查你的代码规范问题，通过手动去修复他们可能
会是个噩梦，尤其是在大项目中;怎么办

- 当我在调试代码之后，突然发现我已经把代码搞得乱七八糟了；怎么办？

- 我平时都适用 IDE 自带的格式化工具，但是它不是按照 PSR 的规范；怎么办？

PHP-CS-Fixer 来拯救你；全名：PHP Coding Standards Fixer，它就是为了解决根据 PSR 规
范修复你代码大部分不符合规范的的修复工具。

> 如果你还不知道什么 PSR 和 PHP_CodeSniffer, 请看 [PHP CodeSniffer - 使用 PSR 规范你的PHP代码](http://n3xtchen.github.io/n3xtchen/php/2014/01/08/php-code_sniffer/)

### 安装 PHP-CS-Fixer

下载 [php-cs-fixer.phar](http://cs.sensiolabs.org/get/php-cs-fixer.phar) 文件；确保你的文件路径包含在 PATH 中，就可以直接使用；

如果是 Linux 用户还需要给该文件可执行的权限：
    
    $ sudo chmod a+x /path/to/php-cs-fixer

也可以使用 Composer 来安装：

    $ composer global require 'fabpot/PHP-CS-Fixer=*'

确保 ~/.composer/vendor/bin/ 这个路径在你的全局 PATH 中。

对于 Mac 用户，还可以使用 homebrew（Mac Port 的替代者） 来安装

    $ brew tap josegonzalez/homebrew-php
    $ brew install php-cs-fixer

#### 如何更新你的 PHP-CS-Fixer 让他支持最新的标准规范：

对于非 homebrew 安装的用户忙，可以：

    $ sudo php-cs-fixer self-update # window 用户不需要使用 sudo

Homebrew 的用户：

    $ brew upgrade php-cs-fixer

### 开始使用吧！

    $ php-cs-fixer fix /path/to/dir/or/file --level=all


`level` 用来选择格式化依据的标准，有 psr0，prs1，psr2，all；默认是选择 psr-2 标准

> 详尽的使用文档请见：[docs](https://github.com/fabpot/PHP-CS-Fixer)

### IDE 整合

IDE 还是大部分选择的主要开发工具，一定程度上是提升了不少开发体验；

PHP-CS-Fixer 不例外也对大部分 IDE 的支持

#### Netbeans

1. 打开 NetBeans；
2. 进入 Tool => Plugins => Download ，然后点击 Plugin；
3. 进入 Available Plugins 搜索 php cs fixer ，选中 PHP CS Fixer 确认安装；
4. 进入 Tool 标签页 => Options => PHP , 名称为 PHP CS Fixer；
5. 将 php-cs-fixer 执行文件的绝对路径填入 PHP CS Fixer；勾选 --level，选择 all；
6. 文件右键点击就可以看到 PHP CS Fixer 的菜单了；

Happy，Fixing!







