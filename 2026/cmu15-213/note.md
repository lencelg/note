# Representing and Manipulating Information
## basis
|hex|decimal|binary|hex|decimal|binary|
|:-----|:------|:---------|:-----|:------|:---------|
|0  |0  |0000   |8	|8	|1000|
|1	|1	|0001	|9	|9	|1001|
|2	|2	|0010	|A	|10	|1010|
|3	|3	|0011	|B	|11	|1011|
|4	|4	|0100	|C	|12	|1100|
|5	|5	|0101	|D	|13	|1101|
|6	|6	|0110	|E	|14	|1110|
|7	|7	|0111	|F	|15	|1111|
## memory representation
![rep](./img/little%20endian%20and%20big%20endian.png)
## basic opertaion
|And|Or|Xor|logic not|Complement|Negate|
|:-----:|:---:|:---------:|:-----:|:------:|:---------:|
|&|\||^|!|-|~|
## tow's completement
unsigned：$B2U(X) = \sum_{i = 0 } ^ {w - 1} {2^{i}* x_i}$<br>
signed：$B2U(X) = -x_{w-1}*2^{w - 1} +\sum_{i = 0 } ^ {w - 2} {2^{i}* x_i}$
* $Umin = 0$
* $Umax = 2^{w} -1$
* $Tmin = -2^{w - 1}$
* $Tmax = 2^{w - 1} −1$
### shift notation
![shift notation](./img/shift%20notation)
### comparsion
![comparsion_convert](./img/comparsion_convert.png)
### overflow
overflow is undefined behavior , nothing is guaranteed to be happened
![](./img/overflow%20give%20unprediable%20value%20in%20c.png "datalab isTmax failed example")
## IEEE floating point

$$ v=(−1)^{s}\times M \times 2^E $$
![](./img/ieee%20conversion.png "bit conversion")
![](./img/floating%20point.png "bit conversion")
![](./img/ieee%20conversion.png "visualization")
![](./img/full%20example.png "example")
### rounding
* towards zero
* round up
* round down
* nearest even(default)
# Machine-Level Representation of Programs
complex instruction set computer(CISC)<br>
reduced instruction set computer(RISC)
<figure>
  <img src="./img/main insruction set.png">
  <figcaption  style="text-align: center; margin-top: 8px;">main instruction set</figcaption>
</figure>


<figure>
  <img src="./img/complier process">
  <figcaption  style="text-align: center; margin-top: 8px;">from c code to binary</figcaption>
</figure>

<figure>
  <img src="./img/reg.png">
  <figcaption  style="text-align: center; margin-top: 8px;">register(partial)</figcaption>
</figure>

## memory layout
<figure>
  <img src="./img/memory layout.png">
</figure>

### stack frame
<figure>
  <img src="./img/stack frame.png">
</figure>

* memory align
### attack
#### Code Injection
![](./img/code%20injection%20attack.png)
#### Return-Oriented Programming
![](./img/gadgets.png)
![](./img/rop.png)
#### tools
* gdb
* objdump
# Program Optimization
## optimization
* Code motion/precomputation
* Strength reduction
* Sharing of common subexperssions
* Removing unnecessary procedure calls
* Exploiting instruction-level parallelism
* Dealing with conditionals(branch prediciton)
* Loop unrolling
  * Reassociated Computation
  * Separate Accumulators
* Vector instructions
## optimization blockers
* procedure calls<br>
    complier treats procedure calls as black box, weak optimization 
    ![](./img/procedule%20calls.png)
    ![](./img/better%20performance.png)
