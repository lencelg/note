#import "@preview/scholia:0.1.0": *

// options: theme: "light" | "dark" · prose: "notes" | "book" · fonts: (…)
#show: scholia

#cover("effective cpp note", subtitle: "lencelg", author: "lencelg from Arcadia Bay", date: "2026 summer")

#set text(font: "Source Han Sans")
#show raw: set text(font: "Hack Nerd Font")
#outline()

#pagebreak()

#let code(body) = text(fill: blue, body)

= Introduction
简单介绍了几个点
- #code[`std::size_t`]是 C++ 中专门用于表示内存大小和对象长度的无符号整数类型(32位系统通常占 4 字节，64位系统占 8 字节)
- #code[`explicit`]声明的函数的参数是不允许被隐式装换的，在类中鼓励使用该声明
- copy 和 copy assignment 的区别
  - #note([
    ```cpp
class Widget {
public:
    Widget();                            // 默认构造函数
    Widget(const Widget& rhs);           // 拷贝构造函数
    Widget& operator=(const Widget& rhs); // 拷贝赋值操作符
    // ...
};

Widget w1;      // 调用 default 构造函数
Widget w2(w1);  // 调用 copy 构造函数
w1 = w2;        // 调用 copy assignment 操作符
Widget w3 = w1  // 调用 copy 构造函数
```
  ])

= Accustoming to c++

== const, enum, inline
- #note[
````cpp
#define ASPECT_RATIO 1.653 // c way

const double AspectRatio   // should in cpp, 编译器可以看到
````]
- 尽量不要写宏函数
== mutable
- #code[`const`]语义理解，解读规则
  - #code[`mutable`]可以释放 non-static 成员变量的 bitwise constness 约束

```cpp
class CTextField {
public:
    // ...
    std::size_t length() const;
private:
    char* pText;
    mutable std::size_t textLength;    // 这些成员变量可能总是
    mutable bool lengthIsValid;        // 会被更改，即使在
};                                     // const 成员函数内。

std::size_t CTextField::length() const 
// const成员函数不能赋值给 textLength 和 lengthIsValid(带了mutable就可以了)
{
    if (!lengthIsValid) {
        textLength = std::strlen(pText);
        lengthIsValid = true;
    }
    return textLength;
}
```

= constructors, destructors and assignment operators

== initialization
- member initialization list 可以提高效率，因为是初始化，而不是在构造函数里面赋值

== class functions
- 编译器可以暗自为 class 创建 default 构造函数、copy 构造函数、copy assignment 操作符，以及析构函数。
  - 如果不想使用自动生成的就只要写出来函数的签名就好了
  - #note([
    ````cpp
class Uncoyable {
protected:
    // 允许派生类对象构造和析构（但不能直接实例化基类）
    Uncoyable() { }
    ~Uncoyable() { }

private:
    // 将拷贝构造函数和拷贝赋值操作符声明为 private
    // 且不提供实现，从而阻止任何拷贝操作
    Uncoyable(const Uncoyable&);              // 拷贝构造（仅声明）
    Uncoyable& operator=(const Uncoyable&);   // 拷贝赋值（仅声明）
};
````
  ])

为多态基类函数声明#code[`virtual`]析构函数

其他没有什么好记录的
