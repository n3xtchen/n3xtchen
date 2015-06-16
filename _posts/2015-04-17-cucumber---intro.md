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
	
我们将通过 **Cucumber** 来指导我们的开发，因此我们先从运行 `cucumber` 命令开始：

	λ MacBook-Pro calculator → cucumber
	No such file or directory @ rb_sysopen - features. Please create a features directory to get started. (Errno::ENOENT)
	
因为我们没有提供任何参数给 `cucumber` 命令；因此，按惯例，我们使用 `features` 目录来保存我们的测试文件。由于不存在这个目录，就像命令提醒我们那样；那我们就按照它的指示继续：

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

保存好你的文件，在运行一次 `cucumber`：

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

Wow，突然这么多的输出，吓的一跳吧。首先，我们可以看到 **Cucumber** 找到了我们的 feature，并且尝试运行它；接下来的是给出了三个 **Ruby** 代码片段。那我们就遵照这个指示进行下一步了，把这三个代码片段黏贴到文件中。

### 创建步骤（Step Definitions）

现在，我们开始实现一些步骤，让我们的场景不再 `undefined`。不要在意它的含义，把它拷贝到文件中就是了；**Cucumber** 的惯例是把步骤定义存放在 `features/step_definitions` 下，现在我们要创建它：

	λ MacBook-Pro calculator → mkdir features/step_definitions
	
现在我们在这个目录下面创建一个 **Ruby** 文件，命名为 `calculator_step.rb`。**Cucumber** 不在乎步骤文件的命名，只要他是一个 **Ruby** 文件，但是好的名称还是很有必要的。现在我们打开它，代码片段复制进去： 

	# features/step_definitions/calculator_step.rb
	Given(/^the input "(.*?)"$/) do |arg1|
	    pending # express the regexp above with the code you wish you had
	end
	
	When(/^the calculator is run$/) do
	    pending # express the regexp above with the code you wish you had
	end
	
	Then(/^the output should be "(.*?)"$/) do |arg1|
	    pending # express the regexp above with the code you wish you had
	end
	
保存完文件，我们执行下 `cucumber`：

	λ MacBook-Pro calculator → cucumber
	Feature: Adding
	
	  Scenario: Add two numbers       # features/adding.feature:2
	    Given the input "2+2"         # features/step_definitions/calculator_step.rb:1
	      TODO (Cucumber::Pending)
	      ./features/step_definitions/calculator_step.rb:2:in `/^the input "(.*?)"$/'
	      features/adding.feature:3:in `Given the input "2+2"'
	    When the calculator is run    # features/step_definitions/calculator_step.rb:5
	    Then the output should be "4" # features/step_definitions/calculator_step.rb:9
	
	1 scenario (1 pending)
	3 steps (2 skipped, 1 pending)
	0m0.057s

我们顺利让场景从 `undefined` 晋级到 `pending`。这是个好消息，说明 **Cucumber** 在执行第一个步骤，但是碰到了 `pending` 标记。我们现在需要使用真正的实现来替换 `pending` 标记。

> 注意
> **Cucumber** 报道另外两个步骤被跳过；是因为当它遇到一个失败或者 `pending` 步骤的时候，**Cucumber** 将会停止执行这个场景，跳过剩下的步骤。

### 实现我们第一个步骤（Step Definitions）

我们已经决定我们的第一版本是一个计算器，接受命令行的参数作为输入，因此我们的第一步就是获取一个参数；我们现在开始定义：

	# features/step_definitions/calculator_step.rb
	Given(/^the input "(.*?)"$/) do |input|
	    @input = input
	end

然后，
	
	λ MacBook-Pro calculator → cucumber
	Feature: Adding
	
	  Scenario: Add two numbers       # features/adding.feature:2
	    Given the input "2+2"         # features/step_definitions/calculator_step.rb:1
	    When the calculator is run    # features/step_definitions/calculator_step.rb:5
	      TODO (Cucumber::Pending)
	      ./features/step_definitions/calculator_step.rb:6:in `/^the calculator is run$/'
	      features/adding.feature:5:in `When the calculator is run'
	    Then the output should be "4" # features/step_definitions/calculator_step.rb:9
	
	1 scenario (1 pending)
	3 steps (1 skipped, 1 pending, 1 passed)
	0m0.031s

我们的第一步通过了！但是场景还是被标记为 pending，当然，是因为我们实现了一步，剩下的两个步骤还没有实现。不过我们取得了进展，不是吗？

### 运行我们的程序

