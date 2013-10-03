---
layout: post
title: "Javascript D3 - Starter"
description: ""
category: javascript
tags: [javascript, d3, beginner, lesson]
---
{% include JB/setup %}

### 什么是 *D3.js*

*D3.js* (D3或Data-Driven Documents）是一个用动态图形显示数据的**JavaScript**库，
一个数据可视化的工具。兼容**W3C**标准，并且利用广泛实现的**SVG**，**JavaScript**，
和**CSS**标准。)

### 安装 *D3.js*

#### 下载

    wget http://d3js.org/d3.v3.zip  # 当前的版本 v3

压缩包包含的文件：

    Archive:  d3.v3.zip
        inflating: LICENSE                 
        inflating: d3.v3.js                
        inflating: d3.v3.min.js 

#### 应用的基本目录结构

    ├── index.html
    └── lib
        ├── LICENSE
        ├── d3.v3.js
        └── d3.v3.min.js

#### **Html**模版

    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="utf-8">
            <title>D3 页面模版</title>
            <script type="text/javascript" src="lib/d3.v3.js"></script>
        </head>
        <body>
            <script type="text/javascript">
            // 漂亮的D3代码将会这里
            </script>
        </body>
    </html>

#### 设置网页服务器

有时，你可以在你的浏览器浏览本地的**HTML**文档。但是，一些浏览器考虑到安全问题
，限制通过 **javascript** 访问本地的文件。这意味这如果你的 *D3* 代码尝试从外部
数据文件（例如 CSV 或者 JSON）获取数据，它就会失败。这不是 *D3* 的错；这是浏览
器的特征，为了防止载入第三方不可信的网站的JS。

综上各种原因，通过网页服服务器加载你的页面将更可靠。

好消息就是让你的本地服务器运行起来非常简单。这里提供了一些方法：

##### 带 **Python** 的命令行(Terminal)

1. 打开你的命令行
2. 通过命令行，定位到你想要提供页面服务的目录（文件夹）。例如，如果你的项目文件
夹位于桌面，你可以输入： `cd ~/Desktop/app-dir`
3. 在终端中，键入 `python -m SimpleHTTPServer 8888 &`

