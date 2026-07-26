#import "@preview/noteworthy:0.4.0": *

#show: noteworthy.with(
  paper-size: "a4",
  language: "EN",
  title: "ntu ml 2022 spring note",
  date: "2026 summer",
  author: "lencelg from Arcadia Bay",
  toc-title: "Table of Contents",
  toc-depth: 3,
  watermark: "",
)

#set text(size: 8pt, font: "Hack Nerd Font")
#pagebreak()

= PyTorch Basic Usage

#definition[
  *PyTorch* —— 基于 Python 的开源机器学习框架，主打两大核心功能：
  1. $"GPU"$ 加速的张量计算（类似 NumPy，但可运行在 $"GPU"$ 上）。
  2. 自动微分机制（autograd），方便训练神经网络，无需手动计算梯度。
]

== Dataset and DataLoader

=== Dataset

需要自定义类继承 `torch.utils.data.Dataset`，并实现三个方法：

#{
  show table.cell: set text(size: 8pt)
  table(
    columns: (1.2fr, 2fr, 2fr),
    table.header(
      [方法],
      [作用],
      [注意事项],
    ),
    [`__init__(self, file)`],
    [读取数据文件，进行预处理（如归一化、切分），存储为列表或数组],
    [可以在此处将数据加载到内存（小数据集）或仅保存文件路径（大数据集）],
    [`__getitem__(self, index)`],
    [返回第 `index` 个样本（通常是一个元组 $"(特征, 标签)"$）],
    [若数据较大，可以在此处动态读取；返回类型应为 `torch.Tensor`],
    [`__len__(self)`],
    [返回数据集总大小],
    [供 DataLoader 确定迭代次数],
  )
}

代码模板：

```python
from torch.utils.data import Dataset, DataLoader

class MyDataset(Dataset):
    def __init__(self, file):
        # 读取原始数据
        self.data = ...   # shape: (N, features)
        self.labels = ... # shape: (N,)

    def __getitem__(self, idx):
        x = torch.tensor(self.data[idx], dtype=torch.float32)
        y = torch.tensor(self.labels[idx], dtype=torch.long)  # 分类用long，回归用float
        return x, y

    def __len__(self):
        return len(self.data)
```

=== DataLoader

- 作用：将 Dataset 输出的单个样本组装成#emph[批次（batch）]，支持#emph[随机打乱]和#emph[多进程并行加载]。
- 常用参数：
  - `batch_size`：每个 batch 的样本数。
  - `shuffle`：每个 epoch 是否重新打乱数据（训练集为 `True`，验证/测试集为 `False`）。
  - `num_workers`：加载数据的子进程数
  - `drop_last`：若样本总数不能被 batch_size 整除，是否丢弃最后一个不完整的 batch（训练时常设为 `True`）。

```python
train_dataset = MyDataset("train.csv")
train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True, num_workers=2)

valid_loader = DataLoader(valid_dataset, batch_size=64, shuffle=False)
```

== Tensor

=== 概念

- 标量（0 维）、向量（1 维）、矩阵（2 维）、更高维数组。
- 例如：
  - 音频：1 维（时间轴）
  - 灰度图：2 维（高 $times$ 宽）
  - RGB 图：3 维（高 $times$ 宽 $times$ 3）
  - 视频：4 维（时间 $times$ 高 $times$ 宽 $times$ 3）

=== 创建

#table(
  columns: (1fr, 3fr),
  table.header(
    [方法],
    [示例],
  ),
  [从列表],
  [`torch.tensor([[1,2],[3,4]])`],
  [从 NumPy],
  [`torch.from_numpy(np.array([1,2,3]))`],
  [全零],
  [`torch.zeros(2,3)` $arrow.r$ shape (2,3)],
  [全一],
  [`torch.ones(2,3)`],
  [随机初始化],
  [`torch.rand(2,3)`（均匀分布）、`torch.randn(2,3)`（标准正态）],
  [等差数列],
  [`torch.arange(0, 10, 2)`],
)

=== 形状操作

#table(
  columns: (1.2fr, 2fr, 2fr),
  table.header(
    [操作],
    [描述],
    [示例],
  ),
  [`x.shape` 或 `x.size()`],
    [查看形状],
    [`torch.Size([2,3])`],
  [`x.view(new_shape)`],
    [重塑（要求元素总数不变）],
    [`x.view(3,2)`],
  [`x.reshape(new_shape)`],
    [类似 view，但更灵活（会自动处理连续内存）],
    [`x.reshape(3,2)`],
  [`x.transpose(dim0, dim1)`],
    [交换两个维度],
    [`x.transpose(0,1)`],
  [`x.squeeze(dim)`],
    [删除指定维度中长度为 1 的维度],
    [`x.squeeze(1)`],
  [`x.unsqueeze(dim)`],
    [在指定位置增加一个长度为 1 的维度],
    [`x.unsqueeze(0)`],
  [`torch.cat([a,b], dim)`],
    [沿指定维度拼接（其他维度必须一致）],
    [`torch.cat([x,y,z], dim=1)`],
)

