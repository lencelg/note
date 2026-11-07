# Advanced Graphs

Advanced graph problems involve weighted edges, which require more sophisticated
algorithms than simple BFS or DFS.

**Dijkstra's algorithm** finds the shortest path in a weighted graph using a min-heap.

**Prim's and Kruskal's algorithms** find the minimum spanning tree, connecting all
nodes at minimum total cost.

These algorithms are more complex than anything seen so far, and the problems
here often combine the algorithm with an additional constraint,
such as a limit on the number of steps or a non-standard cost function.

Understanding the conditions under which each algorithm applies is as important
as knowing how to implement it.

## 743. 网络延迟问题

Dijkstra's algorithm

````cpp
int networkDelayTime(vector<vector<int>> &times, int n, int k) {
    vector<int> dist(n + 1, INT_MAX);
    dist[k] = 0;
    vector<vector<pair<int, int>>> graph(n + 1);
    for (auto &p : times) {
        graph[p[0]].push_back({p[1], p[2]});
    }

    priority_queue<pair<int, int>, vector<pair<int, int>>, greater<>>
        minHeap;

    minHeap.push({0, k});
    while (!minHeap.empty()) {
        auto [cost, u] = minHeap.top();
        minHeap.pop();

        if (cost > dist[u])
            continue;

        for (auto &p : graph[u]) {
            int v = p.first;
            int w = p.second;
            if (dist[u] != INT_MAX && dist[u] + w < dist[v]) {
                dist[v] = dist[u] + w;
                minHeap.push({dist[v], v});
            }
        }
    }

    int ans = *max_element(dist.begin() + 1, dist.end());
    return ans == INT_MAX ? -1 : ans;
}
````

