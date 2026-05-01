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