#import "@preview/scholia:0.1.0": *

#show: scholia

#cover("nn_zero_to_hero note", subtitle: "", author: "lencelg from Arcadia Bay", date: "2026 summer")

#link("https://www.youtube.com/watch?v=VMj-3S1tku0&list=PLAqhIrjkxbuWI23v9cThsA9GvCAUhRvKZ&index=1")[#text(fill: blue, size: 20pt)[video link here to nn_zero_to_hero]]

#outline()

#pagebreak()

= micrograd

similar to cmu10-414 intorduction to backpropagation, no more note for it

= makemore

== biagram

simple start point

here is a elegant way to create 2 character since the name.txt file only contains the normal name lists, use `zip` to manager the iterator

````python
for w in words:
    for ch1, ch2 in zip(w, w[1:]):
        print(ch1, ch2)
````

but need to mark the *Start* and *End* of Sequence

````python
for w in words:
    chs = ['<S>'] + list(w) + ['<E>']
    for ch1, ch2 in zip(chs, chs[1:]):
        print(ch1, ch2)
````

=== counting

the simple idea is just count the frequency of biagrams to sample the next character

````python
b = {}
for w in words:
    chs = ['<S>'] + list(w) + ['<E>']
    for ch1, ch2 in zip(chs, chs[1:]):
        biagram = (ch1, ch2)
        b[biagram] = b.get(biagram, 0) + 1 #use get the set the default value
sorted(b.item(), key = lambda kv : -kv[1]) # descending order
````

\

use torch tensor is simpler and much more efficient
- use tensor to store the result, 26 character + 2 special character = 28 character, so 28x28tensor
- map the biagram to integer index, make a lookup table here

````python
N = torch.zeros((28, 28), dtype=torch.int32)

chars = sorted(list(set(''.join(words))))
stoi = {s:i for i,s in enumerate(chars)}
stoi['<S>'] = 26
stoi['<E>'] = 27

for w in words:
    chs = ['<S>'] + list(w) + ['<E>']
    for ch1, ch2 in zip(chs, chs[1:]):
    ix1 = stoi[ch1]
    ix2 = stoi[ch2]
    N[ix1, ix2] += 1
````

notice that
- `<S>` would not be the second character
- `<E>` would not be the first character

waste some space, use only `.` to for the special character instead of using two, detailed in video

=== sample

first convert the data to be `float`, then we can use `torch.multinormal` to sample

here is simple code for understanding
````python
g = torch.Generator().manual_seed(2147483647)   # create a generator
p = torch.rand(3, generator=g)
p = p / p.sum() # normalize
torch.multinomial(p, num_samples=100, replacement=True, generator=g)
````
#notation[

boardcast semantics
- When iterating over the dimension sizes, starting at the trailing dimension, the dimension sizes must either be equal, one of them is 1, or one of them does not exist.
]
then just sample it

\
````python
P = N.float()
# trick here to apply the change locally without adding a node in the graph
P /= P.sum(1, keepdim=True) # boardcast here
g = torch.Generator().manual_seed(2147483647)
for _ in range(50):
    out = []
    ix = 0
    while True:
        p = P[ix]
        ix = torch.multinomial(p, num_samples=1, 
                              replacement=True, generator=g).item()
        out.append(itos[ix])
        if ix == 0:
            break
    print(''.join(out))
````
the sample result is terriable because the biagram model is just terriable


\

=== evaluation

need some way to evaluate the quality of the model output, notice that $0 lt.eq "prob" lt.eq 1$

#text(fill: blue)[GOAL: maximize likelihood of the data w.r.t. model parameters (statistical modeling)]
- equivalent to maximizing the log likelihood (because log is monotonic)
- equivalent to minimizing the negative log likelihood
- equivalent to minimizing the average negative log likelihood

here is just the code for a little understanding

````python
import torch

log_likelihood = 0.0
n = 0

for w in words[:3]:
    chs = ['.'] + list(w) + ['']
    for ch1, ch2 in zip(chs, chs[1:]):
        ix1 = stoi[ch1]
        ix2 = stoi[ch2]
        prob = P[ix1, ix2]
        logprob = torch.log(prob)
        log_likelihood += logprob
        n += 1
        print(f'{ch1}{ch2}: {prob:.4f} {logprob:.4f}')

print(f'{log_likelihood=}')
nll = -log_likelihood
print(f'{nll=}')
print(f'{nll/n}')
````

for this model, we want to get a smoother loss, so add some fake counts to increase the low prob a little bit

