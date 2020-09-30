---
layout: post
title: "microk8s starter"
description: ""
category: 
tags: []
---
{% include JB/setup %}

一、安装前准备

brew cask install multipass
brew install ubuntu/microk8s/microk8s


二、Ubuntu 镜像安装

microk8s install -c 6 -m 10g

Ubuntu 的镜像没有配置，可能会导致安装过程报错，或者组件缺失

下面谈谈比较稳健的方式：

multipass launch -c 6 -m 10g -d 50g -n microk8s-vm bionic

- -c 6：cpu 数量
- -m 10g：内存数量
- -d 50g:：最大磁盘大小
- -n 容器名称：这里必须使用 microk8s-vm，不然 Mac Os 端就没办法使用 microk8s 的命令了
- bionic：这个是发行版别名，我是用的 ubuntu 18.04(和 microk8s 移植)，可以通过 multipass find 查找其他可用的发行版

安装过程可能会很慢，MacOs 和 Windows 目前都不支持文件导入的方式，寻找其他替代方案

> Ubuntu 源配置（默认的源速度慢，不稳定）

目前，我使用的阿里云 https://developer.aliyun.com/mirror/ubuntu

sed -i s/archive.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list
sed -i s/security.ubuntu.com/mirrors.aliyun.com/g /etc/apt/sources.list
apt-get update
apt-get  upgrade -y

> 安装组件

sudo snap install microk8s --classic

默认安装最新稳定版，现在是 v1.19.2（和 k8s 版本对应）

你可以指定自己安装：

sudo snap install microk8s --classic —channel=1.18/stable

需要注意的是 1.13版本之后，将不在支持 docker，只能使用 ContainerD

三、配置 MicroK8s

> 配置 docker.io 镜像

文件：/var/snap/microk8s/current/args/containerd-template.toml

位置：
- 1.19.2 之前（不包括）：Plugin > plugins.cri.registry > plugins.cri.registry.mirrors > plugins.cri.registry.mirrors."docker.io”
- 1.19.2 之后：plugins."io.containerd.grpc.v1.cri" >  plugins."io.containerd.grpc.v1.cri".registry > plugins."io.containerd.grpc.v1.cri".registry.mirrors > plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io" > enpint


我添加的镜像地址如下：

  endpoint = [
    "https://3laho3y3.mirror.aliyuncs.com",
    "http://f1361db2.m.daocloud.io",
    "https://mirror.ccs.tencentyun.com",
    "https://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://registry-1.docker.io"
  ]

添加完，需要重启 microk8s


> 问题 failed to resolve reference "k8s.gcr.io/pause:3.1"

国内，无法使用 google 官方的镜像，所以安装的时候肯定会报错

$ microk8s kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS     RESTARTS   AGE
kube-system   calico-kube-controllers-847c8c99d-svsvm   0/1     Pending    0          72m
kube-system   calico-node-vvpvw                         0/1     Init:0/3   0          72m
$  microk8s kubectl describe pod calico-node-vvpvw --namespace=kube-system
….
Events:
  Type     Reason                  Age                   From     Message
  ----     ------                  ----                  ----     -------
  Warning  FailedCreatePodSandBox  25m (x19 over 62m)    kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to get sandbox image "k8s.gcr.io/pause:3.1": failed to pull image "k8s.gcr.io/pause:3.1": failed to pull and unpack image "k8s.gcr.io/pause:3.1": failed to resolve reference "k8s.gcr.io/pause:3.1": failed to do request: Head "https://k8s.gcr.io/v2/pause/manifests/3.1": dial tcp 64.233.189.82:443: i/o timeout

目前，containerD 的功能体验和 docker 还是有些差距，这个时候，需要借助 docker（找一台装有 docker 的机子）

1. 找一个国内靠谱且速度快的源，下面是我的选择
    -  gcr.azk8s.cn/google-containers/
    -  registry.cn-hangzhou.aliyuncs.com 这个是我的选择
2. 拉去镜像
docker pull registry.cn-hangzhou.aliyuncs.com/pause:3.1
3. 修改镜像域名
docker tag registry.cn-hangzhou.aliyuncs.com/pause:3.1 k8s.gcr.io/pause:3.1
4. 导入镜像
docker save k8s.gcr.io/pause > pause.tar
5. 传输你的 microK8s 所在服务器
multipass transfer pause.tar "microk8s-vm:pause.tar"
6. 导入
microk8s.ctr —namespace k8s.io image import pause.tar

这个方法同样适用于 k8s 的安装，实现曲线救国

https://www.omingo.cn/2019/06/21/%E5%9B%BD%E5%86%85microk8s%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97/

下面是你后面会遇到下午问题的镜像，重复上述的步骤一一下载下载：

$ ls -l k8s.io/
total 368852
-rw-rw-r-- 1 ubuntu ubuntu  75337216 Sep 29 09:01 heapster-amd64.tar
-rw-rw-r-- 1 ubuntu ubuntu 154733056 Sep 29 09:01 heapster-grafana-amd64.tar
-rw-rw-r-- 1 ubuntu ubuntu  12775936 Sep 29 09:01 heapster-influxdb-amd64.tar
-rw-rw-r-- 1 ubuntu ubuntu  41241088 Sep 29 09:01 k8s-dns-dnsmasq-nanny-amd64.tar
-rw-rw-r-- 1 ubuntu ubuntu  50545152 Sep 29 09:01 k8s-dns-kube-dns-amd64.tar
-rw-rw-r-- 1 ubuntu ubuntu  42302976 Sep 29 09:01 k8s-dns-sidecar-amd64.tar
-rw-rw-r-- 1 ubuntu ubuntu    754176 Sep 29 09:02 pause.tar




- kube-system:Dns
    - coredns-86f78bb79c-rm629
        - k8s.gcr.io/pause:3.1
- kube-system:Dashboard
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
        - 
- kube-system:Storage
    - hostpath-provisioner
- metallb-system:Metallb
    - speaker
    - controller
- ingresss:Ingress
    - nginx-ingress-microk8s-controller

