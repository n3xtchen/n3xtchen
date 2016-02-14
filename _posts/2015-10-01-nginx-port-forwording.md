---
layout: post
title: "Nginx-端口转发(反向代理)"
description: ""
category: Nginx
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

## 设置或者重置 Header

为了适配代理连接，我们使用 `proxy_set_header` 指令。例如，为了改变我们之前讨论的 **Host** 头信息，并增加一些其它的和代理请求一样的 **Header**，我们可以这么做：

	# server context
	
	location /match/here {
	    proxy_set_header HOST $host;
	    proxy_set_header X-Forwarded-Proto $scheme;
	    proxy_set_header X-Real-IP $remote_addr;
	    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	
	    proxy_pass http://example.com/new/prefix;
	}
	
	. . .

上述请求把 **Host** 头设置成 `$host` 变量，它讲包含请求的原始 `host`。`X-Forwarded-Proto` 头信息提供了关于院士客户端请求模式的被代理服务器信息（决定 **http** 还是 **https** 请求）。

`X-Real-IP` 被设置成客户端的 IP 地址，以便代理服务器做判定或者记录基于该信息的日志。`X-Forwarded-For` 头信息是一个包含整个代理过程经过的所有服务器 IP 地址的列表。在上述例子中，我们把它设置成 `$proxy_add_x_forwarded_for` 变量。这个变量包含了从客户端获取的 `X-Forwarded-For` 头信息并把 **Nginx** 服务器的 IP 添加到最后。

当然，我们会把 `proxy_set_header` 指令移到服务器或者 **http** 上下文的外部，允许它同时在多个 `Location` 生效：

	# server context
	
	proxy_set_header HOST $host;
	proxy_set_header X-Forwarded-Proto $scheme;
	proxy_set_Header X-Real-IP $remote_addr;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	
	location /match/here {
	    proxy_pass http://example.com/new/prefix;
	}
	
	location /different/match {
	    proxy_pass http://example.com;
	}

## 为负载均衡代理服务器定义 Upstream 上下文

在上一个例子中，我们演示了如何实现为了一个单一后端服务器做简单的 **Http** 代理。**Nginx** 帮助我们很容易通过指定一个后端服务器集群池子来扩展这个配置。

我们使用 `upstream` 指令来定义服务器群的池子（pool）。这个配置假设这个服务器列表中的每台机子都可以处理来自客户端的请求。它允许我们轻轻松松横向扩展我们的基础设施。`upstream` 指令必须在 **Nginx** 的 `http` 上下文中设置。

让我们一起看个简单的例子：

	# http context
	
	upstream backend_hosts {
	    server host1.example.com;
	    server host2.example.com;
	    server host3.example.com;
	}
	
	server {
	    listen 80;
	    server_name example.com;
	
	    location /proxy-me {
	        proxy_pass http://backend_hosts;
	    }
	}
	
上述例子，我们设置一个叫做 `backend_hosts` 的 **upstream** 上下文。一旦定义了，这个名称可以直接在 `proxy_pass` 中使用，就和常规的域名一样。如你所见，在我们的服务器块内，所有指向 *example.com/proxy-me/...* 的请求都会被传递到我们定义的池子中。在那个池子内，会根据配置算法选取一个服务器。默认，它只是一个简单的循环选择处理（每一个请求都会按顺序传递给不同的服务器）。

### 改变 Upstream 均衡算法

你可以通过指令或者标志修改 **upstream** 池子的均衡算法：

* **（轮询 Round Robin）**：默认的负载均衡算法，如果没有其它算法被指定的话，它会被使用。**upstream** 上下文定义的每一个服务器都会按顺序接受请求。
* **最少连接 least_conn**: 指定新的连接永远应该传递给拥有最少连接的后端服务器。这个算法在后端连接有时候需要持久化的情况下将很有效。
* **ip 哈希 ip_hash**：这种均衡算法基于客户端的 IP 分发到不同的服务器。把客户端 IP的前三位八进制数作为键值来决定服务器处理哪个请求。这样结果是，客户端每次由同一个台服务器服务，它能保证回话的一致性。
* **哈希 hash**：这类均衡算法主要运用于缓存代理。服务器是给予提供的哈希值来分隔的。它可以是文本，变量或者文本变量组合。

