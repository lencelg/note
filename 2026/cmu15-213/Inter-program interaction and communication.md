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
