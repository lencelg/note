#import "@preview/easy-paper:0.2.2": *

#set math.equation(numbering: "(1)")

#show: project.with(
  title: "ai review note",
  author: "lencelg from Arcadia Bay",
  date: auto,
)

#outline()

#pagebreak()

= Lec 1: introduction

这一节要记的内容比较少

几个时间点
- *1950: Turing's “Computing Machinery and Intelligence”*
- *1956: Dartmouth meeting: “Artificial Intelligence” adopted*

然后是几个发展阶段
- 1940-1950: Early days
- 1950—70: The golden years!
- 1970—90: Knowledge-based approaches
- 1990—: Statistical approaches

what is ai?

#image("img/what_is_ai.png")

#pagebreak()

= Lec 2: uninformed search

== search problem

搜索问题的几部分要辨析清楚

a search problem consists of:
- a state space
- a successor function(with action, cost)
- a start and a goal test

A *solution* is a sequence of actions (a plan) which transforms the start state to a goal state 

要理解下面的例子

#figure(
  image("img/search_example.png"),
  caption: "search problem component example",
)

== state space

表示搜素空间有两种
- state space graphs
- search trees

*Important: Lots of repeated structure in the search tree!*

两个对比如下：

#figure(
  image("img/compare.png", height: 20%),
  caption: "comparsion between state space graphs and search trees"
)

#pagebreak()

== cost-unsensitive search
=== DFS

一条路走到底

$b（"分支因子"）$：树中每个节点的最大子节点数

$m（"最大深度"）$：树的最深路径长度

节点总数：最坏情况下，整棵树有 $1 + b + b^2 + . . . + b^m approx O("bm")$ 个节点

#grid(
  columns: 2,
  [
    + expansion
      - Some left prefix of the tree
      - if $m$ is finite, takes time $O("bm")$
    + the fringe space
      -  siblings on path to root, so $O("bm")$
    + completeness
      - 有环就不行, so not complete
    + optimality
      - No, 只是找到最左边的解, 不在乎代价和路径
  ],
  [
    #figure(
        image("img/dfs.png", height: 4.6cm),
        caption: "dfs"
    )
  ]
)

=== BFS

BFS层层递进

#figure(
  image("img/bfs.png"),
  caption: "bfs"
)

=== Iterative Deepening

Idea: get DFS’s space advantage with BFS’s time / shallow-solution advantages

限制深度从1到$m$递增, 在限制深度里面执行DFS来寻找目标

会有重复搜索，但是在实际的问题里面深度不会很深，还可以接受

== cost-sensitive search

=== UCS

*Uniform Cost Search*
+ Strategy: expand a *cheapest node* first:
+ Fringe is a *priority queue* (priority: cumulative cost)

ucs 是贪心算法的体现，每次都扩张代价最小的节点

#figure(
  image("img/ucs.png"),
  caption: "ucs"
)

ucs 是最优的也是完备的

== the one queue

上面的搜索算法都是相同的，只有节点的扩张方式不同

All these search algorithms are the same except for fringe strategies

#image("img/s.png")

#pagebreak()

= Lec 3: informed search

outline
+ Heuristics
+ Greedy Search
+ A\* Search
+ Graph Search

启发式函数能够告诉我们一个state离目标有多远，于是能够利用启发式函数来进行优化搜索

== Greedy search

Strategy: expand a node that you think is closest to a goal state

Worst-case: like a badly-guided DFS

贪心搜索的表现一般很糟糕

== A\* search

#linebreak()
Combining UCS and Greedy idea

+ Uniform-cost orders by path cost, or backward cost $g(n)$
+ Greedy orders by goal proximity, or forward cost $h(n)$

then A\* Search orders by the sum: $f(n) eq g(n) + h(n)$
\
*only stop when we dequeue a goal*, 因为我们多预估了forward cost $h(n)$, 这个时候出队才是真正的扩展了这个节点,入队仅仅意味着算法发现了这个节点，但它的路径还没有被验证。

