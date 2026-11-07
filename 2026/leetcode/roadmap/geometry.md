# Math and Geometry

Math and geometry problems test your ability to translate a visual or numerical
pattern into clean algorithmic logic.

Many of these problems have elegant solutions that depend on a single
mathematical observation, such as the structure of matrix rotation or the
periodicity of digit sums.

Unlike the earlier stages, there is no dominant pattern here.
Instead, you are developing the habit of looking for structure in a problem
before reaching for a general algorithm. These problems are a good test of
problem-solving maturity: can you find the insight, or do you default to brute force?

## 48. 旋转图像

first transpose the matrix (swap across the diagonal), then reverse each row.

````cpp
void rotate(vector<vector<int>> &matrix)
{
    int m = matrix.size(), n = matrix[0].size();
    for (int i = 0; i < m; i++)
    {
        for (int j = i + 1; j < n; j++)
        {
            swap(matrix[i][j], matrix[j][i]);
        }
    }
    for (auto &row : matrix)
    {
        reverse(row.begin(), row.end());
    }
}
````

[Solution Page](https://leetcode.cn/problems/rotate-image/solutions)

## 54. 螺旋矩阵

just simulate the process, but be careful about the index, if index reaches the
end, just return ans;

````cpp
vector<int> spiralOrder(vector<vector<int>> &matrix)
{
    int m = matrix.size(), n = matrix[0].size();
    vector<int> ans(m * n);
    int idx = 0;
    int min_one = min(m, n);
    // full cycle
    for (int i = 0; i < min_one / 2 + 1; i++)
    {
        // start point (i, i)
        if (idx == m * n)
            return ans;

        ans[idx++] = matrix[i][i];

        for (int j = i + 1; j < n - i; j++)
        {
            if (idx == m * n)
                return ans;

            ans[idx++] = matrix[i][j];
        }

        // now at (i, n - i - 1)
        for (int j = i + 1; j < m - i; j++)
        {
            if (idx == m * n)
                return ans;

            ans[idx++] = matrix[j][n - i - 1];
        }
        // now at (m - i - 1, n - i - 1)
        for (int j = n - i - 2; j >= i; j--)
        {
            if (idx == m * n)
                return ans;

            ans[idx++] = matrix[m - i - 1][j];
        }
        // now at (m - i - 1, i);
        for (int j = m - i - 2; j > i; j--)
        {
            if (idx == m * n)
                return ans;

            ans[idx++] = matrix[j][i];
        }
    }
    return ans;
}
````

[Solution Page](https://leetcode.cn/problems/spiral-matrix/solutions)

the elegant solution is boundary reducing, below code from deepseek web chat

````cpp
vector<int> spiralOrder(vector<vector<int>>& matrix) {
    if (matrix.empty() || matrix[0].empty()) return {};
    
    int m = matrix.size();
    int n = matrix[0].size();
    vector<int> res;
    res.reserve(m * n); // 提前分配空间，提升性能
    
    int top = 0, bottom = m - 1;
    int left = 0, right = n - 1;
    
    while (top <= bottom && left <= right) {
        // 1. 从左到右遍历上边界
        for (int j = left; j <= right; j++) {
            res.push_back(matrix[top][j]);
        }
        top++; // 上边界下移
        
        // 2. 从上到下遍历右边界
        for (int i = top; i <= bottom; i++) {
            res.push_back(matrix[i][right]);
        }
        right--; // 右边界左移
        
        // 3. 从右到左遍历下边界（必须判断 top <= bottom）
        if (top <= bottom) {
            for (int j = right; j >= left; j--) {
                res.push_back(matrix[bottom][j]);
            }
            bottom--; // 下边界上移
        }
        
        // 4. 从下到上遍历左边界（必须判断 left <= right）
        if (left <= right) {
            for (int i = bottom; i >= top; i--) {
                res.push_back(matrix[i][left]);
            }
            left++; // 左边界右移
        }
    }
    
    return res;
}
````

## 73. 矩阵置零

````cpp
void setZeroes(vector<vector<int>> &matrix)
{
    int m = matrix.size(), n = matrix[0].size();
    vector<bool> row(m, false);
    vector<bool> col(n, false);
    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < n; j++)
        {
            if (!matrix[i][j])
            {
                row[i] = true;
                col[j] = true;
            }
        }
    }

    for (int i = 0; i < m; i++)
    {
        if (row[i])
        {
            for (int j = 0; j < n; j++)
                matrix[i][j] = 0;
        }
    }

    for (int i = 0; i < n; i++)
    {
        if (col[i])
        {
            for (int j = 0; j < m; j++)
                matrix[j][i] = 0;
        }
    }
}
````

