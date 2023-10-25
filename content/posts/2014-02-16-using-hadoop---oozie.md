---
categories:
- Hadoop
date: "2014-02-16T00:00:00Z"
description: ""
tagline: ""
tags:
- hadoop
- oozie
title: Using Hadoop - 创建简单的 Oozie 工作流
---

> 来源：[Oracle - Build Simple Workflows in Oozie](https://blogs.oracle.com/datawarehousing/entry/building_simple_workflows_in_oozie)

### 简介

寻常情况下，数据并不能按我们希望的方式被打包。我们从大数据源中抽取洞见（
Insight）之前，我们需要对其进行转换（Transformation），match-merge 操作，
数据清洗和整合（data munging）任务。数据清洗和整合对于大部分人人说是很枯燥，
但是又必须做；这种情况，创建自动化处理来解放我们工作。我们把这些工作转换成
重复运行的单元，并创建工作流。在这篇文章中，我们使用 Oozie 来为并行机器学习
任务创建工作流。

###  Hive 动作：先为 Pig 预热

### 开始我们的工作流

Oozie 提供两种方式的工作：工作流和协调工作。工作流很简单：他们定义动作集来
以有向无环（DAG）的方式运行它。协调器工作可以携带工作流中所有相同的动作，并
且他们可以周期性的或者数据到达指定路径的时候被自动触发。为了简化它，我们创建
一个工作流工作；协调工作需要另一个 XML 文件来计划。定义工作流 XML：
    
    <!-- simpleWorkFlow,xml -->
    <workflow-app nam="myApp" xmlns="uri:oozie:workflow:0.1">
        <start to="startAct" />
        <end name="end" />
    </workflow-app>

现在我们需要添加动作，其中也包括我们指定的 Hive 参数。记住，定义动作的时候，
我们要求指定 <ok> 和 <error> 标签来定位成功或失败后执行的动作。

    <action name="ParseNCDCData">
        <hive xmlns="uri:oozie:hive-action:0.2">
            <job-tracker>localhost:8021</job-tracker>
            <name-node>localhost:8020</name-node>
            <configuration>
                <property>
                    <name>oozie.hive.defaults</name>
                    <value>/user/n3xtchen/17173_ooze/hive-default.xml</value>
                </property>
            </configuration>
            <script>parse.hql</script>
        </hive>
        <ok to="WeatherMan"/>
        <error to="end"/>
    </action>

这里有一些东西需要注意：

1. 必须指定工作追踪器（jobTracker）和名称节点（nameNode）
2. 必须包含 hive-default.xml 文件
3. 必须包含脚本文件（.hql）
4. hive-default.xml 和 脚本文件必须存储在 HDFS 文件系统中

最后一点特别重要。Oozie 不会对工作流的存储位置作为假设。你可能要把工作提交到
不同的集群，或者在不同的集群设置不同的 hive-defaults.xml 文件。

最快速的确认这些文件是否存放在正确地方的方法就是，在本地创建工作目录，为它
创建 workflow.xml 文件，复制到你需要的地方。这是，我们的本地目录应该包含：

1. workflow.xml
2. hive-defaults.xml
3. parse.sql

### 添加 Pig 到 Oozie 中

添加 Pig 动作到 XML 中会稍微简单电。所有我们所要做的就是像下面这样：

    <action name="CalData">
        <pig>
            <job-tracker>localhost:8021</job-tracker>
            <name-node>localhost:8020</name-node>
            <script>calData.pig</script>
        </pig>
        <ok to="end"/>
        <error to="end"/>
    </action>

一旦我们添加完成，要将我们的 pig 脚本（calData.pig）上传到我们的工作目录中。

虽然 Oozie 不会做出太多推断，但是它会对 Pig 的 classpath 做出假设。任何在
 working_directory/lib 中的库都会自动被加载，而不需要 Reqister 语句来加载。
任何需要使用 Reqister 登记的库都不能存放在 working_directory/lib 中。如果
存放在不同的 HDFS 目录的化，你可以附加上 <archieve> 标签来指定。

是的，这个非常让人费解。

你可以在 [Pig Cookbook](http://incubator.apache.org/oozie/pig-cookbook.html)
中获取相关的完整文档。

### 让你的 Workflow 工作

你已经定义了你的工作流和收集所有我们需要的的组件。但是在执行它之前，我们还需
要定义工作的一些属性，并把它上传到 Oozie 服务器。我们首先需要先从工作属性开
始，它的本质就是我们提交给 Ooize 服务的请求。在工作目录下，我们将创建叫做
job.properties 的文件：

    nameNode=hdfs://localhost:8020
    jobTracker=localhost:8021
    queueName=default
    workRoot=work_zone
    mapreduce.jobtracker.kerberos.principal=foo
    dfs.namenode.kerberos.principal=foo
    oozie.libpath=$(nameNode)/user/share/lib
    oozie.wf.application.path=${nameNode}/user/$(user.name)/$(workRoot)
    outputDir=work=work-ooze

这个配置中的一些我们已经很熟悉了（例如，JobTracker address），我就介绍下剩下
的部分：

+ workRoot：这是关键的脚本环境变量。我们使用它来简化 Oozie 的工作命令。
+ oozie.libpath：这个至关重要。它是 HDFS 中的文件夹，它包含了 Oozie 的共享库
：执行 Hive，Pig 和其他动作的必要 Jar 包的集合。有一个好方法来确认它们是否被
正确安装并拷贝到 HDFS 上：在应用目录下运行 workflow.xml，并输出到输出目录中。

我们完成提交工作准备了。最后我们还需要做一些事情：

1. 验证我们的 workflow.xml：

    oozie validate workflow.xml

2. 拷贝我们的工作目录到 HDFS 上：

    hadoop fs -put working_dir /user/n3xtchen/work_dir

3. 提交我们的工作给 Oozie 服务器。我们需要确认 Oozie 的服务器网址死正确的，
以及已经在 job.properties 中指定好了：

    oozie job --oozie http://url.to.oozie.server:port_number/ -config 
    /path/to/working_dir/job.properties -submit

我们一定提交了工作，但是我们并没看到在 JobTracker 中任何活动？我们所得到的输
出：

    14-20120525161321-oozie-n3xtchen

这是因为提交给 Oozie 的工作创建了一个工作实体（entry），并把它替换成 PREP 状
态。我们需要为我们的工作流获取乘坐 Oozie 动车的车票。我们负责兑现我们的票以
及执行我们的工作。

    oozie --oozie http://url.to.oozie.server:port_number/ -start
    14-20120525161321-oozie-n3xtchen

当然，如果我们需要从设置起就开始执行我们的工作，我们只需要改变上面的命令参数
 `-submit` 为 `-run` 即可。他就会马上开始预备，马上执行工作流。

4. 运行我们的工作流

### 题外话

从这里，你所获得的是：创建工作流相对比较艰巨的步骤。第一次可能会有点单调乏味
，然而对于那些花大量时间在数据清洗和整合（data munging）的开发者来说是非常有
价值的。首先，当新数据到达并请求相同的处理时，我们已经有定义好的工作流，并准
备执行。其次，由于我们不断的创建有用的动作，使得创建新的工作流变得更迅速。
