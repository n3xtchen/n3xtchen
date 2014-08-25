---
layout: post
title: "Javascript MVC 框架大 PK - Backbone, AngularJS 和 Ember.js"
description: ""
category: Javascript
tags: [Javascript]
---
{% include JB/setup %}

## 1. 介绍

在这篇文章中，我们将要对比当今最流行 MV* 前端框架： Backbone VS. AngularJS VS. Ember.js。选择正确的框架将对你和你的项目产生巨大的影响，无论从开发的时间，还是将来维护代码的成本来说。你可能会选择一款灵活稳定以及被人证实过的框架来搭建你的项目，但是有不想让你的选择受限制。Web 在近几年爆炸式的发展－新的技术不断地产生，以及旧的无效方法论很快地被淘汰。在这样的背景下，我们将要对这三个框架进行深度的对比。

## 2. 初始框架

这些流行的框架拥有很多的共同点：他们都是开源的，使用宽容的 MIT 开源协议，并且使用 MV* 模式创建单页应用（Single Page Web Applications）来解决问题。 他们都有视图（Views），事件（Events），数据模型（Model）以及路由（Routing）的概念。我们将要先从他们的技术背景和历史介绍开始，然后在分开对比这三个框架。

### AngularJS

AngularJS 作为商业产品的一部分，诞生于 2009 年，那时称作为 GetAngular。不久的厚厚，Misko Hevery，GetAngular 的创始人之一，利用 GetAngular 仅使用 3 周的时间重建一个 Web 应用（它原本包含了 1 万 7千行代码，花费了 6 个月的开发时间）。由于将代码量缩减到了 1000 行，这点说服了 Google 捐助这个项目，最后就成为我们如今的开源 AngularJS。AngularJS 有如下特有的独创特征：

* 双向绑定（Two-Way Data Bindings）
* 依赖注入（Dependency Injection）
* 易于测试（easy-to-test）的代码
* 使用指令（directives）拓展 HTML

### Backbone

Backbone.js 是一个轻量 MVC 框架。诞生于 2010 年，它由于作为全功能的 MVC 重框架 - ExtJS 的替代者，迅速走红。这导致很多服务应用依赖它，如 Pinterest, Flixster, AirBNB。

### Ember.js

Ember 的起源可以追溯到 2007 年。它的前身是 SproutCore MVC 框架，前期由 SproutIt 开发的，后来由 Apple 主导，在 2011 年被 Yehuda Katz（著名的 JQuery 和 Ruby On Rails 计划的核心贡献者之一） 分支出来 。Yahoo!，Groupon 和 ZenDesk 也是强有力的支持者。

## 3. 社区

社区是影响我们选择框架的最重要因素之一。一个强大的社区意味着更多的答案被解答，更多的第三方模块以及更多 YouTube 教程…… 我将这些放到一个报表中，数据时间截止到 2014 年 8 月 16 日。Angular 占据绝对的优势，成为 GitHub 最受关注的第六名，在 StackOverflow 拥有更多的问题，比 Backbone 和 Ember 加起来都要多，报表如下：

| 度量                   | AngularJS  | Backbone.js | Ember.js |
| : -------------------- |: -------- :|: --------- :|: ------ :|
| GitHub 的星级（Stars） | 27.2K      | 18.8K       | 11K      |
| 第三方模块             | 800        | 236         | 21       |
| StackOverflow 问题个数 | 49.5k      | 15.9k       | 11.2k    |
| YouTube 视频           | ~75k	      | ~16k        | ~6k      |
| GitHub 贡献者          | 928	      | 230         | 393      |
| Chrome 拓展用户        | 150k	      | 7k          | 38.3k    |

所有的这些指标，仅仅是展示每一个框架的当前状态。这些框架的发展趋势也是非常有趣。幸运的是，我们可以从 Google 趋势中得到答案。

<script type="text/javascript" src="//www.google.com/trends/embed.js?hl=en-US&q=ember.js,+angularjs,+backbone.js&cmpt=q&content=1&cid=TIMESERIES_GRAPH_0&export=5&w=700&h=330"></script>

## 4 框架大小

