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
