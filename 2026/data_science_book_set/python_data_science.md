---
author: lencelg from Arcadia Bay
title: note of python data science book set
---
this note is made from data science book set

PS: 这是一套书籍，很多内容, 每周抽点时间看一看

>立个flag: 完成这个note

[TOC]

# 第一本书数据科学入门第二版
## Introduction
上来就介绍了数据科学，首先是数据，然后根据需求对数据操作，例子是朋友关系的图， 书中做了一个图

展示了数据科学的大致内容

## python速成
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

## 数据可视化
这一章介绍 matplotlib 的几种常见的图形，都是一些简单的例子

下面记录图形的类别
* 线图
* `bar` : 条形图
* `scatter`: 散点图

## 线性代数
这一章节很简略的介绍了向量的相关运算和矩阵的概念，没什么好做笔记的

## 统计学
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

## 概率
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

## 假设和推论
这一章节是概率论中假设与推论部分的大致介绍

### 假设
1. **统计假设检验的用途**  
   数据科学家经常需要检验某个假设是否成立（例如硬币是否均匀、用户对某种设计的偏好等）。这些假设可以转化为关于某个统计量的断言，并利用概率分布来判断其 **合理性**。

2. **核心步骤**  
   - 设立**零假设 $H_0$**：代表默认立场（例如“硬币是均匀的”）。  
   - 设立**替代假设 $H_1$**：希望与之对比的立场（例如“硬币不是均匀的”）。  
   - 通过样本数据计算统计量，判断是否能够拒绝 $H_0$。

3. **掷硬币实例**  
   - 假设硬币正面概率为 $p$，零假设 $H_0: p = 0.5$，替代假设 $H_1: p \neq 0.5$。  
   - 掷 n 次，记正面次数 $X$ ，则 $X \sim \text{Binomial}(n, p)$。  
   - 利用正态分布近似（当 n 较大时）对二项分布进行拟合，从而检验假设。

### p 值

在假设检验中，**\( p \) 值**表示：**在零假设 \( H_0 \) 为真的前提下，观察到当前样本结果（或更极端结果）的概率**。

- 如果 \( p \) 值很小（通常小于预先设定的显著性水平 \( \alpha \)，如 0.05），我们就认为样本结果在 \( H_0 \) 下非常罕见，从而有理由拒绝 \( H_0 \)。
- 如果 \( p \) 值较大，则说明观察到的结果与 \( H_0 \) 并不矛盾，我们无法拒绝 \( H_0 \)。

双侧检验的 \( p \) 值计算

在掷硬币的例子中，我们关心的是正面次数是否**偏离**期望值 \( np \)，不论偏离方向（过多或过少）。因此采用**双侧检验**。

| 概念 | 说明 |
|------|------|
| \( p \) 值 | \( H_0 \) 为真时，观察到当前或更极端结果的概率 |
| 双侧检验 | 考虑两个方向的偏离，将单侧尾部概率乘以 2 |

可以计算概率， 也可以计算区间

### 第一类、第二类错误

1. 第一类错误（Type I Error）**零假设 $H_0$ 实际上为真**时，我们却错误地**拒绝**了它。
2. 第二类错误（Type II Error）当**零假设 $H_0$ 实际上为假**时，我们却未能拒绝它（即接受了错误的 $H_0$）。

**显著性** （significance）: 我们有多大可能性犯第 1 类错误（“假阳性”）.

**势** （power）: 它表示不犯第 2 类错误 （“假阴性”） 的概率

下面是势的一个例子, 只知道 p = 0.5 并不能给我们提供 $X$ 分布的足够的信息 。为了衡量这一点，实际上如果 p = 0.55，抛硬币的结果就会略微多偏向正面朝上。在这种情况下，可以用以下方法计算检验的势：

```python
# 当p是0.5时95%的边界
lo, hi = normal_two_sided_bounds(0.95, mu_0, sigma_0)
# 当p是0.55时的真实mu和sigma
mu_1, sigma_1 = normal_approximation_to_binomial(1000, 0.55)

# 第2类错误意味着我们没有拒绝原假设
# 这会在X仍在最初的区间时发生
type_2_probability = normal_probability_between(lo, hi, mu_1, sigma_1)
power = 1 - type_2_probability # 0.887
```

因此我们可以做单边检验, 也可以做双边检验

### 置信区间
置信区间是从概率反过来求区间, 从可信度入手计算可信区间来衡量结果

## 贝叶斯推断
将未知参数本身视为随机变量, 不再对检验本身进行概率判断，而是对参数进行概率判断。

从参数的 **先验分布**（prior distribution）开始，使用观察到的数据和贝叶斯定理计算出更新后的 **后验分布**（posterior distribution）。

