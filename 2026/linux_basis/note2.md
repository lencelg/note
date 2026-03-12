# The linux command line
PS: note is only written from some chapters, not the entire book
---
a linux system can be divided into four parts
* linux kernal
* GNU tools
* grahyical desktop environment
* software

linux kernal
* system memory managment(swap space inplements virtual memory)
* process concept
* GNU tools
* file system

![](./img/file%20system)

linux desktop environment<br>
- X windows software
    * X.org(old, stable)
    * wayland(new, fast, secure)
- desktop environment example
    * kde
    * gnome
    * fluxbox
    * xfce

linux distro
* full usage linux distro
* specific usage linux distro

cli interface
- tty(teletypewriter)
- use terminal emulator to access cli

some other notation<br>
> ![](./img/manual%20pages)
> ![](./img/system%20filr)

shell trick
- wildcard(metacharacter wildcard)
    - \? : match any sigle character
    - \* : match zero or more characters
      - ```console
        $ touch my_script my_scrapt my_file
        $ ls -l my_scr?pt
        -rw-rw-r--. 1 christine christine 0 Feb 29 16:12 my_scrapt
        -rwxrw-r--. 1 christine christine 74 Feb 29 16:12 my_script
        $ ls -l my*
        -rw-rw-r--. 1 christine christine 0 Feb 29 16:12 my_file
        -rw-rw-r--. 1 christine christine 0 Feb 29 16:12 my_scrapt
        -rwxrw-r--. 1 christine christine 74 Feb 29 16:12 my_script
        $ ls -l my_s*t
        -rw-rw-r--. 1 christine christine 0 Feb 29 16:12 my_scrapt
        -rwxrw-r--. 1 christine christine 74 Feb 29 16:12 my_script
        ```
    - []: match one charcater in the []
      - ```console
        $ ls f*ll
        fall fell fill full
        $ ls f[a-i]ll
        fall fell fill
        ```
    - !: exclude character in []
      - ```console
        $ ls -l f[!a]ll
        -rw-rw-r--. 1 christine christine 0 Feb 29 16:12 fell
        -rw-rw-r--. 1 christine christine 0 Feb 29 16:12 fill
        -rw-rw-r--. 1 christine christine 0 Feb 29 16:12 full
        ```
---
## Link
inode: identity to file, diferent file has different inode
- Hard Link
    - just like a reference to a file(same inode)
    - ```console
      $ ls -l *test_one
      -rw-rw-r--. 1 christine christine 0 Feb 29 17:26 test_one
      $
      $ ln test_one hlink_test_one
      $
      $ ls -li *test_one
      1415016 -rw-rw-r--. 2 christine christine 0 Feb 29 17:26 hlink_test_one
      1415016 -rw-rw-r--. 2 christine christine 0 Feb 29 17:26 test_one
      ```
- Symbolic Link
  - just like a pointer to a file(different inode)
  - use ln -s command
  - ```console
    $ ls -l test_file
    -rw-rw-r--. 1 christine christine 74 Feb 29 15:50 test_file
    $
    $ ln -s test_file slink_test_file
    $
    $ ls -l *test_file
    lrwxrwxrwx. 1 christine christine 9 Mar 4 09:46 slink_test_file -> test_file
    -rw-rw-r--. 1 christine christine 74 Feb 29 15:50 test_file
    ```
some other command
* file
* cat
* more
* less
* bat
* sort
  - ![](./img/sort)
* grep: grep [options] pattern [file]
  * use regular experssion
* ```
  gzip：用于压缩文件。
  gzcat：用于查看压缩过的文本文件的内容。
  gunzip：用于解压文件。
  ```
## other 
interactive shell: common terminal emulator<br>
non-interactive shell: used for running script file<br>
shell script run under VARIABLE.
```console
#array variable
$ mytest=(zero one two three four)
$ echo $mytest
zero
$ echo ${mytest[*]}
zero one two three four
$ mytest[2]=seven
$ echo ${mytest[2]}
seven
$ unset mytest[2]
$ echo ${mytest[*]}
zero one three four
$
$ echo ${mytest[2]}
$ echo ${mytest[3]}
three
$
$ unset mytest
$ echo ${mytest[*]}

$
```
## Understanding file permissions
```console
$ ls -l
total 68
-rw-rw-r-- 1 rich rich 50 2010-09-13 07:49 file1.gz
-rw-rw-r-- 1 rich rich 23 2010-09-13 07:50 file2
-rw-rw-r-- 1 rich rich 48 2010-09-13 07:56 file3
-rw-rw-r-- 1 rich rich 34 2010-09-13 08:59 file4
-rwxrwxr-x 1 rich rich 4882 2010-09-18 13:58 myprog
-rw-rw-r-- 1 rich rich 237 2010-09-18 13:58 myprog.c
drwxrwxr-x 2 rich rich 4096 2010-09-03 15:12 test1
drwxrwxr-x 2 rich rich 4096 2010-09-03 15:12 test2
$
```
|first char|repserentation|
|---|---|
|\- |file|
|d| dir|
| l| link|
| c|  character device|
| b| device|
| p | Named Pipe|
|s| network socket
| r | readable|
| w | writable|
| x | executable|

