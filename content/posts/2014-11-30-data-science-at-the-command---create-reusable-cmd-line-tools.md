---
categories:
- data_analytics
date: "2014-11-30T00:00:00Z"
description: Data Science at the Commandline 读书笔记
tags:
- bash
- data_analytics
- python
- R
title: Data Science at the Commandline - 如何创建可复用命令行工具（Commandline Tools）
---

在前一篇 [如何使用命令行进行数据分析](http://n3xtchen.github.io/n3xtchen/data_analytics/2014/10/30/data-science-at-the-command---a-real-world-use-case/) 中，我们使用几个命令来进行一个简单的数据探索，向大家揭示了 **命令行** 毫不逊色于专业的数据分析工具；我们可以通过管道（Pipelines）将不同的命令串联在一块（我们称之为 **one-liners**）进行一些复杂的数据处理，清理，探索以及建模的任务（**Bash** 天生就是一种胶水语言）。

一些任务你可能只会使用一次，然而有些任务你则需要经常使用；一些任务很有针对性，另一些则可以通用化。如果你可以预见到你需要定期重复使用某个 **one-liners**，那你就应该把它封装成命令行工具（**commandline tools**）。

**commandline tools** 和 **one-liners** 都有它们的各自用途。较于 **one-liners**, **Commandline Tools** 有如下特点：

* 你不需要记住其中的具体代码实现，你只需要知道它的用途和用法就可以了；
* 增加命令的可读性；尤其是你在管道中和其他命令一起使用时；

使用编程语言的好处就是你可以将代码固化在文件中。这意味着，它易于你复用。如果它可以被参数化（parameters），它甚至可以应用于同一模式的问题。而 **commandline tools** 具备这两个特定：它在命令行中执行，可以接受参数；因此可以一次创建多次使用。

<!--

在这篇 post 中，我们将使用两种方式来创建可复用的 **Commandline Tools**。

* 介绍如何将 **one-liners** 转化成 **Commandline Tools**。我们通过增加参数，是的命令行工具具有编程语言同样的灵活性。
* 演示如何使用编程语言来创建 **Commandline Tools**；向 **Unix** 的哲学致敬，你的代码可以和其他命令行工具结合；我们只要介绍两种编程语言：**Python** 和 **R**。
-->

## 将 **One-Liner** 封装成 **Shell Script**

我们使用统计单词数的程序（word counter，几乎可以算是数据分析的 *Hello world* 程序了，^_^）来阐述这个章节。先来看一个 **one-liners**；

Ex 1-1:
	
	$ curl -s http://www.gutenberg.org/cache/epub/76/pg76.txt | # (1)
	> tr '[:upper:]' '[:lower:]' |	# (2)
    > grep -oE '\w+' |				# (3)
	> sort |						# (4)
	> uniq -c | 					# (5)
	> sort -nr | 					# (6)
	> head -n 10					# (7)
	6441 and
	5082 the
	3666 i
	3258 a
	3022 to
	2567 it
	2086 t
	2044 was
	1847 he
	1778 of

从输出中你可以猜出它的用途，这个 **one-liners** 返回《哈克贝利·费恩历险记》使用最频繁的头十个词。它主要完成如下功能：

1.	使用 *curl* 下载《哈克贝利·费恩历险记》；
2.	使用 *tr* 把所有文字转化成小写的；
3.	使用 *grep* 把所有词分割到单独行中；
4.	使用 *sort* 把所有单词根据字母顺序排序；
5.	使用 *uniq* 进行去重，和频度计算；
6.	使用 *sort* 根据单词出现的频度进行倒序排列；
7.	使用 *head* 取出 **Top10**；

如果你只使用一次的话，那没什么问题。想象一下，如果你想要找出 *Gutenberg* 项目中每一本电子书的出现最频繁的十个词；或者从一个新闻站点分时统计热词。这时，最好把 **one-liner** 封装成 **commandline tools**。我们通过参数化，给这个 **one-liner** 增加一些灵活性。

我们将会使用 **Bash** 语言来编写这个脚本。我们需要从 **one-liner** 开始，逐步地改进它。将 **one-liner** 封装成可复用的 **commandline tool**，一般需要遵循下面 6 个步骤：

1. 复制 **one-liner** 到文件中
2. 追加该文件的执行权限
3. 在文件头部定义 **shebang**，用来告诉命令行使用某个程序来执行它
4. 去除固定的输入部分
5. 添加参数
6. （可选）将该脚本的路径添加到 `PATH` 中，使它在任何地方都可以执行。
 
### 步骤 1：复制和黏贴

第一步为了创建的心文件。打开你最喜欢的编辑器或者 IDE，复制黏贴我们的 **one-liner**，保存文件名 *top-words-1.sh*（1 代表我们目前处在第一步，你可以选择你换的名称，但是最好该名称能表达一定的含义，让使用者看出它的用途）。

	$ cat top-words-1.sh
	curl -s http://www.gutenberg.org/cache/epub/76/pg76.txt | # (1)
	tr '[:upper:]' '[:lower:]' |	grep -oE '\w+' | sort |
	uniq -c | sort -nr |  head -n 10

现在我们使用 `bash` 命令执行它，它的结果和 **Ex 1-1** 是相同的：

	$ bash top-words-1.sh
	6441 and
    5082 the
    3666 i
    3258 a
    3022 to
    2567 it
    2086 t
    2044 was
    1847 he
    1778 of

第一步，已经帮我节省下次使用该命令码代码的时间了。但是因为它不能自我执行，需要通过 `bash` 命令来执行，所以它还不是严格意义上的 **commandline tool**。这就是我们下一步要做的；

### 步骤 2: 追加该文件的执行权限

我们不能直接执行它的原因是我们没有响应的访问权限。一般来说，你，作为一个用户，你需要有执行文件的权限。

在完成这个操作之前，我们需要为这个步骤复制一份文件：

	$ cp top-words-{1,2}.sh
	
当你完成所有步骤的时候，你就可以清晰地看出每一个步骤的差异，便于你加深印象；后续的几个步骤都会复制前一步骤的文件。好了，现在开始步骤2 ：

	$ chmod u+x top-words-2.sh
	
`chmod`，命令行工具，字面意思 **change mode**；故名思义，变更文件模式。`u+x` 包含三个字符：

* `u`，表示你想要修改是该文件拥有者的权限；这里的 `u` 指的就是你，因为你创建了它；
* `+`，就更简单，代表要追加权限的动作；
* `x`，代表执行（execute）的意思；

这个整个命令连贯起来，就是你为你创建的文件（*top-words-2.sh*）添加执行的权限；为谁？文件的创建者，就是你。先来我们查看步骤 1 和 2 的权限：

	$ ls -l top-words-{1,2}.sh
	-rw-rw-r-- 1 vagrant vagrant 145 Jul 20 23:33 top-words-1.sh 
	-rwxrw-r-- 1 vagrant vagrant 143 Jul 20 23:34 top-words-2.sh

第一列展示的就是每个文件的访问权限。现在我们解读下 *top-words-2.sh* 的访问权限；

*-rwxrw-r--*:

* 第一个字符 -，知名文件类型：- 表示常规文件，d 代表文件（directory）。
* 第二到第四个字符，代表文件拥有者的访问权限，r 代表读 read，w 代表写 write，x 代表执行 execute；你可能注意到了，*top-words-1.sh* 对应的 x 的位置是 -，表示我们不能直接执行它。
* 第五到第七个字符，也是对应的访问权限，但是他设置的一个分组的权限，**Unix/Linux** 中每个用户都有组的概念，便于用户管理，你可能注意到 `ls` 命令还显示其他东西，其中第三列就是该文件的拥有者的用户名（vagrant，第二到第四个字符，就是为这个用户设置权限），第四列是该文件所属于的用户组（vagrant），`rw-` 代表该分组的用户只有读写权利，而没有执行权限。
* 剩下的三个字符知道所有其他用户对该文件的权限，这里他们只有读的权限。

设好执行权限，现在我们可以这么执行文件：

	$ ./top-words-2.sh
	6441 and
    5082 the
    3666 i
    3258 a
    3022 to
    2567 it
    2086 t
    2044 was
    1847 he
    1778 of

 执行同样命令，我又可以少输 4 个字符（*bash*），如果你需要在未来执行它成千上万次，那就节省很可观的输入次数。

注意到 *./* 了吗？这个代表你和该执行文件处在同一个目录下，你可以这样执行，如果切换到其他目录的时候，就需要你使用绝对路径和相对路径来执行它，否则将直接抛出文件不存在的错误（步骤 6 将会为你介绍如何创建全局访问的命令行工具）：

	$ pwd
	~/example/01/
	$ cd ~
	$ ./top-words-2.sh
	-bash: ./top-words-2.sh: No such file or directory
	$ ~/example/01/top-words-2.sh
	6441 and
    5082 the
    3666 i
    3258 a
    3022 to
    2567 it
    2086 t
    2044 was
    1847 he
    1778 of


### 步骤 3: 在文件头部定义 **shebang**，用来告诉命令行使用某个程序来执行它

**shebang**（也称为Hashbang）是一个由井号（she）和叹号（bang）构成的字符序列（#!），其出现在文本文件的第一行的前两个字符。

如果忽略它，将不是一个好主意，就像我们上一步的做法那样，因为脚本行为将会是未定义。由于我们使用命令行终端的默认脚本是 `/bin/bash`，所以我们可以不添加 **shebang**，就能正确的执行。

当时考虑到脚本可能执行在不同的环境下（例如 **zsh**），执行的过程就会出现问题。因此，需要显性定义它：

	#!/usr/bin/env bash	# 这行就是 shebang 定义
	curl -s http://www.gutenberg.org/cache/epub/76/pg76.txt |
	tr '[:upper:]' '[:lower:]' | grep -oE '\w+' | sort |
	uniq -c | sort -nr | head -n 10

添加这一行告诉命令行，使用 **bash** 来执行下面的脚本。将来，你可能使用  **perl**，**python**，**Ruby** 或者 **R** 等等来编写你的命令行行工具，这是你就可以为它们各自追加 **shebang** 来保证脚本使用正确解释器来运行。
	
> 详细介绍见： http://zh.wikipedia.org/wiki/Shebang

### 步骤 4: 去除固定的输入部分

目前为止，我们已经写好了一个有效的 **commandline tool**，但是还有很多需要优化的，我们需要让我们的程序复用度更高。

我们的脚本文件的第一行是 `curl` 命令，用来下载用来统计词频度的文本文件，因此数据和操作被混合在一块。

但是如果我们希望统计其他电子书的话，或者其他站点的文本呢？工具本身的输入数据是固定不变的。如果能将数据抽离出去，那复用度将会更高。

我们假设使用这个命令用户将要提供一个文本文件，数据和操作分离的行为将会更有效。因此，第一种方案我们只需要简单讲 `curl` 命令去掉就可以了。下面是修改后的脚本：

	#!/usr/bin/env bash
	tr '[:upper:]' '[:lower:]' | grep -oE '\w+' | sort |
	uniq -c | sort -nr | head -n 10

假设我们已经把电子书存储到 *data/finn.txt* 文件中，我们就可以这样调用自述统计脚本：

	$ cat data/ | ./top-words-4.sh

我们把数据抽离出来，作为标准的输入流传入脚本中，那它就能够正常工作。

### 步骤 5: 添加参数

现在，我们将我们的脚本参数化。在我们的脚本中，我们有一些固定的命行参数－举个例子，`sort` 的 `-nr` 以及 `head` 的 `-n 10`。如果脚本可以定义 top n 的排行，那将会很有用；修改见如下：

	#!/usr/bin/env bash
	NUM_WORDS="$1"	（1）
	tr '[:upper:]' '[:lower:]' | grep -oE '\w+' | sort |
	uniq -c | sort -nr | head -n $NUM_WORDS	（2）

1. 变量 `NUM_WORDS` 值设置成 `$1`，他是 **bash** 的特殊变量，它保存命令行传入的第一个参数的值。
2. 使用美元符号（`$`）＋变量名来获取该变量值

现在如果你想要查看前五个被频繁的词，我们需要使用如下方式调用：

	$ cat data/finn.txt | top-words-5.sh 5

如果没提供一个给这个命令，将会返回一个错误信息。

	$ cat data/finn.txt | top-words-5.sh 
	head: option requires an argument -- 'n' 
	Try 'head --help' for more information.

> **Note**: 参数化带来的好处是增加脚本的灵活度，但是过度的参数化，将会获取相反的效果；参数过多的情况使用默认值来屏蔽一些不常用于设置的参数。

### 步骤 6: （可选）将该脚本的路径添加到 `PATH` 中，使它在任何地方都可以执行。

现在已经完成了脚本的编写，得到一个可服用的命令行工具。然而你使用脚本（跨目录或跨用）的时候，还要带上屯长的路径，会用户非常困扰。这一步，让你像调系统命令的一样调用的你代码（例如，你可以在任何目录，调用 `ls`，而不需要知道 `ls` 脚本位于哪一个目录），这样是不是更爽，少敲了不少字符。

首先，我们需要知道 **Bash** 如何寻找你命令行工具；它实际上是通过轮训存储在 **PATH** 环境变量中的目录来完成的。

	$ echo $PATH
	/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/loc al/games:/home/vagrant/tools:/usr/lib/go/bin:/home/vagrant/.go/bin:/home/vagrant /.data-science-at-the-command-line/tools:/home/vagrant/.bin
	
这个是我的 `PATH` 变量值，目录之间使用冒号隔开。为了使它更直观，做一些格式化：

	$ echo $PATH | tr : '\n' | sort
	/bin
	/home/vagrant/.bin 
	/home/vagrant/.data-science-at-the-command-line/tools 
	/home/vagrant/.go/bin
    /home/vagrant/tools
    /sbin
    /usr/bin
    /usr/games
    /usr/lib/go/bin
    /usr/local/bin
    /usr/local/games
    /usr/local/sbin
    /usr/sbin


你可以将脚本存放在上面目录中的一个（建议放在你用户根目录的 *～/.bin*，在 **Linux** 中，每个目录都有不同的功能，混杂到其中，会迷惑后来使用的人），或者把你的脚本目录追加到 `PATH` 中：

	$ export PATH=$PATH:/dir/to/your/scrpit

如果你想要把这个 `PATH` 固化（不用每次都手动配置），你可以把上面的脚本追加到 *~/.bashrc* 或者 *~/.profile* 中，例如：

	$ echo 'PATH=$PATH:/dir/to/your/scrpit' >> ~/.bashrc
	$ source ~/.bashrc	# 使 ~/.bashrc 的变动生效

## 享受生活，告别冗长脚本！^_^

