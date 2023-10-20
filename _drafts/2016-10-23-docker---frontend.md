---
layout: post
title: "用 Docker 快速配置前端开发环境(改)"
description: ""
category: linux
tags: [docker]
---
{% include JB/setup %}

/*
我不是 Docker 专家
文章有错误之处欢迎指出，欢迎各种交流讨论
*/

今天是你入职第一天。

你起了个大早，洗漱干净带着材料去入职。

签了合同，领了机器，坐到工位，泡一杯袋装红茶，按下开机键，输入密码，

然后，下载 Chrome、Postman、Sublime、盗版 PS、NodeJS、配置 NODE_PATH、安装 cnpm、安装 gulp、安装 webpack、安装 browserify、安装 LessSassStylus、安装 JadeCoffeePostCSS、安装 BabelExpressKoa、安装 gitpm2forever……

此处省略一万个插件。

如果顺利的话这个时候你应该已经准备下班了，当然，通常来说都不顺利。

在这个过程中，你可能会遇到网络问题环境问题兼容问题权限问题配置问题配置问题配置问题配置问题配置问题配置问题配置问题。

新人第一周周报：

本周工作：配置环境，熟悉项目
大公司的解决方法

“开发机”。

开发机模式

大公司的思路很简单：既然你自己搞这么麻烦，那我帮你搞好，给你个账号，直接登录上去开发。

确实没毛病，不过这个方案必须解决三个问题：

怎么在本机预览网页
怎么在本机编辑文件
怎么在外网访问开发机
解决方法有很多，这里只说一种：Nginx + Samba + VPN。

Nginx 可以解决第一个问题。每个工程师分配一个账号，每个账号对应一个域名，Nginx 会把域名解析到对应用户的目录下，这样开发就可以在自己电脑上用域名预览网页（需要配置好 host）。举个例子，我的账号是 liangjie，项目的域名是 www.wisdomtmt.com，那我访问 liangjie.wisdomtmt.com 就可以预览开发机中 liangjie 账号下的项目。

Samba 可以解决第二个问题。你可以把它理解成 Windows 中的“共享文件夹”。在开发机上配置好 Samba，然后在自己机器上连接开发机，把共享文件夹拖到编辑器中就可以写代码了。

VPN 可以解决第三个问题。大公司除了专用的软件，还会配套使用硬件来提高安全系数。VPN 硬件类似 U 盾，上面显示一串动态数字密码，定时刷新，每次外网登录 VPN 都需要附加动态密码。

这样就解决了问题，开发人员可以在自己机器上写代码，然后在浏览器中直接预览，遇到意外情况也可以外网登录开发机修复。

粗略来看，这套方案没什么技术问题。但是对于中小型公司来说，搭建整套开发机环境、规范开发流程、规范 VPN 使用流程、全公司切到开发机，这一套走下来需要的时间和人力成本都不低。通常来说也只有大公司才玩得起。

那小公司呢？难道每个新员工都必须浪费时间来配置环境？

当然不是。

出来吧，Docker！

Docker 模式

主角登场。

什么是 Docker？我不是 Docker 专家，所以这里不对 Docker 做专业介绍。如果你还不知道 Docker 是什么，把它看成虚拟机就可以了。

在引入 Docker 之前，我对它做了一些调研，主要想搞清楚以下几个问题：

Docker 能否跨平台？（毕竟你不能要求公司给所有人配 Mac）
如何预览 Docker 里的网页？
如何编辑 Docker 里的文件？
Docker 能否实现一次配置多处使用？
由于 Docker 运行在每个人的机器上，因此不存在外网访问问题。

经过调研，上述问题理论上都可以解决，下面是初步确定的解决方案：

用 Kitematic 客户端实现跨平台运行 Docker
用端口映射预览 Docker 里的网页
用 Samba + 端口映射编辑 Docker 里的文件
配置一个通用的 Image（镜像）
这里面有几个概念需要解释。

首先，Kitematic 是一个 Docker GUI，有了它你就不用和命令行打交道，会方便不少。

其次，Docker 中最重要的三个概念是 Container（容器）、Image（镜像）和 Volume（卷）。

Image 是静态内容，如果你要把某个 Image 跑起来，那就需要一个 Container。这里面有一点很重要：Container 中所做的改动不会保存到 Image。举个例子，你跑起来一个 Ubuntu Image，然后 touch wisdomtmt 创建一个新文件，这时候如果直接重启 Container，文件就没了。那怎么保存改动？很简单，执行 docker commit ContainerID TAG 即可。这里的 commit 和 git commit 类似，执行之后会把当前状态保存为一个新 Image。

