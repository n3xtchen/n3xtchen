---
layout: post
title:  "E: Repository 'http://url stable Release' changed its 'Origin' value from 'XX' to 'YY'"
description: ""
date:   2018-11-12 11:20:09 +0800
category: Linux
tags: [ubuntu]
---

当你在 Ubuntu 使用 `apt-get update` 的时候，我获取如下信息：

	E: Repository 'http://dl.google.com/linux/chrome/deb stable Release' changed its 'Origin' value from 'Google, Inc.' to 'Google LLC'
	N: This must be accepted explicitly before updates for this repository can be applied. See apt-secure(8) manpage for details.

### 分析

这个错误信息确定: Google Chrome 从名为 **Google LLC** 新实体获取的更新和你系统信任的 **Google, Inc** 一样。所以我们需要手动确认这个源的可信度。

### 解决方法

    ichexw in ~ $ sudo apt update
    
**注意**：这里是 `apt` 不是 `apt-get`。

然后，输入 `y` 接受这个变更：

	...
	E: Repository 'http://dl.google.com/linux/chrome/deb stable Release' changed its 'Origin' value from 'Google, Inc.' to 'Google LLC'
	N: This must be accepted explicitly before updates for this repository can be applied. See apt-secure(8) manpage for details.
	Do you want to accept these changes and continue updating from this repository? [y/N] y
	...
    
然后，就不会出现上面这个问题。

> 引用：[Stackoverflow-E: Repository 'http://dl.google.com/linux/chrome-remote-desktop/deb stable Release' changed its 'Origin' value from 'Google, Inc.' to 'Google LLC'](https://stackoverflow.com/questions/50942353/e-repository-http-dl-google-com-linux-chrome-remote-desktop-deb-stable-relea/50942354)
