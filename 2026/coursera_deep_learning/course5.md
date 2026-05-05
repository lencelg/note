---
author: lencelg from Arcadia Bay
title: Recurrent Neural network
---
this note is made from coursera deep learning course, good reference note: [bighuang624/Andrew-Ng-Deep-Learning-notes](https://kyonhuang.top/Andrew-Ng-Deep-Learning-notes/#/)

[TOC]

# Week1
自然语言和音频都是前后相互关联的数据，对于这些序列数据需要使用**循环神经网络（Recurrent Neural Network，RNN）**来进行处理。

typical application
- Speech recognition
- Music generation
- Sentiment classification
- DNA sequence analysis
- Machine translation
- Video activity recognition
- Name entity recognition
## math notation

对于一个序列数据 $x$，用符号 $x^{⟨t⟩}$来表示这个数据中的第 $t$个元素，用 $y^{⟨t⟩}$来表示第 $t$个标签，用 $T_x$ 和 $T_y$来表示输入和输出的长度。对于一段音频，元素可能是其中的几帧；对于一句话，元素可能是一到多个单词。

第 $i$ 个序列数据的第 $t$ 个元素用符号 $x^{(i)⟨t⟩}$，第 $t$ 个标签即为 $y^{(i)⟨t⟩}$。对应即有 $T^{(i)}_x$ 和 $T^{(i)}_y$。

想要表示一个词语，需要先建立一个**词汇表（Vocabulary）**，或者叫**字典（Dictionary）**。将需要表示的所有词语变为一个列向量，可以根据字母顺序排列，然后根据单词在向量中的位置，用 **one-hot 向量（one-hot vector）**来表示该单词的标签：将每个单词编码成一个 $R^{|V| \times 1}$向量，其中 $|V|$是词汇表中单词的数量。一个单词在词汇表中的索引在该向量对应的元素为 1，其余元素均为 0。

例如，'zebra'排在词汇表的最后一位，因此它的词向量表示为：

$$w^{zebra} = \left [ 0, 0, 0, ..., 1\right ]^T$$

**补充：**one-hot 向量是最简单的词向量。它的**缺点**是，由于每个单词被表示为完全独立的个体，因此单词间的相似度无法体现。例如单词 hotel 和 motel 意思相近，而与 cat 不相似，但是

$$(w^{hotel})^Tw^{motel} = (w^{hotel})^Tw^{cat} = 0$$

## Recurrent Neural Network

对于序列数据，使用标准神经网络存在以下问题：

* 对于不同的示例，输入和输出可能有不同的长度，因此输入层和输出层的神经元数量无法固定。
* 从输入文本的不同位置学到的同一特征无法共享。
* 模型中的参数太多，计算量太大。

为了解决这些问题，引入**循环神经网络（Recurrent Neural Network，RNN）**。一种循环神经网络的结构如下图所示：

![Recurrent-Neural-Network](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Recurrent-Neural-Network.png)

当元素 $x^{⟨t⟩}$ 输入对应时间步（Time Step）的隐藏层的同时，该隐藏层也会接收来自上一时间步的隐藏层的激活值 $a^{⟨t-1⟩}$，其中 $a^{⟨0⟩}$ 一般直接初始化为零向量。一个时间步输出一个对应的预测结果 $\hat y^{⟨t⟩}$。

循环神经网络从左向右扫描数据，同时每个时间步的参数也是共享的，输入、激活、输出的参数对应为 $W_{ax}$、$W_{aa}$、$W_{ya}$。

下图是一个 RNN 神经元的结构：

![RNN-cell](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/RNN-cell.png)

前向传播过程的公式如下：

$$a^{⟨0⟩} = \vec{0}$$

$$a^{⟨t⟩} = g_1(W_{aa}a^{⟨t-1⟩} + W_{ax}x^{⟨t⟩} + b_a)$$

$$\hat y^{⟨t⟩} = g_2(W_{ya}a^{⟨t⟩} + b_y)$$

激活函数 $g_1$通常选择 tanh，有时也用 ReLU；$g_2$可选 sigmoid 或 softmax，取决于需要的输出类型。

为了进一步简化公式以方便运算，可以将 $W_{aa}$、$W_{ax}$ **水平并列**为一个矩阵 $W_a$，同时 $a^{⟨t-1⟩}$和 $ x^{⟨t⟩}$ **堆叠**成一个矩阵。则有：

$$W_a = [W_{aa}, W_{ax}]$$

$$a^{⟨t⟩} = g_1(W_a[a^{⟨t-1⟩}; x^{⟨t⟩}] + b_a)$$

$$\hat y^{⟨t⟩} = g_2(W_{ya}a^{⟨t⟩} + b_y)$$

### backward propagation
为了计算反向传播过程，需要先定义一个损失函数。单个位置上（或者说单个时间步上）某个单词的预测值的损失函数采用**交叉熵损失函数**，如下所示：

$$L^{⟨t⟩}(\hat y^{⟨t⟩}, y^{⟨t⟩}) = -y^{⟨t⟩}log\hat y^{⟨t⟩} - (1 - y^{⟨t⟩})log(1-\hat y^{⟨t⟩})$$

将单个位置上的损失函数相加，得到整个序列的成本函数如下：

$$J = L(\hat y, y) = \sum^{T\_x}_{t=1} L^{⟨t⟩}(\hat y^{⟨t⟩}, y^{⟨t⟩})$$

循环神经网络的反向传播被称为**通过时间反向传播（Backpropagation through time）**，因为从右向左计算的过程就像是时间倒流。

更详细的计算公式如下：

![formula-of-RNN](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/formula-of-RNN.png)

## Language Model
**语言模型（Language Model）**是根据语言客观事实而进行的语言抽象数学建模，能够估计某个序列中各元素出现的可能性。

建立语言模型所采用的训练集是一个大型的**语料库（Corpus）**，指数量众多的句子组成的文本
- 第一步是**标记化（Tokenize）**，即建立字典
- 然后将语料库中的每个词表示为对应的 one-hot 向量。
- 需要增加一个额外的标记 \<EOS>（End of Sentence）来表示一个句子的结尾。标点符号可以忽略，也可以加入字典后用 one-hot 向量表示。

对于语料库中部分特殊的、不包含在字典中的词汇，例如人名、地名，可以不必针对这些具体的词，而是在词典中加入一个 UNK（Unique Token）标记来表示。

将标志化后的训练集用于训练 RNN，过程如下图所示：

![language-model-RNN-example](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/language-model-RNN-example.png)

在第一个时间步中，输入的 $a^{⟨0⟩}$和 $x^{⟨1⟩}$都是零向量，$\hat y^{⟨1⟩}$是通过 softmax 预测出的字典中每个词作为第一个词出现的概率；在第二个时间步中，输入的 $x^{⟨2⟩}$是训练样本的标签中的第一个单词 $y^{⟨1⟩}$（即“cats”）和上一层的激活项$a^{⟨1⟩}$，输出的 $y^{⟨2⟩}$表示的是通过 softmax 预测出的、单词“cats”后面出现字典中的其他每个词的条件概率。以此类推，最后就可以得到整个句子出现的概率。

损失函数为：

$$L(\hat y^{⟨t⟩}, y^{⟨t⟩}) = -\sum_t y_i^{⟨t⟩} log \hat y^{⟨t⟩}$$

成本函数为：

$$J = \sum_t L^{⟨t⟩}(\hat y^{⟨t⟩}, y^{⟨t⟩})$$

## Sample

在训练好一个语言模型后，可以通过**采样（Sample）** 新的序列来了解这个模型中都学习到了一些什么。

![Sampling](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Sampling.png)

在第一个时间步输入 $a^{⟨0⟩}$和 $x^{⟨1⟩}$为零向量，输出预测出的字典中每个词作为第一个词出现的概率，根据 softmax 的分布进行随机采样（`np.random.choice`），将采样得到的 $\hat y^{⟨1⟩}$作为第二个时间步的输入 $x^{⟨2⟩}$。以此类推，直到采样到 EOS，最后模型会自动生成一些句子，从这些句子中可以发现模型通过语料库学习到的知识。

这里建立的是基于词汇构建的语言模型。根据需要也可以构建基于字符的语言模型，其优点是不必担心出现未知标识（UNK），其缺点是得到的序列过多过长，并且训练成本高昂。因此，基于词汇构建的语言模型更为常用。

## RNN 的梯度消失

$$The\ cat, which\ already\ ate\ a\ bunch\ of\ food,\ was\ full.$$

$$The\ cats, which\ already\ ate\ a\ bunch\ of\ food,\ were\ full.$$

对于以上两个句子，后面的动词单复数形式由前面的名词的单复数形式决定。但是**基本的 RNN 不擅长捕获这种长期依赖关系**。究其原因，由于梯度消失，在反向传播时，后面层的输出误差很难影响到较靠前层的计算，网络很难调整靠前的计算。

在反向传播时，随着层数的增多，梯度不仅可能指数型下降，也有可能指数型上升，即梯度爆炸。不过梯度爆炸比较容易发现，因为参数会急剧膨胀到数值溢出（可能显示为 NaN）。这时可以采用**梯度修剪（Gradient Clipping）**来解决：观察梯度向量，如果它大于某个阈值，则缩放梯度向量以保证其不会太大。相比之下，梯度消失问题更难解决。**GRU 和 LSTM 都可以作为缓解梯度消失问题的方案**。

## GRU

**GRU（Gated Recurrent Units, 门控循环单元）**改善了 RNN 的隐藏层，使其可以更好地捕捉深层连接，并改善了梯度消失问题。

$$The\ cat, which\ already\ ate\ a\ bunch\ of\ food,\ was\ full.$$

当我们从左到右读上面这个句子时，GRU 单元有一个新的变量称为 $c$，代表**记忆细胞（Memory Cell）**，其作用是提供记忆的能力，记住例如前文主语是单数还是复数等信息。在时间 t，记忆细胞的值 $c^{⟨t⟩}$等于输出的激活值 $a^{⟨t⟩}$；$\tilde c^{⟨t⟩}$ 代表下一个 $c$ 的候选值。$Γ\_u$ 代表**更新门（Update Gate）**，用于决定什么时候更新记忆细胞的值。以上结构的具体公式为：

$$\tilde c^{⟨t⟩} = tanh(W_c[c^{⟨t-1⟩}, x^{⟨t⟩}] + b_c)$$

$$Γ_u = \sigma(W_u[c^{⟨t-1⟩}, x^{⟨t⟩}] + b_u)$$

$$c^{⟨t⟩} = Γ_u \times \tilde c^{⟨t⟩} + (1 - Γ_u) \times c^{⟨t-1⟩}$$

$$a^{⟨t⟩} = c^{⟨t⟩}$$

当使用 sigmoid 作为激活函数 $\sigma$ 来得到 $Γ_u$时，$Γ_u$ 的值在 0 到 1 的范围内，且大多数时间非常接近于 0 或 1。当 $Γ_u = 1$时，$c^{⟨t⟩}$被更新为 $\tilde c^{⟨t⟩}$，否则保持为 $c^{⟨t-1⟩}$。因为 $Γ_u$ 可以很接近 0，因此 $c^{⟨t⟩}$几乎就等于 $c^{⟨t-1⟩}$。在经过很长的序列后，$c$ 的值依然被维持，从而实现“记忆”的功能。

以上实际上是简化过的 GRU 单元，但是蕴涵了 GRU 最重要的思想。完整的 GRU 单元添加了一个新的**相关门（Relevance Gate）** $Γ_r$，表示 $\tilde c^{⟨t⟩}$和 $c^{⟨t⟩}$的相关性。因此，表达式改为如下所示：

$$\tilde c^{⟨t⟩} = tanh(W_c[Γ_r * c^{⟨t-1⟩}, x^{⟨t⟩}] + b_c)$$

$$Γ_u = \sigma(W_u[c^{⟨t-1⟩}, x^{⟨t⟩}] + b_u)$$

$$Γ_r = \sigma(W_r[c^{⟨t-1⟩}, x^{⟨t⟩}] + b_r)$$

$$c^{⟨t⟩} = Γ_u \times \tilde c^{⟨t⟩} + (1 - Γ_u) \times c^{⟨t-1⟩}$$

$$a^{⟨t⟩} = c^{⟨t⟩}$$

## LSTM

**LSTM（Long Short Term Memory，长短期记忆）**网络比 GRU 更加灵活和强大，它额外引入了**遗忘门（Forget Gate）** $Γ\_f$和**输出门（Output Gate）** $Γ\_o$。其结构图和公式如下：

<!--$$\tilde c^{⟨t⟩} = tanh(W\_c[a^{⟨t-1⟩}, x^{⟨t⟩}] + b\_c)$$

$$Γ\_u = \sigma(W\_u[a^{⟨t-1⟩}, x^{⟨t⟩}] + b\_u)$$

$$Γ\_f = \sigma(W\_f[a^{⟨t-1⟩}, x^{⟨t⟩}] + b\_f)$$

$$Γ\_o = \sigma(W\_o[a^{⟨t-1⟩}, x^{⟨t⟩}] + b\_o)$$

$$c^{⟨t⟩} = Γ^{⟨t⟩}\_u \times \tilde c^{⟨t⟩} + Γ^{⟨t⟩}\_f \times c^{⟨t-1⟩}$$

$$a^{⟨t⟩} = Γ\_o^{⟨t⟩} \times tanh(c^{⟨t⟩})$$-->

![LSTM](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/LSTM.png)

将多个 LSTM 单元按时间次序连接起来，就得到一个 LSTM 网络。

以上是简化版的 LSTM。在更为常用的版本中，几个门值不仅取决于 $a^{⟨t-1⟩}$和 $x^{⟨t⟩}$，有时也可以偷窥上一个记忆细胞输入的值 $c^{⟨t-1⟩}$，这被称为**窥视孔连接（Peephole Connection)**。这时，和 GRU 不同，$c^{⟨t-1⟩}$和门值是一对一的。