有同学就要问了，如果每次做改动都要 commit，我写起代码来岂不是很不方便？万一写到一半不小心重启 Docker 怎么办？

这确实是个问题，Docker 也有对应的解决方法：使用 Volume。

简单来说，Volume 就是专门存放数据的文件夹，启动 Image 时可以挂载一个或多个 Volume，Volume 中的数据独立于 Image，重启不会丢失。我们创建一个 Volume，挂载到系统的一个目录下，然后把代码都放进去就可以了。

最后说端口映射。前面说过，Docker 可以看做一个虚拟机，你的所有文件都在里面。如果你在 Container 中运行一个服务器，监听 127.0.0.1:8000，从你自己的机器上直接访问 http://127.0.0.1:8000 是不行的，因为 Container 和你的机器是两个不同的环境。

那怎么办呢？我们先来看一个大家都熟悉的问题。

日常开发中我们经常需要让同事预览网页效果，常用的方法是监听 0.0.0.0:8000，然后让同事连接同一个局域网，访问 http://你的机器IP:8000 即可。

Container 的问题非常相似，只不过我们自己变成了“同事”，需要访问 Docker 内部的网页。看起来只要拿到 Container 的 IP 问题就解决了。

幸运的是，Container 确实有 IP。

通常情况下这个 IP 是 192.168.99.100，只能从 Container 的宿主机（也就是运行 Docker 的机器）访问。不过 Container 的情况有些特别，它只关联了 IP，没有关联端口。因此如果想要访问 Container 内部的端口（比如 8000），你需要手动配置端口映射，把 Container 内部的端口映射到 IP 上。

好了，枯燥的概念讲完了，理解不了也不用着急，跟着下一章走一遍流程就懂了。

动手

正式开工之前，先看看我们都要做什么。

目标：配置一个通用 Image，支持预览网页，支持 Samba 共享文件，预装开发过程中可能用到的包。

过程：

下载并安装 Docker Toolbox
下载并运行 Ubuntu 镜像
做常规的初始化工作（换源、安装常用工具）
安装前端开发工具
安装和配置 Samba
配置端口映射
导出镜像
Let’s rock!

1. 下载并安装 Docker Toolbox

Docker Toolbox 是 Docker 官方开发的 Docker 套装，里面有全套 Docker 环境，也有图形化工具 Kitematic，直接下载安装即可。

Docker Toolbox 支持 Windows 和 Mac OS，可以到官网下载安装（这一步如果没有 VPN 会比较耗时，最好把两个平台的安装包都下载好，之后直接复制给同事安装）。

Linux 环境配置可以参考这篇：Installation on Ubuntu。

下文以 Mac OS 为例，Windows 操作方法类似。

安装完毕之后打开 Kitematic，注册一个 Docker Hub 账号，方便之后的操作。

注册 Docker Hub 账号

2. 下载并运行 Ubuntu 镜像

Docker Hub 上有现成的 Ubuntu 镜像，在 Kitematic 中点击左上角的“NEW”，搜索 Ubuntu，选择第二排第一个即可。

Ubuntu 镜像

这个 Ubuntu 镜像是超级精简版，只有一百多兆，不过国内网络下载起来还是很痛苦。没办法，等着吧，反正只需要下载一次。

下载完成后，在 Kitematic 左侧的 Container 列表中选择 ubuntu，然后点击上方的“START”按钮执行。点击“EXEC”可以进入系统命令行，输入 su 开启 root 权限。这个过程下文不再赘述，统称“打开 Ubuntu 命令行”。

打开 Ubuntu 命令行后，试着执行几个命令看看效果，比如 ls，cd /。玩完之后，点击 Kitematic 右上角的“Settings”，点击“Ports”，你会看到一个 IP 地址，通常情况下是 192.168.99.100。打开宿主机（你自己的电脑）命令行，输入 ping 192.168.99.100，应该是通的。

ping

这样我们就准备好了 Ubuntu 镜像，可以开始配置了。

3. 常规初始化工作

Ubuntu 装完系统第一件事是什么？没错，换源。

