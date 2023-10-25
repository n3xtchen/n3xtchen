---
categories:
- docker
date: "2017-04-15T00:00:00Z"
description: ""
tags:
- docker
title: Docker 指令之 ENTRYPOINT 和 CMD
---

`CMD` 和 `ENTRYPOINT` 指令在运行容器时决定哪些命令将被执行。下面是它们几条共同合作的规则：

1. *Dockerfile* 应该至少指定一个 `CMD` 或者 `ENTRYPOINT` 命令。
2. `ENTRYPOINT` 应该在使用可执行容器时被指定。
3. `CMD` 应该作为 `ENTRYPOINT` 命令定义默认参数或者运行即席命令的一种方式。
4. `CMD` 在容器作为可替换参数时会被替换。

下面例子将会演示上述的规则：

#### 没有 ENTRYPOINT

带方括号（`[]`）的是执行形式（exec form，推荐使用），如果不带方括号则是shell形式（就会在命令的前面加上 `/bin/sh -c` ）。

| 命令                        | 说明                       |
|:---------------------------|:---------------------------|
| No CMD                     | 错误，不允许                 |
| CMD [“exec_cmd”, “p1_cmd”] | exec_cmd p1_cmd            |
| CMD [“p1_cmd”, “p2_cmd”]   | p1_cmd p2_cmd              |
| CMD exec_cmd p1_cmd        | /bin/sh -c exec_cmd p1_cmd |

#### ENTRYPOINT exec_entry p1_entry（shell 形式）

第三个命令就是使用 CMD 为 ENTRYPOINT 设置默认参数（CMD 中都只是参数而不是可执行程序）。

| 命令                        | 说明                                                     |
|:---------------------------|:---------------------------------------------------------|
| No CMD                     | /bin/sh -c exec_entry p1_entry                           |
| CMD [“exec_cmd”, “p1_cmd”] | /bin/sh -c exec_entry p1_entry exec_cmd p1_cmd           |
| CMD [“p1_cmd”, “p2_cmd”]   | /bin/sh -c exec_entry p1_entry p1_cmd p2_cmd             |
| CMD exec_cmd p1_cmd        | /bin/sh -c exec_entry p1_entry /bin/sh -c exec_cmd p1_cmd |

#### ENTRYPOINT [“exec_entry”, “p1_entry”]（执行形式）

| 命令                       | 说明                                            |
|:---------------------------|:-----------------------------------------------|
| No CMD                     | exec_entry p1_entry                            |
| CMD [“exec_cmd”, “p1_cmd”] | exec_entry p1_entry exec_cmd p1_cmd            |
| CMD [“p1_cmd”, “p2_cmd”]   | exec_entry p1_entry p1_cmd p2_cmd              |
| CMD exec_cmd p1_cmd        | exec_entry p1_entry /bin/sh -c exec_cmd p1_cmd |

#### Over！

> 引用自：[What is the difference between CMD and ENTRYPOINT in a Dockerfile?](http://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile/21558992#21558992)

