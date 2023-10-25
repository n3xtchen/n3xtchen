---
categories:
- Flink
date: "2019-02-17T11:15:37Z"
draft: true
tags:
- streaming
title: '深挖 Flink: WordCount 执行过程'
---

## 1. 环境：

- macOS: 10.14.3-x86_64
- Java: 1.8.0_131, 1.7.0_80

## 2. 测试环境搭建

### 2.1.1. 使用 Flink 官方的的初始化脚本创建项目

    ichexw@heygeeks:~/hello-flink  $ bash <(curl https://flink.apache.org/q/sbt-quickstart.sh)
	  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
	                                 Dload  Upload   Total   Spent    Left  Speed
	100 11509  100 11509    0     0  10696      0  0:00:01  0:00:01 --:--:-- 10706
	This script creates a Flink project using Scala and SBT.
	
	Project name (Flink Project): hello-flink # 项目名，也是你的项目目录名
	Organization (org.example): org.heygeeks  # 你的组织机构
	Version (0.1-SNAPSHOT): # 版本
	Scala version (2.12.7): # scala 2.12.7
	Flink version (1.7.0):  # 1.7.0
	
	-----------------------------------------------
	Project Name: hello-flink
	Organization: org.heygeeks
	Version: 0.1-SNAPSHOT
	Scala version: 2.12.7
	Flink version: 1.7.0
	-----------------------------------------------
	Create Project? (Y/n): y
	Creating Flink project under hello-flink

查看下目录结构：

<img src="http://p.aybe.me/blog/conda-download.png?x-oss-process=image/resize,w_920" width="100%" />

### 安装 sbt

从 [sbt 官网](https://www.scala-sbt.org/download.html "sbt url") 下载 sbt 包，解压到项目中：

    $ wget https://piccolo.link/sbt-1.2.8.tgz
    $ tar zxvf sbt-0.13.13.tgz
    $ mv sbt-launcher-packaging-0.13.13 sbt 

安装完，你可以下载的包删除，或者备份到其他地方：

    $ rm sbt-0.13.13.tgz

现在的目录结构：

	.
	├── README
	├── build.sbt
	├── idea.sbt
	├── project
	│   └── assembl
    ├── sbt# 刚才下载的 sbt
	└── src
	    └── main
	        ├── resources
	        └── scala
	            └── org
	                └── heygeeks
	                    ├── Job.sc
	                    ├── SocketTextStreamWordCount.scala# 
	                    └── WordCount.scala
	

简单的介绍下里面的默认程序：

* Job.scala: 只是代码骨架（skeletonn），需要完善逻辑
* SocketTextStreamWordCount.scala: 接受文本 socket 输入的计数程序
* WordCount.scala: 简答计数程序，自己生产数据，消费，并结束，不是常规的 Flink 的程序，用于测试使用

### 编译项目

    $ ./sbt/bin/sbt clean assembly

将会在项目根目录下的 *target/scala-2.11*  生成一个叫做 *hello-flink-assembly-0.1-SNAPSHOT.jar* 的 fat-jar。

### 执行测试程序

你可以使用 `./sbt/bin/sbt run` 来运行项目，使用 WordCount 来测试下环境

	$ ./sbt/bin/sbt run
	Multiple main classes detected, select one to run:
	
	 [1] org.heygeeks.Job
	 [2] org.heygeeks.SocketTextStreamWordCount
	 [3] org.heygeeks.WordCount
	
	Enter number: 3 # 选择你要执行的程序，我选择 WordCount
	
	[info] Running (fork) org.heygeeks.WordCount
	[info] (and,1)
	[info] (arrows,1)
	[info] (be,2)
	[info] (is,1)
	[info] (nobler,1)
	[info] (of,2)
	[info] (a,1)
	[info] (in,1)
	[info] (mind,1)
	[info] (or,2)
	[info] (slings,1)
	[info] (suffer,1)
	[info] (against,1)
	[info] (arms,1)
	[info] (not,1)
	[info] (outrageous,1)
	[info] (sea,1)
	[info] (the,3)
	[info] (tis,1)
	[info] (troubles,1)
	[info] (whether,1)
	[info] (fortune,1)
	[info] (question,1)
	[info] (take,1)
	[info] (that,1)
	[info] (to,4)
	[success] Total time: 122 s, completed Feb 18, 2019 12:54:39 AM
	    
## 3. 代码的执行过程

看一下演示的代码 1-1：

	53     val hostName = args(0)
	54     val port = args(1).toInt
	55
	56     val env = StreamExecutionEnvironment.getExecutionEnvironment
	57
	58     //Create streams for names and ages by mapping the inputs to the corresponding objects
	59     val text = env.socketTextStream(hostName, port)
	60     val counts = text.flatMap { _.toLowerCase.split("\\W+") filter { _.nonEmpty } }
	61       .map { (_, 1) }
	62       .keyBy(0)
	63       .sum(1)
	64
	65     counts.print
	66
	67     env.execute("Scala SocketTextStreamWordCount Example")	


- 56: env: 获取一个执行环境
- 59: Source 操作： 数据入口
- 60-63: Transform Operators：数据转换
- 65: Sink 操作：数据出口
- 67: execute：执行程序

### 3.1. 获取可执行环境

<img src="http://p.aybe.me/blog/flink-stream-env.png?x-oss-process=image/resize,w_920" width="100%" />

上图中，把 `StreamExecutionEnvironment` 的相互间依赖描述出来，把核心的属性和方法标记出口：

- 以 `StreamContextEnvironment`  类作为 **Flink** 任务的调用入口，和默认的 `execute()` 实现
- 任务分发前的处理实现都在 `StreamExecutionEnviroment` 抽象类中，如执行的模式，基本的配置以及预定义的数据源
- `RemoteStreamEnviroment` 和 `LocalStreamEnviroment` 作为要进行的任务分发方式（看图中相关注解）
- `StreamPlanEnviroment` 进行优化计划的规划和浏览

#### RemoteStreamEnviroment 的 execuete 实现

    # 路径: flink-streaming-java/src/main/java/org/apache/flink/streaming/api/environment/StreamContextEnvironment.java
	49     @Override
	50     public JobExecutionResult execute(String jobName) throws Exception {
	51         Preconditions.checkNotNull(jobName, "Streaming Job name should not be null.");
	52
	53         StreamGraph streamGraph = this.getStreamGraph();
	54         streamGraph.setJobName(jobName);
	55
	56         transformations.clear();
	57
	58         // execute the programs
	59         if (ctx instanceof DetachedEnvironment) {
	60             LOG.warn("Job was executed in detached mode, the results will be available on completion.");
	61             ((DetachedEnvironment) ctx).setDetachedPlan(streamGraph);
	62             return DetachedEnvironment.DetachedJobExecutionResult.INSTANCE;
	63         } else {
	64             return ctx
	65                 .getClient()
	66                 .run(streamGraph, ctx.getJars(), ctx.getClasspaths(), ctx.getUserCodeClassLoader(), ctx.getSavepointRestoreSettings())
	67                 .getJobExecutionResult();
	68         }
	69     }
 
`execute()`  函数的作用：

1. 根据 env  中的 `tranformations` 属性中的转换操作生成 StreamGraph（在 getStreamGraph() 中生成）
2. StreamGraph 传递给客户端；在客户端中，转换成 JobGraph，然后执行，（如果是 local 模式，这不传递出去，相应操作直接在 env 中进行，参见 `LocalStreamEnviroment` 的 `execute()` 实现） 

#### 预定义的数据源

这些源都定义在抽象类中

在 StreamExecutionEnvironment.java 中还预定义了读取输入的方法；你也可以通过实现 SourceFunction 接口来实现非并行的源或者实现 ParalleSourceFunction 接口或者继承 RichParalleSourceFunction 类来实现并行的源

#### 基于File的:

- readTextFile(path) --- 一列一列的读取遵循TextInputFormat规范的文本文件，并将结果作为String返回。
- readFile(fileInputFormat, path) --- 按照指定的文件格式读取文件
- readFile(fileInputFormat, path, watchType, interval, pathFilter) --- 这个方法会被前面两个方法在内部调用，它会根据给定的fileInputFormat来读取文件内容，如果watchType是FileProcessingModel.PROCESS_CONTINUOUSLY的话，会周期性的读取文件中的新数据，而如果是FileProcessingModel.PROCESS_ONCE的话，会一次读取文件中的所有数据并退出。使用pathFilter来进一步剔除处理中的文件。

#### 基于Socket的

- socketTextStream---从Socket中读取信息，元素可以用分隔符分开。

#### 基于集合(Collection)的

- fromCollection(seq)--- 从Java的java.util.Collection中创建一个数据流，集合中所有元素的类型是一致的。
- fromCollection(Iterator) --- 从迭代(Iterator)中创建一个数据流，指定元素数据类型的类由iterator返回
- fromElements(elements:_*) --- 从一个给定的对象序列中创建一个数据流，所有的对象必须是相同类型的。
- fromParalleCollection(SplitableIterator)--- 从一个给定的迭代(iterator)中并行地创建一个数据流，指定元素数据类型的类由迭代(iterator)返回。
- generateSequence(from, to) --- 从给定的间隔中并行地产生一个数字序列。

#### 自定义(Custom)

- addSource --- 附加一个新的数据源函数，例如:你可以使用addSource(new FlinkKafkaConsumer08<>(…))来读取Kafka中的数据。请参考: https://ci.apache.org/projects/flink/flink-docs-release-1.3/dev/connectors/来了解更多信息。

### 3.2. 从 Transformation 到 StreamGraph

在 [github.com/apache/flink/flink-streaming-java/src/main/java/org/apache/flink/streaming/api/](https://github.com/apache/flink/tree/master/flink-streaming-java/src/main/java/org/apache/flink/streaming/api/transformations "flink-streaming-api") 目录下：

    .transformations
	├── CoFeedbackTransformation.java
	├── FeedbackTransformation.java
	├── OneInputTransformation.java
	├── PartitionTransformation.java
	├── SelectTransformation.java
	├── SideOutputTransformation.java
	├── SinkTransformation.java
	├── SourceTransformation.java
	├── SplitTransformation.java
	├── StreamTransformation.java
	├── TwoInputTransformation.java
	└── UnionTransformation.j

现在我们，首先看一下 `execute(String jobName)`:


LocalStreamEnvironment.java:89
RemoteStreamEnvironment.java:307

### 3.3. 从 StreamGraph 到 JobGraph

LocalStreamEnvironment.java:92
RemoteStreamEnvironment.java:285
    


### 3.4. 从 JobGraph 到 ExecutionGraph


