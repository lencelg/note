# Sliding Window

The sliding window pattern is used when you need to find an optimal subarray or
substring that satisfies some constraint.

Instead of checking every possible subarray from scratch, you maintain a window
with two pointers and update the result incrementally as the window expands or shrinks.

- Fixed-size windows are straightforward;
- variable-size windows require a clear rule for when to shrink from the left.

This stage also introduces the **monotonic deque**, which extends sliding window
to problems that need the maximum or minimum within the window at each step.

## 121. 买卖股票的最佳时机

直接上代码

````cpp
int maxProfit(vector<int>& prices) {
    int minPrice = 1e5, res = 0;
    for(int p: prices){
        res = max(p - minPrice, res);
        minPrice = min(minPrice, p);
    }
    return res;
}
````

## 3. 无重复字符的最长字串

只需要记录`left`，`right`为当前遍历的`i`

````cpp
int lengthOfLongestSubstring(string s) {
    unordered_set<char> hs; 
    int l = 0;
    size_t res = 0;
    for(char c: s){
        while(hs.count(c)){
            hs.erase(s[l++]);
        }
        hs.insert(c);
        res = max(res, hs.size());
    }
    return res;
}
````

## 76. 最小覆盖字串

标准的变长窗口模板套上：

- 先形成一个合法窗口
- 再最小合法化窗口
- 最后破坏合法窗口

虽然是hard的题目，但是感觉写起来是medium的题目

````cpp
string minWindow(string s, string t) {
    if(t.size() > s.size()) return "";

    unordered_map<int, int> hp;
    for(char c : t){
        hp[c]++;
    }

    int l = 0, al = 0, ar = -1;
    for(int i = 0; i < s.size(); i++){
        char c = s[i];
        if(hp.count(c)) hp[c]--;
        else continue;

        bool check = true;
        for(const auto &[_, v]: hp){
            if(v > 0){
                check = false;
                break;
            }
        }

        if(!check) continue;

        while(!hp.count(s[l]) || (hp.count(s[l]) && hp[s[l]] < 0)){
            if(hp.count(s[l])) hp[s[l]]++;
            l++;
        }

        int cur = i - l + 1;
        if(ar == -1 || (ar - al + 1) > cur){
            al = l;
            ar = i;
        }

        hp[s[l]]++;
        l++;
    }
    return s.substr(al, ar - al + 1); 
}
````

可以在最后的判断这里做点小优化：

````cpp
string minWindow(string s, string t) {
    if(t.size() > s.size()) return "";

    unordered_map<int, int> hp;
    for(char c : t){
        hp[c]++;
    }

    int m = static_cast<int>(s.size());
    int l = 0, al = -1, ar = m;
    for(int i = 0; i < m; i++){
        char c = s[i];
        if(hp.count(c)) hp[c]--;
        else continue;

        bool check = true;
        for(const auto &[_, v]: hp){
            if(v > 0){
                check = false;
                break;
            }
        }

        if(!check) continue;

        while(!hp.count(s[l]) || (hp.count(s[l]) && hp[s[l]] < 0)){
            if(hp.count(s[l])) hp[s[l]]++;
            l++;
        }

        if((ar - al + 1) > (i - l + 1)){
            al = l;
            ar = i;
        }

        hp[s[l]]++;
        l++;
    }
    return al == -1 ? "" : s.substr(al, ar - al + 1); 
}
````

看了灵神的题解才发现原来这里又是标准只包含的英文字母，于是可以用数组代替哈希表。。。

但是使用数组也有一些限制，所以写起来不太一样

