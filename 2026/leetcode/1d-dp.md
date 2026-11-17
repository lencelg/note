# 1-D Dynamic Programming

Dynamic programming is the technique of breaking a problem into overlapping
subproblems, solving each once, and storing the result to avoid recomputation.

In one-dimensional DP, each state depends only on a fixed number of previous
states, so the solution builds a single array from left to right.

The first step is always identifying the recurrence: what does the answer at
position i depend on?

The problems here cover the core DP patterns you will see repeatedly:

- linear sequences
- knapsack decisions
- string segmentation

DP problems are notoriously hard to recognize, and the only reliable way to get
better at them is to solve many and study the structure of their recurrences.

## 70. 爬楼梯

斐波那契数列，两种写法

- 数组
- `while`循环

````cpp
int climbStairs(int n) {
    if (n == 1)
        return 1;

    vector<int> res(n, 0);
    res[0] = 1;
    res[1] = 2;
    for (int i = 2; i < n; i++)
        res[i] = res[i - 1] + res[i - 2];
    return res[n - 1];
}
````

````cpp
int climbStairs(int n) {
    int pre = 0, cur = 1, nxt;
    for (int i = 0; i < n; i++) {
        nxt = pre + cur;
        pre = cur;
        cur = nxt;
    }
    return nxt;
}
````

[灵神题解](https://leetcode.cn/problems/climbing-stairs/solutions/2560716/jiao-ni-yi-bu-bu-si-kao-dong-tai-gui-hua-7zm1)，最优解法是矩阵快速幂，这里有一定的数学推导

## 198. 打家劫舍

打劫和不打劫两种选择，同样是两种写法

````cpp
int rob(vector<int> &nums) {
    int n = nums.size();
    vector<int> r(n + 1);
    r[0] = 0;
    r[1] = nums[0];
    for (int i = 2; i < n + 1; i++) {
        r[i] = max(r[i - 1], r[i - 2] + nums[i - 1]);
    }
    return r[n];
}
````

````cpp
int rob(vector<int> &nums) {
    int pre = 0, cur = nums[0], nxt = cur;
    for (size_t i = 1; i < nums.size(); i++) {
        nxt = max(cur, pre + nums[i]);
        pre = cur;
        cur = nxt;
    }
    return nxt;
}
````

[题解页](https://leetcode.cn/problems/house-robber/solutions)
