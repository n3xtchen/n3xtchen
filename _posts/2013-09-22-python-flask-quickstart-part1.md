---
layout: post
title: "Python Flask 快速入门-第一部分"
description: ""
category: python
tags: [python, flask, beginner, lesson]
---
{% include JB/setup %}
### 最小 *Flask* 应用
    # filename: hello.py
    from flask import Flask # 导入 Flask 模块
    app = Flask(__name__)   # 实例化 Flask 对象

    @app.route('/') # 绑定路由
    def hello_world():  # 声明路由操作函数
        return 'Hello World!'

    if __name__ == '__main__':
        app.run()   # 在本地服务器运行应用

在 `shell` 中运行:

    $ python hello.py
     * Running on http://127.0.0.1:5000/

浏览器中键入 [127.0.0.1:5000/](127.0.0.1:5000/), 显示 *Hello World!*；`control-C` 终止服务器。

### 外部可访问的服务器
    app.run(host='0.0.0.0')

`run` 的默认Host:*127.0.0.1*, 只有本机允许访问。

[0.0.0.0]() 作为`host`值，告诉你的操作系统监听所有的公共IP地址。

### *Debug* 模式

**run()** 能漂亮地启动一个本地开发服务器，但是代码的改动都需要手动重启它。这样子一定都不美，而且*Falsk*能做的更好。
如果你在开启 `debug` 支持，服务器将在每次代码变动时重新载入，而且它将会提供你非常有用的调试，如果你的代码存在错误。

有如下两种方式开始调试器；传入一个`flag`给应用对象：

    app.debug = True
    app.run()

或者传递一个参数给`run`：

    app.run(debug=True)

如上这两种方法都可以生效。
