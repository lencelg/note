# Two Pointers
双指针技术是一种使用两个指针遍历数组的方法。这种技术通常比使用单个指针或嵌套循环更有效地解决问题。通常，指针从数组的两端或以不同的速度遍历。

## 192. 验证回文串

双指针，没什么特别的，按照题目要求判断就行了

写完才发现有一个`isalnum`的函数可以判断判断一个字符是否是“字母或数字”。于是写起来就简洁很多

```cpp
public:
    bool isPalindrome(string s) {
        size_t l = 0;
        
        size_t r = s.size(); 
        while(r > l){
            if(!isLegal(s[l])){
                l++;
                continue;
            }
            
            if(!isLegal(s[r])){
                r--;
                continue;
            }
            
            if(convert(s[l]) != convert(s[r])) return false;
            l++;
            r--;
        }
        return true;
    }
private:
    bool isLegal(char s){
        return (s >= '0' && s <= '9') || (s >= 'a' && s <= 'z') || (s >= 'A' && s <= 'Z');
    }
    int convert(char s){
        if(s >= 'A' && s <= 'Z'){
            return s - 'A' + 'a';
        }
        return s;
    }
```

```java
public boolean isPalindrome(String s) {
    int l = 0, r = s.length() - 1;
    while(l < r)
    {
        char left = s.charAt(l);
        char right = s.charAt(r);
        
        if(!Character.isLetterOrDigit(left)) {
            l++;
            continue;
        }

        if(!Character.isLetterOrDigit(right)) {
            r--;
            continue;
        }

        if(Character.toLowerCase(left) != Character.toLowerCase(right)) {
            return false;
        }
        l++;
        r--;
    }
    return true;
}
```

# 15. 三数之和

这道题比较有深度，鏖战50分钟写出来，看完题解后收获很大，自己写的虽然通过了但是有很多地方可以优化。

这道题应该是经典的双指针题目了

```cpp
vector<vector<int>> threeSum(vector<int>& nums) {
    ranges::sort(nums); 

    vector<vector<int>> res;
    unordered_set<string> hs;
    int n = static_cast<int>(nums.size());
    for (size_t i = 0; i < n; i++)
    {
        int l = i + 1;
        int r = n - 1;
        
        int target = -nums[i];
        while(l < r){
            if((nums[l] + nums[r]) == target){
                ostringstream ss;
                ss << nums[i] << nums[l] << nums[r];
                string key = ss.str();

                if(hs.count(key)){
                    r--;
                    l++;
                    continue;
                }

                hs.insert(key);
                vector<int> cur = {nums[i], nums[l], nums[r]};
                res.emplace_back(std::move(cur));
            }else if((nums[l] + nums[r]) < target){
                if(r < (n -1)){
                    if((nums[l] + nums[r + 1]) < target){
                        r++;
                    }
                }
                l++;
            }else{
                if(l > (i + 1)){
                    if((nums[l - 1] + nums[r]) > target){
                        l--;
                    }
                }
                r--;
            }
        }
    }
    return res;
    
}
```

上面第一版写完 runtime 5%， memory 5%左右

优化的思路可以把当前的三元组的数字拼接成一个string作为key，如{-1, 0, 1}就是"-101"，首键相同就一定是相同的，因为已经排序了

所以可以写

```cpp
if(i > 0 && nums[i] == nums[i - 1]){
    continue;
}
```

然后考虑第二个数字相同，如果第二个相同第三个就一定确定了，于是也可以跳过

```cpp
vector<vector<int>> threeSum(vector<int>& nums) {
    ranges::sort(nums); 

    vector<vector<int>> res;
    int n = static_cast<int>(nums.size());
    for (size_t i = 0; i < n; i++)
    {
        if(i > 0 && nums[i] == nums[i - 1]){
            continue;
        }

        int l = i + 1;
        int r = n - 1;
        
        int target = -nums[i];
        while(l < r){
            if((nums[l] + nums[r]) == target){
                if((l > i + 1) && nums[l - 1] == nums[l]){
                    r--;
                    l++;
                    continue;
                }

                vector<int> cur = {nums[i], nums[l], nums[r]};
                res.emplace_back(std::move(cur));
                r--;
                l++;
            }else if((nums[l] + nums[r]) < target){
                if(r < (n -1)){
                    if(nums[r + 1] == nums[r]){
                        l++;
                        continue;
                    }

                    if((nums[l] + nums[r + 1]) < target) r++;
                }
                l++;
            }else{
                if(l > (i + 1)){
                    if(nums[l - 1] == nums[l]){
                        r--;
                        continue;
                    }
                    if((nums[l - 1] + nums[r]) > target) l--;
                }
                r--;
            }
        }
    }
    return res;
    
}
```

