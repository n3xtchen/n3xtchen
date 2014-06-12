---
layout: post
title: "R Statistics- 入门"
tagline: ""
description: ""
category: R
tags: [R]
---
{% include JB/setup %}

R语言，一种自由软件编程语言与操作环境，主要用于统计分析、绘图、数据挖掘。R本来是由来自新西兰奥克兰大学的 Ross Ihaka 和 Robert Gentleman 开发（也因此称为R），现在由“R开发核心团队”负责开发。R是基于S语言的一个GNU计划项目，所以也可以当作S语言的一种实现，通常用S语言编写的代码都可以不作修改的在R环境下运行。R的语法是来自Scheme。

R 提供一个强大和漂亮的交互环境，用于探索数据。由于 R 是免费的，使它变得更加的流行。目前存在的一批数据分析工具（如 S，MATLAB，SPSS 和 SAS）非常的昂贵，而 R 确实是实现同样效果成本最低廉的一种方式；而且 R 的社区拥有大量的领域专家和开发者，其中不乏统计学家，数据科学家，他们贡献了很多非常有用的包，来帮助拓展 R 的能力。

R的源代码可自由下载使用，亦有已编译的可执行文件版本可以下载，可在多种平台下运行，包括UNIX（也包括FreeBSD和Linux）、Windows和MacOS。

目前的稳定版是 3.10

### 安装 R

R 提供几种可选方式安装方式：

#### **1. 从 Cran 下载软件包**
R可以在CRAN(Comprehensive R Archive Network)上免费下载。Linux、 Mac OS X和Windows都有相应编译好的二进制版本。根据你所选择平台的安装说明进行安装即可。

#### **2. 使用 Linux 包管理器安装**

基于 Redhat 的系统：

	$ yum install R

基于 Debian 的系统：

	$ sudo apt-get isntall r-base
	
#### **3. 编译安装（不推荐）**

### 启动你的 R

R 由多个部分组成，其中包括一个美观的图形用户界面。在 OS X 和 Linux 下，你可以简简单单在终端的敲击 R 就可以启动它了：

	$ R

当然还有很多非官方的 R 图形编程环境，例如 R Commander 和 RStudio。RStudio 不仅提供了很漂亮的图像界面，而且还有服务器版本（RServer），让你在网页中编程和本地一样舒适。当然你也可以使用你最喜欢的自处理软件（如 Vim， Emacs 和 Sublime）。

### Hello, R!

我们先从简单的 R 终端开始把。

	> height <- c(58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72)
	
函数 c() 告诉我们创建的是一个名为 height 向量（Vector，一个有序的数字集合，这里的单位是 inch），`<-` 是 R 的赋值符号（我们也可以使用 `=`）。接下来，我们用同样的方法创建一个体重向量：

	> weight <- c(115, 117, 120, 123, 126, 129, 132, 135, 139, 142, 146, 150, 154, 159, 164)
	
现在我们有数据了，用它来做点东西。我们想要算出身高的平均值：

	> mean(height) 
	[1] 65
	
答案是 65，你会注意到答案之前的 `[1]`。它代表返回值的第一行，如果你的结果有用多项，那它就会一直往下现实，并标出对应的行数。

回到我们的例子。如果我们想求出体重的标准差（Standard Deviation），我们可以使用 `sd()` 函数：

	> sd(weight) 
	[1] 15.49869
	
现在我们想找出女性的体重是否和身高相关。这时，我们使用 `cor()` 函数，它会帮我们找出女性的体重和升高的区别：

	> cor(weight, height) 
	[1] 0.9954948
	
我们发现它们之间存在非常强的线性相关（linear correlation）；几乎 1 比 1 的关系。最后，我们可视化它们的相关性：

	> plot(weight, height)
	
它将通过散点图的方式为我们展示两个向量的之间的关系。

### 工作空间（Workspace）

工作空间(workspace)就是当前R的工作环境,它储存着所有用户定义的对象(向量、矩阵、函数、数据框、列表)。在一个R会话结束时,你可以将当前工作空间保存到一个镜像中,并在下次启动R时自动载入它。各种命令可
在R命令行中交互式地输入。使用上下方向键查看已输入命令的历史记录。命令的历史记录保存到文件`.Rhistory` 中,工作空间(包含向量x)保存到文件 `.RData` 中。
当前的工作目录(working directory)是R用来读取文件和保存结果的默认目录。我们可以使用函数 `getwd()` 来查看当前的工作目录,或使用函数 `setwd()` 设定当前的工作目录。如果需要读入一个不在当前工作目录下的文件,则需在调用语句中写明完整的路径。记得使用引号闭合这些目录名和文件名。

### 执行（Source）文件和运行命令

上一个章节的所有代码都可以输入到 R 交互终端上执行。如果你已经把所有的代码都写到文本中，你可能对讲代码剪切到终端上没有兴趣。我们将提供两种方法运行文件上的代码。

1. 打开 R 终端，并使用 `source()` 命令。

		$ R
		> source('path/to/file.R')
	
2. 使用 R 的批处理命令

		$ R CMD BATCH path/to/file.R
	
### 包（Packages）

