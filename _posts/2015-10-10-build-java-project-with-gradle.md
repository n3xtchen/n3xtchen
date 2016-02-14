---
layout: post
title: "使用 Gradle 创建 Java 项目"
description: ""
category: Java
tags: [java, gradle]
---
{% include JB/setup %}

这个指南将引导你使用 **Gradle** 创建一个简单的 **Java** 项目。

### 成果

你讲创建一个简单的应用，然后使用 **Gradle** 构建它。

### 要求

* 需要 15 分钟
* 使用你常用的文本编辑器或者 **IDE**
* JDK 6 以上（我的机子使用的 JDK 8）

### 配置你的项目

首先，你需要配置使用 **Gradle** 构建的 **Java** 项目。为了注意力集中在 **Gradle** 上，我们现在创建一个尽可能简单的项目。

#### 创建目录结构

在你的项目目录下，创建如下所示子目录结构；比如，你可以在 *nix 系统键入命令：

	$ mkdir -p src/main/java/hello
	$ tree -L 5
	.
	└── src
	    └── main
	        └── java
	            └── hello
	
	4 directories, 0 files
	
你可以在 *src/main/java/hello* 中创建任何你想要的 **Java** 类。为了简化和剩下步骤的一致性， **Spring** 推荐你创建两个类：`HelloWorld.java` 和 `Greeter.java`。

	$ cat src/main/java/hello/HelloWorld.java
	package hello;
	
	public class HelloWorld {
	  public static void main(String[] args) {
	      Greeter greeter = new Greeter();
	      System.out.println(greeter.sayHello());
	    }
	}
	cat src/main/java/hello/Greeter.java
	package hello;
	
	public class Greeter {
	  public String sayHello() {
	      return "Hello world!";
	    }
	}
	
### 安装 Gradle

现在，你已经有一个可以构建的项目了，现在你可以安装 **Gradle**。

由于我的系统是 **Ubuntu 14.04** ，这里提供 **Linux** 的安装方法。

#### 安装 Java

如果你使用也是 **linux**，**Java** 还未安装的话，可以尝试下面安装方法：

	$ add-apt-repository ppa:webupd8team/java
	$ apt-get update
	$ apt-get install oracle-java8-installer

#### 开始安装 Gradle

	$ add-apt-repository ppa:cwchien/gradle
	$ apt-get update
	$ apt-get install gradle-2.7
	
### 测试 Gradle 是否安装成功

	$ gradle
	:help
	
	Welcome to Gradle 2.7.
	
	To run a build, run gradle <task> ...
	
	To see a list of available tasks, run gradle tasks
	
	To see a list of command-line options, run gradle --help
	
	To see more detail about a task, run gradle help --task <task>
	
	BUILD SUCCESSFUL
	
	Total time: 2.696 secs
	
	This build could be faster, please consider using the Gradle Daemon: https://docs.gradle.org/2.7/userguide/gradle_daemon.html
	
如果看到这样的信息，说明 **Gradle** 安装成功，可以进行下一步。

### 看看 Gradle 能干什么

既然 **Gradle** 已经安装好了，现在看看它能做什么。在你创建一个 *build.gradle* 之前，你可以询问下 **Gradle** 有哪些任务可用：

	$ gradle tasks
	:tasks
	
	------------------------------------------------------------
	All tasks runnable from root project
	------------------------------------------------------------
	
	Build Setup tasks
	-----------------
	init - Initializes a new Gradle build. [incubating]
	wrapper - Generates Gradle wrapper files. [incubating]
	
	Help tasks
	----------
	components - Displays the components produced by root project 'n3xt-gradle'. [incubating]
	dependencies - Displays all dependencies declared in root project 'n3xt-gradle'.
	dependencyInsight - Displays the insight into a specific dependency in root project 'n3xt-gradle'.
	help - Displays a help message.
	model - Displays the configuration model of root project 'n3xt-gradle'. [incubating]
	projects - Displays the sub-projects of root project 'n3xt-gradle'.
	properties - Displays the properties of root project 'n3xt-gradle'.
	tasks - Displays the tasks runnable from root project 'n3xt-gradle'.
	
	To see all tasks and more detail, run gradle tasks --all
	
	To see more detail about a task, run gradle help --task <task>
	
	BUILD SUCCESSFUL
	
	Total time: 4.117 secs
	
	This build could be faster, please consider using the Gradle Daemon: https://docs.gradle.org/2.7/userguide/gradle_daemon.html
	
虽然这些任务都是可用的，但是没有项目构建配置，他们不能提供足够的价值。随着你对 *build.gradle* 的充实，一些任务将要更有用，因此你是不是的需要运行下 `task` 检查下可用的任务。

