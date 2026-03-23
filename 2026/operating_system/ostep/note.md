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
## process
process is an instance of programme

### process api
process api can be divided into `several types`
* `create`: 操作系统必须包含一些创建新进程的方法。在 shell 中键入命令或双击应用程序图标时，会调用操作系统来创建新进程，运行指定的程序。
* `destory`: 由于存在创建进程的接口，因此系统还提供了一个强制销毁进程的接口。当然，很多进程会在运行完成后自行退出。但是，如果它们不退出， 用户可能希望终止它们，因此停止失控进程的接口非常有用。
* `wait`: 有时等待进程停止运行是有用的，因此经常提供某种等待接口。
* `miscellaneous` control: 除了杀死或等待进程外，有时还可能有其他控制。例如，大多数操作系统提供某种方法来暂停进程（停止运行一段时间），
然后恢复（继续运行）。
* `statu`: 通常也有一些接口可以获得有关进程的状态信息，例如运行了多长时间，或者处于什么状态。

#### fork()
`fork()` create a child process
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
int main(int argc, char *argv[])
{
    printf("hello world (pid:%d)\n", (int) getpid());
    int rc = fork();
    if (rc < 0) {
    // fork failed; exit
        fprintf(stderr, "fork failed\n");
        exit(1);
    } else if (rc == 0) { // child (new process)
        printf("hello, I am child (pid:%d)\n", (int) getpid());
    } else {
    // parent goes down this path (main)
        printf("hello, I am parent of %d (pid:%d)\n", rc, (int) getpid()); 
    }
    return 0;
}
```
output as follow
```console
prompt> ./p1
hello world (pid:29146)
hello, I am parent of 29147 (pid:29146)
hello, I am child (pid:29147)
prompt>
```
#### wait()
`wait()` wait for a process ends, similar api like `waitpid()`
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
int main(int argc, char *argv[])
{
    printf("hello world (pid:%d)\n", (int) getpid());
    int rc = fork();
    if (rc < 0) {
        // fork failed; exit
        fprintf(stderr, "fork failed\n");
        exit(1);
    } else if (rc == 0) { // child (new process)
        printf("hello, I am child (pid:%d)\n", (int) getpid());
    } else {
        // parent goes down this path (main)
        int wc = wait(NULL);
        printf("hello, I am parent of %d (pid:%d)\n", rc, (int) getpid()); 
    }
    return 0;
}
```
```console
prompt> ./p1
hello world (pid:29146)
hello, I am parent of 29147 (pid:29146)
hello, I am child (pid:29147)
prompt>
```
#### exec()
`exec()` can execute other programme, `never return`

the following programme execute `wc(word count)` programme
```c
 #include <stdio.h>
 #include <stdlib.h>
 #include <unistd.h>
 #include <string.h>
 #include <sys/wait.h>
 int main(int argc, char *argv[])
 {
    printf("hello world (pid:%d)\n", (int) getpid());
    int rc = fork();
    if (rc < 0) {
        // fork failed; exit
        fprintf(stderr, "fork failed\n");
        exit(1);
    } else if (rc == 0) { 
        // child (new process)
        printf("hello, I am child (pid:%d)\n", (int) getpid());
        char *myargs[3];
        myargs[0] = strdup("wc");           // program: "wc" (word count)
        myargs[1] = strdup("p3.c");         // argument: file to count
        myargs[2] = NULL;                   // marks end of array
        execvp(myargs[0], myargs);          // runs word count
        printf("this shouldn't print out");
    } else {
        // parent goes down this path (main)
        int wc = wait(NULL);
        printf("hello, I am parent of %d (wc:%d) (pid:%d)\n", rc, wc, (int) getpid());
    }
    return 0;
 }

```
```console
prompt> ./p3
hello world (pid:29383)
hello, I am child (pid:29384)
29 107 1030 p3.c
hello, I am parent of 29384 (wc:29384) (pid:29383)
prompt>
```
### process status
![](./img/process%20status)
* `running`：在运行状态下，进程正在处理器上运行。这意味着它正在执行
指令。
* `ready`：在就绪状态下，进程已准备好运行，但由于某种原因，操作系统
选择不在此时运行。
* `blocked`：在阻塞状态下，一个进程执行了某种操作，直到发生其他事件
时才会准备运行。一个常见的例子是，当进程向磁盘发起 I/O 请求时，它会被阻塞，
因此其他进程可以使用处理器。

### process infomation
在上下文切换(context switch)中，我们需要知道一个进程的信息，通常使用`数据结构`来记录