$c^{0}$ 常被初始化为零向量。

## BRNN

单向的循环神经网络在某一时刻的预测结果只能使用之前输入的序列信息。**双向循环神经网络（Bidirectional RNN，BRNN）** 可以在序列的任意位置使用之前和之后的数据。其工作原理是增加一个反向循环层，结构如下图所示：

![BRNN](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/BRNN.png)

因此，有

$$y^{⟨t⟩} = g(W_y[\overrightarrow a^{⟨t⟩},  \overleftarrow a^{⟨t⟩}] + b_y)$$

这个改进的方法不仅能用于基本的 RNN，也可以用于 GRU 或 LSTM

**缺点**是需要完整的序列数据，才能预测任意位置的结果。例如构建语音识别系统，需要等待用户说完并获取整个语音表达，才能处理这段语音并进一步做语音识别。因此，实际应用会有更加复杂的模块。

## DRNN

循环神经网络的每个时间步上也可以包含多个隐藏层，形成**深度循环神经网络(Deep RNN)**

![DRNN](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/DRNN.png)

以 $a^{[2]⟨3⟩}$为例，有 $a^{[2]⟨3⟩} = g(W_a^{[2]}[a^{[2]⟨2⟩}, a^{[1]⟨3⟩}] + b_a^{[2]})$。

