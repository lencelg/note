---
author: lencelg from Arcadia Bay
title: modern operating system
---
this note is made from modern operating system(4th edition) book
[TOC]
# Introduction
计莽机安装了一层软件，称为**操作系统**，它的任务是为用户程序提供一个更好、更简单、更渚晰的计箕机换型，并管理计算机的设备。

---

**进程**本质上是正在执行的一个程序。与每个进程相关的是 地址空间 (address space ) 

在许多操作系统中，与一个进程有关的所有信息，除了该进程自身地址空间的内容以外，均存放在操作系统的 一张表中，称为**进程表**(process table) , 进程表是数组（或链表）结构，当前存在的每个进程都要占用其中一项。

一个进程能够创建一个或多个进程（称为**子进程**）, 我们需要考虑**进程间通信(interprocess communication)**, 我们有一个init进程，是所有进程的根源,在启动计算机的时候这个init进程就存在了

在linux系统中可以使用pstree查看**进程树**, 进程树蕴含了进程之间的关系， 每个进程都有一个特有的**UID(User IDentification)**, 用户可以是某个组的成员，每个组也有一个**GID (Group IDentificalion)**.

---

**文件系统**隐藏磁盘和其他 1/0 设备的细节特性, 创建文件、删除文件、读文件和写文件等都需要系统调用.
* root directory
* file descriptor
* file permission
* working directory
  
特殊文件 (special file)
* 块特殊文件 (block special file) : 由可随机存取的块组成的设备，如磁盘等。
* 字符特殊文件 (character special file): 字符特殊文件用千打印机、调制解调器和其他接收或输出字符流的设备。

**管道 (pipe)** 是一种虚文件，它可连接两个进程
![](./img/pipe)

---

**保护**

UNIX操作系统通过对每个文件赋予一个9位的二进制保护代码, 每个字段中有一位用于**读访问**，一位用于**写访问**，一位用于**执行访间**。这些位就是知名的**rwx**位。

保护代码 rwxr-x--x 的含义是所有者可以读、写或执行该文件，其他的组成员可以读或执行（但不能写）该文件，而其他人可以执行（但不能读和写）该文件。

---

**系统调用**

POSIX系统的系统调用例子如下

**进程管理**

| 调用 | 说明 |
|------|------|
| `pid = fork()` | 创建与父进程相同的子进程 |
| `pid = waitpid(pid, &statloc, options)` | 等待一个子进程终止 |
| `s = execve(name, argv, environp)` | 替换一个进程的核心映像 |
| `exit(status)` | 终止进程执行并返回状态 |

**文件管理**

| 调用 | 说明 |
|------|------|
| `fd = open(file, how, ...)` | 打开一个文件供读、写或两者 |
| `s = close(fd)` | 关闭一个打开的文件 |
| `n = read(fd, buffer, nbytes)` | 把数据从一个文件读到缓冲区中 |
| `n = write(fd, buffer, nbytes)` | 把数据从缓冲区写到一个文件中 |
| `position = lseek(fd, offset, whence)` | 移动文件指针 |
| `s = stat(name, &buf)` | 取得文件的状态信息 |

**目录和文件系统管理**

| 调用 | 说明 |
|------|------|
| `s = mkdir(name, mode)` | 创建一个新目录 |
| `s = rmdir(name)` | 删去一个空目录 |
| `s = link(name1, name2)` | 创建一个新目录项 name2，并指向 name1 |
| `s = unlink(name)` | 删去一个目录项 |
| `s = mount(special, name, flag)` | 安装一个文件系统 |
| `s = umount(special)` | 卸载一个文件系统 |

**杂项**

| 调用 | 说明 |
|------|------|
| `s = chdir(dirname)` | 改变工作目录 |
| `s = chmod(name, mode)` | 修改一个文件的保护位 |
| `s = kill(pid, signal)` | 发送信号给一个进程 |
| `seconds = time(&seconds)` | 自1970年1月1日起的流逝时间 |

下面是一个高度简化的shell说明 `fork` 、 `waitpid` 以及 `execve` 的使用。
```c
#define TRUE 1

while(TRUE){
    type_prompt();               /* 在屏幕上显示提示符 */
    read_command(command, parameters);   /* 从终端读取输入 */
    if (fork() != 0) {
        /* 父代码 */
        waitpid(-1, &status, 0);         /* 等待子进程退出 */
    } else {
        /* 子代码 */
        execve(command, parameters, 0);  /* 执行命令 */
    }
}
```

UNIX 中的进程将其存储空间划分为三段： **正文段（如程序代码）**、**正文数据段（如变量）** 以及**堆栈段**, 数据向上增长而堆栈向下增长．夹在中间的是未使用的地址空间。
![](./img/process)

## operating system structure

**单体系统**: 整个操作系统在内核态以单一程序的方式运行。

![](./img/single%20system)

---

**层次式系统**

我们将系统分成，下面是THE操作系统的分层

| 层号 | 功能 |
|------|------|
| 5    | 操作员 |
| 4    | 用户程序 |
| 3    | 输入/输出管理 |
| 2    | 操作员—进程通信 |
| 1    | 存储器和磁鼓管理 |
| 0    | 处理器分配和多道程序设计 |

---

**微内核**

为了实现高可靠性，将操作系统划分成小的、良好定义的模块，只有其中一个模块成为**微内核**运行在内核态 ，其余的模块作为普通用户进程运行。

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