![](./img/file%20permission)
---
permission encoding repersentation by order
![](./img/file%20permission%20encoding)
```console
664
first 6 for owner
second 6 for owner's group
4 for other user

use chomd to change file permission
usage: chmod options mode file
example below
$ chmod 760 newfile
$ ls -l newfile
-rwxrw---- 1 rich rich 0 Sep 20 19:16 newfile
```
use chown(change owner) and chgrp(change group)<br>
more advanced: getfacl and setfacl
---
## editor
vim
|operation|explaination|
|---|---|
|d$|delete content from cursor the the end of the line|
|\:s\/old\/new\/g|replace all the old in current line|
|\:n,ms/old/new/g|replace all the old from n line to m line|
|\:%s/old/new/g|replace all the old in the file|
|\:%s/old/new/gc|replace all the old in the file, show tips when replacing each time|
---
* nano editor
* emacs
* kWrite
* kate
* gedit
# linux shell programming basis(based on bash)
```console
$ date ; who # run two command with ; , it seperate run two command
2026年 03月 08日 星期日 17:33:00 CST
lencelg  tty1         2026-03-08 16:34
```
PS: to run a shell script, don't forget to change the file permission
```bash
#!/bin/bash
# the first line specific the interperter, it is not comment
```
```console
command replacement
* (`) # testing=`date`
* $() # testing=$(date)
```
example usage below
```bash
#!/bin/bash
# copy the /usr/bin directory listing to a log file
today=$(date +%y%m%d)
ls /usr/bin -al > log.$today
```
---
Relocation
```console
* <   # used for input
* >   # used for output
* <<  # inline input redirection
record that >> append content to the end of a file
```
---
Pipe
```
use operation |
connect one command output to the another command input
example
$ rpm -qa | sort > rpm.list
```
---
Math
```console
compute integer

# use expr command
# use []
[] example below
$ cat test7
#!/bin/bash
var1=100
var2=50
var3=45
var4=$[$var1 * ($var2 - $var3)]
echo The final result is $var4

computer floating number
use bc(example below)
$ cat test10
#!/bin/bash
var1=100
var2=45
var3=$(echo "scale=4; $var1 / $var2" | bc)
echo The answer for this is $var3
$ ./test10
The answer for this is 2.2222
```
## Structure Command
if then statment
```bash
if command; then
  commands
fi
# or
if command
then
  commands
fi
```
---
if then else statement
```bash
if command
then
  commands
else
  commands
fi
# statement can be nested like the other programme language
```
---
elif statement
```bash
# could be mutil elif statements
if command1
then
  commands
elif command2
then
  more commands
fi
```
test command and other method
```bash
if [ condition ]
then
  commands
fi
```
![](./img/test2)
![](./img/string%20test)
![](./img/file%20test)
```bash
$ cat numeric_test.sh
#!/bin/bash
# Using numeric test evaluations
#
value1=10
value2=11
#
if [ $value1 -gt 5 ]
then
  echo "The test value $value1 is greater than 5."
fi
#
if [ $value1 -eq $value2 ]
then
  echo "The values are equal."
else
  echo "The values are different."
fi
```
---
logcial operation<br>
* ||: stands for or
* &&: stands for and
--- 
(( expression ))<br>
experssion could be math assignment or comparsion
![](./img/(())experssion)<br>

---
[[experssion]]<br>
similar to ((experssion)), can used for pattern matching in string

---
case command<br>
case ends with a esas
---
for command
```bash
for var in list
do
  commands
done
```
c sytle command
```bash
for (( i=1; i <= 10; i++ ))
do
  echo "The next number is $i"
done
```
---
while and until command
```bash
while test command
do
  other commands
done

until test commands
do
  other commands
done
```
break, continue
```
break n 
continue n
n can be specified as the loop count
```
## argument 
```bash
$0              # shell script name
$1 to $9        # first argument to nine argument
$@              # all the argument
$#              # the argument number
$?              # the return val of the previous command
$$              # 当前脚本的进程识别码
!!              # 完整的上一条命令，包括参数。常见应用：当你因为权限不足执行命令失败时，可以使用 `sudo !!` 再尝试一次。
$_              # 上一条命令的最后一个参数。如果你正在使用的是交互式 shell，你可以通过按下 `Esc` 之后键入 . 来获取这个值。