use reference note for the rest of the course

# Week2
## Word embedding
one-hot 向量将每个单词表示为完全独立的个体，不同词向量都是正交的，因此单词间的相似度无法体现。

特征化: 通过用语义特征作为维度来表示一个词，因此语义相近的词，其词向量也相近。

## analogy reasoning
词嵌入可用于类比推理。

给定对应关系“男性（Man）”对“女性（Woman）”，想要类比出“国王（King）”对应的词汇。 即$e_{man} - e_{woman} \approx e_{king} - e_? $

于是定义相似度函数：$sim(u, v)$

一个最常用的相似度计算函数是**余弦相似度（cosine similarity）**： $sim(u, v) = \frac{u^T v}{|| u ||_2 || v ||_2}$

## embedding marix
可以将嵌入学习的结果保存在嵌入矩阵中。

**嵌入矩阵（Embedding Matrix）** $E$: 将字典中位置为 $i$ 的词的 one-hot 向量表示为 $o_i$，词嵌入后生成的词向量用 $e_i$表示，则有：

$$E \cdot o_i = e_i$$

但在实际情况下一般不这么做。因为 one-hot 向量维度很高，且几乎所有元素都是 0，这样做的 **效率太低** 。因此，实践中直接用专门的函数查找矩阵 $E$ 的特定列。

