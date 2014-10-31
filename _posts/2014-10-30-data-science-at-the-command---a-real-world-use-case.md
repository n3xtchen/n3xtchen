---
layout: post
title: "Data Science at the Commandline - 如何使用命令行进行数据分析"
description: ""
category: data_analytics
tags: [bash, data_analytics]
---
{% include JB/setup %}

《Data Science at the Commandline》中使用了命令行进行数据分析。我利用书中的例子给大家演示下如何使用 **Commandline** 进行数据分析的。不过，首先你需要有一台 **Unix/Linux** 机子，如果你使用的 Windows，那请安装 **Linux** 虚拟机。由于本文使用的数据需要在墙外（你懂得），这里同样也提供他的使用的[样本数据](https://github.com/jeroenjanssens/data-science-at-the-command-line/archive/master.zip) 。那开始进入主题：

每年的纽约时装周（*Fashion Week in New York*）总是令人惊讶不已。因此我们以此为例子，我们将讨论如何使用纽约时报（*The New York Times*）的开放接口获取 **Fashion Week** 的信息。首先，你需要在 **The New York Times** 的[开发者平台注册账户](http://developer.nytimes.com)（墙外，请自找梯子），获取你自己的 **API keys**；这样你才可以检索文章，获取畅销和重大事件列表。

我们将使用文章检索（Article Search API）的 **API**。我使用 **The New York Times Fashion Week** 作为检索词来查询是否有举办时装周。**API** 返回的结果数据是分页的，这意味着我们需要执行多次同样的查询（只是指定的页数不同，就像在搜索引擎点击下一页那样）。我们要使用 `parallel` 命令来轮询这些页数。具体命令见下方（不用纠结于弄懂命令的素有参数，我们只要了解我们使用的），现在打开你的命令行：

	$ cd /你下载的/文件解压的路径//book/ch01/data/
	$ parallel -j1 --progress --delay 0.1 --results results "curl -sL " \
		"'http://api.nytimes.com/svc/search/v2/articlesearch.json?q=New+York+'"\
		"'Fashion+Week&begin_date={1}0101&end_date={1}1231&page={2}&api-key='"\
		"'<your-api-key>'" ::: {2009..2014} ::: {0..99} > /dev/null
		
命令详解：

首先把他们拆成两个命令：

1. 获取接口数据命令

    `cUrl`，用途：从具体的 **URL** 链接中下载数据
	
		curl -sL "http://api.nytimes.com/svc/search/v2/articlesearch.json" \
		    "?q=New+York+Fashion+Week&begin_date={1}0101&end_date={1}1231" \
		    "&page={2}&api-key='<your-api-key>'"
		
2. 批处理操作（`parallel`）

		parallel -j1 --progress --delay 0.1 --results results \
		    "实际请求的命令" ::: {2009..2014} ::: {0..99} > /dev/null
	
	+ `-j1`：限定 job 数为 1
	+ `--progress`：现实进度条
	+ `--delay 0.1`：每个命令间隔 0.1 s
	+ `--result results`：结果文件的前缀
	+ `::: {2009..2014} ::: {0..99}`，这个命令每次生成一个组数据传入到上一个命令；你可能注意到了 `begin_date={1}0101&end_date={1}1231&page={2}`，这里的 `{1}` 就是知道 `::: {2009..2014}` 每次产生的数字替换它，以此类推，`{2}` 也是一样的，命令类似如下：
		
		for x in {2009..2014} 
		do
			for x in {0..99} do
				curl -sL "http://api.nytimes.com/svc/search/v2/articlesearch.json" \
		"?q=New+York+Fashion+Week&begin_date=${x}0101&end_date=${x}1231&page=${y}" \
		"&api-key='<your-api-key>'" > results/1/x/2/y/stdout 2> results/1/x/2/y/stderr
				sleep 0.1
			done 
		done		
	
我们执行多个相同的查询来获取 2009 年到 2014 年的数据。接口只允许获取 100 页的星系，因此我们使用 `brace expansion`（花括号扩展，例子上是 `{2009..2014}`，`{0..99}` ）来生成 100 个数字。因为接口有明确的限制，我们必须确保一次一个请求，间隔 1 秒。并且确认你申请的 **API Key** 替换 `<your-api-key>`。

每一个请求返回十篇文章，因此总共 1000 篇。这些信息是根据信息访问量来排序的，因此它能给我们一个很好新闻报道样本。这个结果存储字啊 **JSON** 中，我们把它存储在 **results** 目录中。我们可以使用 **tree** 命令来查看该目录结构：

	$ tree results | head 
	results
      	└── 1
      		├── 2009
      		│   └── 2
      		│   ├── 0
      		│   │ ├── stderr
      		│   │ └── stdout
      		│   ├── 1
      		│   │ ├── stderr
      		│   │ └── stdout

接下来，我们可使用 `cat`，`jq` 和 `json2csv` 命令来合并和处理结果数据：

	cat results/1/*/2/*/stdout |
      	jq -c '.response.docs[] | {date: .pub_date, type: .document_type, '\
      	'title: .headline.main }' | json2csv -p -k date,type,title > fashion.csv

现在开始拆解命令：

1. 我们把多个结果文件合并到起来输出给另一个命令

  		cat results/1/*/2/*/stdout

2. 我们使用 `jq` 提取发布日期，文档类型已经文章标题

        jq -c '.response.docs[] | {date: .pub_date, '\
            'type: .document_type, title: .headline.main }'

3. 我们使用 `json2csv` 将 **JSON** 转换成 **CSV**，并保存到 `fashion.csv` 文件中。

		json2csv -p -k date,type,title > fashion.csv
		
使用 `wc -l`，我们可以查出总共有 4,855 篇报道：

	$ wc -l fashion.csv
	4856 fashion.csv
	
让我们审查喜爱前十篇报道，来验证我们是否成功获取数据。为了只保留日志，我们使用 `cols` 和 `csvcut`（书中作者写的是 `cut` 命令，我查看了命令的源码中得出的这个结论） 把时间和时区去掉：

	$ < fashion.csv cols -c date cut -dT -f1 | head | csvlook 
	|-------------+------------+-----------------------------------------| 
	| date        | type       | title                                   | 
	|-------------+------------+-----------------------------------------| 
	| 2009-02-15  | multimedia | Michael Kors                            | 
	| 2009-02-20  | multimedia | Recap: Fall Fashion Week, New York      | 
	| 2009-09-17  | multimedia | UrbanEye: Backstage at Marc Jacobs      | 
	| 2009-02-16  | multimedia | Bill Cunningham on N.Y. Fashion Week    | 
	| 2009-02-12  | multimedia | Alexander Wang                          | 
	| 2009-09-17  | multimedia | Fashion Week Spring 2010                | 
	| 2009-09-11  | multimedia | Of Color | Diversity Beyond the Runway  | 
	| 2009-09-14  | multimedia | A Designer Reinvents Himself            | 
	| 2009-09-12  | multimedia | On the Street | Catwalk                 | 
	|-------------+------------+-----------------------------------------|

似乎它已经成功了。为了深入了解它（insight），我们最好进行可视化。我们使用 R 的 `ggplot` 和 `rio`来创建一个线型图。

	$ < fashion.csv Rio -ge 'g + ' \
        'geom_freqpoly(aes(as.Date(date), color=type), ' \ 
	    'binwidth=7) + scale_x_date() + ' \
        'labs(x="date", title="Coverage of New York' \ 
	    'Fashion Week in New York Times")' | display

![image]({{ site.production_url }}/assets/fashion.png)	

这样就可以看出 **New York Fashion Week** 一年举办两次，而且可以很清晰的看出，一次在 2 月份，一次在 8 月份。我们希望也在相同的时间点举办，我们就可以事先准备了。

