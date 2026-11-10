# Backtracking

Backtracking is a systematic way to explore all possible solutions by making a
choice, recursing, and undoing the choice when you backtrack.

It is the right tool for problems that ask for:

- all combinations
- all permutations
- all subsets
- any valid configuration.

**The key skill is recognizing when to prune**: stopping a branch early
when you can tell it cannot lead to a valid solution. Without pruning,
backtracking is just brute force.

Most problems here share the same recursive skeleton and differ only in the
constraints that determine valid choices and stopping conditions.

## 78. 子集

基础的回溯题，也可以写成枚举，因为这里不需要剪枝

````cpp
vector<vector<int>> subsets(vector<int>& nums) {
    vector<vector<int>> ans; 
    vector<int> cur;
    int n = nums.size();
    std::function<void(int, vector<int>&)> f;
    f = [&ans, &n, &nums, &f](int index, vector<int>& cur){
        if (index == n)
        {
            ans.push_back(cur);
            return;
        }
        cur.push_back(nums[index]);
        f(index + 1, cur);
        cur.pop_back();
        f(index + 1, cur);
    };
    f(0, cur);
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/subsets/solutions/2059409/hui-su-bu-hui-xie-tao-lu-zai-ci-pythonja-8tkl)，灵神的还有一个二进制枚举，挺有意思的

## 39. 组合之和

子集的变形题，单个元素可以多次选择

也可以排序以后再选，这样快一些

````cpp
vector<vector<int>> combinationSum(vector<int>& candidates, int target) {
    std::function<void(int idx, int t)> f; 
    vector<int> cur;
    vector<vector<int>> ans;
    int n = candidates.size();
    f = [&candidates, &cur, &ans, &n, &f](int idx, int t){
        if(t < 0 || (idx == n && t != 0)) return;
        if(t == 0)
        {
            ans.push_back(cur);
            return;
        }

        int num = candidates[idx];
        cur.push_back(num);
        f(idx, t - num);

        cur.pop_back(); 
        f(idx + 1, t);
    };
    f(0, target);
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/combination-sum/solutions/2747858/liang-chong-fang-fa-xuan-huo-bu-xuan-mei-mhf9)，代码强度最高的一集了

## 46. 全排列

这里的排列顺序要注意的，每次都要追踪当前没有使用的元素，考虑使用`bool`数组来记录

````cpp
vector<vector<int>> permute(vector<int>& nums) {
    vector<vector<int>> ans;
    vector<int> cur;
    int n = nums.size();
    vector<bool> used(n, false);

    auto f = [&](auto&& self) -> void{
        if(cur.size() == n){
            ans.push_back(cur);
            return;
        }

        for (size_t i = 0; i < used.size(); i++)
        {
            if(used[i]) continue; 

            cur.push_back(nums[i]);
            used[i] = true;

            self(self);

            cur.pop_back();
            used[i] = false;
        }
    };

    f(f);
    return ans;
}
````

## 79. 单词搜索

想起了走迷宫的日子，这里同样要记录有什么剩下的元素

````cpp
bool exist(vector<vector<char>>& board, string word) {
    int row = board.size(), col = board[0].size();
    vector<vector<bool>> used( row, vector<bool>(col, false));

    bool ans = false, found = false;

    auto f = [&](auto&& f, int idx, int i, int j) -> void{
        if(found) return;
        if(idx == word.size())
        {
            ans = true;
            found = true;
            return;
        }
        if(i == row || j == col || i < 0 || j < 0) return;


        if(board[i][j] == word[idx] && !used[i][j])
        {
            used[i][j] = true;
            f(f, idx + 1, i, j - 1);
            used[i][j] = false;

            used[i][j] = true;
            f(f, idx + 1, i, j + 1);
            used[i][j] = false;

            used[i][j] = true;
            f(f, idx + 1, i - 1, j);
            used[i][j] = false;

            used[i][j] = true;
            f(f, idx + 1, i + 1, j);
            used[i][j] = false;
        }
    };

    for (size_t i = 0; i < row; i++)
    {
        for (size_t j = 0; j < col; j++)
        {
            f(f, 0, i, j);
            if(found) break;
        }
        if(found) break;
    }
    return ans;
}
````

