# Greedy

Greedy algorithms make the locally optimal choice at each step and never revisit
decisions.

They are faster and simpler than DP when they work, but proving that a
greedy choice leads to a globally optimal solution is not always obvious.

The problems in this stage cover the most common greedy patterns:

- interval scheduling
- jump games
- character frequency problems.

A useful habit is to first ask whether a greedy approach is
correct before coding it: can a short-sighted choice ever lead you away from
the best solution? If the answer is yes, you probably need DP instead.

## 跳跃游戏

这道题做了不少时间，可能和太累了有关

追踪能到达的最远距离

````cpp
bool canJump(vector<int> &nums) {
    int n = nums.size() - 1;
    if (n == 0)
        return true;

    int longest = nums[0];
    int start = 0;
    while (true) {
        int len = nums[start];
        int origin_start = start;
        bool changed = false;
        for (int i = origin_start; i <= origin_start + len; i++) {
            int length = i + nums[i];
            if (length > longest) {
                longest = length;
                start = i;
                changed = true;
            }
            if (longest >= n)
                return true;
        }

        if (!changed)
            return false;
    }
}
````

[灵神题解](https://leetcode.cn/problems/jump-game/solutions/2798996/liang-chong-li-jie-fang-shi-wei-hu-zui-y-q67s/)，看了题解我才明白什么叫作优雅的代码

## 跳跃游戏 II

上面代码的改版

````cpp
int jump(vector<int> &nums) {
    int n = nums.size() - 1;
    int midx = 0, ans = 0, mx = nums[0];
    while (true) {
        if (midx == n)
            break;
        else if (mx >= n) {
            ans++;
            break;
        }
        int len = nums[midx];
        int oidx = midx;
        for (int j = oidx; j <= oidx + len; j++) {
            if (j + nums[j] > mx) {
                mx = j + nums[j];
                midx = j;
            }
        }
        ans++;
    }
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/jump-game-ii/solutions/2926993/tu-jie-yi-zhang-tu-miao-dong-tiao-yue-yo-h2d4)，灵神的造桥很好理解，同时代码也很简洁

## 加油站

> If total gas is at least total cost, a solution exists, and the starting point
> is always after the last segment where the running tank went negative.

````cpp
int canCompleteCircuit(vector<int>& gas, vector<int>& cost) {
    int g = 0, min_g = 0, ans = 0; 
    for(int i = 0; i < gas.size(); i++){
        g += gas[i] - cost[i];
        if(g < min_g){
            min_g = g;
            ans = i + 1;
        }
    }
    return g >= 0 ? ans : -1;
}
````

[灵神题解](https://leetcode.cn/problems/gas-station/solutions/2933132/yong-zhe-xian-tu-zhi-guan-li-jie-pythonj-qccr/)

## 763. 划分字母区间

记录每个字母最后的下标，每次选择区间内最大的下标

````cpp
vector<int> partitionLabels(string s) {
    unordered_map<int, int> hp;
    // char, last index of that char
    for(int i = 0; i < s.size(); i++){
        hp[s[i]] = i;
    } 

    vector<int> ans;
    int end = hp[s[0]];
    int start = 0;
    for(int i = 0; i < s.size(); i++){
        if(end == i){
            ans.push_back(i - start + 1);
            start = i + 1;
            end = hp[s[i + 1]];
        }
        if(hp[s[i]] > end) end = hp[s[i]];
    }
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/partition-labels/solutions/2806706/ben-zhi-shi-he-bing-qu-jian-jian-ji-xie-ygsn8/)，因为这里只有英文字母，于是可以使用数组代替`hashMap`

## 435. 无重叠的最大区间

按照区间结束时间排序，每次选择结束时间最小的

````cpp
int eraseOverlapIntervals(vector<vector<int>>& intervals) {
    sort(intervals.begin(), intervals.end(), [&](const auto& a, const auto& b){
        return a[1] < b[1];
    });
    int ans = 0;
    int prev_end = intervals[0][1];
    for(int i = 1; i < intervals.size(); i++){
        if(intervals[i][0] < prev_end){
            ans++;
        }else{
            prev_end = intervals[i][1];
        }
    }
    return ans;
}
````

[题解页](https://leetcode.cn/problems/non-overlapping-intervals/solutions/)

## 846. 一手顺子

模拟流程，每次选最小的牌然后排序

````cpp
bool isNStraightHand(vector<int> &hand, int groupSize) {
    int n = hand.size();
    if (n % groupSize)
        return false;
        
    unordered_map<int, int> hp;
    for (auto &h : hand)
        hp[h]++;

    typedef pair<int, int> pii;
    priority_queue<pii, vector<pii>, greater<pii>> pq;
    for (auto &[k, v] : hp)
        pq.push({k, v});

    while (true) {
        vector<pair<int, int>> temp;
        auto [num, cnt] = pq.top();
        pq.pop();
        if (--cnt)
            temp.push_back({num, cnt});
        int pre = num;
        for (int i = 1; i < groupSize; i++) {
            num = pq.top().first, cnt = pq.top().second;
            pq.pop();
            if (num != pre + 1)
                return false;
            if (--cnt)
                temp.push_back({num, cnt});
            pre = num;
        }
        for (auto &p : temp) {
            pq.push(p);
        }
        if (pq.empty())
            break;
    }
    return true;
}
````

看了题解发现其实不用`priority_queue`，原地排序就好了

````cpp
bool isNStraightHand(vector<int> &hand, int groupSize) {
    int n = hand.size();
    if (n % groupSize)
        return false;
    unordered_map<int, int> hp;
    for (auto &h : hand)
        hp[h]++;
    ranges::sort(hand);
    for (int x : hand) {
        if (!hp.count(x))
            continue;
        if (--hp[x] == 0)
            hp.erase(x);
        for (int i = 1; i < groupSize; i++) {
            if (!hp.count(x + i))
                return false;
            if (--hp[x + i] == 0)
                hp.erase(x + i);
        }
    }
    return true;
}
````

[题解页](https://leetcode.cn/problems/hand-of-straights/solutions/)

## 678. 有效的括号字符串

败下阵来，贪心的方向出错了

这道题最经典的解法是维护一个可能存在的未匹配左括号的数量区间 `[min_left, max_left]`。下面是deepseek c端题解

````cpp
bool checkValidString(string s) {
    int min_left = 0;
    int max_left = 0;
    
    for (char c : s) {
        if (c == '(') {
            min_left++;
            max_left++;
        } else if (c == ')') {
            min_left--;
            max_left--;
        } else { // 遇到 '*'
            min_left--; // 把 '*' 当作 ')'
            max_left++; // 把 '*' 当作 '('
        }
        
        // 如果最多可能的左括号都小于 0，说明右括号太多了，直接失败
        if (max_left < 0) return false;
        
        // 如果最少可能的左括号小于 0，说明多余的右括号被 '*' 抵消了，归零
        if (min_left < 0) min_left = 0;
    }
    
    // 如果最少可能的左括号是 0，说明刚好匹配完
    return min_left == 0;
}
````

[题解页](https://leetcode.cn/problems/valid-parenthesis-string/solutions/)

## 165. 分发糖果

败下阵来

[题解页](https://leetcode.cn/problems/candy/solutions/)，官解还不错

题解是两遍遍历，这样就可以满足左右的约束了，和接雨水有点像

````cpp
int candy(vector<int>& ratings) {
    int n = ratings.size();

    vector<int> candies(n, 1);

    // 从左向右
    for (int i = 1; i < n; i++) {
        if (ratings[i] > ratings[i - 1]) {
            candies[i] = candies[i - 1] + 1;
        }
    }

    // 从右向左
    for (int i = n - 2; i >= 0; i--) {
        if (ratings[i] > ratings[i + 1]) {
            candies[i] = max(
                candies[i],
                candies[i + 1] + 1
            );
        }
    }

    return accumulate(
        candies.begin(),
        candies.end(),
        0
    );
}
````

## 502. IPO

双顶堆加速

````cpp
int findMaximizedCapital(int k, int w, vector<int> &profits, vector<int> &capital)
{
    typedef pair<int, int> pii;
    // left for cost <= w, sort by capital descending
    priority_queue<pii> left;
    // right for cost > w, sort by cost ascending
    priority_queue<pii, vector<pii>, greater<>> right;
    for (size_t i = 0; i < profits.size(); i++)
    {
        if (capital[i] > w)
            right.push({capital[i], profits[i]});
        else
            left.push({profits[i], capital[i]});
    }

    for (int i = 0; i < k; i++)
    {
        if (left.empty())
            break;

        auto [gain, cost] = left.top();
        left.pop();
        w += gain;

        while (!right.empty() && w >= right.top().first)
        {
            auto [c, g] = right.top();
            right.pop();
            left.push({g, c});
        }
    }
    return w;
}
````

[题解页](https://leetcode.cn/problems/ipo/solutions)

优化：只使用一个队列

> 项目一旦变得可执行，就永远不会再次变成不可执行。因为我们的资本 `w` 只会增加，不会减少。

````cpp
int findMaximizedCapital(int k, int w, vector<int>& profits, vector<int>& capital)
{
    int n = profits.size();

    vector<pair<int, int>> projects;

    for (int i = 0; i < n; i++)
    {
        projects.emplace_back(capital[i], profits[i]);
    }

    sort(projects.begin(), projects.end());

    priority_queue<int> pq;

    int j = 0;

    for (int i = 0; i < k; i++)
    {

        while (j < n && projects[j].first <= w)
        {
            pq.push(projects[j].second);
            j++;
        }

        if (pq.empty()) break;

        w += pq.top();
        pq.pop();
    }

    return w;
}
````