=== 数据类型

#table(
  columns: (1.2fr, 1.2fr, 1.5fr, 2fr),
  table.header(
    [数据类型],
    [dtype],
    [张量类型],
    [典型用途],
  ),
  [32位浮点],
    [`torch.float32`],
    [`torch.FloatTensor`],
    [模型参数、输入特征],
  [64位浮点],
    [`torch.float64`],
    [`torch.DoubleTensor`],
    [更高精度要求],
  [32位整数],
    [`torch.int32`],
    [`torch.IntTensor`],
    [索引],
  [64位整数],
    [`torch.long`],
    [`torch.LongTensor`],
    [分类标签],
)

#note[
  不同 dtype 的张量不能直接运算，需要转换
]

=== 设备管理

- 默认所有张量在 $"CPU"$ 上创建。
- 移动到 $"GPU"$：

```python
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
x = x.to(device)
```

- 检查 GPU 是否可用：`torch.cuda.is_available()`
- 多 GPU：`cuda:0`、`cuda:1` 等。

=== 自动梯度

- 设置 `requires_grad=True` 后，PyTorch 会追踪对该张量的所有操作，构建计算图。
- 调用 `backward()` 后，梯度累积到 `.grad` 属性中。

```python
x = torch.tensor([1., 2., 3.], requires_grad=True)
y = x.pow(2).sum()   # y = 1^2+2^2+3^2 = 14
y.backward()         # 计算梯度 dy/dx = 2x
print(x.grad)        # tensor([2., 4., 6.])
```

#note[
  每轮训练前需清空梯度（`optimizer.zero_grad()` 或手动 `x.grad.zero_()`），否则梯度会累加。
]

== torch.nn

=== 常用网络层

#{
show table.cell: set text(size: 7pt)
table(
  columns: (1.5fr, 1.8fr, 2.5fr),
  table.header(
    [层],
    [类],
    [说明],
  ),
  [全连接层（线性层）],
    [`nn.Linear(in_features, out_features)`],
    [包含权重 `weight` 和偏置 `bias`],
  [激活函数],
    [`nn.ReLU()`、`nn.Sigmoid()`、`nn.Tanh()`],
    [引入非线性],
  [二维卷积],
    [`nn.Conv2d(in_ch, out_ch, kernel_size)`],
    [图像处理],
  [池化],
    [`nn.MaxPool2d(kernel_size)`],
    [降采样],
  [Dropout],
    [`nn.Dropout(p=0.5)`],
    [防止过拟合，训练时启用，eval 时自动关闭],
  [批归一化],
    [`nn.BatchNorm1d` `nn.BatchNorm2d`],
    [加速收敛],
)

}

#pagebreak()

=== 自定义模型

can write in two forms, use `nn.Sequential`

```python
class MyModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(10, 32),
            nn.ReLU(),
            nn.Linear(32, 1)
        )
    def forward(self, x):
        return self.net(x)
```

or

```python
class MyModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(10, 32)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(32, 1)

    def forward(self, x):
        x = self.fc1(x)
        x = self.relu(x)
        x = self.fc2(x)
        return x
```

=== Loss Function

#table(
  columns: (1.5fr, 2fr, 2.5fr),
  table.header(
    [任务类型],
    [常用损失函数],
    [torch api],
  ),
  [回归（预测连续值）],
    [均方误差],
    [`nn.MSELoss()`],
  [二分类],
    [二元交叉熵],
    [`nn.BCELoss()`（配合 Sigmoid）、`nn.BCEWithLogitsLoss()`（内部包含 Sigmoid）],
  [多分类],
    [交叉熵],
    [`nn.CrossEntropyLoss()`（内部包含 Softmax，输入为 logits，标签为类别索引）],
)

#example[
  ```python
  criterion = nn.CrossEntropyLoss()
  loss = criterion(model_output, labels)   # model_output shape: (batch, num_classes)
  ```
]

== torch.optim

根据梯度更新模型参数，常用优化算法有 SGD、Adam、RMSprop 等。

=== define optim

```python
optimizer = torch.optim.SGD(model.parameters(), lr=0.01, momentum=0.9)
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
```

basic three line of code

```python
optimizer.zero_grad()
loss.backward()
optimizer.step()
```

== Full Example

