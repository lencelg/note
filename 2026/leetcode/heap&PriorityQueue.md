# Heap & Priority Queue

A heap is the right data structure when you repeatedly need the largest or
smallest element from a changing collection.

The problems in this stage cover three heap patterns:

- top-k elements (maintain a heap of size k)
- two heaps (split a dataset into two halves to track the median)
- k-way merge (combine multiple sorted sequences using a single heap).

If you find yourself wanting to sort something repeatedly as new elements arrive
, a heap is almost always the better choice.
Getting comfortable with heap operations and
 knowing which variant to reach for is the main skill this stage develops.

## 215. 数组中第k大的元素

维护一个k大小的小根堆

```cpp
int findKthLargest(vector<int>& nums, int k) {
    priority_queue<int> pq; 
    for (size_t i = 0; i < nums.size(); i++)
    {
        pq.push(nums[i]);
        if(pq.size() > k) pq.pop();
    }
    return pq.top(); 
}
```

[题解页](https://leetcode.cn/problems/kth-largest-element-in-an-array/solutions/)，正确的解法是分治

## 973. 最接近原点的k个点

小根堆

```cpp
vector<vector<int>> kClosest(vector<vector<int>>& points, int k) {
    auto cmp = [](const vector<int>& a, const vector<int>& b){
        return (a[0] * a[0] + a[1] * a[1]) < (b[0] * b[0] + b[1] * b[1]);
    };
    priority_queue<vector<int>, vector<vector<int>>, decltype(cmp)> pq(cmp);
    pq.push(points[0]);
    for(size_t i = 1; i < points.size(); i++)
    {
        pq.push(points[i]);
        if(pq.size() > k) pq.pop();
    }
    vector<vector<int>> ans;
    while(!pq.empty()){
        ans.emplace_back(move(pq.top()));
        pq.pop();
    }
    return ans;
}   
```

[题解页](https://leetcode.cn/problems/k-closest-points-to-origin/solutions/)，感觉都一般

## 621. 任务调度器

做的最久的一集，debug到累。

早上起来做的，布置倒是不是还没有醒的原因

这里我用一个`vector<int>`来记录进入冷却的任务，每一轮要做的个数是`min(size, n + 1)`，debug很久才做出来

````cpp
int leastInterval(vector<char>& tasks, int n) {
    int cnt[26] = {0}; 
    for(auto task : tasks) cnt[task - 'A']++;
    
    priority_queue<int> pq;
    for (size_t i = 0; i < 26; i++)
    {
        if(cnt[i]) pq.push(cnt[i]);
    }
    
    vector<int> incooldown;
    int ans = 0; int cur = n;
    while (!pq.empty() || !incooldown.empty())
    {
        std::for_each(incooldown.begin(), incooldown.end(), [&pq](int e){
            pq.push(e);
        });
        incooldown.clear();

        int size = pq.size();
        size = min(size, n + 1);

        if(cur < n)
        {
            ans += n - cur;
        }

        cur = 0;

        ans += size;
        cur += size - 1;

        for (int i = 0; i < size; i++)
        {
            int l = pq.top() - 1;
            pq.pop();
            if(l) incooldown.push_back(l);
        }
    }
    return ans;
}
````

[题解页](https://leetcode.cn/problems/task-scheduler/solutions/?source=vscode)，这道题是构造题，感觉并不简单，需要一定的推导，反正我是先躺下了。

## 295. 数据流的中位数

写的比较丑陋，使用两个堆，其实也可以自己写一个堆，不过代码量很大而且没有时间和空间优势

````cpp
private:
    priority_queue<int> lowerHalf;
    priority_queue<int, vector<int>, greater<int>> upperHalf;
MedianFinder() { }

void addNum(int num) 
{
    if(lowerHalf.empty())
    {
        lowerHalf.push(num);
        return;
    }

    if(lowerHalf.size() > upperHalf.size()){
        int le = lowerHalf.top();
        if(num > le)
        {
            upperHalf.push(num);
        }
        else
        {
            lowerHalf.pop();
            lowerHalf.push(num);
            upperHalf.push(le);
        }
    }else{
        int le = upperHalf.top();
        if(num < le)
        {
            lowerHalf.push(num);
        }
        else
        {
            upperHalf.pop();
            upperHalf.push(num);
            lowerHalf.push(le);
        }
    }
}

double findMedian() 
{
    if(lowerHalf.size() > upperHalf.size()) return lowerHalf.top();
    else if(lowerHalf.size() < upperHalf.size()) return upperHalf.top();
    else return (lowerHalf.top() + upperHalf.top()) / 2.0;
}
````

[灵神题解](https://leetcode.cn/problems/find-median-from-data-stream/solutions/3015873/ru-he-zi-ran-yin-ru-da-xiao-dui-jian-ji-4v22k)，灵神的题解很简洁

## 703. 数据流中第k大的元素

维护一个k大小的小根堆

````cpp
class KthLargest {
private:
    int _k;
    priority_queue<int, vector<int>, greater<int>> upperHalf;
public:
    KthLargest(int k, vector<int>& nums): _k(k)
    {
        for (size_t i = 0; i < nums.size(); i++)
            add(nums[i]);
    }
    
    int add(int val)
    {
        if(upperHalf.size() < _k)
        {
            upperHalf.push(val);
            return upperHalf.top();
        }else{
            if(val > upperHalf.top())
            {
                upperHalf.pop();
                upperHalf.push(val);
            }
            return upperHalf.top();
        }
    }
};
````

[官方题解](https://leetcode.cn/problems/kth-largest-element-in-a-stream/solutions/600598/shu-ju-liu-zhong-de-di-k-da-yuan-su-by-l-woz8)，官方题解很简洁

## 1046. 最后一块石头的重量

没什么好说的，直接上代码

````cpp
int lastStoneWeight(vector<int>& stones) {
    priority_queue<int> pq;
    for(auto stone: stones) pq.push(stone);  
    while(pq.size() > 1){
        int y = pq.top(); pq.pop();
        int x = pq.top(); pq.pop();
        y -= x;
        if(y) pq.push(y);
    }
    return pq.empty() ? 0 : pq.top();
}
````

[题解页](https://leetcode.cn/problems/last-stone-weight/solutions)

## 355. 设计推特

基本的想法很简单，但是还要想想怎么优化，提升速度

````cpp
class Twitter {
private:
    unordered_map<int, set<int>> followMap;
    vector<pair<int, int>> posts;
public:
    Twitter() { }
    
    void postTweet(int userId, int tweetId) {
        posts.push_back({tweetId, userId});
    }
    
    vector<int> getNewsFeed(int userId) {
        set<int>& followee = followMap[userId];
        vector<int> ans;
        for (int i = posts.size() - 1; i >= 0; i--)
        {
            auto cur = posts[i];
            if(followee.count(cur.second) || userId == cur.second){
                ans.push_back(cur.first);
            }
            if(ans.size() == 10) break;
        }
        return ans;        
    }
    
    void follow(int followerId, int followeeId) {
        if(followerId != followeeId) followMap[followerId].insert(followeeId); 
    }
    
    void unfollow(int followerId, int followeeId) {
        followMap[followerId].erase(followeeId); 
    }
};
````

[官方题解](https://leetcode.cn/problems/design-twitter/solutions/199331/she-ji-tui-te-by-leetcode-solution)，主要是怎么储存`tweetId`与`userId`的关系

官方题解的缺陷是每个人只储存最多10条推文，不适合实际问题

## 767. 重构字符串

其实就模拟流程，优先队列加贪心

````cpp
string reorganizeString(string s) {
    priority_queue<pair<int, char>> pq;
    int cnt[26] = {0};
    for(char c : s) cnt[c - 'a']++;
    for (int i = 0; i < 26; i++) {
        if(cnt[i]){
            pq.push({cnt[i], 'a' + i});
        }
    }
    ostringstream ans;
    while(!pq.empty()){
        if(pq.size() == 1)
        {
            if(pq.top().first != 1) return "";
            ans << pq.top().second;
            break;
        }

        pair<int, char> cur = pq.top(); pq.pop(); 
        pair<int, char> next = pq.top(); pq.pop(); 
        ans << cur.second << next.second; 

        if(--cur.first) pq.push(cur);
        if(--next.first) pq.push(next);
    }
    return ans.str();
}
````

原来这道题也是构造题，[灵神题解](https://leetcode.cn/problems/reorganize-string/solutions/2779462/tan-xin-gou-zao-pai-xu-bu-pai-xu-liang-c-h9jg)，灵神的题解是没有使用优先队列的写法，很有意思

## 480. 滑动窗口中位数

总觉得以前那里见过，但是翻了翻以前的note发现没有，题单上也没有，甚是奇怪

最喜欢优化的一集，这道题对于性能的要求还是比较高的

下面是我未优化版屎山代码，时间超出限制

````cpp
class Solution {
public:
    vector<double> medianSlidingWindow(vector<int>& nums, int k) {
        int n = nums.size(), idx = 0;
        vector<double> ans(n - k + 1);

        priority_queue<long> lowerHalf;
        priority_queue<long, vector<long>, greater<long>> upperHalf;

        int l = 0, r = 0;
        while(r < n){
            addNum(upperHalf, lowerHalf, nums[r]); r++;

            if(r - l < k) continue;

            double target = getMedian(upperHalf, lowerHalf);
            ans[idx++] = target;

            deleteNum(upperHalf, lowerHalf, nums[l]); l++;
        }
        return ans; 
    }
private:
    double getMedian(priority_queue<long, vector<long>, greater<long>> &upperHalf,
        priority_queue<long> &lowerHalf){

        if(upperHalf.size() > lowerHalf.size()) return upperHalf.top();
        else if(upperHalf.size() < lowerHalf.size()) return lowerHalf.top();
        else return (upperHalf.top() + lowerHalf.top()) / 2.0;

    }
    void deleteNum(priority_queue<long, vector<long>, greater<long>> &upperHalf,
        priority_queue<long> &lowerHalf, int num){

        vector<long> left;
        if(num > lowerHalf.top())
        {

            while(upperHalf.top() != num)
            {
                long cur = upperHalf.top();
                left.push_back(cur); upperHalf.pop();
            }
            upperHalf.pop();
            for (size_t i = 0; i < left.size(); i++) upperHalf.push(left[i]);

        }else
        {
            while(lowerHalf.top() != num)
            {
                long cur = lowerHalf.top();
                left.push_back(cur); lowerHalf.pop();
            }
            lowerHalf.pop();
            for (size_t i = 0; i < left.size(); i++) lowerHalf.push(left[i]);
        }

    }
    void addNum(priority_queue<long, vector<long>, greater<long>> &upperHalf,
        priority_queue<long> &lowerHalf, int num){
        if(lowerHalf.empty())
        {
            if(upperHalf.empty()) lowerHalf.push(num);
            else
            {
                if(num > upperHalf.top()) 
                {
                    lowerHalf.push(upperHalf.top());
                    upperHalf.pop();
                    upperHalf.push(num);
                } else
                {
                    lowerHalf.push(num);
                }
            }
            return;
        }

        if(lowerHalf.size() > upperHalf.size()){
            int le = lowerHalf.top();
            if(num > le)
            {
                upperHalf.push(num);
            }
            else
            {
                lowerHalf.pop();
                lowerHalf.push(num);
                upperHalf.push(le);
            }
        }else{
            int le = upperHalf.top();
            if(num < le)
            {
                lowerHalf.push(num);
            }
            else
            {
                upperHalf.pop();
                upperHalf.push(num);
                lowerHalf.push(le);
            }
        }
    }
};
````

这里要做的优化其实是`deleteNum`的时候，当然还有代码的简洁化，好吧放弃了。

[灵神题解](https://leetcode.cn/problems/sliding-window-median/solutions/3628827/295-ti-lan-shan-chu-dui-pythonjavacgojsr-66ch)，有点数学归纳的味道

堆的特点是：只有堆顶元素是对外暴露的，堆底和中间的元素是被“封印”的。

在求滑动窗口中位数时，我们只关心大根堆的堆顶（左半部分最大值）和小根堆的堆顶（右半部分最小值）。

懒删除的触发机制：

- 如果删掉的元素是堆底的元素，它根本不影响结果，所以暂时不用管它；
- 如果删掉的元素刚好是堆顶元素（或者随着其他元素的插入/弹出，它慢慢浮动到了堆顶），此时它会直接污染中位数的计算结果。这时候清除僵尸元素就行了

这道题主要是要实现双顶堆 + 懒删除
