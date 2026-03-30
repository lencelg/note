---
author: lencelg from Arcadia Bay
title: Machine Learning
---
[TOC]

# Machine Learning
divide data into three sets:
* traning set: training parameters
* validation set: tunning hyperparameter
* test set: test the generalization of model
# Naïve Bayes
take the Naïve Bayes classifier as example:

it is predict to be the highest possibility class $Y_i$ given the known feature $\forall F_i \in F$
$$\text{prediction}(f_1, \cdots, f_n) = \underset{y}{\text{argmax}}~P(Y=y \mid F_1=f_1, \ldots, F_N = f_n) \\
= \underset{y}{\text{argmax}}~P(Y=y, F_1=f_1, \ldots, F_N = f_n) \\
= \underset{y}{\text{argmax}}~P(Y=y) \prod_{i=1}^n P(F_i = f_i \mid Y=y)$$

notice that:
$$P(Y, F_1 = f_1, \dots, F_n = f_n) =
\begin{bmatrix}
P(Y = y_1, F_1 = f_1, \dots, F_n = f_n) \\
P(Y = y_2, F_1 = f_1, \dots, F_n = f_n) \\
\vdots \\
P(Y = y_k, F_1 = f_1, \dots, F_n = f_n)
\end{bmatrix}$$
$$= \begin{bmatrix}
P(Y = y_1)\prod_i P(F_i = f_i | Y = y_1) \\
P(Y = y_2)\prod_i P(F_i = f_i | Y = y_2) \\
\vdots \\
P(Y = y_k)\prod_i P(F_i = f_i | Y = y_k)
\end{bmatrix}$$

## Parameter Estimation
given a set of **sample points** or **observations** or **data**, $x_1, \ldots, x_N$, draw from a distribution **parametrized** by an unknown value $\theta$

### maximum likelihood estimation (MLE)
MLE three simplifying **assumptions**:
- Each sample is drawn from the **same distribution**.
- Each sample $x_i$ is conditionally **independent** of the others.
- All possible values of $\theta$ are equally likely before we've seen any data(AKA **uniform prior**).

the **likelihood** $\mathcal{L}(\theta)$, a function which represents the probability of having drawn our sample from our distribution. For a fixed sample $x_1, \ldots, x_N$, the likelihood is just a function of $\theta$:

$$\mathcal{L}(\theta) = P_{\theta}(x_1, \ldots, x_N)$$

re-expressed as follow:

$$\mathcal{L}(\theta) = \prod_{i=1}^N P_{\theta}(x_i)$$

