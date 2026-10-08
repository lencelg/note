---
author: lencelg from Arcadia Bay
title: I/O device
---
this note is made from modern operating system(4th edition) book
[TOC]
# basis
I/O设备大致可以分为两类
- **块设备(block device)** : 信息存储在固定大小的块中．每个块有自己的地址。
- **字符设备(character device)** : 以字符为单位发送或接收一个字符流，而不考虑任何块结构。字符设备是不可寻址的，也没有任何寻道操作。

I/O 设备一般由机械部件和电子部件两部分组成

电子部件称作设备控制器 (device controller) 或适配器 (adapter)

## Memory-mapped I/O
problem:  CPU如何与设备的控制寄存器和数据缓冲区进行通信？

solution1: 每个控制寄存器被分配一个I/O端口 (I/O port)号

solution2: memory-mapped I/O,  将所有控制寄存器映射到内存空间中, 每个控制寄存器被分配唯一的一个内存地址，

## Direct Memory Access
problem: cpu需要寻址设备控制器与I/O设备交换数据。

possible solution: DMA(direct memory access)

workflow: CPU通过设置DMA控制器的寄存器对它进行编程，所以 DMA 控制器知道将什么数据传送到什么地方, DMA控制器还要向磁盘控制器发出一个命令，通知它从磁盘读数据到其内部的缓冲区中，并且对校验和进行校验,如果磁盘控制器的缓冲区中的数据是有效的，那么DMA就可以开始了。

![](./img/DMA)

# I/O software mechanism
## goal and problem
* 设备独立性 (device independence)
* 错误处理 (error handling)
* 同步传输 (synchronous tranmission)
* 异步传输 (asynchronous tranmission)
* 缓冲 (buffering)

## implementation
implementation1: **程序控制 I/O (programmed I/O)** : CPU做全部工作, cpu的工作量大大增加

implementation2: **中断驱动 I/O** :  使用中断来切换cpu的I/O 调度, 明显缺点是中断发生在每个字符上, 中断要花费时间

implementation3: **使用DMA的 I/O** : DMA 重大的成功是将中断的次数从打印每个字符一次减少到打印每个缓冲区一次。

# I/O software architecture
I/O软件通常组织成四个层次

| I/O软件层次 |
|-------------|
| 用户级I/O软件 |
| 与设备无关的操作系统软件 |
| 设备驱动程序 |
| 中断处理程序 |
| 硬件 |

设备驱动程序 (device driver): 管理设备的硬件，厂家把驱动和硬件集成在一起

problem: 如何使所有I/O设备和驱动程序行起来或多或少是相同的。

solution: 对干每一种设备类型．例如磁盘或打印机，操作系统定义一组驱动程序必须支持的函数。

PS: 剩下的不做note

# disk
可参考ostep和csapp

下面介绍RAID6

5级RAID跨磁盘分条带的数据具有一个奇偶块

6级RAID跨磁盘分条带的数据具有两个奇偶块, 可靠性更高，但写的代价增加，容量也少了一些

PS: 时钟以及后面的内容不做介绍

# personal summary
这一章节介绍I/O 设备，从I/O设备的类型到与操作系统如何交流的实现， 再到操作系统的I/O软件的介绍，后面是disk的介绍，与csapp和ostep的介绍一样详细，时钟以及后面的内容概念较多，后面的介绍较为简略，大概描述了一遍主要的I/O设备类型，最后介绍有关计算机的发展相关的I/O历史, 整体来说偏向全面，部分方面详细，是一个出色的章节