---
layout: post
title: "R 入门笔记 - 库管理"
tagline: "Packages"
description: ""
category: R
tags: [R]
---
{% include JB/setup %}

### 载入包

你可以使用 library 函数载入你安装好的包：

    > library(package_name)

这个函数名让人感觉很怪异，如果叫 load_package 可能会更好理解，但是历史原因，
很难改变了。我们可以把 package 当作 R 函数和数据集的集合，一个 library 用来
保存这个 package 的文件。

注意，传入的包名是没有引号的，如果你的包名是字符型，应该这么处理：

    > library("package_name", character.only =TRUE)

如果你使用的包没有安装，则会抛出一个异常，有时你需要处理这个情况：

    > if (!require(noExistedPackage))
    + {
    +     warning("warn msg");
    + }

### 查看已经载入的包

    > search()
    [1] ".GlobalEnv"        "package:stats"     "package:graphics" 
    [4] "package:grDevices" "package:utils"     "package:datasets" 
    [7] "package:methods"   "Autoloads"         "package:base"   

### 库和安装的包

查看安装的包：

    > installed.packages()

查看 R 公共库的默认安装路径：

    > R.home("library")
    # 或者
    > .library()
    [1] /path/to/r/3.0.2/R.framework/Versions/3.0/Resources/library

查看 R 用户库的安装路径：

    > path.expand("~")
    # 或者
    > Sys.getenv("HOME")
    [1] /home/xx-user/

查看所有库的路径，第一个是默认安装路径：

    > .libPaths()
    [1] /path/to/r/3.0.2/R.framework/Versions/3.0/Resources/library
    [2] /home/xx-user/


### 包安装

    > install.packages(
    +    c("xts", "zoo"),    # 指定要安装的包
    +    lib   = "some/other/folder/to/install/to",  # 指定安装位置
    +    repos = "http://www.stats.bris.ac.uk/R/"    # 指定安装来源
    + )

    # 从安装包中安装
    > install.packages(
    +     "path/to/downloaded/file/xts_0.8-8.tar.gz",
    +     repos = NULL, #NULL repo 代表已经下载
    +     type = "source" # 直接安装
    + )

还可以直接从Github下载安装，不过得安装 devtools：

    > install.packages("devtools")

使用方法:

    > library(devtools)
    > install_github("knitr", "yihui")

### 维护

    # 更新包
    > update.packages(ask = FALSE)
    # 删除包
    > remove.packages("packName");

> *Note*：Os X 报错 `fatal error: 'libintl.h' file not found` 的解决方案：
> 
>   $ brew intall gettext
>   $ find ./ -name "libintl.*"
>   ./0.18.3.2/include/libintl.h
>   ./0.18.3.2/lib/libintl.8.dylib
>   ./0.18.3.2/lib/libintl.a
>   ./0.18.3.2/lib/libintl.dylib
>   ./0.18.3.2/share/gettext/intl/libintl.rc
>   $ ln -s /usr/local/Cellar/gettext/0.18.3.2/lib/libintl.* /usr/local/lib/
>   $ ln -s /usr/local/Cellar/gettext/0.18.3.2/include/libintl.h /usr/local/include/libintl.h

