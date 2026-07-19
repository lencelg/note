#import "@preview/scholia:0.1.0": *

#show: scholia

#cover("nn_zero_to_hero note", subtitle: "", author: "lencelg from Arcadia Bay", date: "2026")

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
\
then just sample it

\
````python
P = N.float()
P = P / P.sum(1, keepdim=True) # boardcast here
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