这样，你就可以在 [http://127.0.0.1:8888](http://127.0.0.1:8888)

##### MAMP(Mac Os), WAMP(Windows) 和 LAMP(Linux)

针对你的系统，下载 **AMP** 服务器软件; 它包括 Apache（服务器软件）, MySQL（数据库
软件 和 PHP（网页脚本语言）。(详细参照 各自的安装文档)

### **Data**

笼统的说，数据就是既有某种潜在意义的结构化信息。

在视觉化编程的前提下，数据被存储在数字文件中，文本或者二进制格式。

在 *D3* 和基于浏览器的范畴下， 我们被强制使用用文本数据。如果你可以将你的数据存储
在 **.txt** 的文本格式，**.csv** 文件 或者 **.json** 文件， 那你就可以使用 *D3*。


无论你的数据长啥样，只有将它附着在某个东西上，它才有用处和可看性。用 *D3* 方言说，
它必须绑定在页面的一个元素上。首先让我们创建一个新页面元素。

#### 生成页面元素（Elements）

一般来说，当使用 *D3* 创建一个新的 **DOM** 元素，这个新元素可以是圆，方或者其它展示
你数据的可视化形式。为了避免迷惑，我么先从创建一个段落元素开始。我们将借助之前创建的
模版（`index.html`）开始。

替换 **Script** 标签中的注视：

    d3.select("body").append("p").text("新段落");

> 为了了解这一行代码，你得首先了解你新好朋友 - 链语法（Chain）。

> *D3* 聪明地引入了链语法（你可能已经在 *JQuery* 见过了）。使用点符号将方法串在一起，你可以在一行执行多个动作。

> 方法（method）和函数（funtion）是近义词：一串代码接受一个参数作为输入，执行一些动作，
然后返回一些其它信息作为输出。

然后保存并刷新页面。

**代码解释**：

> D3
> >  d3 对象，我们可以通过它访问它的方法。

> select("body")
> > 传递一个**CSS**选择器参数，它将要返回配的元素中的第一个索引。

> append("p")
> > 创建一个你指定的 **DOM** 元素，并追加到容器最后，返回新添加的元素索引。

> text("新段落")
> >  在选中的元素中插入一个字符串。

#### 绑定数据

数据视觉化就是将数据转化成视觉的过程。**Data in,visual properties out** 。可能更大的数
字创建更高的条栏，或者特定亮度的颜色。这个转化取决于你。没有绑定过程，我们将有一堆无数据，无映射的 **DOM** 元素。这个不是我们想要的。

##### 绑定（in the Bind）

我们使用 *D3* 的 `selection.data()` 方法来将数据和元素绑定在一起。但是首先我们需要两件
东西，在我们绑定数据之前：

+ 数据
+ 选中的元素

##### 数据

*D3* 能非常灵活地处理不同种类的数据，包括数组，字符串或者对象。它能操作 **JSON**，还有
内置的方法帮助你加载 **CSV** 文件。

当然，我们先从最简单的开始; 这里是一个数组：

    var dataset = [ 5, 10, 15, 20, 25];

###### 导入 **CSV** 文件

    # 这是一个 .stock-index.csv 文件
    000001,上证指数,2160.03,0.2,2155.81,2150.96,105401788,978.12,2165.78,2149.59
    000002,Ａ股指数,2261.05,0.19,2256.68,2251.67,104764745,973.53,2267.09,2250.17
    000003,Ｂ股指数,248.68,0.66,247.05,245.12,637043,4.59,249.88,244.3
    000016,上证50,1639.15,0.4,1632.7,1630.69,19965416,185.14,1641.01,1624.88
    000010,上证180,5186.44,0.36,5167.66,5160.28,42964812,432.02,5197.88,5149.49
    399005,中小板指,5164.75,0.34,5147.11,5150.72,11442920.79,157.57,5202.29,5133.2
    399106,深证综指,1043.74,0.37,1039.86,1039.97,83031484.89,962.02,1047.65,1039.95
    399107,深证Ａ指,1089.69,0.37,1085.66,1085.82,82808751.35,960.41,1093.83,1085.79
    399108,深证Ｂ指,826.03,0.59,821.2,818.57,222733.54,1.61,826.45,818.55
    000011,基金指数,3982.4,0.23,3973.09,3967.7,10235646,24.43,3985.39,3964.66

在 *D3* 中，我们可以这样加载：

    d3.csv("stock-index.csv", function(data) {
            console.log(data);
    });

`csv()` 需要传入两个参数：一个 **CSV** 文件路径，和一个匿名函数作为回调函数。

当调用的使用，匿名函数用来处理 **CSV** 的载入和解析过程后的结果；也就是数据。*D3* 会将
文件中的第一行数据作为属性名，剩下的部署是值。你可能不在乎这些，但是它确实为你省了很多
时间。

还有一件事情需要注意， **CSV** 中的每个值都将被存储成字符串，即使是数字。这可能造成不i
可预期的行为，如果你尝试索引你的数据作为数值，但是它是仍然是字符型。


> **处理数据加载错误**

> 注意，`d3.csv()` 是异步方法，意味着这部分代码将等待所有文件加载完之后才开始执行。（
`d3.json()` 也是相同的袁立)

> 这里可能潜在你觉得非常困惑的时候。当你认为 **CSV** 数据可用的使用，实际上还没完成加
载。防止这些意外发生，确保你只在回调函数中使用数据。

> 有些人可能喜欢声明一个全局变量，然后调用 `d3.csv()` 在回调函数在加载数据；在回调函数
中将数据赋值给这个全局变量（这样我可以在随后的函数使用它），最后我们可以调用任何呈现
这个数据的函数。例如：

