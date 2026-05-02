---
author: lencelg from Arcadia Bay
title: d2l book note
---
[TOC]

# Introduction
介绍了ml的大致内容

# Preliminary knowledge
## data operation
`torch.numel()` ：获得张量中所有元素的个数

---

**广播机制**（Broadcasting Mechanism）。当两个张量形状不同时，广播机制通过以下两步实现按元素操作：

1. **扩展**：将其中一个或两个张量沿着长度为 1 的轴复制元素，使二者形状一致。
2. **运算**：对扩展后的数组执行按元素操作。

示例中，张量 `a` 形状为 `(3, 1)`，张量 `b` 形状为 `(1, 2)`。通过广播：
- `a` 的列被复制，变为 `(3, 2)`
- `b` 的行被复制，变为 `(3, 2)`

相加后得到 `3×2` 的结果：

```
[[0, 1],
 [1, 2],
 [2, 3]]
```

## math
向量是一阶张量，矩阵是二阶张量。张量是描述具有任意数量轴的 $n$ 维张量。

---

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

---

如果我们想沿某个轴计算A元素的累积总和， 比如axis=0（按行计算），可以调用cumsum函数。 此函数不会沿任何轴降低输入张量的维度。
```python
>>> a = torch.randint(1, 20, (10,))
>>> a
tensor([13,  7,  3, 10, 13,  3, 15, 10,  9, 10])
>>> torch.cumsum(a, dim=0)
tensor([13, 20, 23, 33, 46, 49, 64, 74, 83, 93])
```

---

梯度

我们可以连结一个多元函数对其所有变量的偏导数，以得到该函数的*梯度*（gradient）向量。
具体而言，设函数$f:\mathbb{R}^n\rightarrow\mathbb{R}$的输入是
一个$n$维向量$\mathbf{x}=[x_1,x_2,\ldots,x_n]^\top$，并且输出是一个标量。
函数$f(\mathbf{x})$相对于$\mathbf{x}$的梯度是一个包含$n$个偏导数的向量:

$$\nabla_{\mathbf{x}} f(\mathbf{x}) = \bigg[\frac{\partial f(\mathbf{x})}{\partial x_1}, \frac{\partial f(\mathbf{x})}{\partial x_2}, \ldots, \frac{\partial f(\mathbf{x})}{\partial x_n}\bigg]^\top,$$

其中$\nabla_{\mathbf{x}} f(\mathbf{x})$通常在没有歧义时被$\nabla f(\mathbf{x})$取代。

假设$\mathbf{x}$为$n$维向量，在微分多元函数时经常使用以下规则:

* 对于所有$\mathbf{A} \in \mathbb{R}^{m \times n}$，都有$\nabla_{\mathbf{x}} \mathbf{A} \mathbf{x} = \mathbf{A}^\top$
* 对于所有$\mathbf{A} \in \mathbb{R}^{n \times m}$，都有$\nabla_{\mathbf{x}} \mathbf{x}^\top \mathbf{A}  = \mathbf{A}$
* 对于所有$\mathbf{A} \in \mathbb{R}^{n \times n}$，都有$\nabla_{\mathbf{x}} \mathbf{x}^\top \mathbf{A} \mathbf{x}  = (\mathbf{A} + \mathbf{A}^\top)\mathbf{x}$
* $\nabla_{\mathbf{x}} \|\mathbf{x} \|^2 = \nabla_{\mathbf{x}} \mathbf{x}^\top \mathbf{x} = 2\mathbf{x}$

同样，对于任何矩阵$\mathbf{X}$，都有$\nabla_{\mathbf{X}} \|\mathbf{X} \|_F^2 = 2\mathbf{X}$。

梯度对于设计深度学习中的优化算法有很大用处。

---

实际中，根据我们设计的模型，系统会构建一个计算图（computational graph）， 来跟踪计算是哪些数据通过哪些操作组合起来产生输出。 自动微分使系统能够随后反向传播梯度

这里，反向传播（backpropagate）意味着跟踪整个计算图，填充关于每个参数的偏导数。
- `tensor1.requires_grad_(True)`：告诉框架需要对<u>**该张量**</u>求导
- `tensor2.backward()`：求 tensor2 对 tensor1 导数（tensor2 需为 tensor1 的表达式，且求导前要执行`requires_grad_(True)`命令）
- `tensor1.grad`：访问求导后张量的导数
- `tensor.grad.zero_()`：梯度清零（Pytorch 默认会累计梯度并存储在`.grad`内）
- `tensor.detach()`：将该变量移出计算图，当作常量处理，多用于神经网络的参数固定
- 一般很少用到向量对向量（以及更高阶）的求导，需要引入一个 gradient 参数，所以会把一个向量转化为标量求导，最常用的就是求和：`tensor.sum().backward()`。`loss`一般是一个标量，如果 loss 是矩阵，维度就会越算越大。
- 可以经过 Python 计算流再求导。

# Linear Neural network
线性回归是一个很简单的优化问题。线性回归的解可以用一个公式简单地表达出来， 这类解叫作解析解（analytical solution）。

**线性回归的最小二乘解**（Normal Equation）：

\[
w^* = (X^T X)^{-1} X^T y
\]

其中：
- \(X\) 是特征矩阵（通常每行一个样本）
- \(y\) 是目标值向量
- \(w^*\) 是最优权重参数向量

该公式要求 \(X^T X\) 可逆（即特征之间线性无关）。

---

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

![](./img/multilayer%20perceptron%20example)

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

