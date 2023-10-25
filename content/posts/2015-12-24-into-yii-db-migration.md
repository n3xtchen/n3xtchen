---
categories:
- PHP
date: "2015-12-24T00:00:00Z"
description: ""
tags:
- yii
title: '探索 Yii2: 数据库迁移（Database Migration）'
---

## 前提

1. **php** >= 5.4
2. **Yii** >= 2.0.6: 这个版本才开始支持数据库模式生成器（Schema Builder）

## 简单的入门

### 先看命令说明

	$ ./yii help migrate
	。。。废话在此处省略。。。
	The migration history is stored in a database table named
	as [[migrationTable]]. The table will be automatically created the first time
	this command is executed, if it does not exist. You may also manually
	create it as follows:	
	
	# 我的翻译：迁移历史将被存储到数据库表 migration 中；如果他不存在这个表，触发迁移命令的时候就会被创建。你也许要手动创建他，语句如下
	
	CREATE TABLE migration (
	    version varchar(180) PRIMARY KEY,
	    apply_time integer
	)
	
	Below are some common usages of this command:
	
	# creates a new migration named 'create_user_table'
	# 我的翻译：生成迁移文件
	yii migrate/create create_user_table
	
	# applies ALL new migrations
	# 我的翻译：执行数据库迁移
	yii migrate
	
	# reverts the last applied migration
	# 我的翻译：回滚数据库迁移
	yii migrate/down
	
	
	SUB-COMMANDS
	
	- migrate/down          Downgrades the application by reverting old migrations.		# 回滚旧版本
	- migrate/history       Displays the migration history.								# 显示迁移历史
	- migrate/mark          Modifies the migration history to the specified version.	# 强制指定历史到特定的版本，只会修改 migrate 表中纪录
	- migrate/new           Displays the un-applied new migrations.						# 查看可更新的迁移
	- migrate/redo          Redoes the last few migrations.								# 重新最近一次的迁移
	- migrate/to            Upgrades or downgrades till the specified version.			# 更新／回滚到指定版本
	- migrate/up (default)  Upgrades the application by applying new migrations.		# 默认是执行迁移
	
	To see the detailed information about individual sub-commands, enter:
	
	  yii help <sub-command>

### 创建迁移（Migration）

运行下面的命令：

	$ ./yii migrate/create <name>

`<name>` 指定了迁移的简要描述，必须传入。例如，在本次迁移，你要建立名为 `posts` 的迁移，使用一下命令：

	$ ./yii migrate/create create_posts_table
	
> 由于参数 `name` 将用来作为迁移生成的类名，因此他只能包含字母，数字以及下划线。

上述的命令将会在项目根目录下 *migrations* 目录中生成一个 **PHP** 类文件.

	$ cat migrateions/m151229_025650_create_posts_table
	<?php

	use yii\db\Migration;
	
	class m151229_025650_create_posts_table extends Migration
	{
	    public function up()
	    {
	
	    }
	
	    public function down()
	    {
	        echo "m151229_025650_create_posts_table cannot be reverted.\n";
	
	        return false;
	    }
	
	    /*
	    // Use safeUp/safeDown to run migration code within a transaction
	    public function safeUp()
	    {
	    }
	
	    public function safeDown()
	    {
	    }
	    */
	}

每一次数据库迁移都会被定义成 **PHP** 类（继承 `yii\db\migration`）。这个迁移类名将会自动生成为如下格式：

	m<YYYMMDD_HHMMSS: 执行命令的系统时间>_<Name: 命令行传入>

在迁移类中，你需要编写 `up()` 方法来告诉 `yii` 如何操作数据库。你可能还需要编写 `down()` 方法来回滚由 `up()` 带来的变动。下面演示如何使用 `yii` 来创建一张 `news` 表：

	<?php
	
	use yii\db\Schema;
	use yii\db\Migration;
	
	class m150101_185401_create_news_table extends Migration
	{
	    public function up()
	    {
	        $this->createTable('news', [
	            'id' => Schema::TYPE_PK,
	            'title' => Schema::TYPE_STRING . ' NOT NULL',
	            'content' => Schema::TYPE_TEXT,
	        ]);
	    }
	
	    public function down()
	    {
	        $this->dropTable('news');
	    }
	}

> 注意：不是所有的迁移都需要回滚。比如，如果 `up()` 操作是删除表的一行，你可能就不能通过 `down()` 来回滚这一条数据。有时，你只是太懒而不愿意实现 `down()` 方法，因为回滚也不是很普遍。这种情况，你应该在 `down()` 方法中返回 `false` 值来指明此处不可回滚。

