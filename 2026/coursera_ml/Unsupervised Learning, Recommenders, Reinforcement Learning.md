# Support Vector Machines(SVM)
reference note from [here](https://github.com/bighuang624/Andrew-Ng-Machine-Learning-notes/blob/master/docs/week6.md?plain=1)

>   ## 支持向量机
>   ![](https://raw.githubusercontent.com/bighuang624/pic-repo/master/SVM-1.png)
>   ### 直观理解
>   支持向量机（Support Vector Machine），便是根据训练样本的分布，搜索所有可能的线性分类器中最佳的那个。因为决定直线位置的并非所有的训练数据，而是其中的两个空间**间隔（margin）**最小的两个不同类别的数据点，这种可以用来真正帮助决策最优线性分类模型的数据点叫做**支持向量（support vector）**。
>   ![](https://raw.githubusercontent.com/bighuang624/pic-repo/master/margin-and-support-vector.png)
>   ### 数学原理
>   在样本空间中，划分超平面可通过以下线性方程来描述：
>   $$w^Tx+b = 0$$
>   其中，$w = (w\_1;w\_2;...;w\_d)$ 为**法向量**，决定了超平面的方向；$b$ 为**位移项**，决定了超平面与原点之间的距离。显然，划分超平面 $(w, b)$ 可被法向量 $w$ 和位移 $b$ 确定。
>   样本空间中任意点 $x$ 到超平面 $(w,b)$ 的距离可写为
>   $$r=\frac{|w^Tx+b|}{\\|w\\|}$$
>   假设超平面 $(w,b)$ 能将训练样本正确分类，即对于 $(x\_i, y\_i) \in D$，若 $y\_i = +1$，则有 $w^Tx\_i+b>0$；若 $y\_i = -1$，则有 $w^Tx+b < 0$。令
>   $$
>   \begin{equation}
>   \begin{cases}
>   w^Tx\_i+b \geq +1, & y\_i=+1 \\\ w^Tx\_i+b \leq -1, & y\_i=-1
>   \end{cases}
>   \end{equation}
>   $$
>   总存在缩放变换使得上式成立。可以理解为构造了一个安全间距。
>   显然，**支持向量**使得上式中的等号成立。它们到超平面的距离之和即**间隔**，为
>   $$\gamma = \frac{2}{\\| w \\|}$$
>   我们的目标是找到具有最大间隔的划分超平面，即找到满足 $y\_i(w^Tx\_i+b) \geq 1, i = 1, 2, ..., m$ 的参数 $w$ 和 $b$，使得 $\gamma$ 最大，即等价于最小化 $\frac{1}{2}\\| w \\|^2$。
>   代价函数：
>   $$min_{\theta}C\sum^m_{i=1}\Big[ y^{(i)}cost_1(\theta^Tx^{(i)}) + (1-y^{(i)})cost_0(\theta^Tx^{(i)}) \Big] + \frac{1}{2}\sum^n_{j=1}\theta^2_j$$
>   正则化参数 $C$ 越大，决策边界越会精准分类，因此异常样本造成的影响也会更大。
## Kernal
use `kenal` to build `complex nonlinear classifiers`

`basic idea` as follow:

![](./img/kernal%20basic%20idea)

`intuition`: 
![](./img/kernal%20intuition)

define `similarity` as notation `f`

example kernal: `Gasussian kernal`

$$
\begin{equation}
\begin{split}
f_1 &= similarity(x, l^{(1)}) \\\ 
&= exp \Big( -\frac{\\| x-l^{(1)} \\|^2}{2\sigma^2} \Big) \\\
&= exp \Big( -\frac{\sum^n_{j=1}(x\_j - l^{(1)}_j)^2}{2\sigma^2} \Big)
\end{split}
\end{equation}
$$

other kernals
* Polynomial kernal
* String kernal
* chi-square kernal
* histogram intersection kernal

rules
>   n为特征数，m为训练样本数。
>
>   (1)如果相较m于而言，n要大许多，即训练集数据量不够支持我们训练一个复杂的非线性模型，我们选用逻辑回归模型或者不带核函数的支持向量机。
>
>   (2)如果n较小，而且m大小中等，例如n在 1-1000 之间，而在n10-10000之间，使用高斯核函数的支持向量机。
>
>   (3)如果n较小，而m较大，例如n在1-1000之间，而m大于50000，则使用支持向量机会非常慢，解决方案是创造、增加更多的特征，然后使用逻辑回归或不带核函数的支持向量机。

# Unsupervised Learning
In `supervised learning`, we have a set of `labels` and use a hypothesis function to fit them. In contrast, in `unsupervised learning`, the data comes `without labels`. We aim to find some underlying structure hidden within the data. Clustering algorithms are a typical example of unsupervised learning.

### K-Means Algorithm

`K-means` is a `classic clustering algorithm`. Its required inputs include the number of clusters $K$ and the training set $\big\{x^{(1)}, x^{(2)}, ..., x^{(m)}\big\}$.

Steps:

1. Randomly initialize $K$ cluster centroids $\mu_1, \mu_2, ..., \mu_K \in \mathbb{R}^{n}$;
2. Assign each data point in the training set to the nearest cluster centroid, ultimately forming $K$ clusters;
3. For each cluster, compute the mean of all data points within that cluster and set it as the new cluster centroid;
4. Repeat steps 2 and 3 until convergence.

If a cluster centroid ends up with no data points assigned to it, it is generally removed. Alternatively, if exactly $K$ clusters are required, a new centroid can be re-initialized randomly.

#### Optimization Objective

Define the following symbols:

- $c^{(i)}$: The index of the cluster to which $x^{(i)}$ is assigned;
- $\mu_k$: The $k$-th cluster centroid;
- $\mu_{c^{(i)}}$: The centroid of the cluster to which $x^{(i)}$ is assigned.

The cost function serving as the optimization objective is:

$$J(c^{(1)}, ... , c^{(m)}, \mu_1, ... , \mu_K) = \frac{1}{m}\sum^m_{i=1} \| x^{(i)} - \mu_{c^{(i)}} \|^2$$ 

Therefore, the K-means algorithm aims to find the parameters $c^{(i)}$ and $\mu_K$ that minimize $J(c^{(1)}, ... , c^{(m)}, \mu_1, ... , \mu_K)$.

#### Random Initialization

A better strategy is to initialize cluster centroids by randomly selecting them from the training data, rather than picking random points in the space.

The K-means algorithm can converge to different results depending on the initial points chosen, potentially getting stuck in local optima. To mitigate this, we can run the algorithm with multiple random initializations and select the clustering result that yields the smallest cost function value.

#### Choosing the Number of Clusters

Plotting the cost function value against varying $K$ and selecting the $K$ at the "elbow" point of the curve is known as the "Elbow method." However, the resulting curve does not always have a clear, distinct elbow.

## Dimensionality Reduction
propose
* `Data Compression`: less data usage and to speed up learning algorithm
* `data visualization` 

intuition

![](./img/dimensionality%20reduction%20intuition)
### PCA
`Principal Component Analysis Problem Formulation` is a common algorithm for dimensionality reduction 

reference note from [here](https://kyonhuang.top/Andrew-Ng-Machine-Learning-notes/#/week7)
>   PCA 会试图寻找一个低维的超平面，对数据进行投影，并最小化投影误差（数据点到该平面的距离）。在应用 PCA 之前，常规做法是先进行均值归一化和特征规范化。
>
>   输入样本集和降维后低维空间的维数 k 值，PCA 算法的过程为：
>
>   1. 对所有样本进行中心化：$x_i \leftarrow x_i - \frac{1}{m}\sum^m_{i=1}x_i$ ；
>   2. 计算样本的协方差矩阵 $XX^T$；
>   3. 对协方差矩阵 $XX^T$ 做特征值分解；
>   4. 取最大的 $k$ 个特征值所对应的特征向量 $w_1, w_2, ..., w_k$。
>
>   则超平面 $W = (w_1, w_2, ..., w_k)$。
>
>   #### 选取 k 值
>
>   平均投影误差平方：
>
>$$\frac{1}{m}\sum^m_{i=1} || x^{(i)} - x^{(i)}_{approx} ||^2$$
>
>
>   数据的总方差：
>
>$$\frac{1}{m}\sum^m_{i=1} || x^{(i)} ||^2$$
>
>   因此选取较小的 k 值，使得：
>
> $$\frac{\frac{1}{m}\sum^m_{i=1} || x^{(i)} - x^{(i)}_{approx} ||^2}{\frac{1}{m}\sum^m_{i=1} || x^{(i)} ||^2} \leq 0.01$$
>
>   这样，99% 的方差会被保留。
>
>   实现时，通常通过对协方差矩阵进行奇异值分解，将求得的特征值排序：$\lambda\_1、\lambda\_1、...、\lambda\_m$，然后取 k 值使：
>
>   $$\frac{\sum^k_{i=1}S_{ii}}{\sum^m_{i=1}S_{ii}} \geq 0.99$$
>
>   ### 压缩重现
>
>   $$z = U^T\_{reduce}x$$
>
>   因此我们可以从低维数据重现一个近似的高维数据：
>
>   $$x \approx x_{approx} = U_{reduce}z$$
>
>   我们称这一过程为原始数据的**重构（reconstruction）**。
>### 应用 PCA 的建议
>
>   用 PCA 可以降低数据的维度，从而使得算法运行更加高效。
>
>   1. 从训练集中只抽取输入的向量，不要标签；
>   2. 使用 PCA 得到原始数据的低维表示；
>   3. 现在我们得到一个新的训练集。
>
>   注意：从 $x^{(i)}$ 到 $z^{(i)}$ 的映射需要通过**仅在训练集上运行 PCA **得到，不过这个映射关系同样可用于验证集和测试集。
>
>   一种错误的认知是可以使用 PCA 来防止过拟合。有些人会认为因为 PCA 能够降低数据维度，因此更少的特征数意味着更小的可能性导致过拟合。实际上，PCA 会舍弃一些有价值的信息，使用 PCA 来防止过拟合不是一种好的应用。使用正则化是更好的防止过拟合的方法。
>
>   在设计机器学习系统时，你可以先在原始数据上尝试运行算法，之后根据效果来决定是否使用 PCA 来加速学习或者压缩数据以减少所需的存储空间。

## Anomaly Detection