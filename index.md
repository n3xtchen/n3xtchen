---
layout: page
title: Welcome To N3xt-Tech!
---
{% include JB/setup %}

    在这里，一同享受技术为我们带来无限乐趣！

### 最新 Blog

Hello, Blogger! 欢迎访问与评论！

{% for post in site.posts %}
- <span>{{
    post.date | date_to_string 
    }}</span> &raquo; [{{ post.title }}]({{ BASE_PATH }}{{ post.url }}){% endfor %}

