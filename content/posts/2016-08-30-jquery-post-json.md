---
categories:
- javascript
date: "2016-08-30T00:00:00Z"
description: ""
tags:
- Jquery
- Json
title: 使用 Jquery 发送 Json 数据的正确姿势
---

让我们先从错误的姿势开始：

	var json = {"name": "I have space"};
	$.post('some_url_need_json', json)
	
首先这两条语句有两个细节需要注意

* 默认，`POST` 的 `Content-Type` 长这样：

		Content-Type: application/x-www-form-urlencoded; charset=UTF-8

* JSON 在发送的过程中会被 `URLEncode` 掉，变成这样:

		name＝I+have+space

当然，前后端都是自己部门开发，相互协调都不会出现问题；但是，记住但是如果使用外包或者开源组件的就会把你坑到死。

为了严谨（借用我一同事的名言）， 我们要这么做：

	$.ajaxSetup({contentType: "application/json; charset=utf-8"});
	$.post('some_url_need_json', JSON.stringify(json))
	
* `$.ajaxSetup`: 配置请求的头信息；
* `JSON.stringify`: 避免发送的内容被 `URLEncode` 掉。