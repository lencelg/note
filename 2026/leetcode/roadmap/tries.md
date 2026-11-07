# Tries

A trie is a tree structure built from the characters of strings, where each path
from the root to a marked node spells out a word.

It is the right data structure when you need fast prefix lookups across a large
set of strings.

A hash map can check if a whole word exists,
but a trie can check if any word in your dictionary starts
with a given prefix in O(length) time.

The three problems in this stage cover:

- building a trie
- searching with wildcards
- using a trie to prune a grid search

it covers the full range of trie applications in interviews.

上次做字典树好像还是cs106b的时候，遥远的记忆了

## 208. 实现前缀树

因为这里只有小写字母，所以用数组比较好，同时要记得写析构函数，leetcode做题就不写了

哈希版本

````cpp
#include <bits/stdc++.h>
using namespace std;
class Trie {
struct Node
{
    unordered_map<char, Node*> children;
    bool exist;
    Node(): exist(false){}
};
Node* head;
public:
    Trie() {
        head = new Node();
    }
    
    void insert(string word) {
        Node* cur = head;
        for(char c : word)
        {
            cur->children[c] = new Node();  
            cur = cur->children[c];
        } 
        cur->exist = true;
    }
    
    bool search(string word) {
        Node* cur = head;
        for(char c : word)
        {
            if(!cur->children.count(c)) return false;
            cur = cur->children[c];
        } 
        return cur->exist;
    }
    
    bool startsWith(string prefix) {
        Node* cur = head;
        for(char c : prefix)
        {
            if(!cur->children.count(c)) return false;
            cur = cur->children[c];
        }
        return true;
    }
};
````

数组版

````cpp
class Trie {
    struct Node {
        Node* children[26];
        bool exist;
        Node() : exist(false) {
            memset(children, 0, sizeof(children));
        }
    };
    Node* head;

public:
    Trie() {
        head = new Node();
    }
    
    void insert(const string& word) {
        Node* cur = head;
        for (char c : word) {
            int idx = c - 'a';
            if (cur->children[idx] == nullptr) {
                cur->children[idx] = new Node();
            }
            cur = cur->children[idx];
        }
        cur->exist = true;
    }
    
    bool search(const string& word) {
        Node* cur = head;
        for (char c : word) {
            int idx = c - 'a';
            if (cur->children[idx] == nullptr) return false;
            cur = cur->children[idx];
        }
        return cur->exist;
    }
    
    bool startsWith(const string& prefix) {
        Node* cur = head;
        for (char c : prefix) {
            int idx = c - 'a';
            if (cur->children[idx] == nullptr) return false;
            cur = cur->children[idx];
        }
        return true;
    }
};
````

