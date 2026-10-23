# Arrays & Hashing

## 1.两数之和

经典题目，两种想法
1. 两边遍历，$O(n^2)$
2. HashMap记录前面的数，然后通过HashMap快速查找

这道题就是经典的空间换时间

````cpp
vector<int> twoSum(vector<int>& nums, int target) {
    unordered_map<int, int> hp;
    for (int i = 0; i < nums.size(); i++)
    {
        if(hp.count(target - nums[i])) {
            return {hp[target - nums[i]], i};
        }
        hp[nums[i]] = i;
    }
    return {}; 
}
````

````java
public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> hp = new HashMap<>();
    for(int i = 0; i < nums.length; i++){
        if(hp.containsKey(target - nums[i])){
            return new int[]{hp.get(target - nums[i]), i};
        }
        hp.put(nums[i], i);
    }
    return new int[]{};
}
````

````python
def twoSum(self, nums: list[int], target: int) -> list[int]:
    hp = {}
    for i, num in enumerate(nums):
        if target - num in hp:
            return [hp[target - num], i]
        hp[num] = i
    return []
````

## 242.有效的字母异位词
两种思路
1. 排序字符串然后遍历比较
2. 使用HashMap来记录频次信息，然后遍历另外一个String来比较频次信息，只用一个HashMap，只需判断是不是有负数的value项

````cpp
bool isAnagram(string s, string t) {
    if(s.size() != t.size()) return false;

    unordered_map<char, int> hp;
    for(char c: s){
        hp[c]++;
    }

    for(char c: t){
        if(--hp[c] < 0){
            return false;
        }
    }
    return true;
}
````

````java
public boolean isAnagram(String s, String t) {
    if(s.length() != t.length()) return false;
    int[] table = new int[26];

    for(int i = 0; i < s.length(); i++){
        table[s.charAt(i) - 'a']++;
    }

    for(int i = 0; i < t.length(); i++){
        table[t.charAt(i) - 'a']--;
        if(table[t.charAt(i) - 'a'] < 0){
            return false;
        }
    }
    return true;
}
````

````python
def isAnagram(self, s: str, t: str) -> bool:
    if len(s) != len(t):
        return False

    table = [0] * 26

    for c in s:
        table[ord(c) - ord('a')] += 1
    
    for c in t:
        table[ord(c) - ord('a')] -= 1

    return all(c == 0 for c in table)
````

## 217.存在重复元素

两种想法
1. 原地算法: 排序数组，然后遍历判断
2. 哈希：使用哈希集合记录频次信息

````cpp
// 原地
bool containsDuplicate(vector<int>& nums) {
    std::ranges::sort(nums);

    for(int i = 1; i < static_cast<int>(nums.size()); i++){
        if(nums[i] == nums[i - 1]) return true;
    }
    return false;
}

// 哈希版
bool containsDuplicate(vector<int>& nums) {
    unordered_set<int> hs;
    for(int x: nums){
        if(hs.count(x) != 0) return true;
        hs.insert(x);
    }
    return false;
}
````

````java
public boolean containsDuplicate(int[] nums) {
    HashSet<Integer> hs = new HashSet<>(); 

    for (Integer x : nums) {
        if(hs.contains(x)){
            return true;
        }
        hs.add(x);
    }
    return false;
}

public boolean containsDuplicate(int[] nums) {
    Arrays.sort(nums);

    for(int i = 1; i < nums.length; i++)
    {
        if(nums[i] == nums[i - 1])
        {
            return true;
        }
    }
    return false;
}
````

````python
def containsDuplicate(self, nums: List[int]) -> bool:
    s = set()

    for x in nums:
        if x in s:
            return True
        s.add(x)
    return False
````

## 49.字母异位词分组

这道题是Medium的题目，难度上了一点
1. 朴素的想法就是遍历strs数组然后对每一个string项排序作为哈希表的key，最后把哈希表的value取出来

最佳解法是发现隐藏的关系: A more optimal approach uses character frequency arrays as keys instead of sorting.

> think about what makes two things equivalent and use that equivalence as a grouping key, a useful mental model for many hash map problems.

由于互为字母异位词的两个字符串包含的字母相同，因此两个字符串中的相同字母出现的次数一定是相同的，故可以将每个字母出现的次数使用字符串表示，作为哈希表的键。

