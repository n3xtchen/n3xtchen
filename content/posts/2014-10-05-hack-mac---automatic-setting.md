---
categories:
- osX
date: "2014-10-05T00:00:00Z"
description: ""
tags:
- osX
title: Mac 骇客指南 - 自动化配置
---

> 译自 [Hacker's Guide to Setting up Your Mac](http://lapwinglabs.com/blog/hacker-guide-to-setting-up-your-mac?utm_source=hackernewsletter&utm_medium=email&utm_term=fav)

骇客总是痴迷于自动化（Automation）。我们想要一个机器人帮我们完成繁重的工作，是的我们可以专注有趣的事情上。在自动化领域，自动化配置领域已经非常的成熟了！

几天我将要大家展示一些将自动化应用到 Mac 安装配置的技术。这篇文章的目的是实现 80 ％ 的自动化，让你在几个小时内完成新 Mac 的配置，而不是花上几天的时间。

### 我们的工具箱

这个博客使用如下开源工具来自动化配置你的 Mac：

+ 使用 Homebrew 安装源程序
+ 使用 Homebrew cask 安装应用
+ 使用 mackup 备份和还原配置
+ 使用 osx-for-hacker.sh 优化 Mac 的默认配置 
+ 使用 dots 将它们整合在一起

### 使用 Homebrew 安装源程序

Homebrew 是一个社区驱动的包安装工具，一个每一个黑客都需要拥有的工具。Homebrew 自动化了安装，编译和链接源代码。它也可以简化更新和卸载源程序。

首先你需要把它安装在你的新 mac 上。将下面的代码片段黏贴到 shell 脚本文件中，执行它来验证你是否安装了 homebrew：

	# 检查 Homebrew,
	# 如果没有，安装它
	if test ! $(which brew); then
	  echo "Installing homebrew..."
	  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
	
	# Update homebrew recipes
	brew update
	
然后，你需要做的就是更新你已经安装的 unix 工具。由于 shellshock 的 bash 漏洞，这一步是至关重要的。下面是更新 unix 工具的 shell 代码片段：

	# Install GNU core utilities (those that come with OS X are outdated)
	brew install coreutils
	
	# 安装 GNU `find`, `locate`, `updatedb`, and `xargs`, g-前缀
	brew install findutils
	
	# Install Bash 4（10.9 默认版本是 3.2）
	brew install bash
	
	# 更新 grep
	brew tap homebrew/dupes	# 添加新源
	brew install homebrew/dupes/grep
	
安装完，你需要更新环境变量 $PATH，使你刚才安装的工具生效：

	# ~/.bash_profile
	$PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
	
上述创建了 Mac 系统的基础。你也可以通过 Homebrew 安装其他工具来改善你的工作流。下面是 MATTHEW MUELLER 推荐的工具：

	binaries=(
	  graphicsmagick	# 各种图片处理
	  webkit2png		# 网页截屏
	  rename			# 重名名工具
	  zopfli			# 压缩工具，压缩比最高的算法
	  ffmpeg			# 视频工具
	  sshfs				# 文件系统远程挂载
	  trash				# 删除工具，rm 造成不可挽回的后果，trash 可以设置缓存目录
	  node				# nodejs
	  tree				# 展示文件树
	  ack				# grep 类的工具，性能更强劲，纯 perl 写的
	  hub				# git 工具的封装，添加更多人性化的功能
	  git				# 这个就不啰嗦了
	)
	echo "installing binaries..."
	brew install ${binaries[@]}
	
所有都安装完，你需要清理所有东西：

	brew cleanup
	
### 使用 Homebrew cask 安装应用

Homebrew Cask 是 Homebrew 的一个扩展，它帮助你自动安装 Mac 应用和字体。

装好 Homebrew 的前提下，你执行下面的命令来安装它：

    brew install caskroom/cask/brew-cask

Homebrew Cask 的应用库非常丰富，并且每天都在增长。你可以从它的官方源中查看可安装的应用，或者你可以通过下述命令搜索你要的应用：

    brew cask search /google-chrome/

对应用的需求因人而异，下面 MATTHEW MUELLER 推荐的应用：

    # Apps
    apps=(
        alfred          
        dropbox         
        google-chrome
        qlcolorcode # 代码高亮预览工具
        screenflick # 屏幕录制，限制键盘操作
        slack       # 企业沟通工具，不错
        transmit    # 远程传输工具，之一 xFTP, S3 等等，付费
        appcleaner  # 应用清理
        firefox
        hazel       # 文件按规则分类移到设定的目录，付费
        qlmarkdown  # 预览 markdown
        seil        # 将 caps lock 替换成其他键盘
        vagrant     # 虚拟机管理
        arq         # 云备份工具
        flash
        iterm2      # 强大的终端，支持分屏，
        qlprettypatch  #  快速查找和高亮文件内容
        shiori      # 书签和自动填单工具，支持 safari，chrome 和 firefox
        sublime-text3   # 最好用的编辑器之一，不是我的菜（vim 党）
        virtualbox  # 虚拟机工具
        atom        # 编辑工具的新秀
        flux        # 调整屏幕适应你的作息
        mailbox     
        qlstephen   # 识别和预览位置类型的文件
        sketch      # UI 设计工具
        tower       # 版本控制的管理工具（Git），付费
        vlc         # 跨平台视屏比方工具
        cloudup     # 流分享工具
        nvalt       # 快速笔记工具
        quicklook-json  # json 美化查看工具
        skype
        transmission    # 下载工具
        # 下面是我补充的
        filezilla   # 免费的远程传输工具
        sequel-pro  # mysql 客户端工具
        mou         # markdown 编辑工具
    )

    # Install apps to /Applications
    # Default is: /Users/$user/Applications
    echo "installing apps..."
    brew cask install --appdir="/Applications" ${apps[@]}

如果你你想安装测试版的应用。你需要添加版本源：

    brew tap caskroom/versions

#### 提醒下 Alfred 用户

如果你是 Alfred 用户，你可能需要注意下：你不能通过 Alfred 访问 cask 安装的应用，因为这些应用的安装位置并不是 `/Applications` 而是 `/opt/homebrew-cask/Caskroom/`。

你可以使用下面的命令来把这个路径添加到 Alfred 中：

    brew cask alfred link

#### 附赠：安装字体

Cask 页可以用来自动下载和安装字体。因此，你需要添加字体的 cask 源：

    brew tap caskroom/fonts

字体库都是以 font- 作为前缀的，因此如果你想要下载 Roboto 字体，可以使用如下命令：

    brew cask search /font-roboto/

这里是我安装字体的方法：

    # fonts
    fonts=(
            font-m-plus
            font-clear-sans
            font-roboto
          )

    # install fonts
    echo "installing fonts..."
    brew cask install ${fonts[@]}

你可以从[这里](https://github.com/caskroom/homebrew-fonts/tree/master/Casks)找到所有的字体库列表。

### Mackup

Mackup 是用户系统和应用配置的开源工具。你可以从[lra/mackup](https://github.com/caskroom/homebrew-cask/tree/master/Casks)查看它所支持的应用。

现在你可以使用 Homebrew 来安装 mackup：

    $ brew install mackup

> 你还可以使用 pip 来安装:
> 
>     $ pip install mackup
> 
> 如果 pip 不可用，你可能需要使用 brew 来安装 python，它默认集成 pip。

默认情况，mackup 将你的配置文件备份到你的 Dropbox 中，因此你需要实现安装 Dropbox。一旦你的 Dropbox 被安装，备份工作将会是非常简单的：

    mackup backup

这个命令将会匹配查找你安装的应用，并拷贝到 ~/Dropbox/Mackup 目录下。

通过下述命令还原你的配置到制定的 Mac 中：

    mackup restore

### 使用 osx-for-hacker.sh 修改 Mac 的默认配置 

[osx-for-hackers.sh](https://gist.github.com/brandonb927/3195465) 由 Brandon Brown 基于 Mathias Bynens 著名的 dotfile 修改的。

脚本作者的初衷是优化 Mac 的默认配置，禁用了一些不需要的配置，加速键盘反应和桌面效果。

但是有人反应使用完导致电池续航能力下降，禁用了某些文件的默认备份，可能会导致重要信息丢失。

介于对其中一些配置以及 Applescript 不是很熟悉，这里就不多加评论。执行前，务必实现对代码细节了解清楚。


### 使用 dots 将它们整合在一起

[dots](https://github.com/MatthewMueller/dots) 是将上述的所有操作配置整合到一块。dots 的开发者的想要把 dots 打造成 Mac 和 ubuntu 的初始化工具。它不对外部依赖，所以它能在很多分发版本中运行。使用下述命令安装：

    (mkdir -p /tmp/dots && cd /tmp/dots && curl -L# https://github.com/matthewmueller/dots/archive/master.tar.gz | tar zx --strip 1 && sh ./install.sh)
    dots boot osx

### 结语

通过自动化配置，你可以迅速让你的新 Mac 跑起来。请及时更新最新的补丁，降低与你工作伙伴的环境差异。





