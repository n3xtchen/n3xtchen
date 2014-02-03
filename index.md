---
layout: page
title: Welcome To G-Tech!
tagline: created by N3xtchen
---
{% include JB/setup %}

    在这里，一同享受技术为我们带来无限乐趣！

### 最新 Blog

Hello, Blogger! 欢迎访问与评论！

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