>      var dataset;  //Global variable
     d3.csv("stock-index.csv", function(data) {
         dataset = data;    //Once loaded, copy to dataset.
         generateVis();     //Then call other functions that
         hideLoadingMsg();  //depend on data being present.
     });

> 更令人困惑的是，回调函数无论数据是否加载成功都将会被调用。事实就是，如果网络中断，文
件名拼写错误，或者任何由服务器端造成的错误，回调函数仍然会被执行。这种场景可能很少发生
，但是如果我们知道如何处理它将哼友帮助。

> 幸运的是，你可以回调函数定义中引入一个可选的 `error` 参数。如果加载文件时，错误将由
服务器端返回并赋给 `error` , 数据将会是 `null`。如果文件加载成功，将不会由错误，`error` 就会是 `null`，数组将会按预期被返回。注意 `error` 必须放在第一个参数，数据第二。

>      var dataset;
     d3.csv("stock-index.csv", function(error, data) {
        if (error)
            console.log(error);
        else
            console.log(data);
        dataset = data;    //Once loaded, copy to dataset.
        generateVis();     //Then call other functions that
        hideLoadingMsg();  //depend on data being present.
     });

还有一个提示：如果你使用 tab 分割的数据 **TSV** 文件，你可以使用 `tsv()`，用法相同

###### 导入 **JSON** 文件

我们可能在之后会更多谈论 **JSON**, 但是现在，你所有需要知道的就是 `d3.json()` 的用法和
`csv()` 一样。

    d3.json("stock.json", function(json) {
        console.log(josn);
    });

这里我们命名解析的输出的变量名为 `json`,但是你爱叫什么叫什么。

##### 选择元素

    var dataset = [5, 10, 15, 20, 35];

现在你想决定选择什么。换句话说，你想要你的数据与哪个元素关联？再一次，让我们保持超级简
单，我们想要使用 `dataset` 中的每个值创建一个新的段落。你可能幻想一些像这样的可能有用
：

    d3.select("body").selectAll("p")

你可能是对的，但是需要引起你注意的是：我们想要选择的段落还不存在。并且这是 `D3` 最为困
惑的一点是：我们如何选者不存在的的元素？

答案就是 `enter()`， 一个相当具有魔力的方法。看看如何使用它：

    d3.select("body").selectAll("p")
        .data(dataset)
        .enter()
        .append("p")
        .text("meow meow");

**代码解释**

> enter()
> > 为了创建一个新的与数据绑定的元素，你必须使用它。如果有更多的数据与元素关联，
`enter()`将魔术般地创建一个你能工作的占位符元素。然后你可以在链中操作这个占位符号元素
。

#### 使用你的数据

我们可以看到这些数据被载到页面中，并且把它绑定到新创建的元素中，但是我们怎么是用它？

    var dataset = [ 5, 10, 15, 20, 25];
    d3.select("body").selectAll("p")
        .data(dataset)
        .enter()
        .append("p")
        .text("meow meow");

让我们修改最后一行：

    .text(function(d) { return d; });

现在我们将在页面上看到每个段落的文本变成他们本身的数据了。

Whoa！我们可以使用我们的数据丰富每一段落的内容，这些都要感谢 `data()` 方法的魔术。

#### 超越文本

在研究 `D3` 的过程中，还有一些意思的东西，比如 `attr()` 和 `style()`，允许我们设置
**HTML** 属性和 **CSS** 属性。

例如：

    .style("color", "red");

    .style("color", function(d) {
            if (d > 15)
                return "red";
            else
                return black;
    });

### 数据和图表

我们继续我们简单数据集合：

    var dataset = [5, 10, 15, 20, 25];

#### 画 `div`s

