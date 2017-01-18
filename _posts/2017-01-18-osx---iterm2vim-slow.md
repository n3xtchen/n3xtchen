---
layout: post
title: "MacOs—修复 iTerm2 和 Tmux/Vim 变慢的问题"
description: ""
category: OsX
tags: [OsX]
---
{% include JB/setup %}

一旦我打开多个 Tmux 窗口，我的 Vim 就变得超级慢。

我的第一反应就是 tmux 在拖慢 vim 的数据，于是我迅速 Google 下确认它。

我去掉所有的 Vim/Tmux 插件之后，开始挖掘 iTerm2 的配置，发现了这一行：

![iTerm2 配置](https://arvid.io/content/images/2016/03/screen.png)

移除掉 **Save lines to scrollback in alternate screen mode** 选项，并设置成合理的回滚行数（我设成了 1000），延迟几乎消失了。