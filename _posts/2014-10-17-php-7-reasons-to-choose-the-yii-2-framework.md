---
layout: post
title: "PHP - 选择 Yii2 框架的7大原因"
description: ""
category: PHP
tags: [php, yii]
---
{% include JB/setup %}

> 译自 [http://www.sitepoint.com/7-reasons-choose-yii-2-framework/](http://www.sitepoint.com/7-reasons-choose-yii-2-framework/)

在过去的一年中， SitePoint 发布了一篇介绍[最流行的 PHP 框架](http://www.sitepoint.com/best-php-frameworks-2014/)的文章。在当时，Yii 的最新稳定版本是 1.1.14。现在 Yii 2.0 已经分布，所以你可以开始在产品中使用它。

在 RC 版的时候，我们已经在谈论它了。现在正式发布了，我们觉得应该重新和大家谈谈选择 Yii2 的一些原因了。

## 1. 易于安装

对于 Web 开发者来说，时间就是金钱，没人愿意把宝贵的时间浪费在繁琐的安装和配置上。

Yii2 使用 [Composer](http://getcomposer.org/) 来安装。如果你想要详细的安装教程，Sitepoint 提供了一个很棒的[文章](http://www.sitepoint.com/expect-yii-2-0/)。如果你的开发模式是前后端分离的，我倾向使用基本的应用模版（Basic）。同时，我建议使用一个模块（Module）作为我们的后端部分。（Yii 模块（Module）就像一个微应用进驻在你的主应用中一样。）

## 2. 利用最主流的技术

Yii 是一个纯面向对象（OOP） 框架，很好地利用了 PHP 的一些最新特性，包括后期静态绑定（late static binding）， SPL类和接口（SPL classes and interfaces）以及匿名函数（anonymous functions）。

所有的类（Class）都被命名空间（namespace）化了，让你充分利用兼容 PSR-4 的自动载入（Autoloader）方式。这意味着很容易就能引用 Yii 的 HTML Helper：

	use yii\helpers\Html;
	
Yii 也允许你定义别名来简化你的命名空间（namespae）。上述例子中，`use` 语句从 `/vendor/yiisoft/yii2/helpers` 载入一个类定义。这个别名定义在 BaseYii 类的第 79 行：

	public static $aliases = ['@yii' => __DIR__];
	
框架本身是使用 Composer 安装的，就像扩展一样。发布扩展的方式同样很简单；你只需简单地编写自己 `composer.josn` ，代码上传到 Github 上，登记到 Packist 包列表中（供大家下载使用）。

## 3. 高可扩展性

Yii 就像一件非常合身的西装，但是裁缝也容易根据你的特殊需求进行订制。实际上，框架的每一个组件都是可扩展的。一个简单的例子，你想要为你的视图（View）添加唯一标识 ID。（这时，你可能很疑惑这么做的用意，请参见 [Css-Trick](http://css-tricks.com/id-your-body-for-greater-css-control-and-specificity/)）

首先，我在我的 `app\componts` 目录中中创建一个名为 `View.php` 文件，把下面的代码：

	namespace app\components;
	 
	class View extends yii\web\View {
	 
	    public $bodyId;
	 
	    /* Yii allows you to add magic getter methods by prefacing method names with "get" */
	 
	    public function getBodyIdAttribute() {
	        return ($this->bodyId != '') ? 'id="' . $this->bodyId . '"' : '';
	    }
	 
	}
	
然后，在你的主布局（Layout，`app\views\layouts\main.php`）文件中，添加下面语句到你的 `Body` 标签中：

	<body <?=$this->BodyIdAttribute?>>
	
最后，我将把下面嫁到我的主配置文件中，让 Yii 可以识别它，并将它替换默认的 `View` 。

	return [
	    // ...
	    'components' => [
	        // ...
	        'view' => [
	            'class' => 'app\components\View'
	        ]   
	    ]
	];

## 4. 鼓励测试

Yii 与 Codeception 紧密整合在一块。Codeception 是一个非常棒的 PHP 测试框架，它简化了创建单元测试（Unit Test），功能测试（Functional Test）和验收测试（Acceptance Test）的过程。因此你将为你所有的应用编写自动化测试脚本，对吧？

Codeception 扩展简化了配置，只需简单地编辑 `/tests/_config.php` 文件就可以了；例如：

	return [
	    'components' => [
	        'mail' => [
	            'useFileTransport' => true,
	        ],
	        'urlManager' => [
	            'showScriptName' => true,
	        ],
	        'db' => [
	                'dsn' => 'mysql:host=localhost;dbname=mysqldb_test',
	        ],
	    ],
	];

使用上述配置，将会导致如下结果：

1. 在功能测试（Functional Test）和验收测试（Acceptance Test）的过程中，任何要发送的邮件都不会被发送，将写到文件中代替。
2. 你在测试中的 URL 展示格式将会是 `index.php/controller/action`，而不是 `/controller/action`。
3. 你将在你的测试数据库中测试，而不是你的生产环境的数据库中。

一个特殊的模块（Module）都共同存于 Yii 框架和 Codeception 中。它给 `TestGuy` 类增加了一些方法，帮助你在功能测试（Functional Test）中操纵 Active Record (Yii 的 ORM)。举个例子，如果你想要查看你的注册表单是否成功创建个叫做 “testuser” 的用户，你可以这么做：

	$I->amOnPage('register');
	$I->fillField('username', 'testuser');
	$I->fillField('password', 'qwerty');
	$I->click('Register');
	$I->seeRecord('app\models\User', array('name' => 'testuser'));

## 5. 简化安全方案

安全性对于任何 Web 应用，都是很关键的部分；幸运的是， Yii 本身就包含一些很棒的特征来帮你排忧解难。

Yii 携带一个安全应用组件，它包含一些方法来协助你创建一个更安全的应用。下面列举了一些创建有用的方法：

* `generatePasswordHash`：从一个密码和一个随机盐（Salt）中生成一个安全哈希值。这个方法将为你生成一个随机盐（Salt），然后使用 PHP 的 `crypt` 函数来为提供的字符创建一个哈希值。
* `validatePassword`：这个是 `generatePasswordHash` 的伴侣函数，它允许你检查用户提供的密码匹配你的存储的哈希值。
* `generateRandomKey`：允许你创建任何长度的随机字符。

Yii 会自动验证来不安全的 HTTP 请求方法（PUT，POST 和 DELETE）CSRF 令牌的有效性；当你使用 `ActiveForm::begin()` 方法来创建你的表单标签时，它将生成和输出一个令牌。这个特征你可以通过编辑你的主配置文件来禁用它：

	return [
	    'components' => [
	        'request' => [
	            'enableCsrfValidation' => false,
	        ]
	];

为了防止被跨境攻击（XSS），Yii 提供了另一个辅助类 `HtmlPurifier`。这个类有一个静态方法 `process`，它使用与它同名的[流行 PHP 的过滤库](http://htmlpurifier.org)来过滤你的输出。

Yii 也包含开箱即用的用户认证和认证类。认证（Authorization）分两种：访问控制过滤器（ACF，Access Control Filter）和基于角色的访问控制器（RBAC，Role-Based Access Control）。

访问控制过滤器（ACF）是两个中最简单的，通过在你控制器（Controller）中添加下述方法来实现：

	use yii\filters\AccessControl;
	 
	class DefaultController extends Controller {
	    // ...
	    public function behaviors() {
	        return [
	            // ...
	            'class' => AccessControl::className(),
	            'only' => ['create', 'login', 'view'],
	                'rules' => [
	                [
	                    'allow' => true,
	                    'actions' => ['login', 'view'],
	                    'roles' => ['?']
	                ],
	                [
	                    'allow' => true,
	                    'actions' => ['create'],
	                    'roles' => ['@']
	                ]
	            ]
	        ];
	    }
	    // ...
	}
	
上述的代码告诉 `Defaultcontroller` 允许访客用户访问 `login` 和 `view` 动作（action），但是不允许访问 `create` 动作（action）。（`?` 是匿名用户的别名，`@` 代表认证的用户）。

RBAC 是一种控制不同类型用户执行特定动作的强大方法。它需要为你的用户创建角色，为你的应用定义权限，并且为相应的角色开通相应的权限。如果你想要开通 `Moderator`（评分者）角色的话，你可以使用这个方法，并为所有用户分配这个角色来投票这个博客（作者对自己的文章非常有自信，^_^）。

你也可以使用 RBAC 来定义角色，允许用户在特定的条件分配特定的权限。举个例子，你应该创建一个规则允许所有用户编辑他们自己的文章，但不能编辑别人创建的文章。

## 6. 缩短开发时间

大部分项目都包含大量的重复任务（没人想要在那上面浪费时间）。Yii 赋予了我们一些工具来协助我们花费更少的时间在这些工作上，而是花更多时间在定制你的应用来满足客户的需求。

`Gii` 就这些最强大工具中的一种。`Gii` 是一个基于 Web 的脚手架工具，它允许你快速的创建代码模版：

* 模型（Models）
* 控制器（Controllers）
* 表单（Forms）
* 模块（Modules）
* 扩展（Extensions）
* CRUD 控制器（Controller）动作（action）和视图（views）

`Gii` 是高度可定制化的。你可以将它设定在特定的环境（一般在开发环境中被启用），只需要像下面代码那样简单的编辑就可以了：

	if (YII_ENV_DEV) {
	    // ...
	    $config['modules']['gii'] = [
	        'class' => 'yii\gii\Module',
	        'allowedIPs' => ['127.0.0.1', '::1']
	    ]
	}
	
它确保了 `Gii` 只在 Yii 环境设置成开发环境时才被载入，并且也只有在本地环境才能被访问。

现在让我们看看模型（Model）生成器：

![image](http://dab1nmslvvntp.cloudfront.net/wp-content/uploads/2014/10/1413153698gii-model-generator.jpg)

它的表名使用响应式点击挂件来尝试猜测你的模型（model）相关联的表（指数据库中的表），所有的字段都会以弹出提示的方式来指导你如何填写。你可以在要求 `Gii` 生成代码之前预览生成的代码，所有的代码模版都是完全可定制的。

也有一些命令行工具用来创建代码模版来协助数据库迁移，信息翻译（l18N）和创建用户自动化测试的数据库基境（Fixtures）。举个例子，你可以使用下面的命令来创建一个心的数据库迁移文件：

	yii migrate/create create_user_table
	
它将会在 `{appdir}/migrations` 创建一个新的迁移模版：

	<?php
 
    use yii\db\Schema;
 
    class m140924_153425_create_user_table extends \yii\db\Migration
    {
        public function up()
        {
 
        }
 
        public function down()
        {
            echo "m140924_153425_create_user_table cannot be reverted.\n";
 
            return false;
        }
	}
	
因此，我们可以为这个表添加一些字段；我只需要在 `up` 方法中添加代码：

	public function up()
	{
	    $this->createTable('user', [
	        'id' => Schema::TYPE_PK,
	        'username' => Schema::TYPE_STRING . ' NOT NULL',
	        'password_hash' => Schema:: TYPE_STRING . ' NOT NULL'
	    ], null);
	}
	
然后我们需要确保我们正常迁移是可逆的，我们可以编辑 `down` 方法：

	public function down()
	{
	    $this->dropTable('user');
	}
	
你只需要执行一下简单的命令就可以创建这个表了：

	./yii migrate
	
以及删除这个表：

	./yii migrate/down
	
## 7. 简单的调整就可以达到很好的性能

每一个人都知道缓慢的网页导致不良的用户体验，因此 Yii 提供了一些工具来帮助你的应用获得更高的性能。

所有的 Yii 的缓存组件都继承 `yii/caching/Cache` 类，允许选择不同的缓存系统，并且使用通用接口（API）来调用。你可以同时定义多个缓存组件。Yii 现在支持数据库和文件缓存，同样也支持 APC，Memcache，Redis，WinCache，XCache 和 Zend Data Cache。

默认情况下，如果你使用 Active Record，然后 Yii 会执行额外的查询来确定所生成模型（Model）对应的表结构。你可以通过配置主配置文件来设置应用缓存这些表结构：

	return [
	    // ...
	    'components' => [
	        // ...
	        'db' => [
	            // ...
	            'enableSchemaCache' => true,
	            'schemaCacheDuration' => 3600,
	            'schemaCache' => 'cache',
	        ],
	        'cache' => [
	            'class' => 'yii\caching\FileCache',
	        ],
	    ],
	];

最后，Yii 提供命令行工具来压缩前端资源（assets），只须简单运行下面命令来生成配置模版：

	./yii asset/template config.php
	
然后编辑配置来指定你想要使用的压缩工具（例如，Closure 编译器，Yui 压缩器或者 UglifyJS）。产生的配置模版就想下面那样：

	<?php
	    return [
	        'jsCompressor' => 'java -jar compiler.jar --js {from} --js_output_file {to}',
	        'cssCompressor' => 'java -jar yuicompressor.jar --type css {from} -o {to}',
	        'bundles' => [
	            // 'yii\web\YiiAsset',
	            // 'yii\web\JqueryAsset',
	        ],
	        'targets' => [
	            'app\config\AllAsset' => [
	                'basePath' => 'path/to/web',
	                'baseUrl' => '',
	                'js' => 'js/all-{hash}.js',
	                'css' => 'css/all-{hash}.css',
	            ],
	        ],
	        'assetManager' => [
	            'basePath' => __DIR__,
	            'baseUrl' => '',
	        ],
	    ]; 
	   
然后运行命令来进行压缩任务：

	./yii asset config.php /app/assets_compressed.php
	
最后，编辑的你 Web 应用配置文件使用压缩后的资产（assets）。
	
	'components' => [
	    // ...
	    'assetManager' => [
	        'bundles' => require '/app/assets_compressed.php'
	    ]
	]
	
> 注：这个步骤你需要手动安装外部的工具。

## 结语

和其他优秀的框架一样，Yii 帮助你快快速构建现代的 Web 应用，并确保优秀的性能。它通过提供一系列为你减负的工具促使你创建安全可测试的站点。你可以很容易使用它提供的所有特性，也可以修改它们来满足你的需求。我真心推荐在你的戏一个 web 项目中使用它。

你尝试过 Yii 2 了吗？那请让我们知道！
