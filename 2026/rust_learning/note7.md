---
author: lencelg from Arcadia Bay
title: note of some books
---
[TOC]

# Basis
## prelude
标准库中的某些type、trait、function、macro是太常用的。每次都写use语句确实非常无聊

因此标准库提供了一个 `std::prelude` 模块，在这个模块中导出了一些最常见的类型、trait等东西

## format!
```rust
fn main() {
    println!("{}", 1);                          // 默认用法,打印Display
    println!("{:o}", 9);                        // 八进制
    println!("{:x}", 255);                      // 十六进制 小写
    println!("{:X}", 255);                      // 十六进制 大写
    println!("{:p}", &0);                       // 指针
    println!("{:b}", 15);                       // 二进制
    println!("{:e}", 10000f32);                 // 科学计数(小写)
    println!("{:E}", 10000f32);                 // 科学计数(大写)
    println!("{:?}", "test");                   // 打印Debug
    println!("{:#?}", ("test1", "test2"));      // 带换行和缩进的Debug打印
    println!("{a} {b} {b}", a = "x", b = "y");  // 命名参数
}
```

## 指针类型

| 类型名    | 简介                                                                 |
|-----------|----------------------------------------------------------------------|
| `Box<T>`  | 指向类型 T 的、具有所有权的指针，有权释放内存                         |
| `&T`      | 指向类型 T 的借用指针，也称为引用，无权释放内存，无权写数据           |
| `&mut T`  | 指向类型 T 的 mut 型借用指针，无权释放内存，有权写数据                 |
| `*const T`| 指向类型 T 的只读裸指针，没有生命周期信息，无权写数据                 |
| `*mut T`  | 指向类型 T 的可读写裸指针，没有生命周期信息，有权写数据               |

下面是一些智能指针

| 类型名       | 简介                                                                 |
|--------------|----------------------------------------------------------------------|
| `Rc<T>`      | 指向类型 T 的引用计数指针，共享所有权，线程不安全                       |
| `Arc<T>`     | 指向类型 T 的原子型引用计数指针，共享所有权，线程安全                   |
| `Cow<'a, T>` | Clone-on-write，写时复制指针。可能是借用指针，也可能是具有所有权的指针 |

## 赋值表达式
赋值表达式不返回值， rust不支持连续赋值
```rust
let x = 1;
let mut y = 2;
// 注意这里专门用括号括起来了
let z = (y = x);
// z = ()
println!("{:?}", z);
```

## const fn
函数可以在编译阶段被编译器执行，返回值也被视为编译期常量
```rust
#![feature(const_fn)]
const fn cube(num: usize) -> usize {
    num * num * num
}
```

## static method in trait
没有receiver参数的方法（或者第一个参数不是self参数的方法）称作“静态方法”

```rust
struct T(i32);

impl T {
    // 这是一个静态方法
    fn func(this: &Self) {
        println!{"value {}", this.0};
    }
}
fn main() {
    let x = T(42);
    // x.func(); 小数点方式调用是不合法的
    T::func(&x);
}
```

## Derive
Rust提供了一个特殊的attribute: `Derive`，它可以帮我们自动impl某些trait, 当然这只适用于一些简单struct

```rust
#[derive(Copy, Clone, Default, Debug, Hash, PartialEq, Eq, PartialOrd, Ord)]
struct Foo {
    data : i32
}
```

# 并发