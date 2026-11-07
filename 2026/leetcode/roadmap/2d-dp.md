# 2-D Dynamic Programming

[Learn Dynamic Programming with Animations – Full Course for Beginners](https://www.youtube.com/watch?v=66hDgWottdA)

Two-dimensional DP extends the same ideas to problems where the state depends on
two variables simultaneously, typically two indices into two sequences or
two dimensions of a grid.

The table is now a matrix, and each cell is filled based on cells above it, to
its left, or diagonally adjacent.

The problems here include:

- string comparison (edit distance, longest common subsequence)
- grid path counting
- interval DP where you think about ranges rather than prefixes.

These problems tend to be harder to set up than 1-D DP, but once you identify
the state and the transition, the code follows directly from the recurrence.

## 62. 不同路径

直接上代码

````cpp
int uniquePaths(int m, int n) {
    vector<vector<int>> dp(m, vector<int>(n, 0));
    dp[0][0] = 1;
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            if (j - 1 >= 0)
                dp[i][j] += dp[i][j - 1];
            if (i - 1 >= 0)
                dp[i][j] += dp[i - 1][j];
        }
    }
    return dp[m - 1][n - 1];
}
````

优化：同时使用的空间只有一列

````cpp
int uniquePaths(int m, int n) {
    vector<int> dp(n, 0);
    dp[0] = 1;
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            if (j - 1 >= 0)
                dp[j] += dp[j - 1];
        }
    }
    return dp[n - 1];
}
````

