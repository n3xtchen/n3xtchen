---
title: 终于我的 Gihub Page 从 Jekyll 迁移到 Hugo 
date: 2023-10-18T21:57:00+08:00
tags:
---

从 2013 年开始，我已经使用 **Jekyll** 十个年头了，当时对 **Ruby** 极其狂热，也是我选择他的原因，中间也换过一次主题，其实没什么不好，迁移的原因是因为 `hugo-obsidian` 用起来挺不错（虽然 Jekyll 也有类似，但是感觉不够丝滑），我可以使用无缝使用 Obsidian 编写我的博客。

想了太多，做的太少，琢磨小半年了，终于动起来，其实也不麻烦，前前后后从动手到完成也就花了 4～5天的时间。下面，
我分享下整个迁移过程、遇到的坑和相应解决方案。


## 一、创建站点

执行命令 `hugo new site n3xtchen`（n3xtchen 可以替换成你想要的任何名称，就是你 Hugo 项目的根目录），下面是产生的内容

```text
n3xtchen/
├── README.md
├── archetypes              # 文档模版，被 hugo new content 使用 
│   └── default.md
├── assets                  # 用于存储 图片/样式（css/sass）/javascript/typescript
├── hugo.toml               # 配置文件
├── content                 # 文档存储路径
├── data
├── i18n                    # 多语言支持
├── layouts
├── static                  # 该目录下的内容直接复制到 public 目录中
└── themes                  # 主题目录
```

## 二、安装主题（使用 hugo mod）

### 1. 初始化模块：

```
$ hugo mod init github.com/n3xtchen/n3xtchen
go: creating new go.mod: module github.com/n3xtchen/n3xtchen
go: to add module requirements and sums:
        go mod tidy
$ tree
.
├── ...
├── go.mod                # 产生的新文件
├── ...

```
> 实际底层是执行 `go init`

==注意：需要检查下 go.mod 中 go 的版本格式，必须是 xx.yy，在我的系统中，版本格式 `go 1.21.3`，那我就需要改成 `go 1.21`，因为我使用 github action 的 hugo(`peaceiris/actions-hugo@v2`)编译器不支持这种格式（xx.yy.zz） ==
### 2. 增加主题模块配置（我使用的主题是 blowfish）

```
$ mkdir config/_default
$ tee -a config/_default/module.toml <<END
[[imports]]
path = "github.com/nunocoracao/blowfish/v2"
END
$ tree
.
├── ...
├── config                # 产生的新文件
│   └── _default
│       └── modules.toml
├── ...
```

### 3. 下载主题

启动 hugo 服务，就会自动下载主题：

```
$ hugo server
go: no module dependencies to download
hugo: downloading modules …
go: added github.com/nunocoracao/blowfish/v2 v2.43.0   # 说明他在获取主题文件
hugo: collected modules in 11799 ms
Watching for changes in /Users/nextchen/Dev/project_pig/n3xtchen/{archetypes,assets,content,data,i18n,layouts,static}
Watching for config changes in /Users/nextchen/Dev/project_pig/n3xtchen/config/_default, /Users/nextchen/Dev/project_pig/n3xtchen/go.mod
Start building sites …
hugo v0.119.0-b84644c008e0dc2c4b67bd69cccf87a41a03937e+extended darwin/arm64 BuildDate=2023-09-24T15:20:17Z VendorInfo=brew


                   | EN
-------------------+-----
  Pages            |  7
  Paginator pages  |  0
  Non-page files   |  0
  Static files     |  8
  Processed images |  0
  Aliases          |  0
  Sitemaps         |  1
  Cleaned          |  0

Built in 29 ms
Environment: "development"
Serving pages from memory
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at //localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```

> hugo 模块的缓存目录下：`${缓存根目录}/modules/filecache/modules/pkg/mod/`
> 查看缓存 目录的方法：`hugo config | greo cache_dir`
> `blowfish` 的存储位置：`${hugo 模块的缓存目录}/github.com/nunocoracao/blowfish`

```text
$ tree
.
├── ...
├── .hugo_build.lock      # hugo 编译的锁文件
├── go.sum                # go 依赖模块的 hash 值 
├── ...
```

### 下载和复制主题相关的配置模版

- 删除默认配置：`rm hugo.toml`
- 复制 blowfish 的配置模版：
	- `cp ${hugo 模块的缓存目录}/github.com/nunocoracao/blowfish/v2@v2.43.0/config/_default/{config.toml,languages.en.toml,markup.toml,menus.en.toml,params.toml} config/_default/`
	-  ==注意不要覆盖：module.toml==
