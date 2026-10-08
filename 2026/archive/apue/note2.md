---
author: lencelg from Arcadia Bay
title: Advanced Programming in the UNIX Environment note
---
[reference note from shichao-an](https://notes.shichao.io/apue/)

note is not finished and not in consideration now

[TOC]

# Process control
每个进程都有一个非负整型表示的唯一进程 ID。

进程 ID 是可复用的。当一个进程终止后，其进程 ID 就成为复用的候选者。大多数 UNIX 系统实现 **延迟复用算法** ，使得赋予新建进程的 ID 不同于最近终止进程所使用的 ID。这防止了将新进程误认为是使用同一 ID 的某个已终止的先前进程。

系统中有一些专用进程. 
- ID 为 0 的进程通常是调度进程，常常被称为 **交换进程（swapper）**. 该进程是内核的一部分，它并不执行任何磁盘上的程序，因此也被称为系统进程。
- 进程 ID 1 通常是 init 进程，在自举过程结束时由内核调用。init 进程决不会终止。它是一个普通的用户进程（与交换进程不同，它不是内核中的系统进程），但是它以超级用户特权运行。

```c
include <unistd.h>

pid_t getpid(void);
/* Returns: process ID of calling process */

pid_t getppid(void);
/* Returns: parent process ID of calling process */

uid_t getuid(void);
/* Returns: real user ID of calling process */

uid_t geteuid(void);
/* Returns: effective user ID of calling process */

gid_t getgid(void);
/* Returns: real group ID of calling process */

gid_t getegid(void);
/* Returns: effective group ID of calling process */
```

None of these functions has an error to return

## `fork` Function
An existing process can create a new one by calling the `fork` function.

```c
#include <unistd.h>

pid_t fork(void);

/* Returns: 0 in child, process ID of child in parent, −1 on error */
```

*  The new process created by `fork` is called the **child process**. This function is called once but returns twice.
   *  `fork` returns child's process ID in parent
   *  `fork` returns 0 in child
* 子进程是父进程的副本。例如，子进程获得父进程数据空间、堆和栈的副本。注意，这是子进程所拥有的副本。父进程和子进程并不共享这些存储空间部分。父进程和子进程共享正文段
* Copy-on-write (COW) is used on modern implementations: a complete copy of the parent’s data, stack and heap is not performed. The shared regions are changed to read-only by the kernel. The kernel makes a copy of that piece of memory only if either process tries to modify these regions.

example code
```c
#include "apue.h"

int globvar = 6; /* external variable in initialized data */
char buf[] = "a write to stdout\n";

int
main(void)
{
    int var; /* automatic variable on the stack */
    pid_t pid;

    var = 88;
    if (write(STDOUT_FILENO, buf, sizeof(buf)-1) != sizeof(buf)-1)
        err_sys("write error");
    printf("before fork\n"); /* we don’t flush stdout */

    if ((pid = fork()) < 0) {
        err_sys("fork error");
    } else if (pid == 0) { /* child */
        globvar++; /* modify variables */
        var++;
    } else {
        sleep(2); /* parent */
    }

    printf("pid = %ld, glob = %d, var = %d\n", (long)getpid(), globvar,
           var);
    exit(0);
}
```

output as follow

```console
$ ./a.out
a write to stdout
before fork
pid = 430, glob = 7, var = 89 # child’s variables were changed
pid = 429, glob = 6, var = 88 # parent’s copy was not changed
$ ./a.out > temp.out
$ cat temp.out
a write to stdout
before fork
pid = 432, glob = 7, var = 89
before fork
pid = 431, glob = 6, var = 88
```

![](./img/file%20sharing.png)

`fork` 有两种用法
1. 一个父进程希望复制自己，使父进程和子进程同时执行不同的代码段: 在网络服务进程中是常见的——父进程等待客户端的服务请求。当这种请求到达时，父进程调用 fork，使子进程处理此请求。父进程则继续等待下一个服务请求
2. 一个进程要执行一个不同的程序。这对 shell 是常见的情况: 在这种情况下，子进程从 fork 返回后立即调用 exec

## `vfork` Function
The function `vfork` has the same calling sequence and same return values as `fork`, but the semantics of the two functions differ.

`vfork` 函数用于创建一个新进程，而该新进程的目的是 exec 一个新程序

The `vfork` function creates the new process, just like `fork`, without copying the address space of the parent into the child, as the child won’t reference that address space; the child simply calls `exec` (or `exit`) right after the `vfork`. Instead, <u>the child runs in the address space of the parent until it calls either `exec` or `exit`.</u>

This optimization is more efficient on some implementations of the UNIX System, but leads to undefined results if the child:
* modifies any data (except the variable used to hold the return value from `vfork`)
* makes function calls
* returns without calling `exec` or `exit`

## `wait` and `waitpid` Functions
<u>When a process terminates, either normally or abnormally, the kernel notifies the parent by sending the `SIGCHLD` signal to the parent.</u>

A process that calls `wait` or `waitpid` can:
* Block, if all of its children are still running
* Return immediately with the termination status of a child, if a child has terminated and is waiting for its termination status to be fetched
* Return immediately with an error, if it doesn’t have any child processes
```c
#include <sys/wait.h>

pid_t wait(int *statloc);
pid_t waitpid(pid_t pid, int *statloc, int options);

/* Both return: process ID if OK, 0 (see later), or −1 on error */
```

检查 wait 和 waitpid 所返回的终止状态的宏
| 宏 | 说明 |
|---|---|
| WIFEXITED(status) | 若为正常终止子进程返回的状态，则为真。<br>对于这种情况可执行WEXITSTATUS(status)，获取子进程传送给exit或exit参数的8位 |
| WIFSIGNALED(status) | 若为异常终止子进程返回的状态，则为真（接到一个不捕捉的信号）。<br>对于这种情况，可执行WTERMSIG(status)，获取使子进程终止的信号编号。另外，有些实现（非Single UNIX Specification）定义宏WCOREDUMP(status)，若已产生终止进程的core文件，则它返回真 |
| WIFSTOPPED(status) | 若为当前暂停子进程的返回的状态，则为真。<br>对于这种情况，可执行WSTOPSIG(status)，获取使子进程暂停的信号编号 |
| WIFCONTINUED(status) | 若在作业控制暂停后已经继续的子进程返回了状态，则为真。<br>仅用于waitpid() |

对于 waitpid 函数中 pid 参数解释
- `pid == -1` 等待任一子进程。此种情况下，waitpid 与 wait 等效。
- `pid > 0` 等待进程 ID 与 pid 相等的子进程。
- `pid = 0` 等待组 ID 等于调用进程组 ID 的任一子进程。（9.4 节将说明进程组。）
- `pid < -1` 等待组 ID 等于 pid 绝对值的任一子进程。

# Signal
The simplest interface to the signal features of the UNIX System is the signal function
```c
#include <signal.h>

void (*signal(int signo, void (*func)(int)))(int);

/* Returns: previous disposition of signal (see following) if OK, SIG_ERR on error */
```
- `signal` 是一个函数，参数为 `(int signo, void (*func)(int))`。
- 它的返回值类型是 `void (*)(int)` —— 一个**函数指针**，指向参数为 `int`、返回值为 `void` 的函数。
- `int signo`：信号编号，如 `SIGINT`、`SIGTERM`。
- `void (*func)(int)`：也是一个函数指针，指向用户定义的信号处理函数（或 `SIG_IGN`、`SIG_DFL`）。

make it much simpler through the use of the following `typedef`:
```c
typedef void Sigfunc(int);

Sigfunc *signal(int, Sigfunc *);
```

这个声明是 **`signal` 函数**的标准原型，用于设置某个信号的处理方式。它看起来复杂，我们可以逐步拆解。

simple example 
```c
void my_handler(int sig) {
    printf("Caught signal %d\n", sig);
}

// 安装处理程序，保存旧的
void (*old)(int) = signal(SIGINT, my_handler);
if (old == SIG_ERR) {
    perror("signal");
}

// 恢复旧的处理程序
signal(SIGINT, old);
```

book example: recognize SIGUSR1 or SIGUSR2
```c
#include "apue.h"

static void sig_usr(int); /* one handler for both signals */

int
main(void)
{
    if (signal(SIGUSR1, sig_usr) == SIG_ERR)
        err_sys("can't catch SIGUSR1");
    if (signal(SIGUSR2, sig_usr) == SIG_ERR)
        err_sys("can't catch SIGUSR2");
    for (;;)
        pause();
}

static void
sig_usr(int signo)    /* argument is signal number */
{
    if (signo == SIGUSR1)
        printf("received SIGUSR1\n");
    else if (signo == SIGUSR2)
        printf("received SIGUSR2\n");
    else
        err_dump("received signal %d\n", signo);
}
```