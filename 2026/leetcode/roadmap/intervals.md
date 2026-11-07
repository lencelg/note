# Intervals

Interval problems appear frequently in scheduling, calendar, and range-based questions.

The dominant technique is sorting by start or end time, which turns an otherwise
quadratic overlap-checking problem into a linear scan.

Once sorted, you can merge overlaps, count simultaneous events, or find gaps with
a single pass.

The harder problems in this stage combine interval sorting with a heap to answer
queries efficiently.

The key mindset shift is thinking of intervals as objects with a start and end,
and reasoning about what it means for two intervals to overlap, contain, or be adjacent.

## 56. 合并区间

排序以后每次从最小起点开始合并

````cpp
vector<vector<int>> merge(vector<vector<int>>& intervals) {
    sort(intervals.begin(), intervals.end()); 
    vector<vector<int>> ans;
    int pre_start = intervals[0][0], pre_end = intervals[0][1];
    for(int i = 1; i < intervals.size(); i++){
        if(intervals[i][0] <= pre_end){
            pre_end = max(pre_end, intervals[i][1]);
        }else{
            ans.push_back({pre_start, pre_end});
            pre_start = intervals[i][0];
            pre_end = intervals[i][1];
        }
    }
    ans.push_back({pre_start, pre_end});
    return ans;
}
````