* ### memory alising
    ```c
    int fn (int *a, int *b)
    {
        *a = 3;
        *b = 4;
        return (*a + 5);
    }

    // 编译器会把以上代码优化成下面的样子么？不会！谁知道程序员会不会这么调用 f(&x,&x);
    int fn (int *a, int *b)
    {
        *a = 3;
        *b = 4;
        return (3 + 5);
    }

    // 但是你可以帮助编译器，使用C99的restrict类型限定符，但还是需要开发者确保两个指针不指向同一数据
    // https://gcc.gnu.org/onlinedocs/gcc/Restricted-Pointers.html
    int fn (int *__restrict__ a, int *__restrict__ b)
    {
        *a = 3;
        *b = 4;
        return (*a + 5); // 这里会被优化为 return (3 + 5)
    }
    ```
# Memory hierarchy
## RAM(random access memory)
* SRAM
* DRAM
## I/O bus
## disk
![](./img/disk.png)
## SSD
![](./img/ssd)
## Locality
![](./img/locality.png)
## Memory hierarchy
![](./img/memory%20hierarchy.png)
## Cache memory
C = B * E * S<br>
validate bit<br>
tag bit

cache miss
* cold(compulsory) miss
* conflict miss
* capacity miss

thrash<br>
miss rate
hit rate 
hit time 
miss penalty
## example
![](./img/blocked%20matrix%20multiplication.png)
Blocking : $1 / (4B) * n^3$<br>
No Blocking : $9 / (8) * n^3$
# Linking
two main tasks
* symbol resolution
* relocation
### ELF format
![](./img/ELF.png)
![](./img/ELF2.png)
### Local variable
* local non-static C variable
  * store on stack(linker know nothing about it)
* local C variable
  * stored in either .bss or .data
### symbols and rules
strong symbols
* precedures and initialized globals
weak symbols
* uninitialized globals
three rules(be careful for tricky bug)
* not more than one strong symbol with same name
* one strong symbol and one weak symbol has the same name , choose the strong one
* more than one weak symbols all has the same name , random choose one