shift           # $3 value to $2, $2 value to $1, $1 value deleted, just as shift
```
```bash
# read from user input, use the read command
read name
read -p "Enter your first and last name: " first last
# if no variable specified, input will be stroed in REPLY variable
$REPLY

# you can set the timer with -t option
# you can also set -s option to avoid showing the infomation typing in the screen, could be used for password or something like that
if read -t 5 -p "Enter your name: " name
then
  echo "Hello $name, welcome to my script."
else
  echo
  echo "Sorry, no longer waiting for name."
fi
exit
```
## Signal
|file descriptor|short hand|
|---|---|
|0|STDIN|
|1|STDOUT|
|2|STDERR|
---
|signal|value|description|
|---|---|---|
|1|SIGHUP|hang up process
|2|SIGINT|interrupt process
|3|SIGQUIT|stop process
|9| SIGKILL|terminate process
|15|SIGTERM|try to terminal process
|18|SIGCONT|continue the stopped process
|19|SIGSTOP|stop the process
|20|SIGTSTP|pause the process
--- 
```bash
to capture a signal, use trap command
usage: trap commands signals
example: trap "echo ' Sorry! I have trapped Ctrl-C'" SIGINT
# you can also modify or remove the signal, example below

#!/bin/bash
#Modifying a set trap
#
trap "echo ' Sorry...Ctrl-C is trapped.'" SIGINT
#
count=1
while [ $count -le 3 ]
do
  echo "Loop #$count"
  sleep 1
  count=$[ $count + 1 ]
done
  trap "echo ' I have modified the trap!'" SIGINT
  count=1
while [ $count -le 3 ]
do
  echo "Second Loop #$count"
  sleep 1
  count=$[ $count + 1 ]
done
exit
```
# Advanced bash shell programming
## function
```bash
two ways to create function

function name{
  commands
}

or 

name{
  commands
}

you can use return command to return something
a function will be treated as a small shell script, so the argument will be the same as the argument note before

you can defind local variable with local command
local temp
```
## Sed and Gawk
sed
---
sed (stream editor): read from stdin and write to stdout, without modifying the origin one<br>
```console
sed options script file
```
|options|description|
|---|---|
|-e commands| 在处理输入时，加入额外的 sed 命令
|-f file| 在处理输入时，将 file 中指定的命令添加到已有的命令中
|-n| 不产生命令输出，使用 p（print）命令完成输出
```console
$ cat data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
$ sed 's/dog/cat/' data1.txt
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
The quick brown fox jumps over the lazy cat.
$ sed -e 's/brown/red/; s/dog/cat/' data1.txt
The quick red fox jumps over the lazy cat.
The quick red fox jumps over the lazy cat.
The quick red fox jumps over the lazy cat.
The quick red fox jumps over the lazy cat.
$ sed -e '
> s/brown/green/
> s/fox/toad/
> s/dog/cat/' data1.txt
The quick green toad jumps over the lazy cat.
The quick green toad jumps over the lazy cat.
The quick green toad jumps over the lazy cat.
The quick green toad jumps over the lazy cat.
$
```
```
below comes to character replacment situation
two way to change /bin/bash to /bin/csh in /etc/passwd
use /: sed 's/\/bin\/bash/\/bin\/csh/' /etc/passwd
use !: sed 's!/bin/bash!/bin/csh!' /etc/passwd
```
```
s/pattern/replacement/flags
/pattern/command
d: use for deleting line
```
|flag| desrciption|
|---|---|
number  |指明新文本将替换行中的第几处匹配。
 g|指明新文本将替换行中所有的匹配。
 p|指明打印出替换后的行。
 w file|将替换的结果写入文件。
 ---
 ```console
 $ cat data5.txt
