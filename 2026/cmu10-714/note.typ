#import "@preview/academi-notes-gr:0.1.0": *

#show: project.with(
  title: "note of cmu10-414/714",
  author: "lencelg from Arcadia Bay",
  academic-year: "2026 summer",
  github: "https://github.com/lencelg",
  logo: "",
)

#set text(font: ("New Computer Modern", "Noto Sans CJK SC"), size: 11pt)
#set par(justify: true, leading: 0.7em)
#set page(numbering: "1")
#show image: set image(width: 70%)

= ML Refresher / Softmax Regression

算是复习课

Three ingredients of machine learning
- The hypothesis class
- The loss function
- An optimization method

== Loss function 1: classification error

The simplest loss function: the *quality* of classifiers.

$
ell_"err"(h(x), y) = cases(0 "if" arg limits("max")_i h_i(x) = y, 1 "otherwise")
$

problem: bad to be used for *optimization*, because it is _not differentiable_.

== Loss function 2: softmax / cross-entropy loss

exponentiating and normalizing its entries

$ z_i = p("label" = i) = (exp(h_i(x))) / (sum_(j=1)^k exp(h_j(x))) "iff" z equiv "softmax"(h(x)) $

define loss to be the (negative) log probability of the true class

aka _softmax_ or _cross-entropy loss_

$ ell_"ce"(h(x), y) = -log p("label" = y) = -h_y(x) + log sum_(j=1)^k exp(h_j(x)) $

== Optimization: gradient descent

For a matrix-input, scalar output function $f : RR^(n times k) -> RR$, the _gradient_ is defined as the matrix of partial derivatives

$
nabla_theta f(theta) in RR^(n times k) = mat(
  (partial f(theta)) / (partial theta_11), ..., (partial f(theta)) / (partial theta_1k);
  dots.v, dots.down, dots.v;
  (partial f(theta)) / (partial theta_"n1"), ..., (partial f(theta)) / (partial theta_"nk")
)
$

Gradient points in the direction that most increases $f$ (locally)

== Stochastic gradient descent

take gradient step each based upon a _minibatch_ (small partition of data)

$
"Repeat:" &\
& "Sample a minibatch of data X" in RR^(B times n), y in {1, ..., k}^B \
& "Update parameters " theta := theta - alpha / B sum_(i=1)^B nabla_theta ell(h_theta(x^((i))), y^((i)))
$

== The gradient of the softmax objective

the gradient of the softmax loss itself: for vector $h in RR^k$

$
(partial l_"ce"(h, y)) / (partial h_i) &= (partial) / (partial h_i) (-h_y + log sum_(j=1)^k exp h_j) \
&= -1_(i = y) + (exp h_i) / (sum_(j=1)^k exp h_j)
$

in vector form: $nabla_h l_"ce"(h, y) = z - e_y$, where $z = "softmax"(h)$

== The gradient of the softmax objective

1. Pretend everything is a scalar, use the typical chain rule
2. then rearrange / transpose matrices/vectors to make the sizes work
3. finally check your answer numerically

整个过程借助教授的板书更好理解

#figure(image("./img/gradient process.png", width: 70%), caption: [])

$theta$ 在SGD的更新规则如下

$ theta := theta - alpha / B X^T (Z - I_y) $

= Manual Neural Networks / Backprop

#text(fill: red)[linear hypothesis problem: ]how to generate nonlinear classification boundaries?

_One idea:_ apply a linear classifier to some (potentially higher-dimensional) features of the data

$ h_theta(x) = theta^T phi(x) $

$ theta in RR^(d times k), phi: RR^n -> RR^d $

but how to create the features function $phi$ ?

记得所有线性组合的结果依旧是线性的.

== Universal function approximation

_Theorem (1D case):_ Given any smooth function $f: RR -> RR$, closed region $cal(D) subset RR$, and $epsilon > 0$, we can construct a one-hidden-layer neural network $hat(f)$ such that
$ max_(x in cal(D)) |f(x) - hat(f)(x)| <= epsilon $

#text(fill: blue)[powerful but need a lot of sample points, not practical]

== Backpropagation

math time

=== The gradient(s) of a two-layer network

warm up math of a two-layer network gradients

$ nabla_((W_1, W_2)) ell_"ce"(sigma(X W_1) W_2, y) $

