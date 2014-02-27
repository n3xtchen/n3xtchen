---
layout: post
title: "Data Pig - 手动安装（Local 模式）"
tagline: ""
description: ""
category: Hadoop
tags: [hadoop, pig]
---
{% include JB/setup %}

### 安装环境：

#### 软件列表：

+ Java-1.6.0 或者更高的版本
+ ant（包含 ant-withouthadoop）

#### 设置环境变量：

    $ export JAVA_HOME=path/to/java/home

### 从源码中安装:

    $ svn co http://svn.apache.org/repos/asf/pig/trunk /<my-path-to-pig>/pig-n.n.n
    $ export PATH=/<my-path-to-pig>/pig-n.n.n/bin:$PATH
    $ export PIG_HOME=/<my-path-to-pig>/pig-n.n.n/

#### 安装本地运行（Local）模式

    $ cd $PIG_HOME
    $ ant jar-withouthadoop

#### 安装 Piggybank

    $ cd $PIG_HOME
    $ cd contrib/piggybank/java/
    $ ant

#### 运行 Pig：

交互模式：

    $ pig -x local
    ...
    grunt> 

批处理模式：

    $ pig -x local xxx.pig
    ...

### 简单的配置

    $ cat $PIG_HOME/conf/pig.properties
    ...
    #exectype local|mapreduce, mapreduce is default
    exectype=local  # 设置它的默认模式，你就不需要使用 -x local 参数
    ...
    ...
    pig.logfile=/home/vagrant/pig/logs/ # 配置你日志搭默认路径，不设置日志将会在运行的当前目录
    ...