```python
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = MyModel().to(device)
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

n_epochs = 20
for epoch in range(n_epochs):
    model.train()               # set to train mode（influencing Dropout/BatchNorm）
    total_train_loss = 0
    for batch_x, batch_y in train_loader:
        batch_x, batch_y = batch_x.to(device), batch_y.to(device)
        optimizer.zero_grad()
        pred = model(batch_x)
        loss = criterion(pred, batch_y)
        loss.backward()
        optimizer.step()
        total_train_loss += loss.item() * batch_x.size(0)
    avg_train_loss = total_train_loss / len(train_loader.dataset)
    print(f"Epoch {epoch+1}, Train Loss: {avg_train_loss:.4f}")

# validation part
model.eval()                # switch to eval mode
total_val_loss = 0
with torch.no_grad():
    for batch_x, batch_y in val_loader:
        batch_x, batch_y = batch_x.to(device), batch_y.to(device)
        pred = model(batch_x)
        loss = criterion(pred, batch_y)
        total_val_loss += loss.item() * batch_x.size(0)
avg_val_loss = total_val_loss / len(val_loader.dataset)

# test part
model.eval()
all_preds = []
with torch.no_grad():
    for batch_x in test_loader:
        batch_x = batch_x.to(device)
        pred = model(batch_x)
        all_preds.append(pred.cpu())
final_preds = torch.cat(all_preds, dim=0)   # (total_samples, num_classes)

# save model
torch.save(model.state_dict(), "model_weights.pth")

# load model
model = MyModel()
model.load_state_dict(torch.load("model_weights.pth"))
model.to(device)
model.eval()

# another way to save model
torch.save(model, "whole_model.pth")
model = torch.load("whole_model.pth")

# save checkpoint（包含优化器状态，用于恢复训练）
checkpoint = {
    'epoch': epoch,
    'model_state_dict': model.state_dict(),
    'optimizer_state_dict': optimizer.state_dict(),
    'loss': loss,
}
torch.save(checkpoint, "checkpoint.pth")

# recover checkpoint
checkpoint = torch.load("checkpoint.pth")
model.load_state_dict(checkpoint['model_state_dict'])
optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
start_epoch = checkpoint['epoch'] + 1
```

== Debug Suggestion

#table(
  columns: (1.8fr, 2fr, 2.5fr),
  table.header(
    [错误现象],
    [可能原因],
    [解决办法],
  ),
  [损失不下降],
    [学习率过大/过小、梯度消失/爆炸],
    [调整 lr，检查梯度（`torch.norm(param.grad)`）],
  [验证损失远高于训练损失],
    [过拟合],
    [增加 Dropout、正则化、数据增强或减小模型容量],
  [CUDA out of memory],
    [batch_size 太大或模型太大],
    [减小 batch_size，使用梯度累积，或切换到更大显存的 GPU],
)

= General Guide for HW

#figure(
  image("img/hw_guide.png", width: 65%),
  caption: [hw_guide],
)

= Optimizer

== SGD（随机梯度下降）

- *原理*：每次从训练集中随机抽取一个样本（或一个小批量）计算梯度，并沿梯度负方向更新参数。
  $ w <- w - eta dot nabla L(w) $
- *优点*：计算快、内存小、可在线学习。
- *缺点*：收敛路径震荡大，易陷入局部最优或鞍点；对学习率 $eta$ 敏感。
- *适用*：数据量大、对收敛速度要求不苛刻时。

== SGD with Momentum（带动量的SGD）

- *原理*：引入动量项（历史梯度的指数加权平均），让更新方向既依赖当前梯度，也依赖历史动量，从而加速收敛并抑制震荡。
  $ v <- beta v + eta dot nabla L(w) ,quad w <- w - v $
- *优点*：加速穿过平坦区域，减少震荡，提高收敛稳定性。
- *缺点*：引入额外的超参数 $beta$（通常0.9），仍需手动调整学习率。
- *适用*：大多数标准任务，尤其是损失曲面有较长平缓区域时。

== Adagrad（自适应梯度算法）

- *原理*：对每个参数使用不同的学习率 – 梯度累计平方和大的参数学习率减小快，反之则学习率保持较大。
  $ w_i <- w_i - frac(eta, sqrt(G_(i i)+epsilon)) nabla_(w_i) L $
- *优点*：适合稀疏特征（如词嵌入），无需手动调整全局学习率。
- *缺点*：学习率单调递减，后期易过早停止学习。
- *适用*：稀疏数据、自然语言处理中词频不均的场景。

== RMSProp（均方根传播）

- *原理*：在Adagrad基础上引入指数衰减移动平均，避免学习率快速归零。
  $ E[g^2]_t <- beta E[g^2]_(t-1) + (1-beta)(nabla L)^2 $
  $ w <- w - frac(eta, sqrt(E[g^2]_t + epsilon)) nabla L $