修改均衡算法，应该像下面那样：

	# http context
	
	upstream backend_hosts {
	
	    least_conn;
	
	    server host1.example.com;
	    server host2.example.com;
	    server host3.example.com;
	}
	
	. . .
	
上述例子中，最少连接数的服务器将会优先选择。`ip_hash` 指令也可以用同样的方式设置，来获取同样数量的会话粘性。

至于 `hash` 方法，你应该提供要哈希的键。可以是任何你想要的：

	# http context
	
	upstream backend_hosts {
	
	    hash $remote_addr$remote_port consistent;
	
	    server host1.example.com;
	    server host2.example.com;
	    server host3.example.com;
	}
	
	. . .
	
上述的例子，请求分发是基于客户端的 ip 和端口。我们也可以添加另外的参数 `consistent`，它实现了 Ketama 一致性 Hash 算法。基本上，它意味着如果你的 **upstream** 服务器改变了， 保证对 cache 的最小印象。

### 设置服务器权重

在后端服务器声明中，每一台的服务器默认是权重平分的。它假定每一台服务器都能也都应该处理同一量级的负载（考虑到负载均衡算法的影响）。然而，你也可以为服务器设置其它的权重。

	# http context
	
	upstream backend_hosts {
	    server host1.example.com weight=3;
	    server host2.example.com;
	    server host3.example.com;
	}
	
	. . .

上述例子中，`host1.example.com` 可以比其它服务器多接受 2 倍的流量。默认，每一台服务器的权重都是 1。

## 使用 Buffer 缓解后端服务器的负载

对于大部分使用代理的用户最关心的一件事情就是添加一台服务器对性能的影响。大部分场景下，利用 **Nginx** 的缓冲和缓存能力，可以大大地减轻负担。

当代理到其它服务器是，两个不同连接的速度影响客户端的体验：

* 从客户端到代理服务器的连接
* 从代理服务器到后端服务器的连接

**Nginx** 可以根据你想要优化哪一个连接来调整它的行为。

没有缓冲（**buffer**），数据将会直接从代理服务器传输到客户端。如果客户端的速度足够快（假设），**buffer** 可以关掉让数据尽可能快速地到达。如果使用 **buffer**，**Nginx** 代理服务器将会临时存储后端响应，然后慢慢把数据喂给客户端。如果客户端很慢，它可以让 **Nginx** 提前关闭后端服务器的连接。它可以控制在哪一步处理分发数据给客户端。

**Nginx** 默认的缓冲设计是客户端有这千差万别的速度。我们可以使用如下指令来调整缓冲速度。你可以把 **buffer** 设置防盗 `http`，`server` 或者 `location` 上下文中。必须记住指令为每一个请求配置的大小，因此如果客户端的请求很多，把值调的过大，会很影响性能：

* `porxy_buffering`：这个指令控制所在上下文或者子上下文的**buffer**是否打开。默认是 `on`。
* `proxy_buffers`：这个指令控制 **buffer** 的数量（第一个参数）和大小（第二个参数）。默认是 8 个 **buffer**，每个 **buffer** 大小是 1 个内存页（4k 或 8k）。增加 **buffer** 的数量可以缓冲更多的信息。
* `proxy_buffer_size`：是来自后端服务器响应信息的一部分，它包含头信息，从响应的部分分离出来。这个指令设置响应部分的缓冲。默认，它和 `proxy_buffers` 一样，但是因为它仅用于头信息，所有它市场被设置成更低的值。
* `proxy_busy_buffer_size`：这个指令设置忙时 **buffer** 的最大值。一个客户端一次只能从一个 **buffer** 读取数据的同时，**buffer** 会被放到队列中，等待发送到客户端。这个指令控制在这个状态下 **buffer** 的空间大小
* `proxy_max_temp_file_size`：这个是 **Nginx** 一次可以写临时文件的最大数据量，当代理服务器的响应太大超出配置的 **buffer** 的时候。
* `proxy_temp_path`：当代理服务器的响应太大超出配置的 **buffer** 的时候，**Nginx** 写临时文件的路径。

