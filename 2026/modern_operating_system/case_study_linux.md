---
author: lencelg from Arcadia Bay
title:  "Case Study: Unix, Linux, Android"
---
this note is made from modern operating system(4th edition) book

[TOC]

# history
linux是类Unix系统，linux在免费 UNICES 的战争赢下了BSD, 其他不做介绍

# linux

## linux basis
linux系统的层次结构如下

![](./img/linux%20architecture)

shell不做多余介绍

linux内核结构如下

![](./img/linux%20kernel)

## linux process
在大多数单用户的工作站里，即使用户已经退出登录，仍然会有很多后台进程，即 **守护进程 (daemon)**

** 计划任务(cron daemon)**  是一个典型的守护进程. 计划任务执行一些周期性的活动, 也可以执行一些计划在某些时间点要进行的任务

---

父进程可以通过`fork`创造子进程， 子进程的PID为0

POSIX定义信号来给予对进程的一些控制

| 信号 | 原因 |
|------|------|
| SIGABRT | 进程中且强迫核心转储 |
| SIGALRM | 定时器超时 |
| SIGFPE | 出现浮点错误（比如，除0） |
| SIGHUP | 进程所使用的电话线被挂断 |
| SIGILL | 用户按了DEL键中断了进程 |
| SIGQUIT | 用户按键要求核心转储 |
| SIGKILL | 杀死进程（不能被捕捉或忽略） |
| SIGPIPE | 进程写入了无读者的管道 |
| SIGSEGV | 进程引用了非法的内存地址 |
| SIGTERM | 用于要求进程正常终止 |
| SIGUSR1 | 用于应用程序定义的目的 |
| SIGUSR2 | 用于应用程序定义的目的 |

常见的相关系统调用如下：

| 系统调用 | 描述 |
|----------|------|
| `pid=fork()` | 创建一个与父进程一样的子进程 |
| `pid=waitpid(pid,&statloc,opts)` | 等待子进程终止 |
| `s=execve(name,argv,envp)` | 替换进程的核心映像 |
| `exit(status)` | 终止进程运行并返回状态值 |
| `s=sigaction(sig,&act,&oldact)` | 定义信号处理的动作 |
| `s=signalreturn(&context)` | 从信号返回 |
| `s=sigprocmask(how,&set,&old)` | 检查或更换信号掩码 |
| `s=sigpending(set)` | 获得阻塞信号集合 |
| `s=sigsuspend(sigmask)` | 替换信号掩码或挂起进程 |
| `s=kill(pid,sig)` | 发送信号到进程 |
| `residual=alarm(seconds)` | 设置定时器 |
| `s=pause()` | 挂起调用程序直到下一个信号出现 |

### linux process implementation
进程描述符的信息可以大致归纳为以下几大类：
- 调度参数
- 内存映射
- 信号
- 机器寄存器
- 系统调用状态
- 文件描述符表
- 统计数据
- 内核堆栈
- 其他

创建一个子进程的过程大概如下： 为子进程创建一个新的进程描述符和用户空间，然后从父进程复制大量的内容。这个子进程被赋予一个PID , 井建立它的内存映射，同时它也被赋予了访问属于父进程文件的权限。然后，它的寄存器内容被初始化井准备运行．

下面是shell执行`ls`的例子

![](./img/shell%20ls)

### linux thread
进程是资源容器，而线程是执行单元。一个进程包含一个或多个线程，线程之间共享地址空间、已打开的文件、信号处理函数、警报信号和其他。

linux系统调用`clone`, 模糊了进程和线程的区别

`pid = clone(function, stack_ptr, sharing_flags, arg);`

sharing_flags是一个位图, 具体的各个位如下

| 标志 | 置位时的含义 | 清除时的含义 |
|------|--------------|--------------|
| CLONE_VM | 创建一个新线程 | 创建一个新进程 |
| CLONE_FS | 共享umask、根目录和工作目录 | 不共享 |
| CLONE_FILES | 共享文件描述符 | 复制文件描述符 |
| CLONE_SIGHAND | 共享信号句柄表 | 复制该表 |
| CLONE_PID | 新线程获得旧的PID | 新线程获得自己的PID |
| CLONE_PARENT | 新线程与调用者有相同的父亲 | 新线程的父亲是调用者 |

### linux scheduler
Linux 系统的线程是 **内核线程** ，所以 Linux 系统的调度是 **基于线程** 的，而不是基于进程的 。

Linux 系统将线程区分为三类
1. 实时先入先出 
2. 实时轮转 
3. 分时

 Linux 系统包含 140 个不同的优先级 （包括实时和非实时任务）