## word embedding learning

### Neural Probabilistic language model
**神经概率语言模型（Neural Probabilistic Language Model）**构建了一个能够通过上下文来预测未知词的神经网络，在训练这个语言模型的同时学习词嵌入。

![Neural-language-model](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Neural-language-model.png)

训练过程中，将语料库中的某些词作为目标词，以目标词的部分上下文作为输入，Softmax 输出的预测结果为目标词。嵌入矩阵 $E$ 和 $w$、$b$ 为需要通过训练得到的参数。

在得到嵌入矩阵后，就可以得到词嵌入后生成的词向量。

### Word2Vec
**Word2Vec** 是一种简单高效的词嵌入学习算法，包括 2 种模型：

* **Skip-gram (SG)**：根据词预测目标上下文
* **Continuous Bag of Words (CBOW)**：根据上下文预测目标词

每种语言模型又包含**负采样（Negative Sampling）**和**分级的 Softmax（Hierarchical Softmax）**两种训练方法。

训练神经网络时候的隐藏层参数即是学习到的词嵌入。

### Skip-gram
![new-Skip-Gram](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/new-Skip-Gram.png)

从左到右是 One-hot 向量，乘以 center word 的矩阵 $W$ 于是找到词向量，乘以另一个 context word 的矩阵 $W'$ 得到对每个词语的“相似度”，对相似度取 Softmax 得到概率，与答案对比计算损失。

设某个词为 $c$，该词的一定词距内选取一些配对的目标上下文 $t$，则该网路仅有的一个 Softmax 单元输出条件概率：

