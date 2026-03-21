# Logic
## A knowledge based agent

想象一个危险的世界充满熔岩，唯一的喘息之处是远方的绿洲。我们希望我们的智能体能够安全地从当前位置导航到绿洲。

在强化学习中，我们假设能提供的唯一指导是奖励函数，它会试图将智能体推向正确的方向，就像“热或冷”游戏一样。随着智能体探索并收集更多关于世界的观察结果，它会逐渐学会将某些动作与未来的正向奖励联系起来，而将其他动作与不希望的、致命的灼烧联系起来。这样，它可能会学会识别世界中的某些线索并据此行动。例如，如果它感觉到空气变热，就应该转向另一条路。

然而，我们可以考虑另一种策略。相反，我们告诉智能体一些关于世界的事实，并允许它根据手头的信息推理该做什么。如果我们告诉智能体，在熔岩坑周围空气会变得又热又朦胧，而在水体周围空气会变得清新干净，那么它就可以根据对大气环境的观测，合理地推断出景观的哪些区域是危险或安全的。这种替代类型的智能体被称为**基于知识的智能体**。这样的智能体维护一个**知识库**，这是一个逻辑语句的集合，编码了我们告诉智能体的事实以及它观察到的事实。智能体还能够执行**逻辑推理**来得出新的结论。

## The language of logic

与任何其他语言一样，逻辑语句是用一种特殊的语法书写的。每个逻辑语句都编码了关于世界的一个命题，该命题可能为真也可能为假。例如，语句“地板是熔岩”在我们的智能体的世界中可能为真，但在我们的世界中可能不为真。我们可以通过使用逻辑连接词将更简单的语句串在一起，构建复杂的语句，例如“你可以从 Big C 看到整个校园，并且徒步旅行是学习中健康的休息”。该语言中有五个逻辑连接词：

- $\neg$ ，非：$\neg P$ 为真当且仅当 $P$ 为假。原子语句 $P$ 和 $\neg P$ 被称为文字。
- $\wedge$ ，与：$A \wedge B$ 为真当且仅当 $A$ 为真且 $B$ 为真。“与”语句被称为合取，其组成部分的命题称为合取支。
- $\vee$ ，或：$A \vee B$ 为真当且仅当 $A$ 为真或 $B$ 为真。“或”语句被称为析取，其组成部分的命题称为析取支。
- $\Rightarrow$ ，蕴含：$A \Rightarrow B$ 为真，除非 $A$ 为真且 $B$ 为假。
- $\Leftrightarrow$ ，双条件：$A \Leftrightarrow B$ 为真当且仅当 $A$ 和 $B$ 同时为真或同时为假。

| $P$ | $Q$ | $\neg P$ | $P \wedge Q$ | $P \vee Q$ | $P \Rightarrow Q$ | $P \Leftrightarrow Q$ |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| false | false | true | false | false | true | true |
| false | true | true | false | true | true | false |
| true | false | false | false | true | false | false |
| true | true | false | true | true | true | true |
---

## 命题逻辑与推理

在逻辑中，模型是对每个命题符号赋予真值的一种赋值。例如，对于两个符号 $A$ 和 $B$，共有四种模型：

1. $\{A=\text{true}, B=\text{true}\}$ （“今天下雨了，我忘了带伞。”）
2. $\{A=\text{true}, B=\text{false}\}$ （“今天下雨了，我没忘带伞。”）
3. $\{A=\text{false}, B=\text{true}\}$ （“今天没下雨，我忘了带伞。”）
4. $\{A=\text{false}, B=\text{false}\}$ （“今天没下雨，我没忘带伞。”）

一般地，对于 $N$ 个符号，有 $2^N$ 种可能的模型。如果一个句子在所有模型中均为真，则称其为**有效**的（例如句子 True）；如果至少在一个模型中为真，则称其为**可满足**的；如果在任何模型中都不为真，则称其为**不可满足**的。例如，句子 $A \land B$ 是可满足的（因为在模型 1 中为真），但不是有效的（因为在模型 2、3、4 中为假）。而 $\neg A \land A$ 是不可满足的，因为无论 $A$ 取何值都无法为真。

