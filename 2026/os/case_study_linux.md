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
