# Aritifical Intelligence A modern apporach
made from [this book](https://aima.cs.berkeley.edu/)<br>
can refer note from [cs50ai](https://cs50.harvard.edu/ai/)
# Introduction
Turing test
* natural language processing
* knowledge representation
* automated reasoning
---
* machine learning 
full Turing test
* origin Turing test
* computer vision
* robotics
---
Link
* Philosophy
* Mathematics
* Econnomics
* Neuroscience
* Psychology
* Computer engineering
* Control theory and cybernetics
* Linguistics
# Intelligent Agent
![](./img/agent%20and%20environment)
performance measure: based on consequentialism<br>
Rational Agent
* Omniscience(全知)
* autonomy(自主)
* learn
---
environment property<br>
$$agent = architecture + program$$
agent program|description|
---|---
| Simple reflex agents|![](./img/simple%20reflex%20agent)
Model-based reflex agents|   * ![](./img/model%20based%20agent)
Goal-based agents|   * ![](./img/goal%20based%20agent)
Utility-based agents|   * ![](./img/model%20and%20utlity%20based%20agent)
learning agents|   * ![](./img/learning%20agent)
---
agent programme representation
![](./img/status%20space%20and%20trasition%20model%20representation)
---
Problem-solving agent
* Goal formulation
* Problem formulation
* Search
* Execution
## Search problem
Compnent|
---|
problem|
states|
initial states|
goal states|
Action|
Applicable|
Transition Model|
Action cost function|
Path|
---
|problem| description|
---|---
standardized problem| benchmark for reasearchers|
real-world problem|example: grid world, sokoban puzzle, infinte world
## Search Algorithm
Algorithm
* Completeness
* Cost optimality
* Time Complexity
* Space Complexity
### Uniformed Search
* BFS
* Dijkstra's algorithm(uniformed-cost search)
* DFS
* Depth-limited search
* iterative deepening search(increasing depth when no solution found)
* bidirectional search
### Informed Search
`heuristic function`: evaulation how close current is to the goal 
* greedy-first search
* A\* Search
* Weigthed A\* Search
* beam Search
* iterative A\* Search
* recursive best-first search
# Complex Search
refer [note from cs50_ai](../../cs50_ai/optimization.md)
---
# Adversarial search and Game
MiniMax Search 
```
function MINIMAX -SEARCH(game, state) returns an action
    player ← game.T O -MOVE(state)
    value, move ← M AX -V ALUE(game, state)
    return move
        
function MAX-VALUE(game, state) returns a (utility, move) pair
    if game.I S-TERMINAL (state) then return game.UTILITY(state, player),null
    v, move ← −∞
    for each a in game.ACTIONS(state) do
        v2, a2 ← MIN -V ALUE(game, game.RESULT (state, a))
        if v2 > v then
        v, move ← v2, a
    return v, move

function MIN -VALUE (game, state) returns a (utility, move) pair
    if game.IS-TERMINAL (state) then return game.UTILITY(state, player), null
    v, move ← +∞
    for each a in game.ACTIONS(state) do
        v2, a2 ← M AX -V ALUE(game, game.R ESULT (state, a))
        if v2 < v then
            v, move ← v2, a
    return v, move

```
alpha-beta pruning
![](./img/Alpha%20beta%20pruning)
---
Heuristic Alpha–Beta Tree Search
![](./img/game%20heursitcs)
* Cutting off search
    ```
    if game.I S -CUTOFF (state, depth) then return game.E VAL(state, player), null
    ```
* forward prunning
---
Monte Carlo tree search(MCTS)
![](./img/MCTS%20explaination)
```
function M ONTE-C ARLO-TREE -S EARCH(state) returns an action
    tree ← N ODE(state)
    while I S-TIME -R EMAINING () do
        leaf ← S ELECT(tree)
        child ← E XPAND (leaf )
        result ← S IMULATE (child)
        BACK -P ROPAGATE(result, child)
    return the move in ACTIONS(state) whose node has highest number of playouts
```
---
stochastic game
* probability
* exepctMiniMax value<br>

evaluation function<br>
![](./img/stochastic%20evaluation)

limitation
* effect from heuristic function
* based on caculating legal move(instead use `utility of node expansion`)
* human plays diff much from machine calculation
* the ability to incorporate machine learning
# CONSTRAINT SATISFACTION  PROBLEMS(CSP)
Example problem
* Map coloring
* Job-shop scheduling
---
* `Node consistency`: A single variable (corresponding to a node in the CSP graph) is node-consistent if all the
values in the variable’s domain satisfy the variable’s unary constraints.<br>
* `Arc consistency`: A variable in a CSP is arc-consistent1 if every value in its domain satisfies the variable’s
binary constraints
   ![](./img/AC-3)
* `path-consistency`:tightens the binary constraints by using implicit constraints
that are inferred by looking at triples of variables
* `K-consistency`
* `Global-constraints`
---
`Backtracking Search for CSPs`
![](./img/csp%20backtracking%20search)
---
`Local Search for CSPs`
![](./img/csp%20local%20search)
---
Structure of CSP
* cutset conditioning
* tree decomposition
* value symmetry