---
layout: post
title: "使用 Spring boot: 构建 Restful 服务"
description: ""
category: Java
tags: [Java, sping]
---
{% include JB/setup %}

这个教程我们将使用 **Spring** 创建一个 *“Hello World”* 的 Restful 服务。

## 你将得到什么

你将创建一个服务接受 **HTTP** 的 **GET** 请求，返回如下内容：

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

### 创建一个资源呈现类

你已经设置了项目和构建系统，你可以开始创建的 web 服务了。

开始思考一下交互。

服务处理来时 `/greetng` 的 `GET` 请求，可选带一个 `name` 查询参数。`GET` 请求应该返回一个带有 JSON 的 `200OK` 的响应。它看起来如下：

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
	
> **注意**：正如你所看到的，Sping 使用 **Jackson JSON** 库子自动把 `Greeting` 类转换成 JSON。

下一步你创建资源控制器来服务这些问候请求。
