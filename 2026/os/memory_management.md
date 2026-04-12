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