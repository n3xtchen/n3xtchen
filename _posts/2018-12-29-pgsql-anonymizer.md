---
layout: post
title:  "PostgreSQL: 匿名化（Anonymizer）工具"
date:   2018-12-29 10:17:41 +0800
category: POSTGRESQL
---

PostgreSQL Anonymizer: 在 PostgreSQL 中隐藏或替换个人身份信息（PII）或者商业敏感信息数据。[项目地址：https://gitlab.com/daamien/postgresql_anonymizer]

我坚信匿名化的声明：**在数据库中敏感信息的存储位置和隐藏信息的规则应该直接通过数据定义语言（DLL）中直接声明**。在 GDPR（如果不知为何物，可以关掉这个页面了） 的时代，开发者应该在表定义中指定匿名化的策略，就像指定数据类型、外键和约定一样。

这个项目的原型设计展示了在 PostgreSQL 内直接实现数据隐蔽的强大能力。目前，他是基于 `COMMENT` 语法声明（可能是最无用的 PostgreSQL 语法）和一个事件触发器。在不远的将来，我希望为动态数据屏蔽引入新的语法（MS Server 已经这么做了）。

使用这个扩展屏蔽用户信息或者永久修改敏感信息。现在已经有各式各样的屏蔽技术：randomization, partial scrambling, custom rules 等等。

这里基本的例子：

想想一个 people 的表：

	=# SELECT * FROM people;
	  id  |      name      |   phone
	------+----------------+------------
	 T800 | n3xtchen | 1351111111

第一步：激活屏蔽引擎

	=# CREATE EXTENSION IF NOT EXISTS anon CASCADE;
	=# SELECT anon.mask_init();

第二步：声明屏蔽的用户

	=# CREATE ROLE skynet;
	=# COMMENT ON ROLE skynet IS 'MASKED';

第三步：声明屏蔽规则

	# COMMENT ON COLUMN people.name IS 'MASKED WITH FUNCTION anon.random_last_name()';
	# COMMENT ON COLUMN people.phone IS 'MASKED WITH FUNCTION anon.partial(phone,2,$$******$$,2)';

第四步：查询屏蔽敏感信息的用户

	# \! psql test -U skynet -c 'SELECT * FROM people;'
	 id  |   name   |   phone
	-----+----------+------------
	T800 | n3xtchen | 13******11
 
 这个项目还在开发中。如果有什么好的主意和建议，不要吝啬，通过 github 的 issue 反馈给作者。
