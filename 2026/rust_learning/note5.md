---
author: lencelg from Arcadia Bay
title: added note
---
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