A heuristic h is _admissible_ (optimistic) if:

$
  0 lt.eq h(n) lt.eq h^*(n)
$

where $h^*(n)$ is the true cost to a nearest goal

== proof


#figure(
  image("img/proof.png", height: 6.5cm),
  caption: "A* optimality proof if heuristic is admissible"
)

下面是claim的详细证明

第一步：$f(n) lt.eq f(A)$
- $f(n) = g(n) + h(n)$
- 因为 $n$ 是 $A$ 的祖先，从 $n$ 到 $A$ 有一条真实路径。
- 可采纳性意味着 $h(n)$ *不会高估* 到达目标的真实代价，即 $h(n) lt.eq "从n到A的真实剩余代价"$
- $g(n) plus h(n) lt.eq g(n) plus "n到A的真实代价" eq g(A)$
- so：*$f(n) lt.eq g(A)$*。

第二步：$g(A) = f(A)$
- $h(A) eq 0$
- $f(A) eq g(A) plus h(A) eq g(A) plus 0 eq g(A)$

then: $f(n) lt.eq g(A) eq f(A)$

第三步
- 因为 B 是*次优解*，它的真实代价 $g(B)$ 大于 A 的代价 $g(A)$
- then *$f(n) lt.eq f(A) lt f(B) $*

#summary[
  A\* is optimal with admissible / consistent heuristics
]

#pagebreak()

= Lec 4: CSP

首先是定义csp问题，csp问题的组成部分

#figure(
  image("img/csp.png"),
  caption: "csp component example"
)
CSP的着色过程一定要会

we use Constraint Graphs to represent the searching state

#figure(
  image("img/constraint_graphs.png", height: 20%),
  caption: "constraint graph example"
)

Backtracking Search 本质是枚举加剪枝, 朴素的版本是有剪枝的，但是力度小了很多

example
+ 地图着色，A=红，B=绿。当要给 C 赋值时，如果发现 C 取红、绿、蓝都和 A 或 B 冲突，普通回溯会立即返回C 无值可选，然后去改 B 的值。

forward checking是力度大一点的剪枝(但是只影响邻居的冲突值)，着色问题里面选取值以后能减少相邻节点的值域

弧一致性也可以加速(删除一个值后，所有受影响的邻居都要重新检查，这个“冲击波”会沿着约束图持续传播，直到全网稳定), AC-3算法

#pagebreak()

== 最小冲突算法（Min-Conflicts）

可以了解一下

初始化：为每个变量随机分配一个值（不管是否违反约束）。

迭代过程：
- 随机选一个当前违反了约束的变量（比如地图着色中，和邻居颜色一样的那个国家）。
- 计算该变量所有可能值中，会引发冲突数量最少的那个值（如果有多个，随机选一个）。
- 将变量改为这个“最小冲突”的值。
- 重复上述步骤（固定次数，或直到没有冲突为止）。

#summary[
\
CSPs are a special kind of search problem:
  + States are partial assignments
  + Goal test defined by constraints
  Basic solution: backtracking search
- Speed-ups:
- Ordering
- Filtering
- Structure – turns out trees are easy!

Iterative min-conflicts is often effective in practice
]

#pagebreak()

= Lec 5: Adversarial Search

== Minimax

#figure(
  image("img/minimax.png"),
  caption: "minimax implementation"
)

Alpha-Beta Pruning可以加速minimax算法
- $alpha$: MAX’s best option on path to root
- $beta$: MIN’s best option on path to root

#grid(
  columns: 2,
  [
    ```python
    def max-value(state, α, β):
        initialize v = -∞
        for each successor of state:
            v = max(v, value(successor, α, β))
            if v ≥ β return v
            α = max(α, v)
        return v
    ```
  ],
  [
    ```python
    def min-value(state , α, β):
        initialize v = +∞
        for each successor of state:
            v = min(v, value(successor, α, β))
            if v ≤ α return v
            β = min(β, v)
        return v
    ```
  ]
)

#pagebreak()

