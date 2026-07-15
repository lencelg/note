#import "@preview/scholia:0.1.0": *

// options: theme: "light" | "dark" · prose: "notes" | "book" · fonts: (…)
#show: scholia.with(prose: "notes")

#cover("git, docker", subtitle: "lencelg", author: "lencelg from Arcadia Bay", date: "2026 summer")


#set text(font: "LXGW WenKai", size: 9.5pt)
#show raw: set text(font: "Hack Nerd Font")

#notation[
  #text(size: 14pt)[

这里的note不会介绍git的基础，只给出一些基本的指令

另外推荐使用lazygit来进行git的相关操作
]]

#outline()

#pagebreak()

= git速查表

````git
配置与设置
  git config --global user.name "Your Name"        # 设置全局用户名
  git config --global user.email "your@email.com"  # 设置全局邮箱
  git config --global init.defaultBranch main      # 默认分支名
  git config --list                                # 查看所有配置

仓库操作
  git init                                         # 初始化新仓库
  git clone <repository_url>                       # 克隆远程仓库

基本操作（工作流）
  git status                                       # 查看状态
  git add <file>                                   # 添加指定文件到暂存区
  git add -A                                       # 添加所有变更（含新文件和删除）
  git add -p                                       # 交互式选择部分修改添加
  git commit -m "message"                          # 提交暂存区变更
  git commit -am "message"                         # 跳过 add，提交已跟踪文件
  git commit --amend                               # 修改最近一次提交

分支管理
  git branch                                       # 列出本地分支
  git branch <branch-name>                         # 创建新分支
  git branch -d <branch-name>                      # 删除分支
  git branch -D <branch-name>                      # 强制删除未合并分支
  git switch <branch-name>                         # 切换分支
  git switch -c <branch-name>                      # 创建并切换分支
  git checkout <branch-name>                       # 切换分支（旧命令）
  git checkout -b <branch-name>                    # 创建并切换（旧命令）

远程仓库
  git remote add origin <url>                      # 添加远程仓库
  git remote -v                                    # 查看远程仓库
  git push origin <branch-name>                    # 推送到远程
  git pull origin <branch-name>                    # 拉取并合并
  git fetch origin                                 # 拉取但不合并
  git push --tags                                  # 推送所有标签

合并与变基
  git merge <branch-name>                          # 合并分支
  git merge --squash <branch-name>                 # 压缩合并
  git rebase <branch-name>                         # 变基到目标分支
  git rebase -i HEAD~n                             # 交互式变基最近 n 次提交

撤销与恢复
  git reset <file>                                 # 从暂存区移除，保留工作区更改
  git reset HEAD^                                  # 撤销提交，保留更改
  git reset --hard HEAD                            # 丢弃所有未提交更改
  git reset --hard <commit-id>                     # 回退到指定提交
  git revert <commit-id>                           # 创建新提交撤销指定提交
  git stash                                        # 暂存未提交更改
  git stash pop                                    # 恢复暂存内容
  git restore <file>                               # 丢弃工作区更改

查看历史与差异
  git log                                          # 完整提交历史
  git log --oneline                                # 简洁单行历史
  git log --graph --all                            # 图形化显示所有分支
  git diff                                         # 未暂存的更改
  git diff --staged                                # 已暂存的更改
  git diff <commit-id>                             # 与指定提交比较
  git blame <file>                                 # 查看每一行的修改信息

标签管理
  git tag                                          # 列出标签
  git tag <tag-name>                               # 创建轻量标签
  git tag -a <tag-name> -m "msg"                  # 创建附注标签
  git tag -d <tag-name>                            # 删除本地标签
````

= git merge, git rebase
假设初始状态：
```
      A---B---C  feature
     /
D---E---F---G  main
```

`git merge` 后：

```
      A---B---C
     /         \
D---E---F---G---H  (H 是合并提交)
```

`git rebase`（在 feature 上执行 `git rebase main`）后：

```
D---E---F---G---A'---B'---C'  (feature 移到了 G 之后，提交变成新的 A'B'C')
```

#notation[

*不要对已经推送到远程的分支执行 `rebase`*  

因为`rebase`会改写提交哈希, 如果其他人基于旧提交开发，就会产生大量冲突和混乱

- 公共分支（如 `main`）用 `merge`。
- 私有分支（尚未推送或仅有自己使用）可用 `rebase` 保持整洁。
]
结合使用的标准工作流