一个 R 包是一个相关函数和帮助文档的合集。它和 Ruby 的 Gem 或者 C/C++ 库很类似。正常情况，一个单独包中的所有函数应该是相关的：例如 stats 的包只包含统计分析的函数。和 Ruby 一样，R 包也有自己的公共源：

1. CRAN（Comprehensive R Archive Network，http://cran.r-project.org）：目前最大的 R 综合资源网络，由 R 基金会所管理（同样也是 R 的主要开发者），目前拥有 5599 个包（2014-06-08），还在持续增长中；全世界拥有众多的镜像网站（国内拥有 cTex.com, 中国科技大学，北交大以及厦大）； 

2. Bioconductor（http://www.bioconductor.org），旨在提供生物信息学的 R 分析包。然而并不以为者他们不适用于其他分析领域。目前拥有包数量 824个（2014-06-08）；

3. R-Forge，一个用于R的协作开发环境。它基于 FusionForge，是 GForge（也是 RubyForge 的底层）的一个分支，目前拥有 1760 个项目。它不同于 Cran 和 Bioconductor 的是任何人都可以在 R-Froge 上设立项目，甚至不需要最终形成 R 包；

4. GitHub，这个就多介绍了，现在很多新的 R 包项目建立在 Github 上，这个得益于 RStudio 首席科学家 Hadley Wickham 的 devtools(它的项目地址：https://github.com/hadley/devtools)，允许我们通过它来安装建立在 github 上的 R 包。

#### **Package 的安装**

R 提供了几种安装方法：

1. 从 Cran 中安装：

    	> install.packages(
    	+    c("xts", "zoo"),    # 指定要安装的包
    	+    lib   = "some/other/folder/to/install/to",  # 指定安装位置
    	+    repos = "http://www.stats.bris.ac.uk/R/"    # 指定安装来源
    	+ )

2. 离线安装：

    	> install.packages(
    	+     "path/to/downloaded/file/xts_0.8-8.tar.gz",
    	+     repos = NULL, #NULL repo 代表已经下载
    	+     type = "source" # 直接安装
    	+ )

3. 从 Github 中安装（依赖 devtools）：
		
		＃ 安装 devtools
	    > install.packages("devtools")
		＃ 使用方法
	    > library(devtools)
	    > install_github("knitr", "yihui")

#### **Package 的使用**

你可以使用 `library` 函数载入你安装好的包：

    > library(package_name) ＃ 不用带引号

这个函数名让人感觉很怪异，如果叫 `load_package` 可能会更好理解，但是历史原因，很难改变了。我们可以把 package 当作 R 函数和数据集的集合，一个 library 用来保存这个 package 的文件。

注意，传入的包名是没有引号的，如果你的包名是字符型，应该这么处理：

    > library("package_name", character.only =TRUE)

如果你使用的包没有安装，则会抛出一个异常，有时你需要处理这个情况：

    > if (!require(noExistedPackage))
    + {
    +     warning("warn msg");
    + }

查看已经载入的包

    > search()
    [1] ".GlobalEnv"        "package:stats"     "package:graphics" 
    [4] "package:grDevices" "package:utils"     "package:datasets" 
    [7] "package:methods"   "Autoloads"         "package:base"   

查看安装的包：

    > installed.packages()

查看 R 公共库的默认安装路径：

    > R.home("library")
    # 或者
    > .library()
    [1] /path/to/r/3.0.2/R.framework/Versions/3.0/Resources/library

查看 R 用户库的安装路径：

    > path.expand("~")
    # 或者
    > Sys.getenv("HOME")
    [1] /home/xx-user/

查看所有库的路径，第一个是默认安装路径：

    > .libPaths()
    [1] /path/to/r/3.0.2/R.framework/Versions/3.0/Resources/library
    [2] /home/xx-user/

#### **维护**

    # 更新包
    > update.packages(ask = FALSE)
    # 删除包
    > remove.packages("packName");
    
    
> *Note*：Os X 报错 `fatal error: 'libintl.h' file not found` 的解决方案： 
>   $ brew intall gettext
>   
>   $ find ./ -name "libintl.*"
>   ./0.18.3.2/include/libintl.h
>   ./0.18.3.2/lib/libintl.8.dylib
>   ./0.18.3.2/lib/libintl.a
>   ./0.18.3.2/lib/libintl.dylib
>   ./0.18.3.2/share/gettext/intl/libintl.rc
>   $ ln -s /usr/local/Cellar/gettext/0.18.3.2/lib/libintl.* /usr/local/lib/
>   $ ln -s /usr/local/Cellar/gettext/0.18.3.2/include/libintl.h /usr/local/include/libintl.h

### 如何寻找帮助

R提供了大量的帮助功能,学会如何使用这些帮助文档可以在相当程度上助力你的编程工作。

                       help.start() | 入门帮助
                help("foo") or ?foo | 获取 foo 帮助
        help.search("foo") or ??foo | 搜索函数名带 foo 的帮助
                     example("foo") | 执行函数 foo 的用例，引号是可选的
                 RSiteSearch("foo") | 在线上文档或者邮件列表存档中搜索 foo
    apropos("foo", mode="function") |
                             data() | 列出所有的可用数据集
                         vignette() | 列出所有的可用事例
                    vignette("foo") | 列出主题foo的事例
