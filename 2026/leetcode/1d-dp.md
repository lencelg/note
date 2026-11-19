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

## 322. 零钱兑换

对金额进行DP，`-1`为不存在

````cpp
int coinChange(vector<int> &coins, int amount) {
    vector<int> a(amount + 1, 0);
    for (int i = 1; i < amount + 1; i++) {
        int cur = INT_MAX;
        for (int coin : coins) {
            if (i - coin >= 0 && a[i - coin] != -1) {
                cur = min(cur, a[i - coin] + 1);
            }
        }
        a[i] = cur == INT_MAX ? -1 : cur;
    }
    return a[amount];
}
````

[灵神题解](https://leetcode.cn/problems/coin-change/solutions/2119065/jiao-ni-yi-bu-bu-si-kao-dong-tai-gui-hua-21m5)，灵神的代码更简洁

下面是ChatGPT c端的优化与分析

- **优化一：不使用 -1 表示不可达**

修改后：

```
int coinChange(vector<int>& coins, int amount) {
    vector<int> dp(amount + 1, amount + 1);
    dp[0] = 0;

    for (int i = 1; i <= amount; i++) {
        for (int coin : coins) {
            if (i >= coin) {
                dp[i] = min(dp[i], dp[i - coin] + 1);
            }
        }
    }

    return dp[amount] == amount + 1 ? -1 : dp[amount];
}
```

- **优化二：对 coins 排序，提前 break**

如果硬币面值比较多，可以考虑：

`sort(coins.begin(), coins.end());`

然后：

```cpp
for (int coin : coins) {
    if (coin > i) break;

    dp[i] = min(dp[i], dp[i - coin] + 1);
}
```

完整代码：

```cpp
int coinChange(vector<int>& coins, int amount) {
    sort(coins.begin(), coins.end());

    vector<int> dp(amount + 1, amount + 1);
    dp[0] = 0;

    for (int i = 1; i <= amount; i++) {
        for (int coin : coins) {
            if (coin > i) break;

            dp[i] = min(dp[i], dp[i - coin] + 1);
        }
    }

    return dp[amount] > amount ? -1 : dp[amount];
}
```

- **优化三：交换 DP 循环顺序**

可以写成：

```cpp
for (int coin : coins) {
    for (int i = coin; i <= amount; i++) {
        dp[i] = min(dp[i], dp[i - coin] + 1);
    }
}
```

这是完全背包问题。

- 外层遍历硬币。
- 内层正序遍历金额。
- 正序遍历允许同一种硬币重复使用。

注意，如果内层改成倒序：

```cpp
for (int i = amount; i >= coin; i--)
```

就变成了每种硬币最多使用一次的 0-1 背包

## 300. 递增最长的子序列

````cpp
int lengthOfLIS(vector<int> &nums) {
    int n = nums.size();

    vector<int> dp(n, 1);
    int ans = 1;
    for (int i = 1; i < n; i++) {
        int idx = -1;
        for (int j = 0; j < i; j++) {
            if (nums[i] > nums[j] && (idx == -1 || dp[j] >= dp[idx])) {
                idx = j;
            }
        }
        if (idx != -1)
            dp[i] = dp[idx] + 1;

        ans = max(ans, dp[i]);
    }
    return ans;
}
````

简洁版：

````cpp
int lengthOfLIS(vector<int> &nums) {
    int n = nums.size();
    vector<int> dp(n, 0);
    int ans = 1;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < i; j++) {
            if (nums[i] > nums[j]) {
                dp[i] = max(dp[i], dp[j]);
            }
        }
        dp[i]++;
        ans = max(ans, dp[i]);
    }
    return ans;
}
````

改进：这里本质是在当前数字找在前面递增的序列的位置，如果这个数字不是在整个数组的最长的数字序列里面也没有关系，直接替换掉就行了
不会对后面的判断造成影响，因为替换以后序列的长度没有发生变化，不存在就替换到最后，于是这里可以使用二分，复杂度到$O(n log(n))$

````cpp
int lengthOfLIS(vector<int> &nums) {
    vector<int> r;
    for (auto num : nums) {
        auto it = lower_bound(g.begin(), g.end(), num);
        if (it != r.end()) {
            *it = num;
        } else {
            r.push_back(num);
        }
    }
    return r.size();
}
````

[灵神题解](https://leetcode.cn/problems/longest-increasing-subsequence/solutions/2147040/jiao-ni-yi-bu-bu-si-kao-dpfu-o1-kong-jia-4zma/)，这里灵神还有一个本地修改`nums`数组的方法，受教了