relocate entry<br>
static library(.a)<br>
* command line order matters!
* Moral: put the libraries at the end of the commmand line.
shared library(.so)
### Library interpositioning
intercept calls to arbitrary function
* Complie time(#define)
* Link time(-Wl)
* run-time(library interpositioning, lysm, LD_PRELOADED environment variable)
# Exceptional Control Flow
An exception is a transfer of control to the OS kernal in response to some event<br>
![](./img/exception.png)
Exception
* Asynchronous Exceptions 
  * interrupt
    * time interrupt 
    * I/O interrrupt
* Synchronous Exceptions
  * trap
    * intentional
    * system calls, breakpoint traps
  * fault
    * unintentional and possibly recoverable
    * page faults, protection faults
  * abort
    * unintentional and unrecoverable
    * illegal instruction

`syscall`<br>

A `process` is an instance of a running program
* Logical Control Flow
* private address space<br>

mode bit<br>
> concurrent flow, concurrency<br>
> mutiltasking, time slice, time slicing<br>
> parallel flow, running in pararllel and parallel execution

## Context switch
![](./img/context%20switch.png)
A context is being in one of three states
* running
* stopped
* terminated
### Process control
signal concepts
* A signal is `pending` if sent but not yet received
* A process can `block` the receipt of certain signal
* A pending signal is received at most once
* Kernal maintain pending and blocked bit vectors in the context of each process<br>
`write` is the only async-signal-safe output function
PID(process id, positive number)<br>
```c
pid_t getpid(void); //return pid
pid_t getppid(void);//return parent pid
``` 

```c
int fork(void);
// return 0 to the child process, return child's pid to parent process
```

![](./img/fork%20understanding.png)
```c
pid_t waitpid(pid_t pid, int *statusp, int options);
pid_t wait(int *statusp); 
// suspend current process until one of its children terminates

unsigned int sleep(unsigned int secs);
int pause(void);

int execve(const char *filename, const char *argv[], const char *envp[]);
// Loads and runs in the current process, call once and never return

pid_t getpgrp(void);
int setpgid(pid_t pid, pid_t pgid);

int kill(pid_t pid, int sig);
```
### non-local jump
```c
jup_buf env;
int setjmp(jmp_buf env); // return 0
int sigsetjmp(sigjmp_buf env, int savesigs); // return non-zero

void longjmp(jmp_buf env, int retval); // never return
void siglongjmp(sigjmp_buf env, int retval); // never return
```
# Unix I/O
Basic File type
* regular file(text file and binary file)
* directory
* socket
```c
int open(char *filename, int flags, mode_t mode);
int close(int fd);
ssize_t read(int fd, void *buf, size_t n);//返回：若成功则为读的字节数，若 EOF 则为 0, 若出错为 一 1 。
ssize_t write(int fd, const void *buf, size_t n);//返回：若成功则为写的字节数，若出错则为 一 1 。
```
RIO
```c
void rio_readinitb(rio_t *rp, int fd);

ssize_t rio_readlineb(rio_t *rp, void *usrbuf, size_t maxlen);
ssize_t rio_readnb(rio_t *rp, void *usrbuf, size_t n);

ssize_t rio_writen(int fd, void *usrbuf, size_t n);
```
file metadata
```c
struct stat
{
    dev_t           st_dev;     // Device
    ino_t           st_ino;     // inode
    mode_t          st_mode;    // Protection & file type
    nlink_t         st_nlink;   // Number of hard links
    uid_t           st_uid;     // User ID of owner
    gid_t           st_gid;     // Group ID of owner
    dev_t           st_rdev;    // Device type (if inode device)
    off_t           st_size;    // Total size, in bytes
    unsigned long   st_blksize; // Blocksize for filesystem I/O
    unsigned long   st_blocks;  // Number of blocks allocated
    time_t          st_atime;   // Time of last access
    time_t          st_mtime;   // Time of last modification
    time_t          st_ctime;   // Time of last change
}

int stat(const char *filename, struct stat *buf);
int fstat(int fd, struct stat *buf);
// return 0 if success else -1
```
read directory 
```c
// example code
 #include "csapp . h"
 int main(int argc, char **argv)
 {
  DIR *Streamp;
  struct dirent *dep;
  streamp = Opendir(argv [1));
  errno = 0;
  while ((dep = readdir (streamp)) ! = NULL) {
    printf("Fou卫d file: %s\n", dep->d_name);
  }
  if (errno ! = 0)
  unix_error("readdir error");
  Closedir(streamp);
  exit(O);
 }
```
* descriptor table 
* open file table 
* v-node table(shared)
![](./img/classic.png)
![](./img/child.png)
### I/O redirection
`int dup2(int oldfd, int newfd);// locate the newfd to the oldfd` 
![](./img/io%20relocate)
```c
#include <stdio.h>
extern FILE *stdin;     // descriptor 0
extern FILE *stdout;    // descriptor 1
extern FILE *stderr;    // descriptor 2
int main()
{
    fprintf(stdout, "Hello, Da Wang\n");
}
```

# Virtual Memory
### basic concepts
Adavantages
* use main memory efficiently
* simplifies memory management
* isolate address spaces

![](./img/vm%20concept)
DRAM cache organization
* large page size: usually 4K~2M
* Fully associative: any virual page can be stored in any physical page, no limitation
* use write-back instead of write-through<br>
Page table
* 

PS(from [小土刀](https://www.wdxtub.com/blog/csapp/thin-csapp-7#%E5%AD%A6%E4%B9%A0%E7%9B%AE%E6%A0%87))
* Write-through: 命中后更新缓存，同时写入到内存中
* Write-back: 直到这个缓存需要被置换出去，才写入到内存中（需要额外的 dirty bit 来表示缓存中的数据是否和内存中相同，因为可能在其他的时候内存中对应地址的数据已经更新，那么重复写入就会导致原有数据丢失）

Virtual Page
* allocated
* cached
* uncached
![](./img/three%20status)

Page Table Entry(PTE)
* page hit
* page fault
  * page fault handler
  * deamand paging
---
![](./img/found%20page)