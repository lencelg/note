---
author: lencelg from Arcadia Bay
title: learning rust
---
[TOC]
# Introduction
Cargo 是 Rust 的构建系统和包管理器

Cargo.toml 是cargo项目的配置文件

cargo一些用法如下
```
cargo new project
cargo build
cargo run
cargo check
cargo build --release
cargo update
```

一个猜数小游戏，很好的例子
```rust
use std::cmp::Ordering;
use std::io;

use rand::Rng;

fn main() {
    println!("Guess the number!");

    let secret_number = rand::thread_rng().gen_range(1..=100);

    loop {
        println!("Please input your guess.");

        let mut guess = String::new();
        
        // read line into guess
        io::stdin()
            .read_line(&mut guess)
            .expect("Failed to read line");

        // trim方法去除会去掉字符串开头和结尾的空白字符
        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        println!("You guessed: {guess}");

        // cmp method
        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You win!");
                break;
            }
        }
    }
}
```

---

# Some basic concept
* mutablility
* immutablility
* constant: immutable
* shadowing
  
basic type
| Length  | Signed  | Unsigned |
| ------- | ------- | -------- |
| 8-bit   | `i8`    | `u8`     |
| 16-bit  | `i16`   | `u16`    |
| 32-bit  | `i32`   | `u32`    |
| 64-bit  | `i64`   | `u64`    |
| 128-bit | `i128`  | `u128`   |
| Architecture-dependent | `isize` | `usize`  |

关于数制
| Number literals  | Example       |
| ---------------- | ------------- |
| Decimal          | `98_222`      |
| Hex              | `0xff`        |
| Octal            | `0o77`        |
| Binary           | `0b1111_0000` |
| Byte (`u8` only) | `b'A'`        |

--- 

# Expression and Assignment

语句不返回值。因此，不能把 `let` 语句赋值给另一个变量

`let y = 6` 这条语句不会返回值，因此没有什么东西可以绑定到 `x` 上
```rust
fn main() {
    let x = (let y = 6);
}
```

---

# Control Flow
```rust
let condition = true;
let number = if condition { 5 } else { 6 };
```

```rust
fn main() {
    let a = [10, 20, 30, 40, 50];

    // iter through a
    for element in a {
        println!("the value is: {element}");
    }
}
```

`break`, `continue`
# Ownership
所有权规则

1. Rust 中的每一个值都有一个 所有者（owner）。
2. 值在任一时刻有且只有一个所有者。
3. 当所有者离开作用域，这个值将被丢弃。

```rust
let s1 = String::from("hello");
let s2 = s1;
// ownership transfer to s2, s1 not longer avaiable, error!
println!("{s1}, world!");
```
下面是两个书中的说明例子
```rust
fn main() {
    let s = String::from("hello");  // s 进入作用域

    takes_ownership(s);             // s 的值移动到函数里 ...
                                    // ... 所以到这里不再有效

    let x = 5;                      // x 进入作用域

    makes_copy(x);                  // x 应该移动函数里，
                                    // 但 i32 是 Copy 的，
    println!("{}", x);              // 所以在后面可继续使用 x

} // 这里，x 先移出了作用域，然后是 s。但因为 s 的值已被移走，
  // 没有特殊之处

fn takes_ownership(some_string: String) { // some_string 进入作用域
    println!("{some_string}");
} // 这里，some_string 移出作用域并调用 `drop` 方法。
  // 占用的内存被释放

fn makes_copy(some_integer: i32) { // some_integer 进入作用域
    println!("{some_integer}");
} // 这里，some_integer 移出作用域。没有特殊之处
```
```rust
fn main() {
    let s1 = gives_ownership();        // gives_ownership 将它的返回值传递给 s1

    let s2 = String::from("hello");    // s2 进入作用域

    let s3 = takes_and_gives_back(s2); // s2 被传入 takes_and_gives_back, 
                                       // 它的返回值又传递给 s3
} // 此处，s3 移出作用域并被丢弃。s2 被 move，所以无事发生
  // s1 移出作用域并被丢弃

fn gives_ownership() -> String {       // gives_ownership 将会把返回值传入
                                       // 调用它的函数

    let some_string = String::from("yours"); // some_string 进入作用域

    some_string                        // 返回 some_string 并将其移至调用函数
}

// 该函数将传入字符串并返回该值
fn takes_and_gives_back(a_string: String) -> String {
    // a_string 进入作用域

    a_string  // 返回 a_string 并移出给调用的函数
}
```