下面介绍具体的调度程序

#### O(1) scheduler
在常数时间内执行任务调度, 调度队列被组织成两个数组、 一个是任务 **正在活动** 的数组，一个是任务 **过期失效** 的数组。

不同的优先级被赋予不同的时间片长度，高优先级的进程拥有较长的时间片。

调度器从正在活动数组中选择一个 **优先级最高** 的任务。如果这个任务的时间片过期失效了，就把它移动到过期失效数组中（可能会插入到优先级不同的列表中）

如果这个任务阻塞了，那么在它的时间片过期失效之前，一旦所等待的事件发生，任务就可以继续运行，它将被放回到之前正在活动的数组中，时间片根据它所消耗的 CPU 时间相应的减少。

#### Completely Fair Scheduler
CFS

使用一棵红黑树作为调度队列的数据结构, 根据任务在 CPU 上运行的时间长短而将其有序地排列在树中，这种时间称为 **虚拟运行时间 (vruntime)** 

CFS 总是优先调度那些 **使用 CPU 时间最少的任务** ，通常是在树中最左边节点上的任务。 CFS 会周期性地根据任务已经运行的时间，递增它的虚拟运行时间值，并将这个值与树中当前最左节点的值进行比较

如果正在运行的任务仍具有较小虚拟运行时间值，那么它将继续运行，否则，它将被插入红黑树的适当位置，井且CPU将执行新的最左边节点上的任务。

## linux memory management

### basic concept
每个 Linux 进程都有一个地址空间，逻辑上有三段组成： 代码、数据和堆栈段。
- **代码段** 包含了形成程序可执行代码的机器指令
- **数据段** 包含了所有程序变址、字符串、数字和其他数据的存储
- **栈段** 从虚拟地址空间的顶部或者附近开始，井且向低地址空间延伸

下面介绍一些特性

大多数Linux系统支持 **共享代码段**, 数据段和栈段从来不共享，除非是同一个父进程下的子进程，并且仅仅是那些没有被修改的页面 。

下面的例子中两个进程A和 B 拥有相同的代码段。

![](./img/shared%20code%20block)

Linux 中的进程可以通过 **内存映射文件** 来访问文件数据。

![](./img/memory%20map)

### system call

跟内存管理相关的一些系统调用。若遇到错误则返回0s为-1；a和addr是内存地址，len是长度，prot是控制保护，flags是混杂位串，fd是文件描述符，offset是文件偏移

| 系统调用 | 描述 |
|----------|------|
| `s=brk(addr)` | 改变数据段大小 |
| `a=mmap(addr,len,prot,flags,fd,offset)` | 映射文件 |
| `s=unmap(addr,len)` | 取消映射文件 |

### phsics memory management
Linux 对物理内存区分以下内存区域 (zone):
1. ZONE_DMA 和 ZONE_DMA32 : 可以用于 DMA 操作的页。
2. ZONE_ NORMAL: 正常的，规则映射的页。
3. ZONE_IDGHMEM: 高内存地址的页．井不永久性映射。

物理内存被分成区域，Linux 为每个区域维护一个 **区域描述符** , 区域描述符包含了每个区域中内存利用情况的信息和一个一个空闲区数组

Linux 维护一个 **页描述符数组** (mem_map) , 页描述符是 page 类型的，而且系统当中的每个物理页框都有一个页描述符。

![](./img/memory%20representation)

### memory allocation
**伙伴算法**, 二分伙伴算法 可以参考ostep

slab 分配器

### page replacement
Linux区分四种不同的页面
* 不可回收的 (unreclaimable)
* 可交换的 (swappable)
* 可同步的 (syncable)
* 可丢弃的 (discardable)

算法不做笔记(lack of interest)

## I/O system
所有的 I/O 设备都被当作文件来处理，井且通过与访问所有文件同样的 `read` 和 `write` 系统调用来访问。

基本的 Linux I/O 调度器基干最初的 **Linus电梯调度器 (Linus Elevator scheduler)**

![](./img/linux%20io%20system)

其他的内容不做笔记

## file system

下面介绍一些系统调用，具体系统不做笔记

