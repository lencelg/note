---
author: lencelg from Arcadia Bay
title: coursera deep learning note
---
this note is made from coursera deep learning course, good reference note: [bighuang624/Andrew-Ng-Deep-Learning-notes](https://kyonhuang.top/Andrew-Ng-Deep-Learning-notes/#/)

[TOC]

# Week1
## cross validation
交叉验证的基本思想是重复地使用数据；把给定的数据进行切分，将切分的数据集组合为训练集与测试集，在此基础上反复地进行训练、测试以及模型选择。

## bias and variance
* **偏差**：度量了学习算法的期望预测与真实结果的偏离程度，即刻画了**学习算法本身的拟合能力**；
* **方差**：度量了同样大小的训练集的变动所导致的学习性能的变化，即刻画了**数据扰动所造成的影响**；
* **噪声**：表达了在当前任务上任何学习算法所能够达到的期望泛化误差的下界，即刻画了**学习问题本身的难度**。

存在高偏差：

* 扩大网络规模，如添加隐藏层或隐藏单元数目；
* 寻找合适的网络架构，使用更大的 NN 结构；
* 花费更长时间训练。

存在高方差：

* 获取更多的数据；
* 正则化（regularization）；
* 寻找更合适的网络结构。

## regularization

**正则化**是在成本函数中加入一个正则化项，惩罚模型的复杂度。正则化可以用于解决高方差的问题。

## Logistic regularization
$$J(w,b) = \frac{1}{m}\sum_{i=1}^mL(\hat{y}^{(i)},y^{(i)})+\frac{\lambda}{2m}{||w||}^2_2$$

* L2 正则化：$$\frac{\lambda}{2m}{||w||}^2_2 = \frac{\lambda}{2m}\sum_{j=1}^{n\_x}w^2_j = \frac{\lambda}{2m}w^Tw$$
* L1 正则化：$$\frac{\lambda}{2m}{||w||}_1 = \frac{\lambda}{2m}\sum_{j=1}^{n\_x}{|w\_j|}$$

其中，λ 为**正则化因子**，是**超参数**。

由于 L1 正则化最后得到 w 向量中将存在大量的 0，使模型变得稀疏化，因此 L2 正则化更加常用。

## regularization in neural network
对于神经网络，加入正则化的成本函数：

$$J(w^{[1]}, b^{[1]}, ..., w^{[L]}, b^{[L]}) = \frac{1}{m}\sum\_{i=1}^mL(\hat{y}^{(i)},y^{(i)})+\frac{\lambda}{2m}\sum\_{l=1}^L{{||w^{[l]}||}}^2\_F$$

因为 w 的大小为 ($n^{[l−1]}$, $n^{[l]}$)，因此

$${{||w^{[l]}||}}^2\_F = \sum^{n^{[l-1]}}\_{i=1}\sum^{n^{[l]}}\_{j=1}(w^{[l]}\_{ij})^2$$

该矩阵范数被称为**弗罗贝尼乌斯范数（Frobenius Norm）**，所以神经网络中的正则化项被称为弗罗贝尼乌斯范数矩阵。

## Dropout regularization
**dropout（随机失活）**是在神经网络的隐藏层为每个神经元结点设置一个随机消除的概率，保留下来的神经元形成一个结点较少、规模较小的网络用于训练。dropout 正则化较多地被使用在**计算机视觉（Computer Vision）**领域。

## Inverted dropout
Inverted dropout is an implementation of Dropout reglarization

```py
keep_prob = 0.8    # 设置神经元保留概率
dl = np.random.rand(al.shape[0], al.shape[1]) < keep_prob
al = np.multiply(al, dl)
al /= keep_prob
```

最后一步`al /= keep_prob`是因为 $a^{[l]}$中的一部分元素失活（相当于被归零），为了在下一层计算时不影响 $Z^{[l+1]} = W^{[l+1]}a^{[l]} + b^{[l+1]}$的期望值，因此除以一个`keep_prob`。

**注意**，在**测试阶段不要使用 dropout**，因为那样会使得预测结果变得随机。

## Dropout understanding
对于单个神经元，其工作是接收输入并产生一些有意义的输出。但是加入了 dropout 后，输入的特征都存在被随机清除的可能，所以该神经元不会再特别依赖于任何一个输入特征，即不会给任何一个输入特征设置太大的权重。

因此，通过传播过程，dropout 将产生和 L2 正则化相同的**收缩权重**的效果。

对于不同的层，设置的`keep_prob`也不同。一般来说，神经元较少的层，会设`keep_prob`为 1.0，而神经元多的层则会设置比较小的`keep_prob`。

dropout 的一大**缺点**是成本函数无法被明确定义。因为每次迭代都会随机消除一些神经元结点的影响，因此无法确保成本函数单调递减。因此，使用 dropout 时，先将`keep_prob`全部设置为 1.0 后运行代码，确保 $J(w, b)$函数单调递减，再打开 dropout。

## Other regularization
* 数据扩增（Data Augmentation）：通过图片的一些变换（翻转，局部放大后切割等），得到更多的训练集和验证集。
* 早停止法（Early Stopping）：将训练集和验证集进行梯度下降时的成本变化曲线画在同一个坐标轴内，当训练集误差降低但验证集误差升高，两者开始发生较大偏差时及时停止迭代，并返回具有最小验证集误差的连接权和阈值，以避免过拟合。这种方法的缺点是无法同时达成偏差和方差的最优。

## Normalize input
$$x = \frac{x - \mu}{\sigma}$$

其中，

$$\mu = \frac{1}{m}\sum^m_{i=1}x^{(i)}$$

$$\sigma = \sqrt{\frac{1}{m}\sum^m_{i=1}x^{{(i)}^2}}$$

使用标准化前后，成本函数的形状有较大差别, 能够减少迭代的次数。

## Vanishing/exploding gradients
在梯度函数上出现的以指数级递增或者递减的情况分别称为**梯度爆炸**或者**梯度消失**, 这是训练深层神经网络的一个障碍.

假定 $g(z) = z, b^{[l]} = 0$，对于目标输出有：

$$\hat{y} = W^{[L]}W^{[L-1]}...W^{[2]}W^{[1]}X$$

* 对于 $W^{[l]}$的值大于 1 的情况，激活函数的值将以指数级递增；
* 对于 $W^{[l]}$的值小于 1 的情况，激活函数的值将以指数级递减。

对于导数同理。因此，在计算梯度时，根据不同情况梯度函数会以指数级递增或递减，导致训练导数难度上升，梯度下降算法的步长会变得非常小，需要训练的时间将会非常长。

### careful random initlization
a partial solution to vanishing/exploding gradients

根据

$$z={w}_1{x}\_1+{w}\_2{x}\_2 + ... + {w}\_n{x}\_n + b$$

可知，当输入的数量 n 较大时，我们希望每个 wi 的值都小一些，这样它们的和得到的 z 也较小。

为了得到较小的 wi，设置`Var(wi)=1/n`，这里称为 **Xavier initialization**。

```py
WL = np.random.randn(WL.shape[0], WL.shape[1]) * np.sqrt(1/n)
```

其中 n 是输入的神经元个数，即`WL.shape[1]`。

这样，激活函数的输入 x 近似设置成均值为 0，标准方差为 1，神经元输出 z 的方差就正则化到 1 了。虽然没有解决梯度消失和爆炸的问题，但其在一定程度上确实减缓了梯度消失和爆炸的速度。

同理，也有 **He Initialization**。它和  Xavier initialization 唯一的区别是`Var(wi)=2/n`，适用于 **ReLU** 作为激活函数时。

当激活函数使用 ReLU 时，`Var(wi)=2/n`；当激活函数使用 tanh 时，`Var(wi)=1/n`。

## Gradient checking 
use gradient checking to check wheather the implementation of backward propagation is correct

使用双边误差的方法去逼近导数，精度要高于单边误差。

$$f'(\theta) = {\lim_{\varepsilon\to 0}} = \frac{f(\theta + \varepsilon) - (\theta - \varepsilon)}{2\varepsilon}$$

将 $W^{[1]}$，$b^{[1]}$，...，$W^{[L]}$，$b^{[L]}$全部连接出来，成为一个巨型向量 θ。这样，

$$J(W^{[1]}, b^{[1]}, ..., W^{[L]}，b^{[L]}) = J(\theta)$$

同时，对 $dW^{[1]}$，$db^{[1]}$，...，$dW^{[L]}$，$db^{[L]}$执行同样的操作得到巨型向量 dθ，它和 θ 有同样的维度。

$$J(dW^{[1]}, db^{[1]}, ..., dW^{[L]}，db^{[L]}) = J(\theta)$$

求得一个梯度逼近值

$$d\theta_{approx}[i] ＝ \frac{J(\theta_1, \theta_2, ..., \theta_i+\varepsilon, ...) - J(\theta_1, \theta_2, ..., \theta_i-\varepsilon, ...)}{2\varepsilon}$$

应该

$$\approx{d\theta[i]} = \frac{\partial J}{\partial \theta_i}$$

因此，我们用梯度检验值是否小于某个阈值，一般是 $10^{-7}$

$$\frac{{||d\theta_{approx} - d\theta||}_2}{{||d\theta_{approx}||}_2+{||d\theta||}_2}$$

检验反向传播的实施是否正确。其中，

$${||x||}_2 = \sum^N_{i=1}{|x_i|}^2$$

表示向量 x 的 2-范数（也称“欧几里德范数”）。

如果梯度检验值和 ε 的值相近，说明神经网络的实施是正确的，否则要去检查代码是否存在 bug。

## Gradient checking implementation notes
- Don’t use in training – only to debug
- If algorithm fails grad check, look at components to try to identify bug.
- Remember regularization.
- Doesn’t work with dropout.
- Run at random initialization; perhaps again after some training.