#import "@preview/ori:0.2.5": *
#set heading(numbering: numbly("{1:一}、", default: "1.1  "))
// #set math.equation(numbering: "(1)")

#show: ori.with(
  title: "d2l book note",
  author: "lencelg from Arcadia Bay",
  semester: "2026 summer",
  date: datetime.today(),
  maketitle: true,
)

#outline()

#set text(size: 10pt)
#show raw: set text(font: "Hack Nerd Font")

#pagebreak()

= Introduction
介绍了ml的大致内容，不多赘述。

= Preliminary knowledge

== data operation

=== cat
可以通过 `cat` 来拼接 `tensor`，`dim=0` 意味着 _行（纵向）拼接_，`dim=1` 意味着 _列（横向）拼接_。

```python
X = torch.arange(12, dtype=torch.float32).reshape((3,4))
Y = torch.tensor([[2.0, 1, 4, 3], [1, 2, 3, 4], [4, 3, 2, 1]])
torch.cat((X, Y), dim=0), torch.cat((X, Y), dim=1)
```

res as follow

```console
(tensor([[ 0.,  1.,  2.,  3.],
         [ 4.,  5.,  6.,  7.],
         [ 8.,  9., 10., 11.],
         [ 2.,  1.,  4.,  3.],
         [ 1.,  2.,  3.,  4.],
         [ 4.,  3.,  2.,  1.]]),
 tensor([[ 0.,  1.,  2.,  3.,  2.,  1.,  4.,  3.],
         [ 4.,  5.,  6.,  7.,  1.,  2.,  3.,  4.],
         [ 8.,  9., 10., 11.,  4.,  3.,  2.,  1.]]))
```

=== Broadcasting Mechanism

_广播机制_（Broadcasting Mechanism）。当两个张量形状不同时，广播机制通过以下两步实现按元素操作：

PyTorch 广播的核心机制是通过将“1”维度的步长设为 0 实现虚拟扩展（零拷贝），_并在反向传播时通过求和规约叠加梯度_

1. _扩展_：将其中一个或两个张量沿着长度为 1 的轴复制元素，使二者形状一致。
2. _运算_：对扩展后的数组执行按元素操作。

张量 `a` 形状为 `(3, 1)`，张量 `b` 形状为 `(1, 2)`。通过广播：
- `a` 的列被复制，变为 `(3, 2)`
- `b` 的行被复制，变为 `(3, 2)`

相加后得到 `3×2` 的结果：

```
[[0, 1],
 [1, 2],
 [2, 3]]
```

=== other
`torch.numel()` ：获得张量中所有元素的个数。

=== deal with missing values
```python
print(data)
```

```console
   NumRooms Alley   Price
0       NaN  Pave  127500
1       2.0   NaN  106000
2       4.0   NaN  178100
3       NaN   NaN  140000
```

use `fillna` to fill NaN
```python
inputs, outputs = data.iloc[:, 0:2], data.iloc[:, 2]
inputs = inputs.fillna(inputs.mean())
print(inputs)
```

```console
   NumRooms Alley
0       3.0  Pave
1       2.0   NaN
2       4.0   NaN
3       3.0   NaN
```

use `get_dummies` (one kind of one-hot encoding)
- 对于 `inputs` 中的类别值或离散值，我们将“NaN”视为一个类别。
- 由于“巷子类型”（“Alley”）列只接受两种类型的类别值“Pave”和“NaN”，
- `pandas` 可以自动将此列转换为两列“Alley_Pave”和“Alley_nan”。
- 巷子类型为“Pave”的行会将“Alley_Pave”的值设置为1，“Alley_nan”的值设置为0。
- 缺少巷子类型的行会将“Alley_Pave”和“Alley_nan”分别设置为0和1。

```python
inputs = pd.get_dummies(inputs, dummy_na=True)
print(inputs)
```

```console
   NumRooms  Alley_Pave  Alley_nan
0       3.0           1          0
1       2.0           0          1
2       4.0           0          1
3       3.0           0          1
```

== math
向量是一阶张量，矩阵是二阶张量。张量是描述具有任意数量轴的 $n$ 维张量。

_对称矩阵_（symmetric matrix）$A$ 等于其转置：$A = A^T$

*两个矩阵的按元素乘法称为 _Hadamard 积_（Hadamard product）（数学符号 $dot.o$）*

矩阵 $A$ 和 $B$ 的 Hadamard 积为：

$ A dot.o B = mat(a_11 b_11, a_12 b_12, dots, a_1n b_1n.o;
                a_21 b_21, a_22 b_22, dots, a_2n b_2n;
                dots.v, dots.v, dots.v, dots.v;
                a_"m1" b_"m1", a_"m2" b_"m2", dots, a_"mn" b_"mn") $

=== sum
```python
A
```

```console
tensor([[ 0.,  1.,  2.,  3.],
        [ 4.,  5.,  6.,  7.],
        [ 8.,  9., 10., 11.],
        [12., 13., 14., 15.],
        [16., 17., 18., 19.]])
```

`axis=0` 可以使输入矩阵沿`0`轴降维以生成输出向量，因此输入轴`0`的维数在输出形状中消失

如果不想降维，可以使用 `keepdim=True` 的参数

```python
A_sum_axis0 = A.sum(axis=0)
A_sum_axis0, A_sum_axis0.shape
```

output as follow

```console
(tensor([40., 45., 50., 55.]), torch.Size([4]))
```

类比就可以知道 `axis=1` 含义了

同样的，如果不想降维，可以使用 `keepdim=True` 的参数

```python
A_sum_axis1 = A.sum(axis=1)
A_sum_axis1, A_sum_axis1.shape
```

```console
(tensor([ 6., 22., 38., 54., 70.]), torch.Size([5]))
```

=== cumsum
如果想沿某个轴计算A元素的累积总和，比如 `axis=0`（按行计算），可以调用 `cumsum` 函数，这不会沿任何轴降低输入张量的维度。

这里的方向和 `sum()` 的方向不一样，要区分清楚

```python
>>> a = torch.randint(1, 20, (10,))
>>> a
tensor([13,  7,  3, 10, 13,  3, 15, 10,  9, 10])
>>> torch.cumsum(a, dim=0)
tensor([13, 20, 23, 33, 46, 49, 64, 74, 83, 93])
```

=== norm
$L_2$ 范数和 $L_1$ 范数都是更一般的 $L_p$ 范数的特例：

$ norm(x)_p = ( sum_(i=1)^n abs(x_i)^p )^(1/p) $

类似于向量的 $L_2$ 范数，$X in RR^(m times n)$ 的 _Frobenius 范数_（Frobenius norm）是矩阵元素平方和的平方根

