# Binary Search

Binary search is not just for finding an element in a sorted array. It is a
general technique for eliminating half the search space at each step

it applies whenever you can define a condition that splits possible answers
into a valid half and an invalid half.

## 704. 二分查找

热身题，：3种写法

- 闭区间
- 左闭右开区间
- 开区间

```cpp
int search(vector<int>& nums, int target) {
    int l = 0, r = static_cast<int>(nums.size()) - 1; 
    while(l <= r){
        int mid = l + (r - l) / 2;
        if(nums[mid] < target) l = mid + 1;
        else if(nums[mid] > target) r = mid - 1;
        else return mid;
    }
    return -1;
}

int search(vector<int>& nums, int target) {
    int l = 0, r = static_cast<int>(nums.size()); 
    while(l < r){
        int mid = l + (r - l) / 2;
        if(nums[mid] < target) l = mid + 1;
        else if(nums[mid] > target) r = mid;
        else return mid;
    }
    return -1;
}

int search(vector<int>& nums, int target) {
    int l = -1, r = static_cast<int>(nums.size());
    while((l + 1) < r){
        int mid = l + (r - l) / 2;
        if(nums[mid] < target) l = mid;
        else if(nums[mid] > target) r = mid;
        else return mid;
    }
    return -1;
}
```

当然这里的写法并不好，应该总是写`lower_bound`的版本，因为这样可以解决更复杂的问题，实用性更强

```cpp
int search(vector<int>& nums, int target) {
    int l = 0, r = static_cast<int>(nums.size()) - 1; 
    while(l <= r){
        int mid = l + (r - l) / 2;
        if(nums[mid] < target) l = mid + 1;
        else r = mid - 1;
    }
    return l; // or right + 1
}

int search(vector<int>& nums, int target) {
    int l = 0, r = static_cast<int>(nums.size()); 
    while(l < r){
        int mid = l + (r - l) / 2;
        if(nums[mid] < target) l = mid + 1;
        else r = mid;
    }
    return l; // or right
}

int search(vector<int>& nums, int target) {
    int l = -1, r = static_cast<int>(nums.size());
    while((l + 1) < r){
        int mid = l + (r - l) / 2;
        if(nums[mid] < target) l = mid;
        else r = mid;
    }
    return r; // or left + 1
}
```

## 33. 搜索旋转数组

二分老朋友了，只要仔细理解每种情形就可以了，本质是把 `left` 和 `right` 放在同一侧

```cpp
int search(vector<int>& nums, int target) {
    int l = 0, r = static_cast<int>(nums.size()) - 1;
    while(l <= r){
        int mid = l + (r - l) / 2;
        if(nums[mid] == target) return mid;
        
        // all on same side
        if(nums[l] < nums[mid] && nums[mid] < nums[r]){
            if(nums[mid] < target) l = mid + 1;
            else r = mid - 1;

            continue;
        }

        // target on left side
        if(target > nums[r]){
            if(nums[mid] <= nums[r]) r = mid - 1;
            else{
                if(nums[mid] < target) l = mid + 1;
                else r = mid - 1;
            }
        }else{
        // target on right side
            if(nums[mid] >= nums[l]) l = mid + 1;
            else{
                if(nums[mid] > target) r = mid - 1;
                else l = mid + 1;
            }
       }
    }
    return -1;
}
```