[题解页](https://leetcode.cn/problems/implement-trie-prefix-tree/solutions/)

## 211. 添加与搜索单词 - 数据结构设计

只是搜索的时候变成了递归，写成dfs

````cpp
class WordDictionary {
    struct node 
    {
        node* children[26];
        bool exist;
        node(): exist(false){
            memset(children, 0, sizeof(children));
        }
    };
    node* head;
public:
    WordDictionary() {
        head = new node(); 
    }
    
    void addWord(string word) {
        node* cur = head;
        for(char c : word)
        {
            if(cur->children[c - 'a'] == nullptr)
            {
                cur->children[c - 'a'] = new node();
            }
            cur = cur->children[c - 'a'];
        }
        cur->exist = true;
    }
    
    bool search(string word) {
        bool found = false;
        int n = word.size();
        auto dfs = [&](this auto&& dfs, int idx, node* cur) -> void{
            if(found) return;
            if(!cur) return;
            if(idx == n)
            {
                found = cur->exist;
                return;
            }

            char c = word[idx];
            if(c != '.') dfs(idx + 1, cur->children[c - 'a']);
            else{
                for (int i = 0; i < 26; i++)
                {
                    if(cur->children[i])
                    {
                        dfs(idx + 1, cur->children[i]);
                    }
                }
            }
        };
        dfs(0, head);
        return found;
    }
};
````

[题解页](https://leetcode.cn/problems/design-add-and-search-words-data-structure/solutions)

## 单词搜索 II

最喜欢优化的一集

基础就是前缀树加上dfs

这里找到了一个单词并不能立刻返回，因为一个单词可能是另外一个单词的前缀。我通过额外的`used`字段来避免重复的`word`

我的初版

````cpp
#include <bits/stdc++.h>
using namespace std;
class Solution {
    struct node
    {
        node* children[26];
        bool exist;
        bool used;
        node(): exist(false), used(false)
        {
            memset(children, 0, sizeof(children));
        }
    };
    node* head; 

    void addWord(string& word)
    {
        node* cur = head;
        for(auto c : word)
        {
            int idx = c - 'a';
            if(cur->children[idx] == nullptr)
            {
                cur->children[idx] = new node();
            }
            cur = cur->children[idx];
        }
        cur->exist = true;
    }
public:
    vector<string> findWords(vector<vector<char>>& board, vector<string>& words) {
        head = new node();
        for(auto& w : words) addWord(w);

        vector<string> ans;
        vector<char> collect;
        int m = board.size(), n = board[0].size();
        vector<vector<bool>> used(m, vector<bool>(n, false));
        constexpr array<pair<int, int>, 4> dirs = {{
            {0, 1}, {1, 0}, {-1, 0}, {0, -1}
        }};
        auto dfs = [&](this auto&& dfs, int i, int j, node* cur) -> void{
            if(!cur) return;

            collect.push_back(board[i][j]);
            used[i][j] = true;
            if(cur->exist && !cur->used)
            {
                cur->used = true;
                string s(collect.begin(), collect.end());
                ans.push_back(move(s));
            }

            for(auto& d : dirs)
            {
                int ni = i + d.first, nj = j + d.second;
                if(0 <= ni && ni < m && 0 <= nj && nj < n)
                {
                    if(!used[ni][nj]) dfs(ni, nj, cur->children[board[ni][nj] - 'a']);
                }
            }
            collect.pop_back();
            used[i][j] = false;
        };

        for (int i = 0; i < m; i++)
        {
            for (int j = 0; j < n; j++)
            {
                dfs(i, j, head->children[board[i][j] - 'a']);
            }
        }
        return ans;
    }
};
````

我这里的优化思路和单词搜索I里面灵神的思路差不多，写了一堆就memory少了2Mb左右，原本是20Mb左右，屎山代码无疑

````cpp
class Solution {
    struct node
    {
        node* children[26];
        bool exist;
        bool used;
        bool reversed;
        node(): exist(false), used(false), reversed(false)
        {
            memset(children, 0, sizeof(children));
        }
    };
    node* head; 

    void addWord(string& word, bool reversed)
    {
        node* cur = head;
        for(auto c : word)
        {
            int idx = c - 'a';
            if(cur->children[idx] == nullptr)
            {
                cur->children[idx] = new node();
            }
            cur = cur->children[idx];
        }
        cur->exist = true;
        if(reversed) cur->reversed = true;
    }
public:
    vector<string> findWords(vector<vector<char>>& board, vector<string>& words){
        head = new node();
        int m = board.size(), n = board[0].size();
        unordered_map<int, int> cnt;
        for (int i = 0; i < m; i++)
            for (int j = 0; j < n; j++)
                ++cnt[board[i][j]];        
        
        vector<bool> exist(words.size(), true);
        vector<bool> rev(words.size(), false);
        for (int i = 0; i < words.size(); i++)
        {
            unordered_map<int, int> record;
            for(auto c: words[i]){
                if(++record[c] > cnt[c]){
                    exist[i] = false;
                    break;
                }
            }
            if(record[words[i][0]] < record[words[i].back()]){
                ranges::reverse(words[i]);
                rev[i] = true;
            }
        }
        
        for (int i = 0; i < words.size(); i++)
        {
            if(exist[i]) addWord(words[i], rev[i]);
        }
        

        vector<string> ans;
        vector<char> collect;
        vector<vector<bool>> used(m, vector<bool>(n, false));

        constexpr array<pair<int, int>, 4> dirs = {{
            {0, 1}, {1, 0}, {-1, 0}, {0, -1}
        }};
        auto dfs = [&](this auto&& dfs, int i, int j, node* cur) -> void{
            if(!cur) return;

            collect.push_back(board[i][j]);
            used[i][j] = true;
            if(cur->exist && !cur->used)
            {
                cur->used = true;
                string s(collect.begin(), collect.end());
                if(cur->reversed) ranges::reverse(s.begin(), s.end());
                ans.push_back(move(s));
            }

            for(auto& d : dirs)
            {
                int ni = i + d.first, nj = j + d.second;
                if(0 <= ni && ni < m && 0 <= nj && nj < n)
                {
                    if(!used[ni][nj]) dfs(ni, nj, cur->children[board[ni][nj] - 'a']);
                }
            }
            collect.pop_back();
            used[i][j] = false;
        };

        for (int i = 0; i < m; i++)
        {
            for (int j = 0; j < n; j++)
            {
                dfs(i, j, head->children[board[i][j] - 'a']);
            }
        }
        return ans;
    }
};
````

这一版runtime 32%左右, memory 90%左右

[题解页](https://leetcode.cn/problems/word-search-ii/solutions/)

下面是ds的答案，看来是我写的太复杂了，屎山代码

````cpp
#include <vector>
#include <string>
#include <cstring>
using namespace std;

class Solution {
    // Trie 节点：使用纯数组，极速
    struct TrieNode {
        TrieNode* children[26];
        string word;
        TrieNode() {
            memset(children, 0, sizeof(children));
        }
    };
    
    TrieNode* root;
    
    // DFS 方向
    int dirs[4][2] = {{0, 1}, {1, 0}, {-1, 0}, {0, -1}};
    
    void dfs(vector<vector<char>>& board, int r, int c, TrieNode* node, vector<string>& ans) {
        char ch = board[r][c];
        
        // 如果已经被访问过，或者 Trie 树里没有这个分支，直接返回
        if (ch == '#' || node->children[ch - 'a'] == nullptr) {
            return;
        }
        
        node = node->children[ch - 'a'];
        
        // 找到单词了！
        if (!node->word.empty()) {
            ans.push_back(node->word);
            node->word = ""; // ⭐ 优化：找到后清空，防止重复添加
            // 可选优化：如果真的想做到极致，可以在这里把 node 从父节点摘除
        }
        
        // 标记当前格子已访问
        board[r][c] = '#';
        
        // 向四个方向扩展
        for (int i = 0; i < 4; i++) {
            int nr = r + dirs[i][0];
            int nc = c + dirs[i][1];
            
            if (nr >= 0 && nr < board.size() && nc >= 0 && nc < board[0].size()) {
                dfs(board, nr, nc, node, ans);
            }
        }
        
        // 回溯：恢复现场
        board[r][c] = ch;
    }

public:
    vector<string> findWords(vector<vector<char>>& board, vector<string>& words) {
        root = new TrieNode();
        
        // 1. 构建 Trie
        for (const string& w : words) {
            TrieNode* cur = root;
            for (char c : w) {
                int idx = c - 'a';
                if (cur->children[idx] == nullptr) {
                    cur->children[idx] = new TrieNode();
                }
                cur = cur->children[idx];
            }
            cur->word = w; // ⭐ 优化：末尾节点直接存整个单词
        }
        
        vector<string> ans;
        
        // 2. 遍历二维网格
        for (int i = 0; i < board.size(); i++) {
            for (int j = 0; j < board[0].size(); j++) {
                dfs(board, i, j, root, ans);
            }
        }
        
        return ans;
    }
};
````

## 14. 最长公共前缀

不明白为什么这道题在前缀树的题单里面，这里最优的解法是直接顺序遍历，可能是锻炼思维的来了

````cpp
string longestCommonPrefix(vector<string>& strs) {
    ostringstream ss;
    for (size_t i = 0; i < strs[0].size(); i++)
    {
        char cur = strs[0][i];
        for (size_t j = 1; j < strs.size(); j++)
        {
            string& s = strs[j];
            if(i == s.size() || s[i] != cur) return ss.str();
        }
        ss << cur;
    }
    return ss.str();
}
````

想了一下：写成前缀树的话就构建第一个单词，然后就是搜索单词并记录当前的最大前缀，最后放回

解法感觉不如直接顺序遍历的好

[题解页](https://leetcode.cn/problems/longest-common-prefix/solutions)，正如灵神的题解那样，简单题简单做

> This problem is simpler than the others but it teaches you that tries are not
> only for search, they also encode shared structure between strings.

## 648. 单词替换

构建前缀树然后检查替换就行了

````cpp
class Solution {
    struct node
    {
        node* children[26];
        bool exist;
        node(): exist(false){
            memset(children, 0, sizeof(children));
        }
    };
    
    void addWord(string& word){
        node* cur = head;
        for(char c: word){
            int idx = c - 'a';
            if(cur->children[idx] == nullptr){
                cur->children[idx] = new node();
            }
            cur = cur->children[idx];
        }
        cur->exist = true;
    }

    node* head;
public:
    string replaceWords(vector<string>& dictionary, string sentence) {
        head = new node();
        for(string& d : dictionary) addWord(d);

        ostringstream ss;
        istringstream iss(sentence); string cur;
        while(iss >> cur)
        {
            node* s = head;
            size_t idx = 0;
            ostringstream collect;
            while (s && !s->exist && idx < cur.size())
            {
                collect << cur[idx];
                s = s->children[cur[idx] - 'a'];
                idx++;
            }
            if(!s || !s->exist) ss << cur;
            else ss << collect.str();

            if(iss.eof()) break;
            ss << " ";
        }
        return ss.str(); 
    }
};
````

[题解页](https://leetcode.cn/problems/replace-words/solutions)，官方的题解包括哈希集合枚举和字典树

## 2707. 字符串中的额外字符

败下阵来，看了题目半天没有思路原来是dp题，dp没学根本没有思路

优秀解法是倒序字典树+动态规划

[题解页](https://leetcode.cn/problems/extra-characters-in-a-string/solutions)

## 2416. 字符串的前缀分数和

第一想法是字典树+dfs，这里修改`node`的属性来方便计数

````cpp
class Solution
{
    struct node
    {
        node *children[26];
        int prefixCnt;
        node() : prefixCnt(0)
        {
            memset(children, 0, sizeof(children));
        }
    };

    void addWord(string &word)
    {
        node *cur = head;
        for (auto c : word)
        {
            c -= 'a';
            if (cur->children[c] == nullptr)
            {
                cur->children[c] = new node();
            }
            cur = cur->children[c];
        }
        cur->prefixCnt++;
    }
    node *head;

public:
    vector<int> sumPrefixScores(vector<string> &words)
    {
        head = new node();
        for (auto &w : words)
        {
            addWord(w);
        }

        auto dfs = [&](this auto &&dfs, node *cur) -> int
        {
            if (!cur)
            {
                return 0;
            }
            int cnt = 0;
            for (size_t i = 0; i < 26; i++)
            {
                cnt += dfs(cur->children[i]);
            }
            cur->prefixCnt = cnt + cur->prefixCnt;
            return cur->prefixCnt;
        };
        for (size_t i = 0; i < 26; i++)
        {
            dfs(head->children[i]);
        }

        vector<int> ans(words.size(), 0);
        int i = 0;
        for (auto &w : words)
        {
            node *cur = head;
            int idx = 0;
            int cnt = 0;
            while (idx < (int)w.size())
            {
                cur = cur->children[w[idx++] - 'a'];
                cnt += cur->prefixCnt;
            }
            ans[i++] = cnt;
        }
        return ans;
    }
};
````

优化：在`addWord`的时候就可以计数了，无需dfs

````cpp
class Solution
{
    struct node
    {
        node *children[26];
        int prefixCnt;
        node() : prefixCnt(0)
        {
            memset(children, 0, sizeof(children));
        }
    };

    void addWord(string &word)
    {
        node *cur = head;
        for (auto c : word)
        {
            c -= 'a';
            if (cur->children[c] == nullptr)
            {
                cur->children[c] = new node();
            }
            cur = cur->children[c];
            cur->prefixCnt++;
        }
    }
    node *head;

public:
    vector<int> sumPrefixScores(vector<string> &words)
    {
        head = new node();
        for (auto &w : words)
            addWord(w);

        vector<int> ans(words.size(), 0);
        int i = 0;
        for (auto &w : words)
        {
            node *cur = head;
            int cnt = 0;
            for (auto c : w)
            {
                c -= 'a';
                cur = cur->children[c];
                cnt += cur->prefixCnt;
            }
            ans[i++] = cnt;
        }
        return ans;
    }
};
````

[灵神题解](https://leetcode.cn/problems/sum-of-prefix-scores-of-strings/solutions/1831554/by-endlesscheng-ghfr)，灵神把字典树代码放在同一个函数里面，这里因为代码量不大反而比放在外面优雅

## 336. 回文对

最夸张的一集，标准解法是前缀树加后缀树。[大神题解](https://leetcode.cn/problems/palindrome-pairs/solutions/2347656/you-yu-suo-you-ti-jie-yi-ti-san-jie-qian-2sur)

## 1268. 搜索推荐系统

我的写法是字典树加dfs

````cpp
class Solution
{
    struct node
    {
        node *children[26];
        bool exist;
        node() : exist(false)
        {
            memset(children, 0, sizeof(children));
        }
    };
    void addWord(string &word)
    {
        node *cur = head;
        for (auto &c : word)
        {
            c -= 'a';
            if (cur->children[c] == nullptr)
                cur->children[c] = new node();
            cur = cur->children[c];
        }
        cur->exist = true;
    }
    node *head;

public:
    vector<vector<string>> suggestedProducts(vector<string> &products, string searchWord)
    {
        head = new node();
        for (auto &p : products)
        {
            addWord(p);
        }

        vector<vector<string>> ans(searchWord.size(), vector<string>());
        int idx = 0;

        auto dfs = [](this auto &&dfs, node *cur, string &s, vector<string> &t) -> void
        {
            if (!cur || t.size() == 3)
                return;
            if (cur->exist)
            {
                t.push_back(s);
            }

            for (size_t i = 0; i < 26; i++)
            {
                s += i + 'a';
                dfs(cur->children[i], s, t);
                s.pop_back();
            }
        };
        node *cur = head;
        string s;
        for (auto &c : searchWord)
        {
            s += c;
            c -= 'a';
            cur = cur ? cur->children[c] : cur;
            vector<string> t;
            dfs(cur, s, t);
            ans[idx++] = move(t);
        }
        return ans;
    }
};
````

[官方题解](https://leetcode.cn/problems/search-suggestions-system/solutions/101822/suo-tui-jian-xi-tong-by-leetcode-solution)，题解一使用`priority_queue`来记录当前节点的子节点的3个字符，解法二使用二分查找来加速，循序渐进，优秀官解。