[题解页](https://leetcode.cn/problems/word-search/solutions)，这里主要是考虑如何优化，灵神的优化的思路很好但是优化二比较难想到

## N皇后

我的写法是一层一层放

````cpp
vector<vector<string>> solveNQueens(int n) {
    vector<vector<string>> ans;

    vector<bool> col(n, false);
    vector<bool> t1(2 * n - 1, false), t2(2 * n - 1, false);
    vector<vector<bool>> place(n, vector<bool>(n, false));

    auto f = [&](this auto&& f, int i) -> void{
        if(i == n)
        {
            vector<string> cur;
            for (int i = 0; i < n; i++)
            {
                ostringstream ss;
                for (int j = 0; j < n; j++)
                {
                    if(place[i][j]) ss << "Q";
                    else ss << ".";
                }
                cur.push_back(ss.str()); 
            }
            ans.push_back(move(cur));
            return;
        }

        for (int j = 0; j < n; j++)
        {
            if(!col[j] && !t1[n - 1 + i + j] && !t2[n - 1 - j + i])
            {
                col[j] = true;
                t1[n - 1 + i + j] = true; t2[n - 1 - j + i] = true;
                place[i][j] = true;

                f(i + 1);

                col[j] = false;
                t1[n - 1 + i + j] = false; t2[n - 1 - j + i] = false;
                place[i][j] = false;
            } 
        }
    };

    f(0);
    
    return ans;
}
````

[题解页](https://leetcode.cn/problems/n-queens/solutions)，这里只记录每一行皇后的`col`信息就可以构建了，空间的使用就少了。

## 子集 II

重点在于如何哈希一个数组，我使用`string`然后排序后哈希

````cpp
vector<vector<int>> subsetsWithDup(vector<int>& nums) {
    unordered_set<string> hs; 
    vector<vector<int>> ans;
    vector<int> cur;
    
    int n = nums.size();
    auto f = [&](this auto&& f, int idx) -> void
    {
        if(idx == n)
        {
            string s(cur.begin(), cur.end());
            sort(s.begin(), s.end());
            if(!hs.contains(s))
            {
                ans.push_back(cur);
                hs.insert(move(s));
            }
            return;
        }

        f(idx + 1);

        cur.push_back(nums[idx]);
        f(idx + 1);
        cur.pop_back();
    };
    f(0);
    return ans;
}
````

性能比较差

> 在不选 $nums[i]$ 时，要跳过后续所有等于 $nums[i]$ 的数。如果不跳过这些数，比如 $nums[i] = nums[i+1] = 2$，
> 那么「选第一个 2 不选第二个 2」和「不选第一个 2 选第二个 2」这两种情况都相当于「选了一个 2」，这就重复了。

[灵神题解](https://leetcode.cn/problems/subsets-ii/solutions/3036436/liang-chong-fang-fa-xuan-huo-bu-xuan-mei-v0js)，灵神的去重方法很好

## 40. 组合之和II

借助上一题题解的思路来写就行了

````cpp
vector<vector<int>> combinationSum2(vector<int>& candidates, int target) {
    ranges::sort(candidates);
    vector<vector<int>> ans; 
    vector<int> cur;
    int n = candidates.size();
    auto f = [&](this auto&& f, int idx, int t){
        if(t == 0)
        {
            ans.push_back(cur);
            return;
        }
        if(idx == n || t < 0) return;

        int num = candidates[idx];
        cur.push_back(num);
        f(idx + 1, t - num);
        cur.pop_back();

        while(idx < n && candidates[idx] == num)
        {
            idx++;
        }
        f(idx, t);
    };
    f(0, target);
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/combination-sum-ii/solutions/3036036/liang-chong-fang-fa-xuan-huo-bu-xuan-mei-a7be)，灵神这里相当于还有一点小小的优化。

把`t < candidates[idx]`的情形拿出来是因为已经排序了数组，后面可以直接跳过，受教了

## 131. 分割回文串

当前分割点是回文串

- 分割当前点
- 不分割当前点

如果当前分割点不是回文串就只能不分割当前点

````cpp
vector<vector<string>> partition(string s) {
    vector<vector<string>> ans; 
    vector<int> r;
    int n = s.size();
    auto f = [&](this auto&& f, int start, int idx) -> void{
        if(idx == n){
            if(start != n) return;
            int i = 0;
            vector<string> cur;
            for(int e : r){
                cur.push_back(s.substr(i, e - i + 1));
                i = e + 1;
            }
            ans.push_back(move(cur));
            return;
        }

        bool vaildate = true;
        int i = start, j = idx;
        while(i <= j){
            if(s[i] != s[j]){
                vaildate = false;
                break;
            }
            i++; j--;
        }

        f(start, idx + 1);

        if(vaildate)
        {
            r.push_back(idx);
            f(idx + 1, idx + 1);
            r.pop_back();
        }
    };
    f(0, 0);
    return ans;
}
````

加速：使用`set`来记录有效的分割点

````cpp
vector<vector<string>> partition(string s) {
    set<pair<int, int>> hs;
    vector<vector<string>> ans; 
    vector<int> r;
    int n = s.size();
    auto f = [&](this auto&& f, int start, int idx) -> void{
        if(idx == n){
            if(start != n) return;
            int i = 0;
            vector<string> cur;
            for(int e : r){
                cur.push_back(s.substr(i, e - i + 1));
                i = e + 1;
            }
            ans.push_back(move(cur));
            return;
        }

        bool vaildate = true;
        int i = start, j = idx;
        pair<int, int> st = {i, j};
        if(!hs.contains(st)){
            while(i <= j){
                if(s[i] != s[j]){
                    vaildate = false;
                    break;
                }
                i++; j--;
            }
            if(vaildate) hs.insert(st);
        }

        f(start, idx + 1);

        if(vaildate)
        {
            r.push_back(idx);
            f(idx + 1, idx + 1);
            r.pop_back();
        }
    };
    f(0, 0);
    return ans;
}
````

好吧，LeetCode提交的测评没有什么速度的提升

[题解页](https://leetcode.cn/problems/palindrome-partitioning/solutions/?source=vscode)，看了灵神题解感觉是因为我这里使用记录分割点的原因，直接使用`string`来记录应该更好

官方的题解使用动态规划的数组来进行记录有效的回文串对来加速搜索，我的是使用了`set`

## 17. 电话号码的字母组合

首先建立映射关系，然后回溯就可以，这里不需要恢复

这道题比较简单，runtime 100%, memory 99%

````cpp
vector<string> letterCombinations(string digits) {
    constexpr std::array<std::string_view, 8> Mapping = {
        "abc", "def", "ghi",
        "jkl", "mno", "pqrs",
        "tuv", "wxyz"
    };
    vector<string> ans;
    string cur(digits.size(), 0);
    auto f = [&](this auto&& f, int idx) -> void
    {
        if(idx == digits.size())
        {
            ans.push_back(cur);
            return;
        }
        
        char c = digits[idx];
        string_view s = Mapping[c - '2'];
        for(char ch : s){
            cur[idx] = ch;
            f(idx + 1);
        }
    };
    f(0);
    return ans;
}
````

[题解页](https://leetcode.cn/problems/letter-combinations-of-a-phone-number/solutions)，解法都差不多

## 37. 解数独

这里要注意的点：

- 没有合法数字的时候要立刻`return`
- 找到解也要立刻`return`

````cpp
void solveSudoku(vector<vector<char>>& board) {
    bool row[9][9] = {false};
    bool col[9][9] = {false};
    bool nine[3][3][9] = {false};
    bool placed[9][9] = {false};
    for (int i = 0; i < 9; i++)
    {
        for (int j = 0; j < 9; j++)
        {
            char c = board[i][j];
            // if(c == '.') continue;
            if (c < '1' || c > '9') continue;
            row[i][c - '1'] = true;
            col[j][c - '1'] = true;
            nine[i / 3][j / 3][c - '1'] = true;
            placed[i][j] = true;
        }
    }
    
    bool found = false;
    auto f = [&](this auto&& f, int r, int c) -> void{
        if(found) return;
        if(r == 9)
        {
            found = true;
            return;
        }
        for (int j = c; j < 9; j++)
        {
            if(placed[r][j]) continue;
            for (int t = 0; t < 9; t++)
            {
                if(!row[r][t] && !col[j][t] && !nine[r / 3][j / 3][t])
                {
                    placed[r][j] = true;
                    row[r][t] = true;
                    col[j][t] = true;
                    nine[r / 3][j / 3][t] = true;

                    board[r][j] = '1' + t;
                    f(r, j + 1);

                    if(found) return;

                    placed[r][j] = false;
                    row[r][t] = false;
                    col[j][t] = false;
                    nine[r / 3][j / 3][t] = false;
                }
            }
            // 没有合法数字
            return;
        }
        f(r + 1, 0);
    };
    f(0, 0);
}
};
````

[题解页](https://leetcode.cn/problems/sudoku-solver/solutions)