- *优点*：解决了Adagrad后期学习率过小的问题，适合非平稳目标。
- *缺点*：仍需要设定初始学习率 $eta$ 和衰减率 $beta$（常用0.9）。
- *适用*：循环神经网络（RNN）、强化学习等非平稳或在线任务。

#pagebreak()

== Adam（自适应矩估计）

- *原理*：结合动量（一阶矩）和RMSProp（二阶矩），并加入偏差修正。

$ m_t = beta_1 m_(t-1) + (1-beta_1) g_t ,quad v_t = beta_2 v_(t-1) + (1-beta_2) g_t^2 $

$ hat(m)_t = m_t / (1 - beta_1^t) ,quad hat(v)_t = v_t / (1 - beta_2^t) $

$ w <- w - eta dot hat(m)_t / (sqrt(hat(v)_t) + epsilon) $

- *优点*：收敛快、对超参数不敏感（默认 $eta = 0.001$，$beta_1 = 0.9$，$beta_2 = 0.999$），效果好。
- *缺点*：在某些情况下可能泛化性能略差于带动量的SGD；需要更多显存存储动量。
- *适用*：绝大多数现代深度学习任务的默认首选。

problem with adam

#table(
  columns: (1.8fr, 3.5fr),
  table.header(
    [statement],
    [explaination],
  ),
  [最大移动距离上界 $approx sqrt(1/(1-beta_2)) eta$],
    [Adam 单步更新不可能无限大，被二阶动量历史与 $beta_2$ 限制。],
  [非信息性梯度贡献更大],
    [由于有效学习率 $prop 1/sqrt(v_t)$，微小梯度使 $v_t$ 变小 $arrow.r$ 步长反而变大，造成不利影响。],
)

== Comparison Table

#table(
  columns: (1.5fr, 1.2fr, 1fr, 2.2fr, 1.2fr),
  table.header(
    [算法],
    [自适应学习率],
    [动量],
    [适用场景],
    [收敛速度],
  ),
  [SGD],
    [否],
    [否],
    [简单模型、数据流],
    [慢],
  [SGD+Momentum],
    [否],
    [是],
    [标准任务、连续优化],
    [较快],
  [Adagrad],
    [是],
    [否],
    [稀疏特征（NLP、推荐系统）],
    [早期快后期慢],
  [RMSProp],
    [是],
    [否],
    [RNN、非平稳目标],
    [快],
  [Adam],
    [是],
    [是],
    [大多数深度学习任务（默认推荐）],
    [很快],
)

== AMSGrad

#note[
  AMSGrad不适合实际使用。
]

核心思想很简单：通过记录历史二阶动量的最大值并用于参数更新，确保了学习率的单调递减，从而在数学上保证了算法的收敛性。

$ g_t = nabla_theta J(theta_t) $

$ m_t = beta_1 m_(t-1) + (1-beta_1) g_t $

$ v_t = beta_2 v_(t-1) + (1-beta_2) g_t^2 $

$ hat(m)_t = m_t / (1 - beta_1^t) ,quad tilde(v)_t = v_t / (1 - beta_2^t) $

$ hat(v)_t = max(hat(v)_(t-1),; tilde(v)_t) ,quad "where " hat(v)_0 = 0 $

$ theta_(t+1) = theta_t - eta dot frac(hat(m)_t, sqrt(hat(v)_t) + epsilon) $

AMSGrad 的实际表现一般，不如原本的Adam。

本质还是 monotonically decreasing learning rate，没有真正解决问题。

== AdaBound

#note[
  AdaBound在很多库很久都没有更新维护了，实际使用存在争议，表现落伍于后续的优化器。
]

AdaBound 的核心思想是利用#emph[动态边界]机制。

$ g_t = nabla J(theta_(t-1)) $

$ m_t = beta_1 m_(t-1) + (1 - beta_1) g_t $

$ v_t = beta_2 v_(t-1) + (1 - beta_2) g_t^2 $

$ theta_t = theta_(t-1) - eta dot frac(m_t, sqrt(v_t) + epsilon) $

#pagebreak()

AdaBound 的核心公式如下：

$ hat(eta)_t = "Clip"(frac(alpha, sqrt(V_t)), eta_l(t), eta_u(t)) $

- $alpha$ 是初始学习率。
- $V_t = "diag"(v_t)$，即由二阶动量 $v_t$ 构成的对角矩阵，是Adam的自适应部分。
- $eta_l(t)$ 和 $eta_u(t)$ 是动态变化的下界和上界（一般是经验法则界限的，"not adaptive at all"）。

最后更新：

$ theta_(t+1) = theta_t - hat(eta)_t dot.o m_t $

== Something May Helps with Optimization

- Data Shuffing
- Dropout
- Gradient noise
- Warm-up
- Fine-tuning
- Normalization
- Regularization

