# Bit Manipulation

Bit manipulation uses the binary representation of integers directly through
bitwise operators:

- AND
- OR
- XOR
- shifts

It is useful for problems involving pairs, uniqueness, flags, or any
situation where you need to extract or toggle individual bits.

XOR is particularly powerful because it is its own inverse: XOR-ing a value
twice cancels out.

The problems here are mostly short, but they require a different way of
thinking about numbers. Once you internalize the basic bit operations,
you will start seeing where they can replace more expensive data structures in
problems across other categories.

## 136. 只出现一次的数字

````cpp
 int singleNumber(vector<int> &nums)
{
    int ans = 0;
    for (int num : nums)
        ans ^= num;
    return ans;
}
````

## 191. 位1的数字

````cpp
int hammingWeight(int n)
{
    int ans = 0;
    while (n)
    {
        if (n % 2)
            ans++;
        n = n >> 1;
    }
    return ans;
}

int hammingWeight(int n)
{
    int ans = 0;
    while (n)
    {
        ans++;
        n &= (n - 1);
    }
    return ans;
}
````

## 338. 比特位计数

1. Removing the lowest set bit: In binary, subtracting `1` from a number flips
all the trailing `0`s to `1`s and flips the rightmost `1` to `0`. Taking the
bitwise AND (`i & (i - 1)`) clears that rightmost `1` while keeping everything
to its left intact.
   - Example (i = 6): 6 is `110`. 6 - 1 = 5 (`101`). `110 & 101 = 100` (4).

2. Building the DP transition: Since `i & (i - 1)` is strictly smaller than `i`
its bit count has already been computed and stored in our dp array.
   - Recurrence Relation: `dp[i] = dp[i & (i - 1)] + 1`
   - Base Case: `dp[0] = 0`

````cpp
vector<int> countBits(int n)
{
    vector<int> ans(n + 1, 0);
    ans[0] = 0;
    for (int i = 1; i <= n; i++)
    {
        ans[i] = ans[i & (i - 1)] + 1;
    }
    return ans;
}
````

## 190. 颠倒二进制位

一个bit一个bit构建

````cpp
int reverseBits(int n)
{
    int ans = 0;
    int cnt = 0;
    while (n)
    {
        ans |= n & 1;
        ans = ans << 1;
        n = n >> 1;
        cnt++;
    }
    ans <<= 31 - cnt;
    return ans;
}
````

[灵神题解](https://leetcode.cn/problems/reverse-bits/solutions/3901287/o1-wei-yun-suan-fen-zhi-yuan-li-jiang-ji-g7c1)，分治确实容易想到，但是我感觉写起来没有头绪...，受教了

## 371. 两整数之和

Binary addition is broken down into two parts:

1. Sum without carry (`a ^ b`): The XOR operator adds bits together and ignores
any carry-over (`1 + 1 = 0`, `1 + 0 = 1`, `0 + 0 = 0`).

2. Carry bits (`(a & b) << 1`): The AND operator finds positions where both bits
are `1` (the only case that generates a carry). Shifting left by `1` moves that
carry to the next higher bit position.

You repeat this process—adding the uncarried sum and the shifted carry—until
there is no carry left (`b == 0`).

````cpp
int getSum(int a, int b)
{
    while (b != 0)
    {
        int carry = (a & b) << 1;
        a = a ^ b;
        b = carry;
    }
    return a;
}
````

## 268. 丢失的数字

重复的数字的变形题

````cpp
int missingNumber(vector<int> &nums)
{
    int ans = 0;
    int n = nums.size();
    for (int i = 0; i < n; i++)
    {
        ans ^= i ^ nums[i];
    }
    return ans ^ n;
}
````

## 7. 整数反转

注意溢出的检测就行了

````cpp
int reverse(int x)
{
    int ans = 0;
    while (x)
    {
        int d = x % 10;
        x /= 10;
        if (d == 0 && ans == 0)
            continue;

        if (INT_MAX / 10 < ans || INT_MIN / 10 > ans)
            return 0;
        ans *= 10;

        if ((d > 0 && INT_MAX - d < ans) || (d < 0 && INT_MIN - d > ans))
            return 0;
        ans += d;
    }
    return ans;
}
````

[官解](https://leetcode.cn/problems/reverse-integer/solutions/755611/zheng-shu-fan-zhuan-by-leetcode-solution-bccn)

看了题解发现`+d`的时候不用判断，因为`0 <= d <= 9`，此时加上一定不会溢出

````cpp
int reverse(int x)
{
    int ans = 0;
    while (x)
    {
        int d = x % 10;
        x /= 10;
        if (d == 0 && ans == 0)
            continue;

        if (INT_MAX / 10 < ans || INT_MIN / 10 > ans)
            return 0;

        ans = ans * 10 + d;
    }
    return ans;
}
````

## 231. 2的幂

````cpp
bool isPowerOfTwo(int n)
{
    return n > 0 && (n & (n - 1)) == 0;
}
````

## 201. 数字范围的按位与

贡献度的角度思考，于是当我们需要通过右移寻找共同的部分即：`left == right`

````cpp
int rangeBitwiseAnd(int left, int right)
{
    int cnt = 0;
    while (left != right)
    {
        left >>= 1;
        right >>= 1;
        cnt++;
    }
    return (left << cnt);
}
````

[题解页](https://leetcode.cn/problems/bitwise-and-of-numbers-range/solutions)

## 137. 只出现一次的数字 II

贡献度思想

````cpp
int singleNumber(vector<int> &nums)
{
    int ans = 0;
    for (int i = 0; i < 32; i++)
    {
        int cnt = 0;
        for (auto num : nums)
        {
            cnt += num >> i & 1;
        }
        cnt %= 3;
        ans |= cnt << i;
    }
    return ans;
}
````

[题解页](https://leetcode.cn/problems/single-number-ii/solutions)，这里的
最优解法是有限状态机，因为只需要追踪`k - 1`个变量，其中`k`是其他字母都出现的次数，题目里面是3
