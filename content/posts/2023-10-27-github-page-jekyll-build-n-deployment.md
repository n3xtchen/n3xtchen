---
title: Jekyll：GitHub Page 的本地环境搭建和部署
date: 2023-10-27T14:35:00+08:00
tags:
---
这一阵子，把我的 **Gihub Page** 迁移到 **Hugo**，但是总有点舍不得，决定写点东西重温一下。

看大家都在吐槽无非围绕 **Jekyll** *难部署*，*性能差* 以及 *主题和内容混淆* 等问题；作为十年的 **Jekyll** 用户，没有亲眼看见，不能以讹传讹。针对对这些问题，通过一系列博客，来洗白（也可能是证明） **Jekyll**；

这个系列的第一篇从部署维度来看看 **Jekyll**，先给个结论，==相比 **Hugo**，它确实没那么方便，但是说很难，就有点过了！== 所以，选择 **Hugo** 还是 **Jekyll**，都决定写博客，这个绝对难不倒你，更何况它不难！
## 一、Ruby 环境安装（rbenv）

==假设你已经安装了 **Bash**/**Zsh** 和 **Git** 命令行工具==
### 1. 安装和配置 rbenv 

**rbenv**： 安装特定 **Ruby** 版本的工具；
#### 安装 rbenv

从源码中安装：`git clone https://github.com/rbenv/rbenv.git ~/.rbenv`

如果你是 **Mac** 用户，你可以使用 `brew install rbenv`;

如果你是 **Debian**/**Ubuntu** 用户，你可以使用 `sudo apt-get install rbenv`

如果你是 **Red Hat** 系的 Linux **用户**，你可以使用 `sudo yum install rbenv`
#### 配置 rbenv

如果你是 **Bash** 用户，执行 `echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc

如果你使用时 **Zsh**，执行 `echo 'eval "$(~/.rbenv/bin/rbenv init - zsh)"' >> ~/.zshrc

==重启你的 Shell 或者 `source ~/.bashrc` （**ZSH** 下就是，`source ~/.zshrc`），就可以开始使用 rbenv 了！==

### 2. 安装 Ruby

```
$ rbenv install 3.1.3
To follow progress, use 'tail -f /var/folders/b7/ypb83z053wdb6jnt4rlllhq40000gn/T/ruby-build.20231027143205.94068.log' or pass --verbose
Downloading openssl-3.1.4.tar.gz...
-> https://dqw8nmjcqpjn7.cloudfront.net/840af5366ab9b522bde525826be3ef0fb0af81c6a9ebd84caa600fea1731eee3
Installing openssl-3.1.4...
Installed openssl-3.1.4 to /Users/nextchen/.rbenv/versions/3.1.3

Downloading ruby-3.1.3.tar.gz...
-> https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.3.tar.gz
Installing ruby-3.1.3...
ruby-build: using readline from homebrew
ruby-build: using libyaml from homebrew
ruby-build: using gmp from homebrew
Installed ruby-3.1.3 to /Users/nextchen/.rbenv/versions/3.1.3

$ rbenv local 3.13 # 在项目根目录下，将会生成 .ruby-version，用来记录你使用 ruby 版本
$ rbenv rehash     # 每次切换环境的时候都要，在当前环境切换到指定的 ruby 版本
```

检查你的 ruby 环境：

```
$ gem env
RubyGems Environment:
  - RUBYGEMS VERSION: 3.3.26
  - RUBY VERSION: 3.1.3 (2022-11-24 patchlevel 185) [arm64-darwin23]
  - INSTALLATION DIRECTORY: /Users/nextchen/.rbenv/versions/3.1.3/lib/ruby/gems/3.1.0
  - USER INSTALLATION DIRECTORY: /Users/nextchen/.gem/ruby/3.1.0
  - RUBY EXECUTABLE: /Users/nextchen/.rbenv/versions/3.1.3/bin/ruby
  - GIT EXECUTABLE: /opt/homebrew/bin/git
  - EXECUTABLE DIRECTORY: /Users/nextchen/.rbenv/versions/3.1.3/bin
  - SPEC CACHE DIRECTORY: /Users/nextchen/.gem/specs
  - SYSTEM CONFIGURATION DIRECTORY: /Users/nextchen/.rbenv/versions/3.1.3/etc
  - RUBYGEMS PLATFORMS:
     - ruby
     - arm64-darwin-23
  - GEM PATHS:
     - /Users/nextchen/.rbenv/versions/3.1.3/lib/ruby/gems/3.1.0
     - /Users/nextchen/.gem/ruby/3.1.0
  - GEM CONFIGURATION:
     - :update_sources => true
     - :verbose => true
     - :backtrace => false
     - :bulk_threshold => 1000
     - :sources => ["https://gems.ruby-china.com/"]
  - REMOTE SOURCES: 
     - https://gems.ruby-china.com/    # gem 源，你可以替换成本地速度比较快的源
  - SHELL PATH:
	  - ...你的系统path
```

