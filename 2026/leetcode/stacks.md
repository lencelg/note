# Stacks

# 20. 有效的括号

没什么好说的，写就完了

```cpp
bool isValid(string s) {
    int n = static_cast<int>(s.size());
    if(n % 2 != 0) return false;
    
    stack<char> st;
    for (int i = 0; i < n; i++)
    {
        switch (s[i])
        {
        case ')':
            if(!st.empty() && st.top() == '(') st.pop();
            else return false;
            break;
        case ']':
            if(!st.empty() && st.top() == '[') st.pop();
            else return false;
            break;
        case '}':
            if(!st.empty() && st.top() == '{') st.pop();
            else return false;
            break;
        default:
            st.push(s[i]);
            break;
        }
    }
    return st.empty(); 
}
```

看完灵神的题解有新的收获, 下面的代码来自灵神，这里只做交流学习使用。

进栈可以使用相对的括号，这也写起来就优雅很多

```cpp
bool isValid(string s) {
    if (s.length() % 2) { // s 长度必须是偶数
        return false;
    }
    stack<char> st;
    for (char c : s) {
        if (c == '(') {
            st.push(')'); // 入栈对应的右括号
        } else if (c == '[') {
            st.push(']');
        } else if (c == '{') {
            st.push('}');
        } else { // c 是右括号
            if (st.empty() || st.top() != c) {
                return false; // 没有左括号，或者左括号类型不对
            }
            st.pop(); // 出栈
        }
    }
    return st.empty(); // 所有左括号必须匹配完毕
}
```

# 155. 最小栈

由于是常数时间检索最小值，所以要追踪最小值的顺序，自然想到用小根堆

```cpp
class MinStack {
private:
    stack<int> st; 
    priority_queue<int, vector<int>, greater<int>> minHeap;
public:
    MinStack() {}
    
    void push(int value) {
        st.push(value); 
        minHeap.push(value);
    }
    
    void pop() {
        int e = st.top();
        st.pop();
        
        vector<int> collect;
        while(minHeap.top() != e){
            collect.push_back(minHeap.top());
            minHeap.pop();
        }
        minHeap.pop();
        for (size_t i = 0; i < collect.size(); i++)
        {
            minHeap.push(collect[i]);
        }
    }
    
    int top() {
        return st.top(); 
    }
    
    int getMin() {
        return minHeap.top(); 
    }
};
```

然而这里的实现并不优雅，跑起来比较慢，可以思考一下还有什么地方可以优化，但是到饭点了，先吃饭吧。好吧还是没有想出来

看了灵神的题解大有收获，这里可以看成是前缀最小值。求前缀最小值可以用pair来记录，也可以当前值与前缀最小值的差值，还可以使用另外一个stack来记录(空间效率就底了不少)。这道题感觉比较考验思维了

