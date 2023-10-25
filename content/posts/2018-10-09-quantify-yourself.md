---
date: "2018-10-09T00:00:00Z"
description: ""
tags: []
title: '量化你自己: （大部分）免费的工具和策略来追踪你生活中的（几乎）每一个角落'
---

是人都想要变得更好，做的更出色，不仅仅是在工作，还有在生活。

* 如何知道比上个月做的更好
* 自我感觉在特定领域有所改善，但是改善了多少？
* 到底花费了多少时间在偏离目标的事情上？
* 我的行为是否遵循我的优先级？

为了回答上面的问题，我从 2017 年开始我的自我追踪和持续改进之旅。

我知道手动跟踪所有内容会非常困难，而且生成对比实际变好的指标所花费的时间与我更相关。考虑到这一点，我寻找各种 App 和工具来帮助精简 “自我量化” 的任务。

结果是一系列追踪 APP 在我的生活背后中大量运转，收集数据来全面了解我的时间实际使用情况，而不是考虑怎么利用时间。

这篇文章将为你展示我所有用来追踪指标的应用，涵盖你如何使用它们来增加实际帮助优化自己和改善自己的洞见。这些实验都尝试与您的生活方式，小工具和目标产生共鸣。

**一个重要的编注**：我的标准之一就是仅仅使用免费应用，但是你应该牢记党你使用免费一些东西时，你本身也是个他们的产品（虽然这种情况经常发生在你付钱的时候）。注册这些应用之前，确保你不介意数据分享和隐私政策。我很乐意和这些公司分享数据，但是这是个人的选择。

### 全文通读或者跳到你感兴趣的章节

#### 你的阅读量

* 书籍
* 文章

#### 其他媒体的消费情况

* 音乐
* Podcast
* TV

#### 如何利用时间？

* 自动时间追踪
* 手动时间追踪

#### 把时间花在哪里？

* 地点

#### 你完成哪些任务以及完成情况？

* 任务
* 写作
* 程序

#### 是否关注你的身体健康？

* 步数
* 睡眠
* 饮食

#### 如何花钱？

* 收入和支出

#### 还有哪些你比较关心的指标？

* 自定义

#### 如何开始追踪和使用你的个人数据？

* 手机，聚合和分析你的数据
* 你从这些追踪数据中收获了什么？

### 阅读书籍

在过去的几年中，我发现音频书籍极大地提高了每年的阅读量。我使用 Goodreads 来追踪我读过的书以及什么时候读的。在阅读的时候，它会鼓励我多做笔记，以至于在读完的时候，我可以写一些正式的书评。它也是一种找新书的工具。

通过使用 Goodreads，我可以生成这样的报告

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_zD2GBw0T7wxzYV00jADRjQ.png)

这个报告可以看出我实际的阅读量，它改变了我的阅读习惯。（我强力推荐你使用它）Goodreads 也提供按年分类。

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_b5be3S4xTofQw6QFSfyOkQ.png)

年度报告帮助你理解你是否挑对书了。如果你的评分都不高，你就需要改变挑书的方式了。

我也可以通过阅读 review 来温习我看过的好内容。如果你不知道自己学了什么，那么阅读的意义在哪里呢？

### 阅读文章

如果你查询过我的 Goodreader 年报，你会发现我在 2016 年之前读书量很少。我为什么没有改善？但我知道我看内容的不少，只不过不是书籍，所以我决定我每个月阅读的文章量。

我的想法就是使用 todoist ——我任务管理的选择——追踪我的阅读清单。我尝试像这样：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_ueSBXdoIhXgfKv2l3doTUw.png)

它也可奏效，但是这个方法优三个缺陷：

1. 数据提取过程他过于手动化
2. 我不能把读一篇文章作为一个任务，我仅仅喜欢使用 Todoist 来做任务管理
3. 一些站点内容很好，但是糟糕的设计/阅读体验

我一个朋友推荐我使用 Pocket。它跨平台，可以作为稍后阅读的应用，解决的第二个问题。

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_UkQ7MNfTJOLxq3jfivJ8zw.png)

