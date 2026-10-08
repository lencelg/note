---
author: lencelg from Arcadia Bay
title: Reinforcement Learning
---
# Reinforcement Learning
**online planning**:
    an agent has no prior knowledge of rewards or transitions in the world (still represented as an MDP)

![](./img/rl)

an agent starts in a state $s$, then takes an action $a$ and ends up in a successor state $s'$, attaining some reward $r$. Each $(s, a, s', r)$ tuple is known as a **sample**

## Model-Based Learning
In model-based learning, an agent generates **an approximation of the transition function**, $\hat{T}(s, a, s')$ and the reward function $\hat{R}(s, a, s')$

by keeping counts of the number of times it arrives in each state $s'$ after entering each Q-state $(s, a)$. The agent can then generate the approximate transition function $\hat{T}$ upon request by **normalizing** the counts it has collected—dividing the count for each observed tuple $(s, a, s')$ by the sum over the counts for all instances where the agent was in Q-state $(s, a)$. Normalization of counts scales them such that they sum to one, allowing them to be interpreted as probabilities. 

---

example below for better understanding

![](./img/MDP%20example)

![](./img/MBL%20exploration)

12 samples, 3 from each episode with counts as follows:

| $$s$$  | $$a$$   | $$s'$$ | $$count$$ |
|--------|---------|--------|-----------|
| $$A$$    | $$exit$$  | $$x$$    | 1         |
| $$B$$    | $$east$$  | $$C$$    | 2         |
| $$C$$    | $$east$$  | $$A$$    | 1         |
| $$C$$    | $$east$$  | $$D$$    | 3         |
| $$D$$    | $$exit$$  | $$x$$    | 3         |
| $$E$$    | $$north$$ | $$C$$    | 2         |

