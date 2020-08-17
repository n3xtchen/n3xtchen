---
layout: post
title: "浏览器之外的 WebAssembly —— 第一部分"
description: ""
category: Rust
tags: [wasm]
---
{% include JB/setup %}

你现在找到的大部分 **WebAssembly** 教程和例子都是聚焦在浏览器之中，比如如何加速网页或者网页应用各种各样的功能。无论如何，**WebAssembly** 真正强大的领域但是被提及的很少：在浏览器之外的场景；也是我们接下来系列关注的点。

### 什么是 WebAssembly？

网页界的朋友总是爱给新生事物起名字，但是总是起的不好（web-gpu 是另一个例子）。**WebAssembly** 既不是网页（Web）也不是汇编器（Assembly），而是从 C++、 C#、Rust 之类的编程语言编译出来的字节码。简单来说，你可以写一些 Rust 代码，然后把它编译成 **WebAssembly** 字节码，最后在 **WebAssembly** 虚拟机中运行该代码。

它真正强大的原因是你不用再自己编写垃圾回收代码，而是将 Rust 或者 C++ 作为脚本语言来使用。因为它可以想 LUA/JavaScript 那样不在需要自行垃圾回收，**WebAssembly** 具有更可预测和更稳定的性能。

它是相对较新的食物，所以还很粗糙，尤其在浏览器之外的场景。我的使用经验中，把这些最粗糙的点一一下来，这就是我写这些博客的原因。记录我的发现，希望能帮助到可能对这个项目感兴趣的人。

### 为什么我们要在浏览器之外运行 **WebAssembly**

浏览器之外，它的主要优势就是可以用不用妥协安全的前提下提供系统级别的访问。它是通过 WASI完成的；Web Assembly System Interface（WASI 全称，大致意思就是 WebAssembly 系统接口）是一个类 C 的函数集，在安全的方式提供功能性的系统访问，如 fd_read，rand，fd_write，thread(WIP) 等等。

这里举出一些你可能使用的场景（当然是非浏览器场景）：

- 视频游戏的脚本语言；
- 最低负载运行代码，就像 Fastly/Cloudflare 的边缘计算（compute-at-edge）场景；
- 最低运行负载在 IOT 设备安全地运行易于更新的代码；
- 不需要 JIT 就能在你的环境中获取极快的性能；

### 前置要求

为了保证本次探险的最佳体验，我建议使用 Visual Studio Code 作为你的 IDE，并且安装如下扩展：

- rust-analyzer：自动补齐和其他很棒的功能
- Code-LLDB：使用 LLDB 进行 debug
- WebAssembly by the WebAssembly foundation：允许你反编译和查看 .wasm 字节码

### 选择一个虚拟机

首先，你需要一个可以运行 **WebAssembly** 程序的虚拟机（VM）。这个 VM 可以被嵌入，因此你可以把它加到你的游戏引擎，或者在你的主程序中调用它。这些提供一些选择：WASM3，Wasmtime，WARM 等等。他们的特性各不相同，比如支持 JIT，使用尽可能少的内存等等；你需要选择其中一个来匹配你的目标平台和场景。

选择 VM 时你仅需关注运行属性和 debug的异常。支持无缝衔接的 debug 经验的 VM 只有 Wasmtime（这是另一个毛刺）。所以即使你由于某种限制，不打算把它部署在你的程序，我也建议你使用它作为 debug VM。无论何时你想要 debug 一些 WASM 代码，那你可以在 Wasmtime 载入它。

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