---

**borrowing**:
我们可以借用别人的东西，cs110L里面有一个借用小熊布偶的例子, 可以带有声明，`mut`代表可以允许改变它

借用有可能存在data race的情形，可以借用并发的竞争来理解
```rust
    let mut s = String::from("hello");

    let r1 = &s; // 没问题
    let r2 = &s; // 没问题
    let r3 = &mut s; // 大问题

    println!("{r1}, {r2}, and {r3}");
```

**slice**:
slice 是一种引用，所以它不拥有所有权。

一个例子如下：
```rust
fn first_word(s: &String) -> usize {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return i;
        }
    }

    s.len()
}
fn main() {
    let mut s = String::from("hello world");

    let word = first_word(&s);

    s.clear(); // 错误！
    // 因为我们清空了s, word不在有效，不能再给借给的人使用!
    println!("the first word is: {word}");
}
```
# Struct
另一种使用 Debug 格式打印数值的方法是使用 `dbg!` 宏。`dbg!` 宏接收一个表达式的所有权（与 `println!` 宏相反，后者接收的是引用）
```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let scale = 2;
    let rect1 = Rectangle {
        width: dbg!(30 * scale),
        height: 50,
    };

    dbg!(&rect1);
}
```

我们可以把 `dbg!` 放在表达式 30 * scale 周围，因为 `dbg!` 返回表达式的值的所有权，所以 `width` 字段将获得相同的值，就像我们在那里没有 `dbg!` 调用一样。我们不希望 `dbg!` 拥有 rect1 的所有权，所以我们在下一次调用 dbg! 时传递一个引用。

每个结构体都允许拥有多个 `impl` 块。
```rust
impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
```
# Enum
枚举变体默认就是公有的

option enum
```rust
enum Option<T> {
    None,
    Some(T),
}
```
```rust
    let x: i8 = 5;
    let y: Option<i8> = Some(5);

    let sum = x + y;
```
if you run it, error comes
```console
$ cargo run
   Compiling enums v0.1.0 (file:///projects/enums)
error[E0277]: cannot add `Option<i8>` to `i8`
 --> src/main.rs:5:17
  |
5 |     let sum = x + y;
  |                 ^ no implementation for `i8 + Option<i8>`
  |
  = help: the trait `Add<Option<i8>>` is not implemented for `i8`
  = help: the following other types implement trait `Add<Rhs>`:
            `&i8` implements `Add<i8>`
            `&i8` implements `Add`
            `i8` implements `Add<&i8>`
            `i8` implements `Add`

For more information about this error, try `rustc --explain E0277`.
error: could not compile `enums` (bin "enums") due to 1 previous error
```
# Pattern Matching
one example usage below
```rust
    fn plus_one(x: Option<i32>) -> Option<i32> {
        match x {
            Some(i) => Some(i + 1),
            _ => None
        }
    }
```
可以使用`if let` 和 `let else` 简洁控制流

看看例子就明白了
```rust
let config_max = Some(3u8);
if let Some(max) = config_max {
    println!("The maximum is configured to be {max}");
}
```

let else
```rust
fn describe_state_quarter(coin: Coin) -> Option<String> {
    if let Coin::Quarter(state) = coin {
        if state.existed_in(1900) {
            Some(format!("{state:?} is pretty old, for America!"))
        } else {
            Some(format!("{state:?} is relatively new."))
        }
    } else {
        None
    }
}
```
# Crate
crate 有两种形式：二进制 crate 和库 crate

rust book中这里创建一个名为`backyard`的二进制 crate 来说明这些规则
```
backyard
├── Cargo.lock
├── Cargo.toml
└── src
    ├── garden
    │   └── vegetables.rs
    ├── garden.rs
    └── main.rs
```
cheat sheet
- **从 crate 根节点开始**: 当编译一个 crate, 编译器首先在 crate 根文件（通常，对于一个库 crate 而言是 *src/lib.rs*，对于一个二进制 crate 而言是 *src/main.rs*）中寻找需要被编译的代码。
- **声明模块**: 在 crate 根文件中，你可以声明一个新模块；比如，用 `mod garden;` 声明了一个叫做 `garden` 的模块。编译器会在下列路径中寻找模块代码：
  - 内联，用大括号替换 `mod garden` 后跟的分号
  - 在文件 *src/garden.rs*
  - 在文件 *src/garden/mod.rs*