现在开始实现我们的第二步：

	When(/^the calculator is run$/) do
	    @output = `ruby cacl.rb #{@input}`
	    raise('Command failed') unless $?.success?
	end

然后,
	
	λ MacBook-Pro calculator → cucumber
	Feature: Adding
	
	  Scenario: Add two numbers       # features/adding.feature:2
	    Given the input "2+2"         # features/step_definitions/calculator_step.rb:1
	ruby: No such file or directory -- cacl.rb (LoadError)
	    When the calculator is run    # features/step_definitions/calculator_step.rb:5
	      Command failed (RuntimeError)
	      ./features/step_definitions/calculator_step.rb:7:in `/^the calculator is run$/'
	      features/adding.feature:5:in `When the calculator is run'
	    Then the output should be "4" # features/step_definitions/calculator_step.rb:10
	
	Failing Scenarios:
	cucumber features/adding.feature:2 # Scenario: Add two numbers
	
	1 scenario (1 failed)
	3 steps (1 failed, 1 skipped, 1 passed)
	0m0.103s
	
这个步骤失败了，是因为没有 `calc.rb` 这个程序可以运行。

### 添加断言

按照 **cucumber** 的指示，我们需要为我们的程序，创建一个 **Ruby** 文件。

针对 Mac/Linux 用户在命令行中输入如下代码来创建这个文件：

	λ MacBook-Pro calculator → touch cacl.rb
	
如果是 Windows 用户，你的命令是：

	​C:\> echo.>calc.rb​
	
然后我们再次执行 `cucumber`

	λ MacBook-Pro calculator → cucumber
	Feature: Adding
	
	  Scenario: Add two numbers       # features/adding.feature:2
	    Given the input "2+2"         # features/step_definitions/calculator_step.rb:1
	    When the calculator is run    # features/step_definitions/calculator_step.rb:5
	    Then the output should be "4" # features/step_definitions/calculator_step.rb:10
	      TODO (Cucumber::Pending)
	      ./features/step_definitions/calculator_step.rb:11:in `/^the output should be "(.*?)"$/'
	      features/adding.feature:6:in `Then the output should be "4"'
	
	1 scenario (1 pending)
	3 steps (1 pending, 2 passed)
	0m0.102s
	
现在我们给我们的最后一步添加断言：

	Then(/^the output should be "(.*?)"$/) do |arg1|
	    expect(@output).to eq 4
	end
	
我们使用 **RSpec** 断言来检查 feature 中指定的期待值是否与程序的实际输出一致:

	λ MacBook-Pro calculator → cucumber
	Feature: Adding
	
	  Scenario: Add two numbers       # features/adding.feature:2
	    Given the input "2+2"         # features/step_definitions/calculator_step.rb:2
	    When the calculator is run    # features/step_definitions/calculator_step.rb:6
	    Then the output should be "4" # features/step_definitions/calculator_step.rb:11
	
	      expected: 4
	           got: ""
	
	      (compared using ==)
	       (RSpec::Expectations::ExpectationNotMetError)
	      ./features/step_definitions/calculator_step.rb:12:in `/^the output should be "(.*?)"$/'
	      features/adding.feature:6:in `Then the output should be "4"'
	
	Failing Scenarios:
	cucumber features/adding.feature:2 # Scenario: Add two numbers
	
	1 scenario (1 failed)
	3 steps (1 failed, 2 passed)
	0m0.080s
	
好极了。现在我们的测试终于能够由于合理的理由失败了：它运行我们的程序，检查输出，告诉我们应该如何正确输出。我们已经为这个版本做了很多工走：当我们回到这个代码的时候，**cucumber** 将告诉我们该做做什么来让我们的程序生效。如果我们所有的需求都可以利用失败的测试来验证，创建软件将会容易很多。

### 通过测试

现在我们有了一个失败的 **Cucumber** 场景，是时候让我们的场景驱动我们解决问题。

试试下面的代码：

	# cacl.rb
	print "4"

终于成功了
	
	λ MacBook-Pro calculator → cucumber
	Feature: Adding
	
	  Scenario: Add two numbers       # features/adding.feature:2
	    Given the input "2+2"         # features/step_definitions/calculator_step.rb:2
	    When the calculator is run    # features/step_definitions/calculator_step.rb:6
	    Then the output should be "4" # features/step_definitions/calculator_step.rb:11
	
	1 scenario (1 passed)
	3 steps (3 passed)
	0m0.095s

> http://baya.github.io/2014/04/21/cucumber%E5%AE%9E%E6%88%98/