1. 在功能分支上开发若干提交。
2. 在合并到 `main` 之前，先用 `rebase` 更新你的分支：
   ```bash
   git switch feature
   git rebase main   # 将 feature 放到 main 最新之上
   ```
3. 解决冲突后，切到 `main`，再用 `merge`（但此时是 *fast-forward* 合并，因为 feature 已经基于最新 main）：
   ```bash
   git switch main
   git merge feature   # 默认会快进（无额外合并提交）
   ```

= docker

== 简单介绍
docker是一种新兴的虚拟化方式

传统虚拟机技术是虚拟出一套硬件后，在其上运行一个完整操作系统，在该系统上再运行所需应用进程；而容器内的应用进程直接运行于宿主的内核，容器内没有自己的内核，而且也没有进行硬件虚拟

#grid(
  columns: (1fr, 1.0fr),
  [
    #figure(
      image("img/traditional.png", fit: "stretch"),
      caption: [传统虚拟化]
    )
  ],
  [
    #figure(
      image("img/docker.png", fit: "stretch", height: 80pt, width: 207pt),
      caption: [docker虚拟化]
    )
  ]
)

docker的优势如下
- 更高效的利用系统资源
- 更快速的启动时间
- 一直的运行环境
- 持续交付和部署
- 更轻松的迁移
- 更轻松的维护和扩展

== docker基本概念
#table(
  columns: (1.9fr, 3fr, 3fr),
  align: (left, left, left),
  stroke: (x, y) => if y == 0 { 2pt } else { 0.5pt },
  fill: (x, y) => if y == 0 { rgb("#eee") } else { none },
  [*概念*], [*说明*], [*生活类比*],
  [镜像（Image）], [只读的“蓝图/模板”，包含程序及运行环境。], [像一张 CD / ISO 安装盘。],
  [容器（Container）], [镜像的运行实例，可启动、停止、删除。], [把 CD 放进光驱读盘运行的“运行态”。],
  [仓库（Repository）], [存放镜像的云端或私有场所（如 Docker Hub）。], [像 App Store / Maven 中央仓库。],
  [Dockerfile], [构建镜像的文本指令脚本。], [像菜谱，描述怎么做这个“镜像”。],
)

=== docker image 
几个特点
- *只读模板*：包含操作系统文件、运行时环境、应用代码和依赖。
- *分层结构（Layer）*：镜像由多个只读层堆叠而成。每一层对应 Dockerfile 中的一条指令, 使得*增量构建*和*共享存储*非常高效。
- *UnionFS（联合文件系统）*：把这些层联合挂载成一个统一的文件系统视图。容器启动时，会在这些只读层上*覆盖一个可写层（容器层）*，所有修改都写入该层，原镜像不受影响（写时复制，CoW）。


Docker 镜像是一个#text(fill: blue)[特殊的文件系统]，除了提供容器运行时所需的程序、库、资源、配置等文件外，还包含了一些为运行时准备的一些配置参数（如匿名卷、环境变量、用户等）。
=== docker container
容器的#text(fill: blue)[实质是进程]，但与直接在宿主执行的进程不同，容器进程运行于属于自己的独立的#text(fill: blue)[命名空间]

因此容器可以拥有自己的`root`文件系统、自己的网络配置、自己的进程空间，甚至自己的用户ID 空间

容器内的进程是运行在一个隔离的环境里, 因此也更加安全

容器存储层要保持无状态化。所有的文件写入操作，都应该使用#text(fill: blue)[数据卷（Volume）]、或者绑定宿主目录

数据卷的生存周期独立于容器，容器消亡，数据卷不会消亡。

== dockerfiles

Dockerfile 是一个文本文件，其内包含了一条条的#text(fill: blue)[指令(Instruction)]，每一条指令构建一层，因此每一条指令的内容，就是描述该层应当如何构建。

一个示例如下, 这里使用只使用一个`RUN`指令是为了只构建一层

````Dockerfile
FROM debian:jessie
RUN buildDeps='gcc libc6-dev make' \
    && apt-get update \
    && apt-get install -y $buildDeps \
    && wget -O redis.tar.gz "http://download.redis.io/releases/redis-3.2.5.tar.gz" \
    && mkdir -p /usr/src/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && rm -rf /var/lib/apt/lists/* \
    && rm redis.tar.gz \
    && rm -r /usr/src/redis \
    && apt-get purge -y --auto-remove $buildDeps
````
