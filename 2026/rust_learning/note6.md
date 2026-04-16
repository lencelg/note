---
author: lencelg from Arcadia Bay
title: note of easy rust 
---
[TOC]

# about .inspect
`.inspect` 与 `dbg!` 有点类似

看以下的例子就可以明白

```rust
fn main() {
    let new_vec = vec![8, 9, 10];

    let double_vec = new_vec
        .iter()
        .inspect(|first_item| println!("The item is: {}", first_item))
        .map(|x| x * 2)
        .inspect(|next_item| println!("Then it is: {}", next_item))
        .collect::<Vec<i32>>();
}
```

output as follow

```console
The item is: 8
Then it is: 16
The item is: 9
Then it is: 18
The item is: 10
Then it is: 20
```

# about Interior mutability

## Cell
cell usage as below
```rust
use std::cell::Cell;

let s = Cell::new(data);
s.set(newdata);
```
## RefCell
`RefCell` 是另一种无需声明 `mut` 而改变值的方法, 使用引用而不是副本.

## Mutex
Mutex是另一种改变数值的方法，不需要声明 `mut`, 一次只能改一个
```rust
let my_mutex = Mutex::new(5);

// use lock().unwrap() to get the data
let mut mutex_changer = my_mutex.lock().unwrap();

// 我们拿到数据可以改变它
*mutex_changer = 6;

// now it output 6
println!("{:?}", mutex_changer); 
```

当拿到锁的变量超出范围就会自动归还锁， 也可以使用 `std::mem:drop(variable_owned_lock)` 来归还锁

```rust
std::mem::drop(mutex_changer);
```

另外一个方法是 `try_lock()`, 它尝试获得锁， 返回一个 `Result`

```rust
let mut other_mutex_changer = my_mutex.try_lock(); // try to get the lock

if let Ok(value) = other_mutex_changer {
    println!("The MutexGuard has: {}", value)
} else {
    println!("Didn't get the lock")
}
```

## RwLock
`RwLock` 的意思是 "读写锁"

规则:
* 很多 `.read()` 变量可以
* 一个 `.write()` 变量可以
* 但多个 `.write()` 或 `.read()` 与 `.write()` 一起是不行的

下面是一个很好的例子

```rust
use std::sync::RwLock;
use std::mem::drop; // We will use drop() many times

fn main() {
    let my_rwlock = RwLock::new(5);

    let read1 = my_rwlock.read().unwrap(); // 一个读者
    let read2 = my_rwlock.read().unwrap(); // 两个读者

    println!("{:?}, {:?}", read1, read2);

    drop(read1);
    drop(read2); // 两个读者都drop了， 可以执行write

    let mut write1 = my_rwlock.write().unwrap();
    *write1 = 6;
    drop(write1);

    println!("{:?}", my_rwlock);
}
```

# Cow
Clone on Write, 写时克隆

It allows functions to return borrowed data when possible without allocation, while automatically cloning the data only when mutation or ownership is required.

Cow 的签名如下: 相关的trait是 `ToOwned` ， 因为我们需要判断是借用还是需要 ownership 后进行复制两种情况, `?Sized` 是因为像是 `str` 之类的类型没有Sized, 这意味着"也许是Sized，但也许不是".

```rust
pub enum Cow<'a, B>
where
    B: 'a + ToOwned + ?Sized,
 {
    Borrowed(&'a B),
    Owned(<B as ToOwned>::Owned),
}

fn main() {}
```

下面是一个实战例子

```rust
use std::borrow::Cow;

fn modulo_3(input: u8) -> Cow<'static, str> {
    match input % 3 {
        0 => "Remainder is 0".into(),
        1 => "Remainder is 1".into(),
        remainder => format!("Remainder is {}", remainder).into(),
    }
}

fn main() {
    for number in 1..=6 {
        match modulo_3(number) {
            Cow::Borrowed(message) => println!("{} went in. The Cow is borrowed with this message: {}", number, message),
            Cow::Owned(message) => println!("{} went in. The Cow is owned with this message: {}", number, message),
        }
    }
}
```

输出如下

```console
1 went in. The Cow is borrowed with this message: Remainder is 1
2 went in. The Cow is owned with this message: Remainder is 2
3 went in. The Cow is borrowed with this message: Remainder is 0
4 went in. The Cow is borrowed with this message: Remainder is 1
5 went in. The Cow is owned with this message: Remainder is 2
6 went in. The Cow is borrowed with this message: Remainder is 0
```

