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
