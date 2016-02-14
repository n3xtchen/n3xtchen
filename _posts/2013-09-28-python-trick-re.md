---
layout: post
title: "Python Trick"
description: ""
category: Python
tags: [python, trick, re]
---
{% include JB/setup %}

### 空白处理

#### 去除字符中的所有空格

    _string     = ' 88 11 10 '
    print   "".join(_string.split())    # 结果是 881110

### 文件路径

#### 脚本文件所在的目录

    import os
    print os.path.dirname(__file__)
