---
author: lencelg from Arcadia Bay
title: d2l book note
---

[TOC]

# Introduction
介绍了ml的大致内容, 不多赘述

# Preliminary knowledge
## data operation
### cat
可以通过`cat`来拼接`tensor`, `dim=0`意味着**行（纵向）拼接**，`dim=1`意味着**列（横向）拼接**. 

```python
X = torch.arange(12, dtype=torch.float32).reshape((3,4))
Y = torch.tensor([[2.0, 1, 4, 3], [1, 2, 3, 4], [4, 3, 2, 1]])
torch.cat((X, Y), dim=0), torch.cat((X, Y), dim=1)
```

res as follow

```console
(tensor([[ 0.,  1.,  2.,  3.],
         [ 4.,  5.,  6.,  7.],
         [ 8.,  9., 10., 11.],
         [ 2.,  1.,  4.,  3.],
         [ 1.,  2.,  3.,  4.],
         [ 4.,  3.,  2.,  1.]]),
 tensor([[ 0.,  1.,  2.,  3.,  2.,  1.,  4.,  3.],
         [ 4.,  5.,  6.,  7.,  1.,  2.,  3.,  4.],
         [ 8.,  9., 10., 11.,  4.,  3.,  2.,  1.]]))
```

## Broadcasting Mechanism

**广播机制**（Broadcasting Mechanism）。当两个张量形状不同时，广播机制通过以下两步实现按元素操作：

PyTorch 广播的核心机制是通过将“1”维度的步长设为 0 实现虚拟扩展（零拷贝），**并在反向传播时通过求和规约叠加梯度**

1. **扩展**：将其中一个或两个张量沿着长度为 1 的轴复制元素，使二者形状一致。
2. **运算**：对扩展后的数组执行按元素操作。

张量 `a` 形状为 `(3, 1)`，张量 `b` 形状为 `(1, 2)`。通过广播：
- `a` 的列被复制，变为 `(3, 2)`
- `b` 的行被复制，变为 `(3, 2)`

相加后得到 `3×2` 的结果：

```
[[0, 1],
 [1, 2],
 [2, 3]]
```


###  other

`torch.numel()` ：获得张量中所有元素的个数

## deal with missing values

```python
print(data)
```

```console
   NumRooms Alley   Price
0       NaN  Pave  127500
1       2.0   NaN  106000
2       4.0   NaN  178100
3       NaN   NaN  140000
```

use `fillna` to fill NaN

```python
inputs, outputs = data.iloc[:, 0:2], data.iloc[:, 2]
inputs = inputs.fillna(inputs.mean())
print(inputs)
```

```console
   NumRooms Alley
0       3.0  Pave
1       2.0   NaN
2       4.0   NaN
3       3.0   NaN
```

use `get_dummies` (one kind of one-hot encoding)

> [**对于`inputs`中的类别值或离散值，我们将“NaN”视为一个类别。**]
> 由于“巷子类型”（“Alley”）列只接受两种类型的类别值“Pave”和“NaN”，
> `pandas`可以自动将此列转换为两列“Alley_Pave”和“Alley_nan”。
> 巷子类型为“Pave”的行会将“Alley_Pave”的值设置为1，“Alley_nan”的值设置为0。
> 缺少巷子类型的行会将“Alley_Pave”和“Alley_nan”分别设置为0和1。

```python
inputs = pd.get_dummies(inputs, dummy_na=True)
print(inputs)
```

```console
   NumRooms  Alley_Pave  Alley_nan
0       3.0           1          0
1       2.0           0          1
2       4.0           0          1
3       3.0           0          1
```

## math
向量是一阶张量，矩阵是二阶张量。张量是描述具有任意数量轴的 $n$ 维张量。

***对称矩阵*（symmetric matrix）$\mathbf{A}$等于其转置：$\mathbf{A} = \mathbf{A}^\top$**

**两个矩阵的按元素乘法称为*Hadamard积*（Hadamard product）（数学符号$\odot$）**

矩阵$\mathbf{A}$ 和$\mathbf{B}$ 的Hadamard积为：

$$
\mathbf{A} \odot \mathbf{B} =
\begin{bmatrix}
    a_{11}  b_{11} & a_{12}  b_{12} & \dots  & a_{1n}  b_{1n} \\
    a_{21}  b_{21} & a_{22}  b_{22} & \dots  & a_{2n}  b_{2n} \\
    \vdots & \vdots & \ddots & \vdots \\
    a_{m1}  b_{m1} & a_{m2}  b_{m2} & \dots  & a_{mn}  b_{mn}