“源”其实就是网址，你在 Ubuntu 中用 apt-get install 安装软件的时候就是从“源”下载。Ubuntu 默认的源在国外，安装起来非常慢，所以要先换成国内的源。

国内有很多 Ubuntu 源，我用的是中科大源。

你可以直接看官方换源教程，也可以直接打开 Ubuntu 命令行（如果你忘了怎么做，看上一节），执行下面的命令：

sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
apt-get update
换源完毕，之后 apt-get 都会从中科大源下载软件。

前面说过，这个 Ubuntu Image 是超级精简版，很多不重要的工具都被删掉了，包括常用的 vim、curl、ipconfig、ping。除此之外，Linux 最常用的 TAB 补全路径也没有，所以下面先安装必要的编辑器和路径补全：

apt-get install vim bash-completion
这样就完成了基础配置，Ubuntu 可以正常用了。

4. 安装前端开发工具

首先安装 npm：

apt-get install npm
然后安装 cnpm，之后所有 npm 操作都改成 cnpm，从淘宝源下载，速度会快很多。

npm install -g cnpm --registry=https://registry.npm.taobao.org
接着安装 n，TJ 大神的 NodeJS 版本管理工具，可以安装多个版本，一键切换。n 需要用到 curl，所以先安装 curl：

apt-get install curl
然后安装 n：

cnpm install -g n
最后使用 n 安装目前的稳定版 NodeJS：

n stable
这样就准备好了前端开发需要的基本工具。

我们的项目目前在使用 Vue，所以我还安装了 vue-cli、browserify、gulp、babel 以及相关的库，你可以根据你的项目需求安装对应的库。

5. 安装和配置 Samba

Samba 是文件共享工具，用于在宿主机中编辑 Docker 内部的文件。

这里有完整配置教程，下面是我整理的超简洁版。

首先安装 Samba：

apt-get install samba
Samba 的用户系统比较特别，简单来说，Samba 的用户确实是系统的用户，但是 Samba 的密码和系统的密码不一样。也就是说，同一个用户在系统和 Samba 中密码需要单独设置，并没有打通。

Docker 的 Ubuntu Image 用户是 root，我们给 root 设置 Samba 密码：

smbpasswd -a root
设置好密码之后，需要创建 Samba 的配置文件，设置共享文件夹和权限：

vim /etc/samba/smb.conf
下面是我的配置示例：

[web]
path = /web
available = yes
valid users = root
read only = no
browsable = yes
public = yes
writable = yes
这里面的重点是 path，指定需要共享的文件夹，这里我共享了 /web 目录，你可以选择一个不同的目录。我的 /web 目录是一个 Volume，用来存放代码，重启 Docker 也不会丢失数据。Volume 的配置方法在后文介绍。

写好配置之后重启 Samba 服务：

service smbd restart
service nmbd restart
这样就完成了 Samba 的配置。

不过现在你还不能从宿主机连接共享文件夹，因为我们还没有配置端口映射。

6. 配置端口映射

首先明确需要映射的端口。

Samba 需要用到的端口：137、138、139、445。

日常开发可能用到的端口：3000、3123（hot-reload 用）、8000、8080。

接着配置端口映射。

注意：Windows 的 Kitematic 有严重 bug，改动 Settings 下的任何选项都会导致所有配置项丢失，解决方法看下一节

如果你是 Mac 系统，可以直接在 Kitematic 中进行配置。

配置端口映射

如图所示，直接在 Settings -> Ports 中添加映射即可。

到这里就已经完成了 Docker Image 的配置，你可以做一些测试，看看共享文件夹和端口映射工作是否正常。

测试一：

打开 Ubuntu 命令行，随便 cd 到一个目录（比如 cd /web）
执行 python -m SimpleHTTPServer，启动一个静态服务器
在宿主机中访问 http://192.168.99.100:8000，应该能看到 /web 目录下的所有文件
测试二：

