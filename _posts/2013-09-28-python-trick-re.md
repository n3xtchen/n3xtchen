---
layout: post
title: "Python Trick - 常见字符处理"
description: ""
category: python
tags: [python, trick, re]
---
{% include JB/setup %}

### 空白处理

#### 去除字符中的所有空格

    _string     = ' 88 11 10 '
    print   "".join(_string.split())    # 结果是 881110