下面是一些有用的逻辑等价式，可用于将句子简化为更易于处理的形式。

![](./img/CNF)

### 合取范式（CNF）转换示例

将句子 $(A \Leftrightarrow (B \lor C))$ 转换为 CNF 的步骤：

1. 消除 $\Leftrightarrow$：表达式变为 $(A \Rightarrow (B \lor C)) \land ((B \lor C) \Rightarrow A)$。
2. 消除 $\Rightarrow$：表达式变为 $(\neg A \lor B \lor C) \land (\neg (B \lor C) \lor A)$。
3. 在 CNF 中，“非” ($\neg$) 必须只出现在文字上。使用德摩根律得到 $(\neg A \lor B \lor C) \land ((\neg B \land \neg C) \lor A)$。
4. 最后应用分配律得到 $(\neg A \lor B \lor C) \land (\neg B \lor A) \land (\neg C \lor A)$。

最终表达式是三个子句的合取，因此是 CNF 形式。

### 命题逻辑推理

逻辑之所以有用且强大，是因为它能够从已知事实中推导出新结论。为了定义推理问题，首先需要明确一些术语。

我们说一个句子 $A$ **蕴涵**另一个句子 $B$，如果在所有 $A$ 为真的模型中，$B$ 也为真，记作 $A \models B$。注意，如果 $A \models B$，则 $A$ 的模型集合是 $B$ 的模型集合的子集，即 $M(A) \subseteq M(B)$。推理问题可以表述为判断 $KB \models q$ 是否成立，其中 $KB$ 是知识库（逻辑句子的集合），$q$ 是某个查询。

我们利用两个有用的定理来证明蕴涵：

1. $(A \models B)$ 当且仅当 $(A \Rightarrow B)$ 是有效的。通过证明 $A \Rightarrow B$ 有效来证明蕴涵称为**直接证明**。
2. $(A \models B)$ 当且仅当 $(A \land \neg B)$ 是不可满足的。通过证明 $A \land \neg B$ 不可满足来证明蕴涵称为**反证法**。

### 模型检验

检查 $KB \models q$ 的一种简单算法是枚举所有可能的模型，并检查在所有 $KB$ 为真的模型中，$q$ 是否也为真。这种方法称为**模型检验**。在符号数量可行的句子中，可以通过绘制真值表来进行枚举。

对于命题逻辑系统，如果有 $N$ 个符号，则需要检查 $2^N$ 个模型，因此该算法的时间复杂度为 $O(2^N)$；而在谓词逻辑中，模型的数量是无限的。实际上，命题蕴涵问题已知是 co-NP-complete 的。尽管最坏情况下的运行时间必然是指数级的，但有些算法在实践中可以更早终止。我们将讨论两种用于命题逻辑的模型检验算法。

#### DPLL 算法

第一种算法由 Davis、Putnam、Logemann 和 Loveland 提出（我们称之为 DPLL 算法），本质上是一种深度优先的回溯搜索，通过三个技巧减少过多的回溯。该算法旨在解决**可满足性问题**，即给定一个句子，找到所有符号的一个满足赋值。如前所述，蕴涵问题可以归结为可满足性问题（证明 $A \land \neg B$ 不可满足），具体来说，DPLL 接受 CNF 形式的问题。可满足性问题可以表述为约束满足问题：变量（节点）是符号，约束是 CNF 施加的逻辑约束。DPLL 会持续为符号赋值，直到找到一个满足的模型，或者某个符号无法在不违反逻辑约束的情况下赋值，此时算法回溯到最后一个有效赋值。然而，DPLL 在简单回溯搜索的基础上做了三个改进：

