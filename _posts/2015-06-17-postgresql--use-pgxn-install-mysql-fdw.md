---
layout: post
title: "PostgreSQL - 使用 PGXN 安装 Mysql-fdw"
description: ""
category: postgresql
tags: [database, extension]
---
{% include JB/setup %}


### 环境要求

* postgresql 9.4
* mysql 5.5
* python2.7 with pip
* [sqitch](http://sqitch.org/)(将在后续配置 SQL 时，使用它)
* git(可选，将在后续配置 SQL 时，使用它)

### PGXN 安装

	$ pip install pgxnclient
	
### PGXN 命令

	$ pgxn help
	usage: pgxn [--help] [--version] COMMAND ...
	
	Interact with the PostgreSQL Extension Network (PGXN).
	
	optional arguments:
	  --help     打印帮助信息并推出
	  --version  打印版本并退出
	
	available commands:
		COMMAND    查看具体命令的用法
			`pgxn help --all`. 内置命令如下:
		check     检查包
		download  下载包，供手动安装时使用
		help      帮助
		info      查询包信息
		install   下载并安装
		load      载入到特定数据库
		mirror    返回可用的下载镜像
		search    搜索
		uninstall 卸载
		unload    卸载扩展]
	    
### 安装 mysql_fdw

首先我们先查看下 mysql_fdw 的包信息

	$ pgxn info mysql_fdw
	name: mysql_fdw
	abstract: MySQL FDW for PostgreSQL 9.3+
	description: This extension implements a Foreign Data Wrapper for MySQL. It is supported on PostgreSQL 9.3 and above.
	maintainer: mysql_fdw@enterprisedb.com
	license: postgresql
	release_status: stable
	version: 2.0.1
	date: 2015-02-04T12:45:26Z
	sha1: dae449a1b017335cf9b19fc769a44589b26f5a59
	provides: mysql_fdw: 2.0.1
	runtime: requires: PostgreSQL 9.3.0
	
然后开始安装：

	$ pgxn install mysql_fdw
	
如果报错，尝试下面的命令：

	$ USE_PGXS=1 pgxn install mysql_fdw
	
### 启用 mysql_fdw 模块

首先，要载入模块，有两种方法：

1. 使用 SQL：
	
		$ CREATE EXTENSION mysql_fdw;
		 	