$$p(t|c) = \frac{exp(\theta_t^T e_c)}{\sum^m_{j=1}exp(\theta_j^T e_c)}$$

$\theta_t$ 是一个与输出 $t$ 有关的参数，其中省略了用以纠正偏差的参数。损失函数仍选用交叉熵：

$$L(\hat y, y) = -\sum^m_{i=1}y_ilog\hat y_i$$

在此 Softmax 分类中，每次计算条件概率时，需要对词典中所有词做求和操作，因此 **计算量很大**

解决方案之一是使用一个**分级的 Softmax 分类器（Hierarchical Softmax Classifier）**，形如二叉树。在实践中，一般采用霍夫曼树（Huffman Tree）而非平衡二叉树，常用词在顶部。

如果在语料库中随机均匀采样得到选定的词 $c$，则 'the', 'of', 'a', 'and' 等出现频繁的词将影响到训练结果。因此，采用了一些策略来平衡选择。

### CBOW
CBOW 在新版的视频里面已经不介绍了，只有refernce note里面有介绍

![CBOW](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/CBOW.png)

CBOW 模型的工作方式与 Skip-gram 相反，通过采样上下文中的词来预测中间的词。

### Negative sampling
为了解决 Softmax 计算较慢的问题，Word2Vec 的作者后续提出了**负采样（Negative Sampling）**模型。

![Defining-a-learning-problem](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Defining-a-learning-problem.png)

当输入的词为一对上下文-目标词时，标签设置为 1（这里的上下文也是一个词）。另外任意取 k 对非上下文-目标词作为负样本，标签设置为 0。

对于小数据集，k 取 5~20 较为合适；而当有大量数据时，k 可以取 2~5。

改用多个 Sigmoid 输出上下文-目标词（c, t）为正样本的概率：

$$P(y=1 | c, t) = \sigma(\theta_t^Te_c)$$

其中，$\theta_t$、$e_c$ 分别代表目标词和上下文的词向量。

之前训练中每次要更新 n 维的多分类 Softmax 单元（n 为词典中词的数量）。现在每次只需要更新 k+1 维的二分类 Sigmoid 单元，计算量大大降低。

关于计算选择某个词作为负样本的概率，作者推荐采用以下公式（而非经验频率或均匀分布）：

$$p(w_i) = \frac{f(w_i)^{\frac{3}{4}}}{\sum^m_{j=0}f(w_j)^{\frac{3}{4}}}$$

其中，$f(w_i)$ 代表语料库中单词 $w_i$ 出现的频率。这种学习方式更加平滑，能够增加低频词的选取可能。

### Glove Vectors
**GloVe（Global Vectors）** 是另一种流行的词嵌入算法。

Glove 模型基于语料库统计了词的**共现矩阵**$X$，$X$中的元素 $X_{ij}$ 表示单词 $i$ 和单词 $j$ “为上下文-目标词”的次数。用梯度下降法最小化以下损失函数：

$$J = \sum^N_{i=1}\sum^N_{j=1}f(X_{ij})(\theta^t_ie_j + b_i + b_j - log(X_{ij}))^2$$

其中，$\theta_i$、$e_j$是单词 $i$ 和单词 $j$ 的词向量；$b_i$、$b_j$；$f()$ 是一个用来避免 $X_{ij}=0$时$log(X_{ij})$为负无穷大、并在其他情况下调整权重的函数。$X_{ij}=0$时，$f(X_{ij}) = 0$。

“为上下文-目标词”可以代表两个词出现在同一个窗口。此时$\theta_i$ 和 $e_j$ 是完全对称的。因此在训练时可以一致地初始化二者，使用梯度下降法处理完以后取平均值作为二者共同的值。

各种词嵌入算法学到的词向量实际上大多都超出了人类的理解范围，难以从某个值中看出与语义的相关程度。

## Sentiment classification
情感分类是指分析一段文本对某个对象的情感是正面的还是负面的。

情感分类的问题之一是标记好的训练数据不足。但是有了词嵌入得到的词向量，中等规模的标记训练数据也能构建出一个效果不错的情感分类器。

使用 RNN 能够实现一个效果不错的情感分类器：

![RNN-sentiment-classification](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/RNN-sentiment-classification.png)

## Debiasing word embeddings
problem: 语料库中可能存在性别歧视、种族歧视、性取向歧视等非预期形式偏见（Bias），这种偏见会直接反映到通过词嵌入获得的词向量。

**1. 中和本身与性别无关词汇**

对于“医生（doctor）”、“老师（teacher）”、“接待员（receptionist）”等本身与性别无关词汇，可以**中和（Neutralize）**其中的偏见。

