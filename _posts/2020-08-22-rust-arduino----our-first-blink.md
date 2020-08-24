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

现在我们把依赖放一边，让我们加一点代码到 `main.rs` 中，后续将逐步完善它：

    // main.rs
    
    #![no_std]
    #![no_main]

首先，我们需要制定一些全局属性让编译器知道我们在不一样的环境里面。我们使用的是嵌入式环境，很多功能在标准库中是没有的，比如堆内存分配接口，线程以及网络接口等等。因此，我们需要在头部添加 `#![no_std]` 属性。
我们还需要使用 `#![no_main]` 重载默认入口（`fn main()`），因为我们将提供和定义自己的入口程序。我们使用 `arduino_uno` 包中提供的宏，来定义访问入口。通常，支持芯片的包都会为你提供入口宏。

然后，我们使用 `use` 在域内引入需要的以来：

    extern crate panic_halt;
    use arduino_uno::prelude::*;
    use arduino_uno::hal::port::portb::PB5;
    use arduino_uno::hal::port::mode::Output;

注意到 `panic_halt` 包了吗？我们之所以需要奔溃处理器（panic）是因为：

在标准库，奔溃已经定义的默认行为：Rust 默认采用的是快速失败的方法，除非用户在奔溃时选择中止程序，否则 Rust 会展开奔溃线程的堆栈。没有标准库的程序中，奔溃行为尚未定义。通过声明 `#[panic_handler]` 来选择处理行为。

让我们继续：

    #[arduino_uno::entry]
    fn main() -> ! {
    
    }

我们给我们的 main 函数加上了 `entry` 的注解，表示这个函数作为程序的入口。`!` 在 Rust 中称作 Never 类型，意味程序不会返回任何东西，类似 C 语言的 `void`。

我们只需要加入几行代码，设置相关 pin 端口高低压，就能让 Led 灯闪烁。现在，我们看一下 ATmega328P 芯片的引脚图：

[ATmega328P 芯片的引脚图](https://components101.com/sites/default/files/inline-images/ATMega328P-Arduino-Uno-Pin-Mapping.png)

在上图中，你可以看到芯片中各种各样引脚。大部分微控制器允许设备对引脚进行读写。他们中一些被分类为 I/O 端口。一个端口代表标准接口的一组引脚。这些端口受相应端口寄存器控制，可以被代码变更的一类字节变量。

在 ATmega328P 的例子中，我们有三个端口寄存器：

- C - 模拟引脚 0 到 5
- D - 数字引脚 0 到 7
- B - 数字引脚 8 到 13

具体说明间：[port Manipulation](https://www.arduino.cc/en/Reference/PortManipulation)

如果你现在手上有 uno，你可以看到数字引脚 13 和内置的 LED 是相连的。我们需要在我们的代码中访问这个引脚来操控 LED。比如，把它设置成 high 和 low。

现在，让我们加一些代码：

    #[arduino_uno::entry]
    fn main() -> ! {
        let peripherals = arduino_uno::Peripherals::take().unwrap();
    
        let mut pins = arduino_uno::Pins::new(
            peripherals.PORTB,
            peripherals.PORTC,
            peripherals.PORTD,
        );
    
        let mut led = pins.d13.into_output(&mut pins.ddr);
    
        loop {
            stutter_blink(&mut led, 25);
        }
    }

上述代码的做了甚多事情。

首先，我们创建了一个叫 `Peripherals` 的实例，它是 uno 外围设备列表。Peripherals 是连接你的芯片和外部设备、传感器等等的桥梁，比如计时器、计数器、串口等等。嵌入式处理器和外围设备是通过一系列控制器和状态寄存器进行沟通的。

我们同作传递外围设备实例提供的端口，创建了一个新的 `Pin` 实例。然后定义一个 led 变量保存 LED 连接的引脚号。