然后看了灵神的题解发现有更优雅的写法与更多的优化, 下面的代码来自灵神，这里只做交流学习用途

```cpp
class Solution {
public:
    vector<vector<int>> threeSum(vector<int>& nums) {
        ranges::sort(nums);
        vector<vector<int>> ans;
        int n = nums.size();
        for (int i = 0; i < n - 2; i++) {
            int x = nums[i];
            if (i && x == nums[i - 1]) continue; // 跳过重复数字
            if (x + nums[i + 1] + nums[i + 2] > 0) break; // 优化一
            if (x + nums[n - 2] + nums[n - 1] < 0) continue; // 优化二
            
            int j = i + 1, k = n - 1;
            while (j < k) {
                int s = x + nums[j] + nums[k];
                if (s > 0) {
                    k--;
                } else if (s < 0) {
                    j++;
                } else { // 三数之和为 0
                    ans.push_back({x, nums[j], nums[k]});
                    for (j++; j < k && nums[j] == nums[j - 1]; j++); // 跳过重复数字
                    for (k--; k > j && nums[k] == nums[k + 1]; k--); // 跳过重复数字
                }
            }
        }
        return ans;
    }
};
```
这里灵神在和为0的时候集中去重比我的双指针反复横跳好多了。这其实就是前面说的第二个键相同第三个键也一定相同，然而灵神这里还有第三个键相同第二个键一定相同的思路，于是就可以比我的代码少了双指针的反复横跳。

java版本我就不写了（绝对不是因为懒！）
# 11. 盛最多水的容器

最经典的双指针问题, java写起来还是差不多就不写了

```cpp
int maxArea(vector<int>& height) {
    int res = 0;
    int l = 0, r = static_cast<int>(height.size()) - 1;
    while(l < r){
        res = max(res, min(height[r], height[l]) * (r - l));
        (height[r] >= height[l]) ? l++ : r--;
    }
    return res;
}
```

# 42. 接雨水
第一道hard题目，想来20来分钟没写出来，看了题解才明白

这里的双指针其实就是前后缀分解的优化版本, 下面是灵神的题解，这里只做学习交流使用

```cpp
int trap(vector<int>& height) {
    int n = height.size();
    vector<int> pre_max(n); // pre_max[i] 表示从 height[0] 到 height[i] 的最大值
    pre_max[0] = height[0];
    for (int i = 1; i < n; i++) {
        pre_max[i] = max(pre_max[i - 1], height[i]);
    }

    vector<int> suf_max(n); // suf_max[i] 表示从 height[i] 到 height[n-1] 的最大值
    suf_max[n - 1] = height[n - 1];
    for (int i = n - 2; i >= 0; i--) {
        suf_max[i] = max(suf_max[i + 1], height[i]);
    }

    int ans = 0;
    for (int i = 0; i < n; i++) {
        ans += min(pre_max[i], suf_max[i]) - height[i]; // 累加每个水桶能接多少水
    }
    return ans;
}

int trap(vector<int>& height) {
    int ans = 0;
    int pre_max = 0, suf_max = 0;
    int left = 0, right = height.size() - 1;
    while (left < right) {
        pre_max = max(pre_max, height[left]); // 前缀最大值
        suf_max = max(suf_max, height[right]); // 后缀最大值
        if (pre_max < suf_max) { // 可以确定 left 处的接水量
            ans += pre_max - height[left];
            left++; // 搞定了 left，现在问题缩小到 [left+1, right]
        } else { // 可以确定 right 处的接水量
            ans += suf_max - height[right];
            right--; // 搞定了 right，现在问题缩小到 [left, right-1]
        }
    }
    return ans;
}
```

希望下次遇到能推倒出来吧

# 167. 两数之和 II - 输入有序数组
1. 二分查找
2. 双指针

双指针的重点在与推倒与数组已经排序的关系，当`nums[l] + nums[r]` > `target`的时候，对于任何 `i > l`, 必定有`nums[i] + nums[r] > target`, 于是一直移动`r--`直到满足`nums[r] + nums[l] > target && nums[r - 1] + nums[l] <= target`, 这时候`l++`就行了

```cpp
// two pointers
vector<int> twoSum(vector<int>& numbers, int target) {
    int l = 0, r = static_cast<int>(numbers.size()) - 1; 
    while(l < r){
        int sum = numbers[l] + numbers[r];
        if(sum == target){
            return {l + 1, r + 1};
        }else if(sum < target){
            l++;
        }else{
            r--;
            while((r - 1) > l  && (numbers[l] + numbers[r - 1]) >= target){
                r--;
            }
        }
    }
    return {1, 2};
}
```