说起添加插件，下一步你需要添加插件来启用 **Java** 基础构建功能。

### 构建 Java 代码

从简单的开始，创建一个只有一行的 *build.gradle* 文件：

	$ cat build.gradle
	apply plugin: 'java'
	
这样的一行将带了强大的特性，再次运行 `gradle task` 看看，你将看到一些新的任务加到列表中，包括构建项目，创建 **JavaDoc**，以及运行测试。

> 你将经常使用 `gradle build` 来构建项目。这个任务编译，测试和打包成 **JAR** 包。你可以试着运行下：
>	$ gradle build

过了几秒，**BUILD SUCCESSFUL** 说明构建已经完成。

看看构建后的结果，看看 *build* 目录。

	build
	|-- classes
	|   `-- main
	|       `-- hello
	|           |-- Greeter.class
	|           `-- HelloWorld.class
	|-- dependency-cache
	|-- libs
	|   `-- n3xt-gradle.jar
	`-- tmp
	    |-- compileJava
	    `-- jar
	        `-- MANIFEST.MF
	
	8 directories, 5 files


在那里，你将找到一些文件夹，包括下面三个常见目录：

* *classes*: 编译后的 *.class* 文件
* *reports*: 构建产生的报道（例如测试报告）
* *libs*: 打包后的项目库（一般是 *JAR* 或者 *WAR* 文件）

这时在 *classes* 目录，你应该可以找到 *HelloWorld.class* 和 *Greeter.class*。

现在，你的项目还有任何库依赖，因此没有 **dependency_cache** 目录。

*reports* 目录中应该包含一个单元测试的报告。因为这个项目还没有编写人和单元测试，报告也是没有什么有趣的内容。

*libs* 目录中应该包含一个 **JAR** 包，和你的项目目录同名。后续，你将会学学会如何制定包名和它的版本。

### 声明依赖

这个简单的 Hello World 例子完全是自给自足的，不依赖任何额外的苦。然而，大部分应用都来外部的库来处理通用或者复杂的功能。

例如，想要在显示 “Hello World!” 同时，你想要答应当前的时间。你当然可以使用原生的时间处理功能，但是为了让例子更有趣些，我们将使用 Joda Time 库。

首先，修改我们的 *HelloWord.java*：

	package hello;
	
	import org.joda.time.LocalTime;
	
	public class HelloWorld {
	  public static void main(String[] args) {
	    LocalTime currentTime = new LocalTime();
	    System.out.println("The current local time is: " + currentTime);
	
	    Greeter greeter = new Greeter();
	    System.out.println(greeter.sayHello());
	  }
	}

这里 `HelloWorld` 使用 Joda Time 类来获取和打印当前时间。

如果你现在使用 *gradle build* 命令来编译项目，编译器将会失败，因为你还没有声明 Joda Time 作为编译的依赖。

对于初学者，你可能需要添加第三方源。

	repositories {
	   mavenCentral()
	}
	
`repositories` 指明了构建可以通过 **Maven Central** 源来解决它的依赖问题。**Gradle** 重度依赖由 **Maven** 构建工具提供的很多惯例以及功能，包括使用 **Maven Central** 作为库依赖的源。

现在，你已经准备好第三方库的源；然后让我们一起声明一些东西。

	sourceCompatibility = 1.8
	targetCompatibility = 1.8
	
	dependencies {
	    compile "joda-time:joda-time:2.2"
	}

在 `repositories` 中，你为 Joda Time 声明一个独立依赖，并且明确的制定你需要的是 2.2 版本。

关于依赖，你另外需要注意的是这个指定的是编译依赖，说明它只在编译时可用（如果你想要构建一个 **War** 文件的话，包含在 */Web-INF/libs* 目录中的）。另一种只要的依赖类型有：

* `prividedCompile`：在编译代码时要求的依赖，但是它也将提供在 **runtime** 时由容器运行需要的依赖（例如，**Java Servlet API**）。
* `testCompile`：在编译和运行测试时的依赖，但是不包括在构建和运行 **runtime** 代码中。

最后，让我们手动指定 **JAR** 包名。

	jar {
	    baseName = 'n3xt-gradle'
	    version =  '0.1.0'
	}

`jar` 指定 **JAR** 将来将如何命名。这个例子中，它将是 `n3xt-gradle-0.1.0.jar`。

现在，如果你运行 `gradle build`，**Gradle** 应该已经从 **Maven Central** 源中解决了 Joda Time 的依赖问题，并且构建成功。

### 使用 Gradle Wrapper 构建你的项目

**Gradle Wrapper** 是使用 **Gradle** 构建工具的最佳方式。它包含 **Windows** 批处理脚本以及 **OS X** 和 **Linux** 的脚本。这些脚本允许你不用预先在你的自己上安装 **Gradle** 前提下运行 **Gradle** 构建项目。为了使用它，在你的 `build.gradle` 底部添加如下代码。
	
	task wrapper(type: Wrapper) {
	    gradleVersion = '2.7'
	}

运行如下命令，下载和初始化 wrapper 脚本：

	$ gradle wrapper

这个任务完成后，你将看到一些新文件。由两个脚本在你的项目根目录中，同时 wrapper jar 和 properties 文件已经添加到新的 `gradle/wrapper` 目录中。

	.
	...
	|-- gradle
	|   `-- wrapper
	|       |-- gradle-wrapper.jar
	|       `-- gradle-wrapper.properties
	|-- gradlew
	`-- gradlew.bat