== Expectimax Search
期望极大搜索（Expectimax Search） 是极小极大搜索（Minimax） 的扩展版本，专门用来处理包含随机性（Stochastic）的博弈场景

#figure(
  image("img/expectimax.png"),
  caption: "expectimax pseudocode"
)

这里不可以剪枝，因为没有探索这个节点, 只是有概率

于是就有Depth-Limited Expectimax来限制层数计算期望值

== Monte Carlo Tree Search(MCTS)
basic idea: 通过反复“随机模拟”试错，把计算资源集中在最有希望的分支上

MCTS 4 个阶段
+ 选择（Selection）
  - 从根节点（当前棋局）开始，利用*UCT 公式*，在现有的树中向下“押注”，一直选到*一个尚未完全展开的节点*（即还有未尝试过的走法），或者选到*叶子节点*（当前模拟到尽头）。
+ 扩展（Expansion）
  - 当到达一个非终局节点时，从它的所有合法走法中，*随机选择（或按策略选择）一个从未尝试过的走法*，在树上长出这个新的子节点。
+ 模拟（Simulation / Playout）
  - 从刚刚扩展出的新节点开始，*双方完全随机走子*（或者用极快的轻量级策略走子），直到棋局分出胜负（输/赢/平）为止。
+ 反向传播（Backpropagation）
  - 将模拟得到的胜负结果*沿着刚才选下来的路径，一直传回根节点*
  - 路径上所有节点的统计信息都会更新：
    - *访问次数（N）* +1
    - *累计胜场（Q）* + 该次模拟的分数

=== UCT 公式
在选择阶段，使用*UCT（Upper Confidence bounds applied to Trees）* 公式来决定走哪条边：

$
  "UCT" eq frac(Q(n), N(n)) + C times sqrt(frac(ln N("parent"), N(n)))
$

- $N(n)$ = number of rollouts from node n
- $U(n)$ = total utility of rollouts (e.g., \# wins) for Player(Parent(n))
- 左侧$frac(Q(n),N(n)) $：*Exploitation* 这是该节点的历史胜率。胜率越高，越倾向于选它。
- *右侧*$C times sqrt( frac(ln N("parent"), N_n))$：*“探索（Exploration）”*。这是对该节点的“不确定性”打分。访问次数越少（被冷落），这个值就越大，鼓励算法去尝试它。
- *参数 $C$*：平衡“利用”和“探索”的常数。$C$ 越大，越倾向于探索冷门分支。

#pagebreak()

= lec 6: Computational Intelligence

== local search

local search doesn't care about the path


== hill climbing

#grid(
  columns: 2,
  [
    + Simple, general idea:
      - Start wherever
      - Repeat: move to the best neighboring state
      - If no neighbors better than current, quit
    + not optimal, not complete
  ],
  [
    #figure(
      image("img/local_search.png", height: 19%),
      caption: "Hill Climbing Diagram"
    )
  ]
)


== Genetic Algorithm


#grid(
  columns: 2,
  [
    #figure(
      image("img/gen.png"),
      caption: "flowchart of GA"
    )
  ],
  [
      #show raw: set text(size: 8.9pt)
      ```python
        /*
          P(t)表示某一代的群体，t为当前进化代数
          Best 表示目前已找到的最优解
        */
        Procedure GA
        begin
            t <- 0;
            initialize(P(t)); //初始化群体
            evaluate(P(t)); //适应值评价
            keep_best(P(t)); //保存最优染色体
            while (不满足终止条件) do
            begin
                P(t) selection(P(t)); //选择算子
                P(t) crossover(P(t)); //交配算子
                P(t) mutation(P(t)); //变异算子
                t <- t+1;
                P(t) <- P(t-1);
                evaluate(P(t));
                if(P(t)的最优适应值大于Best的适应值) 
                  //以P(t)的最优染色体替代Best
                  replace(Best);
                  end if
            end
        end
        ```
  ]
)

#pagebreak()


