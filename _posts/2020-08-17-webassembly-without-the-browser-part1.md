---
layout: post
title: "面向非浏览器领域的 WebAssembly"
description: ""
category: Rust
tags: [wasm]
---
{% include JB/setup %}

你现在找到的大部分 **WebAssembly** 教程和例子都是聚焦在浏览器之中，比如如何加速网页或者网页应用各种各样的功能。无论如何，**WebAssembly** 真正强大的领域但是被提及的很少：浏览器之外的领域；也是我们接下来系列关注的点。

### 什么是 WebAssembly？

网页界的朋友总是爱给新生事物起名字，但是总是起的不好（web-gpu 是另一个例子）。**WebAssembly** 既不是网页（Web）也不是汇编器（Assembly），而是从 C++、C#、Rust 之类的编程语言编译出来的字节码。简单来说，你可以写一些 **Rust** 代码，然后把它编译成 **WebAssembly** 字节码，最后在 **WebAssembly** 虚拟机中运行该代码。

它真正强大的原因是你不用再自己编写垃圾回收代码，而是将 **Rust** 或者 C++ 作为脚本语言来使用。因为它可以像 LUA/JavaScript 那样不在需要自行垃圾回收，**WebAssembly** 具有更可预测和更稳定的性能。

它是相对较新的食物，所以还很粗糙，尤其在浏览器之外的场景。我的使用经验中，把这些最粗糙的点一一下来，这就是我写这些博客的原因。记录我的发现，希望能帮助到可能对这个项目感兴趣的人。

### 为什么我们要在浏览器之外运行 **WebAssembly**

浏览器之外，它的主要优势就是可以用不用妥协安全的前提下提供系统级别的访问。它是通过 `WASI` 完成的；Web Assembly System Interface（WASI 全称，大致意思就是 **WebAssembly** 系统接口）是一个类 C 的函数集，在安全的方式提供功能性的系统访问，如 `fd_read`、`rand`、`fd_write`、线程(WIP) 等等。

这里举出一些你可能使用的场景（当然是非浏览器场景）：

- 视频游戏的脚本语言；
- 最低负载运行代码，就像 Fastly/Cloudflare 的边缘计算（compute-at-edge）场景；
- 最低运行负载在 IOT 设备安全地运行易于更新的代码；
- 不需要 JIT 就能在你的环境中获取极快的性能；

### 前置要求

为了保证本次探险的最佳体验，我建议使用 **Visual Studio Code** 作为你的 **IDE**，并且安装如下扩展：

- `rust-analyzer`：自动补齐和其他很棒的功能
- `Code-LLDB`：使用 LLDB 进行代码调试
- `WebAssembly by the WebAssembly foundation`：允许你反编译和查看 `.wasm` 字节码

### 选择一个虚拟机

首先，你需要一个可以运行 **WebAssembly** 程序的虚拟机（VM）。这个虚拟机（VM）可以被嵌入，因此你可以把它加到你的游戏引擎，或者在你的主程序中调用它。这些提供一些选择：**WASM3**，**Wasmtime**，**WARM** 等等。他们的特性各不相同，比如支持 JIT，使用尽可能少的内存等等；你需要选择其中一个来匹配你的目标平台和场景。

选择虚拟机（VM）时你仅需关注运行属性和调试异常。支持无缝衔接的调试模式的虚拟机（VM）只有 **Wasmtime**。所以即使你由于某种限制，不打算把它部署在你的程序，我也建议你使用它作为调试虚拟机（VM）。无论何时你想要代码调试 WASM 代码，你都可以在 **Wasmtime** 载入它。

### 编写你的第一个 WebAssembly 程序

首先，我们需要创建一个 `lib` 项目：

    cargo new --lib wasm_examply

在 `Cargo.toml` 中加入如下代码：

    [lib]
    crate-type = ["cdylib"]