# alias

我们使用 `type` 关键字可以给类型起别名

`type CharacterVec = Vec<char>; `

# todo!
`todo!` 宏允许我们在项目构造蓝图而不引起编译器的 error

# Rc
教程中的例子是我们想要省下一些储存城市信息资源并符合rust的ownership模型, 使用Rc可以让大家共享也没有造成浪费。

Rc 的 `clone()` 和以前的clone含义不太一样, Rc的 `clone()` 创造另外一个Rc, 它们共享了同一份资源

例外一个有用的函数是 `strong_count(&Rc)`, 它可以让我们查看引用的次数

最后是强弱指针的介绍，因为如果两个Rc互相指向对方，它们就不会死。这就是所谓的 "引用循环" , 弱指针可以对引用进行计数而不是数据本身的Rc, 可以应对这种情况

`Rc::downgrade(&item)` 来创建弱引用。用 `Rc::weak_count(&item)` 来查看弱引用数

# multithreading
关于多线程教程中较为简略

使用 `std::thread::spawn` 来创建线程

将线程绑定到一个变量上，而不是直接使用，不然执行顺序有问题之类的，对于这个变量有 `join()` 方法可以等待其他线程，下面是一个例子

```rust
fn main() {
    for _ in 0..10 {
        let handle = std::thread::spawn(|| {
            println!("I am printing something");
        });

        handle.join(); // 等待所有线程完成
    }
}
```

和线程相关的还有闭包，于是要介绍一些闭包的概念

三种类型的闭包
- `FnOnce` : 取整个值(一次)
- `FnMut` : 取一个可变引用
- `Fn` : 取一个普通引用

下面三个分别是对于的例子，首先是 `Fn`, 然后是 `FnMut`, `FnOnce`

```rust
// Fn 取了一个普通的引用
fn main() {
    let my_string = String::from("I will go into the closure");
    let my_closure = || println!("{}", my_string);
    my_closure();
    my_closure();
}
```

```rust
// FnMut 拿到了一个可变引用
fn main() {
    let mut my_string = String::from("I will go into the closure");
    let mut my_closure = || {
        my_string.push_str(" now");
        println!("{}", my_string);
    };
    my_closure();
    my_closure();
}
```

```rust
// FnOnce 有点像是一次取一个值，和iter很搭
fn main() {
    let my_vec: Vec<i32> = vec![8, 9, 10];
    let my_closure = || {
        my_vec
            .into_iter() // into_iter takes ownership
            .map(|x| x as u8) // turn it into u8
            .map(|x| x * 2) // multiply by 2
            .collect::<Vec<u8>>() // collect into a Vec
    };
    let new_vec = my_closure();
    println!("{:?}", new_vec);
}
```

回到线程的例子，这是一个很有趣的例子, Rust 要求所有跨线程的数据传递都必须满足 `Send` trait（所有权转移）或使用同步原语（如 `Mutex` 、`Arc` ）

```rust
fn main() {
    let mut my_string = String::from("Can I go inside the thread?"); // remove mut does not work

    let handle = std::thread::spawn(|| {
        println!("{}", my_string);
    });

    handle.join();
}
```

上面的代码引起编译器的错误

```
error[E0373]: closure may outlive the current function, but it borrows `my_string`
````

mut 和没有 mut 版本的原因都一样
1. 闭包 || 默认会借用（不可变借用, 也就是 `Fn` ）外部变量 `my_string`
2. 线程的闭包可能会在 `my_string` 被销毁之后才执行, 编译器不依赖运行时顺序进行安全检查(编译器严格了一些)
3. 这会导致潜在的 **悬垂引用**

于是我们要么转移所有权（ `move` ），要么使用 `Arc` 等能延长生命周期的智能指针。

# closures
前面其实已经介绍了一部分闭包了， 教程中的这一部分介绍的是在 `struct` 加入闭包来进行，主要可以内置了特定的捕获方法可以更方便的与结构体使用, 教程里面的例子太常，我就不加入进来了，不过应该是rust by example里面的代码

[这里给出链接](https://kumakichi.github.io/easy_rust_chs/Chapter_47.html)

# Arc