不应该使用数据库原生字段类型，而是使用 `yii` 提供的数据库抽象字段类型，这样就能让你的数据迁移便携独立于特定的数据库。在 `yii\db\Schema` 中定义了一系列常量来存放所支持的数据库抽象字段类型。这些常量的命名格式为 `TYPE_<Name>`。例如，`TYPE_PK` 代表自增主键类型；`TYPE_STRING` 代表字符型。当执行一次数据迁移时，数据库抽象类型将会被转换成相关数据库原生类型。以 **MYSQL** 为例，`TYPE_PK` 会转化成 `int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY`，而 `TYPE_STRING` 会变成 `varchar(255)`。

你还可以使用抽象类型追加额外的约束（constraints）。在上面例子中，`NOT NULL` 追加到 `SCHEMA::TYPE_STRING` 的后面来指明这个字段不可为空。

> 注意：数据库抽象类型和原生类型的映射都被指定在 `QueryBuilder` 类中的 `$typeMap` 属性中。

从 2.0.6 开始，你可以使用新引入的模式（Schema）生成器，它提供更多方便的方法定义表结构。因此，上述的迁移可以改成如下：

	<?php
	
	use yii\db\Migration;
	
	class m150101_185401_create_news_table extends Migration
	{
	    public function up()
	    {
	        $this->createTable('news', [
	            'id' => $this->primaryKey(),
	            'title' => $this->string()->notNull(),
	            'content' => $this->text(),
	        ]);
	    }
	
	    public function down()
	    {
	        $this->dropTable('news');
	    }
	}

所有可用定义字段类型的方法可以在 `yii\db\SchemaBuilderTrait` 的 API 文档中查找。

### 生成迁移脚本

从 2.0.7 版本开始，命令行模式下支持一种便利的方法来创建迁移脚本。

如果迁移名称指定成一种特殊的形式，如 `create_xxx` 或者 `drop_xxx`（不仅仅限于这两种），迁移类文件将自动生成一些额外的代码。

#### 创建表

	$ yii migrate/create create_post
	
生成

	class m150811_220037_create_post extends Migration
	{
	    public function up()
	    {
	        $this->createTable('post', [
	            'id' => $this->primaryKey()
	        ]);
	    }
	
	    public function down()
	    {
	        $this->dropTable('post');
	    }
	}

你可以通过 `--fields` 参数来创建相应的字段。

	$ yii migrate/create create_post --fields=title:string,body:text
	
生成

	class m150811_220037_create_post extends Migration
	{
	    public function up()
	    {
	        $this->createTable('post', [
	            'id' => $this->primaryKey(),
	            'title' => $this->string(),
	            'body' => $this->text()
	        ]);
	    }
	
	    public function down()
	    {
	        $this->dropTable('post');
	    }
	}

还可以指定更多字段定义

	$ yii migrate/create create_post --fields=title:string(12):notNull:unique,body:text
	
生成

	class m150811_220037_create_post extends Migration
	{
	    public function up()
	    {
	        $this->createTable('post', [
	            'id' => $this->primaryKey(),
	            'title' => $this->string(12)->notNull()->unique(),
	            'body' => $this->text()
	        ]);
	    }
	
	    public function down()
	    {
	        $this->dropTable('post');
	    }
	}

> 注意：主键会自动添加，默认的主键名称是 `id`；如果你想要使用其他名称，你可以通过 `--fields=name:primaryKey` 明确指定它。

#### 删除表

	$ yii migrate/create drop_post --fields=title:string(12):notNull:unique,body:text

生成

	class m150811_220037_drop_post extends Migration
	{
	    public function up()
	    {
	        $this->dropTable('post');
	    }
	
	    public function down()
	    {
	        $this->createTable('post', [
	            'id' => $this->primaryKey(),
	            'title' => $this->string(12)->notNull()->unique(),
	            'body' => $this->text()
	        ]);
	    }
	}

#### 添加字段

如果迁移名称是 `add_xxx_to_yyy` 的形式，生成文件则会包含 `addColumn` 和 `dropColumn` 语句。

为了添加字段：

	$ yii migrate/create add_position_to_post --fields=position:integer
	