2. 使用 PGXN：

	我们先看下 pgxn 载入模块命令的用法
	
		$ pgxn help load
		usage: pgxn load [--help] [--mirror URL] [--verbose] [--yes]
                 [--stable | --testing | --unstable] [-d DBNAME] [-h HOST]
                 [-p PORT] [-U NAME] [--pg_config PROG] [--schema SCHEMA]
                 SPEC [EXT [EXT ...]]

		load a distribution's extensions into a database
		
		positional arguments:
		  SPEC                  制定要载入的扩展（或列表）
		  EXT                   只能指定要载入的扩展，默认是全部
		
		optional arguments:
		  --help                打印帮助信息并推出
		  --stable              只接受稳定的版本（默认）
		  --testing             也接受测试中的版本
		  --unstable            也接受不稳定的版本
		  --pg_config PROG      pg_config 可执行命令
		  --schema SCHEMA       使用 SCHEMA 代替默认
		
		global options:
		  --mirror URL          需要交互的镜像 [默认:
		                        http://api.pgxn.org/]
		  --verbose             打印更多信息
		  --yes                 确认所有命令提问
		
		database connections options:
		  -d DBNAME, --dbname 	 库名
		  -h HOST, --host HOST  库主机
		  -p PORT, --port PORT  库端口
		  -U NAME, --username NAME	用户名
		  
		  ... 此时省略

	
	现在，我们使用 pgxn load 命令载入模块
		
		$ pgxn load -d DBNAME -h HOST -p PORT -U NAME SEPC mysql_fdw


### 创建 mysql 外部表

（首先，让我们添加一个有用的 git 别名，我们将在后续中使用，可选）

	$ git config --global alias.add-commit '!git add -A && git commit'

接下来，创建一个测试数据库：

	$ createdb fdw_test
	$ git init .
	Initialized empty Git repository in /Users/ichexw/Dev/pgsql/restapi/.git/
	$ sqitch init fwd_test
	Created sqitch.conf
	Created sqitch.plan
	Created deploy/
	Created revert/
	Created verify/
	$ sqitch config core.engine pg
	$ sqitch target add production db:pg://localhost:5432/fdw_test
	$ sqitch engine add pg
	$ sqitch engine set-target pg production
	$ sqitch add appschmea -n 'Add schema for fdw_test object'
	Created deploy/appschmea.sql
	Created revert/appschmea.sql
	Created verify/appschmea.sql

deploy/appschmea.sql

	BEGIN;
	CREATE EXTENSION mysql_fdw;
	create schema fwd_test;  
	COMMIT; 

revert/appschmea.sql

	BEGIN;  
	DROP EXTENSION mysql_fdw;
	drop schema fwd_test;  
	COMMIT; 

部署你的变更

	Adding registry tables to production
	Deploying changes to production
	  + appschmea .. ok

如果部署成功，把变更提交到版本控制中

	$git add-commit -m "Adding fdw_test schema"
	[master (root-commit) be4eec4] Adding fdw_test schema
	 5 files changed, 43 insertions(+)
	 create mode 100644 deploy/appschmea.sql
	 create mode 100644 revert/appschmea.sql
	 create mode 100644 sqitch.conf
	 create mode 100644 sqitch.plan
	 create mode 100644 verify/appschmea.sql
	 
现在重复上面的步骤，把我们的 mysql 关联到当前数据库

	$ sqitch add mysql_server -n "Add the mysql fdw"
	Created deploy/mysql_server.sql
	Created revert/mysql_server.sql
	Created verify/mysql_server.sql
	Added "mysql_server" to sqitch.plan
	
deploy/mysql_server.sql

	BEGIN;
	
	-- 创建服务对象，即 mysql 服务
	CREATE SERVER mysql_server
	    FOREIGN DATA WRAPPER mysql_fdw
	    OPTIONS (host '127.0.0.1', port '3306');
	
	-- 创建映射的用户，即 mysql 的用户
	CREATE USER MAPPING FOR postgres
	SERVER mysql_server
	OPTIONS (username 'root', password '');
	
	-- 创建外部封装数据，即要映射的 mysql 表
	CREATE FOREIGN TABLE pg_fdw(                                                                  
		id int,
	    name text,
	    created timestamp
	) SERVER mysql_server                                                                     	OPTIONS (dbname 'test', table_name 'pg_fdw');
	
	COMMIT;
	
revert/mysql_server.sql

	-- Revert fwd_test:mysql_server from pg
	
	BEGIN;
	
	-- 注意注意先后顺序
	DROP FOREIGN TABLE pg_fdw;
	DROP USER MAPPING FOR ichexw SERVER mysql_server;
	DROP SERVER mysql_server;
	
	COMMIT;
	
  
### 使用 mysql 外部表   
	
#### 在 mysql 服务器中操作
	
	mysql> INSERT INTO pg_fdw values (1, 'UPS', sysdate());
	Query OK, 1 row affected (0.01 sec)
	mysql> INSERT INTO pg_fdw values (2, 'TV', sysdate());
	Query OK, 1 row affected (0.01 sec)
	mysql> INSERT INTO pg_fdw values (3, 'Table', sysdate());
	Query OK, 1 row affected (0.01 sec)
	mysql> select * from pg_fdw;
	+------+-------+---------------------+
	| id   | name  | created             |
	+------+-------+---------------------+
	|    1 | UPS   | 2015-08-14 12:22:23 |
	|    2 | TV    | 2015-08-14 12:22:49 |
	|    3 | Table | 2015-08-14 12:23:04 |
	+------+-------+---------------------+
	3 rows in set (0.00 sec)
	
#### 在 pgsql 中可以进行同样的操作
	
	fdw_test=# select * from pg_fdw
	fdw_test-# ;
	 id | name  |       created
	----+-------+---------------------
	  1 | UPS   | 2015-08-14 12:22:23
	  2 | TV    | 2015-08-14 12:22:49
	  3 | Table | 2015-08-14 12:23:04
	(3 rows)

	fdw_test=# DELETE FROM pg_fdw where id = 3;
	DELETE 1
	fdw_test=# UPDATE pg_fdw set name = 'UPS_NEW' where id = 1;
	UPDATE 1	
	
#### 我门看看 pgsql 是如何操作 mysql 表的	
	
	fdw_test=# EXPLAIN ANALYZE VERBOSE SELECT id, name FROM pg_fdw WHERE name LIKE 'Table' limit 1;
	                                                     QUERY PLAN
	--------------------------------------------------------------------------------------------------------------------
	 Limit  (cost=10.00..11.00 rows=1 width=36) (actual time=0.653..0.653 rows=1 loops=1)
	   Output: id, name
	   ->  Foreign Scan on public.pg_fdw  (cost=10.00..13.00 rows=3 width=36) (actual time=0.652..0.652 rows=1 loops=1)
	         Output: id, name
	         Local server startup cost: 10
	         Remote query: SELECT `id`, `name` FROM `test`.`pg_fdw` WHERE ((`name` like 'Table'))
	 Planning time: 0.589 ms
	 Execution time: 10.999 ms
	(8 rows)
	
### 结语

哈哈，是不是很方便，**PostgreSQL** 的 FDW 不仅仅支持 **MySQL**，还支持 **Oracle**，**MSSQL** 等等所有主流的数据库，这无形中给数据迁移，带来的极大方便，使用同一个数据库来操作不同的数据，也对多数据库应用带来了很大的便利，是不是很吸引人，快到碗里来吧！^_^

