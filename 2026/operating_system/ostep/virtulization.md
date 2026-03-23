# CPU virtulization
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
#### 调度：比例份额
一个不同类型的调度程序——比例份额（proportional-share）调度程序，有时也称为公平份额（fair-share）调度程序。

比例份额算法基于一个简单的想法：调
度程序的最终目标，是确保`每个工作获得一定比例的 CPU 时间`，而不是优化周转时间和响
应时间。

假设有两个进程 A 和 B，A 拥有 75 张彩票，B 拥有 25 张。因此我们希望 A 占用 75%的 CPU 时间，而 B 占用 25%。

通过不断定时地（比如，每个时间片）抽取彩票，彩票调度从概率上（random）获得这种份额比例。

|ticket mechanism| description|
|---|---|
| 彩票货币（ticket currency）|每个进程可以拥有自己的货币，通过兑换成全局货币进行使用|
| 彩票转让（ticket transfer）|一个进程可以临时将自己 的彩票交给另一个进程。这种机制在客户端/服务端交互的场景中尤其有用，在这种场景中， 客户端进程向服务端发送消息，请求其按自己的需求执行工作，为了加速服务端的执行， 客户端可以将自己的彩票转让给服务端，从而尽可能加速服务端执行自己请求的速度。服 务端执行结束后会将这部分彩票归还给客户端。
 | 彩票通胀（ticket inflation）|一个进程可以临时提升或 降低自己拥有的彩票数量。通胀可以用于进 程之间相互信任的环境。在这种情况下，如果一个进程知道它需要更多 CPU 时间，就可以 增加自己的彩票，从而将自己的需求告知操作系统，这一切不需要与任何其他进程通信。

 ![](./img/ticket%20example)

---
系统的运行严重依赖于彩票的分配。

假设用户自己知道如何分配，因此可以 给每个用户一定量的彩票，由用户按照需要自主分配给自己的工作。然而这种方案似乎什
么也没有解决——还是`没有给出具体的分配策略`。

因此`彩票分配的问题没有最佳答案`

#### 步长调度（stride scheduling）
当需要进行调度时，选择目前拥有最小行程值的进程，并且在运行之后将该进程的行程值增加一个步长。
```c
current = remove_min(queue);        // pick client with minimum pass
schedule(current);                  // use resource for quantum
current->pass += current->stride;   // compute next pass using stride
insert(queue, current);             // put back into the queue
```

![](./img/stride%20example)

彩票调度有一个步长调度没有的优势——不需要全局状态。假如一个新的进
程在上面的步长调度执行过程中加入系统，应该怎么设置它的行程值呢？设置成 0 吗？
这样的话，它就独占 CPU 了。而彩票调度算法不需要对每个进程记录全局状态，只需要
用新进程的票数更新全局的总票数就可以了。因此彩票调度算法能够更合理地处理新加
入的进程。

#### 多处理器调度
|多处理器的问题|description|
|---|---|
| 缓存一致性（cache coherence）|不同cpu的cache不同，通过总线窥探（bus snooping）来保证数据的正确性|
| 缓存亲和度（cache affinity）|cache有许多信息，下次该进程在相同 CPU 上运行时，由于缓存中的数据而执行得更快。相反，在不同的 CPU 上执行，会由于需要重新加载数据而很慢, 应该尽可能将进程保持在同一个cpu上|
| 同步| 类函数正确工作的方法是加锁（locking）。这里只需要一个互斥锁（即 pthread_mutex_t m;），然后在函数开始时调用 lock(&m)，在结束时调用 unlock(&m)，确保代 码的执行如预期。我们会看到，这里依然有问题，尤其是性能方面。|
##### 单队列调度
`单队列多处理器调度（Single Queue Multiprocessor Scheduling，SQMS）` 引入了一些亲和度机制

![](./img/SQNS)
##### 多队列调度
`多队列多处理器调度（Multi-Queue Multiprocessor Scheduling，MQMS）`

在 MQMS 中，基本调度框架包含多个调度队列，每个队列可以使用不同的调度规则，
比如轮转或其他任何可能的算法。当一个工作进入系统后，系统会依照一些启发性规则（如
随机或选择较空的队列）将其放入某个调度队列。这样一来，每个 CPU 调度之间相互独立，
就避免了单队列的方式中由于数据共享及同步带来的问题。

`负载不均（load imbalance）` problem

![](./img/load%20imblance)

solution
* 迁移（migration）
* 工作窃取（work stealing）

如果太频繁地检查其他队列，就会带来较高的开销，可扩展性不好，相反，如果检查间隔太长，又可能会带来严重的负载不均。`找到合适的阈值仍然是黑魔法`.

# Adress virtulization(virtual memory)
three goals
* tranparency
* efficiency
* protection
## memory api
* malloc()
* free()
* realloc()
* calloc()

mmap()调用从操作系统获取内存。通过传入正确的参数，mmap()可以在程序中创建一个匿名（anonymous）内存区域——这个区域不与任何特定文件相关联，而是与交换空间（swap space）相关联

`interesting programme` as follow
```c
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]) {
    printf("location of code : %p\n", main);
    printf("location of heap : %p\n", malloc(100e6));
    int x = 3;
    printf("location of stack: %p\n", &x);
    return 0;
}
```
```console
# run in cachyos
[i]± |master ?:1 ✗| → ./va
location of code : 0x55a9192ea159
location of heap : 0x7fb26faa1010
location of stack: 0x7ffca0ac6814
```
## mechanism
### address translation
![](./img/address%20space)


$$physical address = virtual address + base$$

* 基址（base）寄存器
* 界限（bound）寄存器: provide access protect, in case access outside of bound

CPU负责地址转换的部分统称为`内存管理单元（Memory Management Unit，MMU）`

operating system work
* 第一，在进程创建时，操作系统必须采取行动，为进程的地址空间找到内存空间。
* 第二，在进程终止时（正常退出，或因行为不端被强制终止），操作系统也必须做一些 工作，回收它的所有内存，给其他进程或者操作系统使用。
* 第三，在上下文切换时，操作系统也必须执行一些额外的操作。
* 第四，操作系统必须提供异常处理程序（exception handler），或要一些调用的函数，像上面提到的那样。