正如你看到的，**Nginx** 提供了很少指令来调整缓冲行为。大部分时间，你不需要关心大部分指令，但是它们中的一些会很有用。可能最有用的就是 `proxy_buffer` 和 `proxy_buffer_size` 这两个指令。

下面这个例子中睁开每个 **upstream** 可用代理 **buffer** 数，减少存储头信息的 **buffer** 数：

	# server context
	
	proxy_buffering on;
	proxy_buffer_size 1k;
	proxy_buffers 24 4k;
	proxy_busy_buffers_size 8k;
	proxy_max_temp_file_size 2048m;
	proxy_temp_file_write_size 32k;
	
	location / {
	    proxy_pass http://example.com;
	}

相反，如果你的客户端足够快到你可以直接传输数据，你就可以完全关掉 **buffer**。实际上，即使 **upstream** 比客户端快很多，**Nginx** 还是会使用 **buffer** 的，但是它会直接清空到客户端的数据，不会让它进入到池子。如果客户端很慢，这会导致 **upstream** 连接会一直开到客户端赶上为止。当缓冲被设置为 `off` 的时候，只有 `proxy_buffer_size` 指令定义的 **buffer** 会被使用。

	# server context
	
	proxy_buffering off;
	proxy_buffer_size 4k;
	
	location / {
	    proxy_pass http://example.com;
	}
	
## 高可用性（可选）

你可以通过添加一个冗余的负载均衡器来使 **Nginx** 代理更加健壮，创建一个高可用性基础设施。

一个高可用（HA）的配置是一种容许单点错误的基础设施，你的负载均衡是这个配置的一部分。当你的负载均衡器不可用或者你需要下线维护，你可以通过配置多个负载均衡器防止潜在的停机风险。

这是基本高可用架构图：