经常使用 **Beta** 分布 （Beta distribution）作为先验分布，Beta 分布将所有概率置于 **0~1 范围** 内：

```python
def B(alpha: float, beta: float) -> float:
"""归一化常数，因此总概率为1"""
  return math.gamma(alpha) * math.gamma(beta) / math.gamma(alpha + beta)
def beta_pdf(x: float, alpha: float, beta: float) -> float:
  if x <= 0 or x >= 1:
    # 没有落在[0, 1]之外的权重
    return 0
    return x ** (alpha - 1) * (1 - x) ** (beta - 1) / B(alpha, beta)
```

权重中心在于 `alpha / (alpha + beta)`

## 梯度下降
这一章节的内容介绍和吴恩达的课程差不多，就是少了正则化参数和学习率的内容, 可以参考吴恩达课程的笔记

## 数据获取
这一章节是如何从python中获取数据，包括命令行参数读取和文件读取, 无需多言

## 数据工作
从数据入手构建图表分析，然后清洗数据，还介绍了PCA来降维, 可以参考data100的reference note

## 机器学习
无需多言

```python
# 精确率
def precision(tp: int, fp: int, fn: int, tn: int) -> float:
  return tp / (tp + fp)

# 召回率
def recall(tp: int, fp: int, fn: int, tn: int) -> float:
  return tp / (tp + fn)

# 使用f1来综合衡量
def f1_score(tp: int, fp: int, fn: int, tn: int) -> float:
  p = precision(tp, fp, fn, tn)
  r = recall(tp, fp, fn, tn)
  return 2 * p * r / (p + r)
```

## 朴素贝叶斯
**朴素贝叶斯**是一类基于**贝叶斯定理**的简单但强大的分类算法，它的“朴素”之处在于假设各个特征之间**条件独立**（即在给定类别的情况下，特征之间互不影响）。

basic idea: 对于分类问题，我们想计算一个样本属于某个类别 \(C_k\) 的后验概率：

\[
P(C_k \mid x_1, x_2, \dots, x_n) = \frac{P(C_k) \cdot P(x_1, x_2, \dots, x_n \mid C_k)}{P(x_1, \dots, x_n)}
\]

由于分母对所有类别相同，只需比较分子。

**朴素假设**（特征条件独立）：
\[
P(x_1, \dots, x_n \mid C_k) = \prod_{i=1}^{n} P(x_i \mid C_k)
\]

于是：
\[
P(C_k \mid x_1, \dots, x_n) \propto P(C_k) \prod_{i=1}^{n} P(x_i \mid C_k)
\]

- **训练**：从数据中估计**先验** \(P(C_k)\) 和**类条件概率** \(P(x_i \mid C_k)\)。
  - 对于离散特征：用频率或平滑（如拉普拉斯平滑）。
  - 对于连续特征：通常假设正态分布，估计均值和方差。
- **预测**：对于新样本，计算每个类别的后验概率，取最大值作为预测类别。

## 随机森林
problem: 由于决策树可以很好地拟合训练数据，因此它往往会出现过拟合现象。

idea: **随机森林** 构建多个决策树并将其输出组合在一起。如果它们是分类树，则这些决策通过投票进行分类。如果它们是回归树，则我们用所有决策树输出结果的均值进行预测。

bootstrap集成方法： 根据 bootstrap_sample(inputs) 的结果来训练每棵树。每棵树都将与其他树不同。

## 神经网络
感知器(perceptron): 最简单的神经网络. 

它由具有 n 个二进制输入的单个神经元组成。感知器先计算输入的加权和，如果该加权和大于等于 0，则它被激活

```python
from scratch.linear_algebra import Vector, dot
def step_function(x: float) -> float:
  return 1.0 if x >= 0 else 0.0
def perceptron_output(weights: Vector, bias: float, x: Vector) -> float:
  """如果感知器“被激活”，则返回1，否则返回0"""
  calculation = dot(weights, x) + bias
  return step_function(calculation)
```

## 反向传播
我们可以使用反向传播训练神经网络

思路步骤如下：

> 01. 在输入向量上运行 `feed_forward`(也就是前向传播)，以得到网络中所有神经元的输出。
> 02. 我们知道目标输出，因此可以计算出损失，即误差平方和。
> 03. 根据神经元权重函数计算损失的梯度。
> 04. 向后“传播”梯度和误差，以计算隐藏层神经元权重的梯度。
> 05. 采取梯度下降步骤。

## 聚类分析
介绍了 **k-均值算法** 的实现， 其他没有什么特别值得介绍的

## 自然语言处理
首先是 n-gram 的介绍， 即 n 个单词作为一个 token

建模语言的另一种方法是使用 **语法(grammer)**

但是现实应用中使用 **词向量**