然后就是经典的26大小的数组记录这个信息（题目是只有小写字母）

````cpp
// naive idea
vector<vector<string>> groupAnagrams(vector<string>& strs) {
    unordered_map<string, vector<string>> hp;

    for(string s: strs){
        string c = s;
        std::sort(c.begin(), c.end());
        
        hp[c].emplace_back(s);
    }
    vector<vector<string>> res;
    for(auto[_, v]: hp){
        res.emplace_back(std::move(v));
    }
    return res;
}

// grouping key
vector<vector<string>> groupAnagrams(vector<string>& strs) {
    unordered_map<string, vector<string>> hp;

    for(string s: strs){
        int freq[26] = {0};
        for(char c: s){
            freq[c - 'a']++;
        }
        
        stringstream key;
        for(int i = 0; i < 26; i++){
            if(freq[i] != 0){
                key << char(i + 'a') << freq[i];
            }
        }

        hp[key.str()].emplace_back(s);
    }

    vector<vector<string>> res;
    for(auto[_, v]: hp){
        res.emplace_back(std::move(v));
    }
    return res;
}
````

````java
// naive idea
public List<List<String>> groupAnagrams(String[] strs) {
    HashMap<String, List<String>> hp = new HashMap<>();        
    
    for (String string : strs) 
    {
        char[] array = string.toCharArray();
        Arrays.sort(array);
        String key = new String(array);

        List<String> list = hp.getOrDefault(key.toString(), new ArrayList<String>());
        list.add(string);
        hp.put(key.toString(), list);
    }
    return new ArrayList<List<String>>(hp.values());
}
// grouping key
public List<List<String>> groupAnagrams(String[] strs) {
    HashMap<String, List<String>> hp = new HashMap<>();        
    
    for (String string : strs) 
    {
        int[] freq = new int[26];

        for(int i = 0; i < string.length(); i++)
        {
            freq[string.charAt(i) - 'a']++;
        }

        StringBuilder sb = new StringBuilder();
        for(int i = 0; i < 26; i++)
        {
            if(freq[i] != 0)
            {
                sb.append((char)(i + 'a'));
                sb.append(freq[i]);
            }
        }

        List<String> list = hp.getOrDefault(sb.toString(), new ArrayList<String>());
        list.add(string);
        hp.put(sb.toString(), list);
    }
    return new ArrayList<List<String>>(hp.values());
}
````

````python
def groupAnagrams(self, strs: list[str]) -> list[list[str]]:
    map = collections.defaultdict(list)

    for s in strs:
        map["".join(sorted(s))].append(s)

    return list(map.values())

// grouping keys
def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        mp = collections.defaultdict(list)

        for s in strs:
            counts = [0] * 26
            for c in st:
                counts[ord(c) - ord('a')] += 1

            mp[tuple(counts)].append(s)
        
        return list(mp.values())
````

## 347. 前 K 个高频元素
给你一个整数数组 `nums` 和一个整数 `k` ，请你返回其中出现频率前 `k` 高的元素。你可以按任意顺序返回答案。

进阶：你所设计算法的时间复杂度必须优于 $O(n log n)$ ，其中 $n$ 是数组大小。

优于$O(n log(n))$ 的思路有两种
- 记录频次信息然后对频次排序，用小根堆来辅助去除最少频次的项
- 和第一种差不多，不过使用桶排序来辅助记录最多频次的项
````cpp
// naive idea
vector<int> topKFrequent(vector<int>& nums, int k) {
    unordered_map<int, int> hp;
    for(int n: nums){
        hp[n]++;
    }

    priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>> pq;
    for(auto [key, val]: hp){
        pq.push({val, key});
        if(pq.size() > k){
            pq.pop();
        }
    }

    vector<int> res;
    while (!pq.empty()){
        res.push_back(pq.top().second);
        pq.pop();
    }
    return res; 
}

// bucket sort
vector<int> topKFrequent(vector<int>& nums, int k) {
    unordered_map<int, int> hp;
    for(int x: nums){
        hp[x]++;
    }

    int n = static_cast<int>(nums.size());
    vector<vector<int>> buckets(n + 1);

    for(auto [key, count]: hp){
        buckets[count].push_back(key);
    }

    vector<int> res;
    for(int i = n; i >= 0 && res.size() < k; --i){
        for(int num: buckets[i]){
            res.push_back(num);
        }
        if(res.size() == k) break;
    }
    return res;
}
````

