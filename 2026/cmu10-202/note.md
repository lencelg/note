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

教授解释的例子是python的字典查询，有键、值、查询。

经过softmax后考虑得到的某个row元素较大并且接近1, 其他自然就接近0了，左乘以后算是筛选了$v$中的某一行元素，其他行的信息很少，这就相当与专注了某一部分信息。

然后对于每个$q_i, i \in T$都做同样的查询看看哪一部分与它接近并返回查询的值.

下面附教授的板书

![](./img/look%20up%20table%20interpation.png)

## properties of self-attention

自注意力运算的性质
1. 与$X$内的行排序无关，于是自注意力运算可以看作是集合运算
2. 自注意力的 **全局混合能力** : Every output row can depend on every input row (full mixings over rows) \( A(x) \times w_v \)

由于全局混合能力能够根据未来的词来预测过去的词，于是在language model中使用 masked self attention 来去除这种能力的影响

## multi-head self-attention
base idea: **多角度捕捉依赖** ：不同的头可以关注序列中不同的语义关系（如局部语法、长距离依赖、不同位置交互）。然而单一的self-attention的参数是一样的，无法做到这一点.

basic steps
1. \( Q = XW_Q^T, \quad K = XW_K^T, \quad V = XW_V^T \)

2. Partition each \( Q, K, V \) by columns in different group called "heads"

\[Q = 
\begin{bmatrix}
Q_1 & Q_2 & \cdots & Q_n
\end{bmatrix}\text{(same for K, V)}\] 

\[Q_i, K_i, V_i \in \mathbb R^{T \times \frac{d}{n}}\]

\[ W_P \in \mathbb{R}^{T \times d} \]

4. \( Y = [\text{selfAttn}(Q_1, K_1, V_1) \cdots \text{selfAttn}(Q_n, K_n, V_n)] W_P \) 

# Lec 12: Transformers
outline
- Transformer Layers + Transformer
- Parallel prediction
- Positional encoding / embedding
- Masked attention

# Transformer Layers and Transformers

**Transformer Layer** = self-attention + two-layer MLP + normalization + residual connections

**Transformer** = Embeddings + (Nx) Transformer Layers + normalization + output linear layer

**Transformers Layer (x)**  
1. \( Z = X + \text{MultiheadAttn}(\text{norm}(x)) \)
2. \(\text{Return } Y = Z + \text{MLP}(\text{norm}(Z)) \)
3. \(MLP(z) = \sigma(2w_1^T w_2^T)\)

Norm (x) = \(\frac{x}{||x||_{2}} = x / \sqrt{\sum_{i=1}^d x_i^2}\)

MLP 是 Multi-Layer Perceptron（多层感知机）的缩写, 在 Transformer 的上下文中，每个 Transformer 层中的 MLP 通常是一个两层的全连接前馈网络（FFN），并带有非线性激活函数（常用 ReLU 或 GELU）。

- Transformer \( (X_{oh}) \)  
  1. \( X := X_{oh} W_E^T \in \mathbb{R}^{d \times v} \)  
  2. Repeat \( N \) times:  
    \[
    X := \text{TransformerLayer}_i(X), i \in N
    \]  
  3. Output \( Y = \text{norm}(X) W_O^T \)  

notice that \( Y \in \mathbb{R}^{T \times V} \) and \( W_O \in \mathbb{R}^{V \times d} \)

## posistion embedding

记得multihead-attention是具有全局混合能力的，于是transoformer无法捕获输入的位置信息，于是考虑进行 **位置嵌入(posistion embedding)**

教授介绍了几种方法。

- Absolute positional embedding: adding a fixed (different) embedding to each position of X

1. \( X = X_{oh} W_E^T + P \)

notice that \(P \in \mathbb{R}^{T \times d}\) is fixed matrix with different rows, and P contains the posistion information

\[P = 
\begin{bmatrix}
p_1^T \\
p_2^T \\
...   \\
p_T^T \\
\end{bmatrix}\]

其他就是在softmax上做改动。

Other methods  

-  \[  SelfAttn(Q, K, v) = \text{softmax} \left( \frac{QK^T}{\sqrt{d}} - D \right) v\]

- \[SelfAttn(Q, K, v) = softmax \left(\frac{QD^KT^T}{\sqrt{d}}\right)v\]

## masked self-attention
记得矩阵左乘以后是一个满矩阵， 将部分\(A\)的对角线的元素以后全部设置为零就可以实现mask了，通常是加上一个mask矩阵\(M\)然后再进行softmax

附教授的板书加以理解

![](./img/masked%20self%20attention.png)

# Lec 13: Efficient LLM Inference
outline 
- Generations text from LLMs  
- Temperature Sampling  
- KV caching  

## Generations text from an LLM

\[Y = LLM(x_{oh})\]

\[x_{oh} =
\begin{bmatrix}
0 \cdot 1 & \cdots & 0 \\
0 \cdot 1 & \cdots & 0 \\
0 \cdot 1 & \ddots & 0
\end{bmatrix}\]

\[\text{the "quirk" brown"}\]

\[Y =
\begin{bmatrix}
0.1 & -5 & \cdots & 1.2 \\
\vdots & \vdots & \ddots & \vdots \\
\vdots & \vdots & \vdots & \vdots \\
c_T
\end{bmatrix}\]

- **Sampling** from an LLM

  1. Take last output \( Y_T \) ∈ ℝ\(^k\)  
     convert to probability

     \[P = {\text{softmax}(Y_T)},\quad {\text{softmax}(y)} = \frac{\text{exp}(y)}{\sum_{j=1}^k \text{exp}(y_j)}\]

     - \( \exp(y) \) is the exponential function  
     - \( \sum_{j=1}^k \exp(y_j) \) is the sum of exponentials
  2. Sample next word from p, append to our input sentence