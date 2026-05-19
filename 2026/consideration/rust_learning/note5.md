---
author: lencelg from Arcadia Bay
title: tour of rust note
---
[TOC]
# about match
```rust
fn main() {
    let x = 42;

    match x {
        0 => {
            println!("found zero");
        }
        // 我们可以匹配多个值
        1 | 2 => {
            println!("found 1 or 2!");
        }
        // 我们可以匹配迭代器
        3..=9 => {
            println!("found a number 3 to 9 inclusively");
        }
        // 我们可以将匹配数值绑定到变量
        matched_num @ 10..=100 => {
            println!("found {} number between 10 to 100!", matched_num);
        }
        // 这是默认匹配，如果没有处理所有情况，则必须存在该匹配
        _ => {
            println!("found something else!");
        }
    }
}
```

# about ?
`do_something_that_might_fail()?` is the same as follow

```rust
match do_something_that_might_fail() {
    Ok(v) => v,
    Err(e) => return Err(e),
}
```

# about * operator
```rust
fn main() {
    let mut foo = 42;
    let f = &mut foo;
    let bar = *f; // 取得所有者值的拷贝
    *f = 13;      // 设置引用所有者的值
    println!("{}", bar);
    println!("{}", foo);
}
```

# about ownership
Rust 对于引用的规则总结：
* Rust 只允许同时存在一个可变引用或者多个不可变引用，不允许可变引用和不可变引用同时存在。
* 一个引用永远也不会比它的所有者存活得更久。

第一条规则避免了数据争用的出现

第二条引用规则避免悬垂指针

# about string
Rust 支持类 C 语言中的常见 **转义字符** ；
* `\n` - 换行符
* `\r` - 回车符（回到本行起始位置）
* `\t` - 水平制表符（即键盘 Tab 键）
* `\\` - 代表单个反斜杠 \
* `\0` - 空字符（null）
* `\'` - 代表单引号 '

Rust 中字符串默认支持分行。

```rust
fn main() {
    let haiku: &'static str = "
        我写下，擦掉，
        再写，再擦，
        然后一朵罂粟花开了。
        - 葛饰北斋";
    println!("{}", haiku);
    
    
    println!("你好 \
    世界"); // 注意11行 世 字前面的空格会被忽略
}
```

输出如下

```console
        我写下，擦掉，
        再写，再擦，
        然后一朵罂粟花开了。
        - 葛饰北斋
你好 世界
```

原始字符串支持写入原始的文本而无需为特殊字符转义, 以 `r#"` 开头，以 `"#` 结尾

```rust
fn main() {
    let a: &'static str = r#"
        <div class="advice">
            原始字符串在一些情景下非常有用。
        </div>
        "#;
    println!("{}", a);
}
```

宏 `include_str!` 可以将本地文件中导入文本到程序中

`let hello_html = include_str!("hello.html");`

`concat` 和 `join` 可以以简洁而有效的方式构建字符串。

```rust
fn main() {
    let helloworld = ["你好", " ", "世界", "！"].concat();
    let abc = ["a", "b", "c"].join(",");
    println!("{}", helloworld);
    println!("{}",abc);
}
```

`format!`将生成的参数化字符串返回

```rust
fn main() {
    let a = 42;
    // return String of 42
    let f = format!("生活诀窍: {}",a);
    println!("{}",f);
}
```

# about OOP
Traits 可以从其他 trait 继承方法。

```rust
struct SeaCreature {
    pub name: String,
    noise: String,
}

impl SeaCreature {
    pub fn get_sound(&self) -> &str {
        &self.noise
    }
}

trait NoiseMaker {
    fn make_noise(&self);
}

trait LoudNoiseMaker: NoiseMaker {
    fn make_alot_of_noise(&self) {
        self.make_noise();
        self.make_noise();
        self.make_noise();
    }
}

impl NoiseMaker for SeaCreature {
    fn make_noise(&self) {
        println!("{}", &self.get_sound());
    }
}

impl LoudNoiseMaker for SeaCreature {}

fn main() {
    let creature = SeaCreature {
        name: String::from("Ferris"),
        noise: String::from("blub"),
    };
    creature.make_alot_of_noise();
}
```

方法的执行有两种方式：
* 静态调度——当实例类型已知时
* 动态调度——当实例类型未知时, 我们在 trait 类型前加上使用`dyn`

```rust
// snip form code block above
fn static_make_noise(creature: &SeaCreature) {
    // 我们知道真实类型
    creature.make_noise();
}

fn dynamic_make_noise(noise_maker: &dyn NoiseMaker) {
    // 我们不知道真实类型
    noise_maker.make_noise();
}
```

# about raw pointer
`*const T` - 指向永远不会改变的 T 类型数据的指针。
`*mut T` - 指向可以更改的 T 类型数据的指针。

```rust
fn main() {
    let a = 42;
    let memory_location = &a as *const i32 as usize;
    // output the memory_location
    println!("Data is here {}", memory_location);
}
```