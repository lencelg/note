---
author: lencelg from Arcadia Bay
title: note of python data science book set
---
PS: 这是一套书籍，很多内容, 每周抽点时间看一看

>立个flag: 完成这个note

# 第一本书数据科学入门第二版
# Introduction
上来就介绍了数据科学，首先是数据，然后根据需求对数据操作，例子是朋友关系的图， 书中做了一个图

展示了数据科学的大致内容

# python速成
我有python基础, 这一章节的内容记录部分

---

about Counter

```python
from collections import Counter
c = Counter([0, 1, 2, 0]) # c是（基本的）{0: 2, 1: 1, 2: 1}
```

---

about re

```python
# all the statements are true
re_examples = [
    not re.match("a", "cat"),               # 'cat'不以'a'开头
    re.search("a", "cat"),                  # 'cat'里面有一个'a'
    not re.search("c", "dog"),              # 'dog'中没有'c'
    3 == len(re.split("[ab]", "carbs")),    # 在'carbs'中去掉'a'和'b'，则剩下
    "R-D-" == re.sub("[0-9]", "-", "R2D2")  # 长度为3 用破折号替换数字
]
```
---

about zip

```python
list1 = ['a', 'b', 'c']
list2 = [1, 2, 3]

# same as pairs = [('a', 1), ('b', 2), ('c', 3)]
[pair for pair in zip(list1, list2)]

# use * to do argument unpacking
letters, numbers = zip(*pairs)
# letters content == list1 content, numbers content == list2 content
```

# 数据可视化
这一章介绍 matplotlib 的几种常见的图形，都是一些简单的例子

下面记录图形的类别
* 线图
* `bar` : 条形图
* `scatter`: 散点图

# 线性代数
这一章节很简略的介绍了向量的相关运算和矩阵的概念，没什么好做笔记的

# 统计学
前面介绍了数据的分布的一些概念: 最小值，最大值，众数，中位数，分位数，极差，平方差，标准平方差

下面介绍协方差和相关系数

方差衡量单个变量对其均值的偏离程度, 协方差衡量两个变量对其均值的共同偏离程度 (其实就是衡量两个变量的相关程度)

```python
from scratch.linear_algebra import dot
def covariance(xs: List[float], ys: List[float]) -> float:
    assert len(xs) == len(ys), "xs and ys must have same number of elements"
    return dot(de_mean(xs), de_mean(ys)) / (len(xs) - 1)
```

相关系数: 协方差除以两个变量的标准差的值

```python
def correlation(xs: List[float], ys: List[float]) -> float:
    """计算xs和ys的均值相差多少"""
    stdev_x = standard_deviation(xs)
    stdev_y = standard_deviation(ys)
    if stdev_x > 0 and stdev_y > 0:
        return covariance(xs, ys) / stdev_x / stdev_y
    else:
        return 0 # 如果没有关联，相关系数为零
```

# 概率
这一章节介绍了一些简单的概率论的概念： 条件概率, 贝叶斯定理， 随机变量，连续分布，正态分布和最后的中心极限定理

下面回顾一下中心极限定理

一个随机变量，定义为大量独立同分布的随机变量的均值，它本身就是接近于正态分布的。

样本均值的表达式:

$$ \frac{1}{n}(x_1 + \cdots + x_n)$$

其近似服从正态分布，均值为 $\mu$，标准差为 $\sigma \sqrt{n}$。

更常用的标准化形式:

$$ \frac{(x_1 + \cdots + x_n) - \mu n}{\sigma \sqrt{n}} $$

书中是一个二项分布的例子
- 当n很大时，二项分布近似正态分布：  
$$
  \text{Binomial}(n, p) \approx \text{Normal}(\mu, \sigma^2)
$$
  其中  
$$
  \mu = np, \quad \sigma = \sqrt{np(1-p)}
$$