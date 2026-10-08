---
author: lencelg from Arcadia Bay
---
[TOC]
# Utilities
Rational agents must follow the **principle of maximum utility** — they must always select the action that maximizes their expected utility. However, obeying this principle only benefits agents that have **rational preferences**. 

3 objects, $A$, $B$, and $C$, and our agent is currently in possession of $A$. Say our agent has the following set of irrational preferences:

- Our agent prefers $B$ to $A$ plus \$1
- Our agent prefers $C$ to $B$ plus \$1
- Our agent prefers $A$ to $C$ plus \$1

Let's now properly define the mathematical language of preferences:

- If an agent prefers receiving a prize $A$ to receiving a prize $B$, this is written $A \succ B$
- If an agent is indifferent between receiving $A$ or $B$, this is written as $A \sim B$
- A **lottery** is a situation with different prizes resulting with different probabilities. To denote a lottery where $A$ is received with probability $p$ and $B$ is received with probability $(1-p)$, we write:

  $$L = [p, A; (1-p), B]$$

five **Axioms of Rationality**:

- **Orderability**:  
  $(A \succ B) \vee (B \succ A) \vee (A \sim B)$  
  A rational agent must either prefer one of $A$ or $B$, or be indifferent between the two.
  
- **Transitivity**:  
  $(A \succ B) \wedge (B \succ C) \Rightarrow (A \succ C)$  
  If a rational agent prefers $A$ to $B$ and $B$ to $C$, then it prefers $A$ to $C$

- **Continuity**:  
  $A \succ B \succ C \Rightarrow \exists p \: [p, A; (1-p), C] \sim B$  
  If a rational agent prefers $A$ to $B$ but $B$ to $C$, then it's possible to construct a lottery $L$ between $A$ and $C$ such that the agent is indifferent between $L$ and $B$ with appropriate selection of $p$

- **Substitutability**:  
  $A \sim B \Rightarrow [p, A; (1-p), C] \sim [p, B; (1-p), C]$  
  A rational agent indifferent between two prizes $A$ and $B$ is also indifferent between any two lotteries which only differ in substitutions of $A$ for $B$ or $B$ for $A$

- **Monotonicity**:  
  $A \succ B \Rightarrow (p \geq q) \Leftrightarrow [p, A; (1-p), B] \succeq [q, A; (1-q), B]$  
  If a rational agent prefers $A$ over $B$, then given a choice between lotteries involving only $A$ and $B$, the agent prefers the lottery assigning the highest probability to $A$.

# Decision Network
## Component
anatomy of a **decision network**:
- **Chance nodes** - Chance nodes in a decision network behave identically to Bayes' nets. Each outcome in a chance node has an associated probability, which can be determined by running inference on the underlying Bayes' net it belongs to. We'll represent these with ovals.
- **Action nodes** - Action nodes are nodes that we have complete control over; they're nodes representing a choice between any of a number of actions which we have the power to choose from. We'll represent action nodes with rectangles.
- **Utility nodes** - Utility nodes are children of some combination of action and chance nodes. They output a utility based on the values taken on by their parents, and are represented as diamonds in our decision networks.

## working procedure
- Start by instantiating all evidence that's known, and run inference to calculate the posterior probabilities of all chance node parents of the utility node into which the action node feeds.
- Go through each possible action and compute the expected utility of taking that action given the posterior probabilities computed in the previous step. The expected utility of taking an action $a$ given evidence $e$ and $n$ chance nodes is computed with the following formula:

  $$EU(a \mid e) = \sum_{x_1, ..., x_n}P(x_1, ..., x_n \mid e)U(a, x_1, ..., x_n)$$

  where each $x_i$ represents a value that the $i^{th}$ chance node can take on. We simply take a weighted sum over the utilities of each outcome under our given action with weights corresponding to the probabilities of each outcome.
- Finally, select the action which yielded the highest utility to get the MEU.

![](./img/DN%20a)

## Outcome tree
use outcome tree to visulize the action

![](./img/outcome%20tree)

# The Value of Perfect Information
**VPI**

We can **compare** the VPI of learning some new information with the **cost** associated with observing that information to make decisions about **whether or not it’s worthwhile to observe**.

we represent it as:

$$
\begin{cases}
MEU(e)=\max_a\sum_sP(s|e)U(s,a) \\
MEU(e,e^{\prime})=\max_a\sum_sP(s|e,e^{\prime})U(s,a) \\
MEU(e, E') = \sum_{e'}P(e' \mid e)MEU(e, e')
\end{cases} \Rightarrow VPI(E^{\prime}|e)=MEU(e,E^{\prime})-MEU(e)
$$

## Properties of VPI
- **Nonnegativity.** $\forall E', e\:\: VPI(E' \mid e) \geq 0$  

- **Nonadditivity.** $VPI(E_j, E_k \mid e) \neq VPI(E_j \mid e) + VPI(E_k \mid e)$ in general.  

- **Order-independence.** $VPI(E_j, E_k \mid e) = VPI(E_j \mid e) + VPI(E_k \mid e, E_j) = VPI(E_k \mid e) + VPI(E_j \mid e, E_k)$