首先用“女性（woman）”的词向量减去“男性（man）”的词向量，得到的向量 $g=e_{woman}−e_{man}$ 就代表了“性别（gender）”。假设现有的词向量维数为 50，那么对某个词向量，将 50 维空间分成两个部分：与性别相关的方向 $g$ 和与 $g$ **正交** 的其他 49 个维度 $g_{\perp}$。如下左图：

![Neutralize](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Neutralize.png)

而除偏的步骤，是将要除偏的词向量（左图中的 $e_{receptionist}$）在向量 $g$ 方向上的值置为 0，变成右图所示的 $e^{debiased}_{receptionist}$。

公式如下：

$$e^{bias_component} = \frac{e*g}{||g||_2^2} * g$$
$$e^{debiased} = e - e^{bias\_component}$$

**2. 均衡本身与性别有关词汇**

对于“男演员（actor）”、“女演员（actress）”、“爷爷（grandfather）”等本身与性别有关词汇，中和“婴儿看护人（babysit）”中存在的性别偏见后，还是无法保证它到“女演员（actress）”与到“男演员（actor）”的距离相等。

对这样一对性别有关的词，除偏的过程是**均衡（Equalization）** 它们的性别属性。其核心思想是确保一对词（actor 和 actress）到 $g_{\perp}$ 的距离相等。

![Equalization](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Equalization.png)

公式：

$$ \mu = \frac{e_{w1} + e_{w2}}{2}$$ 


$$\mu_{B} = \frac {\mu * bias\\_axis}{||bias\\_axis||_2} + ||bias\\_axis||_2 *bias\\_axis$$ 

$$\mu_{\perp} = \mu - \mu_{B}$$


$$e_{w1B} = \sqrt{ |{1 - ||\mu_{\perp} ||^2_2} |} * \frac{(e_{\text{w1}} - \mu_{\perp}) - \mu_B} {|(e_{w1} - \mu_{\perp}) - \mu_B)|}$$

$$e_{w2B} = \sqrt{ |{1 - ||\mu_{\perp} ||^2_2} |} * \frac{(e_{\text{w2}} - \mu_{\perp}) - \mu_B} {|(e_{w2} - \mu_{\perp}) - \mu_B)|}$$

$$e_1 = e_{w1B} + \mu_{\perp}$$

$$e_2 = e_{w2B} + \mu_{\perp}$$

# Week3
## Sequence to sequecne model
**Seq2Seq（Sequence-to-Sequence）** 模型能够应用于机器翻译、语音识别等各种序列到序列的转换问题。

一个 Seq2Seq 模型包含**编码器（Encoder）**和**解码器（Decoder）**两部分，它们通常是两个不同的 RNN, 将编码器的输出作为解码器的输入，由解码器负责输出正确的翻译结果。

![Seq2Seq](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Seq2Seq.png)

这种编码器-解码器的结构也可以用于图像描述（Image captioning）。将 AlexNet 作为编码器，最后一层的 Softmax 换成一个 RNN 作为解码器，网络的输出序列就是对图像的一个描述。

## Picking the most likely sentence
机器翻译用到的模型与语言模型相似，只是用编码器的输出作为解码器第一个时间步的输入（而非 0）。因此机器翻译的过程相当于建立一个条件语言模型。

由于解码器进行随机采样过程，输出的翻译结果可能有好有坏。

需要找到能使条件概率最大化的翻译，即

$$arg \ max_{y^{⟨1⟩}, ..., y^{⟨T_y⟩}}P(y^{⟨1⟩}, ..., y^{⟨T_y⟩} | x)$$

贪心搜索算法得到的结果通常不好。

### Beam Search
**集束搜索（Beam Search）** 会考虑每个时间步多个可能的选择。设定一个超参数 **集束宽（Beam Width）** $B$，代表了解码器中每个时间步的预选单词数量。


![Beam-search](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Beam-search.png)

e.g. $B=3$，则将第一个时间步最可能的三个预选单词及其概率值 $P(\hat y^{⟨1⟩}|x)$ 保存到计算机内存，以待后续使用。

第二步中，分别将三个预选词作为第二个时间步的输入，得到 $P(\hat y^{⟨2⟩}|x, \hat y^{⟨1⟩})$。

因为我们需要的其实是第一个和第二个单词对（而非只有第二个单词）有着最大概率，因此根据条件概率公式，有：

$$P(\hat y^{⟨1⟩}, \hat y^{⟨2⟩}|x) = P(\hat y^{⟨1⟩}|x) P(\hat y^{⟨2⟩}|x, \hat y^{⟨1⟩})$$