| 系统调用 | 描述 |
|----------|------|
| `fd = creat(name, mode)` | 创建新文件的一种方法 |
| `fd = open(file, how, ...)` | 打开文件读、写或者读写 |
| `s = close(fd)` | 关闭一个已经打开的文件 |
| `n = read(fd, buffer, nbytes)` | 从文件中读取数据到一个缓冲区 |
| `n = write(fd, buffer, nbytes)` | 把数据从缓冲区写到文件 |
| `position = lseek(fd, offset, whence)` | 移动文件指针 |
| `s = stat(name, &buf)` | 获取一个文件的状态信息 |
| `s = fstat(fd, &buf)` | 获取一个文件的状态信息 |
| `s = pipe(&fd[0])` | 创建一个管道 |
| `s = fcntl(fd, cmd, ...)` | 文件加锁及其他操作 |

下面是与目录相关的一些系统调用。如果发生错误，那么返回值s是-1，dir是一个目录流，dirent是一个目录项.

| 系统调用 | 描述 |
|----------|------|
| `s = mkdir(path, mode)` | 建立新目录 |
| `s = rmdir(path)` | 删除目录 |
| `s = link(oldpath, newpath)` | 创建指向已有文件的链接 |
| `s = unlink(path)` | 取消文件的链接 |
| `s = chdir(path)` | 改变工作目录 |
| `dir = opendir(path)` | 打开目录 |
| `s = closedir(dir)` | 关闭目录 |
| `drent = readdir(dir)` | 读取一个目录项 |
| `rewinddir(dir)` | 回转目录使其再次被读取 |

## linux security
每个用户拥有一个唯一的 **UID(0 ~ 65535)** 的int

用户可以被分组, 有 **GID(组ID)**

UID 为 0 的用户是 **超级用户**

下面是相关的系统调用。当错误发生时，返回值s为-1；uid和gid分别是UID和GID

| 系统调用 | 描述 |
|----------|------|
| `s = chmod(path, mode)` | 改变文件的保护模式 |
| `s = access(path, mode)` | 使用真实的UID和GID测试访问权限 |
| `uid = getuid()` | 获取真实的UID |
| `uid = geteuid()` | 获取有效UID |
| `gid = getgid()` | 获取真实的GID |
| `gid = getegid()` | 获取有效GID |
| `s = chown(path, owner, group)` | 改变所有者和组 |
| `s = setuid(uid)` | 设置UID |
| `s = setgid(gid)` | 设置GID |


# Android
## introduction
Android 是开源的系统, 专为运行在移动智能设备上而设计, 它基于 Linux 内核, 只是将少许新的概念引入 Linux 内核之中.

Android 操作系统的大部分是Java程序设计语言编写的, 内核和大量的低层库是用 C 和 cpp 编写的。

## Android architecture
Android 的体系结构大致如下:

![](./img/andorid%20architecture)

## linux extension
### wake lock
当设备的屏幕关闭之时，设备仍然需要工作：它需要能够接听电话呼叫，接收并处理到来的聊天消息数据，以及许多其他事情。

problem: 移动设备上的电源管理不同于传统的计箕机系统, 因此需要进行扩展

wake lock basic idea:

当屏幕打开时，系统总是持有一个唤醒锁，这样就阻止了设备进入睡眠，所以它将保持运行

在屏样关闭时，系统本身一般井不持有唤醒锁，所以只有在某些其他实体持有唤醒锁的条件下才能保持系统不进入睡眠。当没有唤醒锁被持有时、系统进入睡眠，并且只能由干硬件中断才能将其从睡眠中唤醒.
### out-of-memory Killer
试图在内存极低时进行恢复。

basic idea: 为每个进程分配一个 “坏度" ( badness) 水平，并且简单地杀死最坏的进程。进程的坏度基于进程正在使用的 RAM数量, 它已经运行了多长时间以及其他因素，目标是杀死大量但愿不太重要的进程。

## Dalvik
Dalvik 是 Android 操作系统中已停止维护的 **进程虚拟机 (VM)** ，用于执行为 Android 编写的应用程序。

每个应用程序运行在自己的 Linux 进程中，具有自己的 Dalvik 环境， 这是一种进程隔离, 于是 Android 能够借力于 Linux 的功能特性来管理进程

## Binder IPC
Android 的系统设计特别围绕进程隔离，不但在应用程序之间，而且在系统本身的不同部分之间隔离进程.

problem: 要进行大量的进程间通信，从而在不同的进程之间实现协同．需要做大量的工作并得到正确的结果。

Android 的 Binder进程间通信机制是一个丰富的通用 IPC 设施

# PS
PS: 关于Andorid Binder的剩余内容及后面不做介绍(lack of interest)
# personal view
这一章的case study聚集常见的操作系统，从历史到具体的介绍都很全面，把前面多个章节的内容和操作系统联系起来, 个人认为是书中所有章节中亮点