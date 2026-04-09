---
author: lencelg from Arcadia Bay
title: Structure and Interpretation Computer Programs javascript version
---
[TOC]
# 构造函数的抽象
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

下面是一个简单的思考带来的有用的计算过程替换

我们就可以借助连续求平方的方法，完成一般的乘幂计算了：
$$b^n = (b^{2/n})^2 \text{如果n是偶数}$$

$$b^n = b \times b^{n-1} \text{如果n是奇数}$$
```javascript
function fast_expt(b, n) {
    return n === 0
        ? 1
        : is_even(n)
        ? square(fast_expt(b, n / 2))
        : b * fast_expt(b, n - 1);
}
function is_even(n){
    return n % 2 === 0;
}
```

费马小定理：如果 n 是素数，a 是小于 n 的任意正整数，那么 a 的 n 次方与 a 模 n 同余。

利用费马小定理和fast_expt的思想，可以构造一种$\theta (\log(n))$ 的素数检查
```javascript
function expmod(base, exp, m) {
    return exp === 0
            ? 1
            : is_even(exp)
            ? square(expmod(base, exp / 2, m)) % m
            : (base * expmod(base, exp - 1, m)) % m;
}
function fermat_test(n) {
    function try_it(a) {
        return expmod(a, n, n) === a;
    }
    return try_it(1 + math_floor(math_random() * (n - 1)));
}
function fast_is_prime(n, times) {
    return times === 0
            ? true
            : fermat_test(n)
            ? fast_is_prime(n, times - 1)
            : false;
}
```
费马检查得到的结果则只是可能正确, 可以将其结果看作是一种衡量的概率: 如果数 n 不能通过费马检查，我们可以确信它不是素数。而 n 通过了检查的事实只是一个很强的证据，仍然不能保证 n 为素数。
> 存在一些数 n，它们不是素数但却具有如下性质：对任意的整数 a < n，都有 $a^n$ 与 a 模 n 同余。能骗过费马检查的数称为 Carmichael 数，除了很罕见外，我们对它们知之甚少。

## 高阶函数
从作用上看，函数也是一类抽象，它们描述了一些对数值的复合操作, 于是可以考虑对函数再进行一层抽象，成为**高阶函数**

一些函数的基础思想一样，它们共享了一种公共的基础模式，它们中的很大一部分是相同的，只在所用的函数名上互异, 考虑传入函数来完成抽象的过程

lambda 表达式: (parameters) => expression 

e.g, $x => x + 4$

考虑使用conditional语句进行高效的存储来进行计算， 也使用const进行local variable的声明来明了函数的复合计算过程

## 小结
第一章从计算的基础操作讲起，介绍了递归和迭代的计算的过程和区别，再从函数的抽象与结构化对一些问题探讨计算的思路所在，借助javascript语言，函数的设计贴近人类自然语言的描述，最后是高阶函数的抽象并介绍了condition语句、lambda函数等编程工具来更好的进行函数的抽象，对于问题的思路讲解中，书中的例子函数设计与结构化尤为精彩。

# 构造数据的抽象
除了基本类型，我们考虑对数据本身进行封装成一个新的类型，然后用函数的抽象赋予对应的操作

书中还有一个**Church**计数的例子： ，在一个可以对函数做各种操作的语言里，我们完全可以没有数（至少在只考虑非负整数的情况下），以下面的方式实现 0 和加一操作：

```javascript
const zero = f => x => x;
function add_1(n) {
    return f => x => f(n(f)(x));
}
```

然而在复合数据类型的时候，我们可能要考虑精度问题：
e.g $$\frac{R_1\times R_2}{R_1 + R_2} $$

$$ \frac{1}{1/R_1 + 1/R_2}$$

数据封装以后依旧是同类型的数据，可以进行数据相应的操作， 这成为**闭包**

=> list
```javascript
function list_ref(items, n) {
    return n === 0
            ? head(items)
            : list_ref(tail(items), n - 1);
}
const squares = list(1, 4, 9, 16, 25);
list_ref(squares, 3);
16
```

**对表的映射**

把某个变换应用于一个表里的所有元素，得到由所有结果构成的表

```javascript
function scale_list(items, factor) {
    return is_null(items)
        ? null
        : pair(head(items) * factor,
        scale_list(tail(items), factor));
}
scale_list(list(1, 2, 3, 4, 5), 10);
[10, [20, [30, [40, [50, null]]]]]

-------------------------------------

// 于是map的概念就出现了
function map(fun, items) {
    return is_null(items)
        ? null
        : pair(fun(head(items)),
        map(fun, tail(items)));
}
```