[题解页](https://leetcode.cn/problems/network-delay-time/solutions)，大概就是两种写法，一种是朴素版的，一种是最小堆版的

## 1584. 连接所有点的最小费用

最小生成树，大抵有两种写法

- 堆版Prim算法
- 朴素Prim 算法

````cpp
int minCostConnectPoints(vector<vector<int>> &points) {
    // <distance, point index>
    typedef pair<int, int> pii;
    vector<vector<pii>> graph(points.size());
    for (size_t i = 0; i < points.size(); i++) {
        for (size_t j = i + 1; j < points.size(); j++) {
            int dist = abs(points[j][0] - points[i][0]) +
                       abs(points[j][1] - points[i][1]);
            graph[i].push_back({dist, j});
            graph[j].push_back({dist, i});
        }
    }
    vector<bool> visited(points.size(), false);
    priority_queue<pii, vector<pii>, greater<>> minHeap;
    minHeap.push({0, 0});
    int ans = 0;
    while (!minHeap.empty()) {
        auto [d, pIdx] = minHeap.top();
        minHeap.pop();

        if (visited[pIdx])
            continue;

        visited[pIdx] = true;
        ans += d;

        for (auto &otherPoint : graph[pIdx]) {
            auto [od, oIdx] = otherPoint;

            if(visited[oIdx])
                continue;

            minHeap.push(otherPoint);
        }
    }
    return ans;
}
````

````cpp
int minCostConnectPoints(vector<vector<int>> &points) {
    int n = points.size();
    vector<bool> visited(n, false);
    vector<int> dist(n, INT_MAX);
    dist[0] = 0;
    int ans = 0;
    for (int i = 0; i < n; i++) {
        int cur = -1;
        int min_cost = INT_MAX;
        for (int j = 0; j < n; j++) {
            if (!visited[j] && dist[j] <= min_cost) {
                cur = j;
                min_cost = dist[j];
            }
        }
        visited[cur] = true;
        ans += min_cost;
        for (int j = 0; j < n; j++) {
            if (!visited[j]) {
                int new_distance = abs(points[cur][0] - points[j][0]) +
                                   abs(points[cur][1] - points[j][1]);
                dist[j] = min(dist[j], new_distance);
            }
        }
    }

    return ans;
}
````

[题解页](https://leetcode.cn/problems/min-cost-to-connect-all-points/solutions)，看了题解发现还有并查集写法

## 787. K 站中转内最便宜的航班

Bellman-Ford算法

````cpp
class Solution {
public:
    int findCheapestPrice(int n, vector<vector<int>>& flights, int src, int dst, int k) {
        vector<int> dist(n, INT_MAX);
        dist[src] = 0;

        for (int i = 0; i <= k; i++) {
            vector<int> temp = dist; 
            
            for (const auto& f : flights) {
                int u = f[0], v = f[1], w = f[2];
                if (dist[u] != INT_MAX) {
                    temp[v] = min(temp[v], dist[u] + w);
                }
            }
            dist = temp;
        }

        return dist[dst] == INT_MAX ? -1 : dist[dst];
    }
};
````

[题解页](https://leetcode.cn/problems/cheapest-flights-within-k-stops/solutions)

## 778. 水位上升的泳池中游泳

可以写成bfs

````cpp
int swimInWater(vector<vector<int>> &grid) {
    typedef tuple<int, int, int> tiii;
    int m = grid.size(), n = grid[0].size();
    int end = grid[m - 1][n - 1];

    constexpr int dirs[4][2] = {{0, 1}, {0, -1}, {-1, 0}, {1, 0}};
    vector<vector<bool>> visited(m, vector<bool>(n, false));
    priority_queue<tiii, vector<tiii>, greater<>> pq;
    pq.push({grid[0][0], 0, 0});
    int cnt = 0;
    while (!pq.empty()) {
        auto [v, i, j] = pq.top();
        pq.pop();

        cnt = max(v, cnt);
        visited[i][j] = true;

        if (v == end)
            break;

        for (int d = 0; d < 4; d++) {
            int ni = i + dirs[d][0], nj = j + dirs[d][1];
            if (0 <= ni && ni < m && 0 <= nj && nj < n) {
                if (!visited[ni][nj])
                    pq.push({grid[ni][nj], ni, nj});
            }
        }
    }
    return cnt;
}
````

改进：原地修改`grid`来记录访问的节点

````cpp
int swimInWater(vector<vector<int>> &grid) {
    typedef tuple<int, int, int> tiii;
    int m = grid.size(), n = grid[0].size();
    int end = grid[m - 1][n - 1];

    constexpr int dirs[4][2] = {{0, 1}, {0, -1}, {-1, 0}, {1, 0}};
    priority_queue<tiii, vector<tiii>, greater<>> pq;
    pq.push({grid[0][0], 0, 0});
    int cnt = 0;
    while (!pq.empty()) {
        auto [v, i, j] = pq.top();
        pq.pop();

        cnt = max(v, cnt);
        grid[i][j] = -1;

        if (v == end)
            break;

        for (int d = 0; d < 4; d++) {
            int ni = i + dirs[d][0], nj = j + dirs[d][1];
            if (0 <= ni && ni < m && 0 <= nj && nj < n) {
                if (grid[ni][nj] != -1)
                    pq.push({grid[ni][nj], ni, nj});
            }
        }
    }
    return cnt;
}
````

[题解页](https://leetcode.cn/problems/swim-in-rising-water/solutions)，另外的写法是二分答案，并查集，标准Dijkstra

## 332. 重新安排行程

败下阵来，这是一道欧拉回路的题目

下面是deepseek c端题解

````cpp
// 使用优先队列（小根堆），自动让目的地按字典序从小到大排列
unordered_map<string, priority_queue<string, vector<string>, greater<string>>> graph;
vector<string> ans;

void dfs(const string& curr) {
    // 只要当前节点还有出边的机票
    while (!graph[curr].empty()) {
        string next = graph[curr].top();
        graph[curr].pop(); // 用完这张票就删掉
        
        dfs(next); // 继续深搜
    }
    // 当这个节点没有出边时，加入答案（回溯时加入）
    ans.push_back(curr);
}

vector<string> findItinerary(vector<vector<string>>& tickets) {
    // 1. 建图
    for (const auto& ticket : tickets) {
        graph[ticket[0]].push(ticket[1]);
    }

    // 2. 从 JFK 开始 DFS
    dfs("JFK");

    // 3. 因为是回溯时加入的，此时 ans 是从终点到起点的逆序，需要反转
    reverse(ans.begin(), ans.end());
    
    return ans;
}
````

````cpp
unordered_map<string, vector<string>> graph;
vector<string> ans;

void dfs(const string& curr) {
    auto& dests = graph[curr];
    while (!dests.empty()) {
        string next = dests.back(); // 从后往前取（即字典序最小的）
        dests.pop_back();
        dfs(next);
    }
    ans.push_back(curr);
}

vector<string> findItinerary(vector<vector<string>>& tickets) {
    for (const auto& ticket : tickets) {
        graph[ticket[0]].push_back(ticket[1]);
    }
    // 对每个目的地的 vector 进行降序排序
    for (auto& pair : graph) {
        sort(pair.second.begin(), pair.second.end(), greater<string>());
    }
    dfs("JFK");
    reverse(ans.begin(), ans.end());
    return ans;
}
````

[题解页](https://leetcode.cn/problems/reconstruct-itinerary/solutions/)

## 1514. 概率最大的路径

Dijkstra's algorithm的变形题

````cpp
double maxProbability(int n, vector<vector<int>> &edges,
                      vector<double> &succProb, int start_node,
                      int end_node) {

    // <to, prob> pair
    vector<vector<pair<int, double>>> graph(n);
    for (size_t i = 0; i < edges.size(); i++) {
        graph[edges[i][0]].push_back({edges[i][1], succProb[i]});
        graph[edges[i][1]].push_back({edges[i][0], succProb[i]});
    }

    vector<double> prob(n, 0);
    prob[start_node] = 1;

    // <prob, to> pair
    priority_queue<pair<double, int>> pq;
    pq.push({1, start_node});
    while (!pq.empty()) {
        auto [p, u] = pq.top();
        pq.pop();

        if (p < prob[u])
            continue;

        for (auto &[v, op] : graph[u]) {
            if (prob[v] < op * p) {
                prob[v] = op * p;
                pq.push({prob[v], v});
            }
        }
    }
    return prob[end_node];
}
````

## 1334. 阈值内邻居城市最小的城市

对每个节点都进行一次 Dijkstra's algorithm，记录第一次访问的节点

````cpp
int findTheCity(int n, vector<vector<int>> &edges, int distanceThreshold) {
    // <weight, to> pair
    typedef pair<int, int> pii;
    vector<vector<pii>> graph(n);
    for (auto &edge : edges) {
        graph[edge[0]].push_back({edge[2], edge[1]});
        graph[edge[1]].push_back({edge[2], edge[0]});
    }

    int min_cnt = INT_MAX;
    int ans = 0;
    for (size_t i = 0; i < n; i++) {
        vector<int> dist(n, INT_MAX);
        priority_queue<pii, vector<pii>, greater<>> pq;
        dist[i] = 0;
        pq.push({0, i});
        int cnt = 0;
        while (!pq.empty()) {
            auto [w, u] = pq.top();
            pq.pop();

            if (w > distanceThreshold || w > dist[u])
                continue;

            for (auto [ow, v] : graph[u]) {
                if (dist[v] > ow + w && ow + w <= distanceThreshold) {
                    // 第一次访问这个节点
                    if (dist[v] == INT_MAX)
                        cnt++;
                    dist[v] = ow + w;
                    pq.push({dist[v], v});
                }
            }
            if (cnt > min_cnt)
                break;
        }

        if (cnt <= min_cnt) {
            min_cnt = cnt;
            ans = i;
        }
    }
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/find-the-city-with-the-smallest-number-of-neighbors-at-a-threshold-distance/solutions/2525946/dai-ni-fa-ming-floyd-suan-fa-cong-ji-yi-m8s51)，灵神这道题的题解无敌

看了题解发现这道题本质是**多源最短路径（All-Pairs Shortest Path）问题**，Floyd 算法（Floyd-Warshall 算法）是这里的经典算法

下面的笔记来自deepseek c端改写

Floyd 的本质是一个非常精妙的动态规划。
假设要从节点 `i` 走到节点 `j`，我们有两种选择：

1. 直接走过去。
2. 找一个“中间人” `k`，先走 `i -> k`，再走 `k -> j`。

状态转移方程为：

```text
dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])
```

**重点在于循环的顺序**：最外层的循环变量 `k` 必须是“中间节点”这代表我们在逐步允许中转站：先只允许通过 0 号点中转，再允许通过 1 号点中转……直到允许通过所有点。

C++ 代码实现

```cpp
const int INF = 1e9; // 使用 1e9 代替 INT_MAX 防止加法溢出

void floyd(int n, vector<vector<int>>& dist) {
    // 核心：三层循环，k (中间节点) 必须在最外层！
    for (int k = 0; k < n; k++) {
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                // 尝试通过 k 进行中转，看能否缩短距离
                if (dist[i][k] < INF && dist[k][j] < INF) {
                    dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j]);
                }
            }
        }
    }
}
```

Floyd 适合**节点数非常少**的图（通常 $N \le 500 $。

- **时间复杂度**：$O(N^3)$。因为有三层循环。
- **空间复杂度**：$O(N^2)$。需要一个二维数组存图。
- **支持负权边**：只要图里**没有负权环**，Floyd 也能求对。

| 特性 | Dijkstra (堆优化) | Floyd |
| :--- | :--- | :--- |
| **解决问题** | 单源最短路径 (一个点到其他点) | **多源最短路径** (任意两点间) |
| **时间复杂度** | $O(E \log V)$ | $O(V^3)$ |
| **适用图规模** | 大规模（稀疏图） | 小规模（稠密图，或 $V \le 200 \sim 500)$ |
| **负权边** | **不支持**（必须全正） | **支持**（不能有负权环） |

## 1091. 二进制矩阵中的最短距离

最容易想到的就是bfs，其次就是A\*，但是A\*写法要设计启发式函数，这里的启发式函数是**切比雪夫距离**

````cpp
int shortestPathBinaryMatrix(vector<vector<int>> &grid) {
    int m = grid.size(), n = grid[0].size();

    if (grid[0][0] == 1 || grid[m - 1][n - 1] == 1)
        return -1;
    if (m == 1 && n == 1)
        return 1;

    int dirs[8][2] = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1},
                      {0, 1},   {1, -1}, {1, 0},  {1, 1}};

    queue<pair<int, int>> q;
    q.push({0, 0});
    grid[0][0] = 1;

    int steps = 1;

    while (!q.empty()) {
        int size = q.size();

        while (size--) {
            auto [i, j] = q.front();
            q.pop();

            for (auto &dir : dirs) {
                int ni = i + dir[0];
                int nj = j + dir[1];

                if (ni == m - 1 && nj == n - 1) {
                    return steps + 1;
                }

                if (ni >= 0 && ni < m && nj >= 0 && nj < n &&
                    grid[ni][nj] == 0) {
                    grid[ni][nj] = 1;
                    q.push({ni, nj});
                }
            }
        }
        steps++;
    }
    return -1;
}
````

A\* 写法，下面是deepseek c端写的，我写的启发式函数是曼哈顿距离|欧式几何距离 + 步长 的比较，结果发现失败了

````cpp
int shortestPathBinaryMatrix(vector<vector<int>>& grid) {
    int m = grid.size(), n = grid[0].size();
    if (grid[0][0] == 1 || grid[m-1][n-1] == 1) return -1;
    if (m == 1 && n == 1) return 1;

    // 切比雪夫距离：8 方向网格的正确启发函数
    auto h = [&](int x, int y) {
        return max(abs(x - (m - 1)), abs(y - (n - 1)));
    };

    // 比较器：优先按 f = g + h 排序，g 越小越优先
    auto cmp = [&](const tuple<int, int, int>& a, const tuple<int, int, int>& b) {
        int fA = get<2>(a) + h(get<0>(a), get<1>(a));
        int fB = get<2>(b) + h(get<0>(b), get<1>(b));
        return fA > fB; // 大于号：f 越小，优先级越高 (小根堆)
    };

    // {x, y, g(当前步数)}
    priority_queue<tuple<int, int, int>, vector<tuple<int, int, int>>, decltype(cmp)> pq(cmp);
    pq.push({0, 0, 1});

    // 记录到达每个格子的最短步数
    vector<vector<int>> dist(m, vector<int>(n, INT_MAX));
    dist[0][0] = 1;

    int dirs[8][2] = {
        {-1, -1}, {-1, 0}, {-1, 1},
        {0, -1},           {0, 1},
        {1, -1},  {1, 0},  {1, 1}
    };

    while (!pq.empty()) {
        auto [i, j, g] = pq.top();
        pq.pop();

        // 到达终点，直接返回
        if (i == m - 1 && j == n - 1) return g;

        // 【关键】如果取出的步数已经大于记录了的最短步数，说明是废弃数据，跳过
        if (g > dist[i][j]) continue;

        for (auto& dir : dirs) {
            int ni = i + dir[0], nj = j + dir[1];

            if (ni >= 0 && ni < m && nj >= 0 && nj < n && grid[ni][nj] == 0) {
                int ng = g + 1; // 新步数
                // 只有当找到更短的路径时，才更新并入队
                if (ng < dist[ni][nj]) {
                    dist[ni][nj] = ng;
                    pq.push({ni, nj, ng});
                }
            }
        }
    }

    return -1;
}
````

[题解页](https://leetcode.cn/problems/shortest-path-in-binary-matrix/solutions)，大概看了一眼，就大概只有bfs和A\*
