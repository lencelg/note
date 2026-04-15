---
author: lencelg from Arcadia Bay
title: learning rust part2 of RB
---
[TOC]
# writing tests
## how
```rust
pub fn add(left: u64, right: u64) -> u64 {
    left + right
}

// 标准方式
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
```
`cargo test` 命令会运行项目中所有的测试

`assert!` 在希望确保测试中一些条件为 true 时非常有用。

`assert_ne!` 和 `assert_eq!` 相反

可以使用 `should_panic` 检查 `panic`
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[should_panic]
    fn greater_than_100() {
        Guess::new(200);
    }
}
```

在测试中也可以使用 Result<T, E>

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() -> Result<(), String> {
        let result = add(2, 2);

        if result == 4 {
            Ok(())
        } else {
            Err(String::from("two plus two does not equal four"))
        }
    }
}
```

## 集成测试
```console
adder
├── Cargo.lock
├── Cargo.toml
├── src
│   └── lib.rs
└── tests
    └── integration_test.rs
```

`tests` 文件夹在 Cargo 中是一个特殊的文件夹，Cargo 只会在运行 `cargo test` 时编译这个目录中的文件, 并不需要将其中的任何代码标注为 `#[cfg(test)]`

# build a cli programme
## read the args
vector 的第一个值是我们二进制文件的名称。这与 C 中的参数列表的行为相匹配
```rust
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    dbg!(args);
}
```
## read a file
use `fs::read_to_string`
```rust
use std::env;
use std::fs;

fn main() {
    // --snip--
    println!("In file {file_path}");

    let contents = fs::read_to_string(file_path)
        .expect("Should have been able to read the file");

    println!("With text:\n{contents}");
}
```
# closure
语法如下
```rust
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```
## capture reference or move ownership

use `move()` keyword to move ownership

```rust
use std::thread;

fn main() {
    let list = vec![1, 2, 3];
    println!("Before defining closure: {list:?}");

    thread::spawn(move || println!("From thread: {list:?}"))
        .join()
        .unwrap();
}
```

## 将捕获的值移出闭包
相关的trait
* `FnOnce` 适用于只能被调用一次的闭包。所有闭包至少都实现了这个 trait，因为所有闭包都能被调用。一个会将捕获的值从闭包体中移出的闭包只会实现 `FnOnce` trait，而不会实现其他 `Fn` 相关的 trait，因为它只能被调用一次。
* `FnMut` 适用于不会将捕获的值移出闭包体，但可能会修改捕获值的闭包。这类闭包可以被调用多次。
* `Fn` 适用于既不将捕获的值移出闭包体，也不修改捕获值的闭包，同时也包括不从环境中捕获任何值的闭包。这类闭包可以被多次调用而不会改变其环境，这在会多次并发调用闭包的场景中十分重要。

```rust
impl<T> Option<T> {
    pub fn unwrap_or_else<F>(self, f: F) -> T
    where
        F: FnOnce() -> T
    {
        match self {
            Some(x) => x,
            None => f(),
        }
    }
}
```

下面是一个`sort_by_key`的例子

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let mut list = [
        Rectangle { width: 10, height: 1 },
        Rectangle { width: 3, height: 5 },
        Rectangle { width: 7, height: 12 },
    ];

    list.sort_by_key(|r| r.width);
    println!("{list:#?}");
}
```
output as follow

```console
$ cargo run
   Compiling rectangles v0.1.0 (file:///projects/rectangles)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.41s
     Running `target/debug/rectangles`
[
    Rectangle {
        width: 3,
        height: 5,
    },
    Rectangle {
        width: 7,
        height: 12,
    },
    Rectangle {
        width: 10,
        height: 1,
    },
]
```

# Iterator
```rust
    #[test]
    fn iterator_sum() {
        let v1 = vec![1, 2, 3];

        // get the iter
        let v1_iter = v1.iter();

        // built-in sum() method to use the iter
        let total: i32 = v1_iter.sum();

        assert_eq!(total, 6);
    }
```

another example below to use iter with closures

```rust
    let v1: Vec<i32> = vec![1, 2, 3];

    // use map with iter
    let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();

    assert_eq!(v2, vec![2, 3, 4]);
```

# smart pointer
- `Box<T>`，用于在堆上分配值
- `Rc<T>`，一个引用计数类型，其数据可以有多个所有者
- `Ref<T>` 和 `RefMut<T>`，它们是通过 `RefCell<T>` 访问的。而 `RefCell<T>` 是一个在运行时而非编译时执行借用规则的类型。

# Box<T>

example is enough

```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let list = Cons(1, Box::new(Cons(2, Box::new(Cons(3, Box::new(Nil))))));
}
```

实现 `Deref` trait 来提供\* 运算

```rust
use std::ops::Deref;

// impl detail
impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}

fn main() {
    let x = 5;
    let y = MyBox::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

Rust 在发现类型和 trait 实现满足三种情况时会进行 Deref 强制转换：

1. 当 `T: Deref<Target=U>` 时从 `&T` 到 `&U`。
2. 当 `T: DerefMut<Target=U>` 时从 `&mut T` 到 `&mut U`。
3. 当 `T: Deref<Target=U>` 时从 `&mut T` 到 `&U`。

我们创建了数据就要考虑清理它， 实现`Drop` trait 可以让 rust 帮我们清理数据

```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Dropping CustomSmartPointer with data `{}`!", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer {
        data: String::from("my stuff"),
    };
    let d = CustomSmartPointer {
        data: String::from("other stuff"),
    };
    println!("CustomSmartPointers created");
}
```

我们不能显示的调用 `data.drop()`, 因为rust会自动在生命周期结束的时候调用它

如果我们需要强制提早清理值，可以使用 `std::mem::drop` 函数, e.g `drop(data)`

## Rc<T>
Rc<T> 是一种计数的智能指针，能够共享

```rust
enum List {
    Cons(i32, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;

fn main() {
    let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
    println!("count after creating a = {}", Rc::strong_count(&a));
    let b = Cons(3, Rc::clone(&a));
    println!("count after creating b = {}", Rc::strong_count(&a));
    {
        let c = Cons(4, Rc::clone(&a));
        println!("count after creating c = {}", Rc::strong_count(&a));
    }
    println!("count after c goes out of scope = {}", Rc::strong_count(&a));
}
```

output as follow

```console
$ cargo run
   Compiling cons-list v0.1.0 (file:///projects/cons-list)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.45s
     Running `target/debug/cons-list`
count after creating a = 1
count after creating b = 2
count after creating c = 3
count after c goes out of scope = 2
```

## RefCell<T>
类似于 `Rc<T>`, `RefCell<T>` 只能用于单线程场景, `RefCell` 将借用检查从 **编译时** 推迟到了 **运行时**, `RefCell` 允许在只有不可变引用的情况下，修改内部的值。

通常与`Rc`一起使用

```rust
use std::rc::Rc;
use std::cell::RefCell;

#[derive(Debug)]
struct Node {
    value: i32,
    next: Option<Rc<RefCell<Node>>>,
}

fn main() {
    let node1 = Rc::new(RefCell::new(Node { value: 1, next: None }));
    let node2 = Rc::new(RefCell::new(Node { value: 2, next: Some(node1.clone()) }));

    // 通过 node2 修改 node1 的值
    if let Some(next) = &node2.borrow().next {
        next.borrow_mut().value = 100;
    }
    println!("{:?}", node1.borrow()); // Node { value: 100, next: None }
}
```