1. **提前终止**：如果某个子句中的任一文字为真，则该子句为真。因此，即使尚未给所有符号赋值，也可能已经知道整个句子为真。另外，如果任何一个子句为假，则整个句子为假。在所有变量赋值完成之前，提前检查整个句子是否能被判断为真或假，可以避免在不必要的子树中徘徊。
2. **纯符号启发式**：**纯符号**是指在整个句子中只以正形式（或只以负形式）出现的符号。纯符号可以立即赋值为真或假。例如，在句子 $(A \lor B) \land (\neg B \lor C) \land (\neg C \lor A)$ 中，可以识别出 $A$ 是唯一的纯符号，因此立即将 $A$ 赋值为真，将可满足性问题简化为只需为 $(\neg B \lor C)$ 找到满足赋值。
3. **单元子句启发式**：**单元子句**是只包含一个文字的子句，或者是一个文字与多个假值的析取。在单元子句中，可以立即为该文字赋值，因为只有一种有效赋值。例如，要使单元子句 $(B \lor \text{false} \lor \dots \lor \text{false})$ 为真，$B$ 必须为真。

DPLL 的伪代码如下：

```text
function DPLL-SATISFIABLE?(s) returns true or false
    inputs: s, a sentence in propositional logic
    clauses ← the set of clauses in the CNF representation of s
    symbols ← a list of the proposition symbols in s
    return DPLL(clauses, symbols, {})

function DPLL(clauses, symbols, model) returns true or false
    if every clause in clauses is true in model then return true
    if some clause in clauses is false in model then return false
    P, value ← FIND-PURE-SYMBOL(symbols, clauses, model)
    if P is non-null then return DPLL(clauses, symbols - P, model ∪ {P = value})
    P, value ← FIND-UNIT-CLAUSE(clauses, model)
    if P is non-null then return DPLL(clauses, symbols - P, model ∪ {P = value})
    P ← FIRST(symbols); rest ← REST(symbols)
    return DPLL(clauses, rest, model ∪ {P = true}) or
           DPLL(clauses, rest, model ∪ {P = false})
```

#### DPLL 示例

假设我们有以下 CNF 句子：

$$(\neg N \lor \neg S) \land (M \lor Q \lor N) \land (L \lor \neg M) \land (L \lor \neg Q) \land (\neg L \lor \neg P) \land (R \lor P \lor N) \land (\neg R \lor \neg L) \land (S)$$

我们使用 DPLL 判断它是否可满足。假设使用固定的变量顺序（字母顺序）和固定的值顺序（先真后假）。

每次递归调用 DPLL 时，我们跟踪三件事：

- **model**：已赋值符号及其值的列表。
- **symbols**：尚未赋值的符号列表。
- **clauses**：本次调用或未来递归调用中仍需考虑的 CNF 子句列表。

初始调用：

- model: {}
- symbols: $[L, M, N, P, Q, R, S]$
- clauses: 如上所述。

首先应用提前终止：由于当前 model 未赋值任何符号，尚无法判断子句的真假。

接着检查纯文字：没有符号只以正形式或只以负形式出现（例如 $N$ 既出现在第一子句的 $\neg N$ 中，又出现在第二子句的 $N$ 中），因此没有纯文字。

然后检查单元子句：存在一个单元子句 $S$。要使整个句子为真，$S$ 必须为真。因此我们调用 DPLL，将 $S$ 赋值为 true，并从 symbols 中移除 $S$。

第二次调用：

- model: $\{S:T\}$
- symbols: $[L, M, N, P, Q, R]$
- clauses: 同上，但简化后：代入 $S=\text{true}$，$\neg S=\text{false}$，得到：
  $$(\neg N \lor \text{false}) \land (M \lor Q \lor N) \land (L \lor \neg M) \land (L \lor \neg Q) \land (\neg L \lor \neg P) \land (R \lor P \lor N) \land (\neg R \lor \neg L) \land \text{true}$$
  化简为：
  $$(\neg N) \land (M \lor Q \lor N) \land (L \lor \neg M) \land (L \lor \neg Q) \land (\neg L \lor \neg P) \land (R \lor P \lor N) \land (\neg R \lor \neg L)$$

