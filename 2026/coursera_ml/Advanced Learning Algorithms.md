# Neural Network
## Model representation
![](./img/structure%20of%20neural%20network)
### Forward Propagation
use previous output as current layer input to perform computation
![](./img/forward%20propagation%20example)

a simple neural network with three layer to build the Handwritten digit recognition

```python
layer_1 = Dense(units=25, activation="sigmoid")
layer_2 = Dense(units=15, activation="sigmoid")
layer_3 = Dense(units=1, activation="sigmoid")

model = Sequential([layer_1, layer_2, layer_3])
model.compile(...)

x = np.array([[0..., 245, ..., 17],
[0..., 200, ..., 184]])
y = np.array([1,0])

model.fit(x,y)
model.predict(x_new)
```

general forward progation python implementation

```python
def dense(a_in, W, b):
    units = W.shape[1]
    a_out = np.zeros(units)
    for j in range(units):
        w = W[:, j]
        z = np.dot(w,a_in) + b[j]
        z_out[j] = g(z) # g() is the activation function
    return a_out
```

gpu is good at matrix computation, use matrix mutliplication to speed up computation
```python
# vector version 
def dense(AT, W, b):
    z = np.matmul(AT, W) + b
    a_out = g(z) # again, g() is the activation function
    return a_out 
```

use `tensorflow` to implement a simple neural network

```python
import tensorflow as tf
from tensorflow.keras import Sequential
from tensorflow.keras.layers import Dense

model = Sequential([
    Dense(units=25, activation='sigmoid'),
    Dense(units=15, activation='sigmoid'),
    Dense(units=1, activation='sigmoid'),
])

from tensorflow.keras.losses import BinaryCrossentropy

model.compile(loss=BinaryCrossentropy())

model.fit(X, Y, epochs=100)
```

## Actiavtion Function

example function
* Linear activation function
* sigmoid function(slower)
* RELU(popular, fast)

![](./img/activation%20function%20example)

## Mutliclass classification
![](./img/mutliclass%20classification)

### SoftMax Regression
generalize version of logistic regression

![](./img/softmax%20activation)

Optimization trick

Adam algorithm: Adaptive Movement estimation

base idea: adjust learning rate by the gradient descent performance

---

other type of classification problem
* Mutli-lable Classification

## Backpropagation Algorithm 
![](./img/backpopagation)
![](./img/understanding%20backpagation)
# Advice for applying machine learning

Advices

* Get more traning example: solve high variance
* Try small set of feature: solve high variacne
* Try getting additional feature: solve high bias
* Try adding polynomial features: solve high bias
* Try decreasing or increasing $\lambda$

## Cross Validation  
trandition way: `split` data into `train set` and `test set`, evaluate the performance of both set

again, reference note from [here](https://github.com/bighuang624/Andrew-Ng-Machine-Learning-notes/blob/7c2bf6cf80eb41057b4d8ec789179145aabf8f94/docs/week5.md)
>假设函数可能在训练集上拟合得很好，但是由于过拟合，在实际使用中表现不佳。因此，我们将数据集划分为训练集、验证集和测试集，以评估假设函数。
>
>* 验证集：对应在训练中不断更新的参数和模型准确率；
>* 测试集：对应超参数和最终的模型准确率。
>
>或者说，**验证集用于模型选择和调参，而测试集用于估计实际使用时的泛化能力**。这样，我们不需要在利用测试集调参后，又使用测试集来估计泛化能力而得到错误的结果。
## Variance and Bias
![](./img/variance%20and%20bias)
![](./img/variance%20and%20bias%20intuition)

## Error matrics for skewed dataset
![](./img/precision%20and%20recall)

$$P = \frac{TP}{TP+FP}$$

$$R = \frac{TP}{TP+FN}$$

`F1 score`

$$F1 = \frac{2PR}{P+R}$$
## Other advice
* use `learning curve` to help choose the data
* `transfer learning` when you have small set of data

# Decision trees