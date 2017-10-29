---
layout: post
title: "这里有你想知道的区块链（Blockchains）- 第一部分"
description: ""
category: New-Tech
tags: [blockchain]
---
{% include JB/setup %}

Ah，**区块链**。

这可是一个很重要的东西。如果你完全不知道，那就要检讨下自己。

她时常过于复杂，过于神秘，超奇异。（我不知道用什么词来正确的描述它，但是很多人都叫她 **区块链**（**Blockchains**）她们到底是什么？加入我们，在这里，我将进行简单粗暴讲解一番；我将尽力确保你离开这里之前，知道下面这个问题的答案：

> 当人们谈论区块链时，他们都在说些什么？

这可能会覆盖很多内容，本文将分成两个部分来一一讲解。

第一个部分，了解下 **区块链** 的数据结构，有哪些属性，以及其他你需要理解的细节。

第二个部分，应用你所学到的实现一个实际广泛的 **区块链** 应用，像强大的分布式账本，加密算法（比如，比特币、莱特币或者像以太坊那样的智能合约）

### 哈希

定义 **区块链** 之前，我们需要理解一个概念。对于他们的工作来说，这个概念是至关重要的，绝对耽误大家的学习进度。

这个概念就是 **哈希**（Hash，记下来的内容都是用这个英文单词）。相关的操作就是 **哈希化**（Hashing），我们得到一个 **Hash**，**Hash** 函数和运行的算法。

这里不会讲解各种不同哈希算法的工作原理，因为它们有很多，足够写好几本书了，而且具体实现对于了解区块链，帮助不大。我们需要关注的是，它们所扮演的角色。

一个 **Hash** 算法是用来帮助把你的数据，无论长的还是短的，转化成相同长度的输出。长度的大小依赖于特定的算法，然而同一种算法都将永远产生相同长度的 **Hash**。

来看一个具体的例子，**SHA256**，一个流行通用的哈希算法。将 **n3xtchen** 哈希化

​	n3xtchen

生成 **SHA256**：

​	![n3xtchen的sha256哈希]()

**小**提示：**SHA256** 中的 **256** 代表实际的输出是 **256** 位，我们一般习惯用十六进制（由 **0-9** 和 **a-f** 构成）来表示 **Hash** - 本文也将使用它。

一旦我们使用 **SHA256** 来执行 **Hash** 操作，“n3xthen” 永远都只会产生相同的输出，以及任何字符串都只会产生 64 个字符长度的 **Hash**。让我们一起看一下，不同长度字符串的输出：

​	这里有你想知道的**区块链**（**Blockchains**）- 第一部分

生成 **SHA256**：

​	![]()

上面对于任何 **Hash** 算法来说，原则都是一样。然而，对于好的 **Hash** 函数，还要满足一下原则：

* **均匀分布**（Uniformity）的意思是我们希望任何我们输出的 **Hash** 在感官上是随机等概率的（或者接近）。也就是说，如果我们使用这个函数计算成千上万个 **Hash**，我们不应该从输出中观察到任何模式。

  由于它最小化了哈希任意两个输入产生同一个输出的风险，均匀分布是非常重要的一个特征。假定这种类型的意外冲突不可能发生的前提下，所有通过 **Hash** 交互的软件之间才能进行有效的沟通。

* **不可逆**（Non-invertibility），根据算法的预期用途，是另一个重要原则。这应该是不可能，或者说非常低概率的。理想状态下，很容易把数据哈希化，但是反过来的话就几乎不可能了。

* **不连续** 要求算法对于类似的输入，应该产生差异很大的 **Hash**。当然也存在特定领域（例如，搜索相关的）的 **Hash** 算法要求连续的（与该原则相对立），但是大部分的 **Hash** 函数要求你尽可能不联系。‘abcdefh’ 和 ‘abcdefg’ 的 **Hash** 之间应该是完全不同，而不是仅仅一个或者几个字符不同。

### 我的第一个区块链

**区块链** 是一种数据结构。

具体点说，是一个用来存储序列数据的数据结构。再具体点，使用一种很难被篡改方式来存储序列的数据结构。

最后一部分也是最重要的——很多数据结构被发明出来，被用于有序地存储数据 —— **数组（Array）**，**链表（Linked List）**，**双链表（Double-Linked List）**，等等。**区块链** 就是在它们的基础上添加了一些特征，来确保如果列表的任一部分被篡改，链都能被识别成无效。它们基本上只是个健壮的列表——没有任何魔法。

