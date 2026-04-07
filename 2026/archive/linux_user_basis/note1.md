# Linux user basis
# MIT missing-semester
PS : partial note from [missing-semester-cn-github.io](https://github.com/missing-semester-cn/missing-semester-cn.github.io/tree/master)<br>
## basic introduction
shell : cli interface, interact with system and do work with it<br>
sudo concept
```bash
#  basic navigation
cd                              # go to home dir
cd ..                           # go to father dir
cd .                            # go to current dir
pwd                             # print current dir
cd /                            # go to / dir
cd ~                            # same as the first one
ls                              # print the content in the current dir
mkdir somedir                   # make a dir called somedir 
rmdir somedir                   # remove a empty dir called somedir
rm something                    # remove a something(could be dir as well, be careful to deal with rm command)
touch filename                  # create a empty file named filename

cd -                            # go to previous dir (could be import one !)


#  basic command
echo something >> somefile      # append something to the end of somefile
man                             # manual page
tldr                            # simplified version of manual page with example
mv                              # rename or mv somthing
cp                              # copy a file to a location
cat < hello.txt                 # < and > stands for i/o redirction
cat < hello.txt > hello1.txt
ls -l | tail -nl                # | operation connect one output to another programme input
```
## Shell script basis
```bash
foo=bar         # assign a variable
echo "$foo"     # print bar
echo '$foo'     # print $foo
# create a function called mcd
mcd () {         
    mkdir -p "$1"
    cd "$1"
}
$0              # shell script name
$1 to $9        # first argument to nine argument
$@              # all the argument
$#              # the argument number
$?              # the return val of the previous command
$$              # 当前脚本的进程识别码
!!              # 完整的上一条命令，包括参数。常见应用：当你因为权限不足执行命令失败时，可以使用 `sudo !!` 再尝试一次。
$_              # 上一条命令的最后一个参数。如果你正在使用的是交互式 shell，你可以通过按下 `Esc` 之后键入 . 来获取这个值。

false || echo "Oops, fail"
# Oops, fail

true || echo "Will not be printed"
#

true && echo "Things went well"
# Things went well

false && echo "Will not be printed"
#

false ; echo "This will always run"
# This will always run

#!/bin/bash

echo "Starting program at $(date)" # command substitution

echo "Running program $0 with $# arguments with pid $$"

for file in "$@"; do
    grep foobar "$file" > /dev/null 2> /dev/null
    # 如果模式没有找到，则grep退出状态为 1
    # 我们将标准输出流和标准错误流重定向到Null，因为我们并不关心这些信息
    if [[ $? -ne 0 ]]; then  # check if not equal 0 , use [[]] instead of []
        echo "File $file does not have any foobar, adding one"
        echo "# foobar" >> "$file"
    fi
done

# 通配符 - 当你想要利用通配符进行匹配时，你可以分别使用 `?` 和 `*` 来匹配一个或任意个字符。例如，对于文件 `foo`, `foo1`, `foo2`, `foo10` 和 `bar`, `rm foo?` 这条命令会删除 `foo1` 和 `foo2` ，而 `rm foo*` 则会删除除了 `bar` 之外的所有文件。
# 花括号 `{}` - 当你有一系列的指令，其中包含一段公共子串时，可以用花括号来自动展开这些命令。这在批量移动或转换文件时非常方便。

convert image.{png,jpg}
# 会展开为
convert image.png image.jpg

cp /path/to/project/{foo,bar,baz}.sh /newpath
# 会展开为
cp /path/to/project/foo.sh /path/to/project/bar.sh /path/to/project/baz.sh /newpath

# 也可以结合通配使用
mv *{.py,.sh} folder
# 会移动所有 *.py 和 *.sh 文件

mkdir foo bar

# 下面命令会创建 foo/a, foo/b, ... foo/h, bar/a, bar/b, ... bar/h 这些文件
touch {foo,bar}/{a..h}
touch foo/x bar/y
# 比较文件夹 foo 和 bar 中包含文件的不同
diff <(ls foo) <(ls bar)
# 输出
# < x
# ---
# > y
```

<!-- Lastly, pipes `|` are a core feature of scripting. Pipes connect one program's output to the next program's input. We will cover them more in detail in the data wrangling lecture. -->

you can specify the interpreter of the shell scirpt, take the python file as example
```python
#!/usr/local/bin/python
import sys
for arg in reversed(sys.argv[1:]):
    print(arg)
```
some tools for finding
* fd (recommanded)
* find
* fasd
* autojump<br>

shellcheck : tool for analysis shell script<br>
Crtl + r use of history search (powerful tool, use with fzf) 

## vim
since i am a neovim user, only few notes will be made
* H (go to first line of the screen)， M (middle)， L (bottom)
* visualize chunk：Ctrl+v (useful one)
* s replace char(reminder)
* u undo, `<C-r>` redo
* %s/foo/bar/g # replace foo to bar in the file
* :sp/ :vsp split window
---
for shell
* bash: set -o vi
* zsh:  bindkey -v
* fish: fish_vi_key_bindings
* general: export EDITOR=vim

## Date Wrangling
tools
* grep
* sed
* awk
* sort
* bc
---
basic regualr experssion
* .             match any char except the new line
* \*            match zero time or more
* \+            match at least one time
* [abc]         match one of abc
* (RX1|RX2)     match reuslt of RX1 or RX2
* ^             match end of the line
* $             match begin of the line
## command line environment 
main concept of this lecture
* process and signal (more detail in csapp tiny shell lab)
* tmux tool
* alias
* dotfile
* ssh
* terminal simulator
## Version Control
git uses SHA-1 hash<br>

git usage(modified from [missing-semseter-cn.github.io](https://github.com/missing-semester-cn/missing-semester-cn.github.io/blob/ff760c0205a0df65071a7a672fe1a574376b350e/_2020/version-control.md))
- `git branch`: 显示分支
- `git branch <name>`: 创建分支
- `git checkout -b <name>`: 创建分支并切换到该分支
    - 相当于 `git branch <name>; git checkout <name>`
- `git merge <revision>`: 合并到当前分支
- `git mergetool`: 使用工具来处理合并冲突
- `git rebase`: 将一系列补丁变基（rebase）为新的基线
---
- `git remote`: 列出远端
- `git remote add <name> <url>`: 添加一个远端
- `git push <remote> <local branch>:<remote branch>`: 将对象传送至远端并更新远端引用
- `git branch --set-upstream-to=<remote>/<remote branch>`: 创建本地和远端分支的关联关系
- `git fetch`: 从远端获取对象/索引
- `git pull`: 相当于 `git fetch; git merge`
- `git clone`: 从远端下载仓库
---
- `git commit --amend`: 编辑提交的内容或信息
- `git reset HEAD <file>`: 恢复暂存的文件
- `git checkout -- <file>`: 丢弃修改
- `git restore`: git2.32 版本后取代 git reset 进行许多撤销操作
---
- `git config`: Git 是一个 [高度可定制的](https://git-scm.com/docs/git-config) 工具
- `git clone --depth=1`: 浅克隆（shallow clone），不包括完整的版本历史信息
- `git add -p`: 交互式暂存
- `git rebase -i`: 交互式变基
- `git blame`: 查看最后修改某行的人
- `git stash`: 暂时移除工作目录下的修改内容
- `git bisect`: 通过二分查找搜索历史记录
- `.gitignore`: [指定](https://git-scm.com/docs/gitignore) 故意不追踪的文件
## Debugging and Profiling
debugging tools
* pgb (for python)
* gdb
* lldb
* trace(tracking system calls in linux)
---
static analysis
* code linting
* code formatters
* shellcheck (for shell script)
---
profiling
* time
--- 
memory 
* valgrind
---
other tools in linux
* df
* free
* btop
## Metaprogramming
build system
* make
* cmake

Dependency managment<br>
Continuous integration<br>
test concept
* test suite: all the test
* test unit: test specific unit
* intergation test: test if different parts work fine with each other
* regression test: test  for solving bug
* Mocking: replace content unrelated to test
--- 
github action could be used as a simple CI system
## Security and Cryptography
Entropy: meansure of uncertainty<br>

Cryptographic hash function(example: SHA-1)
```
hash(value: array<byte>) -> vector<byte, N>  (N对于该函数固定)
```
Symmetric Encryption
```
keygen() -> key  (这是一个随机方法)

encrypt(plaintext: array<byte>, key) -> array<byte>  (输出密文)
decrypt(ciphertext: array<byte>, key) -> array<byte>  (输出明文)
```
Public-key Cryptography(example: GPG)
```
keygen() -> (public key, private key)  (这是一个随机方法)

encrypt(plaintext: array<byte>, public key) -> array<byte>  (输出密文)
decrypt(ciphertext: array<byte>, private key) -> array<byte>  (输出明文)

sign(message: array<byte>, private key) -> array<byte>  (生成签名)
verify(message: array<byte>, signature: array<byte>, public key) -> bool  (验证签名是否是由和这个公钥相关的私钥生成的)
```
Multi-factor authentication(example: 2FA)
## other
```console
key map:  Escape：Caps Lock
```