---
author: lencelg from Arcadia Bay
title: Structure and Interpretation Computer Programs javascript version
---
计算过程：
* 线性: 一些计算的线性实现较难
* 迭代: 实现简单， 计算重复导致效率较低

我们可以使用函数构造抽象的过程来完成复合的运算，而无需理解具体的实现。

换零钱方式的统计
```javascript
// 我们有一些 50 美分、25 美分、10 美分、5 美分和 1 美分的硬币，要把 1 美元换成零钱，一共有多少种不同的方式？
/*
    把总数为 a 的现金换成 n 种硬币的不同方式的数目等于
        现金 a 换成除去第一种硬币之外的所有其他硬币的不同方式数目
    加上现金 a - d 换成所有种类的硬币的不同方式数目，其中 d 是第一种硬币的币值
*/
function count_change(amount) {
    return cc(amount, 5);
}
function cc(amount, kinds_of_coins) {
    return amount === 0
            ? 1
            : amount < 0 || kinds_of_coins === 0
            ? 0
            : cc(amount, kinds_of_coins - 1)
            +
            cc(amount - first_denomination(kinds_of_coins), kinds_of_coins);
}
function first_denomination(kinds_of_coins) {
    return   kinds_of_coins === 1 ? 1
            : kinds_of_coins === 2 ? 5
            : kinds_of_coins === 3 ? 10
            : kinds_of_coins === 4 ? 25
            : kinds_of_coins === 5 ? 50
            : 0;
}
```

一个类似的题目

函 数 f 由 如下规则定义：如果n<3， 那么f(n)=n; 如果n ≥ 3，那么
f(n) = f(n - 1) + 2f(n - 2) + 3f(n - 3)。请写一个 JavaScript 函数，它通过一个递归计算过程
计算 f。再写一个函数，通过迭代计算过程计算 f。
```javascript
function fRecursive(n) {
    if (n < 3) {
        return n;
    }
    return fRecursive(n - 1) + 2 * fRecursive(n - 2) + 3 * fRecursive(n - 3);
}

function fIterative(n) {
    if (n < 3) {
        return n;
    }
    // 分别表示 f(0), f(1), f(2)
    let f0 = 0;
    let f1 = 1;
    let f2 = 2;
    
    for (let i = 3; i <= n; i++) {
        const next = f2 + 2 * f1 + 3 * f0;
        // 更新状态：窗口向前滑动
        f0 = f1;
        f1 = f2;
        f2 = next;
    }
    return f2;
}
```