[题解页](https://leetcode.cn/problems/merge-intervals/solutions/)，这里题解的思路有不少

## 57. 插入区间

思路错了，原本想直接插入然后处理重叠的情形，但是解法不如三段处理的优雅

下面的代码来自deepseek c端

````cpp
vector<vector<int>> insert(vector<vector<int>>& intervals,
                            vector<int>& newInterval) {
    vector<vector<int>> ans;
    int i = 0, n = intervals.size();
    
    // 1. 把在 newInterval 左侧（无重叠）的区间直接加进去
    while (i < n && intervals[i][1] < newInterval[0]) {
        ans.push_back(intervals[i]);
        i++;
    }
    
    // 2. 处理所有与 newInterval 重叠的区间，进行融合
    while (i < n && intervals[i][0] <= newInterval[1]) {
        // 更新融合后新区间的起点和终点
        newInterval[0] = min(newInterval[0], intervals[i][0]);
        newInterval[1] = max(newInterval[1], intervals[i][1]);
        i++;
    }
    // 融合彻底结束后，把最终的 newInterval 放进结果
    ans.push_back(newInterval);
    
    // 3. 把剩下的右侧区间加进去
    while (i < n) {
        ans.push_back(intervals[i]);
        i++;
    }
    
    return ans;
}
````

官解评论区二分做法插入原本的数组然后移除重复的区间，不过时间复杂度低一些，删除再插入起码$O(2n)$了，不过就是代码简洁一些

下面的代码来自[子不語](https://leetcode.cn/u/jmc8/)

````cpp
vector<vector<int>> insert(vector<vector<int>>& intervals,
                            vector<int>& newInterval) {
    auto beg = intervals.begin(), end = intervals.end();
    int& a = newInterval[0], & b = newInterval[1];
    auto l = lower_bound(beg, end, a, [](auto& a, int b) { return a[1] < b; });
    auto r = upper_bound(  l, end, b, [](int b, auto& a) { return a[0] > b; });
    if (l != end) a = min(a, l[ 0][0]);
    if (r != beg) b = max(b, r[-1][1]);
    intervals.insert(intervals.erase(l, r), newInterval);
    return intervals;
}
````

## 1851. 包含每个查询的最小区间

败下阵来，这道题是离线查询

[题解页](https://leetcode.cn/problems/minimum-interval-to-include-each-query/solutions/)

````cpp
vector<int> minInterval(vector<vector<int>>& intervals, vector<int>& queries) {
    int n = intervals.size(), m = queries.size();
    vector<int> ans(m, -1);
    
    // 1. 将区间按左端点升序排序
    sort(intervals.begin(), intervals.end());
    
    // 2. 将查询按值升序排序，同时保存原始下标
    vector<pair<int, int>> sorted_q;
    for (int i = 0; i < m; i++) {
        sorted_q.push_back({queries[i], i});
    }
    sort(sorted_q.begin(), sorted_q.end());
    
    // 3. 小根堆：存储 {区间长度, 区间右端点}
    // 这样堆顶永远是目前覆盖当前查询的最短区间
    typedef pair<int, int> pii;
    priority_queue<pii, vector<pii, greater<pii>> pq;
    
    int i = 0; // 指向 intervals 的指针
    for (auto& [query, idx] : sorted_q) {
        // 把所有左端点 <= 当前查询值的区间加入堆中
        while (i < n && intervals[i][0] <= query) {
            int len = intervals[i][1] - intervals[i][0] + 1;
            pq.push({len, intervals[i][1]});
            i++;
        }
        
        // 弹出所有右端点 < 当前查询值的区间（它们无法覆盖当前查询）
        while (!pq.empty() && pq.top().second < query) {
            pq.pop();
        }
        
        // 此时堆顶的区间就是包含当前查询的最小区间
        if (!pq.empty()) {
            ans[idx] = pq.top().first;
        }
    }
    
    return ans;
}
````

## 1094. 拼车

用堆来模拟

````cpp
bool carPooling(vector<vector<int>>& trips, int capacity) {
    sort(trips.begin(), trips.end(), [](const auto& a, const auto& b){
        return a[1] < b[1];
    });

    // <to, numPassengers> pair
    typedef pair<int, int> pii;
    priority_queue<pii, vector<pii>, greater<>> pq;
    int cur = 0;
    for(int i = 0; i < trips.size(); i++){
        // 下车
        while(!pq.empty() && pq.top().first <= trips[i][1]){
            cur -= pq.top().second;
            pq.pop();
        }
        // 判断
        cur += trips[i][0];
        if(cur > capacity) return false;
        // 上车
        pq.push({trips[i][2], trips[i][0]});
    }
    return true;
}
````

[题解页](https://leetcode.cn/problems/car-pooling/solutions/)，看了一圈题解发现是差分数组

[灵神题解](https://leetcode.cn/problems/car-pooling/solutions/2550264/suan-fa-xiao-ke-tang-chai-fen-shu-zu-fu-9d4ra/)，灵神的题解对于差分数组的讲解很不错，大概的意思就是由于等价的操作于是可以快速进行连续区间的操作，可以快速的判断某个时候是否超过限额

## 986. 区间列表的交集

扫描线，双指针

````cpp
vector<vector<int>> intervalIntersection(vector<vector<int>>& firstList,
                                        vector<vector<int>>& secondList) {
    int i = 0, j = 0;
    vector<vector<int>> ans;
    while(i < firstList.size() && j < secondList.size()){
        int start = max(firstList[i][0], secondList[j][0]);
        int end = min(firstList[i][1], secondList[j][1]);

        if(start <= end) ans.push_back({start, end});

        if(firstList[i][1] < secondList[j][1]) i++;
        else if(firstList[i][1] > secondList[j][1]) j++;
        else{
            i++;
            j++;
        }
    }
    return ans;
}
````

[题解页](https://leetcode.cn/problems/interval-list-intersections/solutions/)

## 729. 我的日程安排

直接模拟做了，放置在排序区间，二分查找要插入的位置，判断有无重叠，注意corner case

````cpp
class MyCalendar
{
    vector<pair<int, int>> calender;
    int lower_bound(int target)
    {
        int l = 0, r = calender.size() - 1;
        while (l <= r)
        {
            int mid = l + (r - l) / 2;
            if (calender[mid].first < target)
                l = mid + 1;
            else
                r = mid - 1;
        }
        return l;
    }

  public:
    MyCalendar()
    {
    }

    bool book(int startTime, int endTime)
    {
        pair<int, int> cur = {startTime, endTime};
        if (calender.empty())
        {
            calender.push_back(cur);
            return true;
        }

        int idx = lower_bound(startTime);

        int n = calender.size();
        if (idx == n)
        {
            if(calender[n - 1].second > startTime) return false;

            calender.push_back(move(cur));
            return true;
        }

        if (calender[idx].first < endTime || (idx - 1 >= 0 && calender[idx - 1].second > startTime))
        {
            return false;
        }
        calender.insert(calender.begin() + idx, cur);
        return true;
    }
};
````

[题解页](https://leetcode.cn/problems/my-calendar-i/solutions/)，看了一圈发现依旧是线段树的题目，看来得学一学线段树了

下面是官解简洁的`lower_bound`写法，这里只做交流学习使用

````cpp
class MyCalendar {
    set<pair<int, int>> booked;

public:
    bool book(int start, int end) {
        auto it = booked.lower_bound({end, 0});
        if (it == booked.begin() || (--it)->second <= start) {
            booked.emplace(start, end);
            return true;
        }
        return false;
    }
};

作者：力扣官方题解
链接：https://leetcode.cn/problems/my-calendar-i/solutions/1643942/wo-de-ri-cheng-an-pai-biao-i-by-leetcode-nlxr/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
````

## Segment Tree Introduction

下面的代码来自deepseek c端的回答

线段树（Segment Tree）主要用于处理**区间查询**和**区间修改**问题。

### 1. 为什么需要线段树？

假设你有一个数组 `nums`，你要频繁做两件事：

1. **更新**：把 `nums[5]` 修改为 10，或者把 `nums[2...8]` 全部加上 5。
2. **查询**：求 `nums[2...8]` 的和（或最大值、最小值）。

线段树的复杂度能来到$O(log(n))$

线段树的本质是一棵**平衡二叉树**，每个节点代表原数组中的一个**区间（Segment）**。根节点代表整个区间 `[0, N-1]`，叶子节点代表单个元素。

### 2. 线段树的结构

为了节省内存，我们通常用一个大小为 `4 * N` 的一维数组来模拟二叉树（因为完全二叉树在数组中连续存放最省空间）。

* 假设当前节点在数组中的索引是 `p`。
* 它的左孩子索引是 `2 * p`。
* 它的右孩子索引是 `2 * p + 1`。

### 3. 线段树的基本操作 (不带懒标记)

最基础的线段树，支持**单点修改**和**区间查询**。以**区间求和**为例：

```cpp
#include <vector>
using namespace std;

class SegmentTree {
    vector<int> tree;
    int n;

    // 建树
    void build(const vector<int>& nums, int p, int l, int r) {
        if (l == r) {
            tree[p] = nums[l];
            return;
        }
        int mid = l + (r - l) / 2;
        build(nums, 2 * p, l, mid);       // 建左子树
        build(nums, 2 * p + 1, mid + 1, r); // 建右子树
        tree[p] = tree[2 * p] + tree[2 * p + 1]; // 合并结果（比如求和）
    }

    // 单点更新：把 nums[idx] 修改为 val
    void update(int p, int l, int r, int idx, int val) {
        if (l == r) {
            tree[p] = val;
            return;
        }
        int mid = l + (r - l) / 2;
        if (idx <= mid) update(2 * p, l, mid, idx, val);
        else update(2 * p + 1, mid + 1, r, idx, val);
        tree[p] = tree[2 * p] + tree[2 * p + 1]; // 更新后重新合并
    }

    // 区间查询：求 [L, R] 的和
    int query(int p, int l, int r, int L, int R) {
        if (L <= l && r <= R) {
            return tree[p]; // 当前区间被完全包含
        }
        int mid = l + (r - l) / 2;
        int res = 0;
        if (L <= mid) res += query(2 * p, l, mid, L, R);       // 查左边
        if (R > mid)  res += query(2 * p + 1, mid + 1, r, L, R); // 查右边
        return res;
    }

public:
    SegmentTree(const vector<int>& nums) {
        n = nums.size();
        tree.assign(4 * n, 0);
        build(nums, 1, 0, n - 1);
    }

    void update(int idx, int val) {
        update(1, 0, n - 1, idx, val);
    }

    int query(int L, int R) {
        return query(1, 0, n - 1, L, R);
    }
};
```

### 4. 懒标记 (Lazy Propagation)

如果题目要求**区间修改**（比如把 `[2, 8]` 的所有数加上 5），如果不用懒标记，你每次都要递归到叶子节点，复杂度退化成了 $O(N)$。

**懒标记**的思想是：如果整个区间都被修改了，我就先不往下递归，而是在父节点打个标记（Lazy Tag）。等下次**必须**访问它的子节点时，我再把标记推下去（`push_down`）。

```cpp
class LazySegmentTree {
    vector<int> tree, lazy;
    int n;

    // 下传标记
    void push_down(int p, int l, int r) {
        if (lazy[p] != 0) {
            int mid = l + (r - l) / 2;
            // 更新左孩子
            tree[2 * p] += lazy[p] * (mid - l + 1);
            lazy[2 * p] += lazy[p];
            // 更新右孩子
            tree[2 * p + 1] += lazy[p] * (r - mid);
            lazy[2 * p + 1] += lazy[p];
            // 清空当前标记
            lazy[p] = 0;
        }
    }

public:
    // ... build 建树逻辑 ...

    // 区间修改：把 [L, R] 区间全部加上 val
    void update(int p, int l, int r, int L, int R, int val) {
        if (L <= l && r <= R) {
            tree[p] += val * (r - l + 1);
            lazy[p] += val; // 打上懒标记
            return;
        }
        push_down(p, l, r); // 访问子节点前，先把标记下传
        int mid = l + (r - l) / 2;
        if (L <= mid) update(2 * p, l, mid, L, R, val);
        if (R > mid)  update(2 * p + 1, mid + 1, r, L, R, val);
        tree[p] = tree[2 * p] + tree[2 * p + 1];
    }
};
```

### LeetCode 729 (我的日程安排表)

* **题意转化**：每次预定 `[start, end)`，相当于查询区间内有没有被标记过，如果没有，就把这个区间全部打上标记。
* **难点**：时间范围是 `0 <= start < end <= 10^9`。如果开一个 `10^9` 的数组建树，**内存直接爆炸（MLE）**。
* **解法：动态开点线段树 (Dynamic Segment Tree)**。
    不用预先建好 `4 * N` 的数组，而是用**指针**或**哈希表**。只有当区间被使用到时，才为它动态分配节点。

动态开点线段树代码

```cpp
class MyCalendar {
    struct Node {
        int l, r;
        Node *left, *right;
        int sum;      // 该区间被占用的次数
        int lazy;     // 懒标记
        Node(int l, int r) : l(l), r(r), left(nullptr), right(nullptr), sum(0), lazy(0) {}
    };
    Node* root;

    void push_down(Node* node) {
        if (node->lazy) {
            int mid = node->l + (node->r - node->l) / 2;
            if (!node->left) node->left = new Node(node->l, mid);
            if (!node->right) node->right = new Node(mid + 1, node->r);
            
            node->left->sum += node->lazy;
            node->left->lazy += node->lazy;

            node->right->sum += node->lazy;
            node->right->lazy += node->lazy;

            node->lazy = 0;
        }
    }

    // 查询 [L, R] 的占用情况
    int query(Node* node, int L, int R) {
        if (L <= node->l && node->r <= R) return node->sum;
        push_down(node);
        int mid = node->l + (node->r - node->l) / 2;
        int res = 0;
        if (L <= mid) res += query(node->left, L, R);
        if (R > mid)  res += query(node->right, L, R);
        return res;
    }

    // 更新 [L, R] 为占用 (+1)
    void update(Node* node, int L, int R) {
        if (L <= node->l && node->r <= R) {
            node->sum++;
            node->lazy++;
            return;
        }
        push_down(node);
        int mid = node->l + (node->r - node->l) / 2;
        if (L <= mid) update(node->left, L, R);
        if (R > mid)  update(node->right, L, R);
        node->sum = node->left->sum + node->right->sum;
    }

public:
    MyCalendar() {
        root = new Node(0, 1e9); // 动态开点，时间范围是 [0, 10^9]
    }
    
    bool book(int start, int end) {
        // 约定：检查 [start, end - 1] 是否被占用
        if (query(root, start, end - 1) > 0) return false; // 冲突了
        update(root, start, end - 1); // 没冲突，加入日程
        return true;
    }
};
```