[灵神题解](https://leetcode.cn/problems/minimum-window-substring/solutions/2713911/liang-chong-fang-fa-cong-o52mn-dao-omnfu-3ezz/)

## 424. 替换后的最长重复字符

最小的合法窗口长度一定是`k + 1`，当合法的时候就不断扩张，不合法就缩小到合法

````cpp
int characterReplacement(string s, int k) {
    int m = s.size();
    if(k == m) return k;

    unordered_map<char, int> hp; 
    auto check = [&hp, k](){
        int total = 0, largest = 0;
        for(const auto& [_, v] : hp){
            total += v;
            largest = max(largest, v);
        }
        return (total - largest) <= k;
    };

    int res = k + 1, l = 0;
    for (int i = 0; i < m; i++)
    {
        hp[s[i]]++;

        while((i - l + 1) < (k + 1) && i < m){
            i++;
            hp[s[i]]++;
        }

        while(check() && i < m){
            res = max(res, i - l + 1);
            i++;
            hp[s[i]]++;
        }

        while(!check()){
            if(--hp[s[l]] == 0) hp.erase(s[l]);
            l++;
        }
    }
    
    return res;
}
````

然后可以做点小优化和简化代码，每次验证向右扩张合法的时候不需要遍历哈希表

````cpp
int characterReplacement(string s, int k) {
    int m = s.size();
    if(k == m) return k;

    auto check = [k](int l, int r, int largest){
        return (r - l + 1 - largest) <= k;
    };

    unordered_map<char, int> hp; 
    char largest = '0';
    hp[largest] = -1;

    int l = 0, res = k + 1;
    for (int i = 0; i < m; i++)
    {
        hp[s[i]]++;
        largest = (hp[s[i]] > hp[largest]) ? s[i] : largest;

        while(((i - l + 1) < (k + 1) || check(l, i, hp[largest])) && i < m){
            i++;
            hp[s[i]]++;
            largest = (hp[s[i]] > hp[largest]) ? s[i] : largest;
        }

        res = max(res, i - l);

        do{
            if(--hp[s[l]] == 0) hp.erase(s[l]);
            l++;

            largest = '0';
            for(const auto& [k, v] : hp){
                if(v > hp[largest]) largest = k;
            }
        }while(!check(l, i, hp[largest]));
    }
    
    return res;
}
````

然后就是用数组写一遍，数组的情形有点不一样

不能再扩张的时候有两种情形，因为哈希表可以哈希字符串的结尾的`\0`，所以就不用理会，但是数组会index of bound

- 是合法的，但是`i == m - 1`，这时候无法再扩张了
- 不是合法的

````cpp
int characterReplacement(string s, int k) {
    int m = s.size();
    if(k == m) return k;


    int record[26] = {0}; 
    int largestIndex = 0;
    auto check = [k, &record](int l, int r, int largestIndex){
        return (r - l + 1 - record[largestIndex]) <= k;
    };

    int l = 0, res = k + 1;
    for (int i = 0; i < m; i++)
    {
        int cur = s[i] - 'A';
        record[cur]++;
        largestIndex = (record[cur] > record[largestIndex]) ? cur : largestIndex;

        while(((i - l + 1) < (k + 1) || check(l, i, largestIndex)) && i < m - 1){
            i++;
            cur = s[i] - 'A';
            record[cur]++;
            largestIndex = (record[cur] > record[largestIndex]) ? cur : largestIndex;
        }

        if(check(l, i, largestIndex)){
            res = max(res, i - l + 1);
            break;
        }else res = max(res, i - l);

        do{
            record[s[l] - 'A']--;
            l++;

            for (int i = 0; i < 26; i++)
            {
                largestIndex = (record[largestIndex] > record[i]) ? largestIndex : i;
            }
            
        }
        while(!check(l, i, largestIndex));
    }
    return res;
}
````

其实仔细想一想这里是越长越合法，所以不需要在合法的时候判断再扩张，只需要在不合法的时候缩小就可以了

````cpp
int characterReplacement(string s, int k) {
    int m = s.size();
    if(k == m) return k;


    int record[26] = {0}; 
    int largestIndex = 0;

    int l = 0, res = k + 1;
    for (int i = 0; i < m; i++)
    {
        int cur = s[i] - 'A';
        record[cur]++;
        largestIndex = (record[cur] > record[largestIndex]) ? cur : largestIndex;
        while((i - l + 1 - record[largestIndex]) > k)
        {
            record[s[l] - 'A']--;
            l++;

            for (int i = 0; i < 26; i++)
            {
                largestIndex = (record[largestIndex] > record[i]) ? largestIndex : i;
            }
            
        }
        res = max(res, i - l + 1);
    }
    return res;
}
````

其实这里仔细想一想，当前窗口最大的字符是`s[largestIndex]`

在缩小的时候`l`有两种情形

- `s[l] == s[largestIndex]`这时候移动虽然最大的字符少了一个计数，但是窗口可以替换的字符多了一个计数所以最大的字符没有发生变化，不需要遍历寻找最大的字符，这时窗口再次合法
- `s[l] != s[largestIndex]`这时候移动`l`就可以形成合法窗口了

最终版如下：

````cpp
int characterReplacement(string s, int k) {
    int m = s.size();
    if(k == m) return k;

    int record[26] = {0}; 
    int largestIndex = 0;

    int l = 0, res = k + 1;
    for (int i = 0; i < m; i++)
    {
        int cur = s[i] - 'A';
        record[cur]++;
        largestIndex = (record[cur] > record[largestIndex]) ? cur : largestIndex;
        if((i - l + 1 - record[largestIndex]) > k)
        {
            record[s[l] - 'A']--;
            l++;
        }
        res = max(res, i - l + 1);
    }
    return res;
}
````

早上起来做了快两个小时，现在写完题解感觉人都累了，准备睡大觉

## 239. 滑动窗口的最大值

单调队列：这道题其实没有那么难，不要把自己的思路带偏就很好写了

````cpp
vector<int> maxSlidingWindow(vector<int>& nums, int k) {
    deque<int> dq;
    vector<int> result;

    for (int i = 0; i < nums.size(); i++) {
        if (!dq.empty() && dq.front() <= i - k) {
            dq.pop_front();
        }

        while (!dq.empty() && nums[i] >= nums[dq.back()]) {
            dq.pop_back();
        }

        dq.push_back(i);

        if (i >= k - 1) {
            result.push_back(nums[dq.front()]);
        }
    }
    return result;
}
````

## 567. 字符串的排列

这道题的用例测试感觉比较轻松

````cpp
bool checkInclusion(string s1, string s2) {
    unordered_map<char, int> hp;

    for(char c : s1) hp[c]++;
    size_t l = 0, n = s1.size(), m = s2.size();
    for (size_t r = 0; r < m; r++)
    {
        if(hp.count(s2[r])) hp[s2[r]]--;

        if((r - l + 1) < n){
            continue;
        }

        bool good = true;
        for(auto& [_, v]: hp){
            if(v != 0)
            {
                good = false;
                break;
            }
        }
        if(good) return true;

        if(hp.count(s2[l])) hp[s2[l]]++;
        l++;
    }
    return false; 
}
````

然后就是优化，每次判断窗口的时候只要在`s2[l]`在`s1`里面再判断

````cpp
bool checkInclusion(string s1, string s2) {
    unordered_map<char, int> hp;

    for(char c : s1) hp[c]++;

    int l = 0, n = s1.size(), m = s2.size();

    while(!hp.count(s2[l]) && l < m) l++;

    for (int r = l; r < m; r++)
    {
        if(hp.count(s2[r])) hp[s2[r]]--;

        if((r - l + 1) < n){
            continue;
        }

        bool good = true;
        for(auto& [_, v]: hp){
            if(v != 0)
            {
                good = false;
                break;
            }
        }
        if(good) return true;

        hp[s2[l]]++;
        l++;

        while(!hp.count(s2[l]) && l < m){
            l++;
        }
    }
    return false; 
}
````

这里还是小写的英文字母，于是可以使用数组来代替哈希表，详细的代码看[灵神的本题题解](https://leetcode.cn/problems/permutation-in-string/solutions/3747426/ding-chang-hua-dong-chuang-kou-cong-o26n-ulxp)

这里我就不写了。

## 904. 水果成篮

越长越合法

````cpp
int totalFruit(vector<int>& fruits) {
    unordered_map<int, int> hp;
    int l = 0, ans = 0;
    for (int r = 0; r < fruits.size(); r++)
    {
        hp[fruits[r]]++;

        while(hp.size() > 2){
            if(--hp[fruits[l]] == 0) hp.erase(fruits[l]);
            l++;
        }

        ans = max(ans, r - l + 1);
    }
    return ans;
}
````

## 209. 长度最小的子数组

这里需要注意更新`ans`的地方

````cpp
int minSubArrayLen(int target, vector<int>& nums) {
    int sum = 0;
    int l = 0, ans = numeric_limits<int>::max();
    for (int r = 0; r < nums.size(); r++)
    {
        sum += nums[r];

        if(sum < target) continue;

        while(sum >= target)
        {
            ans = min(ans, r - l + 1);
            sum -= nums[l];
            l++;
        }
    }
    return ans == numeric_limits<int>::max() ? 0 : ans;        
}
````

[灵神题解有两种写法](https://leetcode.cn/problems/minimum-size-subarray-sum/solutions/1959532/biao-ti-xia-biao-zong-suan-cuo-qing-kan-k81nh)

## 713. 乘积小于k的子数组

````cpp
int numSubarrayProductLessThanK(vector<int>& nums, int k) {
        if(*min_element(nums.begin(), nums.end()) > k) return 0;

        int ans = 0; 
        int l = 0, cur = 1;
        for (int r = 0; r < nums.size(); r++)
        {
            cur *= nums[r];

            while(cur >= k){
                cur /= nums[l];
                l++;
            }

            ans += (r - l + 1);
        }
        return ans;        
    }
````

小优化：一次遍历

````cpp
int numSubarrayProductLessThanK(vector<int>& nums, int k) {

    int ans = 0; 
    int l = 0, cur = 1;
    for (int r = 0; r < nums.size(); r++)
    {
        cur *= nums[r];

        while(cur >= k && l <= r){
            cur /= nums[l];
            l++;
        }

        ans += (r - l + 1);
    }
    return ans;        
}
````

看了灵神的题解，灵神的题解对于没有数组符合要求的情形处理的更加优雅，[灵神题解链接](https://leetcode.cn/problems/subarray-product-less-than-k/solutions/1959538/xia-biao-zong-suan-cuo-qing-kan-zhe-by-e-jebq/)

## 1004. 最大连续1的个数III

没什么好说的，直接上代码

````cpp
int longestOnes(vector<int>& nums, int k) {
    int ans = 0;
    int l = 0;
    for (int r = 0; r < nums.size(); r++)
    {
        k -= 1 - nums[r];

        while(k < 0)
        {
            k += 1 - nums[l];
            l++;
        }

        ans = max(ans, r - l + 1);
    }
    return ans;
}
````
