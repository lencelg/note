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

在torch中可以使用`mulitnomial`来辅助sample

```python
import torch

# Y = LLM(X)
batch_size = 1
seq_len = 100
k = 5
Y = torch.randn(batch_size, seq_len, k)

p = torch.softmax(Y[0,-1], dim=-1)
# 抽样100次
torch.multinomail(p, 100, dim=-1, replacement=True)
print(p)
```

## Temperature sampling
上面的sample(Navie Sampling)过于随机，我们想倾向于对真正有用的信息进行sample

basic idea:

- Temperature sampling  
\[ p = \text{softmax} \left( \frac{Y}{\tau} \right) \quad \tau \in \mathbb{R}^+ \]

- As \( \tau \to 0^+ \), \( p \) puts all probability on the most likely next word.

- As \( \tau \to \infty \), \( p \) becomes a uniform distribution.

## KV caching
记得sample之后是将结果加入input sentence, 这样就会有很多重复的计算，于是考虑使用kv cache来提高效率

下面先将motivation

我们只想计算$Y_{T+1}$, 记得矩阵右乘的性质和self-attention的计算过程

1. **Right multipliers** + non-linear operations  
   → apply independently to the rows of our internal representations  

\[\sigma \left( --- x_{T+1}^T --- \right) w_2\]

2. **Self Attention**  
   SelfAttention(Q, K, V) = softmax \(\left( \frac{QK^T}{\sqrt{\alpha}} \right)V\)

\[Y = \text{softmax} \left( \frac{QK^T}{\sqrt{\alpha}} \right) V\]

\[ \begin{bmatrix} Y \\ 
Y_{T+1} \end{bmatrix} =
\operatorname{softmax}
\left(
\frac{
\begin{bmatrix}
Q \\
q_{T+1}^{\top}
\end{bmatrix}
\begin{bmatrix}
K \\
k_{T+1}^{\top}
\end{bmatrix}^{\top}
}{\sqrt{\alpha}}
\right)
\begin{bmatrix}
V \\
v_{T+1}^{\top}
\end{bmatrix}
\]

\[ Y_{T+1}^{\top} =
\operatorname{softmax}
\left(
\frac{
q_{T+1}^{\top}
\begin{bmatrix}
K \\
k_{T+1}^{\top}
\end{bmatrix}^{\top}
}{\sqrt{\alpha}}
\right)
\begin{bmatrix}
V \\
v_{T+1}^{\top}
\end{bmatrix}
\]

于是这里的$K_{T+1}$和$V_{T+1}$都可以通过右乘得到，$K$ and $V$ can use cache now.

kv caching 的步骤如下：

- Given \(x_{T+1}\) as input to self-attention

- Store \(K^{\text{cache}}, V^{\text{cache}}\)

- Form
\[ q_{T+1} = W_Q x_{T+1},
\quad
k_{T+1} = W_K x_{T+1},
\quad
v_{T+1} = W_V x_{T+1}
\]

- Append \(k_{T+1}\) and \(v_{T+1}\) to cache

\[ K^{\text{cache}} := \begin{bmatrix} K^{\text{cache}} \\ k_{T+1}^{\top} \end{bmatrix} \qquad V^{\text{cache}} := \begin{bmatrix}
V^{\text{cache}} \\
v_{T+1}^{\top}
\end{bmatrix}
\]

- Form output

\[ y_{T+1} =
\mathrm{SelfAttn}
\left(
q_{T+1}^{\top},
K^{\text{cache}},
V^{\text{cache}}
\right)
\]

\[ = \operatorname{softmax} \left(
\frac{
q_{T+1}^{\top}
(K^{\text{cache}})^{\top}
}{
\sqrt{d}
}
\right)
V^{\text{cache}}
\]

# Lec 14: Tokenization
outline
- From "words" to tokens  
- Byte Pair Encoding (BPE) Tokenization  
  - Training  
  - Encoding  
  - Decoding