$ norm(X)_F = sqrt( sum_(i=1)^m sum_(j=1)^n x_(i j)^2 ) $

Frobenius 范数满足向量范数的所有性质，它就像是矩阵形向量的 $L_2$ 范数。可以使用 `torch.norm()` 来计算

类似的函数是 `torch.linalg.norm`

`torch.linalg.norm` 默认计算所有元素的 Frobenius 范数
- `ord` 参数：可以指定不同类型的范数（如 `ord=1` 为列和范数，`ord=2` 为谱范数等）。
- `dim` 参数：可以指定沿特定轴计算范数

e.g
```python
# X.shape == (2, 3, 4)
torch.linalg.norm(X, dim=0)  # 沿 axis=0 计算，输出形状 (3,4)
torch.linalg.norm(X, dim=(1,2))  # 沿 axis=1 和 2 计算，输出形状 (2,)
```

== gradient
通过连结一个多元函数对其所有变量的偏导数可以得到该函数的 _梯度_（gradient）向量。

设函数 $f : RR^n -> RR$ 的输入是一个 $n$ 维向量 $x = [x_1, x_2, dots, x_n]^T$，并且输出是一个标量。

函数 $f(x)$ 相对于 $x$ 的梯度是一个包含 $n$ 个偏导数的向量：

$ nabla_x f(x) = [ (partial f(x))/(partial x_1), (partial f(x))/(partial x_2), dots, (partial f(x))/(partial x_n) ]^T $

其中 $nabla_x f(x)$ 通常在没有歧义时被 $nabla f(x)$ 取代。

假设 $x$ 为 $n$ 维向量，经常使用的有以下规则：

* 对于所有 $A in RR^(m times n)$，都有 $nabla_x A x = A^T$
* 对于所有 $A in RR^(n times m)$，都有 $nabla_x x^T A = A$
* 对于所有 $A in RR^(n times n)$，都有 $nabla_x x^T A x = (A + A^T) x$
* $nabla_x norm(x)^2 = nabla_x x^T x = 2x$

对于任何矩阵 $X$，都有 $nabla_X norm(X)_F^2 = 2X$。

== computational graph
系统会构建一个计算图（computational graph），来跟踪计算是哪些数据通过哪些操作组合起来产生输出。自动微分使系统能够随后反向传播梯度。
- `tensor1.requires_grad_(True)`：告诉框架需要对 _该张量_ 求导
- `tensor2.backward()`：求 tensor2 对 tensor1 导数（tensor2 需为 tensor1 的表达式，且求导前要执行 `requires_grad_(True)` 命令）
- `tensor1.grad`：访问求导后张量的导数
- `tensor.grad.zero_()`：梯度清零（Pytorch 默认会累计梯度并存储在 `.grad` 内）
- `tensor.detach()`：将该变量移出计算图，当作常量处理，多用于神经网络的参数固定
- 一般很少用到向量对向量（以及更高阶）的求导，需要引入一个 gradient 参数，所以会把一个向量转化为标量求导，最常用的就是求和：`tensor.sum().backward()`。`loss` 一般是一个标量，如果 loss 是矩阵，维度就会越算越大。
- 可以经过 Python 计算流再求导。

=== add-on
_非标量变量的反向传播_

`y = x * x`（`x = [0, 1, 2, 3]`）。

写法一（显式传入 gradient）
```python
y.backward(torch.ones(len(x))) 
```
这相当于令向量 $v = [1, 1, 1, 1]^T$。

写法二（`sum` 技巧）：
```python
y.sum().backward()
```
- `y.sum()` 是一个 _标量_，即 $y_1 + y_2 + y_3 + y_4$。
- 这个标量对 `x` 求导，就是 $ (partial (y_1 + y_2 + y_3 + y_4))/(partial x) $
- 由于线性加法的导数等于导数的和，这等价于对雅可比矩阵的 _每一列求和_。

对雅可比矩阵的每一列求和，恰好等同于 _雅可比矩阵左乘全 1 向量_（即 $1^T dot J$）。所以：
> *`y.sum().backward()` 等价于 `y.backward(torch.ones_like(y))`*

手动算：
- 原函数：$y_i = x_i^2$
- 雅可比矩阵 $J$ 是一个对角矩阵，对角线上的元素是 $(d y_i)/(d x_i) = 2x_i$。
- 当我们传入全 1 向量 `v` 时，$v^T dot J = [1, 1, 1, 1] times (2x_i) = [2x_1, 2x_2, 2x_3, 2x_4]$。
- 代入 `x = [0, 1, 2, 3]`，就是 `[0, 2, 4, 6]`。

#pagebreak()

= Linear Neural network

== Normal equation

线性回归是一个很简单的优化问题。

线性回归的解可以用一个公式简单地表达出来，这类解叫作解析解（analytical solution）。

线性回归的最小二乘解（Normal Equation）：

$ w^* = (X^T X)^(-1) X^T y $

- $w^*$ 是最优权重参数向量
- 该公式要求 $X^T X$ 可逆（即特征之间线性无关），这对问题的限制严格，对很多问题无法应用

== SGD

*Mini-batch SGD*的具体梯度计算公式。

核心内容：
- 参数 $(w, b)$ 的迭代更新形式为：
  $ (w, b) <- (w, b) - frac((eta),|B|) sum_(i in B) partial_(w,b) l^((i))(w, b) $
  其中 $eta$ 为学习率，$B$ 为小批量样本集，$|B|$ 为批量大小。
- 算法步骤：① 随机初始化参数；② 反复随机采样小批量，并沿负梯度方向更新参数。
- 对于线性回归，$w$ 和 $b$ 的显式更新公式为：
  $ w <- w - frac((eta),|B|) sum_(i in B) x^((i)) ( w^T x^((i)) + b - y^((i)) ) $
  $ b <- b - frac((eta),|B|) sum_(i in B) ( w^T x^((i)) + b - y^((i)) ) $

== softmax

softmax函数能够将未规范化的预测变换为非负数并且总和为1，同时让模型保持可导的性质。

$ hat(y) eq "softmax"(o) quad "其中" quad hat(y)_j eq frac(exp(o_j), sum_k exp(o_k)) $

利用 softmax 的定义 和 $sum^q_(j eq 1) y_j eq 1$，我们得到损失函数如下：

$
l(y, hat(y))
&= - sum_(j=1)^q y_j log frac( exp(o_j), sum_(k=1)^q exp(o_k))  \
&= sum_(j=1)^q y_j log sum_(k=1)^q exp(o_k) - sum_(j=1)^q y_j o_j \
&= log sum_(k=1)^q exp(o_k) - sum_(j=1)^q y_j o_j.
$

