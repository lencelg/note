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
```

mut 和没有 mut 版本的原因都一样
1. 闭包 || 默认会借用（不可变借用, 也就是 `Fn` ）外部变量 `my_string`
2. 线程的闭包可能会在 `my_string` 被销毁之后才执行, 编译器不依赖运行时顺序进行安全检查(编译器严格了一些)
3. 这会导致潜在的 **悬垂引用**

于是我们要么转移所有权（ `move` ），要么使用 `Arc` 等能延长生命周期的智能指针。

# closures
前面其实已经介绍了一部分闭包了， 教程中的这一部分介绍的是在 `struct` 加入闭包来进行，主要可以内置了特定的捕获方法可以更方便的与结构体使用, 教程里面的例子太长，我就不加入进来了，不过应该是rust by example里面的代码

[这里给出链接](https://kumakichi.github.io/easy_rust_chs/Chapter_47.html)

# Arc
`Arc` 的意思是 "atomic reference counter"(原子引用计数器), 每次只写一次数据, 用于多线程访问改写同一个变量

用一个 `Mutex` 把数据包起来，然后用一个 `Arc` 把 `Mutex` 包起来。

下面是一个例子

```rust
use std::sync::{Arc, Mutex};

fn main() {
    let my_number = Arc::new(Mutex::new(0));

    let my_number1 = Arc::clone(&my_number);
    let my_number2 = Arc::clone(&my_number);

    let thread1 = std::thread::spawn(move || { // Only the clone goes into Thread 1
        for _ in 0..10 {
            *my_number1.lock().unwrap() +=1; // Lock the Mutex, change the value
        }
    });

    let thread2 = std::thread::spawn(move || { // Only the clone goes into Thread 2
        for _ in 0..10 {
            *my_number2.lock().unwrap() += 1;
        }
    });

    thread1.join().unwrap();
    thread2.join().unwrap();
    // data 最后变成了20
    println!("Value is: {:?}", my_number);
    println!("Exiting the program");
}
```

# channels
A channel is an easy way to use many threads that send to one place.

用 `std::sync::mpsc` 创建一个channel, `mpsc` 的意思是"多个生产者，单个消费者"

下面是一个例子，任务是将有100万个0的Vec的每个元素增加一， 算是补充的例子

```rust
use std::sync::mpsc::channel;
use std::thread::spawn;

fn main() {
    let (sender, receiver) = channel();
    let hugevec = vec![0; 1_000_000];
    let mut newvec = vec![];
    let mut handle_vec = vec![];

    for i in 0..10 {
        let sender_clone = sender.clone();
        let mut work: Vec<u8> = Vec::with_capacity(hugevec.len() / 10); // new vec to put the work in. 1/10th the size
        work.extend(&hugevec[i*100_000..(i+1)*100_000]); // first part gets 0..100_000, next gets 100_000..200_000, etc.
        let handle =spawn(move || { // make a handle

            for number in work.iter_mut() { // do the actual work
                *number += 1;
            };
            sender_clone.send(work).unwrap(); // use the sender_clone to send the work to the receiver
        });
        handle_vec.push(handle);
    }

    for handle in handle_vec { // stop until the threads are done
        handle.join().unwrap();
    }

    while let Ok(results) = receiver.try_recv() {
        newvec.push(results); // push the results from receiver.recv() into the vec
    }

    // Now we have a Vec<Vec<u8>>. To put it together we can use .flatten()
    let newvec = newvec.into_iter().flatten().collect::<Vec<u8>>(); // Now it's one vec of 1_000_000 u8 numbers

    println!("{:?}, {:?}, total length: {}", // Let's print out some numbers to make sure they are all 1
        &newvec[0..10], &newvec[newvec.len()-10..newvec.len()], newvec.len() // And show that the length is 1_000_000 items
    );

    for number in newvec { // And let's tell Rust that it can panic if even one number is not 1
        if number != 1 {
            panic!();
        }
    }
}
```

# 属性
`#[derive(Debug)]` 这样的类型的代码叫做属性, 属性是给编译器提供信息的小段代码

常见属性如下，意思也很明了
* `#[allow(dead_code)]`
* `#[allow(unused_variables)]`
* `#[warn(unused_variables)]`

其他的就不多说了

# use Box to contain a Trait
在经典场景下我们可以使用Box来包括error， 可以使用 `dyn` 关键词来捕获error而不用指定

notice: 当在结构体使用时，还要impl Error trait

```rust
fn returns_errors(input: u8) -> Result<String, Box<dyn Error>> { // With Box<dyn Error> you can return anything that has the Error trait

    match input {
        0 => Err(Box::new(ErrorOne)), // Don't forget to put it in a box
        1 => Err(Box::new(ErrorTwo)),
        _ => Ok("Looks fine to me".to_string()), // This is the success type
    }

}
```

# 默认值和建造者模式
这个很好理解，`Default` trait 可以初始化一个值

`new` trait 可以提供参数来进行初始化，感觉大部分场景下new trait的使用场景更广一些， Default trait应该用的少一些。

# Deref and DerefMut
`Deref` 是用 `*` 来解引用某些东西的trait, DerefMut 就是可以改变值的解引用的trait

理解和实现也是不难，例子如下, 两个trait的实现代码看起来几乎是一样的。在实现 `DerefMut` 之前，需要先实现 `Deref`

```rust
use std::ops::{Deref, DerefMut};

struct HoldsANumber(u8);

impl HoldsANumber {
    fn prints_the_number_times_two(&self) {
        println!("{}", self.0 * 2);
    }
}

impl Deref for HoldsANumber {
    type Target = u8;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl DerefMut for HoldsANumber { // You don't need type Target = u8; here because it already knows thanks to Deref
    fn deref_mut(&mut self) -> &mut Self::Target { // Everything else is the same except it says mut everywhere
        &mut self.0
    }
}

fn main() {
    let mut my_number = HoldsANumber(20);
    *my_number = 30; // DerefMut lets us do this
    println!("{:?}", my_number.checked_sub(100));
    my_number.prints_the_number_times_two();
}
```

# macro
编写宏是非常复杂的

宏实际上不会编译任何东西。它只是接受一个输入并给出一个输出, 然后编译器会检查它是否有意义, 这就是为什么宏就像 "写代码的代码"。

写一个宏我们要使用另外一个宏: `macro_rules!`

一个简单的宏如下

```rust
macro_rules! give_six {
    () => {
        6
    };
}

fn main() {
    let six = give_six!();
    println!("{}", six);
}
```

宏可以接受输入

```rust
macro_rules! might_print {
    ($input:expr) => {
        println!("You gave me: {}", $input);
    }
}

fn main() {
    // 结果就是打印了上面的println! 语句的内容
    might_print!(6);
}
```

# personal view
easy rust的教程偏向基础的教学，但是中文版的教程是2021年版本的，有一些东西已经不适用了，但也只是极少数，大部分的讲解还是很不错的