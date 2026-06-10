---
author: lencelg from Arcadia Bay
title: note of modern cpp
resource: https://changkun.de/modern-cpp/
---

[TOC]

# Introduction

## nullptr

在 C 中，有些标准库会把 `NULL` 定义为 `((void*)0)` 而有些将它定义为 `0`

C++ 不允许直接将 `void *` 隐式转换到其他类型, 于是C++ 只好将 `NULL` 定义为 `0`

problem: 重载特性发生混乱

```cpp
void foo(char*);
void foo(int);
```

于是`foo(NULL);` 这个语句的行为将取决于 `NULL` 的具体实现

## constexpr

编译器能够在编译时就把常量表达式直接优化并植入到程序运行时，将能增加程序的性能。

```cpp
constexpr int fibonacci(const int n) {
    return n == 1 || n == 2 ? 1 : fibonacci(n-1) + fibonacci(n-2);
}
```

## if/switch 变量声明强化

```cpp
// 将临时变量放到 if 语句内
if (const std::vector<int>::iterator itr = std::find(vec.begin(), vec.end(), 3);
    itr != vec.end()) {
    *itr = 4;
}
```

## std::initializer_list

允许构造函数或其他函数像参数一样使用初始化列表，这就为类对象的初始化与普通数组和 POD(Plain Of Data，即没有构造、析构和虚函数的类或结构体) 的初始化方法提供了统一的桥梁

```cpp
class MagicFoo {
public:
    std::vector<int> vec;
    MagicFoo(std::initializer_list<int> list) {
        for (std::initializer_list<int>::iterator it = list.begin();
             it != list.end(); ++it)
            vec.push_back(*it);
    }
};
int main() {
    // after C++11
    MagicFoo magicFoo = {1, 2, 3, 4, 5};

    std::cout << "magicFoo: ";
    for (std::vector<int>::iterator it = magicFoo.vec.begin(); 
        it != magicFoo.vec.end(); ++it) 
        std::cout << *it << std::endl;
}
```
## structured bindings

```cpp
std::map<std::string, int> scores{{"alice", 90}, {"bob", 80}};
for (const auto& [name, score] : scores) {
    std::cout << name << ": " << score << '\n';
}
```

## auto, decltype

auto 关键字只能对变量进行类型推导出现的

decltype 能够推导计算式

decltype(auto) 主要用于对转发函数或封装的返回类型进行推导

```cpp
std::string  lookup1();
std::string& lookup2();

// c11
std::string look_up_a_string_1() {
    return lookup1();
}
std::string& look_up_a_string_2() {
    return lookup2();
}

// with decltype(auto)
decltype(auto) look_up_a_string_1() {
    return lookup1();
}
decltype(auto) look_up_a_string_2() {
    return lookup2();
}
```

> PS: class and typename, 在模板中定义有**嵌套依赖类型**的变量时，需要用 typename 消除歧义

## if constexpr

将 `constexpr` 这个关键字引入到 if 语句中，允许在代码中声明常量表达式的判断条件

```cpp
template<typename T>
auto print_type_info(const T& t) {
    if constexpr (std::is_integral<T>::value) {
        return t + 1;
    } else {
        return t + 0.001;
    }
}
```

## using
`typedef` 可以为类型定义一个新的名称，但是却没有办法为模板定义一个新的名称。

```cpp
template<typename T, typename U>
class MagicType {
public:
    T dark;
    U magic;
};

// 不合法
template<typename T>
typedef MagicType<std::vector<T>, std::string> FakeDarkMagic;
```

`using` 可以

```cpp
typedef int (*process)(void *);
using NewProcess = int(*)(void *);
template<typename T>
using TrueDarkMagic = MagicType<std::vector<T>, std::string>;
```



# other
`std::string::nops`  is a constant that holds the largest possible value of size_t type (18446744073709551615 on 64-bit systems), so it's value is just -1.

`std::cmp_greater_equal()` 可以用来安全的比较符号数和无符号数

types like `unsigned char/short` are first promoted to int before any arithmetic operation is performed. This is a standard behavior defined in the C language specification.

各平台对于基本类型的大小支持不太一样，使用`<cstdin>`中的类型来写general code

`NULL` is defined as `((void *)0)` 

`Attribute` : 指定一些属性
- \[\[nodiscard\]\]
- \[\[nodiscard("reason")\]\]
- \[\[noreturn\]\]
- \[\[maybe_unused\]\]
- \[\[deprecated\]\]
- \[\[deprecated("reason")\]\]
