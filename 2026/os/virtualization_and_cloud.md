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

两类虚拟化方法
- 第一类虚拟机管理程序
- 第二类虚拟机管理程序

![](./img/two%20kind%20of%20virtual%20machine%20manager)