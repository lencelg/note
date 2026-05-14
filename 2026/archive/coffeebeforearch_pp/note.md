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

## OpenMp
let the compiler do the work for us

```cpp
#include <iostream>
#include <omp.h>

int 
main(){
#pragma omp parallel
    {
        std::cout << "Printing from thread" << omp_get_thread_num() << '\n';
    }

    return 0;
}
```

output as follow

```console
[i]○ → ./omp 
Printing from threadPrinting from thread156
Printing from thread1
Printing from thread4
Printing from thread2
Printing from threadPrinting from thread13
Printing from thread14

Printing from thread7
Printing from thread9
Printing from thread5
8
Printing from thread11
Printing from thread3
Printing from thread12
Printing from thread0
Printing from thread10
```

use ``critical`` to make one thread at a time

```cpp
#include <iostream>
#include <omp.h>

int 
main(){
#pragma omp parallel
    {
#pragma omp critical
        {
        std::cout << "Printing from thread: " << omp_get_thread_num() << '\n';

        }
    }

    return 0;
}
```

output as follow

```console
[i]○ → ./omp 
Printing from thread: 13
Printing from thread: 1
Printing from thread: 4
Printing from thread: 11
Printing from thread: 15
Printing from thread: 5
Printing from thread: 8
Printing from thread: 3
Printing from thread: 6
Printing from thread: 10
Printing from thread: 12
Printing from thread: 2
Printing from thread: 14
Printing from thread: 9
Printing from thread: 7
Printing from thread: 0
```

## pthread
rawer, more powerful

```cpp
// This program shows the basics of using Pthreads in C++
// By: Nick from CoffeeBeforeArch

#include <pthread.h>
#include <array>
#include <cassert>
#include <iostream>

// Our mutex for each thread
// We can statically or dynamically initialize it
// Use pthread_mutex_init(...) for dynamic initialization
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

// Our function that serves as the entry point for the threads
// Return values and parameters are passed through void pointers
void *print_func(void *args) {
  // Cast our argument back to it's original type
  int *ID = static_cast<int *>(args);

  // Lock the mutex before printing
  pthread_mutex_lock(&lock);
  std::cout << "Printing from thread: " << *ID << '\n';
  pthread_mutex_unlock(&lock);

  // We can call pthread_exit to kill the thread
  // Pass NULL if we don't care about the status code
  pthread_exit(NULL);
}

int main() {
  // Create an array of four thread IDs and four threads
  std::array<int, 4> ids = {0, 1, 2, 3};
  std::array<pthread_t, 4> threads;

  // Create four threads with the print function as an entrypoint
  // Arguments:
  //  1.) Address of thread object
  //  2.) Thread attributes (NULL means default)
  //  3.) Entrypoint (function pointer)
  //  4.) Void pointer to arguments
  for (auto &id : ids) {
    pthread_create(&threads[id], NULL, print_func, static_cast<void *>(&id));
  }

  // Called from the main thread, this will block until the other 4 threads
  // complete
  pthread_exit(NULL);
}
```

output as follow

```console
[i]○ → ./pthread 
Printing from thread: 0
Printing from thread: 3
Printing from thread: 2
Printing from thread: 1
```
