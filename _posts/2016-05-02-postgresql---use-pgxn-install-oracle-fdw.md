---
layout: post
title: "PostgreSQL - 使用 PGXN 安装 oracle-fdw"
description: ""
category: PostgreSQL
tags: [database, extension]
---
{% include JB/setup %}

### 安装 oracle_fdw

设置环境变量

	$ export ORACLE_HOME=/mfs/lib/oracle/instantclient_12_1
	$ pgxn install oracle_fdw

> pgxn 的安装见 [PostgreSQL - 使用 PGXN 安装 Mysql-fdw](http://n3xtchen.github.io/n3xtchen/postgresql/2015/06/17/postgresql-use-pgxn-install-mysql-fdw)
	
### 启用 oracle_fdw	
	
创建扩展：

	$ pgsql —db=n3xt_pg
	n3xt_pg# CREATE EXTENSION oracle_fdw;
	CREATE EXTENSION

#### 提示少了 so 文件,报错如下

	postgres=# create extension oracle_fdw;
	ERROR:  could not load library "/opt/pgsql/lib/oracle_fdw.so": libclntsh.so.12.1: cannot open shared object file: No such file or directory

说明动态链接库没有正确的引入

1. 使用 `ln`

	首先查找下这个动态库的位置
	
		$ locate libclntsh.so.12.1.so
		path/to/libclntsh.so.12.1.so
		
	然后 `ln` 到 `$PGHOME/lib`:
	
		$ ln -s path/to/libclntsh.so.12.1.so $PGHOME/lib/libclntsh.so.12.1.so
		
	同类的问题，你只需要定位该动态库的地址，把它 `ln` 到 `$PGHOME/lib` 即可解决。

2.最简单的方法就是在全局引入需要的动态链接库：
		
	$ echo $ORACLE_HOME > /etc/ld.so.conf.d/oracle.conf
	$ ldconfig
	
重复 `create extension` 即可安装成功。

### 使用 oracle_fdw

####  创建远端服务器（foreign server）
	
	n3xt_pg# CREATE SERVER db FOREIGN DATA WRAPPER oracle_fdw 
	n3xt_pg# OPTIONS (dbserver '//127.0.0.1/TEST');
	
#### 映射关联用户
	
	n3xt_pg# CREATE USER MAPPING FOR admin SERVER db229 
	n3xt_pg# OPTIONS (USER 'test', password 'test');
	
#### 创建外部表（FOREIGN TABLE ）
	
	CREATE FOREIGN TABLE users (
		id INT  NOT NULL,
		username	CHARACTER varying(50) NOT NULL,
		password	CHARACTER varying(256) NOT NULL
	) SERVER db OPTIONS (TABLE 'USER' );
	
#### 查询测试

	n3xt_pg# select id, username from users;
	 id | username 
	----+---------
	  1 | n3xtchen
	(2 rows)

