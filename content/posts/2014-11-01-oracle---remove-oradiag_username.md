---
categories:
- Oracle
date: "2014-11-01T00:00:00Z"
description: ""
tags:
- Oracle
title: Oracle - 如何让你的 oradiag_<username> 永久消失
---

如果你在你的 PC 机上安装了 Oracle 数据库，不久你就会发现 `/home/username` 目录下会产生一个 `oradiag_<username>`。你删除了之后，还是会不断的产生！没办法，本人有洁癖，于是在 **StackOverflow** 上找到了[解决方法](http://stackoverflow.com/questions/3520054/what-is-oradiag-user-folder)，这里做个笔记。

1. 首先，你需要找到发生这个的根源，其实根源你厌恶的文件中：
		
		$ head ~/oradiag_<username>/diag/clients/user_<username>/host_*/trace/sqlnet.log
		Sat Nov 01 16:28:19 2014
		Create Relation ADR_CONTROL
		Create Relation ADR_INVALIDATION
		Create Relation INC_METER_IMPT_DEF
		Create Relation INC_METER_PK_IMPTS
		Directory does not exist for read/write [/usr/lib/log/diag/] [/usr/lib/log/diag/clients]
		
	原因是由于 `[/usr/lib/log/diag/] [/usr/lib/log/diag/clients]` 不存在或者不可读写

    不同的软件可能目录有偏差，我使用是 **OS X** 下的 **navicat-for-oracle**，我的要修复的目录如下：
    
    * [/opt/homebrew-cask/Caskroom/navicat-for-oracle/11.0.20/Navicat for Oracle.app/Contentts/OCI/log] 
    * [/opt/homebrew-cask/Caskroom/navicat-for-oracle/11.0.20/Navicat for Oracle.app/Contents/OCI/log/diag/clients]` 

    所以，具体目录要根据的日志信息！

2. 现在找到原因，对症下药自然就药到病除：

		cd /opt/homebrew-cask/Caskroom/navicat-for-oracle/11.0.20/Navicat for Oracle.app/Contentts/OCI/
		sudo chmod -R 777 log
		sudo mkdir log/clients	# 如果存在，就不需要创建
		sudo chmod -R 777 log/clients
		
^_^，轻松搞定，烦劳不再来！

