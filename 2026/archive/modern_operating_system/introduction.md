---
author: lencelg from Arcadia Bay
title: Introduction
---
this note is made from modern operating system(4th edition) book
[TOC]
# Introduction
## Basis
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

# personal summary
书本的第一章， 没什么好讲的