The gradient w.r.t. $W_2$ looks identical to the softmax regression case:

$
(partial ell_"ce"(sigma(X W_1) W_2, y)) / (partial W_2) &= (partial ell_"ce"(sigma(X W_1) W_2, y)) / (partial (S - I_y)) dot (partial sigma(X W_1) W_2) / (partial W_2) \
&= (S - I_y) dot (sigma(X W_1))
$

$
"note that S" = "normalize"(exp(sigma(X W_1) W_2)) \
(S - I_y) in RR^(m times k), (sigma(X W_1)) in RR^(m times d)
$

the rearrange

$
nabla_(W_2) ell_"ce"(sigma(X W_1) W_2, y) = sigma(X W_1)^T (S - I_y)
$

$
"so the gradient matrix" in RR^(d times k)
$

the gradient w.r.t. $W_1$ ...

$
(partial ell_"ce"(sigma(X W_1) W_2, y)) / (partial W_1) &= (partial ell_"ce"(sigma(X W_1) W_2, y)) / ((partial sigma(X W_1) W_2)) dot (partial sigma(X W_1) W_2) / (partial sigma(X W_1)) dot (partial X W_1) / (partial W_1) \
&= (S - I_y) dot (W_2) dot (sigma'(X W_1)) dot (X)
$

notice that

$ (S - I_y) in RR^(m times k) " " W_2 in RR^(d times k) " " (sigma'(X W_1)) in RR^(m times d) " " X in RR^(m times n) $

so the gradient is

$
nabla_(W_1) ell_"ce"(sigma(X W_1) W_2, y) = X^T ((S - I_y) W_2^T circle.stroked.tiny sigma'(X W_1)) \
"so the gradient matrix" in RR^(n times d)
$

where $circle.stroked.tiny$ denotes _elementwise multiplication_

=== "general" backpropagation

"backpropagation" is just chain rule + intelligent caching of intermediate results

consider fully-connected network:

$ Z_(i+1) = sigma_i(Z_i W_i), i = 1, ..., L $

Then

$ (partial ell(Z_(L+1), y)) / (partial W_i) = (partial ell) / (partial Z_(L+1)) dot (partial Z_(L+1)) / (partial Z_L) dot (partial Z_(L-1)) / (partial Z_(L-2)) ... (partial Z_(i+2)) / (partial Z_(i+1)) dot (partial Z_(i+1)) / (partial W_i) $

$ G_(i+1) = (partial ell(Z_(L+1), y)) / (partial Z_(i+1)) $

Then a simple "backward" iteration to compute the $G_i$'s

$ G_i = G_(i+1) dot (partial Z_(i+1)) / (partial Z_i) = G_(i+1) dot (partial sigma_i(Z_i W_i)) / (partial Z_i W_i) dot (partial Z_i W_i) / (partial Z_i) = G_(i+1) dot sigma'(Z_i W_i) dot W_i $

notice $G_(i + 1)$ is

#figure(image("./img/backpropagation.png", width: 70%), caption: [])

then remeber to rearrange the shape to make to size work

#figure(image("./img/rearrange gradient.png", width: 70%), caption: [])

=== put it all together

compute _all_ the gradients by following the procedure

1. Initialize: $Z_1 = X$
   Iterate: $Z_(i+1) = sigma_i(Z_i W_i), i = 1, ..., L$

2. Initialize: $G_(L+1) = nabla_(Z_(L+1)) ell(Z_(L+1), y) = S - I_y$
   Iterate: $G_i = (G_(i+1) circle.stroked.tiny sigma'_i(Z_i W_i)) W_i^T, i = L, ..., 1$

then compute all the needed gradients along the way

$
nabla_(W_i) ell(Z_(k+1), y) = Z_i^T (G_(i+1) circle.stroked.tiny sigma'_i(Z_i W_i))
$

PS: $(partial Z_(i+1)) / (partial W_i)$ is an operation called the "vector Jacobian product"

= Automatic Differentiation

== Numerical differentiation

Directly compute the partial gradient by definition

$ (partial f(theta)) / (partial theta_i) = lim_(epsilon -> 0) (f(theta + epsilon e_i) - f(theta)) / epsilon $

A more numerically accurate way to approximate the gradient, 这和泰勒展开和中分误差有关, 截断误差为二阶精度。

$ (partial f(theta)) / (partial theta_i) = (f(theta + epsilon e_i) - f(theta - epsilon e_i)) / (2 epsilon) + o(epsilon^2) $

Suffer from numerical error, less efficient to compute, two times of forward to compute

*ps: 推导*

对于前向差分：

$ (f(theta + epsilon e_i) - f(theta)) / epsilon = f'(theta) + 1 / 2 f''(theta) epsilon + O(epsilon^2) $

截断误差为 $O(epsilon)$（一阶精度）。

中心差分的误差

对 $f(theta + epsilon e_i)$ 和 $f(theta - epsilon e_i)$ 分别泰勒展开：

$ f(theta + epsilon) = f(theta) + f'(theta) epsilon + 1 / 2 f''(theta) epsilon^2 + 1 / 6 f'''(theta) epsilon^3 + O(epsilon^4) $

$ f(theta - epsilon) = f(theta) - f'(theta) epsilon + 1 / 2 f''(theta) epsilon^2 - 1 / 6 f'''(theta) epsilon^3 + O(epsilon^4) $

两式相减：

$ f(theta + epsilon) - f(theta - epsilon) = 2 f'(theta) epsilon + 1 / 3 f'''(theta) epsilon^3 + O(epsilon^5) $

因此：

$ (f(theta + epsilon) - f(theta - epsilon)) / (2 epsilon) = f'(theta) + 1 / 6 f'''(theta) epsilon^2 + O(epsilon^4) $

截断误差为 $O(epsilon^2)$（二阶精度）。

== Numerical gradient checking

numerical differentiation is a powerful tool to *check an implement of an automatic differentiation algorithm in unit test cases*

$ delta^T nabla_theta f(theta) = (f(theta + epsilon delta) - f(theta - epsilon delta)) / (2 epsilon) + o(epsilon^2) $

Pick $delta$ from unit ball, check the above invariance.

just check whether left is closer enough to the right

== Forward mode automatic differentiation (AD)

#figure(image("./img/forward AD.png"), caption: [])

缺点在于有 $n$ 个参数的时候要进行 $n$ 次 forward AD.

in deeplearning case, mostly care about the situation where $k = 1$ and large $n$

== Reverse mode automatic differentiation (AD)

#figure(image("./img/reverse AD.png", width: 70%), caption: [])

but need to consider the multiple pathway case

== Derivation for the multiple pathway case

$v_1$ is being used in multiple pathways ($v_2$ and $v_3$)

$ v_1 -> v_2, v_3 -> v_4 -> y $

$y$ can be written in the form of $y = f(v_2, v_3)$

$ bar(v)_1 = (partial y) / (partial v_1) = (partial f(v_2, v_3)) / (partial v_2) (partial v_2) / (partial v_1) + (partial f(v_2, v_3)) / (partial v_3) (partial v_3) / (partial v_1) = bar(v)_2 (partial v_2) / (partial v_1) + bar(v)_3 (partial v_3) / (partial v_1) $

Define partial adjoint

$ bar(v)_(i -> j) = bar(v)_j (partial v_j) / (partial v_i) $

for each input output node pair $i$ and $j$

$ bar(v)_i = sum_(j in "next"(i)) bar(v)_(i -> j) $

compute partial adjoints separately then sum them together

one implementation would look like this

$
& "def " "gradient(out)": \
&quad "node_to_grad" <- {"out": [1]} \
&quad "for " i " in " "reverse_topo_order(out)": \
&quad quad bar(v)_i = sum_j bar(v)_(i -> j) = "sum"("node_to_grad"[i]) \
&quad quad "for " k " in " "inputs"(i): \
&quad quad quad "compute " bar(v)_(k -> i) = bar(v)_i dot (partial v_i) / (partial v_k) \
&quad quad quad "append " bar(v)_(k -> i) " to " "node_to_grad"[k] \
& "return adjoint of input " bar(v)_"input"
$

== extending the computational graph

推导的过程跟 TQ 走一遍就明白了

#figure(image("./img/extending computational graph.png", width: 50%), caption: [])

构造的计算图的计算过程是固定，所以对于不同的输入计算图还是一样，这样就不用重新构建了。由于引用了部分的值，所以空间的开销也变少了。

反向传播
- 先前向，后反向
- 不显式创建反向图，只是按顺序计算导数并传播。

反向模式 AD（显式构建反向图）
- 可以计算导数的导数(get it for free)
- 可以存储、优化或多次执行

== Reverse mode AD on Tensors

扩展定义来支持 Tensor

*matrix*

$ X, W -> Z -> v -> y $

*Forward evaluation trace*

$ Z_("ij") = sum_k X_("ik") W_("kj") $

$ v = f(Z) $

*Forward matrix form*

$ Z = X W $

$ v = f(Z) $

*Define adjoint for tensor values*

$
bar(Z) = mat(
  (partial Y) / (partial Z_(1,1)), ..., (partial Y) / (partial Z_(1,n));
  dots.v, dots.down, dots.v;
  (partial Y) / (partial Z_(m,1)), ..., (partial Y) / (partial Z_(m,n))
)
$

*Reverse evaluation in scalar form*

$ bar(X)_(i,k) = sum_j (partial Z_(i,j)) / (partial X_(i,k)) bar(Z)_(i,j) = sum_j W_(k,j) bar(Z)_(i,j) $

*Reverse matrix form*

$ bar(X) = bar(Z) W^T $

= AD implementation

`detach()` 函数可以断开计算图的节点从而节省内存

```python
x = ndl.Tensor([1], dtype="float32")
sum_loss = ndl.Tensor([0], dtype="float32")

for i in range(100):
   sum_loss += x * x
```

上面的例子会构建一个计算图，在这种情况下带来不必要的开销, 使用 `detach()` 改写：

```python
sum_loss = (sum_loss + x * x).detach()
```

= Fully connected networks, optimization, initialization

A L-layer, fully connected network, a.k.a. multi-layer perceptron (MLP) with an explicit bias term

$ z_(i+1) = sigma_i(W_i^T z_i + b_i), i = 1, ..., L $

$ h_theta(x) equiv z_(L+1) $

$ z_1 equiv x $

with parameters $theta = {W_(1:L), b_(1:L)}$, and where $sigma_i(x)$ is the nonlinear activation, usually with $sigma_L(x) = x$

迭代的表达式写成矩阵形式为：

$
Z_(i+1) = sigma_i(Z_i W_i + 1 b_i^T)
$

其中，$1$表示一个表示一个全1的列向量，用于将列向量$b_i^T$广播到与矩阵$Z_i W_i$相匹配的形状。

在实际实现过程中，我们不用浪费空间去构造这样一个全1列向量，而是直接使用广播算子。

== Optimization

=== Newton's Method

牛顿法使用二次曲面对一个高维函数做近似，因此其收敛速度显著快于一阶逼近的梯度下降法。其迭代公式为：

$
theta_(t+1) = theta_t - alpha (nabla_theta^2 f(theta_t))^(-1) nabla_theta f(theta_t)
$

其中，$(nabla_theta^2 f(theta_t))^(-1)$是*Hessian*矩阵的逆矩阵。*Hessian*矩阵每个元素都是二阶导数，其具体定义为：

$
nabla_theta^2 f(theta_t) = H = mat(
  (partial^2 f) / (partial x_1^2), (partial^2 f) / (partial x_1 partial x_2), ..., (partial^2 f) / (partial x_1 partial x_n);
  (partial^2 f) / (partial x_2 partial x_1), (partial^2 f) / (partial x_2^2), ..., (partial^2 f) / (partial x_2 partial x_n);
  dots.v, dots.v, dots.down, dots.v;
  (partial^2 f) / (partial x_n partial x_1), (partial^2 f) / (partial x_n partial x_2), ..., (partial^2 f) / (partial x_n^2)
)
$

对于二次函数，牛顿法可以一次给出指向最优点的方向

reason not to use it
1. Hessian矩阵是$n times n$的，因此参数量稍微大一点其计算代码都非常非常恐怖
2. 对于非凸优化，二阶方法是否更有效还有待商榷。

#pagebreak()

=== Momentum

- SGD 每次做最快的下降方向，是贪心的，会出现来回跳动的问题。

动量法正是对梯度取指数移动平均的方案: 对于以前的方向加以考虑，曲线变得更平滑

$
& u_(t+1) = beta u_t + (1 - beta) nabla_theta f(theta_t) \
& theta_(t+1) = theta_t - alpha u_(t+1)
$

=== Unbiasing Momentum

如果$u_0$初始化为0，那么第一次进行更新是的梯度值是正常更新的$(1-beta)$倍，因此其前期的收敛过程会稍慢，但随着迭代的进行，其效应会逐渐减弱.

在参数更新过程中对动量进行缩放，具体来说：

$ theta_(t+1) = theta_t - (alpha u_(t+1)) / (1 - beta^(t+1)) $

修正以后其前期的更新速度要快了不少。

=== Nestov Momentum

Nesterov是梯度下降中一个非常有效的"trick"，其在传统momentum的基础上，将计算当前位置的梯度改为计算下一步位置的梯度。

$
& u_(t+1) = beta u_t + (1 - beta) nabla_theta f(theta_t - alpha u_t) \
& theta_(t+1) = theta_t - alpha u_(t+1)
$

大致的思想如下: 利用过去两步的差异构造一个"预测"点，在这个点上计算梯度，从而更有效地压缩误差项中的高阶余量。

=== Adam

Adaptive Moment Estimation

$
& u_(t+1) = beta_1 u_t + (1 - beta_1) nabla_theta f(theta_t) \
& v_(t+1) = beta_2 v_t + (1 - beta_2) (nabla_theta f(theta_t))^2 "  " "square (is elementwise)" \
& theta_(t+1) = theta_t - (alpha u_(t+1)) / (sqrt(v_(t+1)) + epsilon) "  " "all operations are elementwise"
$

Adam在实践中得到了广泛应用，在特定任务上，其可能不是最佳的优化器, 但在大部分任务上，其都能有不错的可以作为基线的表现。

#pagebreak()

== Initialization of weights

初始化参数很重要
- weights don't move "that much"
- choice of initailization matters

if initialize weights #text(fill: blue)[randomly], e.g., $W_i ~ cal(N)(0, sigma^2 I)$

The choice of variance $sigma^2$ will affect two (related) quantities:

1. The norm of the forward activations $Z_i$
2. The norm of the the gradients $nabla_(W_i) ell(h_theta(X), y)$

于是可能会出现梯度消失或者爆炸的问题

Consider independent random variables $x ~ cal(N)(0, 1)$, $w ~ cal(N)(0, 1 / n)$; then
$ E[x_i w_i] = E[x_i] E[w_i] = 0, "Var"[x_i w_i] = "Var"[x_i] "Var"[w_i] = 1 / n $
so
$ E[w^T x] = 0, "Var"[w^T x] = 1 " "(w^T x -> cal(N)(0, 1)) "by central limit theorem" $

if use a linear activation and $z_i ~ cal(N)(0, I)$, $W_i ~ cal(N)(0, 1 / n I)$ then
$ z_(i+1) = W_i^T z_i ~ cal(N)(0, I) $

If use a ReLU nonlinearity, then "half" the components of $z_i$ will be set to zero, so we need twice the variance on $W_i$ to achieve the same final variance, hence
$ W_i ~ cal(N)(0, 2 / n I) "  " "Kaiming normal initialization" $

PS: Kaiming 正态初始化的根本原因在于 _ReLU 激活函数对信号方差的减半效应_

= Neural Network Abstraction

Several parts
+ `nn.Module` to moudularize and Compose Things Together
  - For given inputs, how to compute outputs
  - Get the list of (trainable) parameters
  - Ways to initialize the parameters
+ Regularization and optimizer
+ initialization
+ Data loader and preprocessing

= Normalization and Regularization
== normalization
initialization matters for optimization !!!

there are two ways of normalization

#figure(
image("img/two_normalization_method.png"),
caption: [tow ways of normalization]
)
=== layer normalization
$
  hat(z)_(i+1) = sigma_i (W_i^T z_i + b_i)
$

$
  z_(i+1) = frac(hat(z)_(i+1) - E[hat(z)_(i+1)], ("Var"[hat(z)_(i+1)] + epsilon)^(1/2))
$
=== batch normalization

layer normalization normalizes the #text(fill: blue)[rows] of the matrix

batch normalization normalizes the #text(fill: red, "columns") of the martix

\

batch norm makes the predicitions for each example dependent on the entire batch

#text(fill: red)[test time:]
compute a running average of mean/variance for all features at each layer $hat(mu)_(i+1), hat(sigma)_(i+1)^2$, and normalize by these quantities

$ (z_(i+1))_j = frac((hat(z)_(i+1))_j - (hat(mu)_(i+1))_j, ((hat(sigma)_(i+1)^2)_j + epsilon)^(1/2)) $

= Regularization a.k.a. weight decay
== $ell_2$ Regularization


$ limits("minimize")_(W_(1:L)) space (1)/m sum_(i=1)^m ell(h_(W_(1:L))(x^((i))), y^((i))) + lambda/2 sum_(i=1)^L ||W_i||_2^2 $

Results in the gradient descent updates:

$ W_i := W_i - alpha nabla_(W_i) ell(h(X), y) - alpha lambda W_i = (1 - alpha lambda) W_i - alpha nabla_(W_i) ell(h(X), y) $

at each iteration we #text(fill: blue)[#emph("shrink")] the weights by a factor $(1 - alpha lambda)$ before taking the gradient step

== Dropout
Dropout is another regularization strategy
$
  hat(z)_(i+1) = sigma_i (W_i^T z_i + b_i)
$

$
  (z_(i+1))_j = cases(
    (hat(z)_(i+1))_j \/ (1 - p) #h(26pt)"with probability" 1 - p,
    0 #h(92pt)"with probability" p
  )
$

instructive to consider Dropout as bringing a similar stochastic approximation as SDG to the setting of individual activations

= Convolutional Networks
_Multi-channel_ convolutions:

$ x in RR^(h times w times c_"in") " denotes " c_"in" " channel, size " h times w " image input" $
$ z in RR^(h times w times c_"out") " denotes " c_"out" " channel, size " h times w " image input" $
$ W in RR^(c_in times c_"out" times k times k) " (order 4 tensor) denotes convolutional filter" $

single output channel is sum of convolutions over all input channels in Multi-channel convolutions 

#align(center)[
  $ z[:, :, s] = sum_(r=1)^(c_in) x[:, :, r] star W[r, s, :, :] $
]

import concepts:
- Padding
- Strided Convolution/ Pooling
- Grouped Convolution
- Dilations

== Differentiating convolutions
consider the simpler case of a matrix-vector product operation

$ z = W x $

$ (partial z)/(partial x) = W $

so we need to compute the adjoint product

$ overline(v)^T W <=> W^T overline(v) $

computing the backward pass requires multipling by transpose $W^T$

#figure(
  image("img/1d_diff.png", width: 67%),
  caption: [convolutions as matrix multiplication version 1]
)

\
notice that the operation $hat(W)^T v$ is itself just a convolution with the “flipped” filter

adjoint operator $overline(v) (partial "conv"(x, W))/(partial x)$ just requires convolving $overline(v)$ with the flipped $W$:

$ overline(v) (partial "conv"(x, W)/(partial x)) eq "conv"(overline(v), "flip"(W)) $

= Hardware acceleration

store a matrix in memory

Row major:  
$A[i, j] => A_"data"[i * A."shape"[1] + j]$

Column major:  
$A[i, j] => A_"data"[j * A."shape"[0] + i]$

Strides format:  
$A[i, j] => A_"data"[i * A."strides"[0] + j * A."strides"[1]]$

\
strides can perform transformation/slicing in zero copy way
\
\
------------------------------------------------------------------------------------------------------------------------------------

vectorization example: adding two arrays of length 256

````c
void veccad(float* A, float *B, float* C) {
    for (int i = 0; i < 64; ++i) {
    float4 a = load_float4(A + i*4);
    float4 b = load_float4(B + i*4);
    float4 c = add_float4(a, b);
    store_float4(c + i*4, c);
    }
}
// memory (A, B, C) needs to be aligned to 128 bits
````

use `float4` to load 4 float number at once

also can use openmp lib to add Parallelization

== Matrix Multiplication

base version

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  ```c
  dram float A[n][n], B[n][n], C[n][n];
  for (int i = 0; i < n; ++i) {
    for (int j = 0; j < n; ++j) {
      register float c = 0;
      for (int k = 0; k < n; ++k) {
        register float a = A[i][k];
        register float b = B[j][k];
        c += a * b;
      }
      C[i][j] = c;
    }
  }
  ```,
  [
    \
    \
    A's dram->register time cost:  $n^3$ \
    B's dram->register time cost:  $n^3$ \
    A's register memory cost :  1 \
    B's register memory cost :  1 \
    C's register memory cost :  1 \
    \
    Load cost:  2 \* dramSpeed \* $n^3$ \
    Register cost: 3
  ]
)

\
*Register tiled matrix multiplication*

#grid(
  columns: (1.2fr, 1.1fr),
  gutter: 2em,
  ```c
  dram float A[n/v1][n/v3][v1][v3];
  dram float B[n/v2][n/v3][v2][v3];
  dram float C[n/v1][n/v2][v1][v2];

  for (int i = 0; i < n/v1; ++i) {
    for (int j = 0; j < n/v2; ++j) {
      register float c[v1][v2] = 0;
      for (int k = 0; k < n/v3; ++k) {
        register float a[v1][v3] = A[i][k];
        register float b[v2][v3] = B[j][k];
        c += dot(a, b.T);
      }
      C[i][j] = c;
    }
  }
  ```,
  [
    \
    \
    A's dram->register time cost:  $n^3/"v2"$ \
    B's dram->register time cost:  $n^3/"v1"$ \
    A's register memory cost:      $"v1"*"v3"$ \
    B's register memory cost:      $"v2"*"v3"$ \
    C's register memory cost:      $"v1"*"v2"$ \
    \
    *load cost:*  $"dramSpeed" * (n^3/"v2" + n^3/"v1")$ \
    *Register cost:* $"v1"*"v3" + "v2"*"v3" + "v1"*"v2"$
  ]
)

