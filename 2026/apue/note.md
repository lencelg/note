---
author: lencelg from Arcadia Bay
title: Advanced Programming in the UNIX Environment note
---

[TOC]

# Introduction
**Kernel** 控制计算机资源，提供程序运行环境。

## file and directory
Unix 文件系统是目录和文件的一种层次结构。起点是 root directory ("/")  

创建目录时会自动创建两个文件名：`.`（指向当前目录）、`..`（指向父目录）。  

值得一提的是在最高层次的根目录中，这两个文件名是一样的。  

书中的第一个代码例子值得学习  

```c
// 列出文件目录下的所有文件
#include "apue.h"
#include <dirent.h>

int
main(int argc, char *argv[])
{
    DIR    *dp;
    struct dirent  *dirp;

    if (argc != 2)
        err_quit("usage: ls directory_name");

    if ((dp = opendir(argv[1])) == NULL)
        err_sys("can't open %s", argv[1]);

    while ((dirp = readdir(dp)) != NULL)
        printf("%s\n", dirp->d_name);

    closedir(dp);
    exit(0);
}
```
## Input and output
重定向"<"和">".

书中代码例子值得细读.

```c
// 将标准输入复制到标准输出
#include "apue.h"

#define BUFFSIZE 4096

int
main(void)
{
    int n;
    char buf[BUFFSIZE];

    while ((n = read(STDIN_FILENO, buf, BUFFSIZE)) > 0)
        if (write(STDOUT_FILENO, buf, n) != n)
            err_sys("write error");

    if (n < 0)
        err_sys("read error");

    exit(0);
}
```

```c
// 上面的标准I/O 版本, 不过没有使用buf
#include "apue.h"

int
main(void)
{
    int c;

    while ((c = getc(stdin)) != EOF)
        if (putc(c, stdout) == EOF)
            err_sys("output error");

    if (ferror(stdin))
        err_sys("input error");

    exit(0);
}
```

## programme and process
**程序(program)** 是一个可执行文件  

**进程(process)** 是程序的执行实例  

每个进程有独特的ID (process ID)，可以使用`getpid()`获取PID。  

三个控制流函数`fork()`、`exec()`、`waitpid()`

书中的列子是将读取输入的字符串命令然后执行

```c
#include "apue.h"
#include <sys/wait.h>

int
main(void)
{
    char buf[MAXLINE]; /* from apue.h */
    pid_t pid;
    int status;

    printf("%s", /* print prompt (printf requires %% to print %) */
    while ((fgets(buf, MAXLINE, stdin) != NULL) {
        if (buf[strlen(buf) - 1] == '\n')
            buf[strlen(buf) - 1] = 0; /* replace newline with null */

        if ((pid = fork()) < 0) {
            err_sys("fork error");
        } else if (pid == 0) { /* child */
            execvp(buf, buf, (char *)0);
            err_ret("couldn't execute: %s", buf);
            exit(127);
        }

        /* parent */
        if ((pid = waitpid(pid, &status, 0)) < 0)
            err_sys("waitpid error");
        printf("%s ");
    }

    exit(0);
}
```

waitpid 函数返回子进程的终止状态(status变量)，例子中没有使用返回值  

## error handling
在以前只有进程的时候，使用`extern int errno;` 来定义errno  

UNIX系统默认错误码通常会返回一个负值，整型变量errno通常会被设定成相应的值  

在线程中，所以线程都指向同一个全局变量errno，是新定义为

```c
extern int *_errno_location(void);  
#define _errno (*_errno_location())  
```

strerror 函数并返回值是指向消息字符串的指针，errnum 通常是 errno 的值  

```c
#include <string.h>  
char* strerror(int errnum);  
```

`perror()`基于errno的值，在标准错误上产生一条出错信息，它首先输出msg的字符串，然后是一个冒号，一个空格, 接着是errno值的出错信息  

```c
#include <stdio.h>  
void perror(const char* msg);  
```

## user ID  
用户ID为0的用户为根用户(root)  

用户也可以属于一个组，于是有组ID  

相关函数：`getuid()`、`getgid()`  

## signal  
信号(signal)用于通知进程发生了某种情况。  

三种处理信号的方式  
1. 忽略信号，有些信号表示硬件异常  
2. 按优先级处理  
3. 提供捕获信号的函数，并按我们希望的次序处理信号  

SIGINT的系统默认动作是终止进程。  

书中的一个简单例子是定义了一个`sig-int(int)`函数, 不过只是简单的打印出 interrupt 字符串

```c
#include "apue.h"
#include <sys/wait.h>

static void sig_int(int);    /* our signal-catching function */

static void
sig_int(int signo)
{
    printf("interrupt\n");
}

int
main(void)
{
    char buf[MAXLINE];    /* from apue.h */
    pid_t pid;
    int status;

    if (signal(SIGINT, sig_int) == SIG_ERR)
        err_sys("signal error");

    printf("%% ");  /* print prompt */
    while (fgets(buf, MAXLINE, stdin) != NULL) {
        if (buf[strlen(buf) - 1] == '\n')
            buf[strlen(buf) - 1] = 0;    /* replace newline with null */

        if ((pid = fork()) < 0) {
            err_sys("fork error");
        } else if (pid == 0) {    /* child */
            execlp(buf, buf, (char *)0);
            err_ret("couldn't execute: %s", buf);
            exit(127);
        }

        /* parent */
        if ((pid = waitpid(pid, &status, 0)) < 0)
            err_sys("waitpid error");
        printf("%% ");
    }

    exit(0);
}
```

# UNIX standard
这一章不做笔记介绍

# file I/O
在 <unistd.h> 中定义了三个常量：
- `STDIN_FILENO` : 0
- `STDOUT_FILENO`: 1
- `STDERR_FILENO`: 2