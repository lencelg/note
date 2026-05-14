---
author: lencelg from Arcadia Bay
title: note of cmu10-414/714
---

[TOC]

# Lec 2: ML Refresher / Softmax Regression
outline
- How to use mugrade
- Basics of machine learning
- Example: softmax regression

算是复习课

Three ingredients of a machine learning algorithm
- The hypothesis class
- The loss function
- An optimization method

## Loss function 1: classification error
The simplest loss function, typically use to assess the *quality* of classifiers.  

$$
\ell_{err}(h(x), y) = 
\begin{cases} 
0 & \text{if } \arg\max_i h_i(x) = y \\ 
1 & \text{otherwise} 
\end{cases}
$$

problem: the error is a bad loss function to use for *optimization*, i.e., selecting the best parameters, because it is **not differentiable**.

## Loss function 2: softmax / cross-entropy loss
exponentiating and normalizing its entries (to make them all positive and sum to one)

$$z_i = p(\text{label} = i) = \frac{\exp(h_i(x))}{\sum_{j=1}^k \exp(h_j(x))} \iff z \equiv \text{softmax}(h(x))$$

define a loss to be the (negative) log probability of the true class: this is called **softmax** or **cross-entropy loss**

$$\ell_{ce}(h(x), y) = -\log p(\text{label} = y) = -h_y(x) + \log \sum_{j=1}^k \exp(h_j(x))$$

## Optimization: gradient descent
For a matrix-input, scalar output function \( f : \mathbb{R}^{n \times k} \to \mathbb{R} \), the **gradient** is defined as the matrix of partial derivatives

$$
\nabla_\theta f(\theta) \in \mathbb{R}^{n \times k} = 
\begin{bmatrix}
\frac{\partial f(\theta)}{\partial \theta_{11}} & \cdots & \frac{\partial f(\theta)}{\partial \theta_{1k}} \\
\vdots & \ddots & \vdots \\
\frac{\partial f(\theta)}{\partial \theta_{n1}} & \cdots & \frac{\partial f(\theta)}{\partial \theta_{nk}}
\end{bmatrix}
$$

Gradient points in the direction that most increases \( f \) (locally)