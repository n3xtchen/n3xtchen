---
layout: post
title: "Linux - 调整 /home 分区"
description: ""
category: Linux
tags: [linux, disk-partion]
---
{% include JB/setup %}

> 摘自 http://www.ibm.com/developerworks/cn/linux/l-tip-prompt/tip05/

/home 是最经常被移动的分区。某些时候，/home 中的全部空间都用完了，而且需要增加
一个硬盘驱动器。另一些时候，/home 被设置为根分区的一部分，为了提高性能或便于备
份，可能需要将它移动到别的地方。

> **警告**

> 下面的技术说明如何移动一个或多个分区。尽管这项技术的设计使您能够“撤销”失败的
分区移动，但它并不防止用户的错误。换言之，只要进行格式化分区或复制大量文件的操
作，就存在因输入错误而导致大量数据被破坏的可能性。因此，强烈建议您 在行动之前采
取适当的措施来备份所有的重要文件。

### 1.创建新分区

安装完硬盘， 你需要在该硬盘上创建分区；

你可能需要使用的工具：

+ 命令行的有：cfdisk 或者 fdisk
+ 图形分区工具：Parted

在创建了适当的主分区或扩展分区以后，应重新启动系统以便正确地重新读取分区表。这是
唯一需要重启系统的时候。

### 2.在新分区上创建文件系统

假设我们第一步创建了一个分区（路径为：/dev/sdb1）

    $ sudo mkfs.ext4 /dev/sdb1  # 不一定一定要 ext4

### 3.挂载新分区

    $ sudo mkdir /mnt/new_home
    $ sudo monnt /dev/sdb1 /mnt/new_home

### 4.进入单用户

在更新新分区的时候，我们必须保证 /home 的所有文件都是关闭状态，没有被打开；进入
单用户模式，就为了消除这一点：

    $ sudo -i   # 进入超管用户
    password: ******
    # init 1    

### 复制原先的 /home 目录文件到新的分区中
    
    # cp -ax /home/* /mnt/newpart

cp -ax 命令循环地将 /home 中的内容复制到 /mnt/newpart 中，并保留全部文件属性，
也不会交叉任何挂载点

### 使用新分区

#### 原先 /home 目录是一个分区时

    # cd /
    # umount /home
    # umount /mnt/new_home
    # mount /dev/sdb1 /home

**重要步骤**

使用超级用户编辑 /etc/fstab

替换该行：

    /dev/xx /home   some_fs    defaults    1   2

为

    /dev/sda1   /home ext4  defaults    1   2

#### 原先 /home 目录不是一个分区时

假设 /home 目录和根目录在同一分区，也就是说这时，/home 只是一个目录的时候

    # cd /
    # mv /home /home.old
    # mkdir /home      
    # mount /dev/sdb1 /home

**重要步骤**

使用超级用户编辑 /etc/fstab

添加该行：

    /dev/sda1   /home ext4  defaults    1   2

### 7. 扫尾工作
我们特意将原来的 /home 目录/分区保留下来，以防复制文件时出现问题。在证实系
统稳定运行以后，您就可以将原来的 /home 分区用于其他目的，或者删除原来的 
/home 目录。
