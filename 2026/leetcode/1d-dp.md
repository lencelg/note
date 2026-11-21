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

```cpp
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

## 139. 单词拆分

处理好下标就行了

````cpp
bool wordBreak(string s, vector<string> &wordDict) {
    int n = s.size();
    vector<bool> dp(n, false);
    for (int i = 0; i < n; i++) {
        for (auto &word : wordDict) {
            int size = word.size();
            if (i - size + 1 == 0 || (i - size + 1 > 0 && dp[i - size])) {
                if (s.substr(i - size + 1, size) == word) {
                    dp[i] = true;
                    break;
                }
            }
        }
    }
    return dp[n - 1];
}
````

deepseek c端优化：记忆化搜索，`dp`的思路有一点不同

````cpp
bool wordBreak(string s, vector<string>& wordDict) {
    // 1. 用 unordered_set 存储字典，查找时间降到 O(1)
    unordered_set<string> dict(wordDict.begin(), wordDict.end());
    
    int n = s.size();
    // 2. 调整状态定义：dp[i] 表示 s 的前 i 个字符（即 s[0...i-1]）能否被成功拆分
    // 大小设为 n + 1，dp[0] = true 表示空串可以被拆分
    vector<bool> dp(n + 1, false);
    dp[0] = true;

    // 3. 记录字典中的最长单词长度，用于剪枝
    int maxLen = 0;
    for (const string& word : wordDict) {
        maxLen = max(maxLen, (int)word.size());
    }

    // 4. 外层遍历前 i 个字符
    for (int i = 1; i <= n; i++) {
        // 内层从 i 前面最多 maxLen 个字符开始找
        // 如果前面的长度 j 已经超过 maxLen，说明即使找到前缀也没用，直接跳过
        for (int j = max(0, i - maxLen); j < i; j++) {
            // 如果前 j 个字符能拆分，且截取的后半段在字典里
            if (dp[j] && dict.count(s.substr(j, i - j))) {
                dp[i] = true;
                break; // 只要找到一种拆分方式即可跳出内层循环
            }
        }
    }
    
    // 返回整个字符串 s 能否被拆分
    return dp[n];
}
````

[灵神题解](https://leetcode.cn/problems/word-break/solutions/2968135/jiao-ni-yi-bu-bu-si-kao-dpcong-ji-yi-hua-chrs)，灵神的最终版本和上面的DeepSeek优化思路一样的

## 打家劫舍II

> Since House[1] and House[n] are adjacent, they cannot be robbed together.
> Therefore, the problem becomes to rob either House[1]-House[n-1]
> or House[2]-House[n], depending on which choice offers more money.
> Now the problem has degenerated to the House Robber, which is already been solved.

- dp写法
- 循环写法

````cpp
int rob(vector<int> &nums) {
    int n = nums.size();
    if (n == 1)
        return nums[0];
    vector<int> dp1(n);
    dp1[0] = 0;
    dp1[1] = nums[0];
    for (int i = 2; i < n; i++) {
        dp1[i] = max(dp1[i - 1], dp1[i - 2] + nums[i - 1]);
    }

    vector<int> dp2(n);
    dp2[0] = 0;
    dp2[1] = nums[1];
    for (int i = 2; i < n; i++) {
        dp2[i] = max(dp2[i - 1], dp2[i - 2] + nums[i]);
    }
    return max(dp1[n - 1], dp2[n - 1]);
}
````

````cpp
int rob(vector<int> &nums) {
    int n = nums.size();
    if (n == 1)
        return nums[0];

    int pre = 0, cur = nums[0], nxt = cur;
    for (size_t i = 1; i < n - 1; i++) {
        nxt = max(cur, pre + nums[i]);
        pre = cur;
        cur = nxt;
    }
    int ans = nxt;

    pre = 0, cur = nums[1], nxt = cur;
    for (size_t i = 2; i < n; i++) {
        nxt = max(cur, pre + nums[i]);
        pre = cur;
        cur = nxt;
    }
    return max(ans, nxt);
}
````

[题解页](https://leetcode.cn/problems/house-robber-ii/solutions/)

## 91. 解码方法

依旧两种写法

- dp数组
- 循环

````cpp
// 同样是DP数组，LeetCode上第一版的写法比二版的空间少0.3MB
int numDecodings(string s) {
    if(s[0] == '0') return 0;

    int n = s.size();
    if(n == 1) return 1;

    vector<int> dp(n, 0);
    dp[0] = 1;
    if(s[1] != '0') dp[1] += dp[0];
    if(s[0] == '1' || (s[0] == '2' && s[1] < '7')) dp[1]++;

    for(int i = 2; i < n; i++){
        if(s[i] != '0') dp[i] += dp[i - 1];
        if(s[i - 1] == '1' || (s[i - 1] == '2' && s[i] < '7')) dp[i] += dp[i - 2];
    }
    return dp[n - 1];
}

int numDecodings(string s) {
    int n = s.size();
    if(s[0] == '0') return 0;
    if(n == 1) return 1;

    vector<int> dp(n + 1, 0);
    dp[0] = 1;
    dp[1] = 1;
    for(int i = 2; i < n + 1; i++){
        if(s[i - 1] != '0')
            dp[i] += dp[i - 1];

        if(s[i - 2] == '1' || (s[i - 2] == '2' && s[i - 1] < '7'))
            dp[i] += dp[i - 2];
    }
    return dp[n];
}
````

````cpp
int numDecodings(string s) {
    int n = s.size();
    if(s[0] == '0') return 0;
    if(n == 1) return 1;

    int pre2 = 1, pre = 1, cur;
    for(int i = 2; i < n + 1; i++){
        cur = 0;
        if(s[i - 1] != '0') cur += pre;
        if(s[i - 2] == '1' || (s[i - 2] == '2' && s[i - 1] < '7')) cur += pre2;

        int temp = pre;
        pre = cur;
        pre2 = temp;
    }
    return cur;
}
````

## 5. 最长回文字串

dp做法没想出来，正向做就写了

正向做对每个当前的字符进行回文扩展

````cpp
string longestPalindrome(string s) {
    int ansl = 0, ansr = 0;
    int n = s.size();
    for (int i = 0; i < n; i++) {

        if ((n - i + 1) <= (ansr - ansl + 1) / 2)
            break;

        int l = i, r = i;
        while (r + 1 < n && s[r + 1] == s[r])
            r++;
        while (l >= 0 && r < n && s[l] == s[r]) {
            l--;
            r++;
        }

        l++;
        r--;

        if (r - l + 1 > ansr - ansl + 1) {
            ansl = l;
            ansr = r;
        }
    }
    return s.substr(ansl, ansr - ansl + 1);
}
````

[题解页](https://leetcode.cn/problems/longest-palindromic-substring/solutions)，这里最优的解法是Manacher算法

## 416. 分割等和子集

败下阵来，能想到找集合总和的一半，这里的dp思路看了题解感觉不难但是自己想的时候没有思绪

````cpp
bool canPartition(vector<int> &nums) {
    int t = accumulate(nums.begin(), nums.end(), 0);

    if (t % 2)
        return false;
    t /= 2;

    vector<bool> dp(t + 1, false);
    dp[0] = true;

    for (int num : nums) {
        for (int j = t; j >= num; j--) {
            dp[j] = dp[j] || dp[j - num];
        }
    }
    return dp[t];
}
````

优化：提前返回

````cpp
bool canPartition(vector<int> &nums) {
    int t = accumulate(nums.begin(), nums.end(), 0);

    if (t % 2)
        return false;
    t /= 2;

    vector<bool> dp(t + 1, false);
    dp[0] = true;

    for (int num : nums) {

        if(t >= num){
            dp[t] = dp[t] || dp[t - num];
            if(dp[t]) return true;
        }

        for (int j = t - 1; j >= num; j--) {
            dp[j] = dp[j] || dp[j - num];
        }
    }
    return false;
}
````

[灵神题解](https://leetcode.cn/problems/partition-equal-subset-sum/solutions/2785266/0-1-bei-bao-cong-ji-yi-hua-sou-suo-dao-d-ev76)

## 152. 乘积最大的子数组

定义`dp[i]`为以`nums[i]`为结尾最大乘积和最小乘积的`pair`

````cpp
int maxProduct(vector<int> &nums) {
    int n = nums.size();
    // <max, min> pair
    vector<pair<int, int>> dp(n + 1);
    int ans = INT_MIN;
    dp[0].first = 1, dp[0].second = 1;
    for (int i = 1; i < n + 1; i++) {
        int cur = nums[i - 1];

        dp[i].first =
            max({cur, dp[i - 1].first * cur, dp[i - 1].second * cur});
        dp[i].second =
            min({cur, dp[i - 1].first * cur, dp[i - 1].second * cur});

        ans = max(ans, dp[i].first);
    }
    return ans;
}
````

优化：把dp数组的更新写成循环

````cpp
int maxProduct(vector<int> &nums) {
    int n = nums.size();
    int ans = INT_MIN;
    int curMax = 1, curMin = 1;
    for (int i = 0; i < n; i++) {
        int cur = nums[i];

        int a = max({cur, curMax * cur, curMin * cur});
        int b = min({cur, curMax * cur, curMin * cur});

        curMax = a;
        curMin = b;
        ans = max(ans, curMax);
    }
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/maximum-product-subarray/solutions/2968916/dong-tai-gui-hua-jian-ji-gao-xiao-python-i778)，dp的思路一样，灵神的写法三简化并小小优化了代码，受教了

下面评论区还有悟道的：

> 这道题让我突然想到，人生不能只在意高光时刻，低谷时刻也同样有价值。
> 在乘积最大子数组里，f_min 记录的是当前最小乘积。它看起来像是低谷，但当它遇到一个负数时，反而可能翻转成最大的答案。
> 这就像面试一样，一次面试失败，并不代表这段经历没有意义。它可能会变成后面某个高光时刻的前置状态。
> 山重水复疑无路，柳暗花明又一村。
> 低谷不是终点，它可能只是下一次翻转之前的状态。