== common local search algorithm
#figure(
  table(
    columns: (auto, auto),
    align: left,
    [策略], [效果],
    [随机重启（Random Restart）], [简单粗暴],
    [侧向移动（Sideways Move）], [帮助走出“高原”，但也有可能在平地上无限游荡],
    [模拟退火（Simulated Annealing）], [通过温度控制，前期偏向探索，后期精细挖掘，效果极佳],
    [遗传算法（Genetic Algorithm）], [并行搜索，覆盖面广，适合超大空间],
  ),
)
= Lec 7: MDP

== value of states
discounting 要会计算

然后就是理解公式, 要注意这里是本质在计算*expectimax value of a state*

#figure(
  image("img/value_of_state.png"),
  caption: "value of state"
)

== Bellman Equations and Value Iteration
贝尔曼方程 = Expectimax 的“自我对弈”版本。它把“未来的自己”当作最聪明的对手（取 Max），把“环境”当作随机骰子（取期望），并给未来的收益打了折(discounting $gamma$)

valude iteration 做过实验，会有一点印象

Bellman equations *characterize the optimal values*: 

#align(center)[
  $
    V^*(s) = max_a sum_(s') T(s, a, s') bracket[R(s, a, s') + gamma V^*(s')]
  $
]

Value iteration *computes* them:

#align(center)[
  $
    V_(k+1)(s) <- max_a sum_(s') T(s, a, s') bracket[R(s, a, s') + gamma V_k(s')]
  $
]

=== value iteration process

+  #text(weight: "bold", fill: navy)[初始化]：  
  $V_0(s) eq 0$，这代表没有剩余时间步（$t eq 0$）时，期望的累计奖励总为零。

+  #text(weight: "bold", fill: navy)[迭代更新]：  
  给定当前轮次的 $V_k(s)$，对每一个状态进行一次“期望极大搜索（Expectimax）”操作：
  #align(center)[
    #rect(width: 90%, inset: 0.6em, fill: rgb("#f5f7fa"), radius: 4pt)[
      #set text(size: 13pt)
      $ V_(k+1)(s) <- max_a sum_(s') T(s, a, s') ["R(s, a, s')" + gamma V_k(s') ] $
    ]
  ]

+ #text(weight: "bold", fill: navy)[终止条件]：  
  重复上述计算，直至价值函数数值收敛（变化量小于预设阈值 $theta$）。

+ #text(weight: "bold", fill: navy)[复杂度分析]：  
  每一次迭代的时间复杂度为 $O(S^2 A)$。

+ #text(weight: "bold", fill: navy)[收敛定理]：  
  #rect(width: 100%, inset: 0.5em, stroke: rgb("#2b6cb0") + 1pt, radius: 4pt)[
    #text(weight: "bold", fill: rgb("#2b6cb0"))[定理保证]：  
    值迭代必定收敛至唯一的最优价值函数 $V^*$。  
    - 核心理念：迭代过程本质上是不断“修正”当前的近似值，使其精准度逐步向最优值看齐。  
    - #text(fill: red)[关键洞察]：在实际运行中，*最优策略（Policy）* 往往比 *最优价值（Values）* 更早收敛（即机器人知道怎么走，但价值数值还在微调）。
  ]

