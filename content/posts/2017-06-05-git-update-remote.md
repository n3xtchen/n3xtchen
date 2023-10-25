---
categories:
- git
date: "2017-06-05T00:00:00Z"
description: ""
tags:
- git
title: Git 修改远端仓库地址
---

* 如果你想从 **github/bucket** 迁移到私有的 **gitlab**，或者反过来
* 你的 git 地址域名变更了
* 你的项目名称变更了

并且你的代码库已经比较巨大，不想重新全量 pull 代码，那这个教程就适合你。

### 查看现在代码中的远端仓库地址

	ichexw → git remote -v
	origin	http://old/git/repo.git (fetch)
	origin	http://old/git/repo.git (push)
	
但是，你的远端（Remote）地址变成成 *http://new/git*，怎么办？

一条命令解决

### 修改语段仓库地址

	ichexw → git remote set-url origin http://new/git/repo.git
	
验证下：

	ichexw → git remote -v
	origin	http://new/git/repo.git (fetch)
	origin	http://new/git/repo.git (push)
	
	
你已经成功迁移到新的代码库了，可以愉快的 `pull` 和 `push` 了