我们可以使用来生成一个超级简单的柱状图。柱状图实际上就是方形，使用 `div` 很容易画一个
方形。

    <div style="display: inline-block;
                    width: 20px;
                    height: 75px;
                    background-color: teal;"></div> 

显示如下图：

<div style="display: inline-block; width: 20px; height: 75px; background-color: teal;">
</div> 

我们可以把样式抽离出来

    div.bar {
        display: inline-block;
        width: 20px;
        height: 75px;
        background-color: teal;
    }

##### 关于 **Classes**

注意一个元素的类作为一个 **HTML** 属性存储。类是用于关联 **CSS** 样式规则的。可能这会
对你造成一些迷惑，因为给元素设置一个类和直接给它应用一个样式存在一些不同。

这里简要简要的说明另一个 *D3* 的方法，`classed()`, 它用来快速的应用或者删除样式。

    .classed("bar", true) // 添加样式
    .classed("bar", false)    // 删除样式

##### 回到柱状图

我们现在可以使用数据，完成一个完整的 *D3* 的代码：

    var dataset = [5, 10, 15, 20, 25];
    d3.select("body").selectAll("div")
        .data(dataset)
        .enter()
        .append("div")
        .attr("class", "bar")
        .style("height", function(d) {
            return d + "px";
        });

现在，我们所谈论都有都是关于数据化 `divs`。让我们拓展到 **SVG**

#### **SVGs**

你需要注意的是，**SVG** 元素的属性（properties) 都是通过属性（attributes）指定的。换句
话说，每一个元素标签都包括属性/值对。

    <element property="value"></element>

##### 创建 

    var w   = 500;
    var h   = 50;
    var svg = d3.select("body").append('svg')
        .attr("width", 500)
        .attr("height", 50);

##### 数据驱动的形状

**圆型**

    var dataset = [5, 10, 15, 20, 25];
    var circle  = svg.selectAll("circle")
            .data(dataset)
            .enter()
            .append("circle");

    circle.attr("cx", function(d, i) {
            return (i*50)+25;
        })
        .attr("cy", h/2)
        .attr("r", function(d) {
            return d;
        })
        .attr("fill", "yellow")
        .attr("stroke", "orange")
        .attr("stroke-width", function(d) {
            return, d/2;
        });

记住，`selectAll()` 将会返回所有圆型（他们还不存在）的空索引；将数据绑定到我们将要创建
的元素中，`enter()` 返回新元素的占位符索引，最后添加 `circle` 索引到 **DOM** 中。

所有的圆型大批需要位置和尺寸。

    .attr("cx", function(d, i) {
            return (i*50)+25;
    })

为每个元素设置 `cx` 元素。（记住， **SVG** 属于中，`cx` 是圆心的 X 轴坐标）我们把数据
绑定到圆型元素，因此，d值就是我们绑定在该元素的数据。

还有一个参数，**i**，也是自然有的。（感谢 *D3*）和 d 一样，i 是本身就有的，无论你是否
想要，它都会被设置，它代表元素ID（或者计数，当前元素的索引值）。

因此，i是当前元素的索引。从0开始，所以我们第一个的圆的 i = 0；第二个 = 1；以此类推。

为了确定 i 在你定义的函数可用，你必须把它放在参数表中。你必须包含 d，即使你没有使用它
。因为他们与参数的名字无关，而是和参数的个数有关。

`cy` 是圆心的 y 坐标，`r` 是圆的半径。

##### 制作柱型图

现在我们可以整合我们之前学的东西，生成简单的 **SVG** 柱型图。

###### 旧的图表

    var dataset = [ 5, 10, 13, 19, 21, 25, 22, 18, 15, 13,
        11, 12, 15, 20, 18, 17, 16, 18, 23, 25 ];

    d3.select("body").selectAll("div")
    .data(dataset)
    .enter()
    .append("div")
    .attr("class", "bar")
    .style("height", function(d) {
        var barHeight = d * 5;
        return barHeight + "px";
    });

##### 新的图表


