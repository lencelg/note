# Introduction
## virtualization
the following programme allocated memory and print it out
```c
 #include <unistd.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include "common.h"
 int main(int argc, char *argv[])
 {
    int *p = malloc(sizeof(int));
    assert(p != NULL);
    printf("(%d) memory address of p: %08x\n",
    getpid(), (unsigned) p);
    *p = 0;
    while (1) {
    Spin(1);
    *p = *p + 1;
    printf("(%d) p: %d\n", getpid(), *p);
    return 0;
 }
```
the following is output
```console
prompt> ./mem &; ./mem &
[1] 24113
[2] 24114
(24113) memory address of p: 00200000
(24114) memory address of p: 00200000
(24113) p: 1
(24114) p: 1
(24114) p: 2
(24113) p: 2
(24113) p: 3
(24114) p: 3
(24113) p: 4
(24114) p: 4
...
```
每个进程访问自己的私有虚拟地址空间（virtual address space）（有时称为地址空间，address space）， 操作系统以某种方式映射到机器的物理内存上。一个正在运行的程序中的内存引用不会影响其他进程（或操作系统本身）的地址空间。对于正在运行的程序，它完全拥有自己的物理内存。但实际情况是，物理内存是由操作系统操理的共享资源。
## concurrency
the following programme create thread
```c
#include <stdio.h>
#include <stdlib.h>
#include "common.h"
volatile int counter = 0;
int loops;
void *worker(void *arg) {
    int i;
    for (i = 0; i < loops; i++) {
        counter++;
    }
    return NULL;
}
int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "usage: threads <value>\n");
        exit(1);
    }
    loops = atoi(argv[1]);
    pthread_t p1, p2;
    printf("Initial value : %d\n", counter);
    Pthread_create(&p1, NULL, worker, NULL);
    Pthread_create(&p2, NULL, worker, NULL);
    Pthread_join(p1, NULL);
    Pthread_join(p2, NULL);
    printf("Final value : %d\n", counter);
    return 0;
}
```
the following is output
```console
prompt> gcc -o thread thread.c -Wall -pthread
prompt> ./thread 1000
Initial value : 0
Final value : 2000
prompt> ./thread 100000
Initial value : 0
Final value : 143012 // huh??
prompt> ./thread 100000
Initial value : 0
Final value : 137298 // what the??
```
这些奇怪的、不寻常的结果与指令如何执行有关，指令每一执行一条。遗憾的是，上面的程序中的关键部分是增加共享计数器的地方，它需要`3条指令`：一条将计数器的值从内存加载到寄存器，一条将其递增，一条将其保存回内存。因为这3条指令不是以`原子方式（atomically）执行（所有的指令一一性执行）`的，所以奇怪的事情可能会发生。这是一种并发（concurrency）问题
##  persistence
在系统内存中，数据容易丢失，因为像 DRAM 这样的设备以易失（volatile）的方式存储数值。如果断电或系统崩溃，那么内存中的所有数据都会丢失。因此，我们需要硬件和软件来持久地（persistently）存储数据。这样 的存储对于所有系统都很重要，因为用户非常关心他们的数据。

下面的程序：第一个是对 open()的调用，它打开
文件创建它。第二个是 write()，将一些数据写入文件。第三个是 close()，只是简单地关闭文
件，从而表明程序不会再向它写入更多的数据。
```c
#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <fcntl.h>
#include <sys/types.h>
int main(int argc, char *argv[])
{
    int fd = open("/tmp/file", O_WRONLY | O_CREAT | O_TRUNC, S_IRWXU);
    assert(fd > -1);
    int rc = write(fd, "hello world\n", 13);
    assert(rc == 13);
    close(fd);
    return 0;
}
```