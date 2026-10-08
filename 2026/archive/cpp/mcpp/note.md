---
author: lencelg from Arcadia Bay
title: note of modern cpp
resource: https://changkun.de/modern-cpp/
---

[TOC]

# PS 

this note is not finished and not in consideration, cpp is a bad language.

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

## 非模板类型推导

```cpp
template <typename T, int BufSize>
class buffer_t {
public:
    T& alloc();
    void free(T& item);
private:
    T data[BufSize];
};

buffer_t<int, 100> buf; // 100 作为模板参数
```

## 委托构造

允许一个构造函数把初始化工作「委托」给同一个类中的另一个构造函数

```cpp
class Base {
public:
    int value1;
    int value2;
    Base() {
        value1 = 1;
    }
    Base(int value) : Base() { // 委托 Base() 构造函数
        value2 = value;
    }
};
```

## 继承构造

派生类想要复用基类的构造函数，必须在派生类里逐一重新声明、并把参数一一转发给基类

C++11 利用关键字 `using` 引入了继承构造函数的概念，让派生类可以「一键」继承基类的全部构造函数

```cpp
class Base {
public:
    int value1;
    int value2;
    Base() {
        value1 = 1;
    }
    Base(int value) : Base() { // 委托 Base() 构造函数
        value2 = value;
    }
};
class Subclass : public Base {
public:
    using Base::Base; // 继承构造
};
```

## inline variable
C++17 引入了 `inline` 变量，允许在头文件中定义变量（包括类的静态成员），即便被多个翻译单元包含也不会违反**单一定义规则 (ODR)**


```cpp
struct Widget {
    static inline int count = 0; // C++17：在类内定义并初始化静态成员
};
inline int global_value = 42;    // 可安全地放在头文件中
```

## constexpr lambda

满足常量表达式要求的 Lambda 表达式会隐式地成为 constexpr（也可以显式标注 constexpr

```cpp
constexpr auto add = [](int a, int b) { return a + b; };
static_assert(add(1, 2) == 3, "");

constexpr int result = add(3, 4); // 在编译期求值，result == 7
```

## static_assert

```cpp
static_assert(sizeof(int) >= 2);                       // C++17：消息可省略
static_assert(sizeof(int) >= 2, "int 至少需要 2 字节"); // 仍然可以提供消息
```

## auto&&

auto&& 可以绑定到任意值类别

- 左值引用
- 右值引用

## static_cast

static_cast 比 C 风格的 `(type)value` 更严格、更清晰，并且可在一定程度上避免不安全的行为。

# run time

## lambada
Lambda 表达式对外部值进行使用的功能，捕获列表的最常用的四种形式可以是：

- \[\] 空捕获列表
- \[name1, name2, ...\] 捕获一系列变量
- \[&\] 引用捕获，从函数体内的使用确定引用捕获列表
- \[=\] 值捕获，从函数体内的使用确定值捕获列表

```
int value = 1;

auto copy_value = [value] {
    return value;
};

auto ref_value = [&value] {
        return value;
    };
```

C++14 允许捕获的成员用任意的表达式进行初始化，这就允许了右值的捕获

```cpp
auto important = std::make_unique<int>(1);

auto add = [v1 = 1, v2 = std::move(important)](int x, int y) -> int {
    return x+y+v1+(*v2);
};
```

## std::function

`std::function` 是函数的容器, 能够更加方便的将函数、函数指针作为对象进行处理.

```cpp
int foo(int para) {
    return para;
}

int main() {
    // std::function 包装了一个返回值为 int, 参数为 int 的函数
    std::function<int(int)> func = foo;

    int important = 10;
    std::function<int(int)> func2 = [&](int value) -> int {
        return 1+value+important;
    };
    std::cout << func(10) << std::endl;
    std::cout << func2(10) << std::endl;
}
```

## std::bind and std::placeholder

可以将部分调用参数提前绑定到函数身上成为一个新的对象，然后在参数齐全后，完成调用。

```cpp
int foo(int a, int b, int c) {
    return a + b + c;
}
int main() {
    // 将参数1,2绑定到函数 foo 上，
    // 但使用 std::placeholders::_1 来对第一个参数进行占位
    auto bindFoo = std::bind(foo, std::placeholders::_1, 1, 2);
    // 这时调用 bindFoo 时，只需要提供第一个参数即可
    std::cout << bindFoo(1) << std::endl; // 输出 4
}
```

## rlvaue, xvalue, lvalue

> **右值包括纯右值（临时对象）和将亡值（即将被移动的对象），它们可绑定到右值引用 `T&&`，用于实现移动语义和完美转发，从而避免不必要的拷贝。**

| 概念 | 说明 |
|------|------|
| **纯右值 (prvalue)** | 无地址的临时值：`42`、`a+b`、`func()`（返回非引用）。 |
| **将亡值 (xvalue)** | 有地址但资源可被窃取：`std::move(a)`、返回 `T&&` 的函数调用。 |
| **右值引用 `T&&`** | 绑定到右值，延长临时对象生命周期，用于移动构造/赋值。 |
| **移动语义** | 转移资源所有权，避免深拷贝；通过移动构造函数和 `std::move` 实现。 |
| **完美转发** | 保持参数值类别（左/右），用 `T&&` + `std::forward<T>` 实现。 |

常见误区

- `int&& r = a;` → 右值引用不能直接绑定左值，应写作 `int&& r = std::move(a);`。  
- `void f(T&&)` 只接受右值 → 实际上 `T&&` 在模板中是万能引用，也可接收左值。  
- `const T&&` 有用 → 极少使用，因为无法修改资源，移动退化为拷贝。

### 完美转发

一个声明的右值引用其实是一个左值。这就为我们进行参数转发（传递）造成了问题

| 函数形参类型 | 实参参数类型 | 推导后函数形参类型 |
|------------|------------|------------------|
| `T&`       | 左值        | `T&`            |
| `T&`       | 右值        | `T&`            |
| `T&&`      | 左值        | `T&`            |
| `T&&`      | 右值        | `T&&`           |

`std::forward` 能够没有造成任何多余的拷贝，同时完美转发(传递)了函数的实参给了内部调用的其他函数。

qa: 为什么在使用循环语句的过程中，`auto&&` 是最安全的方式？ 因为当 `auto` 被推导为不同的左右引用时，与 `&&` 的坍缩组合是完美转发。

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