一个 **区块链**，就和其他基于列表的数据结构一样，有一个单元（一个区块）构成，它可以存取一个数据包，以及一些有序把区块合并在一起的机制。正如其名。我们把我们的数据打包到整齐的区块中，然后生成一个区块的链。

让我们一起造一个！首先，我们需要数据

![要加密的数据]()

实际放在 **区块链** 中的内容都是有价值的内容。它可以是一堆字符串，就和我们的例子一样；也可以是数千个交易记录的捆绑包，类似场景就是像比特币这样的 **密码币**（cryptocurrency）。至于现在，你只要记住，它基本上和我们的数据种类无关，我只想把它存储在一个通用的格式中。

我们还想要一些关于区块的元数据。它的格式取决于特定区块链的目的，至于我们的例子，在每一个块中，包含一个区块数据。第一个区块是数字 1，第二个是 2，以此类推。

![区块链空白结构]()

在这一点上，一个典型的动态列表结构将会添加一些信息，将多个区块的逻辑链路链接成一个有序序列。通常的形式就是指向存储器中前一个和下一个项目的位置。 我们会继续沿用这个想法。

![添加指针的区块链]()

我们现在有了全功能的 [双链表](https://zh.wikipedia.org/zh-sg/%E5%8F%8C%E5%90%91%E9%93%BE%E8%A1%A8)，它将很好地应用于很多应用。

然而，：每一个区块也存储前一个区块的**哈希**。不连续和随机离散的哈希非常适合检查数据的完整性，因为如果即使输入数据的一位变化，它产生的 **哈希** 也将明显不同。现在填充我们的 **哈希**，完成一个简单但功能完备的 **区块链**。

![填充哈希的区块链]()

这里还有一些东西需要指出。首先，第一个区块链很特别。它的 **“上一个区块”** **哈希** 全部都是 **0**。那是因为不存在上一个区块，因此我们没有东西可以验证。第一个区块时长被叫做**创世纪块（Genesis Block ）**—— 如果你感兴趣的话，你可以看一下比特币的 [创世纪区块](https://blockchain.info/block/000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f)。那里有很多可能对你来说可能不会有实际意义，但是你可以看到 **“上一个区块”** **哈希** 全部为 **0**，就像我们的一样！

其次，要清楚的知道我们所哈希的数据。任何给定区块的**“上一个区块哈希“** 都不仅仅是上一个区块的字符数据。他实际上是 **上一个区块** 的全部数据的 **哈希** —— 元数据，上一个 **哈希** 以及全部。

为了证明这一点（我说过他很重要），看一下第二个区块。他的上一个 **哈希** 是 48b48…e76cb。花一点时间在之前的 **区块链** 寻找。

然后，`SHA256(”I’m a block!")`不等于 48b48...e76cb

![”I’m a block!" 的哈希]()

We reached the 48b48...e76cb hash not by using the string data by itself, but by combining all of: the block number, the previous hash and the string data, in that order. That is, we hashed the string "1" + "00000000...00000000" + "I'm a block!", and in doing so we got the result you can see in the chain:

为了生成 48b48…e76cb 这个 **哈希**，不仅需要字符数据本身，还需要按顺序组和所有的区块。 也就是说，我们把字符串 “1” + “00000000 ... 00000000” + “I’m a block!”，在这样做的时候，我们得到了你可以在链中看到的结果

```
10000000000000000000000000000000000000000000000000000000000000000I'm a block!
```

![上一个块哈希]()

作为简单数据建构进行操作一样，所有这些构成了一个 **区块链** ！链接的区块都包含自己的数据，以及 **上一个区块** 的 **哈希**。

**区块链** 的不同实现是通过使用大量的其他元数据，它们把所有数据都打包到它们区块中，这个是最基本的。在下一篇文章中，我们将进一步探讨如何通过在大型分布式网络中共享这些简单结构来解锁巨大的能力。

目前，很多内容被引入的，因此，我们需要巩固下知识，让我们更多的思考一下我们把整合在一起的简单 **区块链**。 具体来说，正如我之前提到，我想要说明下如何正确地在链中包含的 **哈希** 值使得它能够防止篡改。

### 区块链安全

让我们角色扮演下。我们在一个银行里工作，银行的作用就是把所有的消费记录都存储在 **区块链** 中。之所以这么决定是因为有人告诉他们 **区块链** 被验证出来，没有人不会因为淘气，可以篡改任意一条记录。人们有任何理由做这些事情 —— 把钱转到他们自己的账户上，犯罪目的欺诈别人。如果很容易办到，那就很糟糕了，

我想要讲解清楚我们引入的 **区块链** 的数据结构如何帮助避免此类事情的发生。这里是我们之前使用的区块链，还是拿这个作为例子（从现在开始，为了节省空间，提升展示效率的，我把链表的指针去掉）：

![去掉链表指针的区块链]()

这些区块可能以某种分布式方式存储着 —— 一个区块一个文件，也就是说，你可以自信的认为一个潜在攻击者只能篡改链中的一个或者几个区块。具体实现没那么重要（如果这种自信有那么一点误导你，你就保持这种想法 —— 你迟早会适应密码币群体的）。

你在银行中的工作就是偶尔验证这个交易记录日志，来确保它不会混乱。（或者写一个程序完成这个工作，如果你不想用笔和纸计算很多 **哈希** 的）现在看看具体的过程？

Start at the beginning of the chain. For each block you come to, you're going to calculate the hash of all the data wrapped up in the previous block and compare it to the "previous hash" stored in the current block. If they match, great! Hashes are very fast to calculate so it's no skin off your back to make this check.

从链条的开端开始。对于加入每一个区块，你需要计算前一个区块包含所有数据的 **哈希**，和当前存储的 **上一个哈希** 做对比。如果他们匹配，很好！**哈希** 计算很迅速的，因此对于你来说没有什么成本的。

现在让我们幻想一种场景。我在银行中的工作就是罪犯，尝试盗窃金钱。我碰巧知道 Ingrid 的安脏的夫人，因为我们更新第二个区块，并据为己有。然而，我不能获取其他所有的区块，因此，我只能让他们保持原样。现在的链条看起来像：

![恶意篡改后的区块链]()

When you next come to validate the chain, what do you find? Block 1 checks out, as it always does. Block 2 checks out - it has the correct hash for block 1. That's weird, right? The bad block itself validates just fine. Block 3, however, very much does not check out. You work out the hash of block 2:

当你的下一个验证链的时候，我怎么寻找？区块 1检出，每次都是这么做的。区块链 2 检出 —— 它对于区块 1 来说，是正确的。这很奇怪，对吧？坏的的区块自己可以验证。然而，区块 3 就不能坚持了。你算出了，区块链 2：

```
24fcdb44beb5678169a801f86000aafe8aa0ee3e58e0971ec36f006b8e784aa93Ingrid paid £1000 to JACK
```

![被篡改区块 2 的哈希]()

Woah！区块 3 声称那不是他的 **上一个哈希**！实际上，这根本不行 —— 正常的哈希函数式不连续的。你现在知道链被篡改了。你需要，当你不知道，银行在这种情况下会怎么做 —— 从上一个备份还原链？

我想很恐慌。

How come it was so important to me earlier on that you understand that each block's "previous hash" is the hash of the entire previous block and not just its data string? To see, just go one step further into your validation process and look at block 4. If you've been good and recalculated block 3's "previous hash" to take account of block 2's changes, then you're going to find that block 4's "previous hash" now no longer matches the hash of block 3! This is because part of block 3 has changed - namely, the "previous hash" referring to block 2.

See how the hash-chaining mechanism of a blockchain means that even a single corrupt or tampered-with block will invalidate the entire chain after it. Cool, right? If each block only had the hash of the previous block's content, but not its metadata too, then in our example block 3 would have told us something was amiss, but block 4 would have checked out as good again. A much weaker state of affairs, I hope you agree.

Now...

## Go take a break

And so will I. To write the second half of this rundown.

In this part, we've learned about hashes, and the structure of a basic blockchain. We've also taken a look at an only-a-bit-contrived example of how a blockchain can provide security that a more basic list structure can't, using the power of hashes for data integrity checks.

Next time, we'll see how blockchains are being applied to great effect (and huge financial value) in the real world. Starting with the grand-daddy of cryptocurrencies, Bitcoin, we'll learn about proof-of-work and distributed ledgers to find out how you can make a functioning decentralised currency using a blockchain. Then, finally, I'll cover the basics of the even-more futuristic smart-contract blockchains emerging to generalise the concept to more than just currency, like Ethereum.

Thanks for reading!

> 译自 https://unwttng.com/what-is-a-blockchain