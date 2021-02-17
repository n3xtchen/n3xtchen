---
layout: post
title: "Kubernetes/MicroK8s 安装(For ContainerD and OsX)"
description: ""
category: k8s
tags: [k8s]
---
{% include JB/setup %}

K8S + ContainerD = 大坑，谁折腾谁知道（公有云的好处就体现出来）！各种链接不上，各种下载慢，谁经历谁崩溃！
怀抱的极客精神（其实是犯贱），明知山有虎（坑），偏向虎山行（坑上走）。

吐槽完毕，进入正题。。。

### ContainerD 是什么？

容器运行时（Container Runtime）是 Kubernetes（k8s） 最重要的组件之一，负责管理镜像和容器的生命周期。
Kubelet 通过 Container Runtime Interface (CRI) 与容器运行时交互，以管理镜像和容器。

他的优点（取代 docker 的主要原因）：调用链更短，组件更少，更稳定，占用节点资源更少。

性能是优点，但是功能确实鸡肋，Biggest Problem 就是不支持外部源，在中国大陆上，意味着什么？你知道的。

### MicroK8s 是什么？

MicroK8s是一个轻量级的Kubernetes环境。与Minikube不同，它不需要VirtualBox，因此可以在虚拟服务器上运行。
它是一个轻巧的单节点，并具有Istio，Knative 和 Kubeflow 等全面功能，非常适合学习Kubernetes。

为什么不使用其他方案呢？因为他可以生产部署和应用。

### mulitpass 是什么？

Multipass是一个开源命令行实用程序，允许用户协调Ubuntu Linux虚拟机的创建，管理和维护，以简化应用程序的开发。
它可以在Linux和macOS操作系统上使用，并且截至今天，它也可用于Windows平台。

这个是官方的定义，简单的说，就把它当作 virtualbox/docker。

现在正式进入教程。

### 一、环境准备

    brew cask install multipass
    brew install ubuntu/microk8s/microk8s

开始安装 MicroK8s：

    microk8s install -c 6 -m 10g

如果成功了，在这里故事就结束了，^_^

简单的东西永远都不容易。Ubuntu 的镜像没有配置，可能会导致安装过程报错，或者组件缺失。

### 二、手动安装 MicroK8s

其实原理很简单，`microk8s install` 内部脚本分三步；

#### 1. 安装容器

下面谈谈比较稳健的方式：

    multipass launch -c 6 -m 10g -d 50g -n microk8s-vm bionic

参数都代表"

- -c 6：cpu 数量
- -m 10g：内存数量
- -d 50g:：最大磁盘大小
- -n 容器名称：这里必须使用 microk8s-vm，不然 Mac Os 端就没办法使用 microk8s 的命令了
- bionic：这个是发行版别名，我是用的 ubuntu 18.04(和 microk8s 移植)，可以通过 multipass find 查找其他可用的发行版

安装完成后，通过如下命令验证：

    $ multipass list
    Name                    State             IPv4             Image
    ...(忽略其他镜像)
    microk8s-vm             Running           192.168.64.2     Ubuntu 18.04 LTS
                                              10.1.36.0
                                              10.1.36.1

> 提示：安装过程可能会很慢，因为 multipass 没有中国源，Linux 支持导入，但是 MacOs 和 Windows 目前都不支持文件导入的方式，寻找其他替代方案

#### 2. Ubuntu 源配置（默认的源速度慢，不稳定）

这个步骤就不解释，直接上代码。