- **声明子模块**: 在除了 crate 根节点以外的任何文件中，你可以定义子模块。比如，你可能在 *src/garden.rs* 中声明 `mod vegetables;`。编译器会在以父模块命名的目录中寻找子模块代码：
  - 内联，直接在 `mod vegetables` 后方不是一个分号而是一个大括号
  - 在文件 *src/garden/vegetables.rs*
  - 在文件 *src/garden/vegetables/mod.rs*
- **模块中的代码路径**: 一旦一个模块是你 crate 的一部分，你可以在隐私规则允许的前提下，从同一个 crate 内的任意地方，通过代码路径引用该模块的代码。举例而言，一个 garden vegetables 模块下的 `Asparagus` 类型可以通过 `crate::garden::vegetables::Asparagus` 访问。
- **私有 vs 公用**: 一个模块里的代码默认对其父模块私有。为了使一个模块公用，应当在声明时使用 `pub mod` 替代 `mod`。为了使一个公用模块内部的成员公用，应当在声明前使用`pub`。
- **`use` 关键字**: 在一个作用域内，`use`关键字创建了一个项的快捷方式，用来减少长路径的重复。在任何可以引用 `crate::garden::vegetables::Asparagus` 的作用域，你可以通过 `use crate::garden::vegetables::Asparagus;` 创建一个快捷方式，然后你就可以在作用域中只写 `Asparagus` 来使用该类型。



```rust
use crate::garden::vegetables::Asparagus;

//pub mod garden; 行告诉编译器将 src/garden.rs 中发现的代码包含进来
pub mod garden;

fn main() {
    let plant = Asparagus {};
    println!("I'm growing {plant:?}!");
}
```
mod is private by default

do not forget `pub` keyword, a mod example below
```rust
mod back_of_house {
    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String,
    }

    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("peaches"),
            }
        }
    }
}

pub fn eat_at_restaurant() {
    // 在夏天订购一个黑麦土司作为早餐
    let mut meal = back_of_house::Breakfast::summer("Rye");
    // 改变主意更换想要面包的类型
    meal.toast = String::from("Wheat");
    println!("I'd like {} toast please", meal.toast);

    // 如果取消下一行的注释代码不能编译；
    // 不允许查看或修改早餐附带的季节水果
    // meal.seasonal_fruit = String::from("blueberriejs");
}
```

# collections
## Vector
```rust
    // create vector with Vec::new() or vec!
    let v: Vec<i32> = Vec::new();
    let v = vec![1, 2, 3];

    // update vector with push
    let mut v = Vec::new();
    v.push(8);

    // access to vector with [] or get()
        let v = vec![1, 2, 3, 4, 5];

    let third: &i32 = &v[2];
    println!("The third element is {third}");

    // get() return an Option, could use for error handling for out of bound access
    let third: Option<&i32> = v.get(2);
    match third {
        Some(third) => println!("The third element is {third}"),
        None => println!("There is no third element."),
    }

    // iter an vector
    let v = vec![100, 32, 57];
    for i in &v {
        println!("{i}");
    }
```

## String
```rust
    // create a string with String::new() 
    let mut s = String::new();

    // or
    let data = "initial contents";
    let s = data.to_string();

    // 该方法也可直接用于字符串字面值：
    let s = "initial contents".to_string();
    // same as 
    let s = String::from("initial contents");

    // append string with push_str
    let mut s = String::from("foo");
    s.push_str("bar");

    // notice that Rust 的字符串不支持索引, we use slice
    let hello = "Здравствуйте";
    let s = &hello[0..4];

    // iter a string, print out each char
    for c in "Зд".chars() {
        println!("{c}");
    }

    // iter a string, print out each byte value 
    for b in "Зд".bytes() {
        println!("{b}");
    }

    // other method like contains or replace
```
## Hash Map
```rust
    use std::collections::HashMap;
    
    // create a hashmap
    let mut scores = HashMap::new();

    // insert element
    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);

    // if there is key exist, we do nothing, if not, we insert the key:value pair, return the iterator
    scores.entry(String::from("Blue")).or_insert(50);

    // if we want to update the old value
    use std::collections::HashMap;

    let text = "hello world wonderful world";

    let mut map = HashMap::new();

    for word in text.split_whitespace() {
        let count = map.entry(word).or_insert(0);
        // use * to dereference it
        *count += 1;
    }
```
# Error Handling
rust里面有两大类错误
* 可恢复的（recoverable）错误: `Result<T, E>`
* 不可恢复的（unrecoverable）错误: `panic!`

