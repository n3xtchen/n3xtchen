---
layout: post
title: "如何在 Arduino Uno 中运行 Rust：让你的 LED 灯闪起来"
description: ""
category: Rust
tags: [IOT]
---
{% include JB/setup %}

已经有一段时间没碰板子了，怎么想写一篇关于 **Arduino** 的文章呢？这要追溯到一个月前，我们的 `rust-avr` 分支已经合并到 upstream 了，可以通过 nightly 版来直接使用它来开发 **Arduino** 程序；一直以来都是用 C 来写，Rust 的诱惑力，你懂得。你现在只要完成以下两步就可以为 **AVR** 微控面板编译 Rust 程序了：

1. 在 `.cargo/config.toml` 将平台（Target）指定为 `avr-unknonw-unknonw,unknonw`
2. 执行 `cargo +nightly build` 。

是不是很惊喜？^_^

本人喜欢硬件，也对 Rust 感兴趣，两者一起弄，也是蛮不错的体验。所以后续将会有更多关于 **Arduino**/**ESP8266** 的 Rust 的文章。

在动手之前，我们先了解一些背景，我们文章针对使用 Rust 进行嵌入式开发的新手。如果可以看完全文，建议也可以阅读下 《embedded rust book》的基础章节。

下面是我的软硬件环境：

- macOS Catalina(MBPR 16，在 Ubuntu 和 Arch 下也可以正常编译) 
- `rustc 1.48.0-nightly (d006f5734 2020-08-28)`：如果还没有安装，可以使用下面的命令进行安装：

        $ brew install rustup
        $ rustup-init
        $ rustup install nightly
        $ rustup component add rust-src
        $ rustc --version --verbose
        rustc 1.48.0-nightly (d006f5734 2020-08-28)
        binary: rustc
        commit-hash: d006f5734f49625c34d6fc33bf6b9967243abca8
        commit-date: 2020-08-28
        host: x86_64-apple-darwin
        release: 1.48.0-nightly
        LLVM version: 11.0

- **Arduino Uno**: 在业余爱好者群体中，最为流行的嵌入式解决方案；它是基于 **ATmega328P** 架构的 **AVR** 单片机

> **AVR** 单片机简史: 1997 年由 **ATMEL** 公司研发出的增强型内置 **Flash** 的 **RISC**(Reduced Instruction Set Computer) 精简指令集高速 8 位单片机。随着 2016 年，**Atmel** 被 **Microchip** 收购， **AVR** 随即成为 **Microchip** 的主力 8 位单片机产品之一。

接下来，我们将借用 **Arduino** 界的 `Hello Word`（即控制 LED 灯闪烁）程序来讲解整个开发过程。 虽然很简单，但是对于新手的话，还有有很多要关注的点。

### 设置你的项目

首先创建一个 Rust 项目：

    $ cargo new rust-arduino-blink

我们需要针对 **AVR** 平台交叉编译我们的项目（平台标识：`avr-unknonw-unknonw`）。为了完成这个操作，我们需要使用 nightly 版的编译工具链，因为我们的项目需要依赖一些不稳定的特性：

    $ rustup override set nightly

上述命令只会对执行这个命令的目录内有效。

然后，我们需要安装一些包：

- `avr-gcc`：链接接器
- `avrdude`：用来上传固件到芯片

在 macOS 下，你需要先执行：

    $ brew tap osx-cross/avr

然后执行安装命令安装指定的依赖：

    $ brew install avr-gcc avrdude

接下来，在 `cargo.toml` 中添加依赖包：

    [dependencies]
    # A panic handler is needed.  This is a crate with the most basic one.
    panic-halt = "0.2.0"
    
    [dependencies.arduino-uno]
    git = "https://github.com/Rahix/avr-hal"

    [profile.dev]
    panic = "abort"
    lto = true
    opt-level = "s"

    [profile.release]
    panic = "abort"
    codegen-units = 1
    debug = true
    lto = true
    opt-level = "s"

`avr-hal` 是一个 Rust 包组合（Cargo Workspace），包含各种各样芯片的驱动包（Crate），`arduino-uno` 就是其中之一。感谢 **Rahix** 把它们整合在一起。

我们需要为 **AVR** 平台添加编译元数据。我们将在项目根目录下创建一个文件 `arv-atmega328.json`，包含的内容如下：

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

并且在 `.cargo/config.toml` 引用它：

    [build]
    target = "avr-atmega328p.json"
    
    [unstable]
    build-std = ["core"]

这样子，我们的构建配置就算完成了。

### 让我们开始写一些代码

现在我们把依赖放一边，让我们加一点代码到 `main.rs` 中，后续将逐步完善它：

    // main.rs
    
    #![no_std]
    #![no_main]

首先，我们需要制定一些全局属性让编译器知道我们在不一样的环境里面。我们使用的是嵌入式环境，很多函数在标准库中是没有的，比如堆内存分配接口，线程以及网络接口等等。因此，我们需要在头部添加 `#![no_std]` 属性。
我们还需要使用 `#![no_main]` 重载默认入口（`fn main()`），因为我们将提供和定义自己的入口程序。我们使用 `arduino_uno` 包中提供的宏，来定义访问入口。通常，支持芯片的包都会为你提供入口宏。

然后，我们使用 `use` 在域内引入需要的依赖：

    extern crate panic_halt;
    use arduino_uno::prelude::*;
    use arduino_uno::hal::port::portb::PB5;
    use arduino_uno::hal::port::mode::Output;

注意到 `panic_halt` 包了吗？这种情况，恐慌（Panic）会导致程序或当前线程通过进入无限循环而暂停.

> 当出现 `panic` 时，程序默认会开始 展开（unwinding），这意味着 Rust 会回溯栈并清理它遇到的每一个函数的数据，不过这个回溯并清理的过程有很多工作。另一种选择是直接终止（abort），这会不清理数据就退出程序。

从应对用户交互到对安全问题（导致的崩溃），嵌入式并没有一种通用的方法来解决所有 `panic` 行为，但是还是抽象出几种常用行为，并封装到 `#[panic_handler]` 函数的包中. 其中包含：

- `panic-abort`：紧急情况会导致执行中止指令.
- `panic-halt`：恐慌会导致程序或当前线程通过进入无限循环而暂停.
- `panic-itm`：恐慌消息是使用ITM（ARM Cortex-M特定的外围设备）记录的.
- `panic-semihosting`：紧急消息使用半主机技术记录到主机.

让我们继续：

    #[arduino_uno::entry]
    fn main() -> ! {
    
    }

我们给我们的 `main` 函数加上了 `entry` 的注解，表示这个函数作为程序的入口。`!` 在 Rust 中称作 Never 类型，意味程序不会返回任何东西，类似 C 语言的 `void`。

为了实现 LED 灯闪烁，我们需要加入几行代码，控制相关引脚（pin）端口电压。现在，我们看一下 **ATmega328P** 芯片的引脚图：

![ATmega328P 芯片的引脚图](https://components101.com/sites/default/files/inline-images/ATMega328P-Arduino-Uno-Pin-Mapping.png)

在上图中，你可以看到芯片中各种各样引脚（pin）。大部分微控制器允许设备对引脚进行读写。他们中一些被分类为 I/O 端口。一个端口代表标准接口的一组引脚（pin）。这些端口受相应端口寄存器控制，也可以认为这是一组可以被代码变更的字节变量。

在 **ATmega328P** 的例子中，我们有三组寄存器：

- C - 模拟引脚（pin） 0 到 5
- D - 数字引脚（pin） 0 到 7
- B - 数字引脚（pin） 8 到 13

具体说明见：[port Manipulation](https://www.arduino.cc/en/Reference/PortManipulation)

如果你现在手上有 uno，你可以看到数字引脚（pin） 13 和内置的 LED 是相连的。我们需要在我们的代码中访问这个引脚（pin）来操控 LED。例如，把它设置成 high 或者 low。

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

上述代码的做了很多事情。

首先，我们创建了一个叫 `Peripherals` 的实例，它是 uno 外围设备列表。`Peripherals` 是连接你的芯片和外部设备、传感器等等的桥梁，比如计时器、计数器、串口等等。嵌入式处理器和外围设备是通过一系列控制器和状态寄存器进行沟通的。

我们通过传递外围设备实例提供的端口，创建了一个新的 `Pin` 实例。然后定义一个 `led` 变量保存 LED 连接的引脚号。传递 `ddr` 寄存器给 `d13` 的 `into_ouput` 方法来配置引脚（pin） 13。

DDR 集群器可以将端口的引脚（pin）指定为输入或者输出。DDR 是一个 8 位寄存器，一位代表 I/O 端口的一个引脚（pin）。举个例子，DDRB 的第一位（bit 0）将决定 PB0 是一个输入或者输出，最后一位（bit 7）将决定 PB7 是一个输入或者输出。为了深入理解 DDR 寄存器，那需要做更多的阅读，不在这里展开了。

接下来，通过在循环（`loop {}`）内调用 `stutter_blink` 函数来决定灯闪烁的次数（这里，我们设置为 `25` 次）。

这里是 `stutter_blink` 的定义：

    fn stutter_blink(led: &mut PB5<Output>, times: usize) {
        (0..times).map(|i| i * 10).for_each(|i| {
            led.toggle().void_unwrap();
            arduino_uno::delay_ms(i as u16);
        });
    }

`stutter_blink` 函数的功能就是通过一个毫秒延迟（`delay_ms`）器调用来开关 `led`。这些在一个迭代器内完成。我通过 `0..times` 来指定一个范围，`map` 来逐步放大倍数，来产生渐变延迟的效果。我们当然可以使用 `for` 循环完成这些，并且可读性更好，但是这里为了演示 Rust 中更多高级接口和抽象。我们可以 0 成本在嵌入式系统使用函数式编程（FP）。据我所知，嵌入式领域只有 Rust 才有。

这里是完整的代码：

    // main.rs
    
    #![no_std]
    #![no_main]
    
    extern crate panic_halt;
    use arduino_uno::prelude::*;
    use arduino_uno::hal::port::portb::PB5;
    use arduino_uno::hal::port::mode::Output;
    
    fn stutter_blink(led: &mut PB5<Output>, times: usize) {
        (0..times).map(|i| i * 10).for_each(|i| {
            led.toggle().void_unwrap();
            arduino_uno::delay_ms(i as u16);
        });
    }
    
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

让我尝试完整编译它：

    $ cargo build

如果一切都安好，你将会看到 `target/avr-atmega328p/debug/` 目录下生成了一个 elf 文件 `rust-arduino-blink.elf`。
这就是我们要写入 uno 中的二进制文件。为了刷 elf 文件，我们需要使用 avrdude 工具。让我们在根目录创建一个名为 `falsh.sh` 的脚本文件，构建完之后将它刷到 uno 固件中：


    #! /usr/bin/zsh
    
    set -e
    
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "usage: $0 <path-to-binary.elf>" >&2
        exit 1
    fi
    
    if [ "$#" -lt 1 ]; then
        echo "$0: Expecting a .elf file" >&2
        exit 1
    fi
    
    cargo build
    avrdude -q -C/etc/avrdude.conf -patmega328p -carduino -P/dev/ttyACM0 -D "-Uflash:w:$1:e"

有了它，我们现在就可以执行了（确保你的 **Uno** 已经连接到的 USB了）：

    ./flash.sh target/avr-atmega328p/debug/rust-arduino-blink.elf

我们的第一个运行 Rust 程序的 **Arduino** 程序完成了！

> 引用自：[How to run Rust on Arduino Uno - Our first blink](https://creativcoder.dev/rust-on-arduino-uno/)