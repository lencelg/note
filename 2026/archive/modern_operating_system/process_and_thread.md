---
author: lencelg from Arcadia Bay
title: Process and Thread
---
this note is made from modern operating system(4th edition) book
[TOC]
# Process 
一个进程是某种类型的一个活动，它有程序、输入、输出以及状态。单个处理器可以被若干进程*共享*，它使用某种**调度算法**决定何时停止一个进程的工作，并转而为**另一个**进程提供服务。

## create process

4种主要事件会导致进程的创建：
1. 系统初始化。
2. 正在运行的程序执行了创建进程的系统调用。
3. 用户诘求创建一个新进程。
4. 一个批处理作业的初始化。

停留在后台处理诸如电子邮件、Web页面 、新闻、 打印之类活动的进程称为**守护进程(daemon)**

**可写的内存是不可以共享的．**

父进程和子进程有各自不同的地址空间, 子进程共享父进程的所有内存，但这种情况下内存通过**写时复制(copy-on-write)** 共享，这意味着一且两者之一想要修改部分内存，则这块内存首先被明确地复制，以确保修改发生在私有内存区域。

## closing process

进程的终止
1. 正常退出（自愿的）
2. 出错退出（自愿的）
3. 严重错误（非自愿）
4. 被其他进程杀死（非自愿）

---

进程的存在**层次结构**

在UNIX 中，进程和它的所有子进程以及后裔共同组成一 个进程组。

## process status
进程的三种状态
1. **运行态**(该时刻进程实际占用CPU).
2. **就绪态**(可运行，但因为其他进程正在运行而暂时停止).
3. **阻塞态**(除非某种外部事件发生，否则进程不能运行).

![](./img/process%20status)

## process implementation
操作系统维护若一张表格(一个结构数组)，即**进程表(process table)**. 每个进程占用一个**进程表项(process control block or PCB)**

下面是一个典型系统中**PCB**的关键字段

![](./img/PCB)

# Thread
线程就像分离的进程（共享地址空间除外）

reason to use thread
* 并行实体拥有共享同一个地址空间和所有可用数据的能力, 这是传统进程模型不具备的
* 线程比进程更轻址级，所以它们比进程更容易（即更快）创建，也更容易撤销。
* 加快应用程序执行的速度。
* 真正并行的实现

基于线程和进程模型的构造服务器的三种方法

| 模型 | 特性 |
|------|------|
| 多线程 | 并行性、阻塞系统调用 |
| 单线程进程 | 无并行性、阻塞系统调用 |
| 有限状态机 | 并行性、非阻塞系统调用、中断 |

各个线程都可以访问*进程地址空间*中的每一个内存地址，所以一个线程可以读、写或甚至清除另一个线程的堆栈．线程之间是**没有保护**的.


| 每个进程中的内容 | 每个线程中的内容 |
|:----------------:|:----------------:|
| 地址空间 | 程序计数器 |
| 全局变量 | 寄存器 |
| 打开文件 | 堆栈 |
| 子进程 | 状态 |
| 即将发生的定时器 | __|
| 信号与信号处理程序 | __|
| 账户信息 | __|

线程状态(和进程差不多)：
* 运行
* 阻塞
* 就绪
* 终止。

**每个线程有自己的堆栈**

---

## POSIX thread api

| 线程调用 | 描述 |
|----------|------|
| pthread_create | 创建一个新线程 |
| pthread_exit | 结束调用的线程 |
| pthread_join | 等待一个特定的线程退出 |
| pthread_yield | 释放CPU来运行另外一个线程 |
| pthread_attr_init | 创建并初始化一个线程的属性结构 |
| pthread_attr_destroy | 删除一个线程的属性结构 |

a simple example
```c
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#define NUMBER_OF_THREADS 10

void *print_hello_world(void *tid)
{
    /* 本函数输出线程的标识符，然后退出。 */
    printf("Hello World. Greetings from thread %d\n", tid);
    pthread_exit(NULL);
}

int main(int argc, char *argv[])
{
    /* 主程序创建10个线程，然后退出。 */
    pthread_t threads[NUMBER_OF_THREADS];
    int status, i;

    for(i=0; i < NUMBER_OF_THREADS; i++) {
        printf("Main here. Creating thread %d\n", i);
        status = pthread_create(&threads[i], NULL, print_hello_world, (void *)i);

        if (status != 0) {
            printf("Oops. pthread_create returned error code %d\n", status);
            exit(-1);
        }
    }

    exit(NULL);
}
```

