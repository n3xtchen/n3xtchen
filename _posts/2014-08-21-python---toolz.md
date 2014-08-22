---
layout: post
title: "Python - Toolz - 流式分析（Streaming Analytics）工具"
description: ""
category: Python
tags: [toolz, analytics]
---
{% include JB/setup %}

`Toolz` 可以用于编写分析大型数据流脚本，它支持通用的分析模式，如通过纯函数来对数据进行筛选（Selection），分组（Grouping），化简（Reduction）以及连表（Joining）。这些函数通常可以模拟类似其他数据分析平台（如 `SQL` 和 `Panda`）的类似操作行为。

我将使用下面简单的数据集作为演示数据，贯穿全文

	>>> #           id, name, balance, gender
	>>> accounts = [(1, 'Alice', 100, 'F'),
	...             (2, 'Bob', 200, 'M'),
	...             (3, 'Charlie', 150, 'M'),
	...             (4, 'Dennis', 50, 'M'),
	...             (5, 'Edith', 300, 'F')]
	
## 使用 `Map` 和 `Filter` 来筛选数据

通过标准函数 `map` 和 `filter` 能够完成对列表简单的映射和筛选

	SELECT name, balance
	FROM accounts
	WHERE balance > 150;
	
下面的函数能够满足 `SQL` 的 `SELECT` 和 `WHERE` 需求

	>>> from toolz.curried import pipe, map, filter, get
	>>> pipe(accounts, filter(lambda (id, name, balance, gender): balance > 150),
	...                map(get([1, 2])),
	...                list)
	
它使用了 `map` 和 `reduce` 的加里化（curried）版本。

当然，这些操作也能很好的支持标准的列表（List）和生成器（Generator）的组合语法。这个语法会经常被使用，并通常被认为非常的 Pythonic

	>>> [(name, balance) for (id, name, balance, gender) in accounts
	...                  if balance > 150]

## 使用 `groupby` 和 `reduceby` 完成 Split-apply-combine

我们把 Split-apply-combine 拆分成下面两个概念：

* 根据一些特征将数据拆分到不同组中
* 使用聚合函数对每一个分组进行化简

`Toolz` 支持这种工作流：

* 简单的内存计算方案
* 更复杂的流式计算方案

### 使用内存计算进行 Split-apply-combine

内存计算方案使用 `groupby` 进行分割数据（Split），和 `valmap` 来应用／组合（apply/combine）

	SELECT gender, SUM(balance)
	FROM accounts
	GROUP BY gender;

我们首先使用 `groupby` 和 `valmap` 来分别展示中间结果

	>>> from toolz import groupby, valmap, compose
	>>> from toolz.curried import get, pluck
	>>> groupby(get(3), accounts)
	{'F': [(1, 'Alice', 100, 'F'), (5, 'Edith', 300, 'F')],
 	'M': [(2, 'Bob', 200, 'M'), (3, 'Charlie', 150, 'M'), (4, 'Dennis', 50, 'M')]}
	>>> valmap(compose(sum, pluck(2)),	
	...        _)
	{'F': 400, 'M': 400}
	
然后我们把他们组合在一起

	>>> pipe(accounts, groupby(get(3)),
	...                valmap(compose(sum, pluck(2))))
	{'F': 400, 'M': 400}
	
### 使用流式计算进行 Split-apply-combine

groupby 使用内粗将所有的数据实体存储到字典中。虽然方便，然而它不会流式的，因此这种方法受限于机子的内存。

`Toolz` 通过 `reduceby` 来实现流式的 Split-apply-combine，就像元素流入一样，它并行对每一个分组进行化简处理。为了理解这个概念，你首先应该熟悉内置的 reduce 函数。

`reduceby` 操作接受一个获取键的函数（如 `get(3)` 或者 `lambda x: x[3]`）, 和一个二元运算符（如 `add` 或者 `lesser = lambda acc, x: acc if acc <  x else x`）。它可以连续将获取键的函数应用到每一个项中，通过使用二元运算符将之前的总数结合新的值，为每一个键汇总出总数。由于需要一次性反问全部分组，它不能接受全化简操作（如 `sum` 和 `min`）。这里是一个简单的例子：

	>>> from toolz import reduceby
	
	>>> def iseven(n):
	...     return n % 2 == 0
	
	>>> def add(x, y):
	...     return x + y
	
	>>> reduceby(iseven, add, [1, 2, 3, 4])
	{True: 6, False: 4}
	
偶数会被加到 `True` 的分组中（2 + 4 =6），奇树会被加到 `False` 的分组中（1 + 3 = 4）。

注意，我们已经使用二元运算符 `add` 替换化简函数 `sum`。 但新的值被传入，`add` 的渐进性允许我们做汇总操作。二元操作符（如 add ）比全化简操作（如 `sum`）更能处理大型数据流。

使用 reduceby 的挑战主要在于构建合适的二元操作符。这里有一个解决方案来解决汇总每一个分组的收支

	>>> binop = lambda total, (id, name, bal, gend): total + bal

	>>> reduceby(get(3), binop, accounts)
	{'F': 400, 'M': 400}
	
