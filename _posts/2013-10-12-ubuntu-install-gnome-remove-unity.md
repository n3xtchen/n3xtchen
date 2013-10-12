---
layout: post
title: "Ubuntu 12.04 - 安装 Gnome 卸载 Unity"
description: ""
category: linux
tags: [ubuntu, gnome, unity]
---
{% include JB/setup %}

> 摘自 http://blog.csdn.net/x504635/article/details/8210422

### 安装 Gnome

    sudo apt-get install gnome-session-fallback 
    # or gnome-panel

### Gnome 设置为默认桌面：

    sudo /usr/lib/lightdm/lightdm-set-defaults -s gnome-classic
    # 如果你喜欢 gnome3 用下面的命令
    sudo /usr/lib/lightdm/lightdm-set-defaults -s gnome-shell

### 卸载 Unity

    sudo apt-get -y –auto-remove purge unity
    sudo apt-get -y –auto-remove purge unity-common
    sudo apt-get -y –auto-remove purge unity-lens*
    sudo apt-get -y –auto-remove purge unity-services
    sudo apt-get -y –auto-remove purge unity-asset-pool

