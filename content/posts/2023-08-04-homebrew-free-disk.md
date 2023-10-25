---
date: "2023-08-04T00:00:00Z"
description: ""
tags: []
title: Homebrew 空间释放
---

为了玩大模型，努力释放 Macbook 的空间，蚊子腿也是肉。现在看下我们 **Homebrew** 的目录结构：

```
/opt/homebrew
├── [  8.9 GiB] Cellar/
│   ├── [  1.5 GiB] llvm
│   ├── [  1.3 GiB] rust
│   ├── [527.7 MiB] qumu
│   ├── [526.8 MiB] boost
│   └── ...
├── [974.8 MiB] Library
│   ├── [930.5 MiB] Taps
│   │   ├─── [930 MiB] homebrew
│   │   │    ├── [487.4 MiB] homebrew-core
│   │   │    ├── [384.8 MiB] homebrew-cask
│   │   │    └── ...
│   │   └── ...
│   └── ...
└── ...
```

> `...`: 代表小于 500 GiB 的文件目录 

### 目录占用情况

现在我们来分析分析：

- 占用最大是 `Cellar`：用来存储我们的安装的程序
- 占用第二是 `Library`: 包含 **Homebrew** 的主程序和软件源
- 缓存目录（`brew --cache`）：*/Users/<你的用户名>/Library/Caches/Homebrew*
- 其他的占用都小于 500 GiB

### 开始释放空间

#### 1. 清楚无用的依赖文件

卸载作为其他软件的依赖软件，并且它不会被使用。

```bash
$ brew autoremove
==> Autoremoving 5 unneeded formulae:
abseil
cmocka
heroku/brew/heroku-node
lua@5.3
protobuf
Uninstalling /opt/homebrew/Cellar/cmocka/1.1.7... (17 files, 194.7KB)
Uninstalling /opt/homebrew/Cellar/heroku-node/14.19.0... (6 files, 73.5MB)
Uninstalling /opt/homebrew/Cellar/lua@5.3/5.3.6... (28 files, 407.2KB)
Uninstalling /opt/homebrew/Cellar/protobuf/23.4... (389 files, 12.2MB)
Uninstalling /opt/homebrew/Cellar/abseil/20230125.3... (716 files, 10.0MB)
```

#### 2. 清除缓存

- 清除旧版的缓存：`brew cleanup -s`，这个操作只会保留安装软件的最新安装包，并把旧版本的安装包删除
- 清楚所有的缓存: `rm -r "$(brew --cache)"`

#### 3. 清除 Taps（适用于 3.6 以上的版本）

[4.0.0 — Homebrew](https://brew.sh/2023/02/16/homebrew-4.0.0/)

从 Homebrew 3.6 开始，为了加速官方维护的 Tap（第三方软件源）的更新，将更新方式从 `git clone` 迁移到 `json` 下载的方式。

官方维护的 Tap ： 

- homebrew/bundle
- homebrew/cask

从上面文件目录看，除了安装软件本身，第二大占用就是官方的这两个 Tap 了。

```bash
$ brew untap homebrew/cask homebrew/core
Untapping homebrew/cask...
Untapped 4255 casks (4,329 files, 371.3MB).
Untapping homebrew/core...
Untapped 3 commands and 6674 formulae (7,043 files, 474.5MB).
```

### 结语

运气好可以省出一个 7 亿参数规模的 Llama2 模型的空间，如果你的 Homebrew 平时不怎么管理的，那估计能省更多空间出来。祝好运！