[155题灵神题解](https://leetcode.cn/problems/min-stack/solutions/2974438/ben-zhi-shi-wei-hu-qian-zhui-zui-xiao-zh-x0g8/)

# 739. 每日温度

单调栈

```cpp
vector<int> dailyTemperatures(vector<int>& temperatures) {
    stack<int> st; 
    int n = static_cast<int>(temperatures.size());
    vector<int> res(n, 0);
    st.push(n - 1);
    for (int i = n - 2; i >= 0; i--)
    {
        while(!st.empty() && temperatures[i] >= temperatures[st.top()]) {
            st.pop();
        }

        if(!st.empty()) res[i] = st.top() - i;

        st.push(i);
    }
    return res;       
}
```

```java
public int[] dailyTemperatures(int[] temperatures) {
    Stack<Integer> st = new Stack<>();
    int[] answer = new int[temperatures.length];
    for (int i = temperatures.length - 1; i >= 0; i--)
    {
        while(!st.empty() && temperatures[i] >= temperatures[st.peek()])
        {
            st.pop();
        }
        if(!st.empty()) answer[i] = st.peek() - i;
        st.push(i);
    }
    return answer;
}
```

看完题解和灵神写的差不多

# 22. 括号生成

第一版写的性能很差，memory 5%，time 5%

```cpp
class Solution {
public:
    vector<string> generateParenthesis(int n) {
        string start("(");
        generate(n - 1, n, start);
        return res;
    }
private:
    vector<string> res;
    void generate(int l, int r, string s){
        if(l == 0){
            for (int i = 0; i < r; i++) s += ')';
            if(vaildate(s)) res.emplace_back(std::move(s));
        }else if(r == 0){
            for (int i = 0; i < l; i++) s += '(';
            if(vaildate(s)) res.emplace_back(std::move(s));
        }else{
            generate(l - 1, r, s + '(' );
            generate(l, r - 1, s + ')' );
        }
    }
    bool vaildate(const string& s){
        stack<int> st;
        for (size_t i = 0; i < s.size(); i++)
        {
            if(s[i] == '('){
                st.push(')');
            }else{
                if(st.empty() || st.top() != s[i]) return false;
                st.pop();
            }
        }
        return st.empty();
    }
};
```

看了一点灵神的题解发现原来在创建的时候就可以validate括号的有效性了，不需要新建一个stack来判断。

然后我自己就原来的代码进行优化，memory 93%， time 100%，说明这一版性能提升了很多

```cpp
class Solution {
public:
    vector<string> generateParenthesis(int n) {
        string start(2 * n, '(');
        generate(n - 1, n, 1, start);
        return res;
    }
private:
    vector<string> res;
    void generate(int l, int r, int index, string& s){
        if(l == 0){
            for (int i = 0; i < r; i++) s[index++] = ')';
            res.emplace_back(s);
        }else if(r == 0){
            for (int i = 0; i < l; i++) s[index++] = '(';
            res.emplace_back(s);
        }else{
            if(l > r) return;
            s[index++] = '(';
            generate(l - 1, r, index, s);  
            index--;
            if(l < r){
                s[index++] = ')';
                generate(l, r - 1, index, s);
            }
        }
    }
};
```

# 84. 柱状图中最大的矩形

一开始没想出来，看了灵神的题解才明白: 题目本质是计算高×宽的最大值，最大矩形的高度一定是heights中的元素，可以枚举每个高度，找每个高度左右两边首个低于这个高度的位置。

[灵神题解](https://leetcode.cn/problems/largest-rectangle-in-histogram/solutions/2695467/dan-diao-zhan-fu-ti-dan-pythonjavacgojsr-89s7/)

希望下次看到能够理解写出来吧

# 150. 逆波兰表达式求值

思路也很简单，直接上代码

````cpp
int evalRPN(vector<string>& tokens) {
    stack<int> st;
    for (size_t i = 0; i < tokens.size(); i++)
    {
        string s = tokens[i];

        int num = 0;
        auto [ptr, ec] = std::from_chars(s.data(), s.data() + s.size(), num);
        if(ec == std::errc()){
            st.push(num);
            continue;
        }

        int b = st.top();
        st.pop();
        int a = st.top();
        st.pop();
        if(s == "+") st.push(a + b);
        else if(s == "-") st.push(a - b);
        else if(s == "*") st.push(a * b);
        else st.push(a / b);
    }
    return st.top();
}
````

````java
public int evalRPN(String[] tokens) {
    Stack<Integer> st = new Stack<>();        
    for (String string : tokens) {
        char c = string.charAt(0);
        if(string.length() > 1 || Character.isDigit(c)){
            st.push(Integer.parseInt(string));
            continue;
        }

        int b = st.pop(), a = st.pop();
        if(c == '+') st.push(a + b);
        else if(c == '-') st.push(a - b);
        else if(c == '*') st.push(a * b);
        else st.push(a / b);
    }
    return st.pop();
}
````

# 853. 车队

这道题有点难度，鏖战一个多小时写出来了，我的想法是大根堆排序（key是position）来判断当前的车会不会被追上，但这个题单是关于stack的，于是思考怎么使用stack来解决这个问题

```cpp
int carFleet(int target, vector<int>& position, vector<int>& speed) {
    priority_queue<pair<int, int>> pq;
    for (size_t i = 0; i < position.size(); i++)
    {
        pq.push({position[i], speed[i]});
    }
    
    int res = 0;
    int prev_pos = -1, prev_speed = -1;
    while (!pq.empty())
    {
        if(prev_pos == -1){
            prev_pos = pq.top().first;
            prev_speed = pq.top().second;
            pq.pop();
            continue;
        }

        int cur_pos = pq.top().first;
        int cur_speed = pq.top().second;
        pq.pop();

        if(cur_speed < prev_speed){
            res++;
        }else{
            double time = (prev_pos - cur_pos) / double(cur_speed - prev_speed) ;
            if((prev_pos + time * prev_speed) > target) res++;
            else continue;
        }
        prev_pos = cur_pos;
        prev_speed = cur_speed;
    }
    return res + 1;
    
}
```

基于上一个版本可以做判断追车的优化

```cpp
int carFleet(int target, vector<int>& position, vector<int>& speed) {
    priority_queue<pair<int, int>> pq;
    for (size_t i = 0; i < position.size(); i++)
    {
        pq.push({position[i], speed[i]});
    }

    if(pq.empty()) return 0;

    int res = 0;
    double prev_time = double(target - minHeap.top().first) / minHeap.top().second;
    pq.pop();
    while (!pq.empty())
    {
        double cur_time = double(target - minHeap.top().first) / minHeap.top().second;

        if(cur_time > prev_time){
            prev_time = cur_time;
            res++;
        }
        pq.pop();
    }
    return res + 1;
}
```

于是这里就很明显是可以做一个单调栈来维护了，不过排序是升序的

```cpp
int carFleet(int target, vector<int>& position, vector<int>& speed) {
    vector<pair<int, int>> record;
    for (size_t i = 0; i < position.size(); i++)
    {
        record.push_back({position[i], speed[i]});
    }

    std::sort(record.begin(), record.end(), [](const pair<int, int>& a, const pair<int, int>& b) {
        return a.first < b.first; 
    });

    stack<double> st;
    for (size_t i = 0; i < record.size(); i++)
    {
        int p = record[i].first, s = record[i].second;
        double t = 1.0 * (target - p) / s;

        while(!st.empty() && t >= st.top()){
            st.pop();
        }
        st.push(t);
    }
    return st.size(); 
}
```

考虑到第一版的优化版，于是这里不需要使用一个stack来维护了，直接遍历就可以判断了

```cpp
    int carFleet(int target, vector<int>& position, vector<int>& speed) {
        size_t n = position.size();
        vector<pair<int, int>> record(n);
        for (size_t i = 0; i < n; i++)
        {
            record[i] = {position[i], speed[i]};
        }

        std::sort(record.begin(), record.end(), [](const pair<int, int>& a, const pair<int, int>& b) {
            return a.first > b.first; 
        });

        int res = 0;
        double pt = 0;
        for (size_t i = 0; i < n; i++)
        {
            double t = 1.0 * (target - record[i].first) / record[i].second;

            if(t > pt){
                res++;
                pt = t;
            }

        }
        return res;
    }
```

# 735. 小行星碰撞

碰撞规则已经给出来了，于是很自然的就知道要使用栈记录当前还存在的行星

```cpp
vector<int> asteroidCollision(vector<int>& asteroids) {
    stack<int> st; 
    for (size_t i = 0; i < asteroids.size(); i++)
    {
        int cur = asteroids[i];
        if(!st.empty()){
            if((st.top() < 0 && cur > 0) || (st.top() * cur > 0)){
                st.push(cur);
                continue;
            }
            while(!st.empty() && (st.top() * cur < 0) && abs(cur) > abs(st.top())){
                st.pop();
            }
            if(!st.empty() && (st.top() * cur < 0) && abs(cur) == abs(st.top())){
                st.pop();
                continue;
            }
            if(!st.empty() && (st.top() * cur < 0) && abs(cur) < abs(st.top())) continue;
        }
        st.push(cur);
    }

    int size = static_cast<int>(st.size());
    vector<int> res(size);
    for (int i = size - 1; i >= 0; i--)
    {
        res[i] = st.top();
        st.pop();
    }
    return res; 
}
```

虽然逻辑都在但是感觉空间效率有点低，看了灵神的题解发现先站队写起来就很简洁，空间效率也更高。思路很不一样，受教了

[735灵神题解](https://leetcode.cn/problems/asteroid-collision/solutions/3938065/yong-zhan-wei-hu-xiao-xing-xing-pythonja-llqqe)

# 402. 移掉k个数字

这道题的思维强度比较高，初见没写出来。

[官方的题解](https://leetcode.cn/problems/remove-k-digits/solutions/484940/yi-diao-kwei-shu-zi-by-leetcode-solution)解释的不错

```cpp
string removeKdigits(string num, int k) {
    string st;
    
    for (char digit : num) {
        while (!st.empty() && k > 0 && st.back() > digit) {
            st.pop_back();
            k--;
        }
        st.push_back(digit);
    }
    
    while (k > 0 && !st.empty()) {
        st.pop_back();
        k--;
    }
    
    int start = 0;
    while (start < st.size() && st[start] == '0') {
        start++;
    }
    
    string res = st.substr(start);
    
    return res.empty() ? "0" : res;
}
```

# 496. 下一个更大的数字I

很明显的单调栈，直接上代码

```cpp
vector<int> nextGreaterElement(vector<int>& nums1, vector<int>& nums2) {
    stack<int> st; 
    unordered_map<int, int> hp;

    int n = static_cast<int>(nums2.size());
    int r[n];

    for (int i = n - 1; i >= 0; i--)
    {
        hp[nums2[i]] = i;
        while(!st.empty() && nums2[st.top()] < nums2[i]){
            st.pop();
        }
        if(st.empty()) r[i] = -1;
        else r[i] = nums2[st.top()];
        st.push(i);
    }
    
    vector<int> res(nums1.size());
    for (size_t i = 0; i < nums1.size(); i++)
    {
        res[i] = r[hp[nums1[i]]];
    }
    return res; 
}
```

[灵神题解](https://leetcode.cn/problems/next-greater-element-i/solutions/2820648/shi-pin-dan-diao-zhan-de-liang-chong-xie-ri0i)，只能说灵神的思路还是强的，优化的思路受教了

首先是可以哈希 `nums1` 然后再遍历 `nums2`
- 从右往左遍历
- 从左往右遍历

从左往右遍历的关键在于：

> 只要遍历到比栈顶元素更大的数，就意味着栈顶元素找到了答案，记录答案，并弹出栈顶。