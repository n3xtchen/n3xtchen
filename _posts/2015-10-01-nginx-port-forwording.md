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

## 常规的代理信息

如果你过去只是在简单场景下使用 **Web** 服务器，单台服务器配置，那你可能会怀疑为什么需要代理请求。

使用代理的其中一个理由是横向拓展提升你基础设施。**Nignx** 本来被用来处理并发请求，使它成为客户端接触点的理想选择。这个服务器可以传递请求给任何数量的后端服务器，来处理处理大量任务，达到夸设备拓展负载的目的。这个设计同样也帮助你更容易的增加服务器或者下线需要维护的服务器。

另外一个例子就是当使用应用服务器，该应用本身不能直接处理从客户端传递过来请求时，代理服务器同样有用。很多框架（包括 **Web** 服务器）不如专门设计成高性能服务（如 **Nignx**）健壮。把 **Nginx** 放在这些服务之前，可以提升用户体验和安全性。

**Nigix** 通过接收一个请求，把它转发传递给其他服务器完成来完成代理。请求的结果会传递回 **Nginx**，展示给客户端。实例中的其他服务器可以是远端机器，本地服务，甚至是由 **Nginx** 定义的其他虚拟服务。**Nginx** 代理处理请求的服务器，我们称之为上游（upstream）服务。

**Nginx** 可以代理使用 **http(s)**, **FastCGI**, **SCGI** 和 **uwsgi** 的请求，或者为每种代理制定不同指令进行多级缓存协议。**Nginx** 实例负责传递请求，并把各个信息组件揉成一个 **Upstream** 可理解的格式。

