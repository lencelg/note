# Introduction
machine learning is widely used
* web search
* spam identification
* DNA Sequence
---
machine learning algorithm
* Supervised learning
* Unsupervised learning
* Recommended system
* Reinforcement learning
## Supervised Learning 
### Regression
`predict number`<br>

example<br>
![](./img/house_price.png)
### Classification
`predict categories`<br>

example<br>
![](./img/breast_cancer)
## Unsupervised Learning
find `structure` in unlabled data<br>
* Clustering
* Dimensionality reduction
* Anomaly detection
# Linear Regression
![](./img/linear%20regression%20view)
## Cost Function
define how well the linear regression works<br>

Squared error cost function
$$ J(\theta_{0}, \theta_{1}) = \frac{1}{2m} \sum_{i = 1}^{m}(h_{\theta}(x^{i}) - y ^ {i}) ^ {2} $$

![](./img/visualization%20of%20cost%20function)
### Gradient Descent
find the `best parameters` to `minimize` the cost function<br>
![](./img/gradient%20descent%20visulization)
* local minimum
* global minimum
---
gradient descent algorithm<br>
![](./img/gradient%20descent%20algorithm)
`learning rate`<br>
![](./img/learning%20rate%20influence)
fixed learning rate
* Near a local minimum
  * Derivative becomes smaller
  * Update steps becomes smaller
---
## Multiple features
multiple feature function
$$h_{\theta}(x) = \theta_0 + \theta_1 x_1 + \theta_2 x_2 + \theta_3 x_3 + ... + \theta_n x_n$$

`Vectorlization`:

$$h_{\theta}(x) = \big[\theta_0\ \ \theta_1\ \ ... \ \ \theta_n\big] \left[\begin{matrix}x_0\\\ x_1\\\ ...\\\ x_n\end{matrix}\right]= \theta^Tx$$
### Gradient Descent
$$\theta_j := \theta_j - \alpha\frac{\partial}{\partial \theta_j}J(\theta)$$

for m >= 1:<br>
 
$$\frac{\partial}{\partial \theta_j}J(\theta) = \frac{1}{m}\sum^m_{i=1}(h\_{\theta}(x^{(i)}) - y^{(i)})x^{(i)}_j$$

notice that:

$$J(\theta) = \frac{1}{2m}\sum^m_{i=1}(h_{\theta}(x^{(i)}) - y^{(i)})^2$$