页面加载时间是衡量一个 Web 页面关键指标之一。用户并不总是很有耐性的 —— 因此在任何场景下，你应该让你应用载入的尽可能更快。当考虑框架在载入时间的影响时，一般有两个因素来考量：框架的尺寸以及它启动的时间。

Javascript 代码一般需要压缩，因此我们将要比较他们被压缩的最小版本。然而仅仅看这个是不够的。Backbone.js 最小只有 6.5 KB，一般需要依赖 Underscore.js(5 KB) 和 JQuery（32 KB）或者 Zepto（9.1 KB），所以你需要加入一些第三方插件，进行对比

|      框架           | 净容量      | 带上必要的依赖              |
|: -----------------  |: --------- :|: ------------------------- :|
|  AngularJS 1.2.22	  | 39.5kb	    |39.5kb                       |
|  Backbone.js 1.1.2  |	6.5kb	    |43.5kb (jQuery + Underscore) <br />20.6kb (Zepto + Underscore) |
|  Ember.js 1.6.1     |	90kb	    |136.2kb (jQuery + Handlebars)|

## 5 模版

Angular 和 Ember 都包括模版引擎。Backbone 留给使用其他模版的选择。体验不同模版引擎的最好方法就是代码样例，因此让我们分开对比。我们将展示格式化列表的例子。

### 5.1 AngularJS

AngularJS 模版引擎只是简单将表达式绑定到 HTML 上。绑定的表达式被双花括号保卫。

	{% raw  %}
	<ul>
  	  <li ng-repeat="framework in frameworks" 
      	title="{{framework.description}}">
    	{{framework.name}}
  	  </li>
	</ul>
	{% endraw %}
	
### 5.2 Backbone.js

虽然 Backbone 可以整合很多第三方模版引擎，默认的选择是 Underscore 模版。由于 Underscore 是 Backbone 的依赖包，所以你已经拥有它，你可以简单地利用它，而不需要添加另外地依赖。弱点就是，Underscore 的模版引擎非常基础，你一般需要混入一些 javascript 脚本，下面就是例子：

	<ul>
	  <% _.each(frameworks, function(framework) { %>
	    <li title="<%- framework.description %>">
	      <%- framework.name %>
	    </li>
	  <% }); %>
	</ul>

### 5.3 Ember.js

Ember 目前使用把手（Handlebars）模版引擎，它是著名的模版引擎，Mustache，的拓展。有一个新的把手变种，称作 HTMLBars，目前能很好的运行。Handlebars 不理解 DOM —— 它所做的一切只是简单的字符串变形。HTMLBars 可以理解 DOM，因此变量注入是上下文相关的。由于目前 HTMLBars 还未在生产环境应用，因此我们将使用 Handlebars 答应框架列表：

	{% raw %}
	<ul>
	  {{#each frameworks}}
	    <li {{bind-attr title=description}}>
	      {{name}}
	    </li>
	  {{/each}}
	</ul>
	{% endraw %}

## AngularJS

### 6.1 优点

Angular 已经为前端开发引入了很多独创的概念。双向数据绑定（Two-way data binding）保存很多样板代码。使用 JQuery 代码使用：

	$('#greet-form input.user-name').on('value', function() {
	    $('#greet-form div.user-name').text('Hello ' + this.val() + '!');
	});
	
多亏了 Angular 的双向数据绑定（Two-way data binding），你不再需要自己编写代码了。而是简单的声明：

	<input ng-model="user.name" type="text" />
	Hello {{user.name}}!
	
Promises（异步编程模式） 在 Angular 中扮演着重要的角色。Javascript 是一个单线程(single-thread)，事件循环（event-loop）的语言，这意味这很多操作将采用异步行为（就像网络传输）。异步 Javascript 代码由于通过嵌套回调的编码方式很容易产生意大利面条式的代码，比如臭名昭著的“死亡金字塔（Pyramid Code）“或者“回调地狱（Callback Hell）“。

                                        });
                                    });
                                });
                            });
                        });
                    });
                });
            });
        });
    }); // 这就是回调地狱