### 3. 安装 Jekyll 工具

安装 **Jekyll** 的同时会预装 `minimal`(主题)，**CoffeeScript**（**Javascript** 的转译语言） 和 **Sass**（**Css** 的转译语言）

```
$ gem install jekyll
Fetching terminal-table-3.0.2.gem
Fetching safe_yaml-1.0.5.gem
Fetching rouge-4.2.0.gem
Fetching mercenary-0.4.0.gem
Fetching webrick-1.8.1.gem
Fetching unicode-display_width-2.5.0.gem
Fetching forwardable-extended-2.6.0.gem
Fetching pathutil-0.16.2.gem
Fetching liquid-4.0.4.gem
Fetching kramdown-2.4.0.gem
Fetching kramdown-parser-gfm-1.1.0.gem
Fetching ffi-1.16.3.gem
Fetching rb-inotify-0.10.1.gem
Fetching rb-fsevent-0.11.2.gem
Fetching listen-3.8.0.gem
Fetching jekyll-watch-2.2.1.gem
Fetching google-protobuf-3.24.4-arm64-darwin.gem
Fetching sass-embedded-1.69.5-arm64-darwin.gem
Fetching jekyll-sass-converter-3.0.0.gem
Fetching concurrent-ruby-1.2.2.gem
Fetching i18n-1.14.1.gem
Fetching http_parser.rb-0.8.0.gem
Fetching eventmachine-1.2.7.gem
Fetching em-websocket-0.5.3.gem
Fetching jekyll-4.3.2.gem
Fetching colorator-1.1.0.gem
Fetching public_suffix-5.0.3.gem
Fetching addressable-2.8.5.gem
...
Successfully installed jekyll-4.3.2
...
Installing ri documentation for jekyll-4.3.2
Done installing documentation for webrick, unicode-display_width, terminal-table, safe_yaml, rouge, forwardable-extended, pathutil, mercenary, liquid, kramdown, kramdown-parser-gfm, ffi, rb-inotify, rb-fsevent, listen, jekyll-watch, google-protobuf, sass-embedded, jekyll-sass-converter, concurrent-ruby, i18n, http_parser.rb, eventmachine, em-websocket, colorator, public_suffix, addressable, jekyll after 13 seconds
28 gems installed
```

## 二、Jekyll 站点初始化和配置[^1]

### 1. 初始化项目目录

==需要指定 --skip-bundle，因为我们要调整 Gem 配置和包！== 

```
$ jekyll new --skip-bundle .
New jekyll site installed in /private/tmp/x.
Bundle install skipped.  # 需要跳过，我们需要修改文件
```

目录结构如下：

```
.
├── .gitignore
├── 404.html
├── Gemfile
├── _config.yml
├── _posts              # 你博客编写的地方
│   └── 2023-11-01-welcome-to-jekyll.markdown
├── about.markdown
└── index.markdown
```

### 2. 配置 Gem 源，加速下载

修改你的 `Gemfile` ,配置更快的 Gem 源，如果你在国内（==用默认会很不稳定==），你可以配置成 `https://gems.ruby-china.com/`:

```
# source "https://rubygems.org"         ## 注释掉这行
source "https://gems.ruby-china.com/"   ## 修改源，加速依赖安装
...
```

### 3. 添加  webbrick（Ruby 3.0 以下，请跳过）

由于 **Ruby** 版本3及以上，不再默认安装 `webbrick` ，所以你需要手动安装它:

```sh
$ bundle add webrick
Fetching gem metadata from https://gems.ruby-china.com/...........
Resolving dependencies...
Resolving dependencies...
Resolving dependencies...
Resolving dependencies...
Resolving dependencies....
Resolving dependencies...
Fetching gem metadata from https://gems.ruby-china.com/.........
Resolving dependencies...
...
```

### 4. 项目依赖安装

```
$ bundle install
...
Bundle complete! 8 Gemfile dependencies, 94 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
```

如果出现如下警告,  `bundle add rubyzip --version "2.3.0"`:

```
Post-install message from rubyzip:
RubyZip 3.0 is coming!
**********************

The public API of some Rubyzip classes has been modernized to use named
parameters for optional arguments. Please check your usage of the
following classes:
  * `Zip::File`
  * `Zip::Entry`
  * `Zip::InputStream`
  * `Zip::OutputStream`

Please ensure that your Gemfiles and .gemspecs are suitably restrictive
to avoid an unexpected breakage when 3.0 is released (e.g. ~> 2.3.0).
See https://github.com/rubyzip/rubyzip for details. The Changelog also
lists other enhancements and bugfixes that have been implemented since
version 2.3.0.
```