+ 收敛后提取最优策略: 对于每个状态 $s$, 选择让贝尔曼方程取得最大值的动作： 
  - $ pi^*(s) = arg max_a sum_(s') P(s', s, a)[R + gamma V^*(s')] $

\
下面是示例代码

```python
def value_iteration(env, theta=0.0001, gamma=0.9):
    V = {s: 0 for s in env.states}
    while True:
        delta = 0
        for s in env.states:
            old_v = V[s]
            # 计算所有动作下的最大价值
            V[s] = max([sum([p * (r + gamma * V[s_next]) 
                             for (p, s_next, r) in env.get_transitions(s, a)]) 
                        for a in env.actions])
            delta = max(delta, abs(old_v - V[s]))
        if delta < theta:
            break
    # 提取最优策略
    policy = {}
    for s in env.states:
        policy[s] = argmax(...)
    return V, policy
```

=== value iteration understanding

要理解值迭代的流程, 值迭代是自举的过程。

#figure(
  image("img/understanding.png", height: 40%, width: 60%, fit: "stretch"),
  caption: [#text(size: 11.6pt)[llm generated explaination for value iteration understanding]]
)

#linebreak()

在可视化里面有辐射的视觉效果, 第一轮是辐射到开始节点的一步远的节点, 每一轮辐射的范围都在加大


== policy iteration

#idea[
  先定方案，再验算，验完再改
]

基本的流程如下

+ Evaluation: For fixed current policy $pi$, find values with policy evaluation:
  - Iterate until values converge:
  $ V_(k+1)^(pi_i)(s) <- sum_(s') T(s, pi_i (s), s') [R(s, pi_i (s), s') + gamma V_k^(pi_i)(s')] $
+ Improvement: For fixed values, get a better policy using policy extraction
  - One-step look-ahead:
  $ pi_(i+1)(s) = limits(arg max)_a sum_(s') T(s, a, s') [R(s, a, s') + gamma V^(pi_i)(s')] $
+ 如果 $pi_(i+1)$ 与 $pi_i$ 一样, 说明策略已最优，算法终止
+ 否则, 用 $pi_(i + 1)$ 替换 $pi_i$, 回到阶段一重新评估

\
示例代码如下
#block([
  #show raw: set text(size: 6.94pt)
  ```python
  def policy_iteration(env, gamma=0.9, theta=0.0001):
      # 1. 初始化随机策略
      policy = {s: random.choice(env.actions) for s in env.states}
      
      while True:
          # 2. 策略评估（采用迭代求解方式，也可换成线性方程组求解）
          V = {s: 0 for s in env.states}
          while True:
              delta = 0
              for s in env.states:
                  old_v = V[s]
                  a = policy[s]
                  # 固定动作 a，计算期望值（注意没有 max）
                  V[s] = sum([p * (r + gamma * V[s_next]) 
                              for (p, s_next, r) in env.get_transitions(s, a)])
                  delta = max(delta, abs(old_v - V[s]))
              if delta < theta:
                  break
          
          # 3. 策略改进
          policy_stable = True
          for s in env.states:
              old_action = policy[s]
              # 贪心寻找最佳动作
              best_action = argmax([sum([p * (r + gamma * V[s_next]) 
                                         for (p, s_next, r) in env.get_transitions(s, a)]) 
                                    for a in env.actions])
              policy[s] = best_action
              if old_action != best_action:
                  policy_stable = False
          
          # 4. 判定终止
          if policy_stable:
              break
      return V, policy
  ```
])
=== policy iteration understanding

$pi(s)$ 本质是一个指定动作(action), 但是执行这个动作不一定会到达给定预估的$s'$，于是这里使用了$T(s, pi_i (s))$。

另一个解释版本的公式不太一样, 建议使用上面的公式来理解更好，提取策略的时候就是提取了固定的action而已

下附另一个版本的公式(额外part)
- policy evaluation
  - $ V^pi(s) eq sum_a pi(a|s) sum_(s') P(s'|s, a) [R(s, a, s') plus gamma V^pi(s')] $
- policy improvement
  - $ pi^(')(s) = limits(arg max)_a sum_(s') P(s'|s, a) [R(s, a, s') + gamma V^(pi)(s')] $

#pagebreak()

= Lec 8: Reinforcement Learning

Still assume a Markov decision process (MDP):
- don’t know T or R

#grid(
  columns: (1.4fr, 1fr),
  [
    #set text(size: 9pt)
    Basic idea:
    - Receive feedback in the form of rewards
    - Agent’s utility is defined by the reward function
    - Must (learn to) act so as to maximize expected rewards
    - All learning is based on observed samples of outcomes!
  ],
  [
    #figure(
      image("img/rl.png"),
    )
  ]
)

== Model-Based Learning