to find $\theta$, notice that its first derivative with respect to each of its inputs (also known as the function's **gradient**) must be equal to zero. Hence, the maximum likelihood estimate for $\theta$ is a value that satisfies the following equation:

$$\frac{\partial}{\partial\theta} \mathcal{L}(\theta) = 0$$

## Maximum Likelihood for Naive Bayes
**spam classifier exmaple**, just apply the previous definition

$$\mathcal{L}(\theta) = \prod_{j=1}^{N_h}P(F_i = f_i^{(j)}| Y = ham) = \prod_{j=1}^{N_h}\theta^{f_i^{(j)}}(1 - \theta)^{1 - f_i^{(j)}}$$

use **monotonic transformation**, then we get:

$$\log{\mathcal{L}(\theta)} = \log\bigg(\prod_{j=1}^{N_h}\theta^{f_i^{(j)}}(1 - \theta)^{1 - f_i^{(j)}}\bigg)$$

$$= \sum_{j=1}^{N_h}\log\big(\theta^{f_i^{(j)}}(1 - \theta)^{1 - f_i^{(j)}}\big)$$

$$= \sum_{j=1}^{N_h}\log\big(\theta^{f_i^{(j)}}\big) + \sum_{j=1}^{N_h}\log\big((1 - \theta)^{1 - f_i^{(j)}}\big)$$

$$= \log(\theta)\sum_{j=1}^{N_h}f_i^{(j)} + \log(1 - \theta)\sum_{j=1}^{N_h}(1 - f_i^{(j)})$$

with **derivation**, we get:
$$\frac{\partial}{\partial\theta}\bigg(\log(\theta)\sum_{j=1}^{N_h}f_i^{(j)} + \log(1 - \theta)\sum_{j=1}^{N_h}(1 - f_i^{(j)})\bigg) = 0$$

$$\frac{1}{\theta}\sum_{j=1}^{N_h}f_i^{(j)} - \frac{1}{(1 - \theta)}\sum_{j=1}^{N_h}(1 - f_i^{(j)}) = 0$$

$$\frac{1}{\theta}\sum_{j=1}^{N_h}f_i^{(j)} = \frac{1}{(1 - \theta)}\sum_{j=1}^{N_h}(1 - f_i^{(j)})$$

$$(1 - \theta)\sum_{j=1}^{N_h}f_i^{(j)} = \theta\sum_{j=1}^{N_h}(1 - f_i^{(j)})$$

$$\sum_{j=1}^{N_h}f_i^{(j)} - \theta\sum_{j=1}^{N_h}f_i^{(j)} = \theta\sum_{j=1}^{N_h}1 - \theta\sum_{j=1}^{N_h}f_i^{(j)}$$

$$\sum_{j=1}^{N_h}f_i^{(j)} = \theta \cdot N_h$$

$$\theta = \frac{1}{N_h}\sum_{j=1}^{N_h}f_i^{(j)}$$

## Smoothing
the previous model with MLE lead to classic **overfitting** problem

**Laplace smoothing** can help alleviate the problem

Conceptually, Laplace smoothing with strength $k$ assumes having seen $k$ extra of each outcome. Hence if for a given sample your maximum likelihood estimate for an outcome $x$ that can take on $|X|$ different values from a sample of size $N$ is 

$$P_{MLE}(x) = \frac{count(x)}{N}$$

Laplace estimate with strength $k$ is

$$P_{LAP, k}(x) = \frac{count(x) + k}{N + k|X|}$$

There are two particularly **notable cases** for Laplace smoothing. The first is when $k = 0$, then 

$$P_{LAP, 0}(x) = P_{MLE}(x)$$

The second is the case where $k = \infty$. Observing a very large, infinite number of each outcome makes the results of your actual sample inconsequential and so your Laplace estimates imply that each outcome is **equally likely**. Indeed:

$$P_{LAP, \infty}(x) = \frac{1}{|X|}$$

# Perceptron
## Linear Classifiers
The basic idea of a **linear classifier** is to do classification using a linear combination of the features—a value which we call the **activation**

$$\text{activation}_w(\mathbf{x}) = h_{\mathbf{w}}(\mathbf{x}) = \sum_i w_i f_i(\mathbf{x}) = \mathbf{w}^T \mathbf{f}(\mathbf{x}) = \mathbf{w} \cdot \mathbf{f}(\mathbf{x})$$

$$\text{classify}(\mathbf{x}) = \begin{cases} + & \text{if } h_{\mathbf{w}}(\mathbf{x}) > 0 \\ - & \text{if } h_{\mathbf{w}}(\mathbf{x}) < 0 \end{cases}$$

notice that in vector:
$$h_{\mathbf{w}}(\mathbf{x}) = \mathbf{w} \cdot \mathbf{f}(\mathbf{x}) = \|\mathbf{w}\| \|\mathbf{f}(\mathbf{x})\| \cos(\theta)$$

then, we know:
$$\text{classify}(\mathbf{x}) = \begin{cases} + & \text{if } \cos(\theta) > 0 \\ - & \text{if } \cos(\theta) < 0 \end{cases}$$

with $cos(\theta)$, we know:
$$\text{classify}(\mathbf{x}) = \begin{cases} + & \text{if } \theta < \frac{\pi}{2} \text{ (i.e., when } \theta \text{ is less than 90°, or acute)} \\ - & \text{if } \theta > \frac{\pi}{2} \text{ (i.e., when } \theta \text{ is greater than 90°, or obtuse)} \end{cases}$$

we can know that **Decision Boundary** is where $\text{activation}_w(\mathbf{x}) = \mathbf{w}^T \mathbf{f}(\mathbf{x}) = 0$

![](./img/Decision%20Boundary)

for a better understanding:

![](./img/classified%20example)

# Binary Perceptron
**The Algorithm**

The perceptron algorithm works as follows:

1. Initialize all weights to 0: **w** = **0**

2. For each training sample, with features **$f(x)$** and true class label **$y^* \in \{-1, +1\}$**, do:
   
   2.1 Classify the sample using the current weights, let **y** be the class predicted by your current **w**:
   
   $$y = \text{classify}(x) = \begin{cases} +1 & \text{if } h_{\mathbf{w}}(\mathbf{x}) = \mathbf{w}^T \mathbf{f}(\mathbf{x}) > 0 \\ -1 & \text{if } h_{\mathbf{w}}(\mathbf{x}) = \mathbf{w}^T \mathbf{f}(\mathbf{x}) < 0 \end{cases}$$
   
   2.2 Compare the predicted label **y** to the true label **$y^*$**:
      - If **y** = **$y^*$**, do nothing
      - Otherwise, if **$y \neq y^*$**, then update your weights: **$w \leftarrow w + y^* f(x)$**

3. If you went through **every** training sample without having to update your weights (all samples predicted correctly), then terminate. Else, repeat step 2

visulization may help here

![](./img/binary%20perceptron)

## Bias
If you tried to implement a perceptron based on what has been mentioned thus far, you will notice one particularly unfriendly quirk. Any decision boundary that you end up drawing will be **crossing the origin**

boundary may not go through the origin, and we want to be able to draw those lines.

add bias term $b$, and the decision boundary looks like this: **w**<sup>T</sup>**f**(**x**) + **b** = 0

again, visulization may help

![](./img/bias)

## Multiclass Perceptron
in Multiclass Perceptron, we run it as single perceptron for each class, and take the one with highest score

# Linear Regression
We will denote a set of features with $\mathbf{x} \in \mathbb{R}^n$ for $n$ features, i.e., $\mathbf{x} = (x^1, \ldots, x^n)$.

linear model to predict the output:

$$h_{\mathbf{w}}(\mathbf{x}) = w_0 + w_1 x^1 + \cdots + w_n x^n$$

$$L_2$$ loss function:

$$Loss(h_{\mathbf{w}}) = \frac{1}{2} \sum_{j=1}^N L_2(y^j, h_{\mathbf{w}}(\mathbf{x}^j)) = \frac{1}{2} \sum_{j=1}^N (y^j - h_{\mathbf{w}}(\mathbf{x}^j))^2 = \frac{1}{2} \left\|\mathbf{y} - \mathbf{X} \mathbf{w}\right\|_2^2$$

note that:

$$\mathbf{y} = \begin{bmatrix}
y^1 \\
y^2 \\
\vdots \\
y^N
\end{bmatrix}, \quad
\mathbf{X} = \begin{bmatrix}
1 & x_1^1 & \cdots & x_1^n \\
1 & x^1_2 & \cdots & x^n_2 \\
\vdots & \vdots & \ddots & \vdots \\
1 & x^1_N & \cdots & x^n_N
\end{bmatrix}, \quad
\mathbf{w} = \begin{bmatrix}
w_0 \\
w_1 \\
\vdots \\
w_n
\end{bmatrix}$$

The **least squares solution** denoted with $\hat{\mathbf{w}}$ can now be derived using basic linear algebra rules. More specifically, we will find the $\hat{\mathbf{w}}$ that minimizes the loss function by differentiating the loss function and setting the derivative equal to zero.

$$\nabla_{\mathbf{w}} \frac{1}{2} \left\|\mathbf{y} - \mathbf{X} \mathbf{w}\right\|_2^2 = \nabla_{\mathbf{w}} \frac{1}{2} \left(\mathbf{y} - \mathbf{X} \mathbf{w}\right)^T \left(\mathbf{y} - \mathbf{X} \mathbf{w}\right)$$

$$= \nabla_{\mathbf{w}} \frac{1}{2} \left(\mathbf{y}^T \mathbf{y} - \mathbf{y}^T \mathbf{X} \mathbf{w} - \mathbf{w}^T \mathbf{X}^T \mathbf{y} + \mathbf{w}^T \mathbf{X}^T \mathbf{X} \mathbf{w}\right)$$

$$= \nabla_{\mathbf{w}} \frac{1}{2} \left(\mathbf{y}^T \mathbf{y} - 2 \mathbf{w}^T \mathbf{X}^T \mathbf{y} + \mathbf{w}^T \mathbf{X}^T \mathbf{X} \mathbf{w}\right) = -\mathbf{X}^T \mathbf{y} + \mathbf{X}^T \mathbf{X} \mathbf{w}$$

Setting the gradient equal to zero we obtain:

$$-\mathbf{X}^T \mathbf{y} + \mathbf{X}^T \mathbf{X} \mathbf{w} = 0 \Rightarrow \hat{\mathbf{w}} = (\mathbf{X}^T \mathbf{X})^{-1} \mathbf{X}^T \mathbf{y}$$

Having obtained the estimated vector of weights, we can now make a prediction on new unseen test data points as follows:

$$h_{\hat{\mathbf{w}}}(\mathbf{x}) = \hat{\mathbf{w}}^T \mathbf{x}$$

## Optimization
**Gradient ascent** is used if the objective is a function which we try to maximize.

**Algorithm 1:** Gradient Ascent
1. Randomly initialize $\mathbf{w}$.
2. While $\mathbf{w}$ is not converged:

$$\mathbf{w} \leftarrow \mathbf{w} + \alpha \nabla_{\mathbf{w}} f(\mathbf{w})$$

---

**Gradient descent** is used if the objective is a loss function that we are trying to minimize. Notice that this only differs from gradient ascent in that we follow the opposite direction of the gradient.

**Algorithm 2:** Gradient Descent
1. Randomly initialize $\mathbf{w}$.
2. While $\mathbf{w}$ is not converged:

$$\mathbf{w} \leftarrow \mathbf{w} - \alpha \nabla_{\mathbf{w}} f(\mathbf{w})$$

---

Linear regression has a celebrated closed form solution $\hat{\mathbf{w}} = (\mathbf{X}^T \mathbf{X})^{-1} \mathbf{X}^T \mathbf{y}$, we could have also chosen to solve for the optimal weights by running gradient descent. We'd calculate the **gradient of our loss function** as

$$\nabla_{\mathbf{w}} \text{Loss}(h_{\mathbf{w}}) = -\mathbf{X}^T \mathbf{y} + \mathbf{X}^T \mathbf{X} \mathbf{w}$$

Then, we use this gradient to write out the gradient descent algorithm for linear regression:

**Algorithm 3** : Least Squares Gradient Descent
1. Randomly initialize $\mathbf{w}$
2. While $\mathbf{w}$ is not converged:

$$\mathbf{w} \leftarrow \mathbf{w} - \alpha (-\mathbf{X}^T \mathbf{y} + \mathbf{X}^T \mathbf{X} \mathbf{w})$$

# Logistic Regression
a probability using the logistic function:

$$h_{\mathbf{w}}(\mathbf{x}) = \frac{1}{1 + e^{-\mathbf{w}^T \mathbf{x}}}$$

**derivative property**:

$$g'(z) = g(z)(1 - g(z))$$

The loss function for logistic regression is the $L2$ loss, **but no closed form solution**.

$$\text{Loss}(\mathbf{w}) = \frac{1}{2} (\mathbf{y} - h_{\mathbf{w}}(\mathbf{x}))^2$$

we estimate the unknown weights $\mathbf{w}$ via gradient descent. The gradient of the loss function with respect to the weight of coordinate $i$ is given by:

$$\frac{\partial}{\partial w_i} \frac{1}{2} (y - h_{\mathbf{w}}(\mathbf{x}))^2 = -(y - h_{\mathbf{w}}(\mathbf{x})) h_{\mathbf{w}}(\mathbf{x}) (1 - h_{\mathbf{w}}(\mathbf{x})) x_i$$