生成

	class m150811_220037_add_position_to_post extends Migration
	{
	    public function up()
	    {
	        $this->addColumn('post', 'position', $this->integer());
	    }
	
	    public function down()
	    {
	        $this->dropColumn('post', 'position');
	    }
	}
 
#### 删除字段

如果迁移名称是 `drop_xxx_to_yyy` 的形式，生成文件也会包含 `addColumn` 和 `dropColumn` 语句。

	$ yii migrate/create drop_position_from_post --fields=position:integer
	
生成

	class m150811_220037_drop_position_from_post extends Migration
	{
	    public function up()
	    {
	        $this->dropColumn('post', 'position');
	    }
	
	    public function down()
	    {
	        $this->addColumn('post', 'position', $this->integer());
	    }
	}

#### 生成交叉表

如果迁移名称是 `create_junction_xxx_and_yyy` 的形式，生成文件也会包含创建交叉表的语句。

	$ yii create/migration create_junction_post_and_tag
	
生成

	class m150811_220037_create_junction_post_and_tag extends Migration
	{
	    public function up()
	    {
	        $this->createTable('post_tag', [
	            'post_id' => $this->integer(),
	            'tag_id' => $this->integer(),
	            'PRIMARY KEY(post_id, tag_id)'
	        ]);
	
	        $this->createIndex('idx-post_tag-post_id', 'post_tag', 'post_id');
	        $this->createIndex('idx-post_tag-tag_id', 'post_tag', 'tag_id');
	
	        $this->addForeignKey('fk-post_tag-post_id', 'post_tag', 'post_id', 'post', 'id', 'CASCADE');
	        $this->addForeignKey('fk-post_tag-tag_id', 'post_tag', 'tag_id', 'tag', 'id', 'CASCADE');
	    }
	
	    public function down()
	    {
	        $this->dropTable('post_tag');
	    }
	}

### 事务性（Transational）迁移

在进行复杂的数据库迁移的同时，必须保证每一次迁移整体成功或者失败，这对保持数据库的完整性和一致性是至关重要的。为了达到这个效果，我建议你把每次迁移执行的数据库操作放到事务中。

最简单实现事务性迁移的方法就是把迁移脚本放到 `safeUp()` 和 `safeDown()` 方法中。它们和 `up()` 和 `down()` 的不同在于它们明确指定事务性操作。导致的结果是，只要在方法内的任何一个操作失败，所有在这之前的操作都会自动回滚。

在接下来的例子中，包括建表和插入操作：

	<?php
	
	use yii\db\Migration;
	
	class m150101_185401_create_news_table extends Migration
	{
	    public function safeUp()
	    {
	        $this->createTable('news', [
	            'id' => $this->primaryKey(),
	            'title' => $this->string()->notNull(),
	            'content' => $this->text(),
	        ]);
	
	        $this->insert('news', [
	            'title' => 'test 1',
	            'content' => 'content 1',
	        ]);
	    }
	
	    public function safeDown()
	    {
	        $this->delete('news', ['id' => 1]);
	        $this->dropTable('news');
	    }
	}
	
需要的注意的是，当你在 `safeUp()` 中进行多个数据库操作，那你就应该在 `safeDown` 中进行逆向操作。在上述操作中，我门在 `safeUp()` 中先建表然后插入数据；而在 `safeDown()` 中就应该先删除数据，然后删除表。