= Lec 3

深度学习本质是在拟合一个函数。

于是神经网络的设计可以成 shallow，也可以是 deep networks。

但是一个直观的思想就是 deep networks 可以复用前面学习到的某些特征，从而比 shallow 的网络设计的参数量少得多。

And...

- Deep networks outperforms shallow ones when the required functions are complex and regular.
- Deep is exponentially better than shallow even when $v = x^2$.

== Spatial Transformer Layer

Spatial Transformer Layer（空间变换器层）是深度学习网络中的一个可微模块，旨在让网络主动地、动态地对输入数据（图像或特征图）进行空间变换，例如平移、旋转、缩放或裁剪。

传统的卷积神经网络（CNN）通过卷积和池化操作具有一定的#emph[局部平移不变性]，即能容忍目标在小范围内移动。

然而，CNN本身并#emph[不具备]尺度不变性（scaling invariant）和旋转不变性（rotation invariant）。例如，一个被旋转或缩放的物体，对CNN来说可能是完全不同的东西。

image transformation 本质可以看作是原图片到目标图片的映射，具体来说是采样点的映射。

#figure(
  image("img/spatial_transformer_layer.png", width: 100%),
  caption: [spatial_transformer_layer],
)

Spatial Transformer Layer由三个顺序执行的组件构成：

1. *参数预测（Localisation Net）*
   - 它的任务是接收输入的特征图（$U$），并#emph[预测出空间变换所需的参数（$theta$）（如上图二维的 $a, b, c, d, e, f$）]。
   - 根据不同的输入内容，动态地生成最适合它的变换参数。

2. *坐标映射（Grid Generator）*
   - 在输入特征图（$U$）上#emph[计算出采样点的坐标网格]。

3. *像素采集（Sampler）*
   - 这是最后一步，它根据第二步生成的坐标网格，#emph[从输入特征图（$U$）中采集像素值，从而生成最终的输出特征图（$V$）]。
   - 由于映射后的坐标通常是#emph[小数]，无法直接对应到输入图上的整数像素点，因此这一步需要使用 #emph[插值（interpolation）]（如双线性插值）来计算该位置的像素值。
   - 使用插值可以使得整个变换过程是#emph[可微分的]，这意味着损失函数的梯度可以反向传播，从而端到端地训练整个网络，包括用来预测变换参数的 Localisation Net。

#pagebreak()

下面是 slide 关于 interpolation 的介绍，作为补充：

#figure(
  image("img/interpolation.png", width: 60%),
  caption: [interpolation],
)

= Lec 4

== Self-Attention

对于序列的数据输入，数据的顺序本身存在信息，我们需要另外的设计来学习这种信息。

Vectors sets as input
- One-hot Encoding（every vector do not have relationship with other vectors）
- Word Embedding

then comes to self-attention.

Self-Attention

$ "Attention"(Q, K, V) = "softmax"( (Q K^T) / sqrt(d_k) ) V $

single explanation as follow:

- *点积*：计算 $Q times K^T$。得到的是一个 $N times N$ 的矩阵（$N$ 是序列长度）。里面的数值 $(i, j)$ 代表“第 $i$ 个词”对“第 $j$ 个词”的原始关注强度（相似度）。
- *缩放*：除以 $sqrt(d_k)$。因为维度 $d_k$ 很大时，点积数值会变得很大，导致 Softmax 落入梯度极小的区域，除以根号维度是为了把方差拉回 1。
- *归一化*：对 $N times N$ 矩阵的每一行做 Softmax。现在每一行的数值变成了概率，和为 1。这意味着：“对于当前的词 $i$，它把 100% 的注意力权重，按重要性分摊给了所有词（包括它自己）。”
- *加权求和*：将这个概率矩阵乘以 $V$。每个词的新向量，都融合了#emph[全局所有词]的信息，且融合的比例由相关性决定。

but might have problems:

- *Position 盲区*：在计算步骤 1（$Q times K^T$）时，只涉及向量的点积。点积是#emph[符合交换律]的。
- *结论*：Self-Attention 本身把输入当作#emph[“无序的一袋水果”]，不关心位置信息。

code for learning the idea:

```python
# x (batch, seq_len, dim)
# x_pe = x + pe (pe stands for position encoding vector)

Q = x_pe @ W_q
K = x_pe @ W_k
V = x_pe @ W_v

# attn_weights shape : (batch, seq_len, seq_len)
attn_weights = softmax(Q @ K.transpose(-2, -1) / sqrt(dk))

# attn_weights 矩阵的第 i 行，只依赖于 Q_i 和所有 K_j
```

== Multi-head Self-Attention

简单理解：

- *单头注意力*：只能整体地算出一个注意力权重。
- *多头注意力*：每个头专注某一部分，各司其职。最后，模型把各个头#emph[汇总拼接]，得到信息丰富的向量。

