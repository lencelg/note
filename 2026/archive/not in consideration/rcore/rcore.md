---
author: lencelg from Arcadia Bay
title: note of rcore
---
# PS: note is not finished, all things about rcore is not in consideration
PS: this is made from[rCore-Tutorial-Book-v3](https://rcore-os.cn/rCore-Tutorial-Book-v3/index.html)

[TOC]
# Introduction
第一章是一个大概的介绍，只记录部分

操作系统概览如下：

操作系统内核，它的主要组成部分包括：
1. 进程/线程管理：内核负责管理系统中的进程或线程，创建、销毁、调度和切换进程或线程。
2. 内存管理：内核负责管理系统的内存，分配和回收内存空间，并保证进程之间的内存隔离。
3. 文件系统：内核提供文件系统接口，负责管理存储设备上的文件和目录，并允许应用访问文件系统。
4. 网络通信：内核提供网络通信接口，负责管理网络连接并允许应用进行网络通信。
5. 设备驱动：内核提供设备驱动接口，负责管理硬件设备并允许应用和内核其他部分访问设备。
6. 同步互斥：内核负责协调多个进程或线程之间对共享资源的访问。同步功能主要用于解决进程或线程之间的协作问题，互斥功能主要用于解决进程或线程之间的竞争问题。
7. 系统调用接口：内核提供给应用程序访问系统服务的入口，应用程序通过系统调用接口调用操作系统提供的服务，如文件系统、网络通信、进程管理等。

![](./img/unix%20system.png)

进程的切换(context switch)

![](./img/process%20switch)

# 应用程序与基本执行环境
这一章节是关于三叶虫LibOS操作系统，大概讲述了系统启动的初始化过程

![](./img/libos)

这里是书中的介绍: 通过上图，大致可以看出Qemu把包含app和三叶虫LibOS的image镜像加载到内存中，RustSBI（bootloader）完成基本的硬件初始化后，跳转到三叶虫LibOS起始位置，三叶虫LibOS首先进行app执行前的初始化工作，即建立栈空间和清零bss段，然后跳转到app去执行。app在执行过程中，会通过函数调用的方式得到三叶虫LibOS提供的OS服务，如输出字符串等，避免了app与硬件直接交互的繁琐过程。

下面是编译流程中不同的目标文件的重新排布

![](./img/rearrge%20data)

# 批处理系统

RISC-V 特权级表格如下：

| 级别 | 编码 | 名称 |
|------|------|------|
| 0    | 00   | 用户/应用模式 (U, User/Application) |
| 1    | 01   | 监督模式 (S, Supervisor) |
| 2    | 10   | 虚拟监督模式 (H, Hypervisor) |
| 3    | 11   | 机器模式 (M, Machine) |