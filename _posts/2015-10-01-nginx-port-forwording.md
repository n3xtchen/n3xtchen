---
layout: post
title: "Nginx-端口转发(反向代理)"
description: ""
category: nignx
tags: [nginx]
---
{% include JB/setup %}

> 译自：[Understanding Nginx HTTP Proxying, Load Balancing, Buffering, and Caching](https://www.digitalocean.com/community/tutorials/understanding-nginx-http-proxying-load-balancing-buffering-and-caching)

## 介绍

这里，我们将介绍 **Nginx** 的 **Http** 代理功能（它允许 **Nignx** 传递请求到后端服务器，进行后续处理）。**Nginx** 经常被设置成反向代理帮助横向拓展设施提升负载能力或者传递请求给其他服务器。

接下来，我们将讨论如何使用 **Nginx** 的负载均衡功能来横向拓展（scale out）服务器。我们同样也探讨使用缓存来提升代理的性能。

## 常规的代理信息（重点校对）

如果你过去只是在简单场景下使用 **Web** 服务器，单台服务器配置，那你可能会怀疑为什么需要代理请求。

使用代理的其中一个理由是横向拓展提升你基础设施。**Nignx** 本来被用来处理并发请求，使它成为客户端接触点的理想选择。这个服务器可以传递请求给任何数量的后端服务器，来处理处理大量任务，达到夸设备拓展负载的目的。这个设计同样也帮助你更容易的增加服务器或者下线需要维护的服务器。

另外一个例子就是当使用应用服务器，该应用本身不能直接处理从客户端传递过来请求时，代理服务器同样有用。很多框架（包括 **Web** 服务器）不如专门设计成高性能服务（如 **Nignx**）健壮。把 **Nginx** 放在这些服务之前，可以提升用户体验和安全性。

**Nigix** 通过接收一个请求，把它转发传递给其他服务器完成来完成代理。请求的结果会传递回 **Nginx**，展示给客户端。实例中的其他服务器可以是远端机器，本地服务，甚至是由 **Nginx** 定义的其他虚拟服务。**Nginx** 代理处理请求的服务器，我们称之为**upstream**（上游）服务。

**Nginx** 可以代理使用 **http(s)**, **FastCGI**, **SCGI** 和 **uwsgi** 的请求，或者为每种代理制定不同指令进行多级缓存协议。**Nginx** 实例负责传递请求，并把各个信息组件揉成一个 **upstream** 可理解的格式。

## 解构简单的 HTTP Proxy Pass

最简单的代理类型莫过于把一个请求导向到单一可使用 **http** 协议通信的服务器。这种代理类型我们统称为 **proxy pass**，由 `proxy_pass` 同名 **Nginx** 指令处理。

`proxy_pass` 指令主要在地址（`Location`）语境中被看到。它同样在 `Location` 和 `limit_except` 语境下的 `if` 语法块中有效。当一个请求匹配到一个包含 `proxy_pass` 的 `Location`时，这个请求将会被指令转发（Forward）到这个链接去。

让我们看一个例子：

	# server context
	
	location /match/here {
	    proxy_pass http://example.com;
	}
	
	. . .

在上面代码片段中，`proxy_pass` 定义中的服务器没有提供 **URI**。这个模式的定义，请求的 **URI** 会原封不动地直接传递给 **upstream** 服务器。

例如，当一个匹配 `/match/here/please` 的请求被这个 **block** 处理，这个请求将会以 *http://example.com/match/here/please* 的形式把 URI 发送给 `example.com` 服务器。

让我们一起看看另外一个场景：

	# server context

	location /match/here {
	    proxy_pass http://example.com/new/prefix;
	}
	
	. . .

上述例子中，代理服务器在尾部定义了 **URI** 部分。当 **URI** 放到 `proxy_pass` 定义中，请求中匹配这个 `Location` 的定义的部分在传递的过程中将会被这个 **URI** 替换掉。

例如，一个匹配 `/match/here/please` 的请求将会以 *http://example.com/new/prefix/please* 的形式发送给 **upsream** 服务器。`/match/here` 将会替换成 `/new/prefix`。这一点很重要，必须记住。

有时，这样的替换是不可完成的。这时，定义在 `proxy_pass` 的尾部的**URI** 会被忽略，**Nginx** 直接把来自客户端或被其他 **Nginx** 的指令修改的 **URI** 传递给 **upstream** 服务器。

例如，使用正则表达式匹配 **Location** 时，**Nginx** 不能决定 **URI** 的哪一个部分匹配这个表达式，于是它直接发送客户端请求的原始 **URI**。还有另一个例子，当一个 **rewrite** 指令在同一个地址中使用，会导致客户端的 **URI** 被重写，但是仍然在同一个 **block** 下处理，这时，重写的 **URI** 会被传递。