#pagebreak()

单头的公式：$ "Attention"(Q, K, V) = "softmax"( (Q K^T) / sqrt(d_k) ) V $

多头数学定义为：

$ "MultiHead"(Q, K, V) = "Concathead_1, head_2, ..., head_h)" W^O $

$ "where head"_i eq "Attention"(Q W_i^Q, K W_i^K, V W_i^V) $

3 个投影矩阵 $W_i^Q, W_i^K, W_i^V$：

- 假设词嵌入维度是 $d_("model") = 512$。
- 用 $h = 8$ 个头。
- 每个头的维度 $d_k = d_v = d_("model") / h = 512 / 8 = 64$。

code of the idea:

```python
# x: (batch_size, seq_len, d_model=512)
# 多头数: 8, 每个头维度: 64

# 1. 线性变换并拆分为多组
# W_q, W_k, W_v 形状均为 (512, 512)
Q = x @ W_q  # (batch, seq_len, 512)
# 关键：把最后一维拆成 (8, 64)，并交换维度
Q = Q.view(batch_size, seq_len, 8, 64).transpose(1, 2)  
# 现在 Q 的形状: (batch_size, 8, seq_len, 64)
# 这就实现了 8 个头并行计算，互不干扰！

# 2. 计算缩放点积注意力（此时在 64 维空间中算）
scores = (Q @ K.transpose(-2,-1)) / sqrt(64)
# 得到 attn 形状: (batch, 8, seq_len, seq_len)

# 3. 加权求和后，把 8 个头拼回去
# 形状变回 (batch, seq_len, 512)
# 4. 最后过一层输出投影 W_o (512, 512)
```

== RNN

=== 隐状态（Hidden State）

假设输入序列为 $x_1, x_2, ..., x_T$，RNN 的核心公式：

$ h_t = tanh(W_(h h) dot h_(t-1) + W_(x h) dot x_t + b) $

$ y_t = W_(h y) dot h_t $

- $h_t$：#emph[当前时刻的“记忆摘要”]。它包含了当前输入 $x_t$ 的特征，以及过去所有信息 $h_(t-1)$ 的“压缩遗产”。
- *位置信息的体现*：因为 $h_t$ 是由 $h_(t-1)$ 推导而来的，而 $h_(t-1)$ 又是由 $h_(t-2)$ 推导而来……这形成了一个#emph[一阶马尔可夫链]。$h_t$ 内部的数值分布，天然携带了“步数 $t$”的累积效应。

=== Simple Architecture

#figure(
  image("img/classic.png", width: 70%),
  caption: [classic RNN],
)

#pagebreak()

Bidirectional RNN，BRNN看到的信息更多一些。

#figure(
  image("img/BRNN.png", width: 70%),
  caption: [BRNN],
)

=== Problem: Vanishing / Exploding Gradients

- *反向传播*（BPTT，时间反向传播）：为了更新网络，梯度需要从最后一个词 $t=T$ 一路“倒推”回第一个词 $t=1$。
- *连乘效应*：梯度传播路径上要乘以无数个 $W_(h h)$ 的幂。如果 $W_(h h)$ 的特征值小于 1，梯度越乘越小，最终变为 0（梯度消失）；如果大于 1，梯度指数级爆炸。
- *后果*：RNN 只能有效记住#emph[最近 10~20 个词]。

*无法并行计算*

因为 $h_t$ 的计算必须依赖 $h_(t-1)$ 的结果，所以 #emph[RNN 必须串行执行]。

=== LSTM 与 GRU

problem: 梯度消失带来的“短期记忆”问题。

LSTM（长短期记忆网络）和 GRU。

- *LSTM 的 3 道门*：不再简单地“传递 $h_t$”，而是引入了一个#emph[细胞状态（Cell State）$C_t$]
  - *遗忘门*：决定丢弃过去记忆中的多少信息。
  - *输入门*：决定当前输入的信息有多少写入记忆。
  - *输出门*：决定当前时刻输出多少记忆。
- *效果*：LSTM 可以记住 100~200 个词的距离，但依然无法处理超长篇章，无法并行化。

architecture as follow:

#figure(
  image("img/LSTM.png", width: 80%),
  caption: [LSTM],
)

#emph[LSTM 为什么能解决 RNN 的“梯度消失”？]

- 在原始 RNN 中，梯度回传时需反复乘以矩阵 $W_(h h)$，连乘导致梯度指数级衰减。
- 在 LSTM 中，梯度从 $C_t$ 回传到 $C_(t-1)$ 时，导数公式为：$frac(partial C_t, partial C_(t-1)) = f_t$（忽略 $tilde(C)_t$ 的细微贡献）。

