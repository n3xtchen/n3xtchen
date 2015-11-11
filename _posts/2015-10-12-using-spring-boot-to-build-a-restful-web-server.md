---
layout: post
title: "使用 Spring Boot: 构建 Restful 服务"
description: ""
category: Java
tags: [java, sping]
---
{% include JB/setup %}

这个教程我们将使用 **Spring** 创建一个 `“Hello World”` 的 Restful 服务。

## 你将得到什么

你将创建一个服务接受 **HTTP** 的 `GET` 请求，返回如下内容：

	$ curl http://localhos:8080/greeting -X GET
	{"id":1,"content":"Hello, World!"}
	
你可以通过改变 `name` 参数来定制化响应内容：

	$ curl http://localhos:8080/greeting?name=Me -X GET
	{"id":1,"content":"Hello, Me!"}
	
## 教程要求

* JDK 1.8 或更后
* Gradle 2.3＋ (我的版本是 2.7)

## 项目准备

### 创建项目目录

	$ mkdir -p src/main/java/hello
	
### 创建一个 Gradle 构建文件

	$ cat build.gradle
	buildscript {
	    repositories {
	        mavenCentral()
	    }
	    dependencies {
	        classpath("org.springframework.boot:spring-boot-gradle-plugin:1.2.7.RELEASE")
	    }
	}
	
	apply plugin: 'java'
	apply plugin: 'spring-boot'
	
	jar {
	    baseName = 'n3xt-rest-service'
	    version =  '0.1.0'
	}
	
	repositories {
	    mavenCentral()
	}
	
	sourceCompatibility = 1.8
	targetCompatibility = 1.8
	
	dependencies {
	    compile("org.springframework.boot:spring-boot-starter-web")
	    testCompile("junit:junit")
	}
	
	task wrapper(type: Wrapper) {
	    gradleVersion = '2.7'
	}
	
**Spring Boot** **Gradle 插件** 提供了很多简便的特性：

* 它自动收集所有的 jar 包并添加到 `classpath` 中，构建一个单一可执行的 jar 包，使其更容易执行和传输服务。
* 它检索所有的 `public static void main()` 方法，并标记其所在类可执行。
* 它提供内置的解决依赖，指定与其匹配的 **Spring Boot 依赖** 的版本。你可以覆盖你想要的任何版本，它将成为默认的 Boot 选择的版本。

## 进入正题

### 创建一个资源呈现类(Resource Representation Class)

你已经设置了项目和构建系统，你现在可以开始创建的 web 服务了。

首先思考一下交互。

服务处理来时 `/greetng` 的 `GET` 请求，可选带一个 `name` 查询参数。`GET` 请求应该返回一个带有 **JSON** 的 `200OK` 的响应。它看起来如下：

	{
	    "id": 1,
	    "content": "Hello, World!"
	}
	
`id` 字段是 **Greeting** 的唯一标识，`content` 是一个问候的文本呈现。

为了模块化问候呈现，你可以创建一个资源呈现类。提供一个带属性，构造器以及`id` 和 `content` 数据访问器的老式 **Java** 对象:

	// src/main/java/hello/Greeting.java
	package hello;
	
	public class Greeting {
	
	    private final long id;
	    private final String content;
	
	    public Greeting(long id, String content) {
	        this.id = id;
	        this.content = content;
	    }
	
	    public long getId() {
	        return id;
	    }
	
	    public String getContent() {
	        return content;
	    }
	}
	
> **注意**：正如你所看到的，**Spring** 使用 **Jackson JSON** 库子自动把 `Greeting` 类转换成 **JSON**。

下一步你创建资源控制器来服务这些问候请求。

### 创建一个资源控制器(Resource Controller)

使用 **Spring** 的方式来创建一个 **Web** 服务，**HTTP** 请求由控制器来处理。这个组件使用 `@RestController` 注释来标识，并由 `GreetingController` 处理 `/greeting` 的 `GET` 请求，返回一个新的 `Greeting` 类的实例：

	// src/main/java/hello/GreetingController.java
	package hello;
	
	import java.util.concurrent.atomic.AtomicLong;
	import org.springframework.web.bind.annotation.RequestMapping;
	import org.springframework.web.bind.annotation.RequestParam;
	import org.springframework.web.bind.annotation.RestController;
	
	@RestController
	public class GreetingController {
	
	    private static final String template = "Hello, %s!";
	    private final AtomicLong counter = new AtomicLong();
	
	    @RequestMapping("/greeting")
	    public Greeting greeting(@RequestParam(value="name", defaultValue="World") String name) {
	        return new Greeting(counter.incrementAndGet(),
	                            String.format(template, name));
	    }
	}
	
这个控制器简洁而且简单，但是还是包含很多的概念。让我们一步一步拆解。

`@RequestMapping` 注释确保 `/greeting` 的请求映射到 `greeting()`   方法。

