---
layout: post
title: "Coding in Ruby - Starter"
description: ""
category: ruby
tags: [ruby, learning]
---
{% include JB/setup %}

#### Ruby

Ruby 是一种拥有复杂的极具表达力语法的动态语言，还附带丰富强大接口的核心类库。
Ruby 启发于 Lisp，Smalltalk 和 Perl，并且使用便于 C 和 JAVA 程序学习的语法。
Ruby 是纯面向对象的语言，但也适用于过程和函数式编程。它涵盖强大的元编程，也
可以用于创建适用特殊领域的语言(又称 DSL)。

#### Matz

Yukihiro Matsumoto，以网名 Matz 闻名于英语 Ruby 论坛，是 Ruby 语言的创始人，

> Ruby is desingned to make programmers happy - Matz's guiding philosophy

#### Ruby 是面向对象的(Object-Oriented)

在 Ruby 的世界里，任何值都是对象，即使是简单的数值，布尔值 甚至是空值(nil 是
一个特殊的值，它表示一个缺省值 ；它是 Ruby 版的 Null)。

> 在 Ruby 中，注释(comment) 使用 #；在注视仲， => 箭头表示所注视的代码的返回
> 回值说明。

    1.class     # => Fixnum: 整型
    0.0.class   # => Float: 浮点型 
    true.class  # => TrueClass: 真
    false.class # => FalseClass: 假 
    nil.class   # => NilClass: 空

在很多语言中，函数和方法调用需要圆括号，但是在上述代码仲没有包含任何的括号。
在 Ruby 中，括号时常是可选的，通常可以忽略，尤其是调用时不需要传参数的方法。
事实上，括号是可忽略的，使得他们看起来象字段索引或者对象变量。这个是作者有意
的而为之，但是 Ruby 在对象的封装上非常严格；它不允许外部访问对象内部的状态。
如果真需要访问，必须指定访问函数。

#### 块(Blocks)和迭代(Iterators)

事实上，在数字上调用方法并不是 Ruby 深奥的一面。

    3.times { print "Ruby" }    # 打印RubyRubyRuby  => 3 
    1.upto(9) { |x| print x }   # 打印123456789     => 1 

`times`, `upto` 他们是特殊的方法，这样的调用，我们称之为跌代器(Iterators)。

花括号中的代码, 就称作块(Block)。

当然，整型不是唯一拥有跌代器的值。数组(类似枚举对象)也定义了迭代器(`each`)。

    list = [3, 2, 1, 0] #   => [3, 2, 1, 0] 
    list.each do |item|
        print item+1
    end # 打印 4321 => [3, 2, 1, 0] 

还有许多定义在 `each` 之上的跌代器:

    a = [1, 2, 3, 4]    # => [1, 2, 3, 4] 
    a.map { |x| x*x }   # => [1, 4, 9, 16] 
    a.select { |x| x%2==0 } # 选择器 => [2, 4] 

    a.inject do |sum, x|
        sum + x
    end # 计算 => 10

哈希(Hashes)，类似与数组，它也是 Ruby 的基础数据类型。顾名思义，他们是基于哈
希表的数据结构，将特定的键(Key)对象映射到值(Value)对象。

    h = {
        :one => 1,
        :two => 2
      }     # 创建一个哈希数组  => {:one=>1, :two=>2} 
    h[:one]     ＃ 取值,和数组使用方法相似 => 1
    h[:three] = 3   # 追加指,也类似数组 => 3 
    h.each do |key, value|
        print "#{key}, #{value};"
    end # 打印 one, 1;two, 2;three, 3; => {:one=>1, :two=>2, :three=>3}

双引号字符串中包含 Ruby 表达式，它由 #{ 和 } 包围；表达式中的值将被转化成字
符型(通过调用它们的 `to_s` 方法，所有的对象都有这个方法。)。

这种表示值替换成字符的过程，我们通常称之为字符插入(string interpolation).

> #### Effective Ruby
>
> 回忆下学习到的基础数据类型： 
> 
> + 整形
> 
> + 浮点型
> 
> + 真类
> 
> + 假类
> 
> + 字符串
> 
> + 数组
> 
> + 哈希
> 
> 目前学习到的迭代器:
> 
> + 整形
> 
>     + `times`
> 
>     + `upto`
> 
> + 数组/哈希
> 
>     + `each`
> 
>     + `map`
> 
>     + `select`
> 
>     + `inject`

#### Ruby 中的表达式和操作符