反向传播时，梯度只需要乘以遗忘门 $f_t$ 的值（一个 0~1 的标量或向量），而不是乘以巨大的矩阵 $W$！

当模型训练学会把 $f_t$ 设得接近 1 时，梯度就能像“滑滑梯”一样无损地从序列末尾传到开头。这就是 LSTM 能记住 100~200 个词甚至更长依赖的根本数学原理。

=== comparsion table
#table(
  columns: (1.2fr, 1.8fr, 2.5fr),
  table.header(
    [维度],
    [RNN / LSTM],
    [Transformer (Self-Attention)],
  ),
  [位置信息],
    [隐式自带（时间步顺序决定，无需额外编码）],
    [显式附加（必须加 Positional Encoding 或 RoPE）],
  [感知范围],
    [局部优先（梯度衰减导致长距离遗忘）],
    [全局平等（任意两个词直接关联，距离为 1）],
  [计算模式],
    [串行],
    [并行],
  [复杂度],
    [$O(T dot d^2)$（线性于长度）],
    [$O(T^2 dot d)$（平方于长度，长文本显存爆炸）],
  [长文本优势],
    [长度无限（理论上），但记不住],
    [长度受限（如 4k/128k），但记得牢],
)

== GNN

reason to use GNN
- input data's structure is graph
- find the underlying structure and relationship between data(implicit graph)

need to lable data, but not all data are labeled(expensive!)

#text(fill: red)[problem: ] need some ways to make unlabeled note learn the structure from its neighbors

#text(fill: blue)[solution:]
- spatial-based convolution: generalize the concept of convolution
- spectral-based convolution: back to the definition of convolution in signal processing(fourier warning!)

=== spatial-based convolution

#let term(title, desc) = [
  #strong(title): #desc
]

#term("Aggregate", "用 neighbor feature update 下一層的 hidden state")

#term("Readout", "把所有 nodes 的 feature 集合起來代表整個 graph")

#figure(
image("img/spatial.png"),
caption: [update $h^1_3$ with neighbors $h^0_0,h^0_2,h^0_4$ and its own feature]
)

Aggregate
- direcit sum
- weight sum(mean)
- self-learned weight sum

=== spectral-based convolution

#figure(
image("img/spectral.png", width: 50%),
caption: [processes of spectral-based convolution]
)

threee part
- Fourier transform
- Multiplication
- inverse Fourier transform

no more details about it

#pagebreak()

= Lec 5

== batch normalization introduction

\
*Feature Normalization*

For each dimension $i$:
- mean: $m_i$
- standard deviation: $sigma_i$

#align(center)[
  $ tilde(x)_i^r <- (x_i^r - m_i) / sigma_i $
]

#text(fill: blue)[after normalization:] The means of all dims are 0, and the variances are all 1.

In general, feature normalization makes gradient descent converge faster.

#text(fill: red)[problem: ] the representation power of network might reduce

#text(fill: blue)[solution: ]scale and shift

\
batch normalization three steps
- *Calculate Batch Statistics*: For a given mini-batch of data, the layer computes the mean ($mu_B$) and variance ($sigma_B^2$).
- *Normalize*: It subtracts the batch mean and divides by the square root of the variance plus a small constant (ε) for numerical stability.
- *Scale and Shift*: To preserve the network's representational power, it applies learnable parameters, scale ($gamma$) and shift ($beta$), so the network can "undo" the normalization if a different distribution is optimal.
#figure(
image("img/batch_normalization.png",height: 39%),
caption: [batch normalization example]
)


=== testing
we do not always have #text(fill: red)[batch] at testing time to compute the mean and variance

#text(fill: blue)[solution: ] computing the *moving average* of $mu$ and $gamma$ of the batches during training

e.g. #align(center)[we get $mu^1$, $mu^2$, $mu^3$, ...,$mu^t$]

#align(center)[then compute $mu arrow.l p mu plus (1 - p) mu^t$]

#pagebreak()

== Transformer

#grid(
  columns: (2fr, 1.0fr),
  [
seq2seq usage
- Speech Recognition
- Speech Translation
- Machine Translation

architecture
- encoder
- decoder
  ],
  [
    #figure(
image("img/seq2seq_simple.png", width: 100%),
caption: [simple idea]
    )
  ]
)

old friend transformer, details are not fully recorded here

#figure(
image("img/fullarch.png", height: 55%),
caption: [encoder and decoder]
)

masked self-attention
- self-attention具有全局野, 这是矩阵乘法导致的，于是输出第一个token的时候会用到后面的信息，这在*生成式任务*是不可以的, 存在*信息泄漏*
- mask 可以介入位置，使得满足限制

\
\
#text(fill: red)[no note for other content of this week]
- main class
  - all kinds of atttention
