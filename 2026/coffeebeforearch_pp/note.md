---
author: lencelg from Arcadia Bay
title:  pp note
---

[TOC]

# Introduction
## reason
高性能的需求
- 计算机结构的发展
- 软件应用的发展

并行计算无处不在

## basic concept
并行算法： 每个 **处理单元(PE, Processing Element)** 计算数值的一部分
- 负载
- 数据同步
- 数据通信

几种并行
- 指令级并行----单个处理核内部（指令流水、VLIW、超标量、SIMD）
- 线程级并行----多个处理核之间
- 进程级并行多个处理器之
- 循环并行
- 任务并行
- 访存并行
- ...

## evaluation
加速比(Speedup)
$$S_p = \frac{T_1}{T_p}$$
- $p$ 指cpu数量
- $T_1$ 指顺序执行算法的时间
- $T_p$ 指 $p$ 个处理器并行算法的时间

井行效率（ParallelEfficiency）
$$S_p = \frac{T_1}{p \times T_p}$$
- 并行效率和加速比很像
- Ep的值一般介于0~1之间，用于表示在解决问题时，相较于在通信与同步上的开销，参与计算的处理器得到了多大程度的充分利用
- 拥有理想加速比的算法并行效率为1

## basic method
- 数据并行
- 任务并行

并行编程的过程抽象成设计空间和模式
- 寻找并发性设计空间
  - 任务分解
  - 数据分解
- 算法结构设计空间
  - 分治、流水、任务并行、事件协作
- 支持结构设计空间
  - 主从模式、SPMD
  - 共享队列、分布式队列
- 实现机制设计空间
  - 进程/线程的管理、交互

几个基本问题
- 任务划分
- 调度
- 同步
- 通信

# c11 pp experience
first version

```cpp
#include <iostream>
#include <thread>
#include <mutex>

void print_func(int id){
    std::cout<< "Printing from thread :" << id << '\n';
}
int
main(){
    std::thread t0(print_func, 0);
    std::thread t1(print_func, 1);
    std::thread t2(print_func, 2);
    std::thread t3(print_func, 3);

    t0.join();
    t1.join();
    t2.join();
    t3.join();
}
```

the output is random

```console
[i]○ → ./threads 
Printing from thread :0Printing from thread :
Printing from thread :2
3
Printing from thread :1
```

## add mutex
```cpp
#include <iostream>
#include <thread>
#include <mutex>

std::mutex t;
void print_func(int id){
    t.lock();
    std::cout<< "Printing from thread :" << id << '\n';
    t.unlock();
}
int
main(){
    std::thread t0(print_func, 0);
    std::thread t1(print_func, 1);
    std::thread t2(print_func, 2);
    std::thread t3(print_func, 3);

    t0.join();
    t1.join();
    t2.join();
    t3.join();
}
```

after adding a mutex lock, output is a little bit better

```console
[i]○ → ./threads 
Printing from thread :0
Printing from thread :1
Printing from thread :2
Printing from thread :3
```

## raii way
do in modern raii way
```cpp
#include <iostream>
#include <thread>
#include <mutex>

std::mutex t;
void print_func(int id){
    std::lock_guard<std::mutex> g(t);
    std::cout<< "Printing from thread :" << id << '\n';
}
int
main(){
    std::thread t0(print_func, 0);
    std::thread t1(print_func, 1);
    std::thread t2(print_func, 2);
    std::thread t3(print_func, 3);

    t0.join();
    t1.join();
    t2.join();
    t3.join();
}
```

more convenient with the same result