This is a test line.
This is a different line.
$
$ sed -n 's/test/trial/p' data5.txt
This is a trial line.
$
$ sed 's/test/trial/w test.txt' data5.txt
This is a trial line.
This is a different line.
$
$ cat test.txt
This is a trial line.
$ grep /bin/bash /etc/passwd
root:x:0:0:root:/root:/bin/bash
christine:x:1001:1001::/home/christine:/bin/bash
rich:x:1002:1002::/home/rich:/bin/bash
$
$ sed '/rich/s/bash/csh/' /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
[...]
christine:x:1001:1001::/home/christine:/bin/bash
sshd:x:126:65534::/run/sshd:/usr/sbin/nologin
rich:x:1002:1002::/home/rich:/bin/csh
$
$ grep /bin/bash /etc/passwd
root:x:0:0:root:/root:/bin/bash
christine:x:1001:1001::/home/christine:/bin/bash
rich:x:1002:1002::/home/rich:/bin/bash
$
$ sed '/rich/s/bash/csh/' /etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
[...]
christine:x:1001:1001::/home/christine:/bin/bash
sshd:x:126:65534::/run/sshd:/usr/sbin/nologin
rich:x:1002:1002::/home/rich:/bin/csh
$ sed '2{
> s/fox/toad/
> s/dog/cat/
> }' data1.txt
The quick brown fox jumps over the lazy dog.
The quick brown toad jumps over the lazy cat.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
$
```
---
delete line 
```console
$ cat data1.txt
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy dog
The quick brown fox jumps over the lazy dog
$
$ sed 'd' data1.txt
$ cat data6.txt
This is line number 1.
This is line number 2.
This is the 3rd line.
This is the 4th line.
$
$ sed '3d' data6.txt
This is line number 1.
This is line number 2.
This is the 4th line.
$
$ sed '2,3d' data6.txt
This is line number 1.
This is the 4th line.
$ sed '3,$d' data6.txt
This is line number 1.
This is line number 2.
$
$ sed '/number 1/d' data6.txt
This is line number 2.
This is the 3rd line.
This is the 4th line.
$
```
---
insert line and add text
```
sed '[address]command\
new line'
command:
* i: add line before specific line
* a: add line after specific line
* c: change specifc line
```
```console
$ echo "Test Line 2" | sed 'i\Test Line 1'
Test Line 1
Test Line 2
$ echo "Test Line 2" | sed 'a\Test Line 1'
Test Line 2
Test Line 1
$ echo "Test Line 2" | sed 'i\
> Test Line 1'
Test Line 1
Test Line 2
$ sed '2c\
> This is a changed line of text.
> ' data6.txt
This is line number 1.
This is a changed line of text.
This is the 3rd line.
This is the 4th line.
$ sed '/3rd line/c\           # pattern match mode
> This is a changed line of text.
> ' data6.txt
This is line number 1.
This is line number 2.
This is a changed line of text.
This is the 4th line.
$
```
---
gawk: more powrerful
```
gawk options program file
always use {}
```
|options|description|
|---|---|
|-F fs       |指定行中划分数据字段的字段分隔符
|-f file     |从指定文件中读取 gawk 脚本代码
|-v var=value|定义 gawk 脚本中的变量及其默认值
|-L [keyword]|指定 gawk 的兼容模式或警告级别
---
|variable|description|
|---|---|
$0|代表整个文本行。
$1|代表文本行中的第一个数据字段。
$2|代表文本行中的第二个数据字段。
$n|代表文本行中的第 n 个数据字段。
---
```console
$ echo "My name is Rich" | gawk '{$4="Christine"; print $0}'
My name is Christine
$ gawk '{
> $4="Christine "
> print $0 }'
My name is Rich
My name is Christine
$
```
# Regular experssion
> regular experssion is implemented by regular experssion engine<br>

regular experssion engine<br>
* BRE(basic regualr experssion)
* ERE(extended regular experssion)

## BRE Pattern
* plain text
* special character
    * `.*[]^${}\+?|()` , use `\` to treate it as plain text
* anchor text
    * `^` match pattern in the front of the line
    * `$` match pattern in the end of the line
* \. : match one of any signal character, must match
* character class: [], accept any set of character in the class
* exclude character class: [^]
  * ```console
    $ sed -n '/[^ch]at/p' data6
    This test is at line four.
    $
    ```
* interval
  * ```console
    $ sed -n '/^[0-9][0-9][0-9][0-9][0-9]$/p' data8
    60633
    46201
    45902
    $ sed -n '/[c-h]at/p' data6
    The cat is sleeping.
    That is a very nice hat.
    $ sed -n '/[a-ch-m]at/p' data6
    The cat is sleeping.
    That is a very nice hat.
    $
    ```
* \* : match zero or mutilple times(one time counts)

special interval
![](./img/special%20interval)

## ERE Pattern
* \?: match zero or one time
* \+: match one or mutliple times
* \{}: {m}: match m time or {m, n} match at least m time and at most n time
  * ```console
    $ echo "bt" | gawk --re-interval '/be{1}t/{print $0}'
    $ echo "bat" | gawk --re-interval '/b[ae]{1,2}t/{print $0}'
    bat
    $
    ```
* \| : just like or logical experssion
* (): defind a group
## other
zsh is a modern shell with utilities