Angular 不仅拥有比其他两个框架更大的社区，更多的在线内容，而且还有 Google 作为强力的后盾。因此，核心团队不断地壮大，导致更多的革新和工具来提高开发效率： Protractor， Batarang， ngmin 和 Zone.js, 只列举了一些。另外，团队合作以设计为导向。比如，Angular 2.0 所有的设计文档都在[这里](https://drive.google.com/drive/#folders/0B7Ovm8bUYiUDR29iSkEyMk5pVUk)，每一个人都可以直接提出设计建议。

Angular 自动会把你的代码分类到不同的应用组件类型中：Controllers， Directives， Factories， Filters， Services and Views (templates)。 她们将会组织到模块中，并相互依赖。构建模块的每一个类型都扮演着不同的角色。View 做 UI，Controller 充当 UI 之后的逻辑，Services 负责与后端的交互，组合在一起就构成通用相关的功能组件，而 Directives 使得代码复用，HTML 元素，属性和行为拓展变得更简单。

自动脏代码检查（Dirty Checking）意味着你不需要通过 getter 和 setter 访问你的数据模型 —— 你可以对任意对象进行修改，Angular 将会自动检测改变和提醒所有的观察者。

> “Angular is written with testability in mind.” 

这句话出自 AngularJS 的单元测试指南，意思是编写 AngularJS 代码时，需要考虑可测试性 —— Angular 确实在构建内置服务时（例如 $http 和 $timeout）很注重概念分离，单元隔离以及提供可用性高，强大的模拟对象（Mocks）。

### 6.2 痛点

Angular 紧张由于 Directives 接口负责度，为人所诟病。转置（Transclusion），这个概念让无数开发者云里雾里，例如编译（Compile）函数，前后置链接函数（pre/post linking functions）,错综复杂的作用域类型（transclusion/isolate/child）以及其他配置设置等等。

Angular 的作用域继承使用原型继承，对于来自对象编程开发者来说，需要花时间来掌握的的新概念。难以理解的作用域继承将是导致迷惑开发者的主要元凶。

Angular 表达式（Expressions）被用于扩展 Angular 的视图层。这个表达式语言是非常强大，甚至强大过头了。它让开发者使用复杂的逻辑来实现最简单的赋值和计算。将逻辑放在模版层将导致难以测试，甚至不可测试。下面的例子就是展示如何简单的把表达式语言滥用。

	<button ng-click="(oldPassword && checkComplexity(newPassword) 
		&& oldPassword != newPassword) ? 	(changePassword(oldPassword, 
		newPassword) && (oldPassword=(newPassword=''))) : 
		(errorMessage='Please input a new password matching the following requirements: '
		 + passwordRequirements)">
	Click me</button>
	
在很多情况下，例如指令名的误拼或者调用为定义的域函数的错误只能无情地被忽视了，尤其是你把指令接口的复杂性与与继承混合的时候，查找将非常有挑战性。我曾是发现一些开发者花费大量时间从头到尾检查代码，只是为了查出一个被绑定的事件为什么在某个域中被触发，结果是因为它使用驼峰规则代替下划线分割时，拼错了属性名，这可是血的教训啊。

最后，Angular 的对象轮询机制（Digest Cycle ），收到了特殊的脏数据检查，也令开发者瞠目结舌。当运行非 Angular 上下文时，非常容易忘记带调用 $digest()。另一方面，你需要非常小心避免造成缓慢执行或者无限轮询。通常，每个页面都有很多的交互，Angular 将会变得很慢。一个好的标准就是不要在同一个页面绑定2000 个活动。

## 7 Backbone.js

### 7.1 优点

Backbone 以轻量级，快速和低内存著称。学习曲线非常平缓，需要掌握的概念也不适很多（Models/Collections，Views 和 Routes）。她拥有很棒的文档，简单的代码和重度的注释，甚至使用注释解释用法。你可以使用一个小时的事件通读代码并熟悉她。