[Solution from 灵茶山艾府](https://leetcode.cn/problems/set-matrix-zeroes/solutions/3799648/yi-bu-bu-you-hua-cong-omn-dao-o1-kong-ji-fdgt),
the best solution use $O(1)$ space, the idea is to store infomation in each
row's head adn col's head, but make special opeartion on the first row and first
col

## 202. 快乐数

`1 <= n <= 2 ** 31 - 1`，大的数字会不断变小，多次迭代以后不会超过1000，由于鸽巢原理于是会存在环，检测环有两种简单的写法

- HashMap
- Two pointer: fast pointer and slow pointer

````cpp
int getNextNum(int n)
{
    int ans = 0;
    while (n)
    {
        int d = n % 10;
        ans += d * d;
        n /= 10;
    }
    return ans;
}

bool isHappy(int n)
{
    unordered_set<int> hs;
    while (true)
    {
        if (n == 1)
            return true;
        hs.insert(n);
        n = getNextNum(n);
        if (hs.contains(n))
        {
            break;
        }
        hs.insert(n);
    }
    return false;
}

bool isHappy1(int n){
    if(n == 1)return true;
    int slow = getNextNum(n);
    int fast = getNextNum(getNextNum(n));
    while(slow != 1){
        if(fast == slow) return false;
        slow = getNextNum(slow);
        fast = getNextNum(getNextNum(fast));
    }
    return true;
}
````

[Leetcode cn official solution](https://leetcode.cn/problems/happy-number/solutions/224894/kuai-le-shu-by-leetcode-solution)
the math solution is the most elegant one

## 50. Pow(x, n)

fast exp, just be careful for corner cases

````cpp
double fast_exp(double x, int64_t n)
{
    if (n == 0)
        return 1;

    if (n % 2)
    {
        return x * fast_exp(x, (n - 1));
    }
    else
    {
        double cal = fast_exp(x, n / 2);
        return cal * cal;
    }
}

double myPow(double x, int n)
{
    int64_t p = static_cast<int64_t>(n);
    return n < 0 ? 1 / fast_exp(x, abs(p)) : fast_exp(x, p);
}
````

[Solution from 灵茶山艾府](https://leetcode.cn/problems/powx-n/solutions/2858114/tu-jie-yi-zhang-tu-miao-dong-kuai-su-mi-ykp3i)
the best solution here use while loop instead of $O(log(n))$

## 43. 字符串相乘

假设：

```console
num1 = "123"
num2 = "45"
```

我们创建一个长度为：$m+n$的数组：

```cpp
vector<int> res(m + n, 0);
```

两个长度分别为 `m` 和 `n` 的数字相乘，结果最多有 `m+n` 位。

例如：

```console
123 × 45 = 5535
```

结果数组：

```console
[0, 0, 0, 0, 0]
```

关键公式：

如果 `num1[i]` 和 `num2[j]` 相乘，那么：

- 乘积的个位放在 `res[i + j + 1]`
- 进位放在 `res[i + j]`

也就是：

$pos_1=i+j+1$

$pos_2=i+j$

两个数字的竖式：

```console
        1 2 3
          4 5
```

从右向左计算：

- `3 × 5`，结果在个位。 - `2 × 5`，结果在十位。 - `1 × 5`，结果在百位。 - `3 × 4`，结果在十位。
- `2 × 4`，结果在百位。
- `1 × 4`，结果在千位。

所以对于 `num1[i] * num2[j]`，它在结果中的位置就是 `i+j+1`，可能产生的进位在前一位 `i+j`。

````cpp
string multiply(string num1, string num2) {
    if (num1 == "0" || num2 == "0") {
        return "0";
    }

    int m = num1.size();
    int n = num2.size();

    vector<int> res(m + n, 0);

    for (int i = m - 1; i >= 0; i--) {
        for (int j = n - 1; j >= 0; j--) {
            int a = num1[i] - '0';
            int b = num2[j] - '0';

            int sum = a * b + res[i + j + 1];

            res[i + j + 1] = sum % 10;
            res[i + j] += sum / 10;
        }
    }

    string ans;

    for (int x : res) {
        if (ans.empty() && x == 0) {
            continue;
        }

        ans += (x + '0');
    }

    return ans;
}
````

## 2013. 检测正方形

````cpp
int cnt[1001][1001] = {};

DetectSquares() {}

void add(vector<int> point) {
    int x = point[0];
    int y = point[1];

    cnt[x][y]++;
}

int count(vector<int> point) {
    int x1 = point[0];
    int y1 = point[1];

    int ans = 0;

    // 枚举与查询点处于同一水平线的点
    for (int x2 = 0; x2 <= 1000; x2++) {
        if (x2 == x1 || cnt[x2][y1] == 0) {
            continue;
        }

        int d = abs(x2 - x1);

        // 正方形在上方
        if (y1 + d <= 1000) {
            ans += cnt[x2][y1] * cnt[x1][y1 + d] * cnt[x2][y1 + d];
        }

        // 正方形在下方
        if (y1 - d >= 0) {
            ans += cnt[x2][y1] * cnt[x1][y1 - d] * cnt[x2][y1 - d];
        }
    }

    return ans;
}
````

## 66. 加一

````cpp
vector<int> plusOne(vector<int> &digits)
{
    int carry = 1;
    int n = digits.size();
    vector<int> ans(n);
    for (int i = 0; i < n; i++)
    {
        int cur = digits[n - i - 1];
        if (carry)
        {
            cur += carry;
            carry = cur / 10;
            cur %= 10;
        }
        ans[i] = cur;
    }
    if (carry)
        ans.push_back(1);

    ranges::reverse(ans);
    return ans;
}
````

[Solution from 灵茶山艾府](https://leetcode.cn/problems/plus-one/solutions/3784551/jian-dan-ti-jian-dan-zuo-pythonjavaccgoj-6gb2)，思路简洁，代码优雅，受教了

## 204. 计数素数

判断素数有几个版本

- 暴力
- 判断`1`到`sqrt(n)`
- 判断`1`到`sqrt(n)`，但是跳过`2`的倍数和`3`的倍数
- 基于6的求模算法
- Sieve of Eratosthenes（埃拉托斯特尼筛法）

````cpp
// Sieve of Eratosthenes（埃拉托斯特尼筛法）

vector<bool> sieve(int n) {
    vector<bool> isPrime(n + 1, true);

    isPrime[0] = isPrime[1] = false;

    for (int i = 2; i <= n / i; i++) {
        if (isPrime[i]) {
            for (int j = i * i; j <= n; j += i) {
                isPrime[j] = false;
            }
        }
    }

    return isPrime;
}

// 基于6的求模算法
bool isPrime(int n)
{
    if (n < 2)
        return false;

    if (n == 2 || n == 3)
        return true;

    if (n % 2 == 0 || n % 3 == 0)
    {
        return false;
    }

    for (int i = 5; i <= n / i; i += 6)
    {
        if (n % i == 0 || n % (i + 2) == 0)
        {
            return false;
        }
    }

    return true;
}
````

## 171. Excel 表列序号

本质数制，每27进1

````cpp
int titleToNumber(string columnTitle)
{
    int ans = 0;
    // or use long instead of int for variable mul
    int mul = 1;
    for (int i = columnTitle.size() - 1; i >= 0; i--)
    {
        ans += mul * (columnTitle[i] - 'A' + 1);
        // if use long, the line below can be deleted
        if(i == 0) break;
        mul *= 26;
    }
    return ans;
}
````

下面的解法来自官解评论区的[钰娘娘丿-曱-乀](https://leetcode.cn/u/yu-niang-niang/)，从前往后代码更简洁优雅

````cpp
public int titleToNumber(String columnTitle) {
    int n = columnTitle.length();
    int ans = 0;
    for(int i = 0; i < n; i++){
        ans = ans*26+(columnTitle.charAt(i)-'A'+1);
    }
    return ans;
}
````