## thread implementation
线程有两种实现方式
* 用户空间
* 内核

在用户空间管理线程时，每个进程君要有其专用的**线程表**(thread table)

![](./img/thread%20implementation)

用户空间实现和内核实现各有优缺

人们研究了各种试图将用户级线程的优点和内核级线程的优点结合起来的方法。一种方法是使用**内核级线程**，然后将**用户级线程**与某些或者全部内核线程**多路复用**起来

# Inter Process Communication
IPC problem

我们定义临界区来帮助避免竞争条件

好的并发协作满足的条件如下：
1. 任何两个进程不能同时处于其临界区。
2. 不应对 CPU 的速度和数量做任何假设。
3. 临界区外运行的进程不得阻塞其他进程。
4. 不得使进程无限期等待进人临界区．

|实现互斥|描述|
|---|---|
|屏蔽中断| 每个进程在刚刚进入临界区后立即屏蔽所有中断，井在就要离开之前再打开中断。屏蔽中断后，时钟中断也被屏蔽, 然而把屏蔽中断的权力交给用户进程是不明智的|
|锁变量|共享（锁）变量， 0代表没有线程进入临界区，1代表有线程进入临界区, 然而假设一个进程读出锁变社的值并发现它为0, 而恰好在它将其值设置为 1 之前，另一个进程被调度运行，将该锁变为1, 就有两个线程同时进入临界区|
|严格轮换法|以在一个等待循环中不停地测试(自旋锁(spin lock)), 但浪费CPU时间 |
| Peterson解法|一种简单的互斥算法|
|TSL指令|硬件支持的一种方案|

## consumer-producer problem
生产者－消费者问题 or 有界缓冲区(bounded-buffer)问题

```c
#define N 100    /* 缓冲区中的槽数目 */
int count = 0;    /* 缓冲区中的数据项数目 */

void producer(void)
{
    int item;

    while (TRUE) {
        item = produce_item();           /* 产生下一新数据项 */
        if (count == N) sleep();         /* 如果缓冲区满了，就进入休眠状态 */
        insert_item(item);               /* 将（新）数据项放入缓冲区中 */
        count = count + 1;               /* 将缓冲区的数据项计数器增1 */
        if (count == 1) wakeup(consumer);/* 缓冲区空吗？ */
    }
}

void consumer(void)
{
    int item;

    while (TRUE) {                       /* 无限循环 */
        if (count == 0) sleep();         /* 如果缓冲区空，则进入休眠状态 */
        item = remove_item();            /* 从缓冲区中取出一个数据项 */
        count = count - 1;               /* 将缓冲区的数据项计数器减1 */
        if (count == N - 1) wakeup(producer); /* 缓冲区满吗？ */
        consume_item(item);              /* 打印数据项 */
    }
}
```

```
可能会出现竞争条件，其原因是对于count的访问未加限制。有可能出现以下情况：缓冲区为空，消费者刚刚读取count的值发现它为0。
此时调度程序决定暂停消费者并启动运行生产者。生产者向缓冲区中加入一个数据项，count加1。
现在count的值变成了1。它推断认为由于count刚才为0，所以消费者此时一定在睡眠，于是生产者调用wakeup来唤醒消费者。

但是，消费者此时在逻辑上并未睡眠，所以wakeup信号丢失。当消费者下次运行时，它将测试先前读到的count值，发现它为0，于是睡眠。生产者迟早会填满整个缓冲区，然后睡眠。这样一来，两个进程都将永远睡眠下去。

问题的实质在于发给一个（尚）未睡眠进程的wakeup信号丢失了。
```

