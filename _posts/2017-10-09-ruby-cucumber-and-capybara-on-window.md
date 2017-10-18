---
layout: post
title: "Window 下 Cucumber 新人手册：使用 Ruby 和 Capybara 进行自动化测试"
description: ""
category: Ruby 
tags: [cucumber,capybara]
---
{% include JB/setup %}

## 前言

我一般使用 **Selenium Webdriver** 进行 **WEB** 自动化测试。她是自动化测试领域知名的框架，拥有成熟的社区；当你遇到困难的的时候，你很容易找到解决方法。另一方面，我的一些朋友是 **Ruby For Test** 的大粉丝。我也同时也参加了一些 **Ruby** 自动化测试沙龙，了解 **Ruby** 的一些特性和能力。作为我的观点，**Ruby** 拥有简洁的语法，并且易于上手；你可以使用 **Capybara** 驱动 **WEB** 应用，**RestClient** 进行接口测试和 **SitePrism** 进行 POM (Page Object Model) UI 测试；掌握了这些库，你就可以轻轻松松开始自动化测试了。

本文，我将讲解如何安装和设置 **Ruby**，**Capybara** 和 **Cucumber**。这是针对 **Ruby** 测试新手的入门教程。首先，我们先从定义开始。

## 什么是 Capybara

下面是 [官方](http://teamcapybara.github.io/capybara/) 的描述的非常清楚了：

> Capybara 是由 Ruby 编写的一个库，目的是为了简化模拟用户在应用中的交互。


> Capybara 提供统一简洁的接口来操作不同的驱动来执行你的测试。你可以无差别地选择 **Selenium**, **Webkit** 或 **纯 Ruby drivers**。

> 用 **Capybara** 强大的同步功能来处理异步网页。**Capybara** 会自动等待你的内容出现在页面上，而不用进行手动的睡眠。

## 什么是 Cucumber

**Cucumber** 是一个用于编写和执行软件功能描述。她支持 **行为驱动开发（BDD）**。它提供一种编写测试的方式：不受限于他们的技术背景，任何人都可以读懂。**Cucumber（中文名：黄瓜）** 理解的语言叫做 **Gherkin（中文名：嫩黄瓜）**。**Cucumber** 自己本身是使用 **Ruby** 实现的，但是她允许使用 **Ruby** 或者其他语言（不仅仅限于 **Java**、**C#** 和 **Python**）来编写测试。

下面是 **Gherkin** 脚本：

    Scenario: Filter the television list
      Given some different televisions in the TV listing page
      When I visit the TV listing page 
      And I search for "Samsung" TVs
      Then I only see titles matching with Samsung TVs
      When I erase the search term
      Then I see all television brands again

## 安装和配置

#### 前置条件：

* Window （我的系统是 Win7）
* [FireFox](http://www.firefox.com.cn/)（由于新手，不建议折腾 IE）

#### 安装和配置 Ruby 环境

1. 对于 **Windows** 来说，安装 **Ruby** 最好的地方是 [http://rubyinstaller.org/downloads/](http://rubyinstaller.org/downloads/)。打开网站，下载最新的 32 位 **Ruby**。

    ![Ruby 下载](http://p.aybe.me/blog/DingTalk20171010145948.png?x-oss-process=image/resize,w_300,h_400,limit_0)

2. 在这里，我们将使用 **Ruby 2.4.2** 版本。下面是我勾选的安装选项，大家可以参考下。

    ![Ruby 安装选项](http://p.aybe.me/blog/DingTalk20171013004705.png?x-oss-process=image/resize,w_500,h_350,limit_0)

    > 如果你习惯使用 **Window** 自带的命令行工具（**cmd.exe** 或 **PowerShell**），大家务必把 **Add Ruby executables to your PATH.** 这个选项选中；

    ![Ruby 安装完成](http://p.aybe.me/blog/DingTalk20171013004849.png?x-oss-process=image/resize,w_500,h_350,limit_0)

    看到红色方框了没有？像 **Capybara** 和 **Cucumber** 这样的类库会依赖原生的 **C** 拓展，所以**必须安装**。

    > #### 关于 DevKit
    >
    > 对于老用户来说，使用安装 **DevKit** 来解决安装原生拓展的问题，现在该项目已经不在维护了。从 **Ruby 2.4** 开始，我们使用 **MYSYS2** 编译 **Ruby** 来取代 **Devkit**；
    >
    > 具体内容详见 [Meet MSYS and the DevKit](https://rubyinstaller.org/add-ons/devkit.html)

3. 安装成功后，直接弹出命令行工具，内容如如下；你应该先选择 **2**，安装并更新 **MinGW**，因为 **RubyInstaller** 中的 **MinGW** 版本比较旧，不更新会导致后续安装失败。另外，你还可以一堆的 **Gnome** 工具（Linux 下常见的工具，如 **Bash**，`sed` 等等）


         _____       _           _____           _        _ _         ___
        |  __ \     | |         |_   _|         | |      | | |       |__ \
        | |__) |   _| |__  _   _  | |  _ __  ___| |_ __ _| | | ___ _ __ ) |
        |  _  / | | | '_ \| | | | | | | '_ \/ __| __/ _` | | |/ _ \ '__/ /
        | | \ \ |_| | |_) | |_| |_| |_| | | \__ \ || (_| | | |  __/ | / /_
        |_|  \_\__,_|_.__/ \__, |_____|_| |_|___/\__\__,_|_|_|\___|_||____|
                            __/ |           _
                           |___/          _|_ _  __   | | o __  _| _     _
                                           | (_) |    |^| | | |(_|(_)\^/_>
        
           1 - MSYS2 base installation
           2 - MSYS2 system update
           3 - MSYS2 and MINGW development toolchain
        
        Which components shall be installed? If unsure press ENTER [1,2,3] 
    
    安装过程中会弹出 MSYS2 安装向导，要你选择安装路径；这个路径要记住，环境变量的配置文件就存放在这里。在这里，我把 **MSYS2** 安装在 *C://msys2* 目录下面
    
    ![MSYS2 安装路径](http://p.aybe.me/blog/DingTalk20171013005343.png?x-oss-process=image/resize,w_500,h_350,limit_0)
    
    > 好久没倒腾 **Windows**，发现 **mingw** 居然自带了 **ArchLinux** 的包管理工具 **pacman**，好吃惊！

4. 安装完，会重新回到上述界面。这时，你选择 **3**，来安装开发工具链，比如 `make`、`autoconf`、`automake` 这些常用编译工具。

5. 最后，回车退出。

目前为止，你已经安装你的 **Ruby** 开发环境。

> Note: 后续的步骤都在 **msys2** 中执行

![MinGW 界面](http://p.aybe.me/blog/DingTalk20171013011136.png?x-oss-process=image/resize,w_500,h_350,limit_0)

#### 接下来我们验证下环境是否可用

1. 执行 `ruby -v` 来验证 **Ruby** 安装。命令输出如下：

        Test@t-w7sp1eng-ie9 MINGW32 ~
        $ ruby -v
        bash: ruby: command not found

    尴尬的发现 **MinGW** 没把 **Ruby** 程序加到路径中。怎么办？打开 *C:\msys32\home\Test\.bash_rc* 文件，在文件末尾追加如下命令：

        export PATH=/c/Ruby24/bin:$PATH

    > 小常识：*/c/Ruby24/bin*，**Posix Path**，这是一种文件路径规范，**Unix**/**Linux** 都遵循这个规范，**MinGW** 会把这个格式转化成 **Windows** 的路径格式；如果希望深入了解，详见 [MinGW-Posix Path Conversion](http://www.mingw.org/wiki/Posix_path_conversion)。为了便于学习，我整理一个规律：
    >
    > * 如果遇到第一个 **／**，你将第一个 **／** 去掉，并把第二个改成 **\:**
    > * 其他的 **／** 一律转化成 **\\**

    再次执行命令验证下，将打印出你所安装详细版本：

        Test@t-w7sp1eng-ie9 MINGW32 ~
        $ ruby -v
        ruby 2.4.2p198 (2017-09-14 revision 59899) [i386-mingw32]

2. 执行 `gem -v` 来验证 **RubyGems** 安装，输出相应的版本号。**RubyGems** 是 **Ruby** 的包管理工具，应该包含在 **Ruby** 的标准安装。

        Test@t-w7sp1eng-ie9 MINGW32 ~
        $ gem -v
        2.6.13


3. 验证 **MSYS2-DEVKIT** 是否安装正确

		Test@t-w7sp1eng-ie9 MINGW32 ~
		$ gem install json --platform ruby  <<< 命令在这里
		Temporarily enhancing PATH for MSYS/MINGW...
		# 这里插句话，下面就是说明安装 JSON 库我时，我们编译了原生拓展（native extensions）
		Building native extensions.  This could take a while...
		...

#### 安装自动化测试所需要的库

要安装的库如下:

* Cucumber：技术白痴都看得懂的测试代码，用来指挥整个测试流程
* Capybara：利用 **webdriver** 操纵浏览器，人性化的 DSL，使用起来更便捷
* Selenium Webdriver：它才是真正操纵浏览器的工具
* RSpec：结果验证工具，如断言和判定

复习完前面的内容后，开始安装。。。

1. 在你的 **MSYS2** 命令行中，执行如下命令

		Test@t-w7sp1eng-ie9 MINGW32 ~
		$ gem install cucumber capybara selenium-webdriver rspec

    > 为了安装这 4 个 gems（相当于软件包），我们总共安装了 29 个 gems(包括依赖)。

2. 验证 **Cucumber** 是否安装成功。如果出现如下信息，说明安装成功：

        Test@t-w7sp1eng-ie9 MINGW32 ~
        $ cucumber help <<< 命令在这里
        *** WARNING: You must use ANSICON 1.31 or higher (https://github.com/adoxa/ansicon/) to get coloured output on Windows
        No such file or directory - help. You can use `cucumber --init` to get started.

## 开始使用 Ruby、Capybara 和 Cucumber 开始编写自动化测试脚本

**首先**，我们需要创建一个 *feature* 目录，用于存放我们的所有的测试用例。

**Feature** 文件应该使用 **Gherkin（Given-When-Then，同样支持 i18n：）** 语法来编写。**Gherkin** 是一门面向领域语言（**DSL**），允许你不用考虑具体的实现来描述你的软件行为。

每一个场景（Scenario）有三个部分构成：**Given**，**When** 和 **Then**

* **Given**：描述预设的条件
* **When**：描述你发起的行为
* **Then**：描述预期的结果

还可以使用 **And** 来衔接多个行为。例如：

    Given I am on the product page
    And I am logged in
    Then I should see "Welcome!"
    And I should see "Personal Details"

这个例子中，第一个 **And** 扮演 **Given**，而第二个扮演 **Then**。

进入 *features* 目录，创建一个 *test.feature* 文件。我们的测试用例如下：

* 进入 www.google.com.hk
* 搜索 N3xt-Tech 博客
* 看到 N3xt-Tech 博客 的搜索内容
* 点击 N3xt-Tech 博客 链接
* 等待 10 秒

现在，我们使用 `notepad++`（或者其他文字编辑系统） 打开 *test.feature* 文件（**注意**：一定要使用 **UTF-8** 字符编码保存），使用 **Gherkin** 语法编写上面的测试用例。

    Feature: Find the Yahoo Website
    Scenario: Search a website in google        
      Given I am on the Google homepage
      When I will search for "N3xt-Tech 博客"
      Then I should see "N3xt-Tech 博客"
      Then I will click the “N3xt-Tech 博客” link
      Then I will wait for 10 seconds

编写完，我们尝试运行下我们的测试：

    cucumber features\test.feature

我们还没有定义好测试步骤。因此，我们运行测试后会得到上述结果

![无步骤定义的输出](http://p.aybe.me/blog/DingTalk20171014171445.png?x-oss-process=image/resize,w_500,h_600,limit_0)

这个就是 **Cucumber** 人性化的一个体现，你直接测试说明，她会帮助你生成测试代码模版，这是你只需要填充的测试逻辑就好了。

首先在 *features* 目录中创建一个名为 *step_definitions* 文件。然后，创建一个名为 *test_steps.rb* 的脚本文件，把刚才测试结果的代码片段（上图中红色方框中的内容）粘贴进去。

> **说明**：**Ruby** 程序文件都是使用 *.rb* 后缀保存，所以后续看到 *.rb* 文件，里面就是 Ruby 程序了，

在执行一遍命令，查看下输出：

![填充步骤定义的输出](http://p.aybe.me/blog/DingTalk20171014172141.png?x-oss-process=image/resize,w_500,h_300,limit_0)

看红色方框的部分，对比上一个输出，之前场景（**scenario**）和测试步骤（**steps**）时都是未定义（**undefined**），现在都是 **pending**（待定）和 **skipped** 状态。

代码中 **pending** 的部分就是我们后续要填充的测试逻辑。

现在，我们可以编写测试步骤了。我现在将要教会你们如何一步步实现自动化测试的。

开始前，现在先看看最终目录结构（标准的 **Cucumber** 目录结构）：

    .   # C:\\msys2\home\test
    └── web_test    # 项目目录
        └── features    # 测试用例目录
            ├── step_definitions    # 测试步骤具体实现
            │   └── test_steps.rb
            ├── support           
            │   └── env.rb
            └── test.feature    # Gherkin
    
    4 directories, 3 files

由于作为初学者教程，我将隐藏一些复杂的代码逻辑。

我们在 *features* 目录中创建一个 *support* 目录（如何之前的目录结构中），然后创建 *env.rb* 文件，来初始化环境。*env.rb* 代码如下：

    require 'rubygems'
    require 'capybara'
    require 'capybara/dsl'
    require 'rspec'
     
    Capybara.run_server = false
    #设置默认的 Driver
    Capybara.default_driver = :selenium
    #设置默认的选择器
    Capybara.default_selector = :css
     
    #同步相关设置    
    module Helpers
      def without_resynchronize
        page.driver.options[:resynchronize] = false
        yield
        page.driver.options[:resynchronize] = true
      end
    end
    World(Capybara::DSL, Helpers)

它主要用来配置后续我们可以在 **Cucumber** 使用 **Capybara** 方法，这里暂时不需要了解代码具体实现，在后续博客中将会一一解释。

1. 首先，我们需要访问 *google.com.hk* 站点。**Capybara** 提供 `visit` 方法来实现这个目的。在 **Selenium** ，我们可以使用 `driver.get()` 或 `driver.navigate().to()` 来完成这个动作。因此，我们应该添加如下代码来访问 *google.com.hk*:
   
		visit 'http://www.google.com.uk'

2. 经过上面的操作，我们已经到 *google.com.hk* 的页面上，我们要在搜索框中输入我们要查询的文本。如下所述，查询框的 `id` 是 `lst-ib`。

	![查看工具栏的 id](http://p.aybe.me/blog/DingTalk20171017010602.png?x-oss-process=image/resize,w_600,h_600,limit_0)

	**Capybara** 提供一个方法叫 `fill_in`，用于文本填充操作。我们可以使用如下代码实现这个操作。在 **Selenium** 中，我们可以使用 `textElement.sendKeys(String)` 方法:

		fill_in 'lst-ib', :with => searchText
		click_on 'Google 搜索'	# 点击搜索按钮

3. 接着，我们需要在当前页面检索期待的查询结果。我们可以使用 `page.should have_content` 方法。在 **Selenium** 中，我们可以使用 **JUnit**，**TestNG** 或者 **Hamcrest** 断言:

		page.should have_content(expectedText)

4. 现在，该点击 **Next-Tech 博客** 链接了。如下图所示，链接文本就是 **Next-Tech 博客**：

	![查看Next-Tech 博客超链接的文本](http://p.aybe.me/blog/DingTalk20171017010410.png?x-oss-process=image/resize,w_600,h_600,limit_0)

	在 **Capybara** 中，我们可以使用 `click_link` 来执行点击操作。在 **Selenium** 中，我们可以使用 `driver.findElement(By.linkText("Next-Tech 博客"))`:

		click_link('Next-Tech 博客')

5. 最后一步了，我们将在 **Next-Tech 博客** 的站点上停留 10 秒，使用 `sleep(10)` 来实现。在 **Selenium** 中，我们使用 `Thread.sleep(10)`;

	现在，我们把之前的代码都整合在一起。我们的 *test_steps.rb* 代码如下：
		
		# encoding: UTF-8
		
		# 访问 google.com.hk
		Given(/^I am on the Google homepage$/) do
		  visit 'https://www.google.co.uk/'
		end
		  
		# 输入 "Next-Tech 博客" 到搜索框中
		When(/^I will search for "([^"]*)"$/) do |searchText|
		  fill_in 'lst-ib', :with => searchText
		  click_on 'Google 搜索'
		end
		  
		# 在当前页面将看到 “Next-Tech 博客”
		Then(/^I should see "([^"]*)"$/) do |expectedText|
		  page.should have_content(expectedText)
		end
		  
		# 点击链接
		Then(/^I will click the “([^"]*)” link$/) do |link|
		  click_link(link)
		end
		  
		# 等待 10 s
		Then(/^I will wait for (\d+) seconds$/) do |waitTime|
		  sleep (waitTime.to_i)
		end

6. 我们已经可以开始我们完整的测试用例了。首先，进入你的项目目录，它包含如下所示的 *features* 目录，开始运行 **Cucumber**：

		cd ~/web_test
		cucumber feature\test.feature

在运行时候，发现如下错误：

![缺少geckodriver的报错信息](http://p.aybe.me/blog/DingTalk20171019005104.png?x-oss-process=image/resize,w_500,h_600,limit_0)

这个错误（红色方框内）的主要意思就是 调用 **FireFox** 进行自动化测试时，**Selenium**  没找到相应的驱动来操纵浏览器，所以我们就按照错误中的提示，进行操作。

下载 [geckodriver](https://github.com/mozilla/geckodriver/releases)（地址就是图中**绿色下划线**的部分，当前最新版本是 **0.19.0**），并解压到指定位置（我把它放到 *C://geckodriver-v0.19.0-win32* 中）：

![下载指定geckdriver](http://p.aybe.me/blog/DingTalk20171018234341.png?x-oss-process=image/resize,w_400,h_300,limit_0)

把刚刚下载的程序添加到 **PATH** 中。于是，我们再次打开 *C:\msys32\home\Test.bash_rc* 文件，在该文件末尾追加如下命令：

    export PATH=/c/geckodriver-v0.19.0-win32:$PATH

接着，重新运行 **Cucumber**，看看整个测试执行过程，^_^

## 结语

用 **Ruby** 好多年了，写起来真心爽，主要用来做自动化测试和页面监控。不认真看，还以为你是在写作文，看看 **Capybara** 的封装方法，明显就是主谓宾结构嘛 \^_\^，这样编程语言你不觉得酷吗？**Cucumber** 真的做到了 `只要你识字，肯定看得懂用例`，产品 🐶 也能过来对着代码指指点点了（终于可以更好融入了产品迭代中），自豪不自豪？这就是使用 **Ruby** 开发自动化测试的魅力所在。

我常说：“如果当初可以选择，我希望我的第一门语言是 **Ruby**”。现在后生的语言多少都能看到 **Ruby** 的影子。

Happy Programming！
Happy Testing！