````java
// buckets sort
public int[] topKFrequent(int[] nums, int k) {
    Map<Integer, Integer> map = new HashMap<>();
    for (int num : nums) {
        map.put(num, map.getOrDefault(num, 0) + 1);
    }

    List<Integer>[] buckets = new List[nums.length + 1];
    for (int num : map.keySet()) {
        int freq = map.get(num);
        if (buckets[freq] == null) {
            buckets[freq] = new ArrayList<>();
        }
        buckets[freq].add(num);
    }

    int[] res = new int[k];
    int idx = 0;
    for (int i = buckets.length - 1; i >= 0 && idx < k; i--) {
        if (buckets[i] != null) {
            for (int num : buckets[i]) {
                res[idx++] = num;
                if (idx == k) {
                    break;
                }
            }
        }
    }
    return res;
}
````

## 238. 除了自身以外的乘积

给你一个整数数组 `nums`，返回 数组 `answer` ，其中 `answer[i]` 等于 `nums` 中除了 `nums[i]` 之外其余各元素的乘积。

题目数据 **保证** 数组 `nums` 之中任意元素的全部前缀元素和后缀的乘积都在 **32 位** 整数范围内。

请 **不要使用除法**，且在 `O(n)` 时间复杂度内完成此题。

进阶：在$O(1)$的空间复杂度完成这道题目

---

一个数除了自身以外的乘积由两部分的乘积组成
- 这个数**前面**所有数的乘积
- 这个数**后面**所有数的乘积

这里就是经典小技巧，prefix的乘积可以在遍历的时候计算，从而不需要额外的空间来储存

````cpp
vector<int> productExceptSelf(vector<int>& nums) {
   int n = static_cast<int>(nums.size());

   int postfix[n];
   postfix[n - 1] = 1;

   int cur = 1;
   for (int i = n - 1; i >= 0; --i)
   {
       postfix[i] = cur;
       cur *= nums[i];
   }
   
   vector<int> res(n);
   cur = 1;
   for(int i = 0; i < n; i++){
       res[i] = cur * postfix[i];
       cur *= nums[i];
   }
   return res;
}
````

然而题目里面还有进阶的玩法，其实仔细观察就可以发现在更新的时候`res`数组和`postfix`数组的数据没有冲突，于是可以使用`postfix`数组来实现原地修改

````cpp
vector<int> productExceptSelf(vector<int>& nums) {
    int n = static_cast<int>(nums.size());

    vector<int> postfix(n);
    postfix[n - 1] = 1;

    int cur = 1;
    for (int i = n - 1; i >= 0; --i)
    {
        postfix[i] = cur;
        cur *= nums[i];
    }
    
    cur = 1;
    for(int i = 0; i < n; i++){
        postfix[i] = cur * postfix[i];
        cur *= nums[i];
    }
    return postfix;
}
````

````java
public int[] productExceptSelf(int[] nums) {
    int n = nums.length;
    int[] postfix = new int[n];  
    int cur = 1;
    for(int i = n - 1; i >= 0 ; --i)
    {
        postfix[i] = cur;
        cur *= nums[i];
    }

    int[] res = new int[n];
    cur = 1;
    for(int i = 0; i < n; ++i){
        res[i] = cur * postfix[i];
        cur *= nums[i];
    }
    return res;
}

public int[] productExceptSelf(int[] nums) {
    int n = nums.length;
    int[] postfix = new int[n];  
    int cur = 1;
    for(int i = n - 1; i >= 0 ; --i)
    {
        postfix[i] = cur;
        cur *= nums[i];
    }

    cur = 1;
    for(int i = 0; i < n; ++i){
        postfix[i] = cur * postfix[i];
        cur *= nums[i];
    }
    return postfix;
}
````

# 36. 有效的数独
这道题是一道小的思维题，按照题目要求做就行了

```cpp
bool isValidSudoku(vector<vector<char>>& board) {
    int m = static_cast<int>(board.size());
    int n = static_cast<int>(board[0].size());

    int row[9][9] = {0};
    int col[9][9] = {0};
    int nine[3][3][9] = {0};
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n; j++)
        {
            if(board[i][j] != '.')
            {
                int num = board[i][j] - '1'; 
                row[i][num]++;
                col[j][num]++;
                nine[i / 3][j / 3][num]++;
                if(row[i][num] || col[j][num] || nine[i/ 3][j / 3][num] ){
                    return false;
                }
            }
        }
    }
    return true;
}
```

