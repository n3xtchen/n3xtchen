---
categories:
- PostgreSQL
date: "2015-08-13T00:00:00Z"
description: ""
tags:
- database
- restful
title: PostgreSQL - PostGrest 简介
---

> 译自 [PostGrest Introduction](http://blog.jonharrington.org/postgrest-introduction/)

我目前在进行一个项目，[PostgREST](https://github.com/begriffs/postgrest)，它读取你 **PostgreSQL** 数据库，自动创建“一个简洁的，更标准兼容，更快的 API“。

## 安装

二进制文件在 OS X 和 Linux 下可用，你还需要安装好的 **PostgreSQL** 。接下来，让我们创建一个简单的数据库，并使用一些数据丰富它。[Sqitch](http://sqitch.org/) 是一个管理数据库变更的好工具，我们将在后面的使用到它。

	$ wget https://github.com/begriffs/postgrest/releases/download/v0.2.10.0/postgrest-0.2.10.0-osx.tar.xz
	$ tar xvfJ postgrest-0.2.10.0-osx.tar.xz
	x postgrest-0.2.10.0
	$ mv postgrest-0.2.10.0 postgrest
	$ chmod +x postgrest

## 工作原理

**PostgREST** 允许你建立一个多版本的 API 接口，它假定你将每一个版本存储在 **schema** 中，因此版本 1 就是存储在 **schema** “1” 中，以此类推。

显然，大部分产品数据库不会有一个名叫 “1” 的 **schema**，因此我们可以在 **schema** “1” 中创建视图把数据暴露给 **PostgREST**。我也强烈推荐你也在新的项目中使用这套规范，一个 **REST** 资源没必要映射表的每一行，使用视图从我们的存储格式转化成我们的展示层。

## 创建一个数据

（首先，让我们添加一个有用的 **git** 别名，我们将在后续中使用，可选）

	$ git config --global alias.add-commit '!git add -A && git commit'
	
接下来，创建一个简单的数据库，使用一些数据丰富它。

	$ createdb goodfilm
	$ git init .
	Initialized empty Git repository in /Users/ichexw/Dev/pgsql/restapi/.git/
	$ sqitch init goodfilm
	Created sqitch.conf
	Created sqitch.plan
	Created deploy/
	Created revert/
	Created verify/
	$ sqitch config core.engine pg
	$ sqitch target add production db:pg://localhost:5432/goodfilm
	$ sqitch engine add pg
	$ sqitch engine set-target pg production
	$ sqitch add appschmea -n 'Add schema for good film object'
	Created deploy/appschmea.sql
	Created revert/appschmea.sql
	Created verify/appschmea.sql
	
deploy/appschmea.sql
	
	BEGIN;  
	create schema film;  
	COMMIT; 
	
revert/appschmea.sql

	BEGIN;  
	drop schema film;  
	COMMIT; 
	
部署你的变更

	$ sqitch deploy
	Adding registry tables to production
    Deploying changes to production
      + appschmea .. ok
  
如果部署成功，把变更提交到版本控制中

	$ git add-commit -m "Adding goodfilm schema"
	[master (root-commit) d2d6c70] Adding goodfilm schema
	6 files changed, 41 insertions(+)
	create mode 100644 deploy/appschmea.sql
	create mode 100644 postgrest-0.2.10.0-osx.tar.xz
	create mode 100644 revert/appschmea.sql
	create mode 100644 sqitch.conf
	create mode 100644 sqitch.plan
	create mode 100644 verify/appschmea.sql
	
现在重复上面的步骤，添加 goodfilm 表（一般你会吧这个分到多个文件中，但是为了简洁，我们将使用一个文件）。

	$ sqitch add film -n "Add the goodfilm tables"
	Created deploy/film.sql
	Created revert/film.sql
	Created verify/film.sql
	Added "film" to sqitch.plan
	
deploy/film.sql
	
	BEGIN;
	
	CREATE TABLE film.director  
	(
	  name text NOT NULL PRIMARY KEY
	);
	
	CREATE TABLE film.film  
	(
	  id serial PRIMARY KEY,
	  title text NOT NULL,
	  year date NOT NULL,
	  director text,
	  rating real NOT NULL DEFAULT 0,
	  language text NOT NULL,
	  CONSTRAINT film_director_fkey FOREIGN KEY (director)
	      REFERENCES film.director (name) MATCH SIMPLE
	      ON UPDATE NO ACTION ON DELETE NO ACTION
	);
	
	CREATE TABLE film.festival  
	(
	  name text NOT NULL PRIMARY KEY
	);
	
	CREATE TABLE film.competition  
	(
	  id serial PRIMARY KEY,
	  name text NOT NULL,
	  festival text NOT NULL,
	  year date NOT NULL,
	
	  CONSTRAINT comp_festival_fkey FOREIGN KEY (festival)
	      REFERENCES film.festival (name) MATCH SIMPLE
	      ON UPDATE NO ACTION ON DELETE NO ACTION
	);
	
	CREATE TABLE film.nominations  
	(
	  id serial PRIMARY KEY,
	  competition integer NOT NULL,
	  film integer NOT NULL,
	  won boolean NOT NULL DEFAULT true,
	
	  CONSTRAINT nomination_competition_fkey FOREIGN KEY (competition)
	     REFERENCES film.competition (id) MATCH SIMPLE
	     ON UPDATE NO ACTION ON DELETE NO ACTION,
	  CONSTRAINT nomination_film_fkey FOREIGN KEY (film)
	     REFERENCES film.film (id) MATCH SIMPLE
	     ON UPDATE NO ACTION ON DELETE NO ACTION
	);
	
	COMMIT; 
	
revert/film.sql

	BEGIN;
	
	DROP TABLE film.director CASCADE;  
	DROP TABLE film.film CASCADE;  
	DROP TABLE film.festival CASCADE;  
	DROP TABLE film.competition CASCADE;  
	DROP TABLE film.nominations CASCADE;
	
	COMMIT;
	
	
	$ sqitch deploy
	Deploying changes to production
	  + film .. ok
	$ git add-commit -m "Adding film table"
	[master 1122a28] adding film table
	 4 files changed, 76 insertions(+)
	 create mode 100644 deploy/film.sql
	 create mode 100644 revert/film.sql
	 create mode 100644 verify/film.sql

好的，现在让我们添加一些数据看看。我们将使用威尼斯金狮奖和金棕榈奖最近20年被提名的电影。

	$ git clone https://gist.github.com/7d07a5cd840734342d35.git
	Cloning into '7d07a5cd840734342d35'...
	remote: Counting objects: 6, done.
	remote: Compressing objects: 100% (4/4), done.
	remote: Total 6 (delta 1), reused 0 (delta 0), pack-reused 0
	Unpacking objects: 100% (6/6), done.
	Checking connectivity... done.
	$ psql -d goodfilm < d07a5cd840734342d35/insert_data.sql
	
现在，让我们查询下数据

	$ psql -d goodfilm
	goodfilm=#  select title, rating from film.film limit 5;
	        title        | rating
	---------------------+--------
	 Chuang ru zhe       |    6.2
	 The Look of Silence |    8.3
	 Fires on the Plain  |    5.8
	 Far from Men        |    7.5
	 Good Kill           |    6.1
	 (5 rows)
	 
	 goodfilm=# select * from film.nominations limit 5;
	 id | competition | film | won
	----+-------------+------+-----
	  1 |           1 |    1 | f
	  2 |           1 |    2 | f
	  3 |           1 |    3 | f
	  4 |           1 |    4 | f
	  5 |           1 |    5 | f
	 (5 rows)
	 
让我们查询下提名前五的电影

	goodfilm=# SELECT substring(f.title from 1 for 20) as title, c.name, f.rating from film.nominations as n
        LEFT JOIN film.film as f ON f.id=n.film
        LEFT JOIN film.competition as c ON c.id=n.competition
        ORDER BY f.rating DESC
        limit 5;
        title         |    name     | rating
	----------------------+-------------+--------
	 Winter Sleep         | Palme d'Or  |    8.5
	 Mommy                | Palme d'Or  |    8.3
	 The Look of Silence  | Golden Lion |    8.3
	 Birdman: Or (The Une | Golden Lion |      8
	 Sivas                | Golden Lion |    7.7
	(5 rows)
	
## 创建一个 API

现在我们将会使用 **PostgREST** 来创建一个 API。我们将暴露是三个资源：

* **Film**：电影列表
* **Festival**：包含每年赛事和提名
* **Director**：包含这些电影的导演信息

首先，我们需要添加一个新的 **schema**

	$ sqitch add v1schema -m 'adding API v1 schema'
	Created deploy/v1schema.sql
	Created revert/v1schema.sql
	Created verify/v1schema.sql
	Added "v1schema" to sqitch.plan
	
deploy/v1schema.sql

	BEGIN;  
	create schema "1";  
	COMMIT;
	
revert/v1schema.sql

	BEGIN;  
	drop schema "1";  
	COMMIT;
	
提交它，部署它并把文件加到我们的 API

	$ git add-commit -m "Adding API schema"
	[master 68f5b73] Adding API schema
	 6 files changed, 25 insertions(+)
	 create mode 160000 7d07a5cd840734342d35
	 create mode 100644 deploy/v1schema.sql
	 create mode 100644 postgrest-0.2.10.0-osx.tar.xz.1
	 create mode 100644 revert/v1schema.sql
	 create mode 100644 verify/v1schema.sql
	$ sqitch deploy
	Deploying changes to production
	  + v1schema .. ok
	$ sqitch add v1views -m "Adding API v1 views"
	Created deploy/v1views.sql
	Created revert/v1views.sql
	Created verify/v1views.sql
	Added "v1views" to sqitch.plan
	
现在我们把视图添加我们想要暴露的 API 中。

deploy/v1views.sql

	BEGIN;
	
	create or replace view "1".film as  
	select title, film.year, director, rating, language, comp.name as competition from film.film  
	 left join film.nominations as n on film.id = n.film
	 left join film.competition as comp on n.competition = comp.id;
	
	create or replace view "1".festival as  
	select comp.festival,  
	       comp.name as competition,
	       comp.year,
	       film.title,
	       film.director,
	       film.rating
	 from film.nominations as noms
	 left join film.film as film on noms.film = film.id
	 left join film.competition as comp on noms.competition = comp.id
	 order by comp.year desc, comp.festival, competition;
	
	create or replace view "1".director as  
	select d.name, f.title, f.year, f.rating from film.director as d  
	 left join film.film as f on f.director = d.name;
	
	COMMIT;
	
revert/v1views.sql

	BEGIN;  
	drop view "1".film;  
	drop view "1".director;  
	drop view "1".festival;  
	COMMIT;
	
现在我们部署它，然后运行 **PostGREST** 看看

	$ sqitch deploy
	Deploying changes to production
	  + v1views .. ok
	$ postgrest --db-host localhost --db-port 5432 --db-name goodfilm --db-pool 200 --anonymous $USER --port 3000 --db-user $USER
	WARNING, running in insecure mode, auth will be in plaintext
	WARNING, running in insecure mode, JWT secret is the default value
	Listening on port 3000
	
现在看看结果

	$ curl -s http://localhost:3000/ | python -m json.tool
	[
	    {
	        "insertable": false,
	        "name": "director",
	        "schema": "1"
	    },
	    {
	        "insertable": false,
	        "name": "festival",
	        "schema": "1"
	    },
	    {
	        "insertable": false,
	        "name": "film",
	        "schema": "1"
	    }
	]
	
我们想要查看评分超过 8 的电影

	$ curl -s "http://localhost:3000/festival?year=gte.2014-01-01&rating=gte.8" | python -m json.tool
	[
	    {
	        "competition": "Palme d'Or",
	        "director": "Xavier Dolan",
	        "festival": "Cannes Film Festival",
	        "rating": 8.3,
	        "title": "Mommy",
	        "year": "2014-01-01"
	    },
	    {
	        "competition": "Palme d'Or",
	        "director": "Nuri Bilge Ceylan",
	        "festival": "Cannes Film Festival",
	        "rating": 8.5,
	        "title": "Winter Sleep",
	        "year": "2014-01-01"
	    },
	    {
	        "competition": "Golden Lion",
	        "director": "Joshua Oppenheimer",
	        "festival": "Venice Film Festival",
	        "rating": 8.3,
	        "title": "The Look of Silence",
	        "year": "2014-01-01"
	    },
	    {
	        "competition": "Golden Lion",
	        "director": "Alejandro Gonz\u00e1lez I\u00f1\u00e1rritu",
	        "festival": "Venice Film Festival",
	        "rating": 8,
	        "title": "Birdman: Or (The Unexpected Virtue of Ignorance)",
	        "year": "2014-01-01"
	    }
	]

太棒了，一些加到我们查看列表。我是日本电影超级粉丝，因此看看去年提名的日本电影。

	$ curl -s "http://localhost:3000/film?year=gte.2014-01-01&language=eq.Japanese" | python -m json.tool
	[
	    {
	        "competition": "Golden Lion",
	        "director": "Shin'ya Tsukamoto",
	        "language": "Japanese",
	        "rating": 5.8,
	        "title": "Fires on the Plain",
	        "year": "2014-01-01"
	    },
	    {
	        "competition": "Palme d'Or",
	        "director": "Naomi Kawase",
	        "language": "Japanese",
	        "rating": 6.9,
	        "title": "Still the Water",
	        "year": "2014-01-01"
	    }
	]
	
## 结论

我希望我已经展示了 **PostgreSQL** 如何结合 **PostGrest** 快速把数据暴露给其他应用或者 web 前端。

我对这个项目寄以厚望，你现在有少了必须使用 **NoSQL** 数据存储你的数据的原因（因为自由的 REST API），你也没有理由放弃关系数据库的好处。
	