[灵神题解](https://leetcode.cn/problems/unique-paths/solutions/3062432/liang-chong-fang-fa-dong-tai-gui-hua-zu-o5k32)，最佳解法应该是组合数学，明显问题适合进行数学推导

## 最长公共子序列

教材题，`dp`的定义也不难

````cpp
int longestCommonSubsequence(string text1, string text2) {
    int m = text1.size(), n = text2.size();
    vector<vector<int>> dp(m + 1, vector<int>(n + 1, 0));
    for (int i = 1; i < m + 1; i++) {
        for (int j = 1; j < n + 1; j++) {
            if (text1[i - 1] == text2[j - 1])
                dp[i][j] = dp[i - 1][j - 1] + 1;
            else
                dp[i][j] = max(dp[i][j - 1], dp[i - 1][j]);
        }
    }
    return dp[m][n];
}
````

空间优化：只用两行数组

````cpp
int longestCommonSubsequence(string text1, string text2) {
    int m = text1.size(), n = text2.size();
    vector<int> f(n + 1, 0);
    vector<int> s(n + 1, 0);

    for (int i = 1; i < m + 1; i++) {
        for (int j = 1; j < n + 1; j++) {
            if (text1[i - 1] == text2[j - 1])
                s[j] = f[j - 1] + 1;
            else
                s[j] = max(s[j - 1], f[j]);
        }
        swap(s, f);
    }
    return f[n];
}
````

deepseek c端优化：只用一行数组

````cpp
int longestCommonSubsequence(string text1, string text2) {
    int m = text1.size(), n = text2.size();
    vector<int> dp(n + 1, 0);

    for (int i = 1; i <= m; i++) {
        int prev = 0; // 相当于 dp[i-1][j-1]
        for (int j = 1; j <= n; j++) {
            int temp = dp[j]; // 暂存当前的 dp[j]，其实也就是上一行的 dp[i-1][j]
            
            if (text1[i - 1] == text2[j - 1]) {
                dp[j] = prev + 1;
            } else {
                dp[j] = max(dp[j], dp[j - 1]);
            }
            
            prev = temp; // 为下一列更新 prev (即 dp[i-1][j])
        }
    }
    return dp[n];
}
````

[题解页](https://leetcode.cn/problems/longest-common-subsequence/solutions)

## 72. 编辑距离

A 2D DP table tracks the cost to convert each prefix of one string to each prefix
of the other.

相同就不用修改，不相同就对于每一个字符有三种选择，选择最小的即可，这里主要是DP table的初始化要注意一下

````cpp
int minDistance(string word1, string word2) {
    int m = word1.size(), n = word2.size();
    vector<vector<int>> dp(m + 1, vector<int>(n + 1, 0));
    for (int i = 0; i < n + 1; i++) {
        dp[0][i] = i;
    }

    for (int i = 1; i < m + 1; i++) {
        dp[i][0] = i;
        for (int j = 1; j < n + 1; j++) {
            if (word1[i - 1] == word2[j - 1])
                dp[i][j] = dp[i - 1][j - 1];
            else
                dp[i][j] = min({1 + dp[i - 1][j], 1 + dp[i - 1][j - 1],
                                1 + dp[i][j - 1]});
        }
    }
    return dp[m][n];
}
````

优化：两行数组

````cpp
int minDistance(string word1, string word2) {
    int m = word1.size(), n = word2.size();
    vector<int> f(n + 1, 0);
    vector<int> s(n + 1, 0);
    for (int i = 1; i < n + 1; i++) {
        f[i] = i;
    }

    for (int i = 1; i < m + 1; i++) {
        s[0] = i;
        for (int j = 1; j < n + 1; j++) {
            if (word1[i - 1] == word2[j - 1])
                s[j] = f[j - 1];
            else
                s[j] = min({f[j], f[j - 1], s[j - 1]}) + 1;
        }
        swap(s, f);
    }
    return f[n];
}
````

借助上一题的优化这里也可以写成一行数组，这里要注意的点是每一行开始更新的时候要记录之前的值，然后再更改`dp[0]`的值

````cpp
int minDistance(string word1, string word2) {
    int m = word1.size(), n = word2.size();
    vector<int> dp(n + 1, 0);
    for (int i = 1; i < n + 1; i++) {
        dp[i] = i;
    }

    for (int i = 1; i < m + 1; i++) {
        int prev = i - 1;
        dp[0] = i;
        for (int j = 1; j < n + 1; j++) {
            int temp = dp[j];
            if (word1[i - 1] == word2[j - 1])
                dp[j] = prev;
            else
                dp[j] = min({dp[j], dp[j - 1], prev}) + 1;

            prev = temp;
        }
    }
    return dp[n];
}
````

[题解页](https://leetcode.cn/problems/edit-distance/solutions)

## 312. 戳气球

败下阵来，这道题dp的思路难很多

> instead of choosing which balloon to burst first, you choose which to burst
> last within each interval.
> This problem teaches you that sometimes reversing the order of decisions makes
> the DP structure cleaner.

[题解页](https://leetcode.cn/problems/burst-balloons/solutions)

这道题的难点在于：如果你顺着题意“正着推”，每戳破一个气球，左右相邻的气球就会变化，这会导致状态具有**后效性**，根本无法写出状态转移方程。

**破局的关键在于：逆向思维（从“第一个戳破”变成“最后一个戳破”）。**

假设在区间 `(i, j)` 开区间内，最后一个被戳破的气球是 `k`（`i < k < j`）。
既然 `k` 是最后一个被戳破的，那么在戳破 `k` 的瞬间，它左边的相邻气球一定是 `i`，右边的相邻气球一定是 `j`。

此时戳破 `k` 能获得的硬币数是：
`nums[i] * nums[k] * nums[j]`

而在此之前，`(i, k)` 之间的气球和 `(k, j)` 之间的气球都已经被戳破了。这两个子问题相互独立，互不影响。

因此，状态转移方程就出来了。

### 解题步骤与代码实现

**1. 虚拟边界：**
在数组首尾各添加一个 `1`，这样就不需要写一大堆 `if` 来处理越界问题。
原来的 `nums` 变成了 `val`，长度从 `n` 变成了 `n + 2`。

**2. 状态定义：**
`dp[i][j]` 表示：戳破开区间 `(i, j)` 内所有气球，能获得的最大硬币数。
注意是**开区间**，也就是不包含 `i` 和 `j` 本身。

**3. 状态转移方程：**
我们要找的是 `(i, j)` 内最后一个被戳破的气球 `k`。
`dp[i][j] = max(dp[i][j], dp[i][k] + dp[k][j] + val[i] * val[k] * val[j])`
*(i < k < j)*

**4. 遍历顺序：**
因为 `dp[i][j]` 依赖于更小的区间 `dp[i][k]` 和 `dp[k][j]`，所以必须**按区间长度从小到大**遍历。

```cpp
int maxCoins(vector<int>& nums) {
    int n = nums.size();
    // 1. 构造虚拟边界
    vector<int> val(n + 2, 1);
    for (int i = 1; i <= n; i++) {
        val[i] = nums[i - 1];
    }

    // 2. dp 数组：dp[i][j] 表示开区间 (i, j) 的最大硬币数
    vector<vector<int>> dp(n + 2, vector<int>(n + 2, 0));

    // 3. 枚举区间长度 len，至少为 3（因为开区间中间至少要有 1 个气球）
    for (int len = 3; len <= n + 2; len++) {
        // 枚举左端点 i
        for (int i = 0; i <= n + 2 - len; i++) {
            int j = i + len - 1; // 计算右端点 j

            // 枚举最后一个戳破的气球 k
            for (int k = i + 1; k < j; k++) {
                int total = dp[i][k] + dp[k][j] 
                          + val[i] * val[k] * val[j];
                dp[i][j] = max(dp[i][j], total);
            }
        }
    }

    // 返回开区间 (0, n+1) 的结果
    return dp[0][n + 1];
}
```

## 10. 正则表达式匹配

再次败下阵来，dp放过我吧

[灵神题解](https://leetcode.cn/problems/regular-expression-matching/solutions/902845/go-yi-xing-by-endlesscheng-1vf3/)，灵神无敌题解

## 309. 买卖股票的最佳时机含冷冻期

...

这里要从是否持有股票来分析，于是知道要同时维护两个变量来维持所有的状态

[灵神题解](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-with-cooldown/solutions/2201415/shi-pin-jiao-ni-yi-bu-bu-si-kao-dong-tai-0k0l/)

## 518. 零钱兑换II

dp思路出错，四连败。。。这里因为会有重复，所以dp的定义是用前`i`个硬币组成`amount`的数量，这样就能去除重复了

[灵神题解](https://leetcode.cn/problems/coin-change-ii/solutions/2706227/shi-pin-wan-quan-bei-bao-cong-ji-yi-hua-o3ew0/)

## 494. 目标和

dfs

````cpp
int findTargetSumWays(vector<int>& nums, int target) {
    auto dfs = [&](this auto&& dfs, int i, int t){
        if(i < 0 && t == 0) return 1;
        if(i < 0) return 0;
        return dfs(i - 1, t - nums[i]) + dfs(i - 1, t + nums[i]);
    };
    int n = nums.size();
    int ans = dfs(n - 1, target);
    return ans;
}
````

下面解法来自deepseek c端：

假设把数组分成两部分：

- 前面加 `+` 号的元素之和为 `P`
- 前面加 `-` 号的元素之和为 `N`

那么可以得到两个等式：

1. `P - N = target` （题目要求）
2. `P + N = sum` （数组所有元素的总和）

把这两个式子相加，得到：`2 * P = target + sum`，所以 **`P = (target + sum) / 2`**。

问题变成了：**从数组中选出一些数，使得它们的和恰好为 `(target + sum) / 2`，一共有多少种选法？**，这就是最标准的 0-1 背包问题：每个数字只能用一次。

### 边界情况

1. **奇数情况**：如果 `target + sum` 是奇数，那么除以 2 会得到小数，不可能凑出整数，直接返回 `0`。
2. **越界情况**：如果 `abs(target) > sum`，哪怕所有数都用来凑正向或负向，也达不到目标，返回 `0`。

### 一维数组

```cpp
class Solution {
public:
    int findTargetSumWays(vector<int>& nums, int target) {
        int sum = 0;
        for (int num : nums) sum += num;
        
        // 1. 边界条件拦截
        if (abs(target) > sum || (target + sum) % 2 == 1) return 0;
        
        int bagSize = (target + sum) / 2;
        
        // 2. dp[j] 表示凑成和为 j 的方法数
        vector<int> dp(bagSize + 1, 0);
        dp[0] = 1; // 凑成和为 0 的方法只有 1 种（什么都不选）
        
        // 3. 0-1 背包：外层遍历物品
        for (int i = 0; i < nums.size(); i++) {
            // 内层必须倒序遍历容量，防止同一个数字被重复使用
            for (int j = bagSize; j >= nums[i]; j--) {
                dp[j] += dp[j - nums[i]];
            }
        }
        
        return dp[bagSize];
    }
};
```

### 记忆化搜索（DFS + 备忘录）

```cpp
#include <vector>
#include <unordered_map>
#include <string>

using namespace std;

class Solution {
public:
    int findTargetSumWays(vector<int>& nums, int target) {
        // 哈希表记录计算过的状态：key 为 "index,current_sum"，value 为方法数
        unordered_map<string, int> memo;
        return dfs(nums, target, 0, 0, memo);
    }

private:
    int dfs(vector<int>& nums,
            int target,
            int index,
            int current_sum, unordered_map<string, int>& memo) {
        // 如果已经到了数组末尾，检查当前和是否等于 target
        if (index == nums.size()) {
            return current_sum == target ? 1 : 0;
        }
        
        // 生成当前状态的 key
        string key = to_string(index) + "," + to_string(current_sum);
        
        // 如果之前计算过这个状态，直接返回
        if (memo.count(key)) return memo[key];
        
        // 选择 1：前面加 + 号
        int add = dfs(nums, target, index + 1, current_sum + nums[index], memo);
        // 选择 2：前面加 - 号
        int sub = dfs(nums, target, index + 1, current_sum - nums[index], memo);
        
        // 记录并返回
        memo[key] = add + sub;
        return memo[key];
    }
};
```

[灵神题解](https://leetcode.cn/problems/target-sum/solutions/2119041/jiao-ni-yi-bu-bu-si-kao-dong-tai-gui-hua-s1cx/)

## 97. 交错字符串

dfs超时不用想

````cpp
bool isInterleave(string s1, string s2, string s3) {
    // i for s1, j for s2, k for s3, choose s1 when choose == true else s2
    int a = s1.size(), b = s2.size(), c = s3.size();
    auto dfs = [&](this auto&& dfs, int i, int j, int k, bool choose){
        if(k == c && i == a && j == b) return true;
        if((i == a && choose) || (j == b && !choose)) return false;
        if(choose){
            if(s1[i] == s3[k])
                return dfs(i + 1, j, k + 1, true) || dfs(i + 1, j, k + 1, false);
            else
                return false;
        }else{
            if(s2[j] == s3[k])
                return dfs(i, j + 1, k + 1, true) || dfs(i, j + 1, k + 1, false);
            else
                return false;
        }
    };
    return dfs(0, 0, 0, true) || dfs(0, 0, 0, false);
}

// 改进的dfs
bool isInterleave(string s1, string s2, string s3)
{
    int a = s1.size(), b = s2.size(), c = s3.size();
    if (a + b != c)
        return false;
    // i for s1, j for s2, k for s3, choose s1 when choose == true else s2
    auto dfs = [&](this auto &&dfs, int i, int j, int k) {

        if (k == c && i == a && j == b) return true;

        // only can choose from s2
        if (i == a)
        {
            while (j < b && k < c && s2[j] == s3[k])
            {
                j++;
                k++;
            }
            return j == b && k == c;
        }
        else if (j == b)
        {
            while (i < a && k < c && s1[i] == s3[k])
            {
                i++;
                k++;
            }
            return i == a && k == c;
        }

        if (s1[i] == s2[j])
        {
            if (s1[i] == s3[k])
                return dfs(i + 1, j, k + 1) || dfs(i, j + 1, k + 1);
            else
                return false;
        }
        if (s1[i] == s3[k]) return dfs(i + 1, j, k + 1);
        else if (s2[j] == s3[k]) return dfs(i, j + 1, k + 1);
        else return false;
    };
    return dfs(0, 0, 0);
}
````

二维DP

````cpp
bool isInterleave(string s1, string s2, string s3) {
    int m = s1.size(), n = s2.size(), c = s3.size();
    if(m + n != c) return false; 
    vector<vector<bool>> dp(m + 1, vector<bool>(n + 1, 0));
    dp[0][0] = true;
    for(int i = 1; i < n + 1; i++){
        dp[0][i] = dp[0][i - 1] && s2[i - 1] == s3[i - 1];
    }
    for(int i = 1; i < m + 1; i++){
        dp[i][0] = dp[i - 1][0] && s1[i - 1] == s3[i - 1];
    }
    for(int i = 1; i < m + 1; i++){
        for(int j = 1; j < n + 1; j++){
            bool match_s1 = (dp[i - 1][j] && s1[i - 1] == s3[i + j - 1]);
            bool match_s2 = (dp[i][j - 1] && s2[j - 1] == s3[i + j - 1]);
            dp[i][j] = match_s1 || match_s2;
        }
    }
    return dp[m][n];
}
````

[题解页](https://leetcode.cn/problems/interleaving-string/solutions/)

## 115. 不同的子序列

这道题要是要用无符号的64位整数

### dfs

超时无需多言

````cpp
int numDistinct(string s, string t) {
    int m = s.size(), n = t.size(); 
    if(n > m) return 0;
    // i for s, j for t
    auto dfs = [&](this auto&& dfs, int i, int j){
        if(j == n) return 1;
        if(i == m) return 0;

        if(s[i] == t[j]) return dfs(i + 1, j + 1) + dfs(i + 1, j);
        else return dfs(i + 1, j);
    };
    return dfs(0, 0);
}
````

### memorize dfs

刚好能过

````cpp
int numDistinct(string s, string t) {
    int m = s.size(), n = t.size(); 
    if(n > m) return 0;
    // i for s, j for t
    vector<vector<int>> memo(m + 1, vector<int>(n + 1, -1));
    auto dfs = [&](this auto&& dfs, int i, int j){
        if(j == n) return 1;
        if(i == m) return 0;
        if(memo[i][j] != -1) return memo[i][j];

        if(s[i] == t[j]){
            int val = dfs(i + 1, j + 1) + dfs(i + 1, j);
            memo[i][j] = val;
        } else{
            int val = dfs(i + 1, j);
            memo[i][j] = val;
        }
        return memo[i][j];
    };
    return dfs(0, 0);
}
````

### 2d dp

````cpp
int numDistinct(string s, string t) {
    int m = s.size(), n = t.size(); 
    if(n > m) return 0;
    // i for s, j for t
    vector<vector<unsigned long>> dp(m + 1, vector<unsigned long>(n + 1, 0));
    for(int i = 0; i < m + 1; i++){
        dp[i][0] = 1;
    }
    for(int i = 1; i < m + 1; i++){
        for(int j = 1; j < n + 1; j++){
            dp[i][j] = dp[i - 1][j];
            if(s[i - 1] == t[j - 1]){
                dp[i][j] += dp[i - 1][j - 1];
            }
        }
    }
    return dp[m][n];
}
````

### 2d dp with space optimization

````cpp
int numDistinct(string s, string t) {
    int m = s.size(), n = t.size(); 
    if(n > m) return 0;
    // i for s, j for t
    vector<unsigned long> dp(n + 1, 0);
    dp[0] = 1;
    for(int i = 1; i < m + 1; i++){
        int pre = dp[0];
        for(int j = 1; j < n + 1; j++){
            int temp = dp[j];
            if(s[i - 1] == t[j - 1]){
                dp[j] += pre;
            }
            pre = temp;
        }
    }
    return dp[n];
}
````

[题解页](https://leetcode.cn/problems/distinct-subsequences/solutions/)

看了灵神题解发现写dfs的时候最后从后面往前面写，这样翻译成自底向上的时候就很容易想到了
