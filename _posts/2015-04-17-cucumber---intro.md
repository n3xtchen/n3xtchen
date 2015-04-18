---
layout: post
title: "Cucumber - 入门"
description: ""
category: cucumber
tags: [cucumber, atdd]
---
{% include JB/setup %}

经过一段时间的学习，对 **Cucumber** 有了初步的了解，它所包含的理念深深的打动了我。作为 **TDD** 的拥护者，已经长期被需求折磨的开发来讲，希望借助 **Cucumber** 的推广：

* 有效地指导我们的开发，提高效率，降低需求误解的带来的成本，避免垃圾需求的实现污染代码库；
* 帮助需求方更好地整理思路，更准确的表述需求，以及提供更清晰的用例；

好话不多说，我们现在通过简单的流程初步认识 **Cucumber**。

首先，假设一个案例（来自**《The Cucumber Book》**）， 我们的目的为了编写一个计算器程序。

我们有个非常棒的想法（^_^），这个计算器将来有一天可能会成一个云服务，运行在每个手机，PC 以及浏览器上，帮助人们进行各种各样的计算。我们是务实的善根，因此，我们的第一个版本尽可能的简单。第一版本的程序是一个命令行工具，有 **Ruby** 实现；它接受输入，通过命令行输出结果。

例如，如果输入一个文件，如下：

	2+2
	
它的输出应该是 `4`；

类似的，如果输入的文件是：

	100/2
	
那它的输出就应该是 `50`。

### 创建一个功能（Feature）

**Cucumber** 测试通过功能来分组。

我们首先要做的是创建一个目录来保存我们的程序

	λ MacBook-Pro cucumber → mkdir calculator
	λ MacBook-Pro cucumber → cd calculator
	
我们将通过 **Cucumber** 来指导我们的开发，因此我们先从运行 **cucumber** 命令开始：

	λ MacBook-Pro calculator → cucumber
	No such file or directory @ rb_sysopen - features. Please create a features directory to get started. (Errno::ENOENT)
	
因为我们没有提供任何参数给 **cucumber** 命令；因此，按惯例，我们使用 `features` 目录来保存我们的测试文件。由于不存在这个目录，就像命令提醒我们那样；那我们就按照它的指示继续：

	λ MacBook-Pro calculator → mkdir features
	λ MacBook-Pro calculator → cucumber
	0 scenarios
	0 steps
	0m0.000s
	
现在没有报错了。讲解一些概念，每一个 **Cucumber** 测试就是一个 **scenarios**，以及每一个 **scenarios** 都包含多个 **step**。这个输出告诉我们，**Cucumber** 扫描了 `features` 目录，但是没有找到任何的 **scenarios** 可以执行。

根据我们的用户调查，所有的运算操作中加法占据了 67%，因此我们首先要支持他。使用你最喜欢的编辑器，创建一个叫做 `features/adding.feature` 的文本文件，内容如下：

	 Feature: Adding
	     Scenario: Add two numbers
	         Given the input "2+2"
	 
	         When the calculator is run
	         Then the output should be "4"
	 
这个功能文件包含了我们程序的第一个场景。关键字 `Feature`，`Scenario`，`Given`，`When` 和 `Then` 是结构，其他的东西都是文档。我们称这个结构为 **Gherkin**。

保存好你的文件，在运行一次 `cucumber`，我们讲看到比上一次更多的输出：

	λ MacBook-Pro calculator → cucumber
	Feature: Adding
	
	  Scenario: Add two numbers       # features/adding.feature:2
	    Given the input "2+2"         # features/adding.feature:3
	    When the calculator is run    # features/adding.feature:5
	    Then the output should be "4" # features/adding.feature:6
	
	1 scenario (1 undefined)
	3 steps (3 undefined)
	0m0.002s
	
	You can implement step definitions for undefined steps with these snippets:
	
	Given(/^the input "(.*?)"$/) do |arg1|
	  pending # express the regexp above with the code you wish you had
	end
	
	When(/^the calculator is run$/) do
	  pending # express the regexp above with the code you wish you had
	end
	
	Then(/^the output should be "(.*?)"$/) do |arg1|
	  pending # express the regexp above with the code you wish you had
	end
	
	If you want snippets in a different programming language,
	just make sure a file with the appropriate file extension
	exists where cucumber looks for step definitions.