这个构造器可以支持比可用内存大很多的数据集合。不过输出必须符合内存问题，不过即使是在非常大的 split-apply-combine 的计算中，这个问题很少见。

## 伪流式 `join`

我们通过 `Join` 将多个数据集整合在一起。假设，第二个数据用来存储地址，并给予主键 ID

	>>> addresses = [(1, '123 Main Street'),  # id, address
	...              (2, '5 Adams Way'),
	...              (5, '34 Rue St Michel')]

我们可以将它与我们的账户数据连表，通过指定连接两张表的共同键；在这个例子中，他们共同字段是 ID 字段

	SELECT accounts.name, addresses.address
	FROM accounts, addresses
	WHERE accounts.id = addresses.id;
	
 <br/>	


	>>> from toolz import join, first, second

	>>> result = join(first, accounts,
	...               first, addresses)

	>>> for ((id, name, bal, gender), (id, address)) in result:
	...     print((name, address))
	('Alice', '123 Main Street')
	('Bob', '5 Adams Way')
	('Edith', '34 Rue St Michel')

`Join` 需要传入四个参数，获取左右键函数和左右数据流。它返回包含多对匹配项的序列。在我们例子中，'Join` 的返回值是一个一对第一个元素（即 ID）匹配的项的列表。

### 可以 `join` 任意的函数和数据

它类似于 `SQL`，习惯于对列的 `Join`。无论如何，函数式的 `Join` 比它更加的通用；它不需要操作数组，键函数不需要获取特定的列。在下面的例子中，我们匹配两个数组的数字，一个奇偶数对。

	>>> def iseven(n):
	...     return n % 2 == 0
	>>> def isodd(n):
	...     return n % 2 == 1

	>>> list(join(iseven, [1, 2, 3, 4],
	...           isodd, [7, 8, 9]))
	[(2, 7), (4, 7), (1, 8), (3, 8), (2, 9), (4, 9)]

### 伪流式 `Join`

`Toolz` `Join` 操作是将左边的序列保存在内存中，流式处理右边的序列；因此，如果想要更接近流式处理，传入的两个序列中最大的那个应该放在 `Join` 右边。

	join(func1, smaller, func2, larger)
	

### 具体算法

`Toolz` `Join` 的伪流式操作已经接近最优。 计算速度和输入输出的容量大小程线性相关。左边的序列必须装进内存（换句话说，就是受限于你的内存），而右边采用流式，几乎不受限于你的内存容量。

不像 `SQL` 那样一定要范式化，结果是允许重复的值。如果需要范式化，考虑使用 `unique` 函数（注意，它不是完全流式化的）。

### 更复杂的例子

上面例子账户的例子的 `accounts` 和 `addresses` 是一一对应的关系；每个 ID 一个任命，每个 ID 一个地址。但现实生活中并不是这样的。`Join` 需要足够的灵活来处理一对多甚至多对多的关系。下面的例子找出城市/人的对应关系；一个人有一个朋友，这个朋友在市区有一个住所。这是一个多对多关系例子，因为一个人会有多个朋友，一个朋友会有多个住所。

	>>> friends = [('Alice', 'Edith'),
	...            ('Alice', 'Zhao'),
	...            ('Edith', 'Alice'),
	...            ('Zhao', 'Alice'),
	...            ('Zhao', 'Edith')]
		
	>>> cities = [('Alice', 'NYC'),
	...           ('Alice', 'Chicago'),
	...           ('Dan', 'Syndey'),
	...           ('Edith', 'Paris'),
	...           ('Edith', 'Berlin'),
	...           ('Zhao', 'Shanghai')]
	
	>>> # Vacation opportunities
	>>> # In what cities do people have friends?
	>>> result = join(second, friends,
	...               first, cities)
	>>> for ((name, friend), (friend, city)) in sorted(unique(result)):
	...     print((name, city))
	('Alice', 'Berlin')
	('Alice', 'Paris')
	('Alice', 'Shanghai')
	('Edith', 'Chicago')
	('Edith', 'NYC')
	('Zhao', 'Chicago')
	('Zhao', 'NYC')
	('Zhao', 'Berlin')
	('Zhao', 'Paris')

Join 具有强大的计算能力：

* 它在涵盖大量的分析操作上表现力丰富。
* 它的执行时间和输出输入的容量大小呈线性关系。
* 只有左边的序列需要放在内存中。

## 结语

Toolz 为扁平的 Python 结构进行数据分析时，提供更紧凑的类型。CyToolz 通过 Cython 加速了整个工作流。这种方法使用起来低技术含量，并通过流媒体来支持大数据处理。

同时，Toolz 是一个通用的函数式标准库，并不是仅仅为了数据分析。然而，对于对数据分析感兴趣的用户，有明显的优势（流式化，组合等等），可能在某些场景比使用专门用于分析的项目（如 Pandas 和 SQLAlchemy）。

> 参考：
> 
> 	* http://matthewrocklin.com/blog/work/2014/07/04/Streaming-Analytics/