我也可以从网页中提取内容，使用新的界面阅读，你就可以根据你自己的需求进行定制化，解决了第三个问题。

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_lpnTYcsvq0krE78klyenqw.png)

但是仍然有一个问题没有解决。我没有找到一种好的应用从 Pocket 中提取数据，所以我只能自己来。

#### 开发者方案

我是一个码农，所以我可以根据自己的需求从 Pocket 到处的 HTML 文件中提取自己想要的结果。我只是下载他们的文件，然后执行下面的代码：

```javascript
var pocket = {"unread":1420,"unread_pct":4.79,"read":1020,"read_pct":1.18}
var uls=document.body.getElementsByTagName("ul");unread=uls[0].children.length,pocket.unread_pct=+(100*(1-pocket.unread/unread)).toFixed(2),pocket.unread=unread,read=uls[1].children.length,pocket.read_pct=+(100*(1-pocket.read/read)).toFixed(2),pocket.read=uls[1].children.length,console.log(JSON.stringify(pocket));
```

第一行就是三个月的结果：

```
{"unread":1420,"unread_pct":4.79,"read":1020,"read_pct":1.18}
```

这里，我有 1446 篇文章未读以及读了 1050 文章。增加的百分比是未读  +1.8% 和 读了 + 2.86%。这一个月，我读了 30 篇，就是从这个月已读的总数减去上个月的已读综述

#### 非开发者方案

我在这篇文章的时候，这个方法对很多人来说不可实现。于是，我想了另一个非开发的方案。多亏了我们的编辑 Becky，我构建了一个 IFTTT + Pocket 的原型。

我创建一个把 Pocket 管来呢到 Google Spreadsheets 的小应用。不幸的是，Pocket 没有提供完成时间的字段，因此，我使用标签来追踪我读文章所在的月份。这个展示结果如下：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_IuCZPj42pivCBECwMZglyw.png)

D 列就是这个文章加入到 Pocket 的时间。我决定保留它，以及我可以看到我收藏和阅读的时间。我每次读一篇文章的时候都要添加标签，这样做很不优雅，但是它有效。

现在，我们有一个表格，可以很方便地获取我们想要的数据。A 列就是我们月份标签，可以给文章排序和统计。我们还没有为这个数据添加图标，但是他们已经足够方便来跟踪我们的趋势。

### 音乐

我一般系统边听音乐，边工作。有时候，我使用它鼓励自己，有时让他帮助我集中精神。我使用 last.fm；它可以提供一个报表来展示我听过的音乐，以及听的时间。如果你想，你可以把歌和你高产时间进行关联。你可以手动，也可以使用像 Exist.io 这样的工具来进行自由数据聚合。

Last.fm 也会给你发送年报，而且很有用：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_CXghgp0nlyjw2sSAxhKMRw.png)

### Podcasts

我经常在不需要高度集中精神的时候（如洗盘子，遛狗等等），听 Podcasat（或者 音频书）。我已经使用 Podcast Addict 这款 Android 应用很多年了。它是免费的，但是我通过捐赠来去除广告，顺便贡献使他能成为更好的应用。如果你没有 Android 设备，你可以尝试 Pocket Cast，但是你需要为此花费 9 刀。

这两个应用都有提供统计功能。比如 Podcast Addict，你可以在 setting > stats 看到如下信息：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_4qzi-IICp6tgeNojmdFmyw.png)

不幸的是，这些数据不好提取。我要做年复盘的时候，我必须通过手工方式。通常情况，了解你的内容消费量以及在你的个人发展中贡献量，这个已经足够了。

### TV

我尽量避免随意看电视（随意意味着无目的：坐下来，不断转台来找），但是我还是会追一些剧。我会事先找好我喜欢的剧目，找时间和家人一起看。它同样要花费一些时间，所以我想要追踪它（在这里，你也可以看出一些模式）。

我使用 TV Time 来追踪我看过的电视节目。他仍然是需要手工处理——我必须记住打开应用，把它标记为看过——但是很快就形成习惯了。每当我看一集精彩的剧集时，我会在应用程序中看到有趣的梗，立即获得奖励。

当然，可以看到我的阅读/整体统计来看看我的长期奖励

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_xhlQHGWL9hqu0wy5aPzOaA.png)

