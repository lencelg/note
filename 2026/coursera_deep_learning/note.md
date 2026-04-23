---
author: lencelg from Arcadia Bay
title: coursera deep learning note
---
this note is made from coursera deep learning course, good reference note: [bighuang624/Andrew-Ng-Deep-Learning-notes](https://kyonhuang.top/Andrew-Ng-Deep-Learning-notes/#/)

[TOC]

# Week1
## Introduction
Courses view:
1. **Neural Networks and Deep Learning**
2. **Improving Deep Neural Networks**: Hyperparameter tuning, Regularization and Optimization
3. **Structuring your Machine Learning project**
4. **Convolutional Neural Networks**
5. **Natural Language Processing**: Building sequence models

Nerual newwork example
- standrad NN
- Convolutional NN
- Recurrent NN

Data
- Structured data
- Unstructured data

# Week2
## Neural Network Basis
二分类

Sigmoid 函数：$$s = \sigma(w^Tx+b) = \sigma(z) = \frac{1}{1+e^{-z}}$$

**损失函数(loss function)** 用于衡量预测结果与真实值之间的误差。

最简单的损失函数定义方式为平方差损失：$$L(\hat{y},y) = \frac{1}{2}(\hat{y}-y)^2$$

但 Logistic 回归中我们并不倾向于使用这样的损失函数，因为之后讨论的优化问题会变成非凸的，最后会得到很多个局部最优解，梯度下降法可能找不到全局最优值。

一般使用$$L(\hat{y},y) = -(y\log\hat{y})-(1-y)\log(1-\hat{y})$$

损失函数是在单个训练样本中定义的，它衡量了在**单个**训练样本上的表现。而**代价函数(cost function，或者称作成本函数)**衡量的是在**全体**训练样本上的表现，即衡量参数 w 和 b 的效果。

$$J(w,b) = \frac{1}{m}\sum_{i=1}^mL(\hat{y}^{(i)},y^{(i)})$$

## Gradient Descent
$\alpha$ is the learning rate, gradient descent computer the derivative

repeat {
$$w := w - \alpha\frac{dJ(w, b)}{dw}$$

$$b := w - \alpha\frac{dJ(w, b)}{db}$$
} until some conditions(convergence or enough steps)

## Logistic Regression gradient descent
利用 **反向传播**

假设输入的特征向量维度为 2，即输入参数共有 x1, w1, x2, w2, b 这五个。可以推导出如下的计算图：

![Logistic-Computation-Graph](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Neural_Networks_and_Deep_Learning/Logistic-Computation-Graph.png)

首先反向求出 L 对于 a 的导数：

$$\frac{dL(a,y)}{da}=−\frac{y}{a}+\frac{1−y}{1−a}$$

然后继续反向求出 L 对于 z 的导数：

$$\frac{dL}{dz}=\frac{dL(a,y)}{dz}=\frac{dL}{da}\frac{da}{dz}=a−y$$

于是可以计算:

$$ \frac{dL}{dw_1}=\frac{dL}{dz} \frac{dz}{dw_1} = (a - y) \times x_1 $$
$$ \frac{dL}{dw_2}=\frac{dL}{dz} \frac{dz}{dw_2} = (a - y) \times x_2 $$
$$ \frac{dL}{db}=\frac{dL}{dz} \frac{dz}{db} = (a - y) $$

依此类推求出最终的损失函数相较于原始参数的导数之后，根据如下公式进行参数更新：

$$w _1:=w _1−\alpha \frac{dL}{dw_1}$$
$$w _2:=w _1−\alpha \frac{dL}{dw_2}$$
$$b:=b−\alpha \frac{dL}{db}$$

接下来我们需要将对于单个用例的损失函数扩展到整个训练集的代价函数：

$$J(w,b)=\frac{1}{m}\sum^m_{i=1}L(a^{(i)},y^{(i)})$$ 

$$a^{(i)}=\hat{y}^{(i)}=\sigma(z^{(i)})=\sigma(w^Tx^{(i)}+b)$$

我们可以对于某个权重参数 w1，其导数计算为：

$$\frac{\partial J(w,b)}{\partial{w\_1}}=\frac{1}{m}\sum^m_{i=1}\frac{\partial L(a^{(i)},y^{(i)})}{\partial{w\_1}}$$

## 广播（broadcasting）

Numpy 的 Universal functions 中要求输入的数组 shape 是一致的。当数组的 shape 不相等的时候，则会使用广播机制，调整数组使得 shape 一样，满足规则，则可以运算，否则就出错。

四条规则：

1. 让所有输入数组都向其中 shape 最长的数组看齐，shape 中不足的部分都通过在前面加 1 补齐；
2. 输出数组的 shape 是输入数组 shape 的各个轴上的最大值；
3. 如果输入数组的某个轴和输出数组的对应轴的长度相同或者其长度为 1 时，这个数组能够用来计算，否则出错；
4. 当输入数组的某个轴的长度为 1 时，沿着此轴运算时都用此轴上的第一组值。

# Week3
## Neural Network representation
* input layer
* hidden layer
* output layer

实际上，神经网络只不过将 Logistic 回归的计算步骤重复很多次。

remember to use vectorlization code

## Activation functions
* sigmoid $$ a = \frac{1}{1 + e^{-z}}$$
* tanh (the hyperbolic tangent function，双曲正切函数) $$a = \frac{e^z - e^{-z}}{e^z + e^{-z}}$$
* relu (the rectified linear unit，修正线性单元): $$a=max(0,z)$$
* leaky relu (带泄漏的 ReLU): $$a=max(0.01z,z)$$

graph look like following

![](./img/activation%20function)

## Reasons to use non-linear activation function
在 **隐藏层** 使用线性激活函数和不使用激活函数, 和直接使用 Logistic 回归没有区别，那么无论神经网络有多少层，输出都是输入的 **线性组合** ，与没有隐藏层效果相当，就成了最原始的 **感知器** 了

## Derivative of activation function
* sigmoid 函数：

$$g(z) = \frac{1}{1+e^{-z}}$$

$$g\prime(z)=\frac{dg(z)}{dz} = \frac{1}{1+e^{-z}}(1-\frac{1}{1+e^{-z}})=g(z)(1-g(z))$$

* tanh 函数：

$$g(z) = tanh(z) = \frac{e^z - e^{-z}}{e^z + e^{-z}}$$

$$g\prime(z)=\frac{dg(z)}{dz} = 1-(tanh(z))^2=1-(g(z))^2$$

## Gradient Descent
### forward propagation
just run the computation

$$Z^{[1]}={(W^{[1]})}^TX+b^{[1]}$$

$$A^{[1]}=g^{[1]}(Z^{[1]})$$

$$Z^{[2]}={(W^{[2]})}^TA^{[1]}+b^{[2]}$$

$$A^{[2]}=g^{[2]}(Z^{[2]})=\sigma(Z^{[2]})$$

### backward propagation
神经网络反向梯度下降公式（左）和其代码向量化（右）：

![summary-of-gradient-descent](https://raw.githubusercontent.com/bighuang624/Andrew-Ng-Deep-Learning-notes/master/docs/Neural_Networks_and_Deep_Learning/summary-of-gradient-descent.png)

## Random initialization
如果在初始时将两个隐藏神经元的参数设置为相同的大小，那么两个隐藏神经元对输出单元的影响也是相同的，通过反向梯度下降去进行计算的时候，会得到同样的梯度大小，所以在经过多次迭代后，两个隐藏层单位仍然是对称的。无论设置多少个隐藏单元，其最终的影响都是相同的，那么多个隐藏神经元就没有了意义。

在初始化的时候，W 参数要进行随机初始化，不可以设置为 0。而 b 因为不存在对称性的问题，可以设置为 0。


以 2 个输入，2 个隐藏神经元为例：

```py
W = np.random.rand(2,2)* 0.01
b = np.zeros((2,1))
```

这里将 W 的值乘以 0.01（或者其他的常数值）的原因是为了使得权重 W 初始化为较小的值，这是因为使用 sigmoid 函数或者 tanh 函数作为激活函数时，W 比较小，则 Z=WX+b 所得的值趋近于 0，梯度较大，能够提高算法的更新速度。而如果 W 设置的太大的话，得到的梯度较小，训练过程因此会变得很慢。

ReLU 和 Leaky ReLU 作为激活函数时不存在这种问题，因为在大于 0 的时候，梯度均为 1。