Recalling that $T(s, a, s') = P(s' | a, s)$, we can estimate the transition function with these counts by dividing the counts for each tuple $(s, a, s')$ by the total number of times we were in Q-state $(s, a)$, and the reward function directly from the rewards we reaped during exploration:

**Transition Function**: $\hat{T}(s, a, s')$

$$\hat{T}(A, exit, x) = \frac{\#(A, exit, x)}{\#(A, exit)} = \frac{1}{1} = 1$$

$$\hat{T}(B, east, C) = \frac{\#(B, east, C)}{\#(B, east)} = \frac{2}{2} = 1$$

$$\hat{T}(C, east, A) = \frac{\#(C, east, A)}{\#(C, east)} = \frac{1}{4} = 0.25$$

$$\hat{T}(C, east, D) = \frac{\#(C, east, D)}{\#(C, east)} = \frac{3}{4} = 0.75$$

$$\hat{T}(D, exit, x) = \frac{\#(D, exit, x)}{\#(D, exit)} = \frac{3}{3} = 1$$

$$\hat{T}(E, north, C) = \frac{\#(E, north, C)}{\#(E, north)} = \frac{2}{2} = 1$$

**Reward Function**: $\hat{R}(s, a, s')$

$$\hat{R}(A, exit, x) = -10$$

$$\hat{R}(B, east, C) = -1$$

$$\hat{R}(C, east, A) = -1$$

$$\hat{R}(C, east, D) = -1$$

$$\hat{R}(D, exit, x) = +10$$

$$\hat{R}(E, north, C) = -1$$

---

### law of large numbers
by **law of large numbers**,  as we collect more and more samples by having our agent experience more episodes, our models of $\hat{T}$ and $\hat{R}$ will improve, with $\hat{T}$ converging towards $T$ and $\hat{R}$ acquiring knowledge of previously undiscovered rewards as we discover new $(s, a, s')$ tuples.

### performance view
However, it can be expensive to maintain counts for every $(s, a, s')$ tuple seen

## Model-Free Learning

### Direct Evaluation
**Direct Evaluation** 

record and learn at the end

直接评估所做的就是固定策略 π ，让智能体在遵循策略 π 的前提下经历若干回合。智能体在这些回合中收集样本时，会记录每个状态的总效用以及访问每个状态的次数。

Though direct evaluation eventually learns state values for each state, it’s often **unnecessarily slow to converge** because it **wastes information about transitions between states**.

### Temporal Difference Learning
learn form every experience, not the end

define **sample** as follow:
$$\text{sample} = R(s, \pi(s), s') + \gamma V^{\pi}(s')$$

with $\alpha$ as learning rate:
$$V^{\pi}(s) \leftarrow (1-\alpha)V^{\pi}(s) + \alpha \cdot \text{sample}$$

hence:
$$V^{\pi}_{k}(s) \leftarrow (1-\alpha)V^{\pi}_{k-1}(s) + \alpha \cdot \text{sample}_k$$

write in recursive way:
$$V^{\pi}_{k}(s) \leftarrow \alpha \cdot [(1-\alpha)^{k-1} \cdot \text{sample}_1 + ... + (1-\alpha) \cdot \text{sample}_{k-1} + \text{sample}_k]$$

Because $0 \leq (1 - \alpha) \leq 1$, as we raise the quantity $(1 - \alpha)$ to increasingly larger powers

we can draw some property:
- Learn at every time step, hence using information about state transitions as we get them since we're using iteratively updated versions of $V^{\pi}(s')$ in our samples rather than waiting until the end to perform any computation.
- Give exponentially less weight to older, potentially less accurate samples.
- Converge to learning true state values much faster with fewer episodes than direct evaluation.

### Q-Learning
we want to find an *optimal policy* for our agent, which requires knowledge of the Q-values of states.

transition function and reward function as dictated by the Bellman equation:

$$Q^*(s, a) = \sum_{s'} T(s, a, s')[R(s, a, s') + \gamma V^*(s')]$$

define udpate rule as follow:

$$Q_{k+1}(s, a) \leftarrow \sum_{s'}T(s, a, s')[R(s, a, s') + \gamma \max_{a'} Q_k(s', a')]$$

recall that:

$$\text{sample} = R(s, a, s') + \gamma \max_{a'}Q(s', a')$$

hence:

$$Q(s, a) \leftarrow (1-\alpha)Q(s, a) + \alpha \cdot \text{sample}$$

---
viewpoint

**off-policy learning**:
Q-learning can learn the optimal policy directly even by taking suboptimal or random actions.

### Approximate Q-Learning
using **feature vector** to speed up and save memory

treat values of states and Q-states as **linear value functions**:

$$V(s) = w_1 \cdot f_1(s) + w_2 \cdot f_2(s) + ... + w_n \cdot f_n(s) = \vec{w} \cdot \vec{f}(s)$$

$$Q(s, a) = w_1 \cdot f_1(s, a) + w_2 \cdot f_2(s, a) + ... + w_n \cdot f_n(s, a) = \vec{w} \cdot \vec{f}(s, a)$$

where 

$$\vec{f}(s) = \begin{bmatrix}f_1(s)&f_2(s)&...&f_n(s)\end{bmatrix}^T$$

and 

$$\vec{f}(s, a) = \begin{bmatrix}f_1(s, a)&f_2(s, a)&...&f_n(s, a)\end{bmatrix}^T$$

represent the feature vectors for state $s$ and Q-state $(s, a)$ respectively and $\vec{w} = \begin{bmatrix}w_1&w_2&...&w_n\end{bmatrix}$ represents a weight vector. Defining **difference** as

$$\text{difference} = [R(s, a, s') + \gamma \max_{a'}Q(s', a')] - Q(s, a)$$

define update rule:

$$w_i \leftarrow w_i + \alpha \cdot \text{difference} \cdot f_i(s, a)$$

re-express update rule of exact Q-learning with **difference**:

$$Q(s, a) \leftarrow Q(s, a) + \alpha \cdot \text{difference}$$

# $\varepsilon$-Greedy Policies

Agents following an **$\epsilon$-greedy policy** define some probability $0 \leq \epsilon \leq 1$, and act randomly and explore with probability $\epsilon$. Accordingly, they follow their current established policy and exploit with probability $(1 - \epsilon)$.

If a large value for $\epsilon$ is selected, then even after learning the optimal policy, the agent will still behave mostly randomly. Similarly, selecting a small value for $\epsilon$ means the agent will explore infrequently, leading Q-learning (or any other selected learning algorithm) to learn the optimal policy very slowly.

hence, $\epsilon$ must be **manually tuned** and lowered over time to see results.

# Exploration Functions
manually tuning $\epsilon$ is avoided by **exploration functions**

update rule:

$$Q(s, a) \leftarrow (1-\alpha)Q(s, a) + \alpha \cdot [R(s, a, s') + \gamma \max_{a'} f(s', a')]$$

with $f$ denotes an exploration function:

$$f(s, a) = Q(s, a) + \frac{k}{N(s, a)}$$