如果是 Mac 系统，打开 Finder，按下 ⌘+K，输入 smb://192.168.99.100，回车，输入 root 和 Samba 密码，应该能看到共享文件夹（我设置的是 /web）
![连接服务器](http://static.zybuluo.com/numbbbbb/xif6i8s3gwwg0rd6si1wb79b/%E8%BF%9E%E6%8E%A5%E6%9C%8D%E5%8A%A1%E5%99%A8.png)
![选择共享文件夹](http://static.zybuluo.com/numbbbbb/m7nc3vbmxgycxtxrkj67prti/%E5%85%B1%E4%BA%AB%E6%96%87%E4%BB%B6%E5%A4%B9.png)
双击共享文件夹，应该能在 Finder 中看到 /web 下的所有文件
这样就完成了 Docker Image 的所有配置，下面完成最后一件事：导出镜像，供其他人使用。

7. 导出镜像

别忘了前面的提醒：如果不 commit，重启之后所有改动都会丢失！

所以先 commit。点击 Kitematic 左下角 “DOCKER CLI”，执行：

docker ps
会看到下面这样的输出：

➜  ~ docker ps
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS                                                                                                                                                  NAMES
c5c131f108b1        numbbbbb/ubuntu-test   "/bin/bash"         15 hours ago        Up 50 seconds       0.0.0.0:137-139->137-139/tcp, 0.0.0.0:445->445/tcp, 0.0.0.0:3123->3123/tcp, 0.0.0.0:8000->8000/tcp, 0.0.0.0:8080->8080/tcp, 0.0.0.0:32773->49201/tcp   dev
复制 Container ID，我这里是 c5c131f108b1，然后执行：

docker commit c5c131f108b1 username/imagename
username 换成你的 Docker Hub 用户名，imagename 换成你的镜像名称。我这里就是 numbbbbb/ubuntu-test。

commit 之后就可以把当前 Container 导出 Image 了：

docker export c5c131f108b1 -o ubuntu
执行完后，在你的个人目录下（Mac 上是 /Users/你的用户名）可以找到 ubuntu 文件，这就是我们的最终目标：一个完成所有配置的 Image。

稍微松口气，下面看看新同事入职时如何使用这个 Image。

新人使用流程

我整理的新人入职配置流程：

准备好 Docker Toolbox 安装包和 Ubuntu Image
安装 Docker Toolbox
打开 Kitematic，注册一个 Docker Hub 账号并登陆
在 Kitematic 中点击左下角“DOCKER CLI”打开 Docker 命令行
输入命令docker import，从文件夹中直接把 ubuntu 文件拖拽到命令行中（注意 ubuntu 文件路径中不能有中文，如果有，先把文件移动到另一个纯英文路径的文件夹中）
输入命令docker images，复制出镜像的 IMAGE ID（类似54184b993d46）
输入命令

docker run -t -i --privileged -p 137-139:137-139/tcp \
    -p 445:445/tcp -p 3000:3000/tcp -p 3123:3123/tcp \
    -p 8000:8000/tcp -p 8080:8080/tcp -d --name dev -v /web IMAGEID \
    /bin/bash
把其中的 IMAGEID 替换为上一步复制的内容

回到 Kitematic，应该可以看到左侧多了一个容器，此时环境已经搭建完毕
2016.08.04 Windows 的 Kitematic 有 bug，如果在界面中修改设置会导致 volume 丢失，所以不要在 Kitematic 中修改任何设置，如果要改就从命令行执行

上一节提到过，Windows 的 Kitematic 有 bug，手动添加端口映射会丢失所有配置，所以我们直接用命令添加，只要不从 Kitematic 里修改配置就没问题。

第 7 步的命令还有一个重要内容，就是 -v /web。这会创建并挂载一个 Volume，挂载目录是 /web，把代码放到这个目录下，就不会因为重启 Docker 丢失数据。

没有银弹

说了很多优点，下面来聊聊用 Docker 做开发环境的缺点。

首先，Docker 本身还不够成熟。

Docker 确实很强大，能支持三大操作系统，性能方面也远超传统虚拟机，但是仍然不够成熟。举一个小例子：Kitematic 在 Windows 上丢失配置的 bug 去年年底就有人报过，到现在都没解决。

其次，Docker 这套体系使用成本并不低。

试想一下，作为一个开发人员，在写代码之前必须运行 Kitematic、启动 Ubuntu 镜像、连接共享文件夹、进入镜像启动静态服务器。这个流程太重，理想的开发环境应该是透明的，打开电脑就能写代码。或许下一步可以考虑在这方面做一些自动化脚本来辅助开发。

小结

用 Docker 做前端开发环境确实可行 — 我们团队已经投入使用 — 但是这套方案还远远谈不上完美，需要继续优化。

如果你还是不知道怎么选：

有人有钱有时间，上标准开发机，各大公司都这么搞，肯定没问题
否则，可以试试 Docker，目前没有发现致命问题。