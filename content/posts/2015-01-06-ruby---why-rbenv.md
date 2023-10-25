---
categories:
- Ruby
date: "2015-01-06T00:00:00Z"
description: ""
tags:
- rbenv
title: Ruby - Why rbenv?
---

> 译自 https://github.com/sstephenson/rbenv/wiki/Why-rbenv%3F

## **rbenv** 能做…

* 提供应用级别（application-specific）的 **Ruby** 版本控制；
* 为每个登录用户设置不同的全局 **Ruby** 版本；
* 允许你使用环境变量来覆盖系统的 **Ruby** 版本。

## 和 **RVM** 不同的是，**rbenv** 不需要做…

* *需要重载到 Shell*。 而 **rbenv** 提供一个更简便的方法，只需要把路径添加到 `$PATH` 变量中即可。
* *覆盖 Shell 命令（如 `cd`）或者需要及时破解（prompt hacks）*。这样做是很危险的，而且容易出错（error-prone）。
* *需要配置文件*。除了配置你所需要的 **Ruby** 版本外，你不需要做其他任何事情。
* *安装 Ruby*。你可以自己编译安装 **Ruby**，或者使用 **ruby-build** 自动化这个安装过程；
* *管理 gemsets*。**Bundler** 是管理应用依赖的最好方式哦。如果你的项目还没使用 **Bundler**的话，你可以通过安装 **rbenv-gemset** 来使用这个特性。
* *为了兼容，需要改变 Ruby 库*。**rbenv** 的简单之处就在于，一旦你把它设置到环境变量之后，其它你都不需要管了。