追你喜欢的剧没问题，但是要记住，既然投入你的时间，要从中收获什么。问自己，值得吗？这取决于你的决定。妻子和我非常享受这些时间；当然所有的后期剧集分析和预测都很有趣。

从 TV Time 中唯一缺失的特征是电影追踪。出于这个目的，我决定使用 trakt.tv 来追踪。

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_SdEbKCrw9aVuuMYqJKWlvA.png)

如果能有一个应用能整合 trait.tv 和 tvtime，就好了，但是实际并没有。TV Time 是一款很棒的 Android 应用，但是不知电影。Trakt.tv 支持电影，但是你必须使用其他社区开发的应用来追踪和发送你的统计。所以目前为止，我同时使用他们。

### 时间追踪：自动化

使用自动追踪应用，你只要设置他，就可以不用管他们了。这个应用运行在后台，持续追踪你做的事情，使用了多少时间。这里，我使用 Rescue Time 来根据你的需求配置。

你可以定制，让应用记录你的电脑使用情况/或者它要监控哪些应用。例如，你可以高数 RescueTime 制追踪你使用 Excel 的时间，忽略所有你选择不记录的其他应用。

我使用它来追踪很多应用。我什么都不用做就可以自动获取我一天的时间使用情况：

![img](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_wL__oedxouzCEylYeSnqDQ.png)

我经常从这些报告中获取有价值的内容来帮助自己更好地利用时间。例如，我可以查看应用的分类，问自己是否合理地使用了这些时间。（我看过一本书《When: The Scientific Secrets of Perfect Timing》，书中让我懂得活动的时间那么重要）。随着时间的推移，我可以使用这些数据来优化我的日程，在我精力充沛的时候，安排尽可能多的事情。

### 时间追踪：手动

不幸的是，自动追踪只能到现在这个程度了。知道花了多少时间在邮件已经很好了，但是用了哪一个客户端？是在工作邮件还是个人邮件？同样问题也出现在其他应用中。手动时间追踪要求你操作，比如开始计时，选择分类——但是一旦你养成习惯，将会使你最小化时间。

对于手动时间追踪，我是 Toggl 的超级粉丝。他拥有友好的交互界面，易于使用，可以和很多应用整合（包括支持 Todoist），而且跨平台（包括 Linux）。

我为客户端，类别和项目创建了一个简化的 Toggl 系统，以便轻松提取我感兴趣的报告，同时最大限度地减少添加到我日常活动中的官僚作风。

我使用客户端的一些例子和他们的项目：

* Doist
* Shallow work
* Deep work
* Meeting
* Myself
* Health
* Finance
* PotHix
* Presentation

我根据日常工作、专业生活以及业余项目把报告分成 3 个大类。我追踪开会的时间，以便我后续评估是否值得。如果我发现时间没有很好的利用，我会和我的团队讨论，有规划得使每一个会议更加有用。

我决定在 Doist 下面维护一些项目，减少选择我正在进行的项目所需的认知负荷。在想要精准数据和避免让自我追踪占用太多时间之间需要做一个权衡。

当我只关注一个任务的时候，我进入深度工作状态，他不会让我分心——把手机、社交软件等等关掉。（拿编程做个例子）和我不需要很集中精神使使用浅度工作（相关的软件就是 Twist，我们的团队异步通行应用，做项目管理等等）。

（如果你不知道深度工作和浅度工作的概念，我推荐你读一读 Cal Newport - 《Deep Work》。）

我 99.99% 的时间在远程工作。Toggl 追踪时间帮助我了解我是否停滞了或者有更多工作要做。我尝试 Doist 在工作日使用 8 个小时。追踪那些时间使用更有意识地计划我的一天，聪明地工作来确保我可以把每一个事情都完成。

![](https://cdn-images-1.medium.com/max/1600/1_UPFxSrtTMFobaWOEQjNfhQ.png)

记住：手动追踪很费时费力，你不可能追踪每一个时间。尽可能追踪必要的事情！

### 接下来

我现在有时候会记录我的位置。我是 Google Latitude 的用户，直到他下线，现在我使用 Google timeline。我不经常在社交网络或者其他地方分享我的位置坐标，但是记录我的位置坐标还是有用的。

每个月，Google 会发送一条我地理位置的简报：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_AMiZ_jLT_88YCg2djotywg.png)

