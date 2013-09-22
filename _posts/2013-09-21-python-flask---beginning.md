---
layout: post
title: "Python Flask - 初探"
description: ""
category: python
tags: [python, flask, beginner, lesson]
---
{% include JB/setup %}

### 什么是 *Flask*
> [Flask](http://zh.wikipedia.org/wiki/Flask) 是一個輕量級的 Web應用框架 , 使用 Python 編寫。基於 Werkzeug WSGI 工具箱和 Jinja2 模板引擎。 Flask 使用 BSD 授權。

### 有趣的 *Flask*
    from flask import Flask
    app = Flask(__name__)

    @app.route("/")
    def hello():
        return "Hello World!"

    if __name__ == "__main__":
        app.run()

### 简单的安装
    $ pip install Flask
    $ python hello.py
     * Running on http://localhost:5000/
---
####开始享受你的 *Flask* 之旅
