#  Neural Networks
## Activation Functions
* step function
* logistic sigmoid 
* rectified linear unit (ReLU)
## Gradient Descent
*   Start with a random choice of weights. 
    >*    Repeat:
    >>*        Calculate the gradient based on all data points that will lead to decreasing loss. 
    >>*        Ultimately, the gradient is a vector (a sequence of numbers).
    >>*        Update weights according to the gradient.
## Multilayer Neural Networks
## Backpropagation
* Calculate error for output layer
    >*    For each layer, starting with output layer and moving inwards towards earliest  hidden layer:
    >>*   Propagate error back one layer. In other words, the current layer that’s being considered sends the errors to the preceding layer.
    >>*   Update weights.
* dropout (Overfitting problem) 
### Computer Vision
* Image Convolution
* Pooling , Max-Pooling
### Convolutional Neural Networks
### Recurrent Neural Networks