目前，我使用的[阿里云](https://developer.aliyun.com/mirror/ubuntu)，直接执行如下代码

进入容器:

    multipass shell microk8s-vm

配置源:

    sed -i s/archive.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list
    sed -i s/security.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list
    apt-get update
    apt-get  upgrade -y

#### 3. 手动安装 microk8s

    sudo snap install microk8s --classic

默认安装最新稳定版，现在是 v1.19.2（和 k8s 版本对应）

你可以指定自己安装：

    sudo snap install microk8s --classic —channel=1.18/stable

现在查看下安装成功与否（还是在容器内操作）：

    ubuntu@microk8s-vm:~$ snap list
    Name      Version      Rev    Tracking       Publisher   Notes
    microk8s  v1.18.15     2034   1.18/stable    canonical✓  classic

### 三、配置 MicroK8s

#### 配置 docker.io 镜像

文件：/var/snap/microk8s/current/args/containerd-template.toml

配置所在位置：

- 1.19.2 之前（不包括）：
  - [Plugin]
    - [plugins.cri.registry]
      - [plugins.cri.registry.mirrors]
        - [plugins.cri.registry.mirrors."docker.io"]
- 1.19.2 之后：
  - [plugins."io.containerd.grpc.v1.cri"]
    - [plugins."io.containerd.grpc.v1.cri".registry]
      - [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        - [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]

我添加的镜像地址如下：

    endpoint = [
      "https://3laho3y3.mirror.aliyuncs.com",
      "http://f1361db2.m.daocloud.io",
      "https://mirror.ccs.tencentyun.com",
      "https://hub-mirror.c.163.com",
      "https://docker.mirrors.ustc.edu.cn",
      "https://registry-1.docker.io"
    ]

添加完，需要重启 microk8s。

以为现在就结束，那就天真了，后面才是真正的干货，^_^

### 四、依赖包问题: failed to resolve reference "k8s.gcr.io/pause:3.1"

所有在自建 K8S 的时候，大部分人都在这个部分开始放弃了，这里要感谢 GFW。

国内，无法使用 google 官方的镜像，所以安装的时候肯定会报错。

会发现总是 Pending：

    $ microk8s kubectl get pods --all-namespaces
    NAMESPACE     NAME                                      READY   STATUS     RESTARTS   AGE
    kube-system   calico-kube-controllers-847c8c99d-svsvm   0/1     Pending    0          72m
    kube-system   calico-node-vvpvw                         0/1     Init:0/3   0          72m

继续挖下去，发现已经报错了：

    $  microk8s kubectl describe pod calico-node-vvpvw --namespace=kube-system
    ….
    Events:
      Type     Reason                  Age                   From     Message
      ----     ------                  ----                  ----     -------
      Warning  FailedCreatePodSandBox  25m (x19 over 62m)    kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to get sandbox image "k8s.gcr.io/pause:3.1": failed to pull image "k8s.gcr.io/pause:3.1": failed to pull and unpack image "k8s.gcr.io/pause:3.1": failed to resolve reference "k8s.gcr.io/pause:3.1": failed to do request: Head "https://k8s.gcr.io/v2/pause/manifests/3.1": dial tcp 64.233.189.82:443: i/o timeout

目前，containerD 的功能体验和 docker 还是有些差距，这个时候，需要借助 docker（找一台装有 docker 的机子）

#### 1. 找一个国内靠谱且速度快的源

下面是我的选择（docker 源怎么修改，自行谷歌）

- gcr.azk8s.cn/google-containers
- registry.cn-hangzhou.aliyuncs.com <这个是我的选择>

#### 2. 拉去镜像

    docker pull registry.cn-hangzhou.aliyuncs.com/pause:3.1

#### 3. 修改镜像域名，因为 k8s 只认 k8s.gcr.io

    docker tag registry.cn-hangzhou.aliyuncs.com/pause:3.1 k8s.gcr.io/pause:3.1

#### 4. 导出镜像

    docker save k8s.gcr.io/pause > pause.tar

#### 5. 传输你的 microK8s 所在服务器

    multipass transfer pause.tar "microk8s-vm:pause.tar"

#### 6. 导入镜像

    microk8s.ctr —namespace k8s.io image import pause.tar

> 提示：这个方法同样适用于 k8s 的安装，实现曲线救国，

重复上述的步骤，将下面的包一一下载：

    $ ls -l k8s.io/
    total 368852
    -rw-rw-r-- 1 ubuntu ubuntu  75337216 Sep 29 09:01 heapster-amd64.tar
    -rw-rw-r-- 1 ubuntu ubuntu 154733056 Sep 29 09:01 heapster-grafana-amd64.tar
    -rw-rw-r-- 1 ubuntu ubuntu  12775936 Sep 29 09:01 heapster-influxdb-amd64.tar
    -rw-rw-r-- 1 ubuntu ubuntu  41241088 Sep 29 09:01 k8s-dns-dnsmasq-nanny-amd64.tar
    -rw-rw-r-- 1 ubuntu ubuntu  50545152 Sep 29 09:01 k8s-dns-kube-dns-amd64.tar
    -rw-rw-r-- 1 ubuntu ubuntu  42302976 Sep 29 09:01 k8s-dns-sidecar-amd64.tar
    -rw-rw-r-- 1 ubuntu ubuntu    754176 Sep 29 09:02 pause.tar

因为这些组件依赖这些包:

- kube-system: Dns
  - coredns-86f78bb79c-rm629
    - k8s.gcr.io/pause:3.1
- kube-system: Dashboard
  - metrics-server
    - k8s.gcr.io/metrics-server-amd64:v0.3.6
  - heapster-v1.5.2
    - k8s.gcr.io/heapster-amd64:v1.5.2
  - dashboard-metrics-scraper
  - kubernetes-dashboard
    - k8s.gcr.io/pause:3.1
  - monitoring-influxdb-grafana
    - k8s.gcr.io/heapster-grafana-amd64:v4.4.3
    - k8s.gcr.io/heapster-influxdb-amd64:v1.3.3

### 最后验证 MicroK8s 安装成功与否

执行如下命令:

    ubuntu@microk8s-vm:~$ microk8s status
    microk8s is Running<这个才是代表安装成功>
    addons:
    dashboard: enabled
    dns: enabled
    cilium: disabled
    fluentd: disabled
    gpu: disabled
    helm: disabled
    helm3: disabled
    ingress: disabled
    istio: disabled
    jaeger: disabled
    knative: disabled
    kubeflow: disabled
    linkerd: disabled
    metallb: disabled
    metrics-server: disabled
    prometheus: disabled
    rbac: disabled
    registry: disabled
    storage: disabled

#### Dashboard 端口转发

因为 Dashboard 默认只允许在内网访问

    microk8s.kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0
