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
&= frac(exp(o_j) , sum_(k=1)^q exp(o_k) ) minus  y_j eq "softmax"(o)_j - y_j. $
