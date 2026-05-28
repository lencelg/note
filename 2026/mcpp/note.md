---
author: lencelg from Arcadia Bay
title: note of modern cpp
---

[TOC]

# Lec 2
`std::string::nops`  is a constant that holds the largest possible value of size_t type (18446744073709551615 on 64-bit systems), so it's value is just -1.

`std::cmp_greater_equal()` 可以用来安全的比较符号数和无符号数

types like `unsigned char/short` are first promoted to int before any arithmetic operation is performed. This is a standard behavior defined in the C language specification.

各平台对于基本类型的大小支持不太一样，使用`<cstdin>`中的类型来写general code

`NULL` is defined as `((void *)0)` 

`Attribute` : 指定一些属性
- \[\[nodiscard\]\]
- \[\[nodiscard("reason")\]\]
- \[\[noreturn\]\]
- \[\[maybe_unused\]\]
- \[\[deprecated\]\]
- \[\[deprecated("reason")\]\]