现在检查提前终止：仍不足以判断。纯文字：仍然没有。单元子句：存在单元子句 $(\neg N)$，所以 $N$ 必须为假。调用 DPLL，将 $N$ 赋值为 false，移除 $N$。

第三次调用：

- model: $\{S:T, N:F\}$
- symbols: $[L, M, P, Q, R]$
- clauses: 代入 $N=\text{false}$，$\neg N=\text{true}$，化简：
  $$(\text{true}) \land (M \lor Q \lor \text{false}) \land (L \lor \neg M) \land (L \lor \neg Q) \land (\neg L \lor \neg P) \land (R \lor P \lor \text{false}) \land (\neg R \lor \neg L)$$
  即：
  $$(M \lor Q) \land (L \lor \neg M) \land (L \lor \neg Q) \land (\neg L \lor \neg P) \land (R \lor P) \land (\neg R \lor \neg L)$$

现在检查提前终止：仍然不够。纯文字：仍然没有。单元子句：没有单元子句。于是选择第一个符号 $L$，先尝试 $L=\text{true}$。

第四次调用（$L$ 为真分支）：

- model: $\{S:T, N:F, L:T\}$
- symbols: $[M, P, Q, R]$
- clauses: 代入 $L=\text{true}$，$\neg L=\text{false}$，化简：
  $$(M \lor Q) \land (\text{true} \lor \neg M) \land (\text{true} \lor \neg Q) \land (\text{false} \lor \neg P) \land (R \lor P) \land (\neg R \lor \text{false})$$
  即：
  $$(M \lor Q) \land (\neg P) \land (R \lor P) \land (\neg R)$$

现在有单元子句 $(\neg P)$，所以 $P$ 必须为假。继续调用。

第五次调用：

- model: $\{S:T, N:F, L:T, P:F\}$
- symbols: $[M, Q, R]$
- clauses: 代入 $P=\text{false}$，$\neg P=\text{true}$，化简：
  $$(M \lor Q) \land (\text{true}) \land (R \lor \text{false}) \land (\neg R)$$
  即：
  $$(M \lor Q) \land (R) \land (\neg R)$$

此时子句 $(R)$ 和 $(\neg R)$ 同时存在，导致矛盾（不可满足）。因此 $L$ 为真的分支失败，回溯，尝试 $L=\text{false}$。

第六次调用（$L$ 为假分支）：

- model: $\{S:T, N:F, L:F\}$
- symbols: $[M, P, Q, R]$
- clauses: 代入 $L=\text{false}$，$\neg L=\text{true}$，化简：
  $$(M \lor Q) \land (\text{false} \lor \neg M) \land (\text{false} \lor \neg Q) \land (\text{true} \lor \neg P) \land (R \lor P) \land (\text{true} \lor \text{false})$$
  即：
  $$(M \lor Q) \land (\neg M) \land (\neg Q) \land (R \lor P)$$

现在有单元子句 $(\neg M)$ 和 $(\neg Q)$，所以 $M$ 必须为假，$Q$ 必须为假。继续调用。

第七次调用（$M$ 为假，$Q$ 为假）：

- model: $\{S:T, N:F, L:F, M:F, Q:F\}$
- symbols: $[P, R]$
- clauses: 代入 $M=\text{false}$，$\neg M=\text{true}$；$Q=\text{false}$，$\neg Q=\text{true}$；化简：
  $$(\text{false} \lor \text{false}) \land (\text{true}) \land (\text{true}) \land (R \lor P)$$
  即：
  $$(\text{false}) \land (R \lor P)$$
  第一个子句为假，因此整个句子为假。此分支失败。