我的版本的two pointers虽然和最有的复杂度一样，但是这里还有一个小优化

可以直接写

```cpp
if(sum == target) return {l + 1, r + 1};
sum > target ? l++ : r--;
```

因为题目保证一定存在唯一答案。由于当`nums[l] + nums[r] < target && nums[l] + nums[r + 1] > target`, 并且`nums[l + 1] + nums[i] > target if i > r`, 若`nums[l + 1] + nums[r] < target`就不存在答案了，于是就可以这样来写

如果没有唯一答案就得按照我的来写

这里java写起来差不多就不写了

# 75. 颜色分类

最简单的想法就是计数然后覆盖

```cpp
void sortColors(vector<int>& nums) {
    int count[3] = {0};
    for (int i = 0; i < nums.size(); i++)
        ++count[nums[i]];

    int cur = 0;
    for (int i = 0; i < 3; i++){
        for (int j = 0; j < count[i]; j++){
            nums[cur++] = i;
        }
    }
}
```

双指针一次遍历的重点在于边统计边覆盖，主循环覆盖为2, 然后`p1`覆盖成1，最后`p0`覆盖成0

```cpp
void sortColors(vector<int>& nums) {
    int p0 = 0, p1 = 0;
    for (int i = 0; i < nums.size(); i++) {
        int x = nums[i];
        nums[i] = 2;
        if (x <= 1) nums[p1++] = 1;
        if (x == 0) nums[p0++] = 0;
    }
}
```

# 283. 移动零

1. 暴力遍历，$O(n^2)$
2. 双指针, $O(n)$

找到第一个为零的数`nums[p0]`，然后找到一个不为零的数`nums[p1]`，如果 `p1 >= p0` 就可以交换，不然就把`p1 = p0 + 1`，自己的第一版写完感觉还有可以优化的地方

```cpp
void moveZeroes(vector<int>& nums) {
    int p0 = 0, p1 = 0;
    int n = static_cast<int>(nums.size()) - 1;
    while((p1 <= n) && (p0 <= n))
    {
        while(nums[p0] != 0) {
            p0++;
            if(p0 > n) return;
        }
        while(nums[p1] == 0){
            p1++;
            if(p1 > n) return;
        }

        if(p0 <= p1) {
            swap(nums[p0], nums[p1]);
            p0++;
            p1++;
        }else{
            p1 = p0 + 1;
        }
    }
}
```

首先是循环判断可以写成`p1 <= n`，因为p1超过数组长度时说明已经没有非零的数需要交换了

看完题解发现这里的最优雅写法是围绕循环不变量，非零和零元素的交换本质是维护了零元素的index和非零元素的index，而非零元素的index在遍历的时候使用当前遍历的index就行了。

非零元素与自己交换并没有任何影响, 下面的题解来自灵神，这里只作为学习交流使用

```cpp
void moveZeros(vector<int>& nums) {
    /*
    循环不变量：在循环过程中，nums 的数据分布始终如下图
    [ 非零元素 | 零元素 | 尚未遍历 ]
                ^       ^
               start0   i
    */
    int start0 = 0;
    for (int& x : nums) { // 这里 x 是引用
        if (x) {
            swap(x, nums[start0]);
            start0++;
        }
    }
}
```

# 26. 删除有序数组中的重复项

双指针，思路和上一题差不多。注意的是这里不需要swap，直接修改就可以了，因为题目是去除重复的元素，用swap的话还要处理额外的情况

```cpp
int removeDuplicates(vector<int>& nums) {
    int replaceIndex = 1;
    for (int i = 1; i < static_cast<int>(nums.size()); i++)
    {
        if(nums[i] != nums[i - 1])
        {
            nums[replaceIndex] = nums[i];
            replaceIndex++;
        }
    }
    return replaceIndex; 
}
```

# 881. 救生艇

要用到双指针就需要有单调性了，使用排序加双指针，因为这里是求最小船数

```cpp
int numRescueBoats(vector<int>& people, int limit) {
    ranges::sort(people); 

    int l = 0, r = static_cast<int>(people.size()) - 1;
    int res = 0;

    while(r >= 0 && people[r] >= limit){ r--; res++; }

    while(l <= r){
        int sum = people[l] + people[r];
        if(sum > limit){r--; res++;}
        else{ r--; l++; res++; }
    }
    return res;
}
```

看了官方题解才知道是贪心算法，看完题解发现可以写的更优雅一些

