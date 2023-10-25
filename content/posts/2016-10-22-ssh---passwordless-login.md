---
categories:
- linux
date: "2016-10-22T00:00:00Z"
description: ""
tags: []
title: SSH - 无密码登录
---

### 第一步：生成 Key

在你的机子上，使用 `ssh-keygen` 生成 RSA 私钥（你已经做了，可以跳过这一步）
	
		$ ssh-keygen -t rsa
		Generating public/private rsa key pair.
		# 这一步一般不修改，直接Enter使用默认值，否则你需要输入路径
		Enter file in which to save the key ({你的用户根目录}/.ssh/id_rsa): 
		# 这一步很重要，以为本文的主题是无密码登录，所以就直接回车
		Enter passphrase (empty for no passphrase): 
		Enter same passphrase again:
		Your identification has been saved in /home/username/.ssh/id_rsa
		Your public key has been saved in {你的用户根目录}/.ssh/id_sra.pub
		
		The key fingerprint is:
		ar:bc:d3:9e:g3:1f:63:6f:6b:32:2e:97:ee:42:e1:be n3xtchen@aybe.me
		
		The key’s randomart image is:
		
		+--[ RSA 2048]----+
		| ..+**B.o++o     |
		|  . o+==o. o     |
		|    . .oo.=      |
		|      . +E+ .    |
		|        S .      |
		|                 |
		|                 |
		|                 |
		|                 |
		+-----------------+
		
### 第二步：部署你的公钥到你需要登录的服务器上

#### Linux 下的步骤

	$ ssh-copy-id -i ~/.ssh/id_rsa.pub username@hostname
	/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
	/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed == if 	you are prompted now it is to install the new keys
	username@hostname's password:	# 输入服务器密码
	Number of key(s) added: 1
	
#### Os X 下的步骤

	$ cat ~/.ssh/id_rsa.pub | ssh username@server.dreamhost.com "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
	The authenticity of host 'server.dreamhost.com (208.113.136.55)' can't be established.
	RSA key fingerprint is 50:46:95:5f:27:c9:fc:f5:f5:32:d4:3a:e9:cb:4f:9f.
	Are you sure you want to continue connecting (yes/no)? yes
	
	Warning: Permanently added 'm.aybe.me, 0.0.0.0' (RSA) to the list of known hosts.
	
	username@hostname's password:

### 步骤三：验证

必须确认文件权限：

* 服务器上的 .ssh 目录必须是 700
* 你的机子的 .ssh 目录必须是 600

然后使用命令登录：

	$ ssh username@hostname
	
大功告成！🍻



> 参考文献
> 
> 	* https://help.dreamhost.com/hc/en-us/articles/216499537-How-to-configure-passwordless-login-in-Mac-OS-X-and-Linux
> 	* https://coolestguidesontheplanet.com/make-passwordless-ssh-connection-osx-10-9-mavericks-linux/