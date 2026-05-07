---
author: lencelg from Arcadia Bay
title: cmu10-202 note
---

[TOC]

# Lec 2
**The supervised machine learning paradigm**

- The "usual" programming approach
  - Specification of the desired behavior
  - Think about logic that will achieve that behavior
  - Write program

- The ML approach
  - Examples of the desired behavior
  - ML Algorithm
  - Produced "program"

**Downstream tasks** are specific AI, NLP, or computer vision applications that utilize pre-trained foundational models to achieve a targeted goal

# Lec 3
**vector** : one dimensional of array
- addition
- inner product
- transpose

**matrix** : two dimensional of array
- addition
- matrix multiplication
- transpose

there is another intersting interpation of matrix-verctor interpation

![](./img/matrix_vector_interpation.png)

- Properties of matrix multiplication  
  - Distributive: $A(B + C) = AB + AC$
  - Associative:  $(AB)C = A(BC) $
  - Not commutative: $ AB \neq BA $
  - Transpose of product: $ (AB)^T = B^TA^T $

# Lec 4
one intersting thing of this lecture is how the prof assign the W marix

the example use the MNIST traning set

```python
W = torch.zeros(10,784)
for i in range(10):
  # assign mean of training example of all the data
    W[i] = X_train[y_train==i].mean(dim=0)

y_pred = X_train @ W.T
(y_pred.argmax(dim=1) == y_train).float().mean()
```
```console
tensor(0.6233)
```

but when you normalize the W using `W[i] = W[i] / W[i].norm()`, the accuary of predicting 1 comes to 0.8216

# Lec 5
从“最大化似然”到“最小化负对数似然”

最大似然估计说：我们要选择模型参数，使得训练数据出现的概率最大。对单个样本，似然就是 \(P(\text{output}=y \mid \hat{y})\)。

最大化这个概率等价于 **最小化它的负对数**（因为负对数是单调递减函数）：

\[
-\log P(\text{output}=y \mid \hat{y})
\]

当概率接近1时，负对数接近0；当概率接近0时，负对数趋向无穷大。这正好是一个理想的损失函数：预测越准确，损失越小。

代入 Softmax 表达式，就得到：

\[
L_{CE} = -\log\left( \frac{e^{\hat{y}_y}}{\sum_j e^{\hat{y}_j}} \right)
\]

利用对数性质展开：

\[
-\log\left( \frac{e^{\hat{y}_y}}{\sum_j e^{\hat{y}_j}} \right)
= -\left[ \hat{y}_y - \log \sum_j e^{\hat{y}_j} \right]
= -\hat{y}_y + \log \sum_{j=1}^K e^{\hat{y}_j}
\]

# Lec 10: Structured input models
前面几节没什么好做笔记的

outline
- Language Modeling
- Unstructured to structured inputs
- Three operations of structured inputs models
- Example (beyond text)

首先介绍的例子是预测下一个词, 输入用 one-hot 的词库向量表示，然后把每个词库里的词的 one-hot 堆叠在一起形成一个大的向量，这是无结构化的输入

结构化就是不形成一个向量，而是堆叠成一个矩阵，如果词库中有 $ n $ 个词，输入有 $ d $ 个词， 那么输入的 one-hot matrix input $\in R^{n \times d}$

三种运算
- 矩阵右乘运算可以让参数进行预测形成输出
- 矩阵左乘运算可以捕获更多的信息， e.g. 输入的位置关系
- 非线性运算用在激活函数

# Lec 11: Self Attention
outline
- LLM settings
- The self-attention operation
- (Soft) lookup table interpretation
- Properties of self-attention
- Multi-head attention

记得上节课的矩阵左乘可以捕获更多信息，于是自注意力运算可以算是矩阵左乘和右乘的混合

**The self-attention operation**

\[X \in \mathbb{R}^{T \times d}\]

\[Y = \text{SelfAtt}(X)\]

1. **Form three matrices**  
   \[ Q, K, V \in \mathbb{R}^{T \times d} \]

   \[   Q = XW_Q^T, \quad K = XW_K^T, \quad V = XW_V^T\]

   \[   W_{Q,K,V} \in \mathbb{R}^{d \times d}\]

2. **Output self-attention operation**  

   \[   Y = \text{SelfAtt}(Q, K, V)\]

   \[   = \text{softmax}\left(\frac{QK^T}{\sqrt{d}}\right)V\]

the output $y \in \mathbb R^{T \times d}$