> **注意**: 不是所有的数据库都支持事务，并且有一些数据库操作不能放在事务中。具体例子请参见 [implicit commit ](http://dev.mysql.com/doc/refman/5.7/en/implicit-commit.html)。如果在这个情况下，你应该在 `up()` 和 `down()` 中实现。

### 数据库访问方法

迁移基类 `yii\db\Migration` 提供了一系列方法来访问和操纵数据库。你可能发现这些方法的命名非常类似 **Dao** 方法（由 `yii\db\Command` 提供）。例如， `yii\db\Migration::createTable()` 方法允许你创建一个新表，就像 `yii\db\Command::createTable()` 一样。

使用由 `yii\db\Migration` 提供方法的好处就是你不需要明确实例化 `yii\db\Command` 类，以及执行每一个方法都会自动显示有用的信息，来告诉你完成哪些数据库操作和花了多长时间。

下面是所有的数据库方法方法：

* `execute()`： 执行语句
* `insert()`：插入一行
* `batchInsert()`：批量插入
* `update()`：更新
* `delete()`：删除
* `createTable()`：创建表
* `renameTable()`：重命名表
* `dropTable()`：删除表
* `truncateTable()`：清空表中的数据
* `addColumn()`：添加字段
* `renameColumn()`：重命名字段
* `dropColumn()`：删除字段
* `alterColumn()`：变更字段
* `addPrimarykey()`：添加主键
* `dropPrimarykey()`：删除主键
* `addForeignKey()`：添加外键
* `dropForeignKey()`：删除外键
* `createIndex()`：创建索引
* `dropIndex()`：删除索引

> 信息：`yii\db\Migration` 不提供数据库查询方法，是因为你一般不需要关心从数据库中获取数据的多余信息。它也因为你可以使用强大的 **Query Builder** 来构建和运行复杂的查询。


> 注意：当你在迁移中操作数据时，你可能会发现使用 **Active Record** 类会很有用，因为逻辑中一些已经在其中实现了。无论如何都要记住，和迁移类中的代码（他天生需要被永久固化）相比，应用的逻辑需要被变更。基于这种原因，迁移代码应该和其它应用逻辑保持独立，比如 **Active Record** 类。

### 执行迁移

你可以使用下述命令来执行所有可用的迁移

	$ yii migrate
	
这个命令会显示所有还未执行的迁移。如果你确认你想要执行，他将会按它们的时间戳顺序执行每一个新类中的 `up()` 和 `safeUp()` 方法。如果其中任何一个迁移失败了，命令将直接退出，不在执行后续的迁移。

为了识别已经成功执行的迁移，每进行一次成功的迁移，命令都会像数据库中 `migration` 表中插入一条数据来保存更新的状态。它将帮助迁移工具识别已执行和未执行的迁移。

> 信息：这个迁移工具会自动在指定的数据库中创建 `migration` 表。默认，所使用的数据库会使用配置表（配置的默认路径：*config/db.php*）中已定义好的 **DB** 组件。
 
 如果你想一次性进行多个迁移，那你可以指定迁移个数。例如，你想要执行接下来的三个迁移：

	$ yii migrate 3
	
你还可以通过使用 `migrate/to` 命令更新到指定的迁移版本

	$ yii migrate/to 150101_185401 # 使用时间
	$ yii migrate/to "2015-01-01 18:54:01" # 使用时间字符串
	$ yii migrate/to m150101_185401_create_news_table # 使用名称 
	$ yii migrate/to 1392853618 # 使用时间戳
	
在这个版本之前的迁移，都会被执行。在这个版本之后的迁移，都会被回滚。

### 迁移版本回滚

回滚一个或多个历史已执行的迁移版本，你可以使用如下命令：

	$ yii migrate/down     # 回滚到最近的一次版本
	$ yii migrate/down 3   # 回滚最近三次的版本	
> 注意：不是所有的迁移都可以回滚。如果尝试回滚不可回滚的迁移，将会导致一个错误，然后终止后续的所有回滚。

### 重复（Redo）迁移

重复迁移意味着上一次回滚的版本会再次被执行：

	$ yii migrate/redo        # 重复上一个撤销迁移的版本
	$ yii migrate/redo 3      # 重复上三个撤销迁移的版本
	
> 注意：如果迁移不可回滚，你将无法重复它。

### 迁移版本历史

为了显示迁移类执行与否，你可以使用如下命令：

	$ yii migrate/history     # 显示最近十个被执行的迁移
	$ yii migrate/history 5   # 显示最近五个被执行的迁移
	$ yii migrate/history all # 显示所有被执行的迁移	$ yii migrate/new         # 显示头十个新迁移
	$ yii migrate/new 5       # 显示头五个新迁移
	$ yii migrate/new all     # 显示头五个新迁移

### 修改迁移历史

与实际执行和回滚迁移历史不同，有时你只想简单把你的数据库版本标记到指定版本。当你手动变更数据库到指定状态的时候，你不想为了哪些变更重新执行迁移时，你就可以使用这个命令：

	$ yii migrate/mark 150101_185401                      # 使用时间
	$ yii migrate/mark "2015-01-01 18:54:01"              # 使用时间串
	$ yii migrate/mark m150101_185401_create_news_table   # 使用迁移类名
	$ yii migrate/mark 1392853618                         # 使用时间戳
	
这个命令将修改 `migration` 这张表，修改到指定迁移版本。这个操作不会进行实质性的执行或者回滚操作。

### 定制迁移

有以下几种方式定制迁移命令：

#### 使用命令行参数

可以通过命令行参数来对迁移进行定制化：

* `interactive`: 布尔型（默认是 `true`），指定是否进入交互模式。如果是 `true`，用户将会实时输出执行特定的迁移动作。如果你想要他在后台执行，那就要把它设置成 `false`。
* `migrationPath`：字符型（默认是 `@app/migration`），指定迁移脚本的存储路径。这个可以是目录路径或者路径别名。注意，必须保证目录存在，否则命令将会报错。
* `migrationTable`：字符型（默认是 `migration`），指定存储迁移历史信息的数据库表名。如果不存在，这个表将会自动被创建。你也可以手动创建它（表结构：`version varchar(255) primary key, apply_time integer`）。
* `db`：字符型（默认是 `db`），指定数据库应用组件的 ID。它表示数据库将被这个命令迁移。
* `templateFile`：字符型（默认是 `@yii/views/migration.php`），指定模版文件（它将帮助用户生成迁移脚本骨架）的路径。这个可以是目录路径或者路径别名。这个模版文件是一个 **PHP** 脚本，这个文件预定义了一个 `$className` 变量用来替换生成后的迁移类的类名。
* `generatorTemplateFiles`：数组型（默认是：
	
		[
		  'create_table'    => '@yii/views/createTableMigration.php',
		  'drop_table'      => '@yii/views/dropTableMigration.php',
		  'add_column'      => '@yii/views/addColumnMigration.php',
		  'drop_column'     => '@yii/views/dropColumnMigration.php',
		  'create_junction' => '@yii/views/createJunctionMigration.php'
		]
		
	），指定用于生成迁移代码的模版文件。具体看 [生成迁移](http://www.yiiframework.com/doc-2.0/guide-db-migrations.html#generating-migrations)。
	
* `fields`：用于定义创建迁移类中的字段定义数组。默认是 `[]`。每个字段定义的格式是 `COLUMN_NAME:COLUMN_TYPE:COLUMN_DECORATOR`。例如，`--fields=name:string(12):notNull` 生成一个长度为 12 的不为空的字段。

下面的例子展示了使用这些参数的方法。

例如，如果我门想要迁移个 `forum` 模块，迁移文件在这个模块所在目录的 `migrations` 目录，我们可以使用如下命令：

	# migrate the migrations in a forum module non-interactively
	$ yii migrate --migrationPath=@app/modules/forum/migrations --interactive=0
	
### 配置全局命令

与其每次执行迁移命令的时候都要重复配置参数，你可以一次配置供后续使用：

	return [
	    'controllerMap' => [
	        'migrate' => [
	            'class' => 'yii\console\controllers\MigrateController',
	            'migrationTable' => 'backend_migration',
	        ],
	    ],
	];
	
使用上述配置，每一次你执行迁移命令，`backend_migration` 表将用于记录迁移纪录。你不需要在每次执行迁移都要指定这个参数了。

### 多数据库迁移策略

默认，数据迁移都只会在一个数据库（默认是 `db` 组件指定的数据库）中执行。如果你想它们应用在不同数据库中，你可以指定 `db` 命令参数：

	$ yii migrate --db=db2

上述命令你可以把迁移应用到 `db2` 数据库中。

有时你想要把其中一些迁移应用在一个数据中，而其他的在另一个数据库中。为了达到这个目标，当你实现迁移类是，你应该明确指定 DB 组件 ID：

	<?php
	
	use yii\db\Migration;
	
	class m150101_185401_create_news_table extends Migration
	{
	    public function init()
	    {
	        $this->db = 'db2';
	        parent::init();
	    }
	}

上述迁移将应用 `db2` 表中，即使你通过命令行参数指定成其他数据库。注意，迁移历史仍然记录在有命令行参数指定的数据库中。

如果你有多个使用同一个数据的迁移，建议你创建一个迁移基类（如上述的 `init()` 代码）。每一个迁移类都拓展这个基类。

> 提示：除了设置 `db` 属性之外，你还可以在你的迁移类中创建新的数据库连接。你可以使用 `DAO 方法` 来操作不同的数据库。

迁移多个数据的另外一个策略就是为不同数据库迁移放在不同的路径中。然后你可以分别来执行迁移：

	$ yii migrate --migrationPath=@app/migrations/db1 --db=db1
	$ yii migrate --migrationPath=@app/migrations/db2 --db=db2
	...

第一个命令执行 `db1` 数据库的迁移，第二个是 `db2`，一次类推。

> 译自 http://www.yiiframework.com/doc-2.0/guide-db-migrations.html