## use semaphore to solve the consumer-producer problem
```c
#define N 100    /* 缓冲区中的槽数目 */
typedef int semaphore;    /* 信号量是一种特殊的整型数据 */
semaphore mutex = 1;    /* 控制对临界区的访问 */
semaphore empty = N;    /* 计数缓冲区的空槽数目 */
semaphore full = 0;    /* 计数缓冲区的满槽数目 */

void producer(void)
{
    int item;

    while (TRUE) {    /* TRUE是常量1 */
        item = produce_item();    /* 产生放在缓冲区中的一些数据 */
        down(&empty);    /* 将空槽数目减1 */
        down(&mutex);    /* 进入临界区 */
        insert_item(item);    /* 将新数据项放到缓冲区中 */
        up(&mutex);    /* 离开临界区 */
        up(&full);    /* 将满槽的数目加1 */
    }
}

void consumer(void)
{
    int item;

    while (TRUE) {    /* 无限循环 */
        down(&full);    /* 将满槽数目减1 */
        down(&mutex);    /* 进入临界区 */
        item = remove_item();    /* 从缓冲区中取出数据项 */
        up(&empty);    /* 离开临界区 */
        up(&empty);    /* 将空槽数目加1 */
        consume_item(item);    /* 处理数据项 */
    }
}
```
## synchronization mechanism 
同步机制
* 互斥量用在允许或阻塞对临界区的访问上
* 条件变量则允许线程由于一些未达到的条件而阻塞。

信号量的一个简化版本，称为互斥量(mutex), 互斥量仅仅适用千**管理共享资源或一小段代码**


**POSIX互斥量api**

| 线程调用 | 描述 |
|----------|------|
| pthread_mutex_init | 创建一个互斥量 |
| pthread_mutex_destroy | 撤销一个已存在的互斥量 |
| pthread_mutex_lock | 获得一个锁或阻塞 |
| pthread_mutex_trylock | 获得一个锁或失败 |
| pthread_mutex_unlock | 释放一个锁 |

**POSIX条件变量api**

| 线程调用 | 描述 |
|----------|------|
| pthread_cond_init | 创建一个条件变量 |
| pthread_cond_destroy | 撤销一个条件变量 |
| pthread_cond_wait | 阻塞以等待一个信号 |
| pthread_cond_signal | 向另一个线程发信号来唤醒它 |
| pthread_cond_broadcast | 向多个线程发信号来让它们全部唤醒 |

条件变量与互斥量经常一起使用。
```c
#include <stdio.h>
#include <pthread.h>
#define MAX 1000000000                          /* 需要生产的数量 */
pthread_mutex_t the_mutex;
pthread_cond_t condc, condp;
int buffer = 0;                                 /* 生产者消费者使用的缓冲区 */

void *producer(void *ptr)                       /* 生产数据 */
{
    int i;
    for (i = 1; i <= MAX; i++) {
        pthread_mutex_lock(&the_mutex);         /* 互斥使用缓冲区 */
        while (buffer != 0) pthread_cond_wait(&condp, &the_mutex);
        buffer = i;                             /* 将数据放入缓冲区 */
        pthread_cond_signal(&condc);            /* 唤醒消费者 */
        pthread_mutex_unlock(&the_mutex);       /* 释放缓冲区 */
    }
    pthread_exit(0);
}

void *consumer(void *ptr)                       /* 消费数据 */
{
    int i;
    for (i = 1; i <= MAX; i++) {
        pthread_mutex_lock(&the_mutex);         /* 互斥使用缓冲区 */
        while (buffer == 0) pthread_cond_wait(&condc, &the_mutex);
        buffer = 0;                             /* 从缓冲区中取出数据 */
        pthread_cond_signal(&condp);            /* 唤醒生产者 */
        pthread_mutex_unlock(&the_mutex);       /* 释放缓冲区 */
    }
    pthread_exit(0);
}

int main(int argc, char **argv)
{
    pthread_t pro, con;
    pthread_mutex_init(&the_mutex, 0);
    pthread_cond_init(&condc, 0);
    pthread_cond_init(&condp, 0);
    pthread_create(&con, 0, consumer, 0);
    pthread_create(&pro, 0, producer, 0);
    pthread_join(pro, 0);
    pthread_join(con, 0);
    pthread_cond_destroy(&condc);
    pthread_cond_destroy(&condp);
    pthread_mutex_destroy(&the_mutex);
}
```

