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

## 理解 Nginx 处理 Headers 的方式

有一件事情可能现在不会马上明白，如果你希望 **upstream** 服务合理地处理请求，那仅仅传递 **URI**是不够的。来自于 **Nginx** 请求不同于直接来源于客户端的请求。这里的差异最大的一部分就是请求的 **Headers** 信息。

当 **Nginx** 代理一个请求，它会自动对 **Headers** 信息做一些调整：

* **Nginx** 去除任何空的 **Headers**。传递空值到其他服务器是没有意义的；它只会让请求变得臃肿。
* **Nginx** 默认把包含下划线的 **Headers** 信息视为无效，会被移除。如果你希望把这样的信息解释为有效，你可以把 `underscores_in_headers` 执行设置成 `on`，否则你的头信息将永远不会把他发送给后端服务器。
* `Host` 会被重写成由 `$proxy_host` 定义的值。它可以是 `IP` （或者名称）和端口，直接由 `proxy_pass` 指令定义的。
* 头信息 **Connection** 改成 `close`。这个 **Header** 用在关于两个服务器创建特定链接的信号信号。在这个实例中，**Nginx** 把它设置成 `close` 来指定一旦原始请求被响应，**upstream** 服务的这个连接将被关闭。**upstream** 服务器不应该期待这个连接被持久化。

从第一点看来，我们可以确定任何你不想要传递的头信息应该被设置成空字符串。带空值的头信息会被完全删除掉。

接下来一点用来设置如果你的后端应用想要接受非标准的头，你应该确保它们不应该带下划线。如果你需要的头信息使用下划线，你可以在你的配置后面，把 `underscores_in_headers ` 设置成 `on`（在 **http** 上下文或者为这个 IP/端口组合声明的默认服务器上下文红中有效）。如果你不想这么做，**Nginx** 将会把这个头标记为无效，并在传递给 **upstream** 服务器之前把它丢弃。

头信息 **Host** 在大部分代理场景中起着重要作用。和之前讲的一样，默认，它会被设置成 `$proxy_host` 的值，一个由 `proxy_pass` 定义的包含域名或者 IP 以及端口的值。这样的默认设定是为了让 **Nginx** 确保 **upsteam** 服务器可以响应的唯一的地址（它直接从连接信息取出的）。

`Host` 常见的值如下：

* `$proxy_host`：它把 **Host** 头设置成从 `proxy_pass` 定义的域名或IP加上端口的组合。从 **Nginx** 的角度看，它是默认以及安全的，但是经常不是被代理服务器需要的来正确处理请求的值。
* `$http_host`：它把 **Host** 头设置成从和直接从客户端请求的一样。这个头由客户端发送，可以被 **Nginx** 使用。这个变量名前缀是 `$http_`，后面跟着头信息的名称，以小写命名，任何斜杠都会被下划线替换。虽然 `$http_host` 在大部分情况可用的，但是当客户端请求没有有效的 **Host** 信息的时候，会导致传输失败。
* `$host`：这个是偏好是指：可以是来自请求的主机名，请求中的 **Host** 头信息或者匹配请求的服务器名。

在大部分情况，你将会把 **Host** 头信息设置成 `$host` 变量。它是最灵活的，经常为被代理的服务器提供尽可能精确的 **Host** 头信息。
。