Result enum
```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```
```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let greeting_file_result = File::open("hello.txt");

    // we can use match to match error type , but a long chunk of code, isn't it?
    let greeting_file = match greeting_file_result {
        Ok(file) => file,
        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => fc,
                Err(e) => panic!("Problem creating the file: {e:?}"),
            },
            _ => {
                panic!("Problem opening the file: {error:?}");
            }
        },
    };
}

use std::fs::File;
use std::io::ErrorKind;

fn main() {
    // we can use unwrap_or_else to shorten our code
    let greeting_file = File::open("hello.txt").unwrap_or_else(|error| {
        if error.kind() == ErrorKind::NotFound {
            File::create("hello.txt").unwrap_or_else(|error| {
                panic!("Problem creating the file: {error:?}");
            })
        } else {
            panic!("Problem opening the file: {error:?}");
        }
    });
}
```

about `unwrap()`, 如果 `Result` 值是变体 `Ok`，`unwrap` 会返回 `Ok` 中的值。如果 `Result` 是变体 `Err`，`unwrap` 会为我们调用 `panic!`
```rust
use std::fs::File;

fn main() {
    let greeting_file = File::open("hello.txt").unwrap();
}
```
`expect` 方法也允许我们自定义 `panic!` 的错误信息, 这样我们就有更好的报错信息
```rust
use std::fs::File;

fn main() {
    let greeting_file = File::open("hello.txt")
        .expect("hello.txt should be included in this project");
}
```
我们可以使用`？`来快捷方式来传播错误, 但是记住只能在返回 `Result`、`Option` 或者其它实现了 `FromResidual` 的类型的函数中使用 `?` 运算符。
```rust
use std::fs::File;
use std::io::{self, Read};

fn read_username_from_file() -> Result<String, io::Error> {
    let mut username = String::new();

    File::open("hello.txt")?.read_to_string(&mut username)?;

    Ok(username)
}

```
关于上面的操作很常见，所以std::fs里面已经实现了, `fs::read_to_string`它会打开文件、新建一个 `String`、读取文件的内容，并将内容放入 `String`，接着返回它
```rust
use std::fs;
use std::io;

fn read_username_from_file() -> Result<String, io::Error> {
    fs::read_to_string("hello.txt")
}
```
# Generic, Trait and lifecycle
## Generic
similar to cpp
```rust
struct Point<X1, Y1> {
    x: X1,
    y: Y1,
}

impl<X1, Y1> Point<X1, Y1> {
    fn mixup<X2, Y2>(self, other: Point<X2, Y2>) -> Point<X1, Y2> {
        Point {
            x: self.x,
            y: other.y,
        }
    }
}

fn main() {
    let p1 = Point { x: 5, y: 10.4 };
    let p2 = Point { x: "Hello", y: 'c' };

    let p3 = p1.mixup(p2);

    println!("p3.x = {}, p3.y = {}", p3.x, p3.y);
}
```
## trait
trait 定义了某个特定类型拥有可能与其他类型共享的功能, 有点像是interface, 不过是可以为特定的对象实现的, 和java不一样

trait 默认实现允许调用相同 trait 中的其他方法，哪怕这些方法没有默认实现
```rust
pub trait Summary {
    fn summarize_author(&self) -> String;

    fn summarize(&self) -> String {
        format!("(Read more from {}...)", self.summarize_author())
    }
}

impl Summary for SocialPost {
    fn summarize_author(&self) -> String {
        format!("@{}", self.username)
    }
}

fm main(){
    let post = SocialPost {
        username: String::from("horse_ebooks"),
        content: String::from(
            "of course, as you probably already know, people",
        ),
        reply: false,
        repost: false,
    };

    println!("1 new post: {}", post.summarize());
}
```