`example`: `xv6 proc struct`
```c
// the registers xv6 will save and restore
// to stop and subsequently restart a process
struct context {
    int eip;
    int esp;
    int ebx;
    int ecx;
    int edx;
    int esi;
    int edi;
    int ebp;
};
// the different states a process can be in
enum proc_state { UNUSED, EMBRYO, SLEEPING,
RUNNABLE, RUNNING, ZOMBIE };
// the information xv6 tracks about each process
// including its register context and state
struct proc {
    char *mem;                  // Start of process memory
    uint sz;                    // Size of process memory
    char *kstack;               // Bottom of kernel stack
                                // for this process
    enum proc_state state;      // Process state
    int pid;                    // Process ID
    struct proc *parent;        // Parent process
    void *chan;                 // If non-zero, sleeping on chan
    int killed;                 // If non-zero, have been killed
    struct file *ofile[NOFILE]; // Open files
    struct inode *cwd;          // Current directory
    struct context context;     // Switch here to run process
    struct trapframe *tf;       // Trap frame for the
                                // current interrupt
};
```
### processs mechanism
two basic problem
* limited operation
* context switch
#### limited operation
simple idea: 受限直接执行 

![](./img/direct%20run)

but leads to problem, 如果进程希望执行某种受限操作（如向磁盘发出 I/O 请求或获得更多系统资源（如 CPU 或内存））

define running mode
* user mode
* kernel mode

imporved version as follow

![](./img/limited%20running%20protocol)
#### context switch
`协作方式：等待系统调用`

操作系统相信系统的
进程会合理运行。运行时间过长的进程被假定会定期放弃 CPU，以便操作系统可以决定运
行其他任务。

这种情形下考虑进程执行非法指令， 容易引发安全问题

---
`非协作方式：操作系统进行控制`

时钟中断（timer interrupt）
。时钟设备可以编程为每隔几毫秒产生一次中断。产生中断时，当前正在运行的进
程停止，操作系统中预先配置的中断处理程序（interrupt handler）会运行。此时，操作系统
重新获得 CPU 的控制权，因此可以做它想做的事：停止当前进程，并启动另一个进程。

##### 保存和恢复上下文
`scheduler` decide when to switch to anther process

![](./img/time%20interrupt%20version%20of%20process%20mechanism)

the following `asm code` show the `context switch in xv6 `
```mips
# void swtch(struct context **old, struct context *new);
#
# Save current register context in old
# and then load register context from new.
.globl swtch
swtch:
    # Save old registers
    movl 4(%esp), %eax      # put old ptr into eax
    popl 0(%eax)            # save the old IP
    movl %esp, 4(%eax)      # and stack
    movl %ebx, 8(%eax)      # and other registers
    movl %ecx, 12(%eax)
    movl %edx, 16(%eax)
    movl %esi, 20(%eax)
    movl %edi, 24(%eax)
    movl %ebp, 28(%eax)

    # Load new registers
    movl 4(%esp), %eax      # put new ptr into eax
    movl 28(%eax), %ebp     # restore other registers
    movl 24(%eax), %edi
    movl 20(%eax), %esi
    movl 16(%eax), %edx
    movl 12(%eax), %ecx
    movl 8(%eax), %ebx
    movl 4(%eax), %esp      # stack is switched here
    pushl 0(%eax)           # return addr put in place
    ret                     # finally return into new ctxt
```
### process sheduling policy
接下来介绍进程如何调度

---
调度指标
$$T_{周转时间} = T_{完成时间}−T_{到达时间}$$

basic sheduling algorithm
* FIFO: 先到先服务
* SJF: 最短的先服务
* STCF: 最短完成时间优先
* 轮转（Round-Robin， RR）调度

#### FIFO
`First come First served`, 它很简单，而且易于实现, 容易引发护航效应，平均周转时间很差

`护航效应（convoy effect）`,一些耗时较少的潜在资源消费
者被排在重量级的资源消费者之后
#### SJF
`Shortest Job First`, 最短任务优先, 理论上，SJF 确实是一个最优（optimal）
调度算法

SJF 是一种非抢占式（non-preemptive）调度程序, 不可以通过时钟中断进行上下文切换

现在假设工作可以随时到达，而不是同时到达, 也容易引发`护航效应`

![](./img/SJF%20problem)

#### STCF
`最短完成时间优先(Shortest Time-to-Completion First)`

STCF 是抢占式的调度程序

![](./img/STCF)