**Gradle Wrapper** 现在已经在你的项目可用了。把它添加到你的版本控制系统中；这样只用使用你的项目代码，那你们的编译环境将都相同。由于安装了同一版本的 **Gradle** ，所以可以被完全相同的方法使用。和之前一样，运行构建命令：

	$ ./gradlew build
	
第一次使用指定版本的 **Gradle Wrapper** 时，它将下载和缓存 **Gradle** 二进制代码。**Gradle Wrapper** 文件就是为了版本控制而设计的，因此任何人都不用实现安装和配置 **Gradle**。

这个步骤，你已经构建好你的代码了。**JAR** 文件包含了两个指定的类文件（`Greeter` 和 `HelloWorld`）；我们快速预览下。

	$ jar tvf build/libs/n3xt-gradle-0.1.0.jar
     0 Sun Oct 11 13:38:44 UTC 2015 META-INF/
    25 Fri Oct 09 18:22:50 UTC 2015 META-INF/MANIFEST.MF
     0 Fri Oct 09 18:22:50 UTC 2015 hello/
   988 Sun Oct 11 13:38:44 UTC 2015 hello/HelloWorld.class
   369 Sun Oct 11 13:38:44 UTC 2015 hello/Greeter.class

类文件已经被打包到一起了。有一个需要特别注意，虽然你已经声明了 joda-time 作为依赖，这个库病不包含在这里。并且 **JAR** 文件也不可执行。

为了使这个代码可执行，我们使用 **Gradle** 的 `application` 插件。把它添加到你的 `build.gradle` 文件中。

	apply plugin: 'application'
	
	mainClassName = 'hello.HelloWorld'

然后运行你的 app!

	$ ./gradlew run
	:compileJava UP-TO-DATE
	:processResources UP-TO-DATE
	:classes UP-TO-DATE
	:run
	The current local time is: 14:03:07.860
	Hello world!
	
	BUILD SUCCESSFUL
	
	Total time: 7.375 secs

打包依赖需要更多想法。例如，如果你构建一个 **WAR** 文件，一个与第三方依赖紧密关联的通用格式，我们应该使用 **WAR plugin**。如果你使用 **Spring Boot**，想要可执行的 **JAR** 文件，`spring-boot-gradle-plugin` 将会很方便。这个阶段，**Gradle** 对你的系统没有足够的了解，很难做出选择。但是，现在你应该足有使用 **Gradle** 了。

把这个指南中所有东西都整合到一块，这里是一个完成 `build.gradle` 文件：

	apply plugin: 'java'
	apply plugin: 'application'
	
	mainClassName = 'hello.HelloWorld'
	
	// tag::repositories[]
	repositories {
	    mavenCentral()
	}
	// end::repositories[]
	
	// tag::jar[]
	jar {
	    baseName = 'gs-gradle'
	    version =  '0.1.0'
	}
	// end::jar[]
	
	// tag::dependencies[]
	sourceCompatibility = 1.8
	targetCompatibility = 1.8
	
	dependencies {
	    compile "joda-time:joda-time:2.2"
	}
	// end::dependencies[]
	
	// tag::wrapper[]
	task wrapper(type: Wrapper) {
	    gradleVersion = '2.3'
	}
	// end::wrapper[]

> **注意**：这里有很多的 start/end 注释。这个只是为了解释，你不需要把它放到你的生产构建文件中。

### 总结

恭喜你！你已经可以为你的 **Java** 项目创建一个简单高效的 **Gradle** 构建文件。

> **参考**：
> 
> 	* [gradle 指南](http://spring.io/guides/gs/gradle/)
> 	* [灵活强大的构建系统Gradle](http://tech.meituan.com/gradle-practice.html)