现在我们编辑 `lib.rs`：

    #[no_mangle]
    extern "C" fn sum(a: i32, b: i32) -> i32 {
        let s = a +b
        println!("FROM WASM: Sum is: {:?}, s);
        s
    }

这个函数接受两个数字，相加，返回结果之前打印结果。**WebAssembly** 在模块载入之前，不需要定义默认函数，因此，你可以在主程序中通过它的签名来获取一个函数，然后执行它（这个类似 `dlopen`/`dlsym` 的工作机制）。

我们使用 `[#no_mangle]` 和 `pub extern "C"` 把 `sum` 这个函数在 **C** 中可调用。如果你在浏览器教程中编译它，你可能会提示我们不在需要使用 `wasm-bindgen`。

### 如何编译它呢？

Rust 支持两种个目标平台（Target）：
- `wasm32-unknown-unknown`：标准的 **WebAssembly** 系统。你可以把它当作 **WebAssembly** 的 `#no-std`；它主要用于浏览器，它假设任何系统调用都不可用
- `wasm32-wasi`：假设虚拟机（VM）暴露了 `WASI` 功能，允许标准库的不同实现可以被使用（这个实现的可用性依赖于 `WASI` 函数）。

你可以看一下 **Rust** 标准库的可用实现：https://github.com/rust-lang/rust/tree/master/library/std/src/sys。这个是你在运行 **WebAssembly** VM 时，**Rust** 程序可用的 `WASI` 函数：https://github.com/rust-lang/rust/tree/master/library/std/src/sys/wasi。

现在我们编译成 `wasm32-wasi`：

    # 只要执行一次
    $ rustup target add wasm32-wasi

    # Compile for the wasm32-wasi target.
    $ cargo build --target wasm32-wasi

### 但是 `println!` 如何工作呢？

你可能已经注意到我们调用 `print!` 时，期望程序可以工作，并且打印到终端中，但是 **WebAssembly** 程序如何知道怎么运行呢？

这就是我们使用 `wasm32-wasi` 的原因。这个目标平台为 **Rust** 标准库选择目标系统存在对应版本的函数。打印到终端意味着写到一个特殊的文件标识符中。包括 `wasm32-wasi` 在内，大部分的虚拟机（VM）默认都允许，因此我们不需要做特殊的设置。

如果你在 **VSCode** 安装了对应插件，你只需要右击选择 `target/wasm32-wasi/debug/wasm_example.wasm`，然后选择 `Show WebAssembly`，将会像下面一样，有一个新的文件被自动打开：

    (module
      ....
      (type $t15 (func (param i64 i32 i32) (result i32)))
      (import "wasi_snapshot_preview1" "fd_write" (func $_ZN4wasi13lib_generated22wasi_snapshot_preview18fd_write17h6ec13d25aa9fb6acE (type $t8)))
     (import "wasi_snapshot_preview1" "proc_exit" (func $__wasi_proc_exit (type $t0)))
      (import "wasi_snapshot_preview1" "environ_sizes_get" (func $__wasi_environ_sizes_get (type $t2)))
      (import "wasi_snapshot_preview1" "environ_get" (func $__wasi_environ_get (type $t2)))
      (func $_ZN4core3fmt9Arguments6new_v117hb11611244be67330E (type $t9) (param $p0 i32) (param $p1 i32) (param $p2 i32) (param $p3 i32) (param $p4 i32)
        (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i32) (local $l10 i32)
       global.get $g0
        local.set $l5
      ...

这是一个 `wat` （全称是 WebAssembly text format）文件。它有点像反编译的 x64/ARM ASM 指引，丑陋难以理解。由于 **WebAssembly** 的创建者不能决定文本格式，所以他们只能用丑陋的 S-表达式 来展现。

这个导入语句告诉我们 WASM 程序需要如下函数存在于 `wasi_snapshot_preview1` 命名空间内才能运行：`proc_exit`、`fd_write`、`environ_get`、`environ_sizes_get`。所有的导入或到处的函数需要一个命名空间。`wasi_snapshot_preview1` 是 `WASI` 的命名空间，因此你可以把它当作这些函数的预留命名空间。`println!` 需要 `wasi_snapshot_preview1::fd_write` 来输出到标准输出。

### 宿主（host）程序

你可以选择任何包含 `WASI` 的虚拟机（VM）。为了展示如何调试 **WebAssembly**，我将使用 **Wasmtime**（这是唯一一个支持调试的虚拟机（VM））。

这个程序从路径 `examples/wasm_example.wasm` 载入 wasm 二进制文件。这个文件是你之前编译好的，你可以在 `wasm_example/target/wasm32-wasi/debug/wasm_example.wasm`。**运行宿主程序的时候，请确保它的放置位置正常。**

这里是宿主程序（**Rust**）的完整代码，它包含初始化 **Wasmtime** 虚拟机（VM），载入模块，链接 `WASI`，装载和执行从 WASM 模块带出的 `sum` 函数:

    use std::error::Error;
    use wasmtime::*;
    use wasmtime_wasi::{Wasi, WasiCtx};

    fn main() -> Result<(), Box<dyn Error>> {
        // Store 在某种场景下是一种全局对象，常用更多方式就是传递给大部分构造函数
        let engine = Engine::new(Config::new().debug_info(true));
        let store = Store::new(&engine);

        // 从文件载入模块
        let module = Module::from_file(&engine, "examples/wasm_example.wasm")?;

        // 链接 WASI 模块到我们的虚拟机。Wasmtime 我们决定 WASI 是否可见
        // 因此我们需要在这里载入它， 我们的模块需要某个函数在 wasi_snapshot_preview1 命名空间里可见
        // 这个操作使得 println! 可用。（它使用的是 fd_write）
        let wasi = Wasi::new(&store, WasiCtx::new(std::env::args())?);
        let mut imports = Vec::new();
        for import in module.imports() {
            if import.module() == "wasi_snapshot_preview1" {
                if let Some(export) = wasi.get_export(import.name()) {
                    imports.push(Extern::from(export.clone()));
                    continue;
                }
            }
            panic!(
                "couldn't find import for `{}::{}`",
                import.module(),
                import.name()
            );
        }
        // 获取模块后，我们需要初始化它
        let instance = Instance::new(&store, &module, &imports)?;

        // 通过 instance 获取 sum 签名
        let main = instance.get_func("sum")
            .expect("`main` was not an exported function");

        // 将签名转化成可调用的函数
        let main = main.get2::<i32, i32, i32>()?;

        let result = main(5, 4)?;
        println!("From host: Answer returned to the host VM: {:?}", result);
        Ok(())
    }

这个项目需要的依赖：

    [dependencies]
    wasmtime = "0.19"
    wasmtime-wasi = "0.19"
    anyhow = "1.0.28"

执行它，并且看到如下输出：

    $ cargo run
    Compiling wasm_host v0.1.0 (wasm_host)
    Finished dev [unoptimized + debuginfo] target(s) in 35.38s
    Running `target\debug\wasm_host.exe`
    From WASM: Sum is: 9
    From host: Answer returned to the host VM: 9

我们发现 `wasm` 模块的 `println!` 可以正确地答应到终端，并且返回的结果就是预期的 `9`.

### 结语

在这个教程中，我们已经学会如何在浏览器之外编译 **WebAssembly** 程序，配置一个宿主程序，载入入和运行你的 WASM 二进制代码，执行从 WASM 导出的函数。在下一个部分，我们将接触到代码调试，优化程序大小，从主程序虚拟机（VM）暴露函数给 WASM 程序，以及两个虚拟机（VM）间的内存共享。