#### 新度量指标：响应时间
$$T_{响应时间} = T_{首次运行}−T_{到达时间}$$

例如，如果我们有上面STCF的调度（A 在时间 0 到达，B 和 C 在时间 10 达到），每个作业
的响应时间如下：作业 A 为 0，B 为 0，C 为 10（平均：3.33）
#### Round-Robin
 RR 在一个时间片（time slice，有时称为调度量子， scheduling
quantum）内运行一个工作，然后切换到运行队列中的下一个任务，而不是运行一个任务直
到结束。它反复执行，直到所有任务完成。

![](./img/PR)

系统设计者
需要权衡时间片的长度，使其足够长，以便`摊销（amortize）上下文切换成本`，而又不会使
系统不及时响应。

#### 结合 I/O
让我们假设有两项工作 A 和 B，每项工作需要 50ms 的 CPU
时间。但是，有一个明显的区别：A 运行 10ms，然后发出 I/O 请求（假设 I/O 每个都需要
10ms），而 B 只是使用 CPU 50ms，不执行 I/O。调度程序先运行 A，然后运行 B（见图 7.8）。

一种常见的方法是将 A 的每个 10ms 的子工作视为一项独立的工作。因此，当系统启动
时，它的选择是调度 10ms 的 A，还是 50ms 的 B。对于 STCF，选择是明确的：选择较短的
一个，在这种情况下是 A。然后，A 的工作已完成，只剩下 B，并开始运行。然后提交 A
的一个新子工作，它抢占 B 并运行 10ms。这样做可以实现`重叠（overlap）`，一个进程在等
待另一个进程的 I/O 完成时使用 CPU，系统因此得到更好的利用（见图 7.9）。
![](./img/IO%20overlap)

#### 调度：多级反馈队列
`多级反馈队列（Multi-level Feedback Queue， MLFQ）`

该调度程序经过多年的一系列优化，出现在许多现代操作系统中。

MLFQ 中有许多独立的队列（queue），每个队列有不同的优先级（priority level）。任何
时刻，一个工作只能存在于一个队列中。MLFQ 总是优先执行较高优先级的工作（即在较
高级队列中的工作）。每个队列中可能会有多个工作，因此具有同样的优先级我们就对这些工作采用轮转调度

MLFQ 调度策略的`关键在于如何设置优先级`。MLFQ 没有为每个工作指定不变的优先情绪而已，而是`根据观察到的行为调整它的优先级`。

rules
* 规则 1：如果 A 的优先级 > B 的优先级，运行 A（不运行 B）。
* 规则 2：如果 A 的优先级 = B 的优先级，轮转运行 A 和 B。
* 规则 3：工作进入系统时，放在最高优先级（最上层队列）。
* 规则 4a：工作用完整个时间片后，降低其优先级（移入下一个队列）。
* 规则 4b：如果工作在其时间片以内主动释放 CPU， 则优先级不变。

`rule 3`说明:如果不知道工作是短工作还是长工作，那么就在开始的时候假设其是短工作，并赋予最高优先级。如果确实是短
工作，则很快会执行完毕，否则将被慢慢移入低优先级队列，而这时该工作也被认为是长
工作了。通过这种方式，`MLFQ 近似于 SJF`。

---
目前为止的规则会使MLFQ存在`饥饿（starvation）问题`.如果系统有“太多”交互型工作，就会不断占用 CPU，导致长工作永远无法得到 CPU（它们饿死了） 。即使在这种情况下，我们希望这些长 工作也能有所进展。

聪明的用户会重写程序，`愚弄调度程序（game the scheduler）`。愚弄调度程序指
的是用一些卑鄙的手段欺骗调度程序，让它给你远超公平的资源。

---
* 规则 5：经过一段时间 S，就将系统中所有工作重新加入最高优先级队列。

![](./img/rule4)

* 规则 4：一旦工作用完了其在某一层中的时间配额（无论中间主动放弃了多少次 CPU），就降低其优先级（移入低一级队列）。

![](./img/rule5)

all the rules below
* 规则 1：如果 A 的优先级 > B 的优先级，运行 A（不运行 B）。
* 规则 2：如果 A 的优先级 = B 的优先级，轮转运行 A 和 B。
* 规则 3：工作进入系统时，放在最高优先级（最上层队列）。
* 规则 4：一旦工作用完了其在某一层中的时间配额（无论中间主动放弃了多少次
CPU），就降低其优先级（移入低一级队列）。
* 规则 5：经过一段时间 S，就将系统中所有工作重新加入最高优先级队列。