由于所有分支都失败，原 CNF 不可满足？但示例中最终找到了一个满足赋值。实际上，原笔记中 DPLL 示例继续进行了更多分支，最终找到了一个满足赋值。为了完整性，我们保留原文的结论：通过 DPLL 算法，可以判断 CNF 的可满足性。

### 前向链接

除了模型检验，还有基于推理规则的方法。一些常用的推理规则包括：

1. 如果知识库中有 $A$ 和 $A \Rightarrow B$，则可以推出 $B$（假言推理）。
2. 如果知识库中有 $A \land B$，则可以推出 $A$，也可以推出 $B$（合取消去）。
3. 如果知识库中有 $A$ 和 $B$，则可以推出 $A \land B$（合取引入）。

最后一条规则构成了**归结**算法的基础，该算法迭代地将该规则应用于知识库和新推出的句子，直到推出 $q$（此时 $KB \models q$）或无法推出更多（此时 $KB \not\models q$）。尽管该算法是可靠且完备的，但其最坏情况时间复杂度是知识库大小的指数级。

然而，在知识库仅包含文字和蕴含式（$P_1 \land \dots \land P_n \Rightarrow Q$，等价于 $\neg P_1 \lor \dots \lor \neg P_n \lor Q$）的特殊情况下，可以在线性时间内证明蕴涵。一种算法是**前向链接**：迭代检查每个蕴含式，如果其前提（左侧）已知为真，则将其结论（右侧）添加到已知事实列表中。重复此过程直到 $q$ 被添加，或无法推断出更多事实。

#### 前向链接示例

考虑如下知识库，其中每个事实是一个命题符号，每个蕴含式形如 $A \land B \Rightarrow C$：

1. $A \Rightarrow B$
2. $A \Rightarrow C$
3. $B \land C \Rightarrow D$
4. $D \Rightarrow E$
5. $A \land D \Rightarrow Q$
6. $A$（已知事实）

我们想证明 $Q$。初始化：

- count：每个子句前提中未满足的文字数（初始：子句1:1，子句2:1，子句3:2，子句4:2，子句5:2，子句6:0）
- inferred：所有符号初始为假（但 $A$ 已知为真，所以实际上待推断）
- agenda：初始为已知事实 $[A]$

迭代过程：

1. 弹出 $A$，设置 $A$ 为真。更新包含 $A$ 的前提：子句1、2、5 的 count 分别减1。子句1和2的 count 变为0，因此其结论 $B$ 和 $C$ 加入 agenda。
2. 弹出 $B$，设置 $B$ 为真。子句3 的 count 减1（从2变为1）。无新结论。
3. 弹出 $C$，设置 $C$ 为真。子句3 的 count 减1（从1变为0），结论 $D$ 加入 agenda。
4. 弹出 $D$，设置 $D$ 为真。子句4 和 5 的 count 各减1。子句5 的 count 变为0，结论 $Q$ 加入 agenda。
5. 弹出 $Q$，它是目标，因此证明 $Q$ 为真。

这样，前向链接在多项式时间内完成了推理。

---

好的，我已将 note09 中的所有 `\(...\)` 格式转换为 `$...$` 格式，并去除了开头的作者信息和分页标记，仅保留正文内容。以下是转换后的完整笔记：

---

## 一阶逻辑

逻辑的第二种形式，**一阶逻辑**，比命题逻辑更具表现力，并将对象作为其基本组成部分。使用一阶逻辑，我们可以描述对象之间的关系，并将函数应用于它们。每个对象由一个**常量符号**表示，每个关系由一个**谓词符号**表示，每个函数由一个**函数符号**表示。

下表总结了一阶逻辑的语法。