\
=== apply to nerual network

#text(size: 10pt)[

````python
import torch
import torch.nn.functional as F

# create the dataset
xs, ys = [], []
for w in words:
    chs = ['.'] + list(w) + ['.']
    for ch1, ch2 in zip(chs, chs[1:]):
        ix1 = stoi[ch1]
        ix2 = stoi[ch2]
        xs.append(ix1)
        ys.append(ix2)

xs = torch.tensor(xs)
ys = torch.tensor(ys)
num = xs.nelement()
print('number of examples: ', num)

# initialize the 'network'
g = torch.Generator().manual_seed(2147483647)
W = torch.randn((27, 27), generator=g, requires_grad=True)   # weights

# gradient descent
for k in range(10):
    # forward pass
    # input to the network: one-hot encoding
    xenc = F.one_hot(xs, num_classes=27).float()  
    logits = xenc @ W                              # predict log-counts
    counts = logits.exp()                          # counts, equivalent to N
    probs = counts / counts.sum(1, keepdims=True)  # probabilities for next character
    loss = -probs[torch.arange(num), ys].log().mean()
    print(loss.item())

    # backward pass
    W.grad = None   # set to zero the gradient
    loss.backward()

    # update
    W.data += -0.1 * W.grad
````
]

finally comes to the sample part, only small changes

````python
# ---
# BEFORE:
#p = P[ix]
# ---
# NOW:
xenc = F.one_hot(torch.tensor([ix]), num_classes=27).float()
logits = xenc @ W # predict log-counts
````

== MLP

biagrams model(not neural version) grows exponentially

the basic idea is roughly the same as the paper

#figure(
image("img/mlp_basic_idea.png", height: 33%),
caption: [basic idea]
)

=== build dataset

\
````python
block_size = 10  # context length: characters took to predict the next one
X, Y = [], []
for w in words:
    print(w)
    context = [0] * block_size
    for ch in w + ' ':
        ix = stoi[ch]
        X.append(context)
        Y.append(ix)
        print(''.join(itos[i] for i in context), '-->', itos[ix])
        context = context[1:] + [ix]  # crop and append

X = torch.tensor(X)
Y = torch.tensor(Y)
````
\
=== shapes

reshaping is very import here

neurons' shape is [6, 100] in the example
````python
# emb is the shape of [32, 3, 2], need to change it to [32, 6]
torch.cat((emb[:, 0, :], emb[:, 1, :], emb[:, 2, :]), 1) # works, but not generalize

torch.cat(torch.unbind(emb, 1), 1) # works, but not so efficient

emb.view(emb.shape[0], 6) # efficient, only change the way to indice the understorage, or use -1 instead of emb.shape[0], which mean pytorch auto infer the dim
````

=== put it all together

\
#text(size: 9pt)[
````python
X.shape, Y.shape  # dataset
# torch.Size([32, 3]), torch.Size([32])

g = torch.Generator().manual_seed(2147483647)  # for reproducibility
C = torch.randn((27, 2), generator=g)           # embedding matrix: 27 chars -> 2-dim embedding
W1 = torch.randn((6, 100), generator=g)         # first linear layer weights
b1 = torch.randn(100, generator=g)              # first linear layer bias
W2 = torch.randn((100, 27), generator=g)        # second linear layer weights
b2 = torch.randn(27, generator=g)               # second linear layer bias
parameters = [C, W1, b1, W2, b2]

sum(p.nelement() for p in parameters)           # number of parameters in total

emb = C[X]  # (32, 3, 2)embedding of each character
h = torch.tanh(emb.view(-1, 6) @ W1 + b1) # (32, 100)hidden layer with tanh
logits = h @ W2 + b2                     # (32, 27)output logits

# counts = logits.exp()
# prob = counts / counts.sum(1, keepdims=True)
# loss = -prob[torch.arange(32), Y].log().mean()

loss = F.cross_entropy(logits, Y) 
# use built-in ones, more efficient, numerically well-bahaved
````
]

the full dataset train loop looks like this