设词典中有 $N$ 个词，则当 $B=3$ 时，有 $3*N$ 个 $P(\hat y^{⟨1⟩}, \hat y^{⟨2⟩}|x)$。仍然取其中概率值最大的 3 个，作为对应第一个词条件下的第二个词的预选词。

以此类推，最后输出一个最优的结果，即结果符合公式：

$$arg \ max \prod^{T_y}_{t=1} P(\hat y^{⟨t⟩} | x, \hat y^{⟨1⟩}, ..., \hat y^{⟨t-1⟩})$$

当 $B=1$ 时，集束搜索就变为贪心搜索。

#### Refinements to Beam Search 
**长度标准化（Length Normalization）** 是对集束搜索算法的优化方式。对于公式

$$arg \ max \prod^{T_y}_{t=1} P(\hat y^{⟨t⟩} | x, \hat y^{⟨1⟩}, ..., \hat y^{⟨t-1⟩})$$

当多个小于 1 的概率值相乘后，会造成**数值下溢（Numerical Underflow）**，即得到的结果将会是一个电脑不能精确表示的极小浮点数。

因此，我们会取 $log$ 值，并进行标准化：

$$arg \ max \frac{1}{T_y^{\alpha}} \sum^{T_y}\_{t=1} logP(\hat y^{⟨t⟩} | x, \hat y^{⟨1⟩}, ..., \hat y^{⟨t-1⟩})$$

其中，$T_y$ 是翻译结果的单词数量，$\alpha$ 是一个需要根据实际情况进行调节的 **超参数** 。标准化用于减少对输出长的结果的惩罚（因为翻译结果一般没有长度限制）。

关于集束宽 $B$ 的取值，较大的 $B$ 值意味着可能更好的结果和巨大的计算成本；而较小的 $B$ 值代表较小的计算成本和可能表现较差的结果。通常来说，$B$ 可以取一个 10 以下的值。

和 BFS、DFS 等精确的查找算法相比，集束搜索算法运行速度更快，但是不能保证一定找到 $arg \ max$ 准确的最大值。

### Error analysis
集束搜索是一种启发式搜索算法，其输出结果不总为最优。

当结合 Seq2Seq 模型和集束搜索算法所构建的系统出错（没有输出最佳翻译结果）时，我们通过误差分析来分析错误出现在 RNN 模型还是集束搜索算法中。

e.g. 对于下述两个由人工和算法得到的翻译结果：

$$Human:\ Jane\ visits\ Africa\ in\ September.\ (y^*)$$

$$Algorithm:\ Jane\ visited\ Africa\ last\ September.\ (y^*)$$

将翻译中没有太大差别的前三个单词作为解码器前三个时间步的输入，得到第四个时间步的条件概率 $P(y^* | x)$ 和 $P(\hat y | x)$，比较其大小并分析：

* 如果 $P(y^* | x) > P(\hat y | x)$，说明是集束搜索算法出现错误，没有选择到概率最大的词；
* 如果 $P(y^* | x) \le P(\hat y | x)$，说明是 RNN 模型的效果不佳，预测的第四个词为“in”的概率小于“last”。

建立一个如下图所示的表格，记录对每一个错误的分析，有助于判断错误出现在 RNN 模型还是集束搜索算法中。

如果错误出现在集束搜索算法中，可以考虑增大集束宽 $B$；否则，需要进一步分析，看是需要正则化、更多数据或是尝试一个不同的网络结构。

![Error-analysis-process](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Error-analysis-process.png)

## Bleu score

**Bleu（Bilingual Evaluation Understudy）得分** 用于评估机器翻译的质量，其思想是机器翻译的结果越接近于人工翻译，则评分越高。

![Bleu-score-on-unigram](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Bleu-score-on-unigram.png)

上述方法是以单个词为单位进行统计，以单个词为单位的集合称为**unigram（一元组）**。而以成对的词为单位的集合称为**bigram（二元组）**。对每个二元组，可以统计其在机器翻译结果（$count$）和人工翻译结果（$count\_{clip}$）出现的次数，计算 Bleu 得分。

以此类推，以 n 个单词为单位的集合称为**n-gram（多元组）**，对应的 Blue（即翻译精确度）得分计算公式为：

$$p_n = \frac{\sum_{\text{n-gram} \in \hat y}count\_{clip}(\text{n-gram})}{\sum_{\text{n-gram} \in \hat y}count(\text{n-gram})}$$

对 N 个 $p_n$ 进行几何加权平均得到：

