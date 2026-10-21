---
author: lencelg from Arcadia Bay
title: note of coffeebeforearch cpp from scratch
---

note used to review cpp

- [std::sort](#stdsort)
- [delete with \[\] for array](#delete-with--for-array)
- [smart pointer](#smart-pointer)
- [std::span](#stdspan)
- [about class design](#about-class-design)
- [std::move](#stdmove)
- [virtual inheritance](#virtual-inheritance)
- [function object](#function-object)
- [lambdas](#lambdas)
- [std::jthread](#stdjthread)
- [std::mutex](#stdmutex)
- [std::atomic](#stdatomic)
- [namespace](#namespace)
- [random](#random)
- [constexpr](#constexpr)
- [c11 pp experience](#c11-pp-experience)
  - [add mutex](#add-mutex)
  - [raii way](#raii-way)
  - [OpenMp](#openmp)
  - [pthread](#pthread)

# std::sort
```cpp
std::array<int, 5> my_array = {53, 21, 2, 85, 2};
print(my_array);

std::sort(my_array.begin(), my_array.end());
```

use `std::ranges::sort()` for this instead

```cpp
std::array<int, 5> my_array = {53, 21, 2, 85, 2};
print(my_array);

std::ranges::sort(my_array);
```

# delete with [] for array
```cpp
int *int_ptr = new int[10];
int_ptr[5] = 241;
std::cout << "Value " << int_ptr[5] << '\n';
std::cout << "Address " << &int_ptr[5] << '\n';
delete[] int_ptr;
return 0;
```

# smart pointer 
unique pointer

```cpp
auto ptr = std::make_unique<int[]>(10);
for(int i = 0; i < 10; i += 1) {
    ptr[i] = i * i;
}
std::cout << ptr[5] << '\n';
std::cout << ptr[9] << '\n';
return 0;

```

shared pointer

```cpp
auto ptr1 = std::make_shared<int[]>(10);
auto ptr2 = ptr1;
std::cout << "Reference count: " << ptr1.use_count() << '\n';
return 0;
```

# std::span
`std::span` 可以引用连续的内存，没有所有权

```cpp
#include <iostream>
#include <span>
#include <vector>

void print_subvector(std::span<int> span) {
    for(auto value : span) {
        std::cout << value << ' ';
    }
    std::cout << '\n';
}

int main() {
    std::vector<int> my_vector = {1, 2, 3, 4, 5};
    print_subvector(std::span(my_vector.begin() + 1, 3));
    return 0;
}
```

output as follow

```console
2 3 4
```

# about class design
把所有的部分生成在一起

```cpp
#include <iostream>

struct Point {
    int x;
    int y;

    // 1. 默认构造函数
    Point() : x(0), y(0) {}

    // 2. 参数化构造函数
    Point(int new_x, int new_y) : x(new_x), y(new_y) {}

    // 3. 拷贝构造函数
    Point(const Point &other) : x(other.x), y(other.y) {}

    // 4. 移动构造函数
    Point(Point &&other) noexcept : x(other.x), y(other.y) {
        other.x = 0;
        other.y = 0;
    }

    // 运算符重载
    Point operator+(const Point &rhs) {
        return Point(x + rhs.x, y + rhs.y);
    }

    Point& operator+=(const Point &rhs) {
        x += rhs.x;
        y += rhs.y;
        return *this;
    }

    void print() const {
        std::cout << "x = " << x << '\n';
        std::cout << "y = " << y << '\n';
    }
};

// << 重载
std::ostream& operator<<(std::ostream &os, const Point &p) {
    os << "x = " << p.x << ", y = " << p.y;
    return os;
}

int main() {
    Point p0;                     // 默认构造
    Point p1(10, 20);            // 参数化构造
    Point p2(p1);                // 拷贝构造
    Point p3(std::move(p2));     // 移动构造（p2 被移走后为 {0,0}）

    // 逻辑测试
    Point p4(30, 40);
    p1 += p4;
    
    // 使用重载的 << 
    std::cout << "p0: " << p0 << '\n';
    std::cout << "p1: " << p1 << '\n';
    std::cout << "p2 (after move): " << p2 << '\n';
    std::cout << "p3: " << p3 << '\n';
    
    return 0;
}
```

# std::move
`std::move` 通过将左值强制转换为右值引用`T&&`，强制启用移动语义，使程序能够转移资源所有权（如内存、文件描述符）

本质是`static_cast<T&&>`

# virtual inheritance
使用 virtual inheritance 来解决菱形继承的问题

```cpp
#include <iostream>

struct A {
    A() {
        std::cout << "Constructing A!\n";
    }
};

struct B : virtual A {
    B() {
        std::cout << "Constructing B!\n";
    }
};

struct C : virtual A {
    C() {
        std::cout << "Constructing C!\n";
    }
};

struct D : B, C {
    D() {
        std::cout << "Constructing D!\n";
    }
};

int main() {
    D d;
    A &a = d;
    return 0;
}
```

# function object
overload () operator , so it works
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

struct IsDivisable {
    int divisor;
    IsDivisable(int new_divisor) : divisor(new_divisor) {}
    bool operator()(int dividend) {
        return dividend % divisor == 0;
    }
};

int main() {
    IsDivisable is_divisable_by_10(10);
    std::vector<int> my_vector = {41, 20, 84, 94, 23};
    auto itr = std::ranges::find_if(my_vector, is_divisable_by_10);
    std::cout << *itr << '\n';
    return 0;
}
```

output 20

# lambdas
just a little variant of the () version, but better design

```cpp
auto is_divisable_by_10 = [divisor=10](int dividend) {
    return dividend % divisor == 0;
};
std::vector<int> my_vector = {41, 20, 84, 94, 23};
auto itr = std::ranges::find_if(my_vector, is_divisable_by_10);
std::cout << *itr << '\n';
return 0;
```

# std::jthread
The class `jthread` represents a single thread of execution. It has the same general behavior as `std::thread`, except that jthread automatically rejoins on destruction, and can be cancelled/stopped in certain situations.

类 jthread 表示单个执行线程。它的一般行为和 std::thread 相同，除了 jthread 在析构时会自动再合并，而且能在特定情况下取消/停止。

于是我们有时候甚至可以不用调用`.join()`

```cpp
#include <iostream>
#include <thread>
#include <vector>

void print_thread_id(int id) {
    std::cout << "Printing from thread: " << id << '\n';
}

int main() {
    std::vector<std::jthread> my_threads;
    for(int i = 0; i < 3; i+=1) {
        my_threads.emplace_back(print_thread_id, i);
    }
    return 0;
}
```

输出可以会交错

```console
[i]○ → ./jthread
Printing from thread: Printing from thread: 12
Printing from thread: 0
```

# std::mutex
use std::mutex in raii way to fix the output interleaved problem, a little better
```cpp
#include <iostream>
#include <mutex>
#include <thread>
#include <vector>

int main() {
    std::mutex m;
    auto print_thread_id = [&m](int id) {
        std::lock_guard<std::mutex> lg(m);
        std::cout << "Printing from thread: " << id << '\n';
    };
    
    std::vector<std::jthread> my_threads;
    for(int i = 0; i < 3; i+=1) {
        my_threads.emplace_back(print_thread_id, i);
    }
    return 0;
}
```

# std::atomic
do in atomic way
```cpp
#include <atomic>
#include <iostream>
#include <thread>

int main() {
    std::atomic<int> counter = 0;
    auto work = [&counter](){
        for(int i = 0; i < 10000; i += 1) {
            counter += 1;
        }
    };

    std::thread t1(work);
    std::thread t2(work);
    t1.join();
    t2.join();

    std::cout << counter << '\n';
    return 0;
}
```

# namespace
`::print();` just invoke the current namespace `print` function

# random
不得不说在cpp生成一个随机数的过程和其他语言对比还是感觉麻烦不少

```cpp
#include <iostream>
#include <random>

int main() {
    // 1. 创建真正的随机数引擎（依赖硬件/操作系统熵源）
    std::random_device rd;

    // 2. 用 random_device 生成的种子初始化梅森缠绕器（Mersenne Twister 19937）
    //    mt19937 是目前最常用的高质量伪随机数生成器
    std::mt19937 mt(rd());

    // 3. 定义一个均匀分布对象，取值范围是闭区间 [1, 6]（即 1~6 的整数）
    std::uniform_int_distribution uniform(1, 6);

    for(int i = 0; i < 10; i += 1) {
        // uniform(mt) 调用分布对象，它会从 mt 取出原始随机比特并映射到 [1,6]
        std::cout << uniform(mt) << ' ';
    }
    std::cout << '\n';
    return 0;
}
```

# constexpr
`constexpr` 表达式是指值不会改变并且在编译过程就能得到计算结果的表达式

```cpp
#include <iostream>
#include <random>

constexpr int factorial(int n) {
    if(n <= 1) {
        return 1;
    } else {
        return n * factorial(n - 1);
    }
}

int main() {
    std::random_device rd;
    int result = factorial(rd() % 6);
    std::cout << result << '\n';
    return 0;
}
```

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
