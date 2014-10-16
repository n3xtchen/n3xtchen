---
layout: post
title: "Ruby - 通过 Rail 来学习 SQL"
description: ""
category: ruby
tags: [ruby, rail, sql]
---
{% include JB/setup %}

> 译自 [http://www.sitepoint.com/understanding-sql-rails/](http://www.sitepoint.com/understanding-sql-rails/?utm_medium=email&utm_campaign=SitePoint+Ruby+20141015&utm_content=SitePoint+Ruby+20141015+CID_dc98d89d4db41ff889d2a30db5281762&utm_source=CampaignMonitor&utm_term=Understanding%20SQL)

结构化的关系数据库现在已经无处不在了；它就是大家所说的用于 Web 前端接口的后端数据库；在无状态协议中（如 HTTP），你的数据库可以用来持久保存状态；它是机器后面的大脑。

在 MVC 模式的传统场景中，你的数据模型（Model 层）用来解决一部分问题。你从数据库获取数据的方式直接影响到整体的方案。如果你的数据关系错综复杂和冗余，它会严重影响前端代码的实现。

因此，我将在这里探讨 SQL 数据库。众所周知，Rails 提供很好的方案来解决此类问题。框架让我们更容易使用数据模型（Models）和关系（Relations）的方式来思考真实场景的问题。

数据模型中的关系（Relation）让你的模型（Model）成为真实世界的对象。更令人兴奋的是它很好地适应 OOP 面向对象的开发范型。它简化了代码库，使你的架构更加智能和敏捷。

我希望在这个文章结束的时候，你将会增加对关系数据库的了解；它将让你认识到你的后端结构存储对实际架构的重要性。

接下来，我们都想设计一个漂亮的架构，Right？那就开始吧！

## 安装

首先你需要有一台装好 `Ruby` 和 `Rails` 的 PC 机，下面是我的环境参数：

	$ ruby -v
	ruby 2.1.1p76 (2014-02-24 revision 45161) [x86_64-darwin12.0]
	$ gem -v
	2.2.2
	$ rails -v
	Rails 4.1.6
	
然后创建你的项目：

	$ rails new understanding_sql_through_rails
	
这是一个特定的例子，它实际上使一个简单的博客系统。它由 用户（Users），博客（Posts） 和 分类（Catagories） 组成。这样，我们先粗略地定义下数据结构和关系。

我们的首要目的是 MVC 框架的 Model 设计。

我们先用 `Rails` 创建需要的模型（Model）和关系（Relations）：

    $ rails g model User name:string{30}
	$ rails g model Post title:string{40} content:text{3200} user:references:index
	$ rails g model Category name:string{15}
	$ rails g migration CreateCategoriesPostsJoinTable categories:index posts:index
	
作为最佳实践，我建议为你的字段设置最大长度。在结构化的数据库中，如果你设置了合理的字段大小，计算机将更容易计算索引数据的时间。结构化数据集的最大好处就是每条数据只占用设定的空间，因此它更容易被查询。我的建议是最大程度的使用它。

现在，开始生成数据库：

	$ rake db:migrate
	
简单。`Rails` 已经帮我们把所有需要的代码都生成好了。你可以浏览下下你创建的项目目录下生成的代码。最让人兴奋的是，通过简单的命令，你就能完成你的关系数据库的配置。

为了确保你创建的模型（Model）中的关系（Relation）是正确的，你修改下你的代码文件，修改如下：

	# app/models/category.rb    这是代码路径，下面类推
	class Category < ActiveRecord::Base
		has_and_belongs_to_many :posts	    # 添加这一行
	end
	
	# app/models/post.rb
	class Post < ActiveRecord::Base
		belongs_to :user				
		has_and_belongs_to_many :categories	# 添加这一行
	end
	
	# app/models/user.rb
	class User < ActiveRecord::Base
		has_many :posts				       # 添加这一行
	end
	
通过上述，把这些数据的关系映射到 `Rails` 代码中。这个很重要，你需要记住。比如，一个用户（User）由很多帖子（Post），一个帖子（Post）属于一个用户（User）。

将下面代码追加到 db/seeds.rb 中：

	user = User.create({name: 'Joe'})
	post = Post.create({title: 'Post', content: 'Something', user_id: user.id})
	Category.create({name: 'Cat1', post_ids: [post.id]})

然后执行它：

    $ rake db:seed
	
## 关系（Relations）

在 `Rails` 中，你的整个数据都安装设置好了。现在，是时候深入探讨其中的原理。框架很好地抽象了这一层。为了更好了解它，我们需要看看它是如何被实现地：

	$ rails console
	Loading development environment (Rails 4.1.6)
	2.1.1 :001 > post = Post.first
	2.1.1 :002 >  post.categories
	2.1.1 :003 > category = Category.first
	2.1.1 :004 > category.posts
	2.1.1 :005 > user = User.first
	2.1.1 :006 > user.posts

框架可以触发多种 SQL 关系查询。正如你所见，一篇博客（Post）有并且属于多个分类（Category）；一个分类（Category）有和属于多篇博客（Post）。一个用户（User）有多篇博客（Post）。

这些关系非常直观，就像你用标准的英语描述他们一样。最激进的是你完全不需要知道底层的实现技术，只需要了解对应的问题所属域模型（Domain Model）。

在任何解决方案中，领域模型（Domain Model）由对象（Object）和关系（Relations）组成；它用来关联用户的媒介；它加速了的人机沟通，以至于你不需要关心如何解决他们的问题。

客户和个人只关心你的终端产品是否更好地服务他们。客户更乐见把一个问题对应到相关到领域。这意味着作为架构师的你能够将真实世界的问题关联到计算机语言中。

无需多说，你只需要记住模型（Model）是如何解决你的问题的？

在某种形式上，你的 SQL 数据库也是追踪数据之间关系（Relation）的一种方式。

## SQL 查询

    $ rails dbconsole

它将带你进入 SQL 的世界而不是 `Rails`。SQLite 应该是 `Rails` 默认的数据库。

如果你想要查询某一个用户（User）发布的博客（posts）：

    -- 这是 SQL 语句
	SELECT id, title FROM posts WHERE posts.user_id = 1;
	
如上展示的，当一个子对象归属一个父对象，子对象从父对象获取一个外健（Foreign Key）。

现在来点有难度的，我想要属于 Cart1 分类（Category）的博客（Post）：

    -- 这是 SQL 语句
	SELECT posts.id,
	  posts.title
	FROM categories,
	  posts,
	  categories_posts
	WHERE categories.id = categories_posts.category_id
	  AND posts.id = categories_posts.post_id
	  AND categories.name = 'Cat1';
	
我使用隐含的连接查询（Join）。在任何所给的数据表中，`id` 是主键（Primary Key）。在实际场景中，我仅使用 SQL 做简单的信息查询。如果要做的更多那意味着把业务逻辑（Business Logic）放到 SQL 中。我建议你尽可能避免这样。你的领域逻辑（Domain Logic）不应该属于 SQL 层。

在这个基础上，你应该尽可能高效利用 SQL 关系，来避免数据冗余。每次你看到你的表中存在很多重复的数据，那你就该停下来，重新思考下数据结构的设计。   

总的来说，这就是结构化的关系数据库能为你做的事情。

## 优化

你可能已经注意到我们每个 Model 创建脚本后面都有一个 `:index`。我把他们加到模型（Model）生成器中。实际上，它们是索引（Index）。在 SQL 中，当你通过关系查询数据的时候，索引（Index）将会优化你的查询。注意，每一个主键默认都是一个索引，但是外健不是。

在 dbconsole 中，查询查询创表语句（这个实际上是 Sqlite 的语法）：

	.schema

你将会看到：

	CREATE TABLE "categories" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(15), "created_at" datetime, "updated_at" datetime);
	CREATE TABLE "categories_posts" ("category_id" integer NOT NULL, "post_id" integer NOT NULL);
	CREATE TABLE "posts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(40), "content" text(3200), "user_id" integer, "created_at" datetime, "updated_at" datetime);
	CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
	CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(30), "created_at" datetime, "updated_at" datetime);
	CREATE INDEX "index_categories_posts_on_category_id_and_post_id" ON "categories_posts" ("category_id", "post_id");
	CREATE INDEX "index_categories_posts_on_post_id_and_category_id" ON "categories_posts" ("post_id", "category_id");
	CREATE INDEX "index_posts_on_user_id" ON "posts" ("user_id");
	CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");

因此，如果索引（Index）出现在你的领域模型（Domain Model）设计中的时候，你应该是提高性能方案方面的专家了!^_^

## 结语

这就是今天的全部内容了。我希望你能看到 SQL 的强大之处，以及如何高效地在现实场景中使用它。

Happy Hacking!