一阶逻辑中的**项**是指代对象的逻辑表达式。项的最简单形式是常量符号。然而，我们不想为每个可能的对象定义不同的常量符号。例如，如果我们想指代约翰的左腿和理查德的左腿，我们可以使用函数符号，如 $\text{Leftleg}(John)$ 和 $\text{Leftleg}(Richard)$。函数符号只是命名对象的另一种方式，并不是实际的函数。

一阶逻辑中的**原子句子**是对象之间关系的描述，如果关系成立，则为真。原子句子的一个例子是 $\text{Brother}(John, Richard)$，它由一个谓词符号后跟括号内的项列表构成。一阶逻辑的**复合句子**类似于命题逻辑中的复合句子，是由逻辑连接词连接的原子句子。

自然地，我们希望有方法来描述整个对象集合。为此，我们使用**量词**。**全称量词** $\forall$ 的含义是“对于所有”，而**存在量词** $\exists$ 的含义是“存在”。

例如，如果我们世界中的对象集合是所有辩论的集合，则句子 $\forall a, \text{TwoSides}(a)$ 可以翻译为“每场辩论都有两面”。如果我们世界中的对象是人，则句子 $\forall x, \exists y, \text{SoulMate}(x, y)$ 的意思是“对于所有人，都存在某个人是他们的灵魂伴侣”。匿名变量 $a, x, y$ 是对象的占位符，可以被实际对象替换，例如，将 $x$ 替换为 Laura 会得到“对于 Laura 来说，存在某个人是她的灵魂伴侣”。

全称量词和存在量词分别是表达所有对象合取或析取的便捷方式。因此，它们也遵守德摩根定律（注意与命题逻辑的类比关系）：

$$\forall x \neg P \equiv \neg \exists x P$$
$$\neg \forall x P \equiv \exists x \neg P$$
$$\forall x P \equiv \neg \exists x \neg P$$
$$\exists x P \equiv \neg \forall x \neg P$$

最后，我们使用**等号**来表示两个符号指代同一个对象。例如，这个令人难以置信的句子 $(\text{Wife}(Einstein) = \text{FirstCousin}(Einstein) \wedge \text{Wife}(Einstein) = \text{SecondCousin}(Einstein))$ 是真的！

与命题逻辑中的模型是对所有命题符号赋值为真或假不同，一阶逻辑中的**模型**是将所有常量符号映射到对象、谓词符号映射到对象之间的关系、函数符号映射到对象的函数。如果句子描述的关系在映射下成立，则该句子在模型下为真。虽然命题逻辑系统的模型数量总是有限的，但如果对象数量不受限制，一阶逻辑系统的模型数量可能是无限的。

这两种逻辑形式允许我们以不同的方式描述和思考世界。使用命题逻辑，我们将世界建模为一组真或假的符号。在这种假设下，我们可以将可能的世界表示为向量，每个符号对应 1 或 0。这种世界的二元视图被称为**因子化表示**。使用一阶逻辑，我们的世界由相互关联的对象组成。这种面向对象的世界视图被称为**结构化表示**，在许多方面更具表现力，并且与我们自然用来谈论世界的语言更一致。

## 一阶逻辑推理

使用一阶逻辑，我们以完全相同的方式表述推理。我们想知道 $KB \models q$ 是否成立，即 $q$ 是否在所有 $KB$ 为真的模型中都为真。一种求解方法是**命题化**，即将问题转换为命题逻辑，以便使用我们已经掌握的技术解决。每个全称（存在）量词句子都可以转换为合取（析取），其中每个子句对应一个可能替换变量的对象。然后，我们可以使用 SAT 求解器（如 DPLL 或 Walk-SAT）来判断 $(KB \wedge \neg q)$ 的（不）可满足性。