考虑相对于任何未规范化的预测 $o_j$ 的导数，我们得到：

$
partial_(o_j) l(y, hat(y))
&= frac(exp(o_j) , sum_(k=1)^q exp(o_k) ) minus  y_j eq "softmax"(o)_j - y_j. 
$

=== implement from scratch
*实现softmax*由三个步骤组成：

1. 对每个项求幂（使用`exp`）；
2. 对每一行求和（小批量中每个样本是一行），得到每个样本的规范化常数；
3. 将每一行除以其规范化常数，确保结果的和为1。

表达式如下：

$
"softmax"(upright(X))_"ij" eq frac(exp(upright(X))_"ij", sum_k exp(upright(X))_"ik")
$

代码如下：

````python
def softmax(X):
  X_exp = torch.exp(X)
  partition = X_exp.sum(1, keepdim=True)
  return X_exp / partition
````  

#problem[
代码实现有点草率。 矩阵中的非常大或非常小的元素可能造成数值上溢或下溢，但没有采取措施来防止这点。
]

交叉熵采用真实标签的负对数似然， $L eq minus log(P_"true")$

````python
def cross_entropy(y_hat, y):
    return - torch.log(y_hat[range(len(y_hat)), y])
````

=== concise implementation

记得前文的数值上溢和下溢问题

#tip-block([
  在 softmax 计算之前，先从所有 $o_k$ 中减去 $max(o_k)$, 看到每个 $o_k$ 按常数进行的移动不会改变 softmax 的返回值: 

$
hat(y)_j &= frac(exp(o_j - max(o_k)) exp(max(o_k)), sum_k exp(o_k - max(o_k)) exp(max(o_k)))\
&= frac(exp(o_j - max(o_k)), sum_k exp(o_k - max(o_k))).
$
])

然后再进行推导

$
log(hat(y)_j) &= log( frac(exp(o_j - max(o_k)), sum_k exp(o_k - max(o_k))) )\
&= log( exp(o_j - max(o_k)) ) - log( sum_k exp(o_k - max(o_k)) )\
&= o_j - max(o_k) - log( sum_k exp(o_k - max(o_k)) ).
$

于是可以避免计算$exp(O_j minus max(O_k))$可能出现的数值下溢问题

= mlp

深度学习基础的概念，不多做介绍

= deep-learning-computation

== block
first is the template to use the pytorch to define our own block

tow main part
- inherit from `nn.Moudle` and define the `__init__` function
- define the `forward` function

````python
class MLP(nn.Module):
    def __init__(self):
        # 调用MLP的父类Module的构造函数来执行必要的初始化。
        super().__init__()
        self.hidden = nn.Linear(20, 256)
        self.out = nn.Linear(256, 10)

    # 定义模型的前向传播
    def forward(self, X):
        return self.out(F.relu(self.hidden(X)))
````

parameters can be accessed by calling the `state_dict()` function

````python
net = nn.Sequential(nn.Linear(4, 8), nn.ReLU(), nn.Linear(8, 1))
print(net[2].state_dict())
````

output as following

````console
OrderedDict([('weight', tensor([[ 0.3016, -0.1901, -0.1991, -0.1220,  0.1121, -0.1424, -0.3060,  0.3400]])), ('bias', tensor([-0.0291]))])
````

other ways to do so
- `.bias`, `.bias.data`, `.weight`, `.weight.grad`, `.name_parameters()`

== save and load

for each tensor, we can use `load` and `save` to read and write them

````python
x = torch.range(4)
torch.save(x, 'x-file')
x2 = torch.load('x-file')
````

so we can do it for the model parameters too

````python
# define a net model somewhere before
torch.save(net.state_dict(), 'mlp.params')
clone.load_state_dict(torch.load('mlp.params'))
````

== use gpu

so the most common gpu in used is nvidia\(but, nvidia, f\*\*k you)

we can check it with commandline

````console
nvidia-smi
````

#note-block([
  在PyTorch中，CPU和GPU可以用`torch.device('cpu')`
和`torch.device('cuda')`表示。
`cpu`设备意味着PyTorch的计算将尝试使用所有CPU核心。
`gpu`设备只代表一个卡和相应的显存。
如果有多个GPU，使用`torch.device(f'cuda:{i}')`
来表示第$i$块GPU（$i$从0开始）,
`cuda:0`和`cuda`是等价的。
])

we can use `torch.cuda.device_count()` to query how many gpu we have, use `.device` to check the device that it use

````python
x = torch.tensor([1, 2, 3])
x.device
````

can define some function to easily specific the device
 
````python
def try_gpu(i=0):
    """如果存在，则返回gpu(i)，否则返回cpu()"""
    if torch.cuda.device_count() >= i + 1:
        return torch.device(f'cuda:{i}')
    return torch.device('cpu')

def try_all_gpus():
    """返回所有可用的GPU，如果没有GPU，则返回[cpu(),]"""
    devices = [torch.device(f'cuda:{i}')
             for i in range(torch.cuda.device_count())]
    return devices if devices else [torch.device('cpu')]
````

and use it

````python
X = torch.ones(2, 3, device=try_gpu())
net = nn.Sequential(nn.Linear(3, 1))
net = net.to(device=try_gpu())
````

#pagebreak()

= convolutional nn

== why conv

basic idea

1. *平移不变性*（translation invariance）：不管检测对象出现在图像中的哪个位置，神经网络的前面几层应该对相同的图像区域具有相似的反应。
2. *局部性*（locality）：神经网络的前面几层应该只探索输入图像中的局部区域，而不过度在意图像中相隔较远区域的关系。最后可以聚合这些局部特征，以在整个图像级别进行预测。

多层感知机的在图像处理的限制
- 参数爆炸，忽略先验知识，固定输入的尺寸，优化困难

== conv layer
严格来说，卷积层是个错误的叫法，因为它所表达的运算其实是*互相关运算*（cross-correlation），而不是卷积运算。

#grid(
  columns: (1.8fr, 2fr),
  [
    #image("img/cross-corrlation.png")
  ],
  [
    \
$
0 times 0+1 times 1+3 times 2+4 times 3=19,\
1 times 0+2 times 1+4 times 2+5 times 3=25,\
3 times 0+4 times 1+6 times 2+7 times 3=37,\
4 times 0+5 times 1+7 times 2+8 times 3=43.
$
  ]
)

输入大小为$n_h times n_w$, 卷积核大小$k_h times k_w$，输出大小为输入大小减去卷积核大小:

$ (n_h-k_h+1) times (n_w-k_w+1). $

so we can define a corr2d function to operate it

````python
def corr2d(X, K):
    """计算二维互相关运算"""
    h, w = K.shape
    Y = torch.zeros((X.shape[0] - h + 1, X.shape[1] - w + 1))
    for i in range(Y.shape[0]):
        for j in range(Y.shape[1]):
            Y[i, j] = (X[i:i + h, j:j + w] * K).sum()
    return Y
````

== learning convolutional kernal

可以通过“输入-输出”对来学习由`X`生成`Y`的卷积核而无需手工设置

````python
# 二维卷积层，有1个输出通道和形状为（1，2）的卷积核
conv2d = nn.Conv2d(1,1, kernel_size=(1, 2), bias=False)

# 四维输入和输出格式（批量大小、通道、高度、宽度），批量大小和通道数都为1
X = X.reshape((1, 1, 6, 8))
Y = Y.reshape((1, 1, 6, 7))
lr = 3e-2

for i in range(10):
    Y_hat = conv2d(X)
    l = (Y_hat - Y) ** 2
    conv2d.zero_grad()
    l.sum().backward()
    # 迭代卷积核
    conv2d.weight.data[:] -= lr * conv2d.weight.grad
    if (i + 1) % 2 == 0:
        print(f'epoch {i+1}, loss {l.sum():.3f}')
````

output as follow

````console
epoch 2, loss 4.149
epoch 4, loss 1.216
epoch 6, loss 0.417
epoch 8, loss 0.157
epoch 10, loss 0.062
````

== pooling

我们处理图像时，我们希望逐渐降低隐藏表示的空间分辨率、聚集信息，这样随着我们在神经网络中层叠的上升，每个神经元对其敏感的感受野（输入）就越大。

pooling可以降低卷积层对位置的敏感性，同时降低对空间降采样表示的敏感性。

max pooling as follow, average pooling is just take the average of the numbers
#figure(
grid(
  columns: (1.2fr, 2fr),
  [
    #image("img/max_pooling.png", width: 112%)
  ],
  [
    \
$
max(0, 1, 3, 4)=4,\
max(1, 2, 4, 5)=5,\
max(3, 4, 6, 7)=7,\
max(4, 5, 7, 8)=8.\
$
  ]
),
caption: [max pooling]
)

stride, padding不多做介绍了

== LeNet-5

LeNet-5是经典的卷积网络设计

#figure(
  image("img/lenet-5.png"),
  caption: [leNet-5]
)

可以在torch上轻松定义

````python
net = nn.Sequential(
    nn.Conv2d(1, 6, kernel_size=5, padding=2), nn.Sigmoid(),
    nn.AvgPool2d(kernel_size=2, stride=2),
    nn.Conv2d(6, 16, kernel_size=5), nn.Sigmoid(),
    nn.AvgPool2d(kernel_size=2, stride=2),
    nn.Flatten(),
    nn.Linear(16 * 5 * 5, 120), nn.Sigmoid(),
    nn.Linear(120, 84), nn.Sigmoid(),
    nn.Linear(84, 10))
````

d2l train code, worth to understand

````python
def train_ch6(net, train_iter, test_iter, num_epochs, lr, device):
    """用GPU训练模型"""
    def init_weights(m):
        if type(m) == nn.Linear or type(m) == nn.Conv2d:
            nn.init.xavier_uniform_(m.weight)
    net.apply(init_weights)
    print('training on', device)
    net.to(device)
    optimizer = torch.optim.SGD(net.parameters(), lr=lr)
    loss = nn.CrossEntropyLoss()
    animator = d2l.Animator(xlabel='epoch', xlim=[1, num_epochs],
                            legend=['train loss', 'train acc', 'test acc'])
    timer, num_batches = d2l.Timer(), len(train_iter)
    for epoch in range(num_epochs):
        # 训练损失之和，训练准确率之和，样本数
        metric = d2l.Accumulator(3)
        net.train()
        for i, (X, y) in enumerate(train_iter):
            timer.start()
            optimizer.zero_grad()
            X, y = X.to(device), y.to(device)
            y_hat = net(X)
            l = loss(y_hat, y)
            l.backward()
            optimizer.step()
            with torch.no_grad():
                metric.add(l * X.shape[0], d2l.accuracy(y_hat, y), X.shape[0])
            timer.stop()
            train_l = metric[0] / metric[2]
            train_acc = metric[1] / metric[2]
            if (i + 1) % (num_batches // 5) == 0 or i == num_batches - 1:
                animator.add(epoch + (i + 1) / num_batches,
                             (train_l, train_acc, None))
        test_acc = evaluate_accuracy_gpu(net, test_iter)
        animator.add(epoch + 1, (None, None, test_acc))
    print(f'loss {train_l:.3f}, train acc {train_acc:.3f}, '
          f'test acc {test_acc:.3f}')
    print(f'{metric[2] * num_epochs / timer.sum():.1f} examples/sec '
          f'on {str(device)}')

lr, num_epochs = 0.9, 10
train_ch6(net, train_iter, test_iter, num_epochs, lr, d2l.try_gpu())
````

#pagebreak()

= modern cnn

modern cnn专注在大型数据集上，是深度卷积神经网络

== AlexNet

#grid(
  columns: (2fr, 1.9fr),
  [
    #figure(
     image("img/alexnet.png", height: 28%),
     caption: [leNet-5(左), AlexNet(右)]
    )
  ],
  [
    \
    \
    \
    \
AlexNet和LeNet的设计理念非常相似，但也存在差异。

1. AlexNet比相对较小的LeNet5要深得多。
2. AlexNet由八层组成：五个卷积层、两个全连接隐藏层和一个全连接输出层。
3. AlexNet使用ReLU而不是sigmoid作为其激活函数。
4. AlexNet使用`dropout`来控制模型的复杂度
  ]
)

代码如下：