notice that v3 does not affect the load cost, so we can choose v3 equals 1

the code reuse the memory, so load cost reduce

\
*Cache line aware tiling*

#grid(
  columns: (1.2fr, 1.1fr),
  gutter: 2em,
  ```c
  dram float A[n/b1][b1][n];
  dram float B[n/b2][b2][n];
  dram float C[n/b1][n/b2][b1][b2];
  for (int i = 0; i < n/b1; ++i) {
      llcache float a[b1][n] = A[i];
      for (int j = 0; j < n/b2; ++j) {
          llcache float b[b2][n] = B[j];

          C[i][j] = dot(a, b.T);
      }
  }
  ```,
  [
    \

    A's dram->l1 time cost: $n^2$ \
    B's dram->l1 time cost: $n^3 \/ "b1"$ \

    *Constraints:* \
    - $"b1" * n + "b2" * n < "l1 cache size"$ \
    - To still apply register blocking on dot \
      - $"b1" % "v1" == 0$ \
      - $"b2" % "v2" == 0$
  ]
)

putting together

```c
  dram float A[n/b1][b1/v1][n][v1];
  dram float B[n/b2][b2/v2][n][v2];

  for (int i = 0; i < n/b1; ++i) {
      l1cache float a[b1/v1][n][v1] = A[i];
      for (int j = 0; j < n/b2; ++j) {
          l1cache float b[b2/v2][n][v2] = B[j];
          for (int x = 0; x < b1/v1; ++x) {
              for (int y = 0; y < b2/v2; ++y) {
                  register float c[v1][v2] = 0;
                  for (int k = 0; k < n; ++k) {
                      register float ar[v1] = a[x][k][::];
                      register float br[v2] = b[y][k][::];
                      C += dot(ar, br.T)
                  }
              }
          }
      }
  }
```
*load cost:*  $"l1speed" * (n^3\/"v2" + n^3\/"v1") + "dramspeed" * (n^2 + n^3\/"b1")$

*memory reuse matters*

= GPU Acceleration

#grid(
  columns: (1fr, 1.8fr),

  [
    #image("img/gpu.png", width: 85%)
  ],
  [
    \
    \
    - Single instruction multiple threads (SIMT)
    - All threads executes the same code, but can take different path
    - Threads are grouped into blocks
      - Thread within the same block have shared memory
    - Blocks are grouped into a launch grid
    - A kernel executes a grid 
  ]
)

usually data come from cpu and the call gpu to do the acceleration

#text(fill: red)[data copy is expensive!]

real applications usually *keep data in gpu memory as long as possible*

- Thread level: register tiling
- Block level: shared memory tiling