````python
lr = 0.1
for _ in range(1000):
    # forward pass
    emb = C[X]
    h = torch.tanh(emb.view(-1, 6) @ W1 + b1
    logits = h @ W2 + b2
    loss = F.cross_entropy(logits, Y)

    # backward pass
    for p in parameters:
        p.grad = None
    loss.backward()

    # update
    for p in parameters:
        p.data += -lr * p.grad
````

we can arhieve very low loss because we can overfit the model with the neurons we haved

use the minibatch to train

````python
lr = 0.1
for _ in range(1000):
    # mini-batch construction
    ix = torch.randint(0, X.shape[0], (32,))

    # forward pass
    emb = C[X[ix]]
    h = torch.tanh(emb.view(-1, 6) @ W1 + b1
    logits = h @ W2 + b2
    loss = F.cross_entropy(logits, Y[ix])

    # backward pass
    for p in parameters:
        p.grad = None
    loss.backward()

    # update
    for p in parameters:
        p.data += -lr * p.grad
````

\
=== imporvements

\
````python
# build the dataset
block_size = 3 # context length took to predict the next one

def build_dataset(words):
  X, Y = [], []
  for w in words:

    #print(w)
    context = [0] * block_size
    for ch in w + '.':
      ix = stoi[ch]
      X.append(context)
      Y.append(ix)
      #print(''.join(itos[i] for i in context), '--->', itos[ix])
      context = context[1:] + [ix] # crop and append

  X = torch.tensor(X)
  Y = torch.tensor(Y)
  print(X.shape, Y.shape)
  return X, Y

import random
random.seed(42)
random.shuffle(words)
n1 = int(0.8*len(words))
n2 = int(0.9*len(words))

Xtr, Ytr = build_dataset(words[:n1])
Xdev, Ydev = build_dataset(words[n1:n2])
Xte, Yte = build_dataset(words[n2:])


# define the parameters
g = torch.Generator().manual_seed(2147483647) # for reproducibility
C = torch.randn((27, 10), generator=g)
W1 = torch.randn((30, 200), generator=g)
b1 = torch.randn(200, generator=g)
W2 = torch.randn((200, 27), generator=g)
b2 = torch.randn(27, generator=g)
parameters = [C, W1, b1, W2, b2]


# training 
for p in parameters:
  p.requires_grad = True

lri = []
lossi = []
stepi = []

for i in range(200000):
  
  ix = torch.randint(0, Xtr.shape[0], (32,))
  
  emb = C[Xtr[ix]] # (32, 3, 2)
  h = torch.tanh(emb.view(-1, 30) @ W1 + b1) # (32, 100)
  logits = h @ W2 + b2 # (32, 27)
  loss = F.cross_entropy(logits, Ytr[ix])
  #print(loss.item())
  
  for p in parameters:
    p.grad = None
  loss.backward()
  
  lr = 0.1 if i < 100000 else 0.01
  for p in parameters:
    p.data += -lr * p.grad

  stepi.append(i)
  lossi.append(loss.log10().item())

# training loss 
emb = C[Xtr] # (32, 3, 2)
h = torch.tanh(emb.view(-1, 30) @ W1 + b1) # (32, 100)
logits = h @ W2 + b2 # (32, 27)
tr_loss = F.cross_entropy(logits, Ytr)
tr_loss

# validation loss
emb = C[Xdev] # (32, 3, 2)
h = torch.tanh(emb.view(-1, 30) @ W1 + b1) # (32, 100)
logits = h @ W2 + b2 # (32, 27)
dev_loss = F.cross_entropy(logits, Ydev)
dev_loss

# test loss
emb = C[Xte] # (32, 3, 2)
h = torch.tanh(emb.view(-1, 30) @ W1 + b1) # (32, 100)
logits = h @ W2 + b2 # (32, 27)
ts_loss = F.cross_entropy(logits, Yte)
ts_loss

# sample from the model
g = torch.Generator().manual_seed(2147483647 + 10)

for _ in range(20):
    
    out = []
    context = [0] * block_size # initialize with all ...
    while True:
      emb = C[torch.tensor([context])] # (1,block_size,d)
      h = torch.tanh(emb.view(1, -1) @ W1 + b1)
      logits = h @ W2 + b2
      probs = F.softmax(logits, dim=1)
      ix = torch.multinomial(probs, num_samples=1, generator=g).item()
      context = context[1:] + [ix]
      out.append(ix)
      if ix == 0:
        break
    
    print(''.join(itos[i] for i in out))
````

== Acitvation, grad, batchnorm

use #text(fill: blue)[`@torch.no_grad()`] to disable gradient tracking in a function or use #text(fill: blue)[`with torch.no_grad()`] for a chunks of operations

the first batch loss is high is beacause of the way we init the weights
- we expect to be near 0, all roughly the same
- `torch.randint()` does not fit what we want
- we can decrease the weight to get more uniform weight at start up