```cpp
int numRescueBoats(vector<int>& people, int limit) {
    ranges::sort(people); 

    int res = 0;
    int l = 0, r = static_cast<int>(people.size()) - 1;
    while(l <= r){
        if((people[l] + people[r])> limit) r--;
        else{ r--; l++;}

        res++;
    }
    return res;
}

```

# 18. 四数之和

这里的思路其实和三数之和差不多，写了就会发现重点在于处理数字加法溢出, 这里我是使用`int64_t`来进行cast

```cpp
vector<vector<int>> fourSum(vector<int>& nums, int target) {
    ranges::sort(nums); 

    vector<vector<int>> res;
    int n = static_cast<int>(nums.size());
    for (int i = 0; i < n - 3; i++)
    {
        if(i > 0 && nums[i] == nums[i - 1]) continue;
        if((int64_t(nums[i]) + nums[i + 1] + nums[i + 2] + nums[i + 3]) > target) return res;
        if((int64_t(nums[i]) + nums[n - 1] + nums[n - 2] + nums[n - 3]) < target) continue;

        for (int j = i + 1; j < n - 2; j++)
        {
            if(j > (i + 1) && nums[j] == nums[j - 1]) continue;

            int l = j + 1, r = n - 1;
            while(l < r){
                int64_t sum = int64_t(nums[i]) + nums[j] + nums[l] + nums[r];

                if(sum < target) l++;
                else if(sum > target) r--;
                else{
                    res.push_back({nums[i], nums[j], nums[l], nums[r]});
                    l++; r--;
                    while(l < r && nums[l] == nums[l - 1]) l++;
                    while(r > l && nums[r] == nums[r + 1]) r--;
                }
            }
        }
    }
    return res;
}
```

java 写起来用`long`

```java
public List<List<Integer>> fourSum(int[] nums, int target) {
    Arrays.sort(nums);

    int n = nums.length;
    List<List<Integer>> res = new ArrayList<>(); 
    for (int i = 0; i < n - 3; i++)
    {
        if(i > 0 && nums[i] == nums[i - 1]) continue;
        if(((long)nums[i] + nums[i + 1] + nums[i + 2] + nums[i + 3]) > target) return res;
        if(((long)nums[i] + nums[n - 1] + nums[n - 2] + nums[n - 3]) < target) continue;

        for (int j = i + 1; j < n - 2; j++)
        {
            if(j > (i + 1) && nums[j] == nums[j - 1]) continue;

            int l = j + 1, r = n - 1;
            while(r > l)
            {
                long sum = (long)nums[i] + nums[j] + nums[l] + nums[r];
                if(sum < target) l++;
                else if(sum > target) r--;
                else{
                    res.add(new ArrayList<>(Arrays.asList(nums[i], nums[j], nums[l], nums[r])));
                    l++; r--;
                    while(l < r && nums[l] == nums[l - 1]) l++;
                    while(l < r && nums[r] == nums[r + 1]) r--;
                }
            }
        }
    }
    return res;
}
```

看完灵神的题解发现还有地方可以优化，那就是在第二个数字的时候优化

```java
public List<List<Integer>> fourSum(int[] nums, int target) {
Arrays.sort(nums);

    int n = nums.length;
    List<List<Integer>> res = new ArrayList<>(); 
    for (int i = 0; i < n - 3; i++)
    {
        if(i > 0 && nums[i] == nums[i - 1]) continue;
        if(((long)nums[i] + nums[i + 1] + nums[i + 2] + nums[i + 3]) > target) return res;
        if(((long)nums[i] + nums[n - 1] + nums[n - 2] + nums[n - 3]) < target) continue;

        for (int j = i + 1; j < n - 2; j++)
        {
            if(j > (i + 1) && nums[j] == nums[j - 1]) continue;
            if(((long)nums[i] + nums[j] + nums[j + 1] + nums[j + 2]) > target) break;
            if(((long)nums[i] + nums[j] + nums[n - 1] + nums[n - 2]) < target) continue;

            int l = j + 1, r = n - 1;
            while(r > l)
            {
                long sum = (long)nums[i] + nums[j] + nums[l] + nums[r];
                if(sum < target) l++;
                else if(sum > target) r--;
                else{
                    res.add(new ArrayList<>(Arrays.asList(nums[i], nums[j], nums[l], nums[r])));
                    l++; r--;
                    while(l < r && nums[l] == nums[l - 1]) l++;
                    while(l < r && nums[r] == nums[r + 1]) r--;
                }
            }
        }
    }
    return res;
}
```

没有写出完全优化版本还是有点粗心了。。。
