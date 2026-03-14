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
* v-node table(shared)<br>
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


# Network Programming
## Client-Server model
every web application is based on `Client-Server model`<br>
![](./img/client-server%20model)
## Network
web is an `I/O device` to a computer<br>
![](./img/io%20devices)
---
web can be divided into three parts
* SAN - System Area Network
  * Switched Ethernet, Quadrics QSW, ...
* LAN - Local Area Network
  * Ethernet, ..
* WAN - Wide Area Network
  * High speed point-to-point phone lines
---
|network part|graph description|
---|---
Ethernet Segment|![](./img/Ethernet%20segment)
Bridged Ethernet Segment|![](./img/Bridged%20Ethernet%20segment)
internets|![](./img/internets)
---
two thing needed to do to transmit message
* define internet address
* transmission protocol
---
## TCP/IP
Transmission Control Protocol/Internet Protocol
* IP (Internet Protocal)
    * Provides basic naming scheme and unreliable delivery capability of packets (datagrams) from host-to-host
* UDP (Unreliable Datagram Protocol)
    * Uses IP to provide unreliable datagram delivery from process-to-process
* TCP (Transmission Control Protocol)
    * Uses IP to provide reliable byte streams from process-to-process over connections
---
IP address(IPV4)
```c
/* IP address structure */
struct in_addr {
    uint32_t s_addr; /* Address in network byte order (big-endian) */
};
```
unix provides several functions to transfer between big-endian and little-endian<br>

Dotted Decimal Notation<br>
IP address：`0x8002C2F2 = 128.2.194.242`
### Internet domain name
to `simplify`, people use domain name instead of ip address in usage(tranmission actually uses ip address)<br>
![](./img/internet%20domain%20name)
### Internet connection
`socket pair`: *`(cliaddr: cliport, servaddr: servport)`*<br>
![](./img/internet%20connection)
## Socket Interface
socket interface is `a set functions combined with unix i/o functions` to create web applications