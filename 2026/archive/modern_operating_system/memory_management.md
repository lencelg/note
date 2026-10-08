---
author: lencelg from Arcadia Bay
title: Memory Management
---
this note is made from modern operating system(4th edition) book
[TOC]
# abstraction: adress space
要使多个应用程序同时处千内存中并且不互相影响，需要解决两个问题：保护和重定位.

简单的解决办法: **动态重定位** 使用基址寄存器和界限寄存器来规定执行的位置, 但是速度慢了一点

## swapping 
problem: 处理内存超载

basic idea: 把一个进程完整调入内存，使该进程运行一段时间，然后把它存回磁盘。

## free memory management
可以参考csapp的malloc lab和ostep的相关章节

* 使用位图的存储管理
* 使用链表的存储管理
  * first fit
  * next fit
  * best fit
  * worest fit
  * quick fit

下面介绍quick fit

它为那些常用大小的空闲区维护单独的链表。快速适配算法寻找一个指定大小的空闲区是十分快速的，但它和所有将空闲区按大小排序的方案一样，共同的缺点: 在一个进程终止或被换出时，寻找它的相邻块并查看是否可以**合井的过程**是非常费时的。

# virtual memory
basic idea: 每个程序拥有自己的地址空间，这个空间被分割成多个块，每一块称作一**页或页面(page)** 

虚拟地址被送到 **内存管理单元** (Memory Management Unit, MMU), MMU把虚拟地址映射为物理内存地址

虚拟地址空间按照固定大小划分成被称为 **页面(page)** 的若干单元, 在物理内存中对应的单元称为 **页框(page frame)** .

如果访问的page页面没有被映射，操作系统会陷入page fault的陷阱来修改映射关系。

---

我们使用虚拟页表来存储page的信息, 一个页表项如下：

![](./img/page%20table%20entry)

## speed up paging 
baisc idea: 考虑使用cache加速

这种设备称为**TLB**(Translation Lookaside Buffer), 它通常在MMU中，包含少量的表项

## dealing with large memory
problem: 怎样处理巨大的虚拟地址空间

one solution: 考虑使用**多级页表**, ostep和csapp中有很好的介绍

other solution: **inverted page table**(倒排页表)

下面介绍inverted page table

每个页框对应一个表项, 而不是每个虚拟页面对应一个表项。 然后可以借助散列表用虚拟地址进行散列来提高映射速度

# page replacement algorithm

书中介绍的算法小结如下, 不做过多的介绍

| 算法 | 注释 |
|------|------|
| 最优算法 | 不可实现，但可用作基准 |
| NRU（最近未使用）算法 | LRU的很粗糙的近似 |
| FIFO（先进先出）算法 | 可能抛弃重要页面 |
| 第二次机会算法 | FIFO的改进版本，比FIFO有较大的改善 |
| 时钟算法 | 现实的 |
| LRU（最近最少使用）算法 | 很优秀，但很难实现 |
| NFU（最不经常使用）算法 | LRU的相对粗略的近似 |
| 老化算法 | 非常近似LRU的有效算法 |
| 工作集算法 | 实现起来开销很大 |
| 工作集时钟算法 | 好的有效算法 |

# segmentation
在机器上提供多个 **互相独立** 的称为 **段(segment)** 的地址空间。每个段由一个从0到最大允许的线性地址序列组成

分段也有助于在几个进程之间共享过程和数据。常见的例子就是共享库(shared library)

# case study
最后探究了分段与分页结合的系统的设计， MULTICS和Intel x86

下面介绍Intel x86的机制

自从 x86-64 起，除了在“传统模式”下，分段机制已被认为是**过时的**且不再被支持。

x86 处理器中有两张表，即 LDT (Local Descriptor Table), 局部描述符表 和 GDT (Global Descriptor Table), 全局描述符表

为了访问一个段，  x86程序必须把这个段的选择子(selector) 装入机器的6个段寄存器的某一个中

![](./img/selector)

在选择子被装人段寄存器时，对应的描述符被从 LDT或GOT 中取出装人微程序寄存器中

![](./img/file%20descriptor)

我们拿到线性地址就可以进行映射, 也可以考虑加入cache来加速映射

![](./img/mapping%20to%20address)

# personal summary
这一章涉及内存的管理
* 空闲内存管理(e.g `malloc()` in c)
* 交换技术
* 页面的置换算法
* 分段与分页的机制 
* cache的加速还有相应的数据结构来记录数据

最后的case study是分段与分页结合的设计模式介绍。描述的内容和csapp以及ostep的差不多，但case study算是亮点。