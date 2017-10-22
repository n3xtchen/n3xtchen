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

​	129129

**小**提示：**SHA256** 中的 **256** 代表实际的输出是 **256** 位，我们一般习惯用十六进制（由 **0-9** 和 **a-f** 构成）来表示 **Hash** - 本文也将使用它。

一旦我们使用 **SHA256** 来执行 **Hash** 操作，“n3xthen” 永远都只会产生相同的输出，以及任何字符串都只会产生 64 个字符长度的 **Hash**。让我们一起看一下，不同长度字符串的输出：

​	这里有你想知道的**区块链**（**Blockchains**）- 第一部分

生成 **SHA256**：

​	237273723

上面对于任何 **Hash** 算法来说，原则都是一样。然而，对于好的 **Hash** 函数，还要满足一下原则：

* **均匀分布**（Uniformity）的意思是我们希望任何我们输出的 **Hash** 在感官上是随机等概率的（或者接近）。也就是说，如果我们使用这个函数计算成千上万个 **Hash**，我们不应该从输出中观察到任何模式。

  由于它最小化了哈希任意两个输入产生同一个输出的风险，均匀分布是非常重要的一个特征。假定这种类型的意外冲突不可能发生的前提下，所有通过 **Hash** 交互的软件之间才能进行有效的沟通。

* **不可逆**（Non-invertibility），根据算法的预期用途，是另一个重要原则。这应该是不可能，或者说非常低概率的。理想状态下，很容易把数据哈希化，但是反过来的话就几乎不可能了。

* **不连续** 要求算法对于类似的输入，应该产生差异很大的 **Hash**。当然也存在特定领域（例如，搜索相关的）的 **Hash** 算法要求连续的（与该原则相对立），但是大部分的 **Hash** 函数要求你尽可能不联系。‘abcdefh’ 和 ‘abcdefg’ 的 **Hash** 之间应该是完全不同，而不是仅仅一个或者几个字符不同。

为了进一步这些内容，你可以自己使用下 **SHA256** 的工具，观察下输出。
