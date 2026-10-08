---
author: lencelg from Arcadia Bay
title:  Security
---
this note is made from modern operating system(4th edition) book

[TOC]

PS: 这一章我只做了密码学原理部分的note

# Cryptography
加密的目的是将 **明文** (原始信息或文件), 通过某种手段变为 **密文**

在算法中使用的加密参数叫作 **密钥(key)**

$P$代表明文，$K_g$代表加密密钥， $C$代表密文， $E$代表加密算法函数

![](./img/secure)

## private-key cryptography
对称私钥加密技术

特点： 给定了加密密钥就能够较为容易地找到解密密钥，反之亦然, 不太安全

---

## public-key cryptography
problem: 私钥加密体系的发送者与接受者必须同时拥有密钥。他们甚至必须有物理上的接触, 才能传递密钥.

特点： 在公钥密码体系中，加密运算比较简单，而没有密钥的解密运算却十分繁琐。

例子： RSA

## 单向函数
给定参数f和x, 很容易计算出y = f(x).  但是给定 f(x), 要找到相应的x却不可行. 这成为 **单向函数**

## 数字签名
motivation: 留下签名能提供信息， 很有用, 考虑使用散列函数生成数字签名

例子： SHA-1, SHA-256， SHA-512

## software security problem
可以参考csapp， 下面列出概念
* Buffer Overflow
* 栈金丝雀保护
* code rejection
* ROP(返回导向编程)
* 地址空间布局随机化

后面还有一些其他攻击
* 格式化字符串攻击
* 悬垂指针
* 空指针间接引用攻击
* 整数溢出攻击
* 命令注入攻击
* 检查时间／使用时间攻击

# personal summary
这一张关于安全，我不是很感兴趣， 就看了密码学的部分，其他不做笔记, 依旧很全面的章节