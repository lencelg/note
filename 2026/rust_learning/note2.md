---
author: lencelg from Arcadia Bay
title: learning rust
---
this bad note made from [Rust By Example](https://doc.rust-lang.org/rust-by-example/index.html)

this is part2 of the note
[TOC]

# Functions
## Closures
**Closures** are functions that can capture the enclosing environment. e.g capture the x val;(kind of lambda function)
```
|val| val + x
```
capture variables ways:
* by reference: `&T`
* by mutable reference: `&mut T`
* by value: `T`