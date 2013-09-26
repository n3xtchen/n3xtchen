---
layout: post
title: "Sinatra, Go!"
description: ""
category: ruby
tags: [ruby, senatra, beginning]
---
{% include JB/setup %}

*Sinatra* 是一个优雅封装最简洁的 Web 应用开发库的 **Ruby** 微框架。

### Hello *Sinatra*

    # hello.rb
    require 'sinatra'

    get '/' do
      'Hello world!'
    end

#### 安装 *Sinatra*

    $ gem install sinatra

#### 运行 *Sinatra*

    $ ruby hello.rb

### 路由（Routes）