> **注意**： 上面的例子没有指明 `GET`，`PUT` 或者 `POST` 等等，因为  `@RequestMapping` 默认可以响应上述所有种类的请求。使用 `@RequestMapping(method=GET)` 来明确指定它。

`@RequestParam` 绑定请求参数 `name` 的值到 `greeting()` 的 `name` 方法参数上。这个查询字符串不是必须的；如果请求中未传递，将使用默认值(`defaultValue`, 这里的值是 `World`)。

方法中创建返回一个新的 `Greeting` 对象，其中 `id` 的值基于 `counter` 的递增值，`name` 根据给予 `name` 参数和 `greeting` 模版
格式化的结果。

传统的 **MVC** 控制器和 **Restful** 服务控制器最大的不同就是 **HTTP** 请求体的不同。不依赖于利用模版技术(View Technology) 来渲染 `Greeting` 对象成 **HTML**。对象数据将直接以 **JSON** 形式输出。

这个代码使用了 **Spring 4** 的新注释 `@RestController`，它标记这个类作为一个控制器，其中每一个方法返回的是一个领域对象而不是视图(View)。简要的说就是把 `@Controller` 和 `@ResponseBody` 融合在一起。

`Greeting` 对象必须转化成 **JSON**。对亏了 **Spring** 的 **HTTP** 信息转化器的支持，你不需要手动做这个转化。因为 `Jackson 2` 在 *classpath* 中，**Spring** 的`MappingJackson2HttpMessageConverter` 将自动被选择用来转化 `Greeting` 实例成 **JSON**。

### 使应用可执行

虽然可以把这个服务打包成传统的 `WAR` 文件，直接部署到外部的应用服务，下面将演示如何创建一个独立应用。你把所有的东西打包到一个可执行的 `JAR` 文件，在古老的 `main()` 方法中。接着，你使用 **Spring** 内置支持的 **Tomcat** 服务容器来代替部署成外部实例。

	// src/main/java/hello/Application.java
	package hello;
	
	import org.springframework.boot.SpringApplication;
	import org.springframework.boot.autoconfigure.SpringBootApplication;
	
	@SpringBootApplication
	public class Application {
	
	    public static void main(String[] args) {
	        SpringApplication.run(Application.class, args);
	    }
	}

`@SpringBootApplication` 是一个很便捷的注释语法，可以添加如下配置：

* `@Configuration` 标记类作为一个 **bean** 源，来定义应用的上下文。
* `@EnableAutoConfiguration` 告诉 **Sprint Boot** 基于 
* *classplath* 配置的 **Bean**，其他的 **Bean** 以及各种属性配置
* 正常情况你要加入一个 `@EnableWebMvc` 注释，但是当 **spring-webmvc** 存在于 *classpath* 中的时候，**Spring Boot** 会自动添加它。这个标记应用作为一个 **Web** 服务，激活关键的行为，例如 `DisoatcherServlet`。
* `@ComponentScan` 告诉 **Spring** 查找在 `hello` 中的其他的组件，配置以及服务，允许它查找 `GreetingController`。

这个 `main()` 方法使用 **Spring Boot** 的 `SpringApplication.run()` 方法来启动应用。你注意到了吗？没有写一行的 XML？也没有 **web.xml** 文件。这个 **Web** 应用 100％ 的 **JAVA**，你不必关心任何的基础配置。

#### 构建一个可执行 JAR

如果你使用 **Gradle**，你可以使用 `./gradlew bootRun` 运行应用。

你可以构建一个简单的可执行 **JAR**，包含所有的依赖，类以及资源。这样整个开发周期中有利于传递，版本控制以及部署，跨平台等等。

	./gradlew build
	
然后你运行你的 **JAR** 文件：

	java -jar build/libs/n3xt-rest-service-0.1.0.jar
	
如果你使用 **Maven**，你可以使用 `mvn spring-boot:run` 运行应用。或者你可以使用 `mvn clean package` 编译 **JAR** 文件和运行他：

	java -jar target/n3xt-rest-service-0.1.0.jar
	
> **注意**：整个过程将会创建一个可执行 **JAR** 文件。你也可以选择编译成 **WAR** 文件。

输出日志将会显示。服务将在几秒后启动和运行。


### 测试你的服务

现在服务已经启动，访问 [http://localhost:8080/greeting](http://localhost:8080/greeting)，你将看到：

	{"id":1,"content":"Hello, World!"}

 传递了一个 `name` 参数，像这样 [http://localhost:8080/greeting?name=User]( http://localhost:8080/greeting?name=User)。你可能已经注意到 `content` 值的变化了：
 
 	{"id":2,"content":"Hello, User!"}
 	
 这个变化意味了 `@RequestParam` 在 `GreetingController` 按照预期生效了。`name` 参数已经设置了，但是可以使用查询参数来明确覆盖。
 
同时也注意到 `id` 从 `1` 变成 `2`。这证明你对同一个对象进行多次请求，`counter` 每次请求都会按照预期递增。

### 总结

恭喜你学会使用 **Spring** 开发 **Restful** 应用了。
