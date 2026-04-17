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
## Builder
直接使用 `thread::spawn` 生成的线程，默认没有名称，并且其栈大小默认为 2MB, 可以考虑使用 `Builder` 来配置生成的线程

```rust
let thread_name = format!("child-{}", id);
let size: usize = 3 * 1024;
let builder = Builder::new().name(thread_name).stack_size(size)
```

`Builder` 的 `spawn` 方法返回的是 `Result<JoinHandle<T>>`, 记得要把内容取出来。

## Thread Local Storage
线程本地存储(TLS)

书中的例子如下， `thread_local`创建一个静态变量作为参数， `thread::LocalKey`(例子中的FOO) 是一个结构体，它提供了一个 `with` 方法，可以通过给该方法传入闭包来操作线程本地存储中包含的变量。
```rust
use std::cell::RefCell;
use std::thread;

fn main() {
    thread_local!(static FOO: RefCell<u32> = RefCell::new(1));

    FOO.with(|f| {
        assert_eq!(*f.borrow(), 1);
        *f.borrow_mut() = 2;
    });

    thread::spawn(|| {
        FOO.with(|f| {
            assert_eq!(*f.borrow(), 1);
            *f.borrow_mut() = 3;
        });
    });

    FOO.with(|f| {
        assert_eq!(*f.borrow(), 2);
    });
}
```

## Send 和 Sync
Send 和 Sync 是两个特殊的 trait
* 实现了 Send 的类型，可以安全地在线程间传递所有权。也就是说，可以跨线程移动。
* 实现了 Sync 的类型，可以安全地在线程间传递不可变借用。也就是说，可以跨线程共享。

## Barrier and Condition Variable 
屏障和条件变量

Barrier 通过 `wait` 方法在某个点阻塞全部进入临界区的线程

```rust
use std::sync::{Arc, Barrier};
use std::thread;

fn main() {
    let mut handles = Vec::with_capacity(5);
    let barrier = Arc::new(Barrier::new(5));

    for _ in 0..5 {
        let c = barrier.clone();
        handles.push(thread::spawn(move || {
            println!("before wait");
            c.wait();
            println!("after wait");
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

输出结果如下

```console
before wait
before wait
before wait
before wait
before wait
after wait
after wait
after wait
after wait
after wait
```

条件变量在满足指定条件之前阻塞某一个得到互斥锁的线程(要和互斥锁一起用), 代码例子就不展示了

## 原子类型
原子类型本身虽然可以保证原子性，但不提供在多线程中共享的方法，需要使用 `Arc<T>` `将其跨线程共享.

# 异步并发
首先是异步编程的概念：

异步编程允许程序在等待某些操作（如 I/O、网络请求、定时器）完成时，**不阻塞** 当前线程，而是去执行其他任务，等到操作完成后再回来继续执行, 由于没有阻塞线程所以是在 **用户态运行时调度**

异步编程通常使用 **协程** 作为底层实现机制

## 协程
首先了解一下协程

**协程**（Coroutine）是一种**更轻量级的并发单元**，它允许一个函数在执行过程中**暂停**（yield），并在之后某个时刻**恢复**（resume）继续执行，同时保留当时的局部状态（栈帧、程序计数器等）。

可以把协程理解为**可暂停和恢复的函数**。线程由操作系统内核管理，而协程通常由程序自身（运行时库）管理，因此切换开销极低。

### 协程的核心特点

- **主动让出控制权**：协程可以在特定点（如 `await`、`yield`）主动暂停，把执行权交还给调度器。
- **保留状态**：暂停时保存局部变量、调用栈等，恢复时能继续执行。
- **用户态调度**：不需要操作系统参与，切换速度很快（微秒级甚至纳秒级）。
- **轻量**：一个线程可以运行成千上万个协程，内存占用小（通常几十到几百字节）。

### 协程和线程

| 维度 | 线程 | 协程 |
|------|------|------|
| 调度方式 | 操作系统内核调度（抢占式） | 用户态调度（协作式或半抢占式） |
| 切换成本 | 较高（系统调用、栈切换） | 极低（函数调用级别） |
| 栈大小 | 固定（通常MB级） | 动态（可小至几十KB，甚至共享栈） |
| 数量限制 | 受系统资源限制（通常几千个） | 可达数十万甚至百万个 |
| 并发模型 | 适合CPU密集型 | 适合I/O密集型或大量任务 |
| 同步原语 | 锁、信号量等 | 通道、消息传递等（通常无需锁） |

# personal view
这本书是2019年出版的，有很多东西都不太适用了，看了一些基础的概念， 后面还有一些第三方并发库的东西，我就没有阅读也没有做笔记, 这本书的参考价值有限，所以就放弃阅读了