\end{bmatrix}.
$$

### sum

```python
A
```

```console
tensor([[ 0.,  1.,  2.,  3.],
        [ 4.,  5.,  6.,  7.],
        [ 8.,  9., 10., 11.],
        [12., 13., 14., 15.],
        [16., 17., 18., 19.]])
```

`axis=0`可以使输入矩阵沿0轴降维以生成输出向量，因此输入轴0的维数在输出形状中消失

如果不想降维，可以使用`keepdim=True`的参数

```python
A_sum_axis0 = A.sum(axis=0)
A_sum_axis0, A_sum_axis0.shape
```

```console
(tensor([40., 45., 50., 55.]), torch.Size([4]))
```

类比就可以知道`axis=1`含义了

同样的，如果不想降维，可以使用`keepdim=True`的参数

```python
A_sum_axis1 = A.sum(axis=1)
A_sum_axis1, A_sum_axis1.shape
```

```console
(tensor([ 6., 22., 38., 54., 70.]), torch.Size([5]))
```

### cumsum

如果想沿某个轴计算A元素的累积总和， 比如axis=0（按行计算），可以调用cumsum函数, 这不会沿任何轴降低输入张量的维度。

这里的方向和`sum()`的方向不一样，要区分清楚

```python
>>> a = torch.randint(1, 20, (10,))
>>> a
tensor([13,  7,  3, 10, 13,  3, 15, 10,  9, 10])
>>> torch.cumsum(a, dim=0)
tensor([13, 20, 23, 33, 46, 49, 64, 74, 83, 93])
```

### norm

$L_2$范数和$L_1$范数都是更一般的$L_p$范数的特例：

$$\|\mathbf{x}\|_p = \left(\sum_{i=1}^n \left|x_i \right|^p \right)^{1/p}.$$