![高可用架构图](https://assets.digitalocean.com/articles/high_availability/ha-diagram-animated.gif)	

这个例子中，在静态 IP （它可以映射到一台或多台服务器）后面拥有多个负载均衡（一个激活的，其它的一个或多个是被动激活的）。客户端请求从静态 IP 路由到激活的负载均衡器，然后到后端服务器。想了解更多，请阅读 [this section of How To Use Floating IPs](https://www.digitalocean.com/community/tutorials/how-to-use-floating-ips-on-digitalocean#how-to-implement-an-ha-setup)。

## 配置代理混存来减少响应时间

**buffer** 用力帮助减轻后端服务器负担来处理更多的请求的同时，**Nginx** 还提供一个从后端服务器缓存内容的功能，减少要连接 **upstream** 的需求。

### 配置代理缓存

我们使用 `proxy_cache_path` 指令来为代理内容设置缓存。它会创建一个用代理服务器返回数据存储的地区。`proxy_cache_path` 指令必须在 `http` 上下文中设置。

下面例子中，我们将会配置这个和相关指令来设置我们的缓存系统。

	# http context
	
	proxy_cache_path /var/lib/nginx/cache levels=1:2 keys_zone=backcache:8m max_size=50m;
	proxy_cache_key "$scheme$request_method$host$request_uri$is_args$args";
	proxy_cache_valid 200 302 10m;
	proxy_cache_valid 404 1m;

我们可以使用 `proxy_cache_path` 指令来定义缓存的存储路径。在这个例子，我使用 `/var/lib/nginx/cache` 这个路径。如果这个路径不存在，你需要创建这个目录，并赋予正确的权限：

	sudo mkdir -p /var/lib/nginx/cache
	sudo chown www-data /var/lib/nginx/cache
	sudo chmod 700 /var/lib/nginx/cache
	
参数 `levels=` 用来指示 `cache` 如何组织。**Nginx** 将会通过哈希键值创建一个缓存 **key**（在下方配置）。上述我们选择的等级将会创建一个单字符目录（它将会是哈希值的最后一个字符），包含一个两个字符的子目录（哈希值从后向前紧接的两个字符）。你一般不需要关心这个细节，但是它会帮助 **Nginx** 快速查找相关值。

参数 `keys_zone=` 定义缓存区域（我们称之为 `backzone`）的名称。这个也是我们定义存储多少元数据的地方。在这个场景中，我们存储 8 MB 的键。**Nginx** 将每一兆会存储 8000 个实体。参数 `max_size` 用来定义实际缓存数据的最大尺寸。

上面我们使用的另一个指令就是 `proxy_cache_key`。它用来设置用来存储缓存值的键。这个相同的键用来检查一个请求是否可以使用缓存进行服务。我们把它设成 **scheme** （**http** 和 **https**），**HTTP** 请求方法和请求的服务器以及 **URI** 的组合。

`proxy_cache_valid` 指令可以被指定多次。它允许我们基于不同状态码存储不同值。在我们的例子中，我们存储成功和重定向为 10 分钟，和 404 状态返回为1分钟清除缓存。

现在，我们已经配置了缓存区域，但是我们仍然需要告诉 **Nginx** 什么时候使用缓存。

在我们定义代理到后端的 `location` 中，我们配置缓存的使用：

	# server context
	
	location /proxy-me {
	    proxy_cache backcache;
	    proxy_cache_bypass $http_cache_control;
	    add_header X-Proxy-Cache $upstream_cache_status;
	
	    proxy_pass http://backend;
	}
	
	. . .
	
使用 `proxy_cache` 指令，我们可以指定应该使用缓存上下文的 `backend` 缓存区域。**Nginx** 将在传递到后端之前检查有效的实体。

`proxy_cache_bypass` 指令用来设置 `$http_cache_control` 变量。它包含一个指示器，指定一个客户端是否需要明确请求一个资源的新鲜，未缓存版本。设置这个指令允许 **Nginx** 正确地处理客户端请求类型。不需要没有后续的请求。

我们也增加一个多余头信息（`X-Proxy-Cache`）。我们设置这个头成 `$upstream_cache_status` 变量值。基本上，它设置一个头如果一个请求导致一个缓存命中，一个缓存丢失，或者如果一个缓存明确被绕过。尤其在 debug 的时候，特别有用；并且对客户端来说有用的信息。

## 缓存结果的注意事项

缓存可以极大地提高代理服务器的性能。然而，配置缓存的时候，还是需要考虑的东西还是很多的。

首先，任何用户相关的数据都不应该被缓存。因为这样会导致一个用户数据的结果会呈现给另一个用户。如果你的站点是纯静态的，那这可能不是问题。

如果你的站点有些动态元素，那你就需要在后端服务器考虑到这一点。你如何处理它依赖于应用或者服务怎么在后端处理这些。对于隐私内容，你应该把 `Cache-Control` 头设置成 `no-cache`,`no-store`,或者 `private`，这个依赖于数据本身：

* `no-cache`:说明响应不会在不进行第一次检查（数据在后端还未改变）之前提供服务。如果你的数据是动态的并且很重要的时候，这将会很有用。一个 **ETag** 哈希元数据头信息会在每一次请求的时候被检查，如果后端返回同一个哈希值的时候，之前的值可以被使用。
* `no-store`：说明没办法缓存接受的数据。这个对隐私数据是最有用的，这意味着每一次数据来自后端服务器。
* `private`:说明缓存数据的空间是不共享的。这个在缓存用户浏览器数据的时候很有用，但是代理服务器不会在后续的请求中承认数据的有效性。
* `public`:说明请求的是公共信息，它可以被任意的缓存。

控制这个行为相关的头还有 `max-age`，它控制任何资源可以被缓存多久。

根据数据的敏感度，正确地设置这些头信息，将会帮助你有效利用缓存，既能保障你的隐私数据安全和动态内容的有效刷新。

如果你的后端服务器也使用 **Nginx**，你可以像下面这样使用 `expires` 指令，它将会为 `Cache-Control` 设置 `max-age`:

	location / {
	    expires 60m;
	}
	
	location /check-me {
	    expires -1;
	}
	
在上面的例子中，第一个块允许内容被缓存1个小时。第二个块则把 `Cache-Control` 头设置成 `no-cache`。还想设置其他值，你可以使用 `add_header` 指令：

	location /private {
	    expires -1;
	    add_header Cache-Control "no-store";
	}
	
## 结语

**Nginx** 是第一个也是最重要的反向代理服务器，还可以作为 Web 服务器使用。因为这样的设计决策，代理请求到另个服务器变得相当的简单。**Nginx** 也足够灵活，允许你根据需求对代理配置进行灵活的控制。
	
