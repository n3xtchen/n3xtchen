---
layout: post
title: "如何在 Arduino Uno 中运行 Rust：让你的 Led 灯闪起来"
description: ""
category: Rust
tags: [IOT]
---
{% include JB/setup %}

在写这片文章之前，大概一个月前，我们的 rust-avr 分支已经合并到主分支了。你可以在 `.cargo/config.toml` 指定平台目标为 `avr-unknonw-unknonw,unknonw`， 执行 `cargo +nightly build` 在 avr 微控面板上编译 Rust 程序了。

我痴迷于使用代码控制现实物件的想法。后续将会有更多关于 Arduino/ESP8266 的 Rust 冒险之旅的文章。 

- 目标受众：针对使用 Rust 进行嵌入式开发的新手。如果可以看完全文，建议也可以阅读下 《embedded rust book》的基础章节。
- 编译环境是
    - Arch Linux
    - `rustc 1.47.0-nightly (22ee68dc5 2020-08-05)`
- Arduino Uno: 在业余爱好者群体中，最为流行的嵌入式解决方案；它是基于 ATmega328P 架构的 AVR 单片机

> AVR 单片机简史: 1997 年由 ATMEL 公司研发出的增强型内置 Flash 的RISC(Reduced Instruction Set Computer) 精简指令集高速 8 位单片机。随着 2016 年，Atmel 被 Microchip 收购，AVR 随即成为Microchip的主力8位单片机产品之一。

接下来，我们将借用 Arduio 届的 Hello Word（即控制 Led 灯闪烁） 来阐述整个开发过程。 虽然很简单，但是对于新手的话，还有很多知识点。

### 设置你的项目

首先创建一个 cargo 项目：

    $ cargo new rust-arduino-blink

我们需要针对 AVR 平台交叉编译我们的项目（平台三重标示：`avr-unknonw-unknonw`）。为了完成这个操作，我们需要使用 nightly 版的编译工具链，因为我们的项目需要依赖一些不稳定的特性：

    $ rustup override set nightly

上述命令只会对执行这个命令的目录内有效。

然后，我们需要安装一些包：

- `arv-gcc`：作为编译连接器
- `arduino-avr-core`：我们要使用其中的工具包，如 avrdude 用来上传代码到芯片 

安装命令如下：

    $ pacman -S avr-gcc arduino-avr-core

接下来，在 `cargo.toml` 中添加依赖包：

    [dependencies]
    # A panic handler is needed.  This is a crate with the most basic one.
    panic-halt = "0.2.0"
    
    [dependencies.arduino-uno]
    git = "https://github.com/Rahix/avr-hal"

`avr-hal` 是一个包（Cargo）空间，包含一堆各种芯片的驱动包（Crate），`arduino-uno` 就是其中之一。感谢 Rahix 把它们整合在一起。

我们需要为 avr 平台添加编译元数据。我们将在项目根目录下创建一个文件 `arv-atmega328.json`，包含的内容如下：

    {
      "llvm-target": "avr-unknown-unknown",
      "cpu": "atmega328p",
      "target-endian": "little",
      "target-pointer-width": "16",
      "target-c-int-width": "16",
      "os": "unknown",
      "target-env": "",
      "target-vendor": "unknown",
      "arch": "avr",
      "data-layout": "e-P1-p:16:8-i8:8-i16:8-i32:8-i64:8-f32:8-f64:8-n8-a:8",
    
      "executables": true,
    
      "linker": "avr-gcc",
      "linker-flavor": "gcc",
      "pre-link-args": {
        "gcc": ["-Os", "-mmcu=atmega328p"]
      },
      "exe-suffix": ".elf",
      "post-link-args": {
        "gcc": ["-Wl,--gc-sections"]
      },
    
      "singlethread": false,
      "no-builtins": false,
    
      "no-default-libraries": false,
    
      "eh-frame-header": false
    }

并且在 `.cargo/config.toml` 索引它：

    [build]
    target = "avr-atmega328p.json"
    
    [unstable]
    build-std = ["core"]

这样子，我们的构建配置算完成了。

### 让我们写一些代码