$$p_{ave} = exp(\frac{1}{N}\sum^N_{i=1}log^{p_n})$$

problem: 当机器翻译结果短于人工翻译结果时，比较容易能得到更大的精确度分值，因为输出的大部分词可能都出现在人工翻译结果中。

改进的方法是设置一个**最佳匹配长度（Best Match Length）** ，如果机器翻译的结果短于该最佳匹配长度，则需要接受 **简短惩罚（Brevity Penalty，BP）** ：

$$
BP = 
\begin{cases} 
1, &MT\_length \ge BM\_length \\\
exp(1 - \frac{MT\_length}{BM\_length}), &MT\_length \lt BM\_length 
\end{cases}
$$

因此，最后得到的 Bleu 得分为：

$$Blue = BP \times exp(\frac{1}{N}\sum^N_{i=1}log^{p_n})$$

Bleu 得分的贡献是提出了一个表现不错的**单一实数评估指标**

## Attention Model intuition
对于一大段文字，人工翻译一般每次阅读并翻译一小部分。因为难以记忆，很难每次将一大段文字一口气翻译完, 同理，用 Seq2Seq 模型建立的翻译系统，对于长句子，Blue 得分会随着输入序列长度的增加而降低。

实际上，我们也并不希望神经网络每次去“记忆”很长一段文字，而是想让它像人工翻译一样工作。因此， **注意力模型（Attention Model）** 被提出。

![Attention-Model](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Attention-Model.png)

注意力模型的一个示例网络结构如上图所示。其中，底层是一个双向循环神经网络（BRNN），该网络中每个时间步的激活都包含前向传播和反向传播产生的激活：

$$a^{\langle t’ \rangle} = ({\overrightarrow a}^{\langle t’ \rangle}, {\overleftarrow a}^{\langle t’ \rangle})$$

顶层是一个“多对多”结构的循环神经网络，第 $t$ 个时间步的输入包含该网络中前一个时间步的激活 $s^{\langle t-1 \rangle}$、输出 $y^{\langle t-1 \rangle}$ 以及底层的 BRNN 中多个时间步的激活 $c$，其中 $c$ 有（注意分辨 $\alpha$ 和 $a$）：

$$c^{\langle t \rangle} = \sum\_{t’}\alpha^{\langle t,t’ \rangle}a^{\langle t’ \rangle}$$

其中，参数 $\alpha^{\langle t,t’ \rangle}$ 即代表着 $y^{\langle t \rangle}$ 对 $a^{\langle t' \rangle}$ 的“注意力”，总有：

$$\sum_{t’}\alpha^{\langle t,t’ \rangle} = 1$$

我们使用 Softmax 来确保上式成立，因此有：

$$\alpha^{\langle t,t’ \rangle} = \frac{exp(e^{\langle t,t’ \rangle})}{\sum^{T_x}_{t'=1}exp(e^{\langle t,t’ \rangle})}$$

而对于 $e^{\langle t,t’ \rangle}$，我们通过神经网络学习得到。输入为 $s^{\langle t-1 \rangle}$ 和 $a^{\langle t’ \rangle}$，如下图所示：

![Computing-attention](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Computing-attention.png)

注意力模型的一个缺点是时间复杂度为 $O(n^3)$。

## Speech recognition
在语音识别任务中，输入是一段以时间为横轴的音频片段，输出是文本。

以前的语音识别系统通过语言学家人工设计的**音素（Phonemes）**来构建，音素指的是一种语言中能区别两个词的最小语音单位。

在现在的端到端系统中，用深度学习就可以实现输入音频，直接输出文本。

语音识别系统可以用注意力模型来构建，一个简单的图例如下：

![Attention-model-for-speech-recognition](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Attention-model-for-speech-recognition.png)

用 **CTC（Connectionist Temporal Classification）**损失函数来做语音识别的效果也不错。由于输入是音频数据，使用 RNN 所建立的系统含有很多个时间步，且输出数量往往小于输入。

因此，不是每一个时间步都有对应的输出。CTC 允许 RNN 生成下图红字所示的输出，并将两个空白符（blank）中重复的字符折叠起来，再将空白符去掉，得到最终的输出文本。

![CTC-for-speech-recognition](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/CTC-for-speech-recognition.png)

## Trigger Word Detection
**触发词检测（Trigger Word Detection）** 常用于各种智能设备，通过约定的触发词可以语音唤醒设备。

使用 RNN 来实现触发词检测时，可以将触发词对应的序列的标签设置为“1”，而将其他的标签设置为“0”。

![Trigger-word-detection-algorithm](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Sequence_Models/Trigger-word-detection-algorithm.png)