类似于向量的$L_2$范数，$\mathbf{X} \in \mathbb{R}^{m \times n}$(**的*Frobenius范数*（Frobenius norm）是矩阵元素平方和的平方根**

**$$\|\mathbf{X}\|_F = \sqrt{\sum_{i=1}^m \sum_{j=1}^n x_{ij}^2}.$$**

Frobenius范数满足向量范数的所有性质，它就像是矩阵形向量的$L_2$范数。可以使用`torch.norm()`来计算

类似的函数是`torch.linalg.norm`

torch.linalg.norm 默认计算所有元素的 Frobenius 范数
- `ord` 参数：可以指定不同类型的范数（如 ord=1 为列和范数，ord=2 为谱范数等）。
- `dim` 参数：可以指定沿特定轴计算范数

e.g

```python
# X.shape == (2, 3, 4)
torch.linalg.norm(X, dim=0)  # 沿 axis=0 计算，输出形状 (3,4)
torch.linalg.norm(X, dim=(1,2))  # 沿 axis=1 和 2 计算，输出形状 (2,)
```

## gradient

通过连结一个多元函数对其所有变量的偏导数可以得到该函数的*梯度*（gradient）向量。

设函数$f:\mathbb{R}^n\rightarrow\mathbb{R}$的输入是一个$n$维向量$\mathbf{x}=[x_1,x_2,\ldots,x_n]^\top$，并且输出是一个标量。

函数$f(\mathbf{x})$相对于$\mathbf{x}$的梯度是一个包含$n$个偏导数的向量:

$$\nabla_{\mathbf{x}} f(\mathbf{x}) = \bigg[\frac{\partial f(\mathbf{x})}{\partial x_1}, \frac{\partial f(\mathbf{x})}{\partial x_2}, \ldots, \frac{\partial f(\mathbf{x})}{\partial x_n}\bigg]^\top,$$

其中$\nabla_{\mathbf{x}} f(\mathbf{x})$通常在没有歧义时被$\nabla f(\mathbf{x})$取代。

假设$\mathbf{x}$为$n$维向量，经常使用的有以下规则:

* 对于所有$\mathbf{A} \in \mathbb{R}^{m \times n}$，都有$\nabla_{\mathbf{x}} \mathbf{A} \mathbf{x} = \mathbf{A}^\top$
* 对于所有$\mathbf{A} \in \mathbb{R}^{n \times m}$，都有$\nabla_{\mathbf{x}} \mathbf{x}^\top \mathbf{A}  = \mathbf{A}$
* 对于所有$\mathbf{A} \in \mathbb{R}^{n \times n}$，都有$\nabla_{\mathbf{x}} \mathbf{x}^\top \mathbf{A} \mathbf{x}  = (\mathbf{A} + \mathbf{A}^\top)\mathbf{x}$
* $\nabla_{\mathbf{x}} \|\mathbf{x} \|^2 = \nabla_{\mathbf{x}} \mathbf{x}^\top \mathbf{x} = 2\mathbf{x}$

对于任何矩阵$\mathbf{X}$，都有$\nabla_{\mathbf{X}} \|\mathbf{X} \|_F^2 = 2\mathbf{X}$。

## computational graph

系统会构建一个计算图（computational graph）， 来跟踪计算是哪些数据通过哪些操作组合起来产生输出。自动微分使系统能够随后反向传播梯度.
- `tensor1.requires_grad_(True)`：告诉框架需要对<u>**该张量**</u>求导
- `tensor2.backward()`：求 tensor2 对 tensor1 导数（tensor2 需为 tensor1 的表达式，且求导前要执行`requires_grad_(True)`命令）
- `tensor1.grad`：访问求导后张量的导数
- `tensor.grad.zero_()`：梯度清零（Pytorch 默认会累计梯度并存储在`.grad`内）
- `tensor.detach()`：将该变量移出计算图，当作常量处理，多用于神经网络的参数固定
- 一般很少用到向量对向量（以及更高阶）的求导，需要引入一个 gradient 参数，所以会把一个向量转化为标量求导，最常用的就是求和：`tensor.sum().backward()`。`loss`一般是一个标量，如果 loss 是矩阵，维度就会越算越大。
- 可以经过 Python 计算流再求导。


### add-on

**非标量变量的反向传播**

`y = x * x`（`x = [0, 1, 2, 3]`）。

**写法一（显式传入 gradient）：**
```python
y.backward(torch.ones(len(x))) 
```
这相当于令向量 \( v = [1, 1, 1, 1]^T \)。

**写法二（`sum` 技巧）：**
```python
y.sum().backward()
```
- `y.sum()` 是一个**标量**，即 \( y_1 + y_2 + y_3 + y_4 \)。
- 这个标量对 `x` 求导，就是 \( \frac{\partial (y_1 + y_2 + y_3 + y_4)}{\partial x} \)。
- 由于线性加法的导数等于导数的和，这等价于对雅可比矩阵的**每一列求和**。

对雅可比矩阵的每一列求和，恰好等同于 **雅可比矩阵左乘全 1 向量**（即 \( \mathbf{1}^T \cdot J \)）。所以：
> **`y.sum().backward()` 等价于 `y.backward(torch.ones_like(y))`**

手动算：
- 原函数：\( y_i = x_i^2 \)
- 雅可比矩阵 \( J \) 是一个对角矩阵，对角线上的元素是 \( \frac{dy_i}{dx_i} = 2x_i \)。
- 当我们传入全 1 向量 `v` 时，\( v^T \cdot J = [1, 1, 1, 1] \times diag(2x_i) = [2x_1, 2x_2, 2x_3, 2x_4] \)。
- 代入 `x = [0, 1, 2, 3]`，就是 `[0, 2, 4, 6]`。

# Linear Neural network

线性回归是一个很简单的优化问题。线性回归的解可以用一个公式简单地表达出来， 这类解叫作解析解（analytical solution）。

**线性回归的最小二乘解**（Normal Equation）：

\[
w^* = (X^T X)^{-1} X^T y
\]

\(w^*\) 是最优权重参数向量

该公式要求 \(X^T X\) 可逆（即特征之间线性无关）, 这对问题的限制严格，对很多问题无法应用

SGD

**小批量随机梯度下降（Mini-batch SGD）** 的具体梯度计算公式。

核心内容：
- 参数 \((w, b)\) 的迭代更新形式为：
  \[
  (w, b) \leftarrow (w, b) - \frac{\eta}{|B|} \sum_{i \in B} \partial_{(w,b)} l^{(i)}(w, b)
  \]
  其中 \(\eta\) 为学习率，\(B\) 为小批量样本集，\(|B|\) 为批量大小。
- 算法步骤：① 随机初始化参数；② 反复随机采样小批量，并沿负梯度方向更新参数。
- 对于线性回归，\(w\) 和 \(b\) 的显式更新公式为：
  \[
  w \leftarrow w - \frac{\eta}{|B|} \sum_{i \in B} x^{(i)} \left( w^\top x^{(i)} + b - y^{(i)} \right)
  \]
  \[
  b \leftarrow b - \frac{\eta}{|B|} \sum_{i \in B} \left( w^\top x^{(i)} + b - y^{(i)} \right) \quad 
  \]

# multilayer perceptron
我们可以通过在网络中加入一个或多个隐藏层来克服线性模型的限制， 使其能处理更普遍的函数关系类型。

![](./img/multilayer%20perceptron%20example.png)

仿射函数的仿射函数本身就是仿射函数, 多层线性激活函数和单层是等价的, 于是在仿射变换之后对每个隐藏单元应用 **非线性的激活函数（activation function）**

## 4.1 popular activation function
- 修正线性单元（Rectified linear unit，ReLU）

\[
\text{ReLU}(x) = \max(x, 0)
\]

- ReLU 的一个变体——参数化 ReLU（pReLU）

\[
p\text{ReLU}(x) = \max(0, x) + \alpha \min(0, x)
\]

其中 \(\alpha\) 是一个可学习的参数（通常初始化为较小的值）。相比标准 ReLU（负半轴输出恒为 0），pReLU 在负半轴引入了一个线性项 \(\alpha x\)，使得即使输入为负，部分信息仍能流通，从而缓解“神经元死亡”问题

---

Sigmoid 函数的导数：

\[
\frac{d}{dx} \text{sigmoid}(x) = \frac{\exp(-x)}{(1 + \exp(-x))^2} = \text{sigmoid}(x) \cdot (1 - \text{sigmoid}(x))
\]

其中 \(\text{sigmoid}(x) = \frac{1}{1 + e^{-x}}\)。该性质在神经网络的反向传播中很重要，因为它能用函数自身表示导数，计算高效。

---

**tanh 函数（双曲正切）** ：

\[
\tanh(x) = \frac{1 - \exp(-2x)}{1 + \exp(-2x)}
\]

等价于 \(\tanh(x) = \frac{e^x - e^{-x}}{e^x + e^{-x}}\)。

**tanh 函数的导数**：

\[
\frac{d}{dx} \tanh(x) = 1 - \tanh^2(x)
\]

该导数同样可以用函数自身表示，计算方便，且在反向传播中常用。tanh 的输出范围为 \((-1, 1)\)，是 Sigmoid 的零中心化变体。

## 4.4
泛化是机器学习中的基本问题

在我们确定所有的超参数之前，我们不希望用到测试集。于是考虑加入验证集

## 4.8

**Xavier 初始化**:

主要内容：
- 对于一个 **全连接层**  \(o_i = \sum_{j=1}^{n_{in}} w_{ij} x_j\)，假设权重 \(w_{ij}\) 与输入 \(x_j\) 相互独立，且均值为 0、方差分别为 \(\sigma^2\) 和 \(\gamma^2\)，则输出 \(o_i\) 的方差为 \(\text{Var}[o_i] = n_{in} \sigma^2 \gamma^2\)。
- 为保持前向传播时方差稳定，需 \(n_{in} \sigma^2 = 1\)。
- 反向传播时，为避免梯度爆炸/消失，需 \(n_{out} \sigma^2 = 1\)。
- 二者无法同时满足，故采用折中方案：\(\frac{1}{2}(n_{in} + n_{out}) \sigma^2 = 1\)，即
  \[
  \sigma = \sqrt{\frac{2}{n_{in} + n_{out}}}
  \]
- 因此，Xavier 初始化从均值为 0、方差为 \(\frac{2}{n_{in}+n_{out}}\) 的分布中采样权重（通常为高斯分布或均匀分布）。对于均匀分布 \(U(-a, a)\)，由于方差为 \(a^2/3\)，可得 \(a = \sqrt{6 / (n_{in}+n_{out})}\)。

## 4.9 环境和分布偏移
通过将基于模型的决策引入环境，我们可能会破坏模型。 这是应用中泛化的内容。

### 协变量偏移（Covariate Shift）：
- 在协变量偏移下，**输入（特征）的分布** \(P(x)\) 可能随时间改变，但**条件分布** \(P(y \mid x)\)（即标签函数）保持不变。
- 这种偏移由协变量（特征）分布的变化引起，因此得名。
- 当认为 \(x\) 是原因、\(y\) 是结果时，协变量偏移是一种自然的假设。
- 例子：区分猫和狗的任务，训练数据中的图像分布可能发生变化，但给定图像时其类别标签的条件概率不变。

该笔记继续介绍了另外两种分布偏移：

### 标签偏移（Label Shift）
- **定义**：与协变量偏移相反，标签边缘概率 \(P(y)\) 可以变化，但类别条件分布 \(P(x \mid y)\) 在不同领域保持不变。
- **适用场景**：当认为 \(y\)（标签）导致 \(x\)（特征）时，例如根据症状判断疾病，疾病的流行率可能变化，但症状与疾病的关系稳定。
- **与协变量偏移的关系**：有时两者可同时成立；若标签是确定的，即使 \(y\) 导致 \(x\)，协变量偏移假设也满足。但此时使用基于标签偏移的方法通常更优，因为标签往往是低维的，而输入是高维的。

### 概念偏移（Concept Shift）
- **定义**：标签本身的定义发生变化。例如，精神疾病的诊断标准、时尚潮流、工作头衔等随时间或地点改变。
- **例子**：美国不同地区对“软饮”的称呼（如 soda、pop、coke）分布不同，体现了概念偏移。
- **影响**：$P(y|x)$ 的分布在不同概念的环境中的翻译不同

# CNN
## LeNet
最经典的 CNN 就是 LeNet 了

LeNet（LeNet-5）由两个部分组成：
- 卷积编码器：由两个卷积层组成;
- 全连接层密集块：由三个全连接层组成。

![](./img/leNet)

## AlexNet
AlexNet使用了8层卷积神经网络

![](./img/AlexNet)

## VGG
经典卷积神经网络的基本组成部分是下面的这个序列：
- 带填充以保持分辨率的卷积层；
- 非线性激活函数，如ReLU；
- 汇聚层，如最大汇聚层。

![](./img/VGG)

## NiN
VGG和NiN相似

NiN块以一个普通卷积层开始，后面是两个$ 1 X 1 $ 的卷积层。这两个卷积层充当带有ReLU激活函数的逐像素全连接层。

![](./img/NiN)

## GoogLeNet
书中简化的GoogLeNet一共使用9个Inception块和全局平均汇聚层的堆叠来生成其估计值。

在GoogLeNet中，基本的卷积块被称为 *Inception块* （Inception block）

![](./img/inception)

Inception块相当于一个有4条路径的子网络。它通过不同窗口形状的卷积层和最大汇聚层来并行抽取信息，并使用 $ 1 X 1 $ 卷积层减少每像素级别上的通道维数从而降低模型复杂度。

简化的GoogLeNet一共使用9个Inception块和全局平均汇聚层的堆叠来生成其估计值。

![](./img/googleNet)

## ResNet
这里函数类动机的内容可作为coursera deeplearning 课程补充

![](./img/resnet%20math)

残差块

![](./img/resduial%20block)

resnet 可以减少梯度减少和梯度爆炸的问题

## DenseNet
稠密连接网络（DenseNet）在某种程度上是ResNet的逻辑扩展。

![](./img/densenet)

# RNN 
## 8.3
语言模型的目标是：给定一个单词序列（比如 “deep learning is fun”），算出它出现的概率  
\[
P(\text{deep}, \text{learning}, \text{is}, \text{fun})
\]

根据概率链式法则，可以把联合概率拆成一系列条件概率的乘积：

\[
P(\text{deep}) \cdot P(\text{learning} \mid \text{deep}) \cdot P(\text{is} \mid \text{deep}, \text{learning}) \cdot P(\text{fun} \mid \text{deep}, \text{learning}, \text{is})
\]

然后我们有一个大型文本语料库, 最简单的想法是**数数** 来计算概率：

- \(P(\text{deep})\) ≈ 单词 “deep” 出现的次数 / 语料库所有单词总数  
- \(P(\text{learning} \mid \text{deep})\) ≈ 相邻的 “deep learning” 出现次数 / “deep” 出现的次数  

\[
\hat{P}(\text{learning} \mid \text{deep}) = \frac{n(\text{deep}, \text{learning})}{n(\text{deep})}
\]

**问题：数据稀疏性**  
- 很多合理的单词组合（尤其是三个词以上）可能在语料库中出现次数为 0，导致条件概率估计为 0。  
- 一旦某个条件概率为 0，整个句子的概率就变成 0 → 模型会认为该句子不可能出现，这显然不合理。  
- 即使是常见的两词组合（如 “deep learning”），在中小语料库中也可能出现次数很少，统计不可靠。

### 拉普拉斯平滑

核心思想：**给每个可能的事件（单词或词序列）都“预留”一点点概率，避免零概率**。

\[
\hat{P}(x) = \frac{n(x) + \epsilon_1 / m}{n + \epsilon_1}
\]  
其中：
- \(m\) = 词汇表中唯一单词的总数（去重后的单词个数）
- \(\epsilon_1\) 是一个超参数，控制平滑强度

直观理解：
- 分子额外加了 \(\epsilon_1 / m\)：让每个单词（无论出现与否）都能分到一点“虚拟计数”  
- 分母加了 \(\epsilon_1\)：保持所有单词的概率之和为 1  
- 当 \(\epsilon_1 = 0\)：回到原始频率估计（不平滑）  
- 当 \(\epsilon_1 \to \infty\)：\(\hat{P}(x) \to \frac{1}{m}\)，即均匀分布。

---

对于条件概率（给定前一个词）

原公式：  
\[
\hat{P}(x' \mid x) = \frac{n(x, x')}{n(x)}
\]