#### 最终的目录结构和 Gemfile 配置

目录结构如下（==注意：Gemfile.lock 需要纳入版本控制==）：

```
$ tree
.
├── 404.html
├── Gemfile
├── Gemfile.lock
├── _config.yml
├── _posts
│   └── 2023-11-01-welcome-to-jekyll.markdown
├── about.markdown
└── index.markdown
```

`Gemfile`(`##` 是我添加的注释，注释的行都是有修改)如下：

```ruby
# source "https://rubygems.org"         ## 注释掉这行
source "https://gems.ruby-china.com/"   ## 修改源，加速依赖安装
# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
# gem "jekyll", "~> 4.3.2"             ## 注释掉，我们将使用 GitHub Pages
# This is the default theme for new Jekyll sites. You may change this to anything you like.
gem "minima", "~> 2.5"
# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
gem "github-pages", group: :jekyll_plugins    # 关闭注释，我们需要部署 GitHub Pages
# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]

gem 'rubyzip', '2.3.0'          # 新增
gem "webrick", "~> 1.8"         # 新增，解决 jekyll 无法启动问题
```

### 5. 启动 Jekyll

`--incremental` 表示文件内容变动就会自动编译

```
$ bundle exec jekyll serve --incremental
Configuration file: /private/tmp/x/_config.yml
To use retry middleware with Faraday v2.0+, install `faraday-retry` gem
            Source: /private/tmp/x
       Destination: /private/tmp/x/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
       Jekyll Feed: Generating feed for posts
                    done in 0.098 seconds.
 Auto-regeneration: enabled for '/private/tmp/x'
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```

> 问题：`Deprecation Warning: Using / for division outside of calc() is deprecated and will be removed in Dart Sass 2.0.0.` 
> 解决方法：`bundle add "jekyll-sass-converter" -v "~> 2.0"; bundle install;` 重新启动服务即可。

## 三、编写博客
#### 1. 博客文件名 
- 博客文件：`yyyy-mm-dd-{文件名}.markdown`
	- 例如模版给我们的 `2023-11-01-welcome-to-jekyll.markdown`；
- 文件名最好可以描述你博客缩写的关键词，因为他会作为 URL 链接
	- 上述例子对应的链接就是 `/2023/11/01/welcome-to-jekyll`
#### 2. 博客文件内容

他是 **Markdown** 文件，下面是例子：

```
---
layout: post                    # 博客页面的模版
title:  "Welcome to Jekyll!"    # 博客标题
date:   2023-11-01 19:09:20 +0800
categories: jekyll update       # 博客分类
---

正文部分
```

正文部分可以使用 Markdown 语法编写你的博客
#####  **Front-Matter**

被 `---` 包围住的内容，我们称之为 **Front-Matter**，他的编写格式符合 **Yaml** 规范：
-  `layout`、`title` 是必须的；
- `date` 是可选的，格式为 `YYYY-MM-DD HH:MM:SS +/-TTTT`，如果设置了，会代替文件名上时间，作为 URL 链接的一部分
- `categories`: 表示分类，如果设置了，会出现在 URL 链接，那上一个做例子，如果设置了，URL 链接就会变成 `/jekyll/update/2023/11/01/welcome-to-jekyll`
- `tags`：你还可以设置标签
## 四、部署到 github page 上

### 1. 创建 Github 代码库

创建一个 **Github** Repo，名叫 `<你的 blog 名称>`
### 2. 将你的代码提交 Github 中[^2]

```bash
cd <你的创建 jekyll>
git init .
git checkout --orphan gh-pages      # 你博客存放的分支，可以是任何分支，大家习惯用这个分支名
git add .              # 把你刚才生成和编写的内容提交上
git remote add origin https://github.com/<你的git用户名>/<你的blog名称>
git push -u origin gh-pages         # 将你的代码推送到 Github 中
```

### 3. 设置发布分支[^3]

1. 登陆 Githubt，访问 `https://github.com/<你的 Github 用户名>/<你的博客 Repo 名称>`；
2. 点击顶部导航栏的 `Settings`，进入左侧的导航栏 `Code and aution` 下的 `Page` 配置页面;
3. 定位 `Build and delpument` 下；
	1. 选中 `Source` 中的 `Deploy from a branch` ；
	2. 在 `Branch` 中选择你的博客所在的分区，这里我们选择 `gh-pages`；
4. 点击 `Save`

等待部署好，你可以提供通过 `<你的 Github 用户名>.github.io/<你的博客 Repo 名称>`

[^1]: [Testing your GitHub Pages site locally with Jekyll - GitHub Docs](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll)
[^2]: [Creating a GitHub Pages site - GitHub Docs](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site)
[^3]: [Configuring a publishing source for your GitHub Pages site - GitHub Docs](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)