由于她足够小和简单，因此 Backbone 很适合作为构建自己框架的底层。基于 Backbone 作为底层的框架有很多，比如 Aura，Backbone UI，Chaplin，Geppetto，Marionette，LayoutManager，Thorax，Vertebrae。而 Angular 和 Ember 则走不同的路线，编码中充分体现框架构建者的意识，这可能不适和你的项目需要或者不符合你个人风格。Angular 2.0 承诺改变这一现状，由更小独立的模块构成，因此你可以选择和组合。我们将赤目以待。

### 7.2 痛点

Backbone 不提供结构。她甚至不提供构建结构的基本工具，交给开发者决定如何构建自己的应用，存在很多空白需要填补，甚至连内存管理都需要小心的考虑。由于视图生命周期管理的缺失使得 route/state 长期占据内存，除非你小心释放无用的对象。

由于很多函数不是 Backbone 本身提供，这块就交给第三方插件来填充空白，这意味着构建应用时面临许多的选择。例如，内置的 Models 可以由 Backbone 提供；你还可以选择Document model，BackBone.NestedType，Backbone.Schema，Backbone-Nested， backbone-nestify， 这里只列举了一些。 你需要调研决定哪一个最适合你的项目，这需要花费事件 —— 而框架最主要目的之一就是节省你的事件。

Backbone 不支持双向数据绑定，意味着你需要写很多的模版在模型改变时更新视图，视图改变时改变模型。看看上面给的例子，Angular 展示了如何双向数据绑定来减少代码。

Backbone 中的视图是直接操纵 DOM 的，这样真的很难进行单元测试，更加碎片化和更难复用。

## 8. Ember.js

### 8.1 优点

Ember.js 是约定优于配置（Convention over Configuration）的拥护者。这意味着替代编写更多的模版代码，Ember 可以自动推测大部分配置，例如当决定路由资源时会自动决定路由和控制器名称。如果没有自己定义控制器的时候，Ember 会自动为你创建一个控制器。

Ember 本身包含很棒的路由和可选的数据层（称为 ember data）。不像之前两个框架，只有非常轻的数据层（Backbone 的 Collection/Model 和 Angular 的 $resource），Ember 拥有全功能的数据模块（可以和 Ruby On Rails 完美整合或者其他符合约定的 JSON 接口）。她还可以设置基境（Fixture）为开发提供测试和模拟环境。

性能是 Ember.js 设计中最重要的目标。例如 Run Loop 的概念，为了确保更新的数据只造成一次 DOM 更新，即便同一块数据被更新了几次，还有计算指标的缓存机制，以及在编译事件或者你的服务器上有预编译 HandleBars 模版的能力，帮助你的应用载入和运行的很快。

### 8.2 痛点

Ember 的 API 在她稳定之前改变了很多；导致了很多过期的内容，很多例子都不能使用，让第一次接触框架的开发感觉到迷惑。如果你看过 Ember Data 的变更日志，你就会明白我的意思了。这么多的大变动，这导致了很多 Stackflow 的问题和一些编码教程变得过时。

为了保持模版的数据实时更新，DOM 会被 Handlebars 使用的 script 标签。这会随着 HTMLBars 的转变，随着时间推移，你的 DOM 树会被很多 script 标签填充，以致你难以辨认自己的代码。最坏的情况是，她会弄乱 CSS 样式，以及破坏与其他框架的整合。

## 9 总结

我们已经看过了这三个框架的优缺点。Ember 整体方法论强调 MVC 结构，对于有 MVC 开发背景的人来说，容易适应，如 Ruby，Python，Java，C# 等等其他面向对象的语言。Ember 还提升了应用的性能，通过支持约定优于配置很大程度上为你节省了你自己编写模版的时间。

Backbone 强调极度抽象。她小，快以及易于学习，提供你需要最小的代码（甚至比最小还要少）。

Angular 的拓展 HTML 的独创方法与 Web 开发者产生了很多共鸣。强大的社区支持和强有力的 Googld 作为后盾，目前得到了很快速和发展，她同时可以适应快速构建原型项目以及大型的应用产品。


> 参考：
>
>	* [Javascript Framework Comparison](http://www.airpair.com/js/javascript-framework-comparison?utm_source=javascriptweekly&utm_medium=email)
>	* [逃离回调地狱](http://jianshu.io/p/a0379bef5913)
