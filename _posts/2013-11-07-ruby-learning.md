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

Ruby 的语法是面对表达式的(expression-oriented)。控制结构例如 `if` 在其他语言中
叫做声明语句(Statements)，但在 Ruby 实际上就是表达式。

    minimun = if x < y then x else y end

虽说所有的语句在 Ruby 中都是表达式，但是它们并不是都返回有意义的值。例如， 
`while` 循环和方法定义是表达式，它一般返回 `nil` 值。

和其他语言一样，Ruby 表达式由值和操作符(Operator)组成。大部分操作符和 C, Java 系
的语言类似。

    1 + 1   # => 2 
    1 * 2   # => 2 
    1 + 2 == 3  # 判断 => true 
    2 ** 8  # N次方 => 256 
    "cool" + " Ruby"    # 字符拼接  => "cool Ruby" 
    "Ruby" * 3  # 重复字符，注意和数字不同 => "RubyRubyRuby" 
    "%d %s" % [2, 'rubies'] # 格式化字符 => "2 rubies" 

很多操作符都是作为方法实现的，类可以根据你的想法定义(重定义)这些方法。`*` 就是个
很好的例子，在字符和数值的行为完全不同。`<<` 也是一个很好的例子；整型使用它进行
移位操作，这个和 C 的语法一致。与此同时，象 C++ 一样，string，数组和流(stream)
可以使用这个操作符进行追加操作。

还有一个可以覆盖的强大的操作符就是 `[]`。 在数组和哈希类中用这个来访问元素。但是
你能在你的类中重定义它。<!--You can even define it as a method that expects multiple 
arguments, comma-separated between the square brackets. (The Array class accepts an 
index and a length between the square brackets to indicate a subarray or “slice” 
of the array.) And if you want to allow square brackets to be used on the lefthand 
side of an assignment expression, you can define the corresponding []= operator. 
The value on the righthand side of the assignment will be passed as the final argument 
to the method that implements this operator-->

#### 方法(methods)

使用 `def` 定义方法；方法的返回值是该方法定义块的最后一个表达式。

    def sayHiTo(name)
        print "Hi, "+name
        true
    end # => nil

    sayHiTo('N3xtchen') # 打印 Hi, N3xtchen => true

上述方法定义在类和模块的外部，他的影响范围是全局的。(从技术角度来说，方法应该作用在对象
中比较科学。)

如何在外部定义类和模块的方法的，(当然，这些类和模块是开放的，允许在运行时外部被修改)?我们
可以通过方法冠以类名，使用 . 来分隔。 

    def Math.square(x)
        x*x
    end

> Math 是 Ruby 集成的核心库，它允许外部给他添加新方法。

方法参数可以制定默认值，它智能接受指定个数的参数。

#### 赋值(Assignment)

    x =1    # => 1 
    x += 1  # 可以和操作符组合使用 => 2 
    x -= 1  # => 1 
    x, y = 1, 2 #  => [1, 2] 
    x, y = y, x # 变量交换值 => [2, 1] 
    x, y, z = [1, 2, 3] # => [1, 2, 3] 
    x = Math.square(2)  # 调用函数赋值 => 4
    Math.x  = 1 # 给对象属性赋值 => 1

#### 前置和后置标点(Punctuation Suffixes and Prefixs)


#### 正则(Regexp) 和 范围(Range)

先前，我们提到了数组和哈希作为 Ruby 的基础数据类型；还演示了字符和数字的方法。还有两个数据
类型值得关注。

正则表达式(Regular Expression) 用来描述文本模型，并拥有匹配的函数。正则表达式由 `/` 包围。
注意，匹配的是字符型。

范围(Range) 呈现的是值是否落在某个区间, 匹配的是数值。

他们都是使用 `===` 测试匹配，返回布尔值。

    # 正则
    /[Rr]uby/ === "Ruby"    # 匹配成功 => true 
    /[Rr]uby/ === "ruby"    # 匹配成功 => true 
    /[Rr]uby/ === "wrong"   # 匹配失败 => false 
    /\d{5}/ === "11111"     # 匹配成功 => True
    # 范围
    range = 1..3    # 大等于1，小等于3 => 1..3
    range === 1     # => true 
    range === 3     # => true 
    range === 0     # => false 
    range === 4     # => false 

    range = 1...3   # 大等于1，小于3 => 1...3
    range === 1     # => true 
    range === 3     # => false 
    range === 0     # => false 
    range === 4     # => false 

这里，我们可能会用到 Case 条件语句(和 C 的 Swtich 语句类似)。
现在我们可以尝试写一个小程序:


    # Short description for generation.rb
    # 
    # @package case
    # @author n3xtchen <echenwen@gmail.com>
    # @version 0.1
    # @created in 2013-11-08 14:46
    def enterYouBirthYear?
        while true
            print "Enter Your Birth Year[yyyy]: "
            year    = gets
            case year
            when /\d{4}/
                return year.to_i
            end
        end
    end

    def whichGeneration(year)
        generation = case year
        when 1946..1963 
            "Baby Boomer"
        when 1964..1976 
            "Generation X"
        when 1978..2000 
            "Generation Y"
        else 
            nill
        end
    end

    year    = enterYouBirthYear?
    print "I am born in #{year}!"
    generation  = whichGeneration(year)
    print "I am "+generation+"!"

运行它！

    $ ruby generation.rb
    Enter Your Birth Year[yyyy]: 1987
    I am born in 1987!I am Generation Y!