- 将 `config/_default/config.toml` 的主题设置成 github.com/nunocoracao/blowfish/v2 ，==如果使用 hugo module 安装主题的时候，这一步很重要，否者 gh-page 部署的时候，样式会丢失！

```text
$ tree
.
├── ...
├── config
│   └── _default
│       ├── config.toml          # 新增
│       ├── languages.en.toml    # 新增    
│       ├── markup.toml          # 新增
│       ├── menus.en.toml        # 新增
│       ├── module.toml          # 不能被覆盖
│       └── params.toml          # 新增
├── ...
├── hugo.toml                    # 该文件会被删除
├── ...
```

> 版本控制应该改忽略的文件：[Hugo.gitignore](https://github.com/github/gitignore/blob/main/community/Golang/Hugo.gitignore)


### 三、自定义主页和中文支持

#### 1. 增加中文支持

```
$ tee config/_default/languages.zh-CN.toml <<END
languageCode = "zh-CN"
languageName = "Simplified Chinese (China)"
weight = 1
title = "N3xtChen 的博客"      # 你博客的标题

[author]      # 添加作者信息
name = "n3xtchen"
image = "/images/author.jpg"  # 存储在 assets 下
headline = "和你分享有趣的技术！"
bio = "Sharing Funny Tech With You"
links = [
  { twitter = "https://twitter.com/mN3XT" },
  { github = "https://githhub.com/n3xtchen" }
]

[params]
  displayName = "CN"
  isoCode = "zh-cn"
  rtl = false
  dateFormat = "2006-01-02"
END
$ sed -i 's/\(defaultContentLanguage =\).*/\1 "zh-CN"/g' config/_default/config.toml
```
#### 2. 生成主页

首页增加 Banner

```
$ hugo new content _index.md
Content "/Users/nextchen/Dev/project_pig/n3xtchen/content/_index.md" created
$ tee -a content/_index.md <<END

{{< alert icon="rss" >}}
在这里，一同享受技术为我们带来无限乐趣！
{{< /alert >}}
END
```
#### 3. 定制主页

修改的功能：
- 首页展示近期的发表文章（5条）和显示更多文章链接
- 文章列表显示分类信息
- 文章内显示分类信息、目录和提供社交分享链接

具体修改如下（*config/_default/params.toml*）：
```
...
[homepage]
  ...
  showRecent = true      # 需要修改，打开，在主页显示近期发布的文章
  showRecentItems = 5
  showMoreLink = true.   # 需要修改，打开，在主页显示更多文章按钮
  showMoreLinkDest = "/posts"
  ...

[article]
  ...
  showTableOfContents = true        # 需要修改，显示文章目录        
  # showRelatedContent = false
  # relatedContentLimit = 3
  showTaxonomies = true             # 需要修改，显示分类和标签
  showAuthorsBadges = false
  showWordCount = true
  sharingLinks = [ "linkedin", "twitter", "reddit", "pinterest", "facebook", "email", "whatsapp", "telegram"]    # 需要修改，提供分享链接
...
```

#### 4. 定制网站图标

首先，将你制作好的图标保存到 `static` 中；
然后，在 `layouts/partials/` 创建 `favicons.html`，内容如下

```html
<link rel="icon" href="{{"favicon.png" | relURL}}" type="image/png">
```

#### 5. 定制菜单

在顶部菜单栏，增加博客、分类页和标签页入口

```
$ tee config/_default/menus.zh-CN.toml <<END
[[main]]
  name = "时间线"
  pageRef = "posts"
  weight = 10

[[main]]
  name = "分类"
  pageRef = "categories"
  weight = 20

[[main]]
  name = "标签"
  pageRef = "tags"
  weight = 30
END
```

这个时候，相应页面使用的默认模版，可以创建对应 section 页面来定制

```bash
hugo new content posts/_index.md          # 定制博客列表主页
hugo new content categories/_index.md     # 定制分类页主页
hugo new content tags/_index.md           # 定制标签页主页
```

### 四、Jekyll 迁移文档

#### 1. 将 Jekyll 的文档转化成 Hugo 格式
```
$ git checkout gh-pages
$ mkdir /tmp/jekyll_to_hugo
$ hugo import jekyll . /tmp/jekyll_to_hugo
$ cp /tmp/jekyll_to_hugo/content/{post,draft}/* content/posts/
```
#### 2. 保持和 Jekyll 一样链接格式（建议）

==如果你之前的文章被其他站点引用，或者你想保持原有的搜索排名，建议沿用之前的链接格式！==

功能如下（**jekyll** 的习惯）：
- 将文件名的日期作为 `date` 的值[^1]
- 链接格式：`/年/月/日/文件名`
	- 文件名：`2021-01-01-file_name`，对应的链接为：`/2021/01/01/file_name`

```
$ tee -a config/_default/config.toml <<END

[frontmatter]
  date = [':filename', ':default'] # 如果文件名有日期，读取文件名，否则读取 frontmatter 中的日期

[permalinks]
  posts = '/:year/:month/:day/:slug/' # slug 获取文件名时，忽略日期
END
```
#### 3. 去除 Jekyll-Bootstrap （可选）

==如果你使用了 JB，可以往下，否则跳过！==

我之前使用 **Bootstrap** 主题，所以文章主体头部都会加上 `{% include JB\/setup %}`，现在不需要了，所以需要去除，不然都会被展示出来

```bash
sed -i '' '/{% include JB\/setup %}/d' content/posts/*
```

#### 4. 增加 mathjax 支持（可选）[^3]

==如果你有需要公式渲染需求，可以往下，否则跳过！==

复制 **blowfish** 的 `head.html`，用于后续的修改

```bash
$ mkdir layouts/partials/
$ cp ${hugo 模块的缓存目录}/github.com/nunocoracao/blowfish/v2@v2.43.0/layouts/partials/head.html layouts/partials/
```

在 `layouts/partials` 下创建 `mathjax.html `实现 **Latex** 渲染功能，内容如下[^2]：

```html
<style>
code.has-jax {
-webkit-font-smoothing: antialiased;
background: inherit !important;
border: none !important;
font-size: 100%;
}
</style>

<script>
MathJax = {
  tex: {
	inlineMath: [['$', '$'], ['\\(', '\\)']],
	displayMath: [['$$','$$'], ['\\[', '\\]']],
	processEscapes: true,
	processEnvironments: true
  },
  options: {
	skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre']
  }
};

window.addEventListener('load', (event) => {
  document.querySelectorAll("mjx-container").forEach(function(x){
	x.parentElement.classList += 'has-jax'})
});
</script>
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
<script type="text/javascript" id="MathJax-script" async
							 src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
```

修改 `head.html`，让浏览器启动 **Mathjax** 渲染功能：

```html
<head>
...

{{/* 增加 mathjax3 支持 */}}
{{ if .Params.mathjax }}{{ partial "mathjax.html" }}{{ end }} # 新增的

</head>
```
 
在 `config/_default/params.toml` 打开配置

```
...
  
mathjax = true   # 新增的

[header]
...
```

##### 我这边仍然出现如下问题，需要通过修改文档才能解决：

1. ==当行公式会被识别成公式块==
	- 原因是 **Jekyll** 单行 **Latex** `$$x_i$$` 会被解析成 `\(x_i\)`，而在 **Hugo** 就不会自动转，所以需要修改成 `$x_i$`
	- 下面代码中是找出可能出现问题的文件: `grep -rnw '\$\$' content/posts`
2. ==`//` 不会换行==
	- 原因是 **Hugo** 转移 `/`，所以需要 `////` 替换他
## 五、部署到 github-page

创建 `.github/workflows/hugo-gh-page.yml`[^4],内容如下：

```yml
name: Hugo GitHub Pages

on:
  push:
    branches:
      - main            # 你 Hugo 项目所在的分支

jobs:
  build-deploy:
    runs-on: ubuntu-20.04
    concurrency:
      group: ${{ github.workflow }}-${{ github.ref }}
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          submodules: true
          fetch-depth: 0

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: "latest"

      - name: Build
        run: hugo --minify

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        if: ${{ github.ref == 'refs/heads/main' }} # 你 Hugo 项目所在的分支
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_branch: gh-pages          # 你配置的 github-page 的分支
          publish_dir: ./public
```

> github-page 分支的设置：[Configuring a publishing source for your GitHub Pages site - GitHub Docs](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)

[^1]: [Configure Hugo | Hugo-Configure dates](https://gohugo.io/getting-started/configuration/#configure-dates)
[^2]: [MathJax | Beautiful math in all browsers.](https://www.mathjax.org/#gettingstarted)
[^3]: [Render LaTeX math expressions in Hugo with MathJax 3 · Geoff Ruddock](https://geoffruddock.com/math-typesetting-in-hugo/)
[^4]: [Hosting & Deployment · Blowfish](https://blowfish.page/docs/hosting-deployment/)
