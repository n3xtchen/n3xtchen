---
date: "2019-01-22T10:27:57Z"
draft: true
title: dnn-for-interview
---

# softmax 函数

softmax函数的本质就是将一个K维的任意实数向量压缩（映射）成另一个K维的实数向量，其中向量中的每个元素取值都介于（0，1）之间。

softmax函数经常用在神经网络的最后一层，作为输出层，进行多分类。

$$
Softmax(i) = \frac{e^{V_i}}{\sum_j e^{V_j}}
$$

sigmoid 具体针对的是二分类问题，而 softmax 解决的是多分类问题，因此从这个角度也可以理解 sigmoid 函数是 softmax 函数的一个特例。

# 神经网络为什么会产生梯度消失现象？

激活函数的导数小于 1，那么随着层数的增加，求出梯度更新信息将会以指数形式衰减。

# 常见的激活函数有哪些？都有什么特点？（知识）

# 挑一种激活函数推导梯度下降的过程。（知识+逻辑）

# Attention机制什么？（知识）

# 阿里是如何将attention机制引入推荐模型的？（知识+业务）

# DIN是基于什么业务逻辑引入attention机制的？（业务）

# DIN中将用户和商品进行了embedding，请讲清楚两项你知道的embedding方法。（知识）

# 你如何serving类似DIN这样的深度学习模型(工具+业务)
