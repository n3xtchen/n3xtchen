---
categories:
- vim
date: "2017-01-22T00:00:00Z"
description: ""
tags:
- vim
title: Vim - NERDTree 文件(夹)操作
---

首先，在 **vim** 中键入如下命令打开 `NERDTree`：
	
	:NERDTree

通过 `ctrl` + `w` 加上方向键切换到 NERDTree 工具条，键入 `m`：


	NERDTree Menu. Use j/k/enter and the shortcuts indicated
	==========================================================
	> (a)dd a childnode	# 一个节点，可以是文件或者文件夹
	  (m)ove the current node	# 移动或者重命名当前节点
	  (d)elete the current node	# 删除当前节点
	  (r)eveal in Finder the current node	# 文件系统中打开当前节点
	  (o)pen the current node with system editor # 使用系统默认的编辑器打开
	  (q)uicklook the current node
	  (c)opy the current node
	  (l)ist the current node
	  

## 现在讲解几个常用的操作

### 添加文件或者文件夹

`m` 模式下，键入 `a` 进入如下界面：

	Add a childnode
	==========================================================
	Enter the dir/file name to be created. Dirs end with a '/'	# 文件夹要以斜杠结尾
	/private/tmp/test/1/[这里你输入你要的文件名]

### 重命名或者移动文件

`m` 模式下，键入 `m` 进入如下界面：
	
	Rename the current node
	==========================================================
	Enter the new path for the node:
	/private/tmp/test/1/my	# 这里修改你要名称或者路径
	

### 删除文件

`m` 模式下，键入 `d` 进入如下界面：
	
	Delete the current node
	==========================================================
	Are you sure you wish to delete the node:
	/private/tmp/test/1/my (yN):
	
	
	