Estimate T and R using historical data (#text(fill: blue)[Episodes]).

\

basic idea as follow:
- *Model-Based Idea:*
  - Learn an approximate model based on experiences
  - Solve for values as if the learned model were correct
- *Step 1:* Learn empirical MDP model
  - Count outcomes $s'$ for each $s$, $a$
  - Normalize to give an estimate $hat(T)(s, a, s')$
  - Discover each $hat(R)(s, a, s')$ when we experience $(s, a, s')$

- *Step 2:* Solve the learned MDP
  - For example, use value iteration, as before

== Model-Free Learning

*Passive reinforcement learning*
- Direct evaluation
- Temporal difference learning
*Active reinforcement learning*
- Q-learning

=== Passive reinforcement learning

在被动强化学习中，智能体遵循一个给定的固定策略 $pi$，并不尝试改进它。目标仅仅是评估该策略，即通过遵循 $pi$ 产生的经验来估计状态价值函数 $V^pi(s)$。

主要特点
- 智能体的策略 $pi(s)$ 是固定的且已知。
- 智能体不探索更好的动作，只观察由 $pi$ 导致的奖励和状态转移。
- 目标是准确估计从每个状态出发的期望累积折扣奖励：$V^pi(s) = EE [G_t | S_t = s]$。

=== 直接效用估计

蒙特卡洛思想

- 按照固定策略 $pi$ 执行多个幕（episode）
- 对每个状态，计算该幕结束时观测到的实际回报（累积折扣奖励）
- 将所有幕中每个状态的回报取平均

- 回报 $G_t$ 的计算公式：
  $ G_t = sum_(k=0)^(oo) gamma^k R_(t+k+1) $
- 增量式更新规则（平均值更新）：
  $ V(s) <- V(s) + alpha (G_t - V(s)) $

What’s good about direct evaluation?
- easy to understand
- doesn’t require any knowledge of T, R
- eventually computes the correct average values, using just sample transitions
What bad about it?
- wastes information about transitions between states
- Each state must be learned separately, and therefore it takes a #text(fill: red)[long time] to learn

=== 时序差分（TD）学习

- 在幕*进行中*在线更新价值估计，无需等到幕结束。
- 使用自举（bootstrapping）：用下一状态的当前估计来更新当前状态。

- TD(0) 更新规则：
  $ V(s) <- V(s) + alpha [r + gamma V(s') - V(s)] $
  其中：
  - $alpha$ 是学习率。
  - $r + gamma V(s')$ 称为 *TD 目标*。
  - $r + gamma V(s') - V(s)$ 称为 *TD 误差*。

=== 比较

#block(
  [
    #set text(size: 10.3pt)
  - *蒙特卡洛*：
    - #text(fill: green)[无偏]（收敛到真实值）。
    - #text(fill: red)[高方差]。
    - 必须等到一个幕结束才能更新。
  - *TD 学习*：
    - #text(fill: red)[有偏]（依赖初始估计）。
    - #text(fill: green)[较低方差]。
    - 每一步后都可以在线更新。

  ]
)

== Active Reinforcement Learning

=== basic idea

#problem(
  [
    TD value learning
    - if we want to turn values into #text(fill: red)[a (new) policy], we’re sunk
  ]
)

#idea(
  [
    - learn Q-values, not values
    - *Makes action selection model-free too*
  ]
)

=== Q-value iteration
Q值迭代（Q-Value Iteration） 是值迭代在 状态-动作对（State-Action Pair） 上的直接推广。

- 值迭代：寻找逐层（深度受限）的价值
  - 从已知正确的 $V_0(s) = 0$ 开始
  - 给定 $V_k$，计算所有状态的深度 $k+1$ 价值：
    $ V_(k+1)(s) <- max_a sum_(s') T(s, a, s') [R(s, a, s') + gamma V_k(s')] $

- 但 $Q$ 值更有用，所以改为计算它
  - 从已知正确的 $Q_0(s,a) = 0$ 开始
  - 给定 $Q_k$，计算所有 $q$-状态的深度 $k+1$ 的 $q$ 值：
    $ Q_(k+1)(s, a) <- sum_(s') T(s, a, s') [R(s, a, s') + gamma max_(a') Q_k (s', a')] $


\
代码如下
#block(
  [
    #show raw:set text(size: 10pt)
    ```python
    def q_value_iteration(env, theta=0.0001, gamma=0.9):
    # 初始化 Q 表：状态数 x 动作数
    Q = {s: {a: 0 for a in env.actions} for s in env.states}
    
    while True:
        delta = 0
        for s in env.states:
            for a in env.actions:
                old_q = Q[s][a]
                # 计算当前 (s, a) 的期望收益（需要模型 P 和 R）
                new_q = sum([p * (r + gamma * max(Q[s_next].values())) 
                             for (p, s_next, r) in env.get_transitions(s, a)])
                Q[s][a] = new_q
                delta = max(delta, abs(old_q - new_q))
        if delta < theta:
            break
            
    # 提取策略：每个状态取 max Q 的动作
    policy = {s: max(Q[s], key=Q[s].get) for s in env.states}
    return Q, policy
    ```
  ]
)
=== Q-learning
*Q-learning 和 Q-values iteration 是不一样的*

#figure(
  image("img/q-value.png", width: 100%, height: 31.5%, fit: "stretch"),
  caption: "slide from class"
)

\
代码辅助理解如下
#block(
  [
    #show raw: set text(size: 10pt)
    ```python
    def q_learning(env, episodes=1000, alpha=0.8, gamma=0.9, epsilon=0.1):
        Q = np.zeros((n_states, n_actions))
        # 用于统计每回合步数（可选）
        for ep in range(episodes):
            state, _ = env.reset()
            done = False
            while not done:
                # 1. ε-贪心选择动作
                if np.random.uniform(0, 1) < epsilon:
                    action = env.action_space.sample()  # 探索
                else:
                    action = np.argmax(Q[state, :])     # 利用
                
                # 2. 执行动作，获取反馈（注意这里用的是 env.step，不依赖 P 矩阵）
                next_state, reward, terminated, truncated, _ = env.step(action)
                done = terminated or truncated
                
                # 3. Q-learning 核心更新（不用概率P，直接用采样数据）
                best_next = np.max(Q[next_state, :]) if not done else 0
                td_target = reward + gamma * best_next
                Q[state, action] = Q[state, action] + alpha * (td_target - Q[state, action])
                
                state = next_state
        # 提取策略
        policy = {s: np.argmax(Q[s, :]) for s in range(n_states)}
        return Q, policy
        ```

  ]
)