```java
public boolean isValidSudoku(char[][] board) {
    int[][] row = new int[9][9];        
    int[][] col = new int[9][9];        
    int[][][] nine = new int[3][3][9];        

    for (int i = 0; i < 9; i++) 
    {
        for (int j = 0; j < 9; j++) 
        {
            if(board[i][j] != '.')
            {
                int num = board[i][j] - '1';
                row[i][num]++;
                col[j][num]++;
                nine[i / 3][j / 3][num]++;
                if(row[i][num] || col[j][num] || nine[i / 3][j / 3][num] ){
                    return false;
                }
            }
        }
    }
    return true;
}
```

# 128. 最长连续序列

这里能够知道`nums`的同一个元素出现的次数没有关系并且会对任务复杂化，于是考虑使用 set 来简化

检测也很简单，就是在一段连续序列最小的元素开始不断增长序列。

小优化：在长度大于 n / 2 的时候就可以返回，因为只有最长的序列的才能满足这一个条件

```cpp
int longestConsecutive(vector<int>& nums) {
    int res = 0;
    int n = static_cast<int>(nums.size()) / 2;

    // 这里更优雅的写法是
    // unordered_set<int> hs(nums.begin(), nums.end());
    unordered_set<int> hs; 
    for(int num: nums){
        hs.insert(num);
    }

    for(auto num : hs){
        if(!hs.count(num - 1)){
            int cur = num;
            int lenght = 1;

            while(hs.count(cur + 1)){
                lenght++;
                cur++;
            }

            res = res > lenght ? res : lenght;

            if(res > n){
                return res;
            }
        }
    }
    return res;
}
```

```java
public int longestConsecutive(int[] nums) {
    Set<Integer> hs = new HashSet<>();        
    for (int num : nums) 
    {
        hs.add(num);
    }

    int res = 0;
    for (Integer num: hs) 
    {
        if(!hs.contains(num - 1)) 
        {
            int y = num + 1;

            while (hs.contains(y))
            {
                y++; 
            }

            res = Math.max(y - num, res);

            if(res > (nums.length / 2))
            {
                return res;
            }
        }
    }
    return res;
}
```

# 169. 多数元素

这道题很不错，有很多解题思路，进阶的解法思路也让人眼前一亮
1. HashMap 记录频次， $O(n)$时间，$O(n)$空间
2. 原地排序， $O(nlog(n)) + O(n)$时间，$O(log(n))$栈空间
3. [Boyer-Moore 投票算法](https://zh.wikipedia.org/wiki/%E5%A4%9A%E6%95%B0%E6%8A%95%E7%A5%A8%E7%AE%97%E6%B3%95)

```cpp
// HashMap
int majorityElement(vector<int>& nums) {
    unordered_map<int, int> hp;
    for(int num: nums){
        hp[num]++;
    }

    int n = static_cast<int>(nums.size()) / 2;
    for(auto [k, v]: hp)
    {
        if(v > n) return k;
    }
    return 0;
}

// 自己写堆排序就是O(1)的空间
int majorityElement(vector<int>& nums) {
    ranges::sort(nums);
    size_t n = nums.size();
    int maxCount = 0;
    for(size_t i = 0; i < n;){
        int curIndex = i + 1;
        while(curIndex < n && nums[curIndex] == nums[i]){
            curIndex++;
        }
        int curCount = curIndex - i;
        maxCount = maxCount > curCount ? maxCount : curCount;
        if(maxCount > (n / 2)){
            return nums[i];
        }

        i += curCount;
    }
    return 0;
}

//  Boyer-Moore 投票算法
int majorityElement(vector<int>& nums) {
    int count = 0;
    int candidate = 0;
    for(int num: nums){
        if(count == 0){
            candidate = num;
        }
        count += (candidate == num) ? 1 : -1;
    }
    return candidate;
}
```

```java
public int majorityElement(int[] nums) {
    int count = 0;
    int res = 0;
    for (int num : nums) {
        if(count == 0){
            res = num;
        }
        count += (res == num) ? 1 : -1;
    } 
    return res;
}
```