这一次[官方的题解](https://leetcode.cn/problems/search-in-rotated-sorted-array/solutions/220083/sou-suo-xuan-zhuan-pai-xu-shu-zu-by-leetcode-solut/)反而感觉是写的最清晰的

## 153. 寻找旋转排序数组中的最小值

三种情况

- 在最左边
- 在最右边
- 在中间，有`nums[mid - 1] > nums[mid] && nums[mid + 1] > nums[mid]`

```cpp
int findMin(vector<int>& nums) {
    int n = static_cast<int>(nums.size());
    if(n == 1) return nums[0];
    else if(n == 2) return min(nums[0], nums[1]);

    int l = 0, r = n - 1; 
    while(l <= r){
        int mid = l + (r - l) / 2;
        if((mid - 1) < 0 && nums[mid + 1] > nums[mid]) return nums[mid];
        if((mid + 1) == n && nums[mid - 1] > nums[mid]) return nums[mid];
        if(mid > 0 && nums[mid - 1] > nums[mid] && mid < (n - 1) && nums[mid] < nums[mid + 1]) return nums[mid];

        if(nums[mid] >= nums[0]) l = mid + 1;
        else r = mid - 1;
    }
    return nums[0];
}
```

看了灵神的题解感觉灵神的思路太强了，强烈建议学习

[153题灵神题解](https://leetcode.cn/problems/find-minimum-in-rotated-sorted-array/solutions/1987499/by-endlesscheng-owgd/)

## 875. 爱吃香蕉的珂珂

二分答案

```cpp
int minEatingSpeed(vector<int>& piles, int h) {
    int l = 0, r = *max_element(piles.begin(), piles.end());
    while ((l + 1) < r)
    {
        int mid = l + (r - l) / 2;
        ok(mid, piles, h) ? r = mid : l = mid;
    }
    return r;
}
bool ok(int mid, vector<int>& piles, int h){
    int cnt = 0;
    for(int p : piles){
        cnt += p / mid;
        if(p % mid != 0) cnt++;

        if(cnt > h) return false;
    }
    return true;
}
```

[灵神题解](https://leetcode.cn/problems/koko-eating-bananas/solutions/2710324/er-fen-da-an-fu-ti-dan-pythonjavacgojsru-eb18/)

灵神这里的小优化就是匿名函数加整数取整，看灵神题解总是能够学到新东西

## 4. 寻找两个正序数组的中位数

这道题比较难，没写出来，初见还是建议看[题解](https://leetcode.cn/problems/median-of-two-sorted-arrays/solutions/)，题解页里面有不少优质解答，灵神的题解循序渐进。

中位数的本质是：**将一个集合划分为两个长度相等的子集，使得左子集的元素全部小于等于右子集。**
对于两个数组，我们就是要找一条“分割线”，把 `nums1` 和 `nums2` 都切成左右两半，并且保证：

1. **左半部分元素总数** = **右半部分元素总数**（或多 1 个）。
2. **左半部分的所有元素** $\le$ **右半部分的所有元素**。

假设我们在 `nums1` 的索引 `i` 处切一刀，`nums1` 被分成 `[0, i-1]`（左）和 `[i, m-1]`（右）。

为了让左右元素个数相等，`nums2` 的切分点 `j` 是固定的：

`j = (m + n + 1) / 2 - i`

*(注：`+ 1` 是为了当总数为奇数时，左半部分比右半部分多一个元素，中位数就是左半部分的最大值)*

切分的条件:

完美的切分点 `i` 和 `j` 必须满足以下两个条件：

- `nums1[i-1] <= nums2[j]` （nums1 左边最大 <= nums2 右边最小）
- `nums2[j-1] <= nums1[i]` （nums2 左边最大 <= nums1 右边最小）

我们在较短的数组（假设是 `nums1`）上进行二分查找 `i`：

- 如果 `nums1[i-1] > nums2[j]`：说明 `nums1` 的左边太大了，`i` 需要往左移（减小）。
- 如果 `nums2[j-1] > nums1[i]`：说明 `nums1` 的左边太小了，`i` 需要往右移（增大）。
- 如果恰好满足条件，那就是我们找的分割线。

边界处理

- 当 `i = 0` 时，`nums1` 左边没有元素，可以视作 **负无穷大** ($-\infty$)。
- 当 `i = m` 时，`nums1` 右边没有元素，可以视作 **正无穷大** ($+\infty$)。

```cpp
#include <vector>
#include <algorithm>
#include <climits>
using namespace std;

class Solution {
public:
    double findMedianSortedArrays(vector<int>& nums1, vector<int>& nums2) {
        // 保证 nums1 是较短的数组，这样二分查找的范围更小，效率更高
        if (nums1.size() > nums2.size()) {
            return findMedianSortedArrays(nums2, nums1);
        }
        
        int m = nums1.size();
        int n = nums2.size();
        int totalLeft = (m + n + 1) / 2; // 左半部分应有的元素总数
        
        int left = 0;
        int right = m;
        
        while (left <= right) {
            int i = left + (right - left) / 2; // nums1 的切分点
            int j = totalLeft - i;             // nums2 的切分点
            
            // 处理越界情况
            int nums1LeftMax = (i == 0) ? INT_MIN : nums1[i - 1];
            int nums1RightMin = (i == m) ? INT_MAX : nums1[i];
            int nums2LeftMax = (j == 0) ? INT_MIN : nums2[j - 1];
            int nums2RightMin = (j == n) ? INT_MAX : nums2[j];
            
            // 检查是否找到了完美的切分点
            if (nums1LeftMax <= nums2RightMin && nums2LeftMax <= nums1RightMin) {
                // 如果总长度是奇数，中位数就是左半部分的最大值
                if ((m + n) % 2 == 1) {
                    return max(nums1LeftMax, nums2LeftMax);
                } 
                // 如果总长度是偶数，中位数是 (左半最大 + 右半最小) / 2.0
                else {
                    return (max(nums1LeftMax, nums2LeftMax) + min(nums1RightMin, nums2RightMin)) / 2.0;
                }
            } 
            // nums1 切分线靠右了，左半部分太大
            else if (nums1LeftMax > nums2RightMin) {
                right = i - 1;
            } 
            // nums1 切分线靠左了，左半部分太小
            else {
                left = i + 1;
            }
        }
        return 0.0;
    }
};
```

这道题的本质是在两个有序数组中寻找第 $k$ 个小的元素, 中位数就是特殊的“第 k 小元素”。

基于“寻找第 k 小”的经典解法（排除法）

我们要找第 $k$ 小的数。我们可以分别在 `nums1` 和 `nums2` 中取出第 $k/2$ 个元素进行比较：

- 比较 `nums1[k/2 - 1]` 和 `nums2[k/2 - 1]`。
- 如果 `nums1[k/2 - 1] < nums2[k/2 - 1]`，说明 `nums1` 的前 $k/2$ 个元素绝对不可能是第 $k$ 小的元素。
  - 哪怕 `nums2` 的前 $k/2 - 1$ 个元素全都比 `nums1[k/2 - 1]` 小，`nums1` 的这 $k/2$ 个元素最多也只能排在总排名的第 $k-1$ 位。
- 所以，我们可以**安全地删掉** `nums1` 的前 \(k/2\) 个元素。
- 然后让 \(k = k - k/2\)，继续在剩下的数组里找第 \(k\) 小的元素。

*(注：如果某个数组长度不足 \(k/2\)，那就直接淘汰它的全部元素)*

```cpp
#include <vector>
#include <algorithm>
using namespace std;

class Solution {
public:
    double findMedianSortedArrays(vector<int>& nums1, vector<int>& nums2) {
        int m = nums1.size();
        int n = nums2.size();
        int totalLeft = (m + n + 1) / 2;
        int totalRight = (m + n + 2) / 2;

        // 如果是奇数，找第 totalLeft 小
        // 如果是偶数，找第 totalLeft 小和第 totalRight 小
        if ((m + n) % 2 == 1) {
            return getKthElement(nums1, nums2, totalLeft);
        } else {
            return (getKthElement(nums1, nums2, totalLeft) + getKthElement(nums1, nums2, totalRight)) / 2.0;
        }
    }

private:
    // 核心：寻找第 k 小的元素
    int getKthElement(const vector<int>& nums1, const vector<int>& nums2, int k) {
        int m = nums1.size();
        int n = nums2.size();
        int index1 = 0, index2 = 0;

        while (true) {
            // 边界情况
            if (index1 == m) return nums2[index2 + k - 1];
            if (index2 == n) return nums1[index1 + k - 1];
            if (k == 1) return min(nums1[index1], nums2[index2]); // 找第1小，直接比首元素

            // 正常情况：每次淘汰 k/2 个元素
            int newIndex1 = min(index1 + k / 2 - 1, m - 1);
            int newIndex2 = min(index2 + k / 2 - 1, n - 1);
            int pivot1 = nums1[newIndex1];
            int pivot2 = nums2[newIndex2];

            if (pivot1 <= pivot2) {
                // nums1 的前 k/2 个元素被淘汰，更新 k 和 index1
                k -= (newIndex1 - index1 + 1);
                index1 = newIndex1 + 1;
            } else {
                // nums2 的前 k/2 个元素被淘汰，更新 k 和 index2
                k -= (newIndex2 - index2 + 1);
                index2 = newIndex2 + 1;
            }
        }
    }
};
```

- **划分数组法**：是在较短的数组上二分，找一条完美的“切割线”，使得左边刚好有 $k$ 个元素。逻辑比较绕，边界条件多$-\infty$ 和 $+\infty$ 的处理）。
- **找第 k 小（排除法）**：这是**标准的 Top K 问题解法**。每次比较两段 $k/2$ 的前缀，谁的前缀最大值更小，谁的前缀就全军覆没。不需要考虑奇数偶数。

## 74. 搜索二维矩阵

简单的二分，当然也可以把二维当作一维来访问

```cpp
bool searchMatrix(vector<vector<int>>& matrix, int target) {
    int m = matrix.size(), n = matrix[0].size(); 

    int l = 0, r = m - 1;
    int row = -1;
    while(l <= r){
        row = l + (r - l) / 2;
        if(matrix[row][0] > target) r = row - 1;
        else if(matrix[row][n - 1] < target) l = row + 1;
        else break;
    }
    
    if(l == m || r == -1) return false;

    l = 0, r = n - 1;
    while(l <= r){
        int mid = l + (r - l) / 2;
        if(matrix[row][mid] > target) r = mid - 1;
        else if(matrix[row][mid] < target) l = mid + 1;
        else return true;
    }
    return false;
}
```

```cpp
bool searchMatrix(vector<vector<int>>& matrix, int target) {
    int m = matrix.size(), n = matrix[0].size();
    int left = 0, right = m * n - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        // 核心：一维下标转二维坐标
        int mid_val = matrix[mid / n][mid % n];
        
        if (mid_val == target) return true;
        else if (mid_val < target) left = mid + 1;
        else right = mid - 1;
    }
    return false;
}
```

## 981. 基于时间的键值储存

哈希加二分查找，直接上代码

```cpp
class TimeMap {
private:
    unordered_map<string, vector<pair<int, string>>> data;
public:
    TimeMap() { }

    void set(string key, string value, int timestamp) {
        pair<int, string> d = {timestamp, value};
        data[key].emplace_back(std::move(d));
    }
    
    string get(string key, int timestamp) {
        if(!data.count(key)) return "";

        const vector<pair<int, string>>& s = data[key];

        int l = -1, r = static_cast<int>(s.size());
        timestamp += 1;
        while((l + 1) < r){
            int mid = l + (r - l) / 2;
            (s[mid].first < timestamp ? l : r) = mid;
        }
        if(r == 0) return "";
        else return s[r - 1].second;
    }
};
```

## 1011. 在 D 天内送达包裹的能力

二分答案，上代码

```cpp
class Solution {
public:
    int shipWithinDays(vector<int>& weights, int days) {
        int l = 0, r = std::accumulate(weights.begin(), weights.end(), 0);
        while((l + 1) < r){
            int mid = l + (r - l) / 2;
            (check(weights, days, mid) ? r : l) = mid;
        }
        return r;
    }
private: 
    bool check(vector<int>& weights, int days, int speed){
        int used = 0;
        for(int w: weights){
            used += w;
            if(used > speed){
                days--;
                used = w;
            }
            if(days == 0 || used > speed) return false;
        }
        return true;
    }
};
```

## 34. 在排序数组中查找元素的第一个和最后一个位置

经典的`lower_bound`写法

```cpp
class Solution {
public:
    vector<int> searchRange(vector<int>& nums, int target) {
        int n = nums.size();
        int first = lower_bound(nums, target, n);        

        if(first == n || nums[first] != target) return {-1, -1};

        int second = lower_bound(nums, target + 1, n) - 1;        
        return {first, second};
    }
private:
    int lower_bound(vector<int>& nums, int target, int n){
        int l = -1, r = n;
        while((l + 1) < r){
            int mid = l + (r - l) / 2;
            (nums[mid] < target ? l : r) = mid;
        }
        return r;
    }
};
```

## 162. 寻找峰值

二分查找，答案有三种可能：在最左边，在最右边，在中间

在中间的时候以`mid`为中心的三个数有三种情况

- 是一个递增序列
- 是一个递减序列
- `mid`是谷值，`nums[mid - 1] > nums[mid]` && `nums[mid] < nums[mid + 1]`

值得注意的在中间的时候要注意 `mid == 0`, 这时候会越界，但是`index = 1`这时候一定就是峰值，直接返回

````cpp
int findPeakElement(vector<int>& nums) {
    int n = static_cast<int>(nums.size());  
    if(n == 1) return 0;
    if(n == 2) return nums[0] > nums[1] ? 0 : 1;

    if(nums[0] > nums[1]) return 0;
    if(nums[n - 1] > nums[n - 2]) return n - 1;

    int l = 0, r = n - 1;
    while(l <= r){
        int mid = l + (r - l) / 2;
        if(mid == 0) return 1;
        if(nums[mid - 1] < nums[mid] && nums[mid] > nums[mid + 1]) return mid;
        
        if(nums[mid - 1] < nums[mid] && nums[mid] < nums[mid + 1]) l = mid + 1;
        if(nums[mid - 1] > nums[mid] && nums[mid] > nums[mid + 1]) r = mid - 1;
        if(nums[mid - 1] > nums[mid] && nums[mid] < nums[mid + 1]) l = mid + 1;
    }
    return 0;
}
````

但是这样写不够优雅，在上面的版本可以简化成下面的代码

> 为什么这里要写 mid == 0 的case，而不用写 mid == n - 1 的case？

因为当 `mid` 移动的时候最多只能到`n - 2`，这时候一定不会越界

````cpp
int findPeakElement(vector<int>& nums) {
    int n = static_cast<int>(nums.size());  
    if(n == 1) return 0;

    if(nums[0] > nums[1]) return 0;
    if(nums[n - 1] > nums[n - 2]) return n - 1;

    int l = 0, r = n - 1;
    while(l <= r){
        int mid = l + (r - l) / 2;
        if(mid == 0) return 1;
        if(nums[mid - 1] < nums[mid] && nums[mid] > nums[mid + 1]) return mid;
        
        if(nums[mid - 1] > nums[mid] && nums[mid] > nums[mid + 1]) r = mid - 1;
        else l = mid + 1;
    }
    return 0;
}
````

[灵神题解](https://leetcode.cn/problems/find-peak-element/solutions/1987497/by-endlesscheng-9ass/)，看了灵神题解才明白这道题的本质是判断峰值的走向，受教了