## pipe
motivation: 有了信号量和互斥量之后，进程间通信看来就容易了一些. 然而**并非如此**。使用信号量时要非常小心, 代码编写顺序很重要,bug很难调试. 为了更易编写正确的程序, **管程**是一种高级的同步原语

definition: 一个管程是一个由过程、变量及数据结构等组成的一个集合，它们组成一个特殊的楼块或软件包。

working policy: 管程有一个很重要的特性．即任一时刻管程中只能有一个活跃进程，这一特性使管程能有效地完成互斥。还引入了条件变量

PS: 管程是一种概念， c语言并不支持

下面是java语言的管程解决producer-consumer problem的代码
```java
public class ProducerConsumer {
    static final int N = 100; // 定义缓冲区大小的常量
    static producer p = new producer(); // 初始化一个新的生产者线程
    static consumer c = new consumer(); // 初始化一个新的消费者线程
    static our_monitor mon = new our_monitor(); // 初始化一个新的管程

    public static void main(String args[]) {
        p.start(); // 开始生产者线程
        c.start(); // 开始消费者线程
    }

    static class producer extends Thread {
        public void run() { // run方法包含了线程代码
            int item;
            while (true) { // 生产者循环
                item = produce_item();
                mon.insert(item);
            }
        }

        private int produce_item() { ... } // 实际生产
    }

    static class consumer extends Thread {
        public void run() { // run方法包含了线程代码
            int item;
            while (true) { // 消费者循环
                item = mon.remove();
                consume_item(item);
            }
        }

        private void consume_item(int item) { ... } // 实际消费
    }

    static class our_monitor { // 这是一个管程
        private int buffer[] = new int[N];
        private int count = 0, lo = 0, hi = 0; // 计数器索引

        public synchronized void insert(int val) {
            if (count == N) go_to_sleep(); // 如果缓冲区满，则进入休眠
            buffer[hi] = val; // 向缓冲区中插入一个新的数据项
            hi = (hi + 1) % N; // 设置下一个数据项的槽
            count = count + 1; // 缓冲区中的数据项又多了一项
            if (count == 1) notify(); // 如果消费者在休眠，则将其唤醒
        }

        public synchronized int remove() {
            int val;
            if (count == 0) go_to_sleep(); // 如果缓冲区空，进入休眠
            val = buffer[lo]; // 从缓冲区中取出一个数据项
            lo = (lo + 1) % N; // 设置待取数据的槽
            count = count - 1; // 缓冲区中的数据项数目减少1
            if (count == N - 1) notify(); // 如果生产者正在休眠，则将其唤醒
            return val;
        }

        private void go_to_sleep() { try(wait()); catch(InterruptedException exc) {}; }
    }
}
```
## other synchronization mechanism 
* 消息传递 (message passing)
* 屏障 (barrier) 

屏障 (barrier) 用于进程组而不是用于双进程的生产者－消费者类情形的。

屏障可用于一组进程同步: 当一个进程到达屏障时，它就被屏障阻拦，直到所有进程都到达该屏障为止。

![](./img/barrier)

## Read-Write-Copy
读-复制-更新 ( Read-Copy-Update, RCU), 将更新过程中的移除和再分配过程分离开来。

basic idea: 在某些情况下，我们可以允许写操作来更新数据结构，即便还有其他的进程正在使用它。窍门在干确保每个读操作要么读取**旧的数据版本**，要么读取**新的数据版本**，但**绝不能**是新旧数据的组合。

# scheduling
三种系统的调度环境
1. 批处理(batch processing)
2. 交互式(interactive system)
3. 实时(real time)(不予介绍)

## batch processing
* first-come first-served
* shortest job first
* shortest remaining time next

## interactive system
* 轮转调度
* 优先级调度
* 多级队列(使用优先级调度)
* 最短进程优先
* 保证调度
* 彩票调度

# classic IPC problem
* 哲学家就餐问题
* 读者-写者问题

# personal summary
书本的第二章讨论进程， 线程方面很全面，后面介绍同步机制和调度算法， 调度算法的介绍偏向简略, 最后是经典IPC问题，具有广度但在代码方面也有一定的深度。