````python
net = nn.Sequential(
    # 这里使用一个11*11的更大窗口来捕捉对象。
    # 同时，步幅为4，以减少输出的高度和宽度。
    # 另外，输出通道的数目远大于LeNet
    nn.Conv2d(1, 96, kernel_size=11, stride=4, padding=1), nn.ReLU(),
    nn.MaxPool2d(kernel_size=3, stride=2),
    # 减小卷积窗口，使用填充为2来使得输入与输出的高和宽一致，且增大输出通道数
    nn.Conv2d(96, 256, kernel_size=5, padding=2), nn.ReLU(),
    nn.MaxPool2d(kernel_size=3, stride=2),
    # 使用三个连续的卷积层和较小的卷积窗口。
    # 除了最后的卷积层，输出通道的数量进一步增加。
    # 在前两个卷积层之后，汇聚层不用于减少输入的高度和宽度
    nn.Conv2d(256, 384, kernel_size=3, padding=1), nn.ReLU(),
    nn.Conv2d(384, 384, kernel_size=3, padding=1), nn.ReLU(),
    nn.Conv2d(384, 256, kernel_size=3, padding=1), nn.ReLU(),
    nn.MaxPool2d(kernel_size=3, stride=2),
    nn.Flatten(),
    # 这里，全连接层的输出数量是LeNet中的好几倍。使用dropout层来减轻过拟合
    nn.Linear(6400, 4096), nn.ReLU(),
    nn.Dropout(p=0.5),
    nn.Linear(4096, 4096), nn.ReLU(),
    nn.Dropout(p=0.5),
    # 最后是输出层。由于这里使用Fashion-MNIST，所以用类别数为10，而非论文中的1000
    nn.Linear(4096, 10))
````

== VGG
AlexNet没有提供后人任何设计模式，VGG是一种设计模板。

VGG网络可以分为两部分：

- 第一部分主要由卷积层和汇聚层组成
- 第二部分由全连接层组成

#figure(
image("img/vgg.png", height: 33%),
caption: [VGG block]
)

VGG-11使用8个卷积层和3个全连接层，原始的VGG网络使用5个VGG块

````python
def vgg_block(num_convs, in_channels, out_channels):
    layers = []
    for _ in range(num_convs):
        layers.append(nn.Conv2d(in_channels, out_channels, kernel_size=3, padding=1))
        layers.append(nn.ReLU())
        in_channels = out_channels
    layers.append(nn.MaxPool2d(kernel_size=2,stride=2))
    return nn.Sequential(*layers)

def vgg(conv_arch):
    conv_blks = []
    in_channels = 1
    # 卷积层部分
    for (num_convs, out_channels) in conv_arch:
        conv_blks.append(vgg_block(num_convs, in_channels, out_channels))
        in_channels = out_channels

    return nn.Sequential(
        *conv_blks, nn.Flatten(),
        # 全连接层部分
        nn.Linear(out_channels * 7 * 7, 4096), nn.ReLU(), nn.Dropout(0.5),
        nn.Linear(4096, 4096), nn.ReLU(), nn.Dropout(0.5),
        nn.Linear(4096, 10))

conv_arch = ((1, 64), (1, 128), (2, 256), (2, 512), (2, 512))
net = vgg(conv_arch)
````

== NiN


#image("img/NiN.png", height: 40%)

NiN完全取消了全连接层，在最后使用的是一个*全局平均汇聚层*

代码如下：

````python
def nin_block(in_channels, out_channels, kernel_size, strides, padding):
    return nn.Sequential(
        nn.Conv2d(in_channels, out_channels, kernel_size, strides, padding),
        nn.ReLU(),
        nn.Conv2d(out_channels, out_channels, kernel_size=1), nn.ReLU(),
        nn.Conv2d(out_channels, out_channels, kernel_size=1), nn.ReLU())

net = nn.Sequential(
    nin_block(1, 96, kernel_size=11, strides=4, padding=0),
    nn.MaxPool2d(3, stride=2),
    nin_block(96, 256, kernel_size=5, strides=1, padding=2),
    nn.MaxPool2d(3, stride=2),
    nin_block(256, 384, kernel_size=3, strides=1, padding=1),
    nn.MaxPool2d(3, stride=2),
    nn.Dropout(0.5),
    # 标签类别数是10
    nin_block(384, 10, kernel_size=3, strides=1, padding=1),
    nn.AdaptiveAvgPool2d((1, 1)),
    # 将四维的输出转成二维的输出，其形状为(批量大小,10)
    nn.Flatten())
````

#pagebreak()

== googleNet

googleNet是优秀的神经网络模型设计, googleNet吸收了NiN中串联网络的思想

其中的基本块是incepton块

#figure(
      image("img/inception.png"),
      caption: [inception block]
)

````python
class Inception(nn.Module):
    # c1--c4是每条路径的输出通道数
    def __init__(self, in_channels, c1, c2, c3, c4, **kwargs):
        super(Inception, self).__init__(**kwargs)
        # 线路1，单1x1卷积层
        self.p1_1 = nn.Conv2d(in_channels, c1, kernel_size=1)
        # 线路2，1x1卷积层后接3x3卷积层
        self.p2_1 = nn.Conv2d(in_channels, c2[0], kernel_size=1)
        self.p2_2 = nn.Conv2d(c2[0], c2[1], kernel_size=3, padding=1)
        # 线路3，1x1卷积层后接5x5卷积层
        self.p3_1 = nn.Conv2d(in_channels, c3[0], kernel_size=1)
        self.p3_2 = nn.Conv2d(c3[0], c3[1], kernel_size=5, padding=2)
        # 线路4，3x3最大汇聚层后接1x1卷积层
        self.p4_1 = nn.MaxPool2d(kernel_size=3, stride=1, padding=1)
        self.p4_2 = nn.Conv2d(in_channels, c4, kernel_size=1)

    def forward(self, x):
        p1 = F.relu(self.p1_1(x))
        p2 = F.relu(self.p2_2(F.relu(self.p2_1(x))))
        p3 = F.relu(self.p3_2(F.relu(self.p3_1(x))))
        p4 = F.relu(self.p4_2(self.p4_1(x)))
        # 在通道维度上连结输出
        return torch.cat((p1, p2, p3, p4), dim=1)
````

#grid(
  columns: (1fr, 2fr),
  [
    #figure(
      image("img/googleNet.png", height: 61%, width: 102%, fit: "stretch"),
      caption: [googleNet]
    )
  ],
  [
    #set text(size: 8.2pt)
    \
    \
    \
    \
    \
    \
    \
    \
    \
    \
    \
    代码如下：
    ````python
b1 = nn.Sequential(nn.Conv2d(1, 64, kernel_size=7, stride=2, padding=3),
                  nn.ReLU(), 
                  nn.MaxPool2d(kernel_size=3, stride=2, padding=1))
b2 = nn.Sequential(nn.Conv2d(64, 64, kernel_size=1), 
                  nn.ReLU(),
                  nn.Conv2d(64, 192, kernel_size=3, padding=1), 
                  nn.ReLU(), 
                  nn.MaxPool2d(kernel_size=3, stride=2, padding=1))
b3 = nn.Sequential(Inception(192, 64, (96, 128), (16, 32), 32),
                   Inception(256, 128, (128, 192), (32, 96), 64),
                   nn.MaxPool2d(kernel_size=3, stride=2, padding=1))
b4 = nn.Sequential(Inception(480, 192, (96, 208), (16, 48), 64),
                   Inception(512, 160, (112, 224), (24, 64), 64),
                   Inception(512, 128, (128, 256), (24, 64), 64),
                   Inception(512, 112, (144, 288), (32, 64), 64),
                   Inception(528, 256, (160, 320), (32, 128), 128),
                   nn.MaxPool2d(kernel_size=3, stride=2, padding=1))
b5 = nn.Sequential(Inception(832, 256, (160, 320), (32, 128), 128),
                   Inception(832, 384, (192, 384), (48, 128), 128),
                   nn.AdaptiveAvgPool2d((1,1)),
                   nn.Flatten())

net = nn.Sequential(b1, b2, b3, b4, b5, nn.Linear(1024, 10))
    ````
  ]
)

