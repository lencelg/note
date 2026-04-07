---
title: HMMs
author: lencelg from Arcadia Bay
---
[TOC]
# Markov Models
* Value of X at a given time is called the **state** (usually discrete, finite)
* The *transition model* $P(X_t | X_{t-1})$ specifies how the state evolves over time
* *Stationarity* assumption: transition probabilities are the same at all times
* *Markov* assumption: “future is independent of the past given the present”
  * $X_{t+1}$ is independent of $X_0,…, X_{t-1}$ given $X_t$
  * This is a *first-order Markov model* (a *k*th-order model allows dependencies on *k* earlier steps)
* Joint distribution $P(X_0,…, X_T)$ = $P(X_0)\prod_{t} P(X_t | X_{t-1})$

![](./img/makrov%20models)

## The Mini-Forward Algorithm
By properties of marginalization, we know that

$$P(W_{i+1}) = \sum_{w_i}P(w_i, W_{i+1})$$

By the chain rule, we can re-express this as follows:

<p>
</p>

$$\boxed{P(W_{i+1}) = \sum_{w_i}P(W_{i+1}|w_i)P(w_i)}$$

<p>
</p>

| $$ W_0 $$ | $$ P(W_0) $$ |
| :-------: | :----------: |
|    sun    |     0.8      |
|   rain    |     0.2      |

| $$ W_{i+1} $$ | $$ W_i $$ | $$ P(W_{i+1} \| W_i) $$ |
| :------------: | :-------: | :----------------------: |
|      sun       |    sun    |           0.6            |
|      rain      |    sun    |           0.4            |
|      sun       |   rain    |           0.1            |
|      rain      |   rain    |           0.9            |

Using the mini-forward algorithm, we can compute $ P(W_1) $ as follows:

<p></p>

$P(W_1 = sun) = \sum_{w_0}P(W_1 = sun | w_0)P(w_0)$ $= P(W_1 = sun | W_0 = sun)P(W_0 = sun) + P(W_1 = sun | W_0 = rain)P(W_0 = rain)$ $= 0.6 \cdot 0.8 + 0.1 \cdot 0.2 = \boxed{0.5}$

<p></p>

$P(W_1 = rain) = \sum_{w_0}P(W_1 = rain | w_0)P(w_0)$ $= P(W_1 = rain | W_0 = sun)P(W_0 = sun) + P(W_1 = rain | W_0 = rain)P(W_0 = rain)$$ $$= 0.4 \cdot 0.8 + 0.9 \cdot 0.2 = \boxed{0.5}$

Hence our distribution for $P(W_1)$ is:

| **$$ W_1 $$** | **$$ P(W_1) $$** |
| :-----------: | :--------------: |
|      sun      |       0.5        |
|     rain      |       0.5        |

## Stationary Distrubution
compute the **stationary distribution** of the weather. As the name suggests, the stationary distribution is one that remains the same after the passage of time, i.e.

$$P(W_{t+1}) = P(W_t)$$

We can compute these converged probabilities of being in a given state by combining the above equivalence with the same equation used by the mini-forward algorithm:

$$P(W_{t+1}) = P(W_t) = \sum_{w_t}P(W_{t+1} | w_t)P(w_t)$$

For our weather example, this gives us the following two equations:

<p></p>

$P(W_t = sun) = P(W_{t+1} = sun | W_t = sun)P(W_t = sun) + P(W_{t+1} = sun | W_t = rain)P(W_t = rain)$ $= 0.6 \cdot P(W_t = sun) + 0.1 \cdot P(W_t = rain)$

<p></p>

$P(W_t = rain) = P(W_{t+1} = rain | W_t = sun)P(W_t = sun) + P(W_{t+1} = rain | W_t = rain)P(W_t = rain)$ $= 0.4 \cdot P(W_t = sun) + 0.9 \cdot P(W_t = rain)$

Now we have two equations in two unknowns. To solve, note that the sum of these probabilities must equal one, i.e.

$$P(W_t = sun) + P(W_t = rain) = 1$$

Thus, if we let $$x = P(W_t = sun)$$ and $$y = P(W_t = rain)$$, we can write the following system of equations:

1. $x + y = 1$
2. $0.6x + 0.1y = x$
3. $0.4x + 0.9y = y$

Using the first equation, we can substitute $y = 1 - x$ into the other two, which gives us a single equation in one unknown:

$$0.6x + 0.1(1 - x) = x$$

Solving this equation yields $x = 1/5$, and substituting this value into the first equation gives $y = 4/5$. Thus, our stationary distribution is:

| **$$W$$** | **$$P(W)$$** |
| :-------: | :----------: |
|    sun    |     0.2      |
|   rain    |     0.8      |

# HMMs
* Underlying Markov chain over states *X*
* You observe evidence *E* at each time step
* $X_t$ is a single discrete variable; $E_t$ may be continuous and may consist of several variables

![](./img/HMMs)

Unlike vanilla Markov models, we now have two different types of nodes. To make this distinction, we'll call each $W_i$ a **state variable** and each weather forecast $F_i$ an **evidence variable**. Since $W_i$ encodes our belief of the probability distribution for the weather on day $i$, it should be a natural result that the weather forecast for day $i$ is conditionally dependent upon this belief. The model implies similar conditional independence relationships as standard Markov models, with an additional set of relationships for the evidence variables:

$$F_1 \perp W_0 \mid W_1$$

$$\forall i = 2, \dots, n; \quad W_i \perp \{W_0, \dots, W_{i-2}, F_1, \dots, F_{i-1}\} \mid W_{i-1}$$

$$\forall i = 2, \dots, n; \quad F_i \perp \{W_0, \dots, W_{i-1}, F_1, \dots, F_{i-1}\} \mid W_i$$

## The Forward Algorithm

Using the conditional probability assumptions stated above and marginalization properties of conditional probability tables, we can derive a relationship between $B(W_i)$ and $B'(W_{i+1})$ that's of the same form as the update rule for the mini-forward algorithm. We begin by using marginalization:

$$B'(W_{i+1}) = P(W_{i+1} \mid f_1, \dots, f_i) = \sum_{w_i}P(W_{i+1}, w_i \mid f_1, \dots, f_i)$$

This can be re-expressed then with the chain rule as follows:

$$B'(W_{i+1}) = P(W_{i+1} \mid f_1, \dots, f_i) = \sum_{w_i}P(W_{i+1} \mid w_i, f_1, \dots, f_i)P(w_i \mid f_1, \dots, f_i)$$

## Viterbi Algorithm
consider the following **state trellis**
![](./img/vertibi%20algorithm)

The algorithm consists of **two passes:** 
- the first runs forward in time and computes the probability of the best path to each (state, time) tuple given the evidence observed so far. 
- The second pass runs backwards in time: first it finds the terminal state that lies on the path with the highest probability, and then traverses backward through time along the path that leads into this state (which must be the best path).

Define $m_{t}[x_{t}] =\max_{x_{1}:t-1}P(x_{1:t}, e_{1: t})$, so we get:

$$
\begin{aligned}m_t[x_t]&=\max_{x_{1:t-1}}P(e_t|x_t)P(x_t|x_{t-1})P(x_{1:t-1},e_{1:t-1})\\&=P(e_t|x_t)\max_{x_{t-1}}P(x_t|x_{t-1})\max_{x_{1:t-2}}P(x_{1:t-1},e_{1:t-1})\\&=P(e_t|x_t)\max_{x_{t-1}}P(x_t|x_{t-1})m_{t-1}[x_{t-1}].\end{aligned}
$$

Using 

$$a_t[x_t]=P(e_t|x_t)\arg\max_{x_{t-1}}P(x_t|x_{t-1})m_{t-1}[x_{t-1}]=\arg\max_{x_{t-1}}P(x_t|x_{t-1})m_{t-1}[x_{t-1}]$$

<pre><code>
Result: Most likely sequence of hidden states x<sub>1:N</sub>
/* Forward pass
for t=1 to N:
    for x<sub>t</sub> in X:
        if t=1:
            m<sub>t</sub>[x<sub>t</sub>] = P(x<sub>t</sub>)P(e<sub>0</sub>|x<sub>t</sub>)
        else:
            a<sub>t</sub>[x<sub>t</sub>] = argmax<sub>x<sub>{t-1}</sub></sub> P(x<sub>t</sub>|x<sub>t-1</sub>)m<sub>t-1</sub>[x<sub>t-1</sub>];
            m<sub>t</sub>[x<sub>t</sub>] = P(e<sub>t</sub>|x<sub>t</sub>)P(x<sub>t</sub>|a<sub>t</sub>[x<sub>t</sub>])m<sub>t-1</sub>[a<sub>t</sub>[x_t]];
        
    

/* Find the most likely path's ending point
x<sub>N</sub> = argmax<sub>xN</sub> m<sub>N</sub>[x<sub>N</sub>];
/* Work backwards through our most likely path and find the hidden states
For t=N to 2:
    x<sub>t-1</sub> = a<sub>t</sub>[x<sub>t</sub>];

</code></pre>