在我还在上班的时候，在交通工具上花费的时间用来理解我的通勤时间也是极好的。远程工作之后，看到我在交通工具上使用时间也是不错的。

我不能提取很多信息来关联我的地理数据，但是能可以看到我过去访问过哪些地方，也是挺好的，尤其当我在旅游的时候。

#### 任务

虽然可能看起来有点偏颇，但在我的印象中，我几乎从一开始就是Todoist用户——准确说 2007年——10年后，我到 doist 工作。

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_MZ9NPRUEzO1uFhrGOgVc1A.png)

我申请 API 和整合开发工程的职务的原因，很多出于我喜欢这个产品，认同公司的价值。在过去十年中，我使用了很多任务列表应用，最终我决定回到 Todoist，因为它有我所有想要的功能。

Todoist 有一个有效的视角，在那里， 你能看到你在某个时间点完成某些事情的高级统计报表。我不是坚持日常任务目标的超级粉丝。（虽然如果你愿意，你可以改变它们，让它更容易，或者如果你愿意，可以更多挑战自己），但是我真心喜欢在每个月看到周视角的大图：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_HTByqqMzNya4bYzqzjmrbQ.png)

这个报告展示了我如何按找拆解我的任务。红色条状是我的私人任务，蓝色的是工作任务。在我的日常中，时常有很多细小的个人任务，我的工作任务则是很大块，需要深度工作。为了使这个视图更有用，你得为你要追踪的工作分类选择不同颜色，便于查看。

这样的报道加上 Toggl 和 RescueTime 提供的报告，让我想知道我是否花了太多时间阅读我的 Twist 线程。

我是一个早上的人，我本应该花更多时间在做深度工作的时候，我却常常在读 Twist（一种团队协作工具）。计划是在早上浏览我的 twisted 帖子并将我需要跟进的对话直接从应用程序转换为Todoist任务，以便我可以在下午处理它们。（让 twist 的未读数量为0 会让我好受点，我可以在Todoist中更好地开展后续工作）。

有了这些数据，我可以根据以前没有注意到的趋势得出一些结论。

另外值得称道的是 Todoist 的年报（在每年的一月份发出，这么做不仅仅为了娱乐，其中也暗含一些有用的个人洞见）：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_w2uOlGefPYDevkMaMcRNgQ.png)

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_RUuOKy3dxKxyqP0VTuV3sA.png)

#### 身体和健康

这个目录有很多可用的追踪器。，他们中大部分都可以附带可穿戴设别，当然需要额外的付费，他们追踪各种各样的东西。你可以购买他们，当然你也可以保持简单，使用免费或者最少花费的部分。

##### 步数

当然，我知道步数不是衡量健康状况的好指标，但是走路确实有益健康。如果你，比方我，关心每天走了多少步，Google Fit 将会是不错的选择。

Google Fit 追踪步数，距离以及猜测你正在进行体育运动类型（最后一项，现在看来不是很准确）。其实很简单；你只要安装它，然后随身携带你的手机即可（这不是废话吗？）。

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_1hLF92nlP5pl8xqL3ajwSw.png)

以我为例，我使用 30 刀的腕带来帮助我追踪我的步数，它还可以追踪我的睡眠。

##### 睡眠

现在手机应用都可以用来追踪你的睡眠，但是，个人不喜欢在睡觉的时候，离手机太近了。出于这个原因，我决定买一个腕带来追踪我的睡眠模式，而且还能让步数统计更准确。

你可以买到各种各样的智能腕带，价格从几十刀到几百刀不等。我选择了一个不是很贵，而且可以满足的需求——小米手环2——但是可能大部分腕带可能都能满足我的需求。至于要不要全天带在手腕，这就是你自己的选择。

下面的图就是我从 MiFit 获取的睡眠报告：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_h_7jFJJ0c7-o1B-SyQvplQ.png)

这里可以看到按天、周、月维度看我的睡眠时间。上面的截图还是相当好用的，因为我不仅可以看到我的睡眠时间，还可以看出我的睡眠质量。深紫色就是展示我的深度睡眠。