== batch-norm

#problem-box[

 训练深层神经网络是十分困难的，特别是在较短的时间内使他们收敛更加棘手。
]

数据预处理的方式通常会对最终结果产生巨大影响。

批量规范化被认为可以使优化更加平滑。

batchnorm存在*争议*

#quote-block([
回想一下，我们甚至不知道简单的神经网络（多层感知机和传统的卷积神经网络）为什么如此有效。
即使在暂退法和权重衰减的情况下，它们仍然非常灵活，因此无法通过常规的学习理论泛化保证来解释它们是否能够泛化。

在提出批量规范化的论文中，作者除了介绍了其应用，还解释了其原理：通过减少*内部协变量偏移*（internal covariate shift）。
据推测，作者所说的*内部协变量转移*类似于上述的投机直觉，即变量值的分布在训练过程中会发生变化。

然而，这种解释有两个问题：

1、这种偏移与严格定义的*协变量偏移*（covariate shift）非常不同，所以这个名字用词不当；

2、这种解释只提供了一种不明确的直觉，但留下了一个有待后续挖掘的问题：为什么这项技术如此有效？

随着批量规范化的普及，*内部协变量偏移*的解释反复出现在技术文献的辩论，特别是关于“如何展示机器学习研究”的更广泛的讨论中。

一些作者对批量规范化的成功提出了另一种解释：在某些方面，批量规范化的表现出与原始论文中声称的行为是相反的。

然而，与机器学习文献中成千上万类似模糊的说法相比，内部协变量偏移没有更值得批评。
很可能，它作为这些辩论的焦点而产生共鸣，要归功于目标受众对它的广泛认可。

批量规范化已经被证明是一种不可或缺的方法。它适用于几乎所有图像分类器，并在学术界获得了数万引用。
])

== ResNet

first is the residual block

#figure(
  image("img/residual_block.png"),
  caption: [difference between residual block and normal one]
)

#figure(
image("img/code_version.png"),
caption: [包含以及不包含 1 × 1 卷积层的残差块]
)

下面是有关的代码：

````python
class Residual(nn.Module):
  def __init__(self, input_channels, num_channels, use_1x1conv=False, strides=1):
      super().__init__()
      self.conv1 = nn.Conv2d(input_channels, num_channels,
                            kernel_size=3, padding=1, stride=strides)
      self.conv2 = nn.Conv2d(num_channels, num_channels,
                            kernel_size=3, padding=1)
      if use_1x1conv:
        self.conv3 = nn.Conv2d(input_channels, num_channels,
                                kernel_size=1, stride=strides)
      else:
        self.conv3 = None
      self.bn1 = nn.BatchNorm2d(num_channels)
      self.bn2 = nn.BatchNorm2d(num_channels)

  def forward(self, X):
      Y = F.relu(self.bn1(self.conv1(X)))
      Y = self.bn2(self.conv2(Y))
      if self.conv3:
        X = self.conv3(X)
      Y += X
      return F.relu(Y)
````

````python
def resnet_block(input_channels, num_channels, num_residuals, first_block=False):
    blk = []
    for i in range(num_residuals):
        if i == 0 and not first_block:
            blk.append(Residual(input_channels, num_channels,
                                use_1x1conv=True, strides=2))
        else:
          blk.append(Residual(num_channels, num_channels))
    return blk
````

ResNet的前两层跟之前介绍的GoogLeNet中的一样：

在输出通道数为64、步幅为2的7 × 7卷积层后，接步幅
为2的3 × 3的最大汇聚层。不同的是ResNet每个卷积层后增加了批量规范化层。


#grid(
  columns: (1fr, 1.8fr),
  [
    #figure(
      image("img/resnet18.png", height: 50%),
      caption: [resnet-18]
    )
  ],
  [
    \
    \
    \
    \
    \
    \
    \
    相关代码如下：
    ````python
b1 = nn.Sequential(nn.Conv2d(1, 64, kernel_size=7,
                             stride=2, padding=3),
        nn.BatchNorm2d(64), nn.ReLU(),
        nn.MaxPool2d(kernel_size=3, stride=2, padding=1))
b2 = nn.Sequential(*resnet_block(64, 64, 2, first_block=True))
b3 = nn.Sequential(*resnet_block(64, 128, 2))
b4 = nn.Sequential(*resnet_block(128, 256, 2))
b5 = nn.Sequential(*resnet_block(256, 512, 2))
net = nn.Sequential(b1, b2, b3, b4, b5,
                    nn.AdaptiveAvgPool2d((1,1)),
                    nn.Flatten(), nn.Linear(512, 10))
    ````
  ]
)

== DenseNet

稠密连接网络（DenseNet）在某种程度上是ResNet的逻辑扩展。

这里的逻辑扩展可以从泰勒展开式的角度来理解：

$
f(x) eq f(0) + f'(0) x + frac(f''(0), 2!)  x^2 + frac(f'''(0),3!)  x^3 + dots.
$

ResNet将函数展开为

$ f(bold(x)) eq bold(x) + g(bold(x)). $

DenseNet的输出是连接，这种连接是一种映射