- extra class
  - NAT model
  - pointer network

#pagebreak()

= Lec 6
== GAN
basic idea: #text(fill: red)[network as generator]

#figure(
image("img/basic_idea.png", width: 50%),
caption: [GAN basic idea]
)

#text(fill: red)[why we need distribution here?]

answer: the same input has many different output, bring #text(fill: blue)[creativity] for model

\
two main part of GAN
- generator
- discriminator

discriminator learns to assign high score to real objects and low score to generated objects
#algorithm[ *GAN algorithm*
  
  - initialize generator and discriminator
  - in each training iteration:
    - Fix generator G and update discriminator D
    - Fix discriminator D and update generator G
]

\
#text(fill: blue)[generator objective]: minimize $G^star eq arg limits(min)_G italic("Div") (P_G, P_"data")$

although we do not know the distribution of $P_G$ and $P_"data"$, we can #text(fill: blue)[sample] from them

\
for #text(fill: blue)[discriminator D], objective function is

$ D^* = "arg" max_D V(D, G) $

$ V(D, G) = E_(y ~ P_"data") [log D(y)] + E_(y ~ P_G) [log (1 - D(y))] $

$D^star$ is actually the negative cross entropy, so we are actually wants to minimize the corss entropy

后面介绍了一些不同的divergence, 不多做介绍

\

evaluation metrics
- FID（Fréchet Inception Distance）
- IS（Inception Score）
- Precision and Recall

#pagebreak()

= Lec 6.5
== BERT series

#figure(
image("img/self-supervised.png", width: 50%),
caption: [difference between supervised and self-supervised]
)

the system learns to predict part of its input from other parts of its output

to make use of self-supervised
- *Using mask*: we can mask randomly some input
- *Next sentence prediction(#text(fill: red)[not so helpful])*: add special token [CLS] and [SEP]
- Robustly optimized BERT approach(RoBERTa)
- SOP: sentence order prediction

\
but wait a minute, why BERT works?(simple intuition from class)
- words embedding and similarity between works in context
- Zero-shot Reading Comprehension
- Cross-lingual Alignment

== PLMs
=== background
Pre-trained Language Models (PLMs)/ 預訓練語言模型
- Fine-tuning PLMs on downstream tasks achieves exceptional performance on many kinds of downstream tasks

PLMs is very successful in many tasks

=== problem
- *Data Scarcity* in downstream tasks
- The PLM is *too big*, and they are still getting bigger

=== solution
==== Data Scarcity
Data-Efficient Fine-tuning: Prompt tuning

\
need three thing for Prompt tuning
- A prompt template
- A PLM
- A verbalizer
\
\
\

*prompt template*: convert data points into a natural language prompt

#figure(
image("img/prompt_template.png", width: 93%),
caption: [prompt template example]
)

#pagebreak()
*verbalizer*: A  mapping between the label and the vocabulary

#figure(
image("img/verbalizer.png", width: 50%),
caption: [verbalizer example]
)

prompt tuning 和传统的 Standard Fine-tuning 不一样，这里不做详细笔记

Prompt tuning has better performance than Standard Fine-tuning under data scarcity because 
- it incorporates human knowledge
- it intorduces no new parameters

\
*Few-shot learning*

in addition to task description, model get a few example on the task, *No gradient updates are performed.*

*LM-BFF*: better few-shot fine-tuning of language model
- core concept: #text(fill: red)[prompt] + demonstration


\
*Semi-supervised learning*: we have some labeled training data and a large amount of unlabeled data

method: Pattern-Exploiting Training(PET)
#algorithm[PET] 
+ Use different prompts and verbalizer to prompt-tune different PLMs on the labeled data
+ Predict the unlabeled dataset and combine the predictions from different models
+ Use a PLM with classifier head to train on the soft-labeled data set 

\
*Zero-shot*: inference on the downstream task without any training data
- example: just our daily use of LLM and ai agent

==== model too large

- Pre-train a large model, but use a samller model for the downstream problem
- share parameters among the transformer layers

\
recall that standard Fine-tuning is actually modifying the hidden representation  of PLM to perform downstream tasks

we can use *special submodules(adapter)* to modify the hidden representations

#figure(
image("img/adapter.png", height: 25%),
caption: [adapter]
)

during Fine-tuning, only update the adapters and the classifier head

#pagebreak()

LoRA: Low-Rank Adapation of Large Language Models

#figure(
image("img/LoRA.png", width: 60%),
caption: [LoRA]
)

\

Prefix Tuning: Insert trainable prefix in each layer(transformer layer)

Only the prefix (key and value) are updated during fine-tuning

\

Soft Prompting
- Prepend the prefix embedding at the input laye

\
Early exit
- Reduce the number of layers used during inference
- Add a classifier at each layer
