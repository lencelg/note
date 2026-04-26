---
author: lencelg from Arcadia Bay
title: Convolutional neural networks
---
this note is made from coursera deep learning course, good reference note: [bighuang624/Andrew-Ng-Deep-Learning-notes](https://kyonhuang.top/Andrew-Ng-Deep-Learning-notes/#/)

[TOC]

# Week1
## Computer vision introduction
computer problems
* Image classification : 图片分类
* Object detection : 目标检测
* Neural Style Transfer : 神经风格转换

the challenge is the input image is very large, one solution is to use **Convolutional neural netorwk** (CNN)

## Edge detection
**Convolutional Operation** is the basis of component of convolutional neural network

two mainly type of edge detection
* Vertical edges
* Horizontal edges

a dynamic example of convolutional operation as follow: 

![](./img/Convolutional-operation.jpg)

卷积操作的 API：
* 在 Python 中，卷积用`conv_forward()`表示；
* 在 Tensorflow 中，卷积用`tf.nn.conv2d()`表示；
* 在 keras 中，卷积用`Conv2D()`表示。

### filter
typical filter
- Sobel filter
- Scharr filter

![](./img/Sobel-Filter-and-Scharr-Filter.png)

滤波器中的值还可以设置为 **参数** ，通过模型训练来得到。这样，神经网络使用反向传播算法可以学习到一些低级特征，从而实现对图片所有边缘特征的检测, 这是一个很强大的想法

### padding
假设输入图片的大小为 $n \times n$，而滤波器的大小为 $f \times f$，则卷积后的输出图片大小为 $(n-f+1) \times (n-f+1)$。

the problem without padding
* shrinking output
* throw away info from edge of input

use padding to pad zeros to extend the original image

设每个方向扩展像素点数量为 $p$，则填充后原始图片的大小为 $(n+2p) \times (n+2p)$，滤波器大小保持 $f \times f$不变，则输出图片大小为 $(n+2p-f+1) \times (n+2p-f+1)$。

typical convolution
- Valid convolution: no padding, output size is $(n-f+1) \times (n-f+1)$;
- Same convolution: padding to make the output size to be the same as input size,  $p = \frac{f-1}{2}$ .

在计算机视觉领域，$f$通常为奇数。原因包括 Same 卷积中 $p = \frac{f-1}{2}$能得到自然数结果，并且滤波器有一个便于表示其所在位置的中心点。

### strided convolutions
设置**步长（Stride）** 来压缩一部分信息

![](./img/Stride.jpg)

设步长为 $s$，填充长度为 $p$，输入图片大小为 $n \times n$，滤波器大小为 $f \times f$，则卷积后图片的尺寸为：

$$\biggl\lfloor \frac{n+2p-f}{s}+1   \biggr\rfloor \times \biggl\lfloor \frac{n+2p-f}{s}+1 \biggr\rfloor$$

目前为止我们学习的“卷积”实际上被称为**互相关（cross-correlation）**，而非数学意义上的卷积。真正的卷积操作在做元素乘积求和之前，要将滤波器沿水平和垂直轴翻转（相当于旋转 180 度）。因为这种翻转对一般为水平或垂直对称的滤波器影响不大，按照机器学习的惯例，我们通常不进行翻转操作，在简化代码的同时使神经网络能够正常工作。

## Convolution over volumes
三维卷积的图示如下

![](./img/Convolutions-on-RGB-image.png)

如果想同时检测垂直和水平边缘，或者更多的边缘检测，可以增加更多的滤波器组。例如设置第一个滤波器组实现垂直边缘检测，第二个滤波器组实现水平边缘检测。设输入图片的尺寸为 $n \times n \times n\_c$（$n\_c$为通道数），滤波器尺寸为 $f \times f \times n_c$，则卷积后的输出图片尺寸为 $(n-f+1) \times (n-f+1) \times n'_c$，$n'_c$为滤波器组的个数。

![](./img/More-Filters.jpg)

对于一个 3x3x3 的滤波器，包括偏移量 $b$在内共有 28 个参数。不论输入的图片有多大，用这一个滤波器来提取特征时，参数始终都是 28 个，固定不变。即**选定滤波器组后，参数的数目与输入图片的尺寸无关**

因此，卷积神经网络的参数相较于标准神经网络来说要少得多。这是 CNN 的优点之一。

## Notation
设 $l$ 层为卷积层：

* $f^{[l]}$：**滤波器的高（或宽）**
* $p^{[l]}$：**填充长度**
* $s^{[l]}$：**步长**
* $n^{[l]}_c$：**滤波器组的数量**

* **输入维度**：$n^{[l-1]}_H \times n^{[l-1]}_W \times n^{[l-1]}_c$ 。其中 $n^{[l-1]}_H$表示输入图片的高，$n^{[l-1]}_W$表示输入图片的宽。之前的示例中输入图片的高和宽都相同，但是实际中也可能不同，因此加上下标予以区分。

* **输出维度**：$n^{[l]}_H \times n^{[l]}_W \times n^{[l]}_c$ 。其中

$$n^{[l]}_H = \biggl\lfloor \frac{n^{[l-1]}_H+2p^{[l]}-f^{[l]}}{s^{[l]}}+1   \biggr\rfloor$$

$$n^{[l]}_W = \biggl\lfloor \frac{n^{[l-1]}_W+2p^{[l]}-f^{[l]}}{s^{[l]}}+1   \biggr\rfloor$$

* **每个滤波器组的维度**：$f^{[l]} \times f^{[l]} \times n^{[l-1]}_c$ 。其中$n^{[l-1]}_c$ 为输入图片通道数（也称深度）。
* **权重维度**：$f^{[l]} \times f^{[l]} \times n^{[l-1]}_c \times n^{[l]}_c$
* **偏置维度**：$1 \times 1 \times 1 \times n^{[l]}_c$

## Convolutional neural netowrk architecture
随着神经网络计算深度不断加深，图片的高度和宽度 $n^{[l]}_H $、$n^{[l]}_W$一般逐渐减小，而 $n^{[l]}_c$在增加。

a typical convolutional neural network contains three parts
- Convolution layer : 卷积层
- Pooling layer : 池化层
- Fully Connected layer : 全连接层

## Pooling layer
**池化层** 的作用是缩减模型的大小，提高计算速度，同时减小噪声提高所提取特征的稳健性。

max pooling

![](./img/Max-Pooling.png)

avarage pooling

![](./img/Average-Pooling.png)

Hyperparameters
- f: filter size
- s: stride
- Max or avarage pooling

input dimensions:

$$n_H \times n_W \times n_c$$

output dimensions：

$$\biggl\lfloor \frac{n_H-f}{s}+1   \biggr\rfloor \times \biggl\lfloor \frac{n_W-f}{s}+1   \biggr\rfloor \times n_c$$

## Convolutional neural network example
![](./img/CNN-Example.jpg)

FC3 和 FC4 为全连接层，与标准的神经网络结构一致.

|| Activation shape | Activation Size | #parameters|
|:--- | :--- | :--- | :--- |
|**Input:** | (32, 32, 3) | 3072 | 0
|**CONV1(f=5, s=1)** | (28, 28, 6) | 4704 | 158
|**POOL1** | (14, 14, 6) | 1176 | 0
|**CONV2(f=5, s=1)** | (10, 10, 16) | 1600 | 416
|**POOL2** | (5, 5, 16) | 400 | 0
|**FC3** | (120, 1) | 120 | 48120
|**FC4** | (84, 1) | 84 | 10164
|**Softmax** | (10, 1) | 10 | 850

## CNN advantages

相比标准神经网络，对于大量的输入数据，卷积过程有效地减少了 CNN 的参数数量，原因有以下两点：

* **参数共享（Parameter sharing）** ：特征检测如果适用于图片的某个区域，那么它也可能适用于图片的其他区域。即在卷积过程中，不管输入有多大，一个特征探测器（滤波器）就能对整个输入的某一特征进行探测。
* **稀疏连接（Sparsity of connections）** ：在每一层中，由于滤波器的尺寸限制，输入和输出之间的连接是稀疏的，每个输出值只取决于输入在局部的一小部分值。

池化过程则在卷积后很好地聚合了特征，通过降维来减少运算量。

由于 CNN 参数数量较小，所需的训练样本就相对较少，因此在一定程度上不容易发生过拟合现象。并且 CNN 比较擅长捕捉区域位置偏移。即进行物体检测时，不太受物体在图片中位置的影响，增加检测的准确性和系统的健壮性。