#mitex(`$$\mathbf{x} \to \left[
\mathbf{x},
f_1(\mathbf{x}),
f_2([\mathbf{x}, f_1(\mathbf{x})]), f_3([\mathbf{x}, f_1(\mathbf{x}), f_2([\mathbf{x}, f_1(\mathbf{x})])]), \ldots\right].$$`)

#align(center, [
  #image("img/denseNet.png", height: 13%)
])

DenseNet使用了ResNet改良版的“批量规范化、激活和卷积”架构

首先是DenseBlock

````python
def conv_block(input_channels, num_channels):
    return nn.Sequential(
        nn.BatchNorm2d(input_channels), nn.ReLU(),
        nn.Conv2d(input_channels, num_channels, kernel_size=3, padding=1))

class DenseBlock(nn.Module):
    def __init__(self, num_convs, input_channels, num_channels):
        super(DenseBlock, self).__init__()
        layer = []
        for i in range(num_convs):
            layer.append(conv_block(
                num_channels * i + input_channels, num_channels))
        self.net = nn.Sequential(*layer)

    def forward(self, X):
        for blk in self.net:
            Y = blk(X)
            # 连接通道维度上每个块的输入和输出
            X = torch.cat((X, Y), dim=1)
        return X
````

然后是transistion block

````python
def transition_block(input_channels, num_channels):
    return nn.Sequential(
        nn.BatchNorm2d(input_channels), nn.ReLU(),
        nn.Conv2d(input_channels, num_channels, kernel_size=1),
        nn.AvgPool2d(kernel_size=2, stride=2))
````

类似于ResNet使用的4个残差块，DenseNet使用的是4个稠密块。

在每个模块之间，ResNet通过步幅为2的残差块减小高和宽，DenseNet则使用过渡层来减半高和宽，并减半通道数。

代码如下：

````python
b1 = nn.Sequential(
    nn.Conv2d(1, 64, kernel_size=7, stride=2, padding=3),
    nn.BatchNorm2d(64), nn.ReLU(),
    nn.MaxPool2d(kernel_size=3, stride=2, padding=1))

num_channels, growth_rate = 64, 32
num_convs_in_dense_blocks = [4, 4, 4, 4]
blks = []
for i, num_convs in enumerate(num_convs_in_dense_blocks):
    blks.append(DenseBlock(num_convs, num_channels, growth_rate))
    # 上一个稠密块的输出通道数
    num_channels += num_convs * growth_rate
    # 在稠密块之间添加一个转换层，使通道数量减半
    if i != len(num_convs_in_dense_blocks) - 1:
        blks.append(transition_block(num_channels, num_channels // 2))
        num_channels = num_channels // 2

net = nn.Sequential(
    b1, *blks,
    nn.BatchNorm2d(num_channels), nn.ReLU(),
    nn.AdaptiveAvgPool2d((1, 1)),
    nn.Flatten(),
    nn.Linear(num_channels, 10))
````

= recurrent-neural-network

== basis
为了训练语言模型，我们需要计算单词的概率，
以及给定前面几个单词后出现某个单词的条件概率，
这些概率本质上就是语言模型的参数。

基本的概率规则如下：

#mitex(`$$P(x_1, x_2, \ldots, x_T) = \prod_{t=1}^T P(x_t  \mid  x_1, \ldots, x_{t-1}).$$`)

一种常见的策略是执行某种形式的*拉普拉斯平滑*（Laplace smoothing），

#mitex(`$$
\begin{aligned}
    \hat{P}(x) & = \frac{n(x) + \epsilon_1/m}{n + \epsilon_1}, \\
    \hat{P}(x' \mid x) & = \frac{n(x, x') + \epsilon_2 \hat{P}(x')}{n(x) + \epsilon_2}, \\
    \hat{P}(x'' \mid x,x') & = \frac{n(x, x',x'') + \epsilon_3 \hat{P}(x'')}{n(x, x') + \epsilon_3}.
\end{aligned}
$$`)

还有马尔可夫模型与$n$元语法

#mitex(`$$
\begin{aligned}
P(x_1, x_2, x_3, x_4) &=  P(x_1) P(x_2) P(x_3) P(x_4),\\
P(x_1, x_2, x_3, x_4) &=  P(x_1) P(x_2  \mid  x_1) P(x_3  \mid  x_2) P(x_4  \mid  x_3),\\
P(x_1, x_2, x_3, x_4) &=  P(x_1) P(x_2  \mid  x_1) P(x_3  \mid  x_1, x_2) P(x_4  \mid  x_2, x_3).
\end{aligned}
$$`)

通常，涉及一个、两个和三个变量的概率公式分别被称为
*一元语法*（unigram）、*二元语法*（bigram）和*三元语法*（trigram）模型。

== simple rnn

#figure(
image("img/simple_rnn.png", height: 20%),
caption: [simple rnn with hidden state]
)

== perplexity

可以通过一个序列中所有的$n$个词元的交叉熵损失的平均值来衡量：

#mitex(`$$\frac{1}{n} \sum_{t=1}^n -\log P(x_t \mid x_{t-1}, \ldots, x_1),$$`)

由于历史原因，自然语言处理的科学家更喜欢使用一个叫做*困惑度*（perplexity）的量。

#mitex(`$$\exp\left(-\frac{1}{n} \sum_{t=1}^n \log P(x_t \mid x_{t-1}, \ldots, x_1)\right).$$`)

= modern rnn

== gated recurrent unit

#figure(
image("img/gru.png", height: 28%),
caption: [gated recurrent unit]
)

gru包括三个部分
- 重置门
- 更新门
- 候选隐状态

三个门的计算如下：

#mitex(`$$
\begin{aligned}
\mathbf{R}_t &= \sigma(\mathbf{X}_t \mathbf{W}_{xr} + \mathbf{H}_{t-1} \mathbf{W}_{hr} + \mathbf{b}_r),\\
\mathbf{Z}_t &= \sigma(\mathbf{X}_t \mathbf{W}_{xz} + \mathbf{H}_{t-1} \mathbf{W}_{hz} + \mathbf{b}_z),\\
\tilde{\mathbf{H}}_t &= \tanh(\mathbf{X}_t \mathbf{W}_{xh} + \left(\mathbf{R}_t \odot \mathbf{H}_{t-1}\right) \mathbf{W}_{hh} + \mathbf{b}_h)
\end{aligned}
$$`)
对于门控循环单元（GRU）中的重置门和更新门，其权重参数和偏置参数如下：
- 输入权重：#math.italic($bold(W)_(x r), bold(W)_(x z) in bb(R)^(d times h)$)
- 隐藏权重：#math.italic($bold(W)_(h r), bold(W)_(h z) in bb(R)^(h times h)$)
- 偏置参数：#math.italic($bold(b)_r, bold(b)_z in bb(R)^(1 times h)$)

对于候选隐藏状态，其权重和偏置为：
- 输入权重：#math.italic($bold(W)_(x h) in bb(R)^(d times h)$)
- 隐藏权重：#math.italic($bold(W)_(h h) in bb(R)^(h times h)$)
- 偏置项：#math.italic($bold(b)_h in bb(R)^(1 times h)$)

其中，符号 #math.italic($dot.o$) 表示 Hadamard 积（按元素乘积）运算符。

于是最终的更新公式就是：

#mitex(`$$\mathbf{H}_t = \mathbf{Z}_t \odot \mathbf{H}_{t-1}  + (1 - \mathbf{Z}_t) \odot \tilde{\mathbf{H}}_t.$$`)

然后就是scratch的代码了

````python
// 初始化参数并返回参数
def get_params(vocab_size, num_hiddens, device):
    num_inputs = num_outputs = vocab_size

    def normal(shape):
        return torch.randn(size=shape, device=device)*0.01

    def three():
        return (normal((num_inputs, num_hiddens)),
                normal((num_hiddens, num_hiddens)),
                torch.zeros(num_hiddens, device=device))

    W_xz, W_hz, b_z = three()  # 更新门参数
    W_xr, W_hr, b_r = three()  # 重置门参数
    W_xh, W_hh, b_h = three()  # 候选隐状态参数
    # 输出层参数
    W_hq = normal((num_hiddens, num_outputs))
    b_q = torch.zeros(num_outputs, device=device)
    # 附加梯度
    params = [W_xz, W_hz, b_z, W_xr, W_hr, b_r, W_xh, W_hh, b_h, W_hq, b_q]
    for param in params:
        param.requires_grad_(True)
    return params

// 隐状态初始化
def init_gru_state(batch_size, num_hiddens, device):
    return (torch.zeros((batch_size, num_hiddens), device=device), )

def gru(inputs, state, params):
    W_xz, W_hz, b_z, W_xr, W_hr, b_r, W_xh, W_hh, b_h, W_hq, b_q = params
    H, = state
    outputs = []
    for X in inputs:
        Z = torch.sigmoid((X @ W_xz) + (H @ W_hz) + b_z)
        R = torch.sigmoid((X @ W_xr) + (H @ W_hr) + b_r)
        H_tilda = torch.tanh((X @ W_xh) + ((R * H) @ W_hh) + b_h)
        H = Z * H + (1 - Z) * H_tilda
        Y = H @ W_hq + b_q
        outputs.append(Y)
    return torch.cat(outputs, dim=0), (H,)
````

下面是高级api快乐版

````python
num_inputs = vocab_size
gru_layer = nn.GRU(num_inputs, num_hiddens)
model = d2l.RNNModel(gru_layer, len(vocab))
````
== lstm

#figure(
image("img/lstm.png"),
caption: [lstm],
)

#mitex(`$$
\begin{aligned}
\mathbf{I}_t &= \sigma(\mathbf{X}_t \mathbf{W}_{xi} + \mathbf{H}_{t-1} \mathbf{W}_{hi} + \mathbf{b}_i),\\
\mathbf{F}_t &= \sigma(\mathbf{X}_t \mathbf{W}_{xf} + \mathbf{H}_{t-1} \mathbf{W}_{hf} + \mathbf{b}_f),\\
\mathbf{O}_t &= \sigma(\mathbf{X}_t \mathbf{W}_{xo} + \mathbf{H}_{t-1} \mathbf{W}_{ho} + \mathbf{b}_o),\\
\tilde{\mathbf{C}}_t &= \text{tanh}(\mathbf{X}_t \mathbf{W}_{xc} + \mathbf{H}_{t-1} \mathbf{W}_{hc} + \mathbf{b}_c),\\
\mathbf{C}_t &= \mathbf{F}_t \odot \mathbf{C}_{t-1} + \mathbf{I}_t \odot \tilde{\mathbf{C}}_t.\\
\mathbf{H}_t &= \mathbf{O}_t \odot \tanh(\mathbf{C}_t).
\end{aligned}
$$`)

这里的参数就不解释了，和上面的gru的类比就可以知道

代码如下：

````python
# 依旧是初始化参数并返回
def get_lstm_params(vocab_size, num_hiddens, device):
    num_inputs = num_outputs = vocab_size

    def normal(shape):
        return torch.randn(size=shape, device=device)*0.01

    def three():
        return (normal((num_inputs, num_hiddens)),
                normal((num_hiddens, num_hiddens)),
                torch.zeros(num_hiddens, device=device))

    W_xi, W_hi, b_i = three()  # 输入门参数
    W_xf, W_hf, b_f = three()  # 遗忘门参数
    W_xo, W_ho, b_o = three()  # 输出门参数
    W_xc, W_hc, b_c = three()  # 候选记忆元参数
    # 输出层参数
    W_hq = normal((num_hiddens, num_outputs))
    b_q = torch.zeros(num_outputs, device=device)
    # 附加梯度
    params = [W_xi, W_hi, b_i, W_xf, W_hf, b_f, W_xo, W_ho, b_o, W_xc, W_hc,
              b_c, W_hq, b_q]
    for param in params:
        param.requires_grad_(True)
    return params

# 额外的记忆元
def init_lstm_state(batch_size, num_hiddens, device):
    return (torch.zeros((batch_size, num_hiddens), device=device),
            torch.zeros((batch_size, num_hiddens), device=device))

def lstm(inputs, state, params):
    [W_xi, W_hi, b_i, W_xf, W_hf, b_f, W_xo, W_ho, b_o, W_xc, W_hc, b_c,
     W_hq, b_q] = params
    (H, C) = state
    outputs = []
    for X in inputs:
        I = torch.sigmoid((X @ W_xi) + (H @ W_hi) + b_i)
        F = torch.sigmoid((X @ W_xf) + (H @ W_hf) + b_f)
        O = torch.sigmoid((X @ W_xo) + (H @ W_ho) + b_o)
        C_tilda = torch.tanh((X @ W_xc) + (H @ W_hc) + b_c)
        C = F * C + I * C_tilda
        H = O * torch.tanh(C)
        Y = (H @ W_hq) + b_q
        outputs.append(Y)
    return torch.cat(outputs, dim=0), (H, C)
````

bi-rnn 不多做介绍了, 但是bi-rnn用了未来和过去的数据，所以只能在某些特定的任务上使用，不是通用的

== encoder-deconder

#figure(
image("img/endecoder.png"),
caption: [encoder, decoder架构]
)

encoder, decoder架构定义了一种映射的关系，用于机器翻译很合适

== seq2seq

#figure(
image("img/s2s.png", height: 15%),
caption: [seq2seq]
)

bos(beging of sequence), eos(end of sequence)

mask屏蔽不相关项，BLUE来评估生成序列的质量, 训练，预测这几部分不做详细的介绍了

#pagebreak()

= other

剩下的章节不多做笔记了