从这些报告中，我可以分析我每次的数据，来评估是否足够好了，还是我应该改变一下自己的日常来改善我的睡眠时间/质量。截屏上的一个好例子就是我的平均睡眠时间：< 7 小时就是不好的，因此我将提出一个计划来帮助我在下个月改善。

##### 饮食

我发现用来追踪饮食和锻炼的最好应用是 MyFitnessPal。他们的饮食数据是无比的。我追踪我的日常摄入的食物和锻炼，但有时没有坚持做。我在节食过程中做过这种跟踪，体验非常出色。

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_ZGbGhCCQSJBwDMJaaT8TjA.png)

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_lApGxBqSZFffzfZACIn78A.png)

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_t-39BCkCAirvmoQW8MY50A.png)

追踪你摄入的食物是很难的，因为它一个纯手工的过程，但是如果你遵循某种饮食习惯，结果是很有价值的。但是，可以偶尔追踪下一周，提供一个数据点，看啊看你是否进行正确的饮食习惯，从种类上和量上。

#### 财务状况

钱是我要追踪的最重要内容中的一种。我已经坚持好多年了。请记住财务追踪和控制支出不是同一个东西。你可以不改变生活的习惯，就能追踪你的财务情况。最棒的是，你可以查看你的收支，以及他们是否使你的生活更有价值。你也查看自己的以往的花费数据，来决定你能否支付一项大额支出——比如房产或者长途旅游。

我使用本地应用，连接我的银行来获取我的支出。他们通过连接到你信用卡公司，来使用你的数据。如果你可以接受，它将是一个简洁的工具，把你在追踪花费分类下节省大量的时间，但是它是用一个国家，他们不是以英语作为本地语言。

在这个应用中，我可以生成下面这张图，展示每一个类的占比（如娱乐，家庭，以及旅游等等。）：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_rgGzTNTs79VhiBzg9RQ_pw.png)

与其推荐一款大家都不能用应用，我建议大家使用 YNAB（你需要一个预算的简称）。它们有自己的一套独特财务管理哲学和系统，但是也包含了我要使用的特征：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_w8Aaioi9tPkqqGrAWT03NA.png)

YNAB 的最大问题是需要付费，因此，它是否值得你投资。Mint 和 Clarity Money 也是一个不错的免费备选方案，但是没有相关的使用经验。

#### 写作

你知道你每个月写了多少字吗？当你用英文写作时，你犯了多少错吗？Grammarly 可以帮助你解答这些问题。

如果你非英文母语，我强烈推荐它。它能识别不被注意常见的错误（比如介词）。

Grammarly 每个月会发送一个简报，告诉你上一个月的统计数据：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_4aItbRCl8w77mumKJntOWg.png)

不幸的是，Grammarly 只提供的这个简报，于是我做了一些手动提取工作来创建一个表格：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_4NG8C1XZe7XiZEoZFYxoXA.png)

能看出写作字数的增长，是不是很棒？

当然，你可以挑战每个月的字数目标。

#### 代码追踪

这个章节适用于平时有写代码需求的人。如果你想要追踪你每天在写代码的时间，使用的语言/编辑器，我强烈推荐使用 Wakatime。

我在我的 now 页面（基于 Derek Siver now page）使用它们内置的图表。我最喜欢的图表之一就是我的语言突破：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_JVPaQAsDrPSsHU4IzJ9vvQ.png)

为了让他奏效，你必须在你的 IDE/文本编辑器中安装它，但是这个没什么难度。

#### 你自定义的指标

有时你想要追踪一些特定的指标，但是没有 apps 提供这个功能。在这种场景下，你需要回到 Google Spreadsheets 来构建你的自己指标。举个例子，我设置了一个目标，一年做 20 次公共演讲，然后按月来追踪进度。

下面的图就是我去年最终图表：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_1I95hRmvvDOeLvzyryq93A.png)

我能够知道哪些地方和我的计划相关，将会是很棒的事情。你可以看到事情的转变，在四月的时候，我看到我在我计划内。

