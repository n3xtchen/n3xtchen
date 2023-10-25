---
categories:
- PostgreSQL
date: "2015-06-16T00:00:00Z"
description: ""
tags:
- database
- json
- api
title: 简化：将代码移到数据库函数中
---

> 原文引用：[Simplify: move code into database functions](https://sivers.org/pg)

如果你是一个网页或者接口开发者，并且使用数据库，那这边适合你。

我发现了一种不同寻常和有用的方式构建代码。这对我来说是非常的与众不同，因此我必须分享它。

## 事情是怎样的呢？

大部分 Web 开发者－无论是依赖还是不依赖框架（如 Rails，Django，Laravel，Sinatra，Flask 或者是 Symfony）－都适用同样的模式工作：

* 核心的数据库只是作为数据的存储
* 所有逻辑都在 Ruby/Python/PHP/Javascript 类中。

## 为什么这样不好呢？？

这样可能会导致一些潜在的问题：

* 所有东西都必须通过 Ruby/Python/PHP/Javascript 类来实现－也包括 shell 脚本以及其他不属于网站的部分；
* 所有东西都不能直接访问数据；为了这么做，你必须要把逻辑定义在其他语言中；
* 数据被当作愚蠢的存储器，即使数据库足够智能，可以完成大部分的逻辑；
* 如果你增加业务逻辑到数据库中，那你需要同时变更代码和数据结构；如果它的规则也变化，那就需要修改更多的地方；
* 两个系统－数据和围绕它的代码－相互捆绑又彼此独立；
* 如果需要使用其他语言（比如从 Ruby 到 Javascript，或者 Python 到 Elixir），你就必须要重写所有的东西。

## 简单 VS 复杂

你应该去听听 **Rich Hichkey** 35 分钟令人惊叹的演讲 [Simplicity Matters by Rich Hickey](https://www.youtube.com/watch?v=rI8tNMsozo0)。

对于这篇文章，与他的观点不谋而合：

* **复杂** 是客观存在。它意味着很多东西都捆绑在一起；
* **简单** 也是客观存在的。它可以是一种原材料，**复杂**的对立面；
* 它门都和 **简单** 无关。你可以很容易的安装和自己绑定在一些非常复杂的东西上（如 ORM），有时候创建一个简单的东西却很困难；
* 类，模型以及方法（OOP）是一个不必要并发症；
* 信息是简单的，但是不要把它们隐藏在一个宏语言后面；
* 直接用数值工作：哈希数组；
* 如果一个 JSON 接口－一个哈希数组－作为最终接口，那就更有理由跳过抽象成，直接使用数值工作

## 为什么这个很触动我

我从 1997 年开始，一直都使用相同的数据库：同一个数据，值和 SQL 表。但是代码却标更了很多次。

在 1997 年，我使用 **Perl**。1998 年，我转到 **PHP**。2004 年，我使用 **Rails** 重写。2007 年，我又转回道 **PHP**。在 2009 年，使用极简的 **Ruby**。2012 年，使用客户端的 **Javascript**。

**每一次，我都要围绕数据库重写所有的逻辑**：如何添加一个用户信息到数据库，如果验证支票的有效性，以及如何标识一个订单是已付费的等等。

但是 **在这整个过程，我信任的 PostgreSQL 数据库是唯一不变的**。

因为大部分都是[数据逻辑，而不是业务逻辑](http://rob.conery.io/2015/02/21/its-time-to-get-over-that-stored-procedure-aversion-you-have/)，所以它应该在数据库中。

因此，我把我的数据逻辑直接存储在 **PostgreSQL** 中，因为我还计划使用它很多年，但是持续计划使用编程做实验（TO－DO：Haskell，Elixir，Racket，Lua）。

## 那应该是怎样的呢？

Web 开发者已经把数据库作为愚蠢的存储，但是实际上它已经很智能了。

在数据库中就能简单德实现所有的逻辑。

但是把他捆绑在外部的代码就会变的很复杂。

一旦你把所有的逻辑都放到数据库中，那外部的代码就消失了！

然后数据库是自包含的，不用绑定任何东西。

你的外部接口可以很容易转到 Javascript，Haskell，Elixir 或者其他任何东西，因为你的核心逻辑都都在数据库中。

## 那怎么做呢？

### 表约束

最简单的就是从约束（**Constraints**）开始：

	CREATE TABLE people (
	  id serial primary key,
	  name text NOT NULL CONSTRAINT no_name CHECK (LENGTH(name) > 0),
	  email text UNIQUE CONSTRAINT valid_email CHECK (email ~ '\A\S+@\S+\Z')
	);
	CREATE TABLE tags (
	  person_id integer NOT NULL REDERENCES people(id) ON DELETE CASCADE,
	  tag varchar(16) CONSTRAINT tag_format CHECK (statkey ~ '\A[a-z0-9._-]+\Z')
	);
	
在这里定义了数据的有效性验证。

`people` 这张表中，`name` 不能为空，`email` 必须比符合规范（包含 @ 和 . ，不能包含空格）。`tags.person_id` 必须存在 `people` 中，但是如果 `people` 中删除了，`tags` 表中对应的也会删除；另外 **tag** 必须要符合规范，只能是小写字母，数字，点，下划线或者破折号。

### 触发器（Triggers）

如果一些操作必须在你修改数据的之前或者之后触发，那就要使用 [**trigger**](http://n3xtchen.github.io/n3xtchen/postgresql/2015/04/14/postgresql---trigger/)：

	CREATE FUNCTION clean() RETURNS TRIGGER AS $$
	BEGIN
	  NEW.name = btrim(regexp_replace(NEW.name, '\s+', ' ', 'g'));
	  NEW.email = lower(regexp_replace(NEW.email, '\s', '', 'g'));
	END;
	$$ LANGUAGE plpgsql;
	CREATE TRIGGER clean BEFORE INSERT OR UPDATE OF name, email ON people
	  FOR EACH ROW EXECUTE PROCEDURE clean();

这个例子在我们添加数据到数据库之前格式化输入，以防有些人不小心把空格输到邮箱中，或者换行符到他的名字总。

### 函数（Functions）

编写一些可复用的函数，来代替反复使用的代码。

	CREATE FUNCTION get_person(a_name text, a_email text) RETURNS SETOF people AS $$
	BEGIN
	  IF NOT EXISTS (SELECT 1 FROM people WHERE email = a_email) THEN
	    RETURN QUERY INSERT INTO people (name, email)
	      VALUES (a_name, a_email) RETURNING people.*;
	  ELSE
	    RETURN QUERY SELECT * FROM people WHERE email = a_email;
	  END IF;
	END;
	$$ LANGUAGE plpgsql;
	
这是我经常食用的：给定某人的用户名和邮箱，如果他不在我们的数据库中，添加他。然后，从数据库中返回这个用户的信息。

### 用于 JSON 的视图

替代外部代码把你的数据转化成 JSON，你可以[直接在数据库中创建 JSON](http://www.postgresql.org/docs/9.4/static/functions-json.html#FUNCTIONS-JSON-CREATION-TABLE)。

在这里，使用[视图](http://www.postgresql.org/docs/9.4/static/sql-createview.html)来作为 JSON 的结构模版。在视图中，使用 `json_agg` 来嵌入值。

	CREATE VIEW person_view AS
	  SELECT *, (SELECT json_agg(t) AS tags FROM
	    (SELECT tag FROM tags WHERE person_id=people.id) t)
	  FROM people;

这个将在下面 API 的函数中用到。

### API 函数

外部代码只能通过这些函数访问数据库。

他们都只返回 JSON。

	CREATE FUNCTION update_password(p_id integer, nu_pass text, OUT js json) AS $$
	BEGIN
	  UPDATE people SET password=crypt(nu_pass, gen_salt('bf', 8)) WHERE id = p_id;
	  js := row_to_json(r) FROM (SELECT * FROM person_view WHERE id = p_id) r;
	END;
	$$ LANGUAGE plpgsql;
	
	CREATE FUNCTION people_with_tag(a_tag text, OUT js json) AS $$
	BEGIN
	  js := json_agg(r) FROM
	    (SELECT * FROM person_view WHERE id IN
	      (SELECT person_id FROM tags WHERE tag = a_tag)) r;
	END;
	$$ LANGUAGE plpgsql;

任何和数据相关的操作，你都可以使用 **PostgreSQL** 内置的[存储过程语言](http://www.postgresql.org/docs/9.4/static/xplang.html)。

[**PL/pgSQL**](http://www.postgresql.org/docs/9.4/static/plpgsql-overview.html) 不是一个最简洁的语言，但是为了简化数据库操作，还是值得的。

如果你喜欢 **Javascript**，你可能需要 **PLv8**，这有个[关于它好的分享](http://plv8-talk.herokuapp.com/)。


## 现在，如果你需要一个 REST API：

	require 'pg'
	require 'sinatra'
	DB = PG::Connection.new(dbconfig)
	
	def qry(sql, params=[])
	  @res = DB.exec_params('SELECT js FROM ' + sql, params)
	end
	
	after do
	  content_type 'application/json'
	  body @res[0]['js']
	end
	
	get '/people' do
	  qry('get_people()')
	end
	
	get %r{/people/([0-9]+)} do |id|
	  qry('get_person($1)', [id])
	end
	
	put %r{/people/([0-9]+)} do |id|
	  qry('update_password($1, $2)', [id, params[:password]])
	end
	
	get '/people/tagged' do
	  qry('people_with_tag($1)', [params[:tag]])
	end

## 或者你需要一个客户端库：

	require 'pg'
	require 'json'
	DB = PG::Connection.new(dbconfig)
	
	def js(func, params=[])
	  res = DB.exec_params('SELECT js FROM ' + func, params)
	  JSON.parse(res[0]['js'])
	end
	
	def people
	  js('get_people()')
	end
	
	def person(id)
	  js('get_person($1)', [id])
	end
	
	def update_password(id, newpass)
	  js('update_password($1, $2)', [id, newpass])
	end
	
	def people_tagged(tag)
	  js('people_with_tag($1)', [tag])
	end

### 就到这里！

无论是 REST API 还是客户端库，你所需要做的就是传递参数给数据库函数，返回 JSON。

我并不打算说服所有人都这么做。但是我只希望它能对你有用处，或者至少听起来有趣。












