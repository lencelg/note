---
author: lencelg from Arcadia Bay
title: Constraint Satisfaction Problems
---
# CSP
represent constraints with **constraint graph**

Consider map coloring the map of Australia:

![](./img/coloring)

![](./img/coloring%20graph)

# Solving CSP
**backtracking search**

![](./img/backtracking-search-pseudo.png)

visualization dfs and backtracking

![](./img/dfs-vs-backtracking.png)

## forward checking
use **forward checking** to prun the contradict condition to speed up
### arc-3
use arc to implement Arc consitstency

![](./img/arc-consistency-pseudo.png)

# PS
for the rest of note, refer to [official textbook CSP chapter](https://inst.eecs.berkeley.edu/~cs188/textbook/csp/)