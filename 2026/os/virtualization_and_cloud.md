---
author: lencelg from Arcadia Bay
title: File System
---
this note is made from modern operating system(4th edition) book
[TOC]
# virtualization
虚拟化的主要思想是虚拟机监控程序(Virtual Machine Monitor, VMM) 在同 一物理硬件上创建出有多台虚拟机器的假象。

优点：
* 强隔离性
* 统一开发环境

于是各大公司开展 **云** 来托管虚拟机

# virtual machine manager
goal
1. 安全性 ：虚拟机管理程序应完全掌控虚拟资源。
2. 保真性 ：程序在虚拟机上执行的行为应与在裸机上相同．
3. 高效性 ：虚拟机中运行的大部分代码应不受虚拟机管理程序的干涉。

虚拟化在x86体系结构上长期以来一直是个问题: Intel 386 体系结构中的缺陷以向后兼容的名义在新 CPU 中延续了20年

**敏感指令(sensitive instructions)** : 每个包含内核态和用户态的 CPU都有一个特殊的指令集合，其中的指令在内核态和用户态执行的行为不同。

**特权指令 (privileged instruction)** : 一个指令集合，其中的指令在用户态执行时会导致陷人.

机器可虚拟化的一个必要条件是敏感指令为特权指令的子集. 因为我们可以在陷入时模拟指令

后来cpu中引入了虚拟化支持， intel(VT, Virtualization Technology), amd(SVM, Secure Virtual Machine)

在没有虚拟化支持的时候使用了 **二进制翻译 (binary translation)** 的技术: 进行改写操作, 替换掉部分不属于特权指令的敏感指令。

两类虚拟化方法
- 第一类虚拟机管理程序
- 第二类虚拟机管理程序

![](./img/two%20kind%20of%20virtual%20machine%20manager)

# implement virtualization without virtualization support from cpu
basic idea: 利用二进制翻译和处理器的特权级

虚拟机管理程序对敏感指令进行代码改写，一次改写一个块

![](./img/without%20VT)

# Paravirtualization
虚拟机管理程序必须一套调用接口: 应用编程接口 (Application Programming Interface, API)

**虚拟机接口(Virtual Machine Interface, VMI)** : 用于内核执行敏感操作, 应用时链接到特定的库来进行操作

其他的虚拟机接口方案: **半虚拟化操作(paravirt op)**, 厂商提倡使用一个与虚拟机管理程序无关的接口让内核与任意的虚拟机管理程序交流

I/O虚拟化与内存虚拟化不做介绍