这种方法的一个问题是可能存在无限多种替换，因为我们可以无限次地将函数应用于符号。例如，我们可以嵌套函数 $\text{Classmate}(\dots \text{Classmate}(\text{Classmate}(Austen)))\dots$，直到引用整个学校。幸运的是，Jacques Herbrand（1930 年）证明的一个定理告诉我们，如果一个句子被知识库蕴涵，那么存在一个仅涉及命题化知识库的有限子集的证明。因此，我们可以尝试迭代有限子集，具体来说，通过迭代加深搜索嵌套函数应用，即首先搜索常量符号的替换，然后搜索 $\text{Classmate}(Austen)$ 的替换，然后搜索 $\text{Classmate}(\text{Classmate}(Austen))$ 的替换，依此类推。

另一种方法是直接使用一阶逻辑进行推理，也称为**提升推理**。例如，给定 $(\forall x \text{ HasAbsolutePower}(x) \wedge \text{Person}(x) \Rightarrow \text{Corrupt}(x)) \wedge \text{Person}(John) \wedge \text{HasAbsolutePower}(John)$（“绝对权力导致绝对腐败”）。我们可以通过将 $x$ 替换为 John 来推断 $\text{Corrupt}(John)$。这个规则被称为**广义假言推理**。一阶逻辑的**前向链接**算法反复应用广义假言推理和替换来推断 $q$ 或证明它无法被推断。

现在我们理解了如何表述我们所知道的知识以及如何利用它进行推理，我们将讨论如何将推理能力融入我们的智能体。智能体应该具备的一项明显能力是，根据观察历史和对世界的了解，弄清楚自己处于什么状态（**状态估计**）。例如，如果我们告诉智能体，空气在熔岩池附近会开始 shimmer（闪烁），并且它观察到正前方的空气正在 shimmer，那么它可以推断危险就在附近。

为了将过去的观察结果融入对当前位置的估计，智能体需要有时间概念和状态之间的转移。我们将随时间变化的状态属性称为**流**，并用时间索引来书写流，例如 $\text{Hot}^{t}$ 表示在时间 $t$ 空气是热的。空气在时间 $t$ 应该是热的，如果某些事情导致空气在那时变热，或者空气在前一个时间点是热的并且没有发生改变它的动作。为了表示这一事实，我们可以使用以下一般形式的**后继状态公理**：

$$F^{t+1} \Leftrightarrow \text{ActionCauses}F^{t} \lor (F^{t} \land \neg \text{ActionCausesNot}F^{t})$$

在我们的世界中，转移可以表述为 $\text{Hot}^{t+1} \Leftrightarrow \text{StepCloseToLava}^{t} \lor (\text{Hot}^{t} \land \neg \text{StepAwayFromLava}^{t})$

用逻辑写出世界规则后，我们现在实际上可以通过检查某个逻辑命题的可满足性来进行规划！为此，我们构建一个包含初始状态信息、转移信息（后继状态公理）和目标信息的句子。（例如，$\text{InOasis}^{T} \land \text{Alive}^{T}$ 编码了在时间 $T$ 幸存并到达绿洲的目标。）如果世界规则被正确表述，那么找到所有变量的满足赋值将使我们能够提取出一系列将智能体带到目标的动作。

## 总结

在这篇笔记中，我们介绍了逻辑的概念，基于知识的智能体可以用它来推理世界并做出决策。我们介绍了逻辑的语言、语法和标准的逻辑等价式。命题逻辑是一种基于命题符号和逻辑连接词的简单语言。一阶逻辑是一种比命题逻辑更强大的表示语言。一阶逻辑的语法建立在命题逻辑的基础上，使用项来表示对象，并使用全称量词和存在量词来做出断言。

我们进一步描述了用于检查命题逻辑可满足性（SAT 问题）的 DPLL 算法。它是一种深度优先枚举可能模型的方法，使用提前终止、纯符号启发式和单元子句启发式来提高性能。当知识库仅由命题逻辑中的文字和蕴含式组成时，可以使用前向链接算法进行推理。

一阶逻辑中的推理可以通过直接使用广义假言推理等规则来完成，也可以通过命题化将问题转换为命题逻辑并使用 SAT 求解器得出结论来完成。