basic concept
- token ≡ "collection of characters"
- tokens include whitespace
- text → tokens is not unique* in general  (the same text can be represented by different token sequences)
- tokens → text is unique

在[openai tokenizer](https://platform.openai.com/tokenizer)上可以进行tokenization的体验

## BPE
**Byte Pair Encoding (BPE) Tokenization** 有三个过程
- **"Training"** – using a large collection of text, construct our set of tokens (and an ordering of tokens that lets us uniquely tokenize text)
- **Encoding** – convert text to a sequence of token ids
- **Decoding** – convert a sequence of token ids to text

traning steps are as follow:
1. Split text on whitespace (leaving whitespace in words).  
   split words into characters (called corpus)
2. Define tokens as set of all single characters.
3. Repeat until we reach a target # of tokens.
   - Find the most common pair of tokens.
   - Merge these into new token (save the merge rule).
4. Return list of tokens and merge rules.

**Keep only unique words (and counts) in corpus.**

encoding的过程结合教授板书的例子来理解更好

![](./img/BPE%20encoding.png)

BPE Decodings 容易理解: Replace each token id with its text

# Lec 15: Training an LLM + Adam
outline
- Training an LLM  
- Adam optimizer

## Training an LLM
简化的流程大概如下

1. Collect data, i.e text data (from internet, or from existing dataset)

2. Tokenize the data (store this)

3. Split data into chunks of size seq_len+1 (also will minibatches)

4. Repeat for \( i = 1, \dots, \# \) chunks
   - \( X_{tok} = token[i][:seq\_len] \)
   - \( Y = token[i][1:] \)
   - \( \hat{Y} = LLM(X_{tok}) \)
   - Loss = \(\sum_{t=1}^{length} \mathcal{L}(\hat{Y}_t, Y_T)\)
   - Update parameters (i.e. weights) with a gradient update

## Adam optimizer
- Stochastic Gradient Descent (SGD) update  
  \[ W := W - \eta \nabla_w Loss(\hat{y}(w), y) \]

- Problems with SGD  
  - **bound around**：损失曲面在某些方向上陡峭，在另一些方向上平坦。SGD 会在陡峭方向上来回摆动，收敛慢。  
    ➡ **动量（Momentum）** ：累积历史梯度方向，平滑更新，减少震荡。

  - **梯度尺度不一**：不同权重参数的梯度数量级可能差异很大（某些层梯度很小，某些层很大）。统一的学习率不适合所有参数。
    ➡ **自适应学习率(adaptive update)**：为每个参数单独调整步长（e.g. AdaGrad、RMSProp）。

- Adam  
  - Like SGD with momentum, except that we also compute average magnitude of each element's gradient, scale updates by this magnitude.  

1. Initialize \( u, v := 0 \), \( W \)  
2. Repeat for \( t = 1, \dots \)  
   \[   u := \beta_1 u + (1 - \beta_1) \nabla_{\text{loss}}\]  

   \[   v := \beta_2 v + (1 - \beta_2) \nabla_{\text{loss}}^2 \\
   \text{(elementary square)} \]    

   \[   \hat{u} := u / (1 - \beta_1^t)\]  

   \[   \hat{v} := v / (1 - \beta_2^t)\]  

   \[   w := w - n \frac{\hat{u}}{\sqrt{\hat{v} + \epsilon}} \\
   \text{(elementwise division and square root)}\]    

- 需要记录\( u, v \), 3倍的参数量
- 偏差修正（除以 \(1-\beta^t\)）解决初始时刻估计偏小的问题。
- 一阶动量（动量项）：梯度的指数加权平均，模拟速度。
- 二阶动量（自适应项）：梯度平方的指数加权平均，模拟每个参数的历史尺度，从而动态调整学习率。

# Lec 16: Introduction to post-training
outline
- An example: chat and instruction following
- The goals of post-training
- Methods for post-training
- Foundation Models and evolving ML paradigm

在例子里面教授的意思大概就是如何让训练好的模型来做其他的任务，通过post-traning来进行transfer learning

- pretrain = normal autoregressive training of an LLM  
- post-training = training done after pretraining to make the LLM solve some task or follow some prescribed behavior  
- Common paradigm: pretrain an LLM on lots of data, post-train on **relatively little data**
- With relatively little post-training, LLMs can often exhibit the desired behavior

## post-traning goals
post-traning 的三个任务如下(llm generated)：
- **监督微调**  
  - 主要目标：建立对话格式，学会理解并执行指令  
  - 主流技术方法：指令微调、参数高效微调（如 LoRA）  
  - 所需数据：数万至数百万条人工标注或合成的“指令-回复”对  

- **偏好对齐**  
  - 主要目标：让模型理解人类的价值观与偏好，从“能用”变为“好用”  
  - 主流技术方法：RLHF、DPO、KTO  
  - 所需数据：“好/坏”或“偏好”的对比数据对（如人类对两个回复打分）  

- **强化学习**  
  - 主要目标：通过自我探索与反馈，解锁并提升复杂的推理能力  
  - 主流技术方法：GRPO、DAPO、RLVR  
  - 所需数据：可验证的任务（如数学题答案、代码执行结果、规则逻辑）  

教授还有一个补充的goal
- Tool use (web search, terminals, compilers, general computer use)

## method for post-traning
首先是few-shot prompts

在输入 prompt 中直接给模型展示几个任务示例，让它“照葫芦画瓢”
- Prompts / few-shot prompts
  - Build a prompt that produces the desired behaviour of them, by providing some examples  
    x = "What is the capital of England? London 
    what is in the capital of France? Paris 
    what is the capital of the US?"
    y = "Washington, DC"

不需要重新训练或微调，节省计算资源；缺点是依赖模型已有的推理能力，且对长上下文和复杂任务可能不够稳定。

---

Supervised  Finetunning(SFT)
- Keep training  model (auto regressively) on data that demonstrates on desired behavior

---
利用强化学习

- Reinforcement learning  
  - Instead of providing a target response to given prompt, we have a **reward function** that characterizes how good a response is.  
  - Generate a lot of possible responses to prompt, use the reward function to score them, train (autoregressively) on the "good" responses.

---

- Hybrids
  - Direct Preference Optimization(DPO): train model on pairs of good/bad responses
  - Distillation(知识蒸馏): training to match the distribution of tokens from another model

最后就是ml的趋势介绍

![](./img/evolution%20of%20ml%20paradigm.png)

# Lec 17: Chat and instruction tuning
outline
- Chat formatting
- Notation
- Supervised fine-tuning (SFT)
- Direct Preference Optimization (DPO)

使用tag来进行format.
```
现在有两个句子
<user> How are you? </user >
<assistant> Fine, thanks for asking </assistant >

于是X = <user> How are you? </user > <assistant>
y = Fine, thanks for asking </assistant >

第二次对话
<user> How's the weather  </user>
<assistant> I don't have access to weather info  </assistant>
  
X = 一开始的两个句子加上 <user> How's the weather  </user> <assistant>
y就是剩下的
```

## Supervised Finetuning (SFT)

SFT和监督学习的思想是一样的

- Given dataset of \((x_i, y_i)\) \(i = 1, \dots, N\) pairs

- Minimize  
  \[  \mathcal{L}_{SFT} = \sum_{i=1}^N - \log p(y_i | x_i)\]

  using e.g. stochastic gradient descent (or Adam,...)

- The same as minimizing cross entropy loss only on the \(y\) portion of each pair

- Common to include only one conversation per element of the batch

缺点： 很难找到好的数据集。

## Direct Preference Optimization (DPO)
Direct Preference Optimization (DPO)

- Given a data set of triples \((x_i, y_i^+, y_i^-)\), \(i=1,...,N\)
  indicator that for input \(x_i\), we prefer
  output \(y_i^+\) to \(y_i^-\)
- define loss as follow
    2.

\[\mathcal{L}_{DPO} = \frac{1}{N} \sum_{i=1}^N \text{softplus} \left( -\log p(y_i^+ |x_i) + \log p(y_i^- |x_i) \right) + \log \text{pref}(y_i^+ |x_i) - \log \text{pref}(y_i^- |x_i)\]

where

\[\text{softplus}(x) = \log(1+e^x)\]

\[\text{pref}(y |x) \quad \text{来自于pref模型(一个训练的好的模型)}\] 

# Lec 18 - Reinforcement Learning
outline
- Back ground on RL
- RL for LLMs
- REINFORCE
- Additions

## RL for LLMs 
- Goal: adjust LLM to maximize expected reward  
  maximize \[ E_{y \sim p(y|x)} [R(x, y)] \]  

- Preview of the results method  

1. Generate a bunch of samples  
   \[ Y_1, \dots, Y_N \sim p(y|x) \]  

2. Calculate the reward of each sample  
   \[ r_i = R(x, y_i) \]  

3. Train on the generated samples  
   (i.e. with SFT) weighted by reward  
     
   \[\text{maximize} \quad \frac{1}{N} \sum_{i=1}^N \log p(y_i | x) \cdot r_i \]  

\[ W := W + \eta \frac{1}{N} \sum_{i=1}^N r_i \nabla_w \log p(y_i | x) \]

## REINFORCE
- Preview: how can we approximate expectation?

\[ E_{y \sim p(y|x)} [R(x, y)]? \]

Monte Carlo Sampling(helpful for this):

1. Draw samples \( y_1, \dots, y_N \sim p(y|x) \)
2. **Approximate expectation** as average over the samples

\[ E_{y \sim p(y|x)} [R(x, y)] = \frac{1}{N} \sum_{i=1}^N R(x, y_i) \]

问题在于如何计算梯度，一种方法是利用Monte Carlo Sampling近似计算

推导过程如下：

$$
\begin{align}
&\nabla_w E_{y \sim p(y|x)} [R(x, y)] \\
&=\nabla_w \sum_y p(y|x) R(x, y) \\
&= \nabla_w \sum_y p(y|x) R(x, y)\\
&= \sum_y \frac{p(y|x)}{p(y|x)} \nabla_w p(y|x) R(x, y)\\
\end{align}
$$

$$
\text{notice that} \quad \frac{\nabla_w p(y|x)}{p(y|x)} = \nabla_w \log p(y|x)
$$

$$
\begin{align}
\text{上式} &= \sum_y p(y|x) \nabla_w \log p(y|x) R(x, y)\\
&= E_{y \sim p(y|x)} [\nabla_w \log p(y|x) R(x, y)
\end{align}
$$

- approximate this term with Monte Carlo sampling  
  1. Sample: $ y_1, \dots, y_n \sim p(y|x) $
  2. Approximate:  
    $$  \nabla_w E_{y \sim p(y|x)} [R(x, y)] = \frac{1}{n} \sum_{i = 1}^N (\nabla_w \log p(y_i|x)) R(x, y_i)$$

下面附教授的板书加以理解

![](./img/reinforcement%20learning.png)

# Additions

- Baseline or advantage function  
  $$ \frac{\partial}{\partial x} (f(x) + c) = \frac{\partial}{\partial x} f(x) $$

- Adding constant to reward doesn’t change its gradient  
  $$ \nabla_w E_{y \sim p(y|x)} [R(x, y) + c] = \nabla_w E_{y \sim p(y|x)} [R(x, y)] $$

- Subtract the average reward from reward of each sample  
  $$ \nabla_w E_{y \sim p(y|x)} [R(x, y)] \approx \frac{1}{N} \sum_{i=1}^N \nabla_w \log p(y_i | x) (R(x_i, y_i) - \bar{R}) $$

where  
$$ \bar{R} = \frac{1}{N} \sum_{i=1}^N R(x_i, y_i) $$

- Importance weighting: weights the samples to allow for sampling from distributions other than $ p(y|x) $

- Regularization: penalize large deviations from the distribution of the current model