你可以为了任何一个指标，创建一个 “goal vs actual" 曲线——读书，发布的文章，跑的里程以及收入等等。Lucid Chart 有一个很棒的新手引导，帮助快速学会使用它。

如果你使用 Google Sheet 追踪你想关注的一个或两个目标，可视化进度的额外冬季将值得你手动操作。（向 Todoist 添加每周或每月定期任务可能会有所帮助，以提醒您时刻跟进它。）

如果你不想提供数据给第三方公司，电子表格软件将会是很棒的工具，追踪任何我想要覆盖到的事情。你可以使用 Google Spreadsheets，Excel 或者 OpenOffice Calc 来创建你自己报表系统。但是要记住创建和维护这样的追踪系统需要花一些时间和努力，所以如果你不介意安装写软件来追踪的话，是一个不错的选择。

### 如何开展数据收集和分析？

我趋于最便宜，最强定制化的追踪配置，但是有时花点钱让一些事情更好的落地。让我们评估下免费和付费方式来汇总你的数据。

#### 免费

你不用同时使用所有的这些应用或策略。如果你想要开始自己收集数据，你可以挑选一个应用/策略，应用到你生活的一个特定领域。

例如，你应该开始使用 RescueTime。它不需要日常手动输入（只需要在开始的时候，进行一些分类配置），你就可以在几周之后看到一些有趣的模式。

#### 付费

如果你开始使用应用开始追踪的你数据，为一些有用的服务付费，我将会推荐尝试下 Exist.io。它是一个付费服务，但是你可以免费试用 30 天，如果你是被推荐的，就可以试用 60 天。如果你想要试用 2 个月，我可以提供给你我的推荐链接。

你可以把它但做一种个人仪表盘，整合所有的数据，容易使用和分析。这款应用通过链接你的日常使用来引导你：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_pI--4OkhWmM69PBCO4CzPg.png)

你很快就能看到像下面这样的报表：

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_K5z__v5HAohLhGfq8DGGcA.png)

为了以你的数据为中心，应用允许你为每一天添加自动标签，它会自动分拆出有趣的洞见——比如生产和锻炼的相关性，甚至体重和位置相关性。它也能根据现在的平均水平来设置个人目标，甚至内置情绪追踪（这个指引没有涵盖这个内容）。

![](https://n3xt-f0t0.oss-cn-shenzhen.aliyuncs.com/blog/quantify-yourself/1_Nh41HMRPgbchPOPsuasG3w.png)

它一个很棒的服务，很棒的公司。

### 从这些追踪数据中收获了什么？

一句话，可以持续改善。好的习惯很难形成。坏的习惯也很难打破。如果没有意识的提升到生活中，就很难做到这两件事。

追踪你的数据可以真实的展示你平时时间使用情况（而不是你考虑如何利用时间）。不是对逝去的时间的责备或内疚。它是一种通知模式，并为你下个月改善作出有意识的决定。它给你变得更好的机会——而不是你看起来像什么。

以有形，可衡量的方式将您的生活与您的价值观和优先事项保持一致，这也感觉很好。

这里是我常规检查我的指标之后归纳我所能改善的点：

* 检查我是否符合四月预期的前提下，改善我演示文档的外观
* 改变我选书的方式，因为我读过书的评分普遍比较低
* 我需要改变的工作方式，因为我不能聚焦我想做的事情
* 停止在日常时间阅读我的 newsfeed，因为已经加了很多文件到 Pocket 中，都没有读
* 减少听播客的时间。使用有声读物来替代，因为它对我的生活注入更多的价值
* 增加一个预警提醒我是否每天使用 Telegram 超过 30 分钟
* 追踪每天我花在工作上的时间。我通过加入硬性指标，来聚焦我完成的事情和更智能的工作。通过这些，来平衡我的工作和生活

这些改变已经为我的生活注入的大量的价值。你可能得到同样的结论。就像大家说的，从来都没有全栈解决的方案。你可以从这里读到所有生活和工作的建议，但是最终，每个人都是不一样的。汇总你自己的数据让它根据你的想法来优化你的生活。你可能永远都不能达到你的理想状态（这是多么遗憾的一件事情），但是你可以沿着这条路需有改善它。