平滑后：  
\[
\hat{P}(x' \mid x) = \frac{n(x, x') + \epsilon_2 \cdot \hat{P}(x')}{n(x) + \epsilon_2}
\]

- 分子额外加了一项 \(\epsilon_2 \cdot \hat{P}(x')\)：其中 \(\hat{P}(x')\) 是平滑后的单词 \(x'\) 的单字概率。  
- 这样即使 \(n(x, x') = 0\)，该条件概率也不为 0，而是退回到 \(\hat{P}(x')\) 的加权形式。

---

对于三元组条件概率

\[
\hat{P}(x'' \mid x, x') = \frac{n(x, x', x'') + \epsilon_3 \cdot \hat{P}(x'')}{n(x, x') + \epsilon_3}
\]

递归地利用低阶平滑概率。

#### 局限
- **意义**：简单有效，能保证任意词序列的概率 > 0，使语言模型在预测时不会因为某个从未出现的组合而完全崩溃。  
- **局限**：  
  - 对高阶（长距离）依赖的建模仍然很弱，因为随着 n 增大，可能的组合数指数增长，平滑后大部分概率会均匀分配给无数从未出现的序列。  
  - 后来被更强大的神经网络语言模型（如 RNN、Transformer）取代，但平滑思想在统计语言模型和很多其他 ML 任务（如朴素贝叶斯分类）中仍有价值。
  - 我们需要存储所有的计数
  - 完全忽略了单词的意思， 意义类似的单词被抛弃了。

## 8.4 

**困惑度(Perplexity)** : 度量语言模型的质量

这段笔记讨论了**语言模型的质量评估方法**，重点引入**困惑度（Perplexity）**作为评价指标。

**信息论视角：交叉熵损失**  
   - 对于长度为 \(n\) 的序列，平均交叉熵损失为：  
     \[
     \frac{1}{n} \sum_{t=1}^{n} -\log P(x_t \mid x_{t-1}, \dots, x_1)
     \]  
     - 该值表示编码每个词元所需的平均比特数。损失越低，模型越好。

**困惑度（Perplexity）的定义**  
   \[
    \text{Perplexity} = \exp\left( -\frac{1}{n} \sum_{t=1}^{n} \log P(x_t \mid x_{t-1}, \dots, x_1) \right)
   \]  
   可以理解为“模型预测下一个词元时，实际有效候选词数量的几何平均”。

5. **困惑度的极值与基线**  
   - 完美模型：困惑度 = 1（总是以概率1预测正确词元）  
   - 最差模型：困惑度 → \(+\infty\)（总是给正确词元概率0）  
   - 均匀分布基线：困惑度 = 词表大小（此时模型没有学到任何偏好）

# modern RNN
## 门控循环单元（GRU）
关注一个序列
- 不是每个观察值都同等重要
- 想只记住相关的观察需要，通过一些控制单元：
  - 能关注的机制（更新门）
  - 能遗忘的机制（重置门）

![](./img/GRU)

更新状态公式：

$$\bf H_t=Z_t⊙ H_{t-1}+(1-\bf Z_t)⊙\~H_t$$

$\bf Z_t = 1$ 时，直接用前一时刻状态，舍弃当前状态
$\bf Z_t = 0$ 时，不起作用；如果配合 $\bf R_t = 1$，就是RNN。

门控循环单元具有两个显著特征：
- 重置门有助于捕获序列中的短期依赖关系；
- 更新门有助于捕获序列中的长期依赖关系。

可以参考一下代码

```python
def gru(inputs, state, params):
    W_xz, W_hz, b_z, W_xr, W_hr, b_r, W_xh, W_hh, b_h, W_hq, b_q = params
    H, = state
    outputs = []
    for X in inputs:
        Z = torch.sigmoid((X @ W_xz) + (H @ W_hz) + b_z)
        R = torch.sigmoid((X @ W_xr) + (H @ W_hr) + b_r)
        H_tilda = torch.tanh((X @ W_xh) + ((R * H) @ W_hh) + b_h)
        H = Z * H + (1 - Z) * H_tilda
        Y = H @ W_hq + b_q
        outputs.append(Y)
    return torch.cat(outputs, dim=0), (H,)
```

## 长短期记忆网络（LSTM）
隐变量模型存在着长期信息保存和短期输入缺失的问题。 解决这一问题的最早方法之一是 **长短期存储器（long short-term memory，LSTM）**

结构如下：

![](./img/lstm)

**门**

$$
\begin{split}
&{\bf I}_t=\sigma({\bf X}_t{\bf W}_{xi}+{\bf H}_{t-1}{\bf W}_{hi}+{\bf b}_i)\\
&{\bf F}_t=\sigma({\bf X}_t{\bf W}_{xf}+{\bf H}_{t-1}{\bf W}_{hf}+{\bf b}_f)\\
&{\bf O}_t=\sigma({\bf X}_t{\bf W}_{xo}+{\bf H}_{t-1}{\bf W}_{ho}+{\bf b}_o)
\end{split}
$$

**候选记忆单元**

$${\bf \~C}_t=tanh({\bf X}_t{\bf W}_{xc}+{\bf H}_{t-1}{\bf W}_{hc}+{\bf b}_c)$$

- RNN的输出
- ${\bf C, \~C}$ 与 $\bf H$ 形状相同

**记忆单元**

$${\bf C}_t={\bf F}_t⊙{\bf C}_{t-1}+{\bf I}_t⊙{\bf\~C}_t$$

- $F=0$，舍去上一个记忆单元
- $I=0$，舍弃当下的记忆单元
- 两者相加，${\bf C}_{t-1}$ 和 ${\bf\~C}_t$ 都经过非线性变换，在 $0-1$ 之间，所以${\bf C}_{t}$ 在 $0-2$ 之间
  - 仔细想来，$\bf C$ 没有经过非线性，可以叠加出比较大的值 
   
**隐状态**

$${\bf H}_t={\bf O}_t⊙tanh({\bf C}_t)$$
- 所以要再次非线性把 ${\bf C}_t$ clamp住。
- ${\bf O}_t=0$，把输入和前一刻状态都舍弃，相当于重置 ${\bf H}_t$
- ${\bf O}$ 是对 ${\bf H}$ 的保存与否
- 相当于 ${\bf C}$ 是对 ${\bf H}$ 状态的中间量

**输出**

$$ {\bf O}_t=\phi({\bf W}_{ho}{\bf H}_t+{\bf b}_o) $$

- 与RNN最后形式相同

## 深度循环神经网络
一个具有$L$个隐藏层的深度循环神经网络， 每个隐状态都连续地传递到当前层的下一个时间步和下一层的当前时间步。

![](./img/DRNN)

深度循环神经网络使用多个隐藏层来获得更多的非线性性

表现
- 深度循环神经网络需要大量的调参（如学习率和修剪） 来确保合适的收敛，模型的初始化也需要谨慎。
- 计算慢了，收敛快了

## 双向循环神经网络
基本想法： 隐马尔可夫模型中的动态规划

双向循环神经网络使用了过去的和未来的数据, 仅仅应用于部分场合。 填充缺失的单词、词元注释（例如，用于命名实体识别） 以及作为序列处理流水线中的一个步骤对序列进行编码（例如，用于机器翻译）。

![](./img/Double%20RNN)

双向循环神经网络的计算速度非常慢, 因为网络的前向传播需要在双向层中进行前向和后向递归， 并且网络的反向传播还依赖于前向传播的结果。

## 机器翻译与数据集
机器翻译的数据集是由源语言和目标语言的文本序列对组成的。e.g 英语是源语言（source language）， 法语是目标语言（target language）。

编码器-解码器架构是序列转换模型的架构

![](./img/encoder%20decoder)

## 搜索策略
我们逐个预测输出序列， 直到预测序列中出现特定的序列结束词元“\<eos>”。

### 贪心搜索
在每一步，都选择**当前条件概率最大**的那个词元作为输出，不考虑未来步骤的影响。

\[
y_{t'} = \arg\max_{y \in Y} P(y \mid y_1, \dots, y_{t'-1}, c)
\]
- \(y_{t'}\)：当前时间步 \(t'\) 选择的词元  
- \(Y\)：所有可能词元的集合（词表）  
- \(c\)：编码器传来的上下文向量（例如机器翻译中的源句子编码）

- 计算效率极高（每步只做一次取最大，无需分支）
- 实现简单
- 容易陷入局部最优：当前步选的最优词可能导致后续整体概率不佳  

### 穷举搜索
穷举搜索（exhaustive search）： 穷举地列举所有可能的输出序列及其条件概率， 然后计算输出条件概率最高的一个。
- 结果最优
- 计算量太大

### 束搜索
*束搜索（beam search）* 是贪心搜索的一个改进版本, beam search 有一个超参数，名为束宽 $k$（beam size）。
- 保存最好的 k 个候选
- 在每个时刻，对每个候选新加一项( n 种可能)，在 k n 个选项中选出最好的 k 个

计算量介于贪心搜索和穷举搜索之间, 实际上，贪心搜索可以看作一种束宽为$1$的特殊类型的束搜索。

# ch 12
- 命令式编程：按顺序执行，易于调试，灵活，但计算慢了，如Python、PyTorch。
- 符号式编程：先定义计算图，然后执行，优化潜力大，但调试困难，如TensorFlow 1.x、Theano。
- 现代框架的融合（如TensorFlow 2.x的Eager Execution、JAX等）: 用户写命令式代码，框架在背后进行符号式优化，兼顾灵活性与性能。

## 多GPU训练

- 拆分网络: 可以用更大的网络处理数据。然而，GPU的接口之间需要的密集同步可能是很难办的，特别是层之间计算的工作负载不能正确匹配的时候， 还有层之间的接口需要大量的数据传输的时候 
- 拆分层内的工作: 例如，将问题分散到4个GPU，每个GPU生成16个通道的数据，而不是在单个GPU上计算64个通道. 然而，我们需要大量的同步或屏障操作（barrier operation），因为每一层都依赖于所有其他层的结果。
- 跨多个GPU对数据进行拆分: 所有GPU尽管有不同的观测结果，但是执行着相同类型的工作。 完成每个小批量数据的训练之后，梯度在GPU上聚合。这种方法最简单，并可以应用于任何情况，同步只需要在每个小批量数据处理之后进行。 

![](./img/multi%20GPU)

## 参数服务器
problem: 可能所有服务器的分布跨越了多个机架和多个网络交换机.

(Wang et al., 2018)的研究结果表明最优的同步策略是将网络分解成两个环，并基于两个环直接同步数据。

![](./img/Ring%20Synchronization)

# ch 13
## 区域卷积神经网络（R-CNN）系列
### R-CNN
R-CNN首先从输入图像中选取若干（例如2000个） **提议区域** （如锚框也是一种选取方法），并标注它们的类别和边界框（如偏移量）。 然后, 用卷积神经网络对每个提议区域进行前向传播以抽取其特征。

由于提议区域可能比较多， R-CNN模型通过预训练的卷积神经网络有效地抽取了图像特征，但它的速度很慢。

### Fast R-CNN
motivation: R-CNN的速度在于对每个提议区域，卷积神经网络的前向传播是独立的，而没有共享计算。

Fast R-CNN 是仅在整张图象上执行卷积神经网络的前向传播。

###  Faster R-CNN
Faster R-CNN提出将选择性搜索替换为区域提议网络（region proposal network），从而减少提议区域的生成数量，并保证目标检测的精度。
### Mask R-CNN
如果在训练集中还标注了每个目标在图像上的像素级位置，Mask R-CNN能够利用 **详尽的标注信息** 进一步提升目标检测的精度。