== regression

这些都是ml基础，不做过多介绍
- 最小二乘法
- 随机梯度下降
- batch概念

\
The normal equations的推导

#figure(
  image("img/normal_equation.png"),
  caption: "normal equations"
)

#pagebreak()

= Lec 9: clustering

下面只列出要点
- k-mean 算法(更新规则和整个流程)
- K-nearest neighbor

= Lec 10: Neural network

这一节简单介绍了NN的内容

下面只列出要点
- 激活函数是非线性的原因(线性的组合依旧是线性的，所以分类要线性可分才行，但是大部分问题都不是线性可分的，xor的例子)
- NN可以自动学习边界
- CNN, 卷积, kernal, 全连接层

卷积神经网络的两大核心设计特征
+ 局部连接（Local Connectivity）
  - 神经元仅与输入图像的局部感受野相连。
  - 利用图像的空间局部相关性。
  - 显著减少连接数量。
+ 权重共享（Weight Sharing）
  - 同一卷积核在输入的不同位置使用相同的参数。
  - 能够检测平移不变的模式（如边缘、纹理）。
  - 大幅降低参数量。
+ 带来的优势
- *减少过拟合风险*：参数总量下降，模型复杂度可控。
- *支持深层网络构建*：每层参数不随层数线性增长，使得堆叠更多卷积层变得可行，从而提取更高层次的抽象特征。

\
后面其实和实验的内容差不多, 做过实验就会了解
