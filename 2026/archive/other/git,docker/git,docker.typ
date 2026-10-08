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

#pagebreak()

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

#pagebreak()

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

== 常用命令另速查表

````docker
【镜像操作】
  docker pull <镜像名>[:标签]      # 拉取镜像
  docker images                    # 查看本地镜像列表
  docker rmi <镜像ID>              # 删除镜像
  docker build -t <名称>:<标签> .  # 构建镜像

【容器操作】
  docker run -d -p 8080:80 <镜像>   # 后台运行容器，映射端口
  docker run -it <镜像> /bin/bash   # 交互式运行（进入容器内部）
  docker ps                         # 查看运行中的容器
  docker ps -a                      # 查看所有容器（含已停止）
  docker stop <容器ID>              # 停止容器
  docker start <容器ID>             # 启动已停止的容器
  docker rm <容器ID>                # 删除已停止的容器
  docker rm -f <容器ID>             # 强制删除运行中的容器
  docker logs -f <容器ID>           # 实时查看容器日志
  docker exec -it <容器ID> /bin/bash # 进入正在运行的容器内部

【网络与卷】
  docker network create <网络名>    # 创建网络
  docker volume create <卷名>       # 创建数据卷

【清理】
  docker system prune               # 清理停止的容器、虚悬镜像等
  docker system prune -a            # 更彻底清理（含所有未使用镜像）
````

== docker三劍客

#notation[

Docker 1.12.0+ Swarm mode 已经内嵌入 Docker 引擎，成为了 docker 子命令docker swarm 
]

- Compose 项目是 Docker 官方的开源项目，负责实现对 Docker 容器集群的快速编排
- Docker Machine 是 Docker 官方编排（Orchestration）项目之一，负责在多种平台上快速安装 Docker 环境。
- Docker Swarm 提供 Docker 容器集群服务，是 Docker 官方对容器云生态进行支持的核心方案。

#pagebreak()

= 底层实现的简单介绍

== C/S基本架构


#grid(
  columns: (1.0fr, 1.0fr),
  [
    #set text(size: 13pt)
    - Docker 采用了 `C/S` 架构，包括客户端和服务端。
    - Docker 守护进程一般在宿主主机后台运行，等待接收来自客户端的消息。
    - Docker 客户端则为用户提供一系列可执行命令，用户用这些命令实现跟 Docker 守护进程交互。    
  ],
  [
    #figure(
      image("img/docker_arch.png"),
      caption: [docker C/S 架构]
    )
  ]
)

== 命名空间
每个容器都有自己单独的命名空间，运行在其中的应用都像是在独立的操作系统中运行一样。

=== pid 命名空间
不同用户的进程就是通过 pid 命名空间隔离开的，且不同命名空间中可以有相同 pid。

=== net 命名空间
网络端口是共享 host 的端口, 网络隔离是通过另外通过 net 命名空间实现的， 每个 net 命名空间有独立的网络设备, IP 地址, 路由表, /proc/net 目录。

=== ipc 命名空间
容器中进程交互还是采用了 Linux 常见的进程间交互方法(interprocess communication - IPC),包括信号量、消息队列和共享内存等。

容器的进程间交互实际上是host 上具有相同 pid 命名空间中的进程间交互，所以需要在 IPC 资源申请时加入命名空间信息，每个 IPC 资源有一个唯一的 32 位 id。

=== mnt 命名空间
mnt 命名空间允许不同命名空间的进程看到的文件结构不同，这样每个命名空间 中的进程所看到的文件目录就被隔离开了。

=== uts 命名空间
UTS("UNIX Time-sharing System") 命名空间允许每个容器拥有独立的 hostname 和 domainname, 使其在网络上可以被视作一个独立的节点而非 主机上的一个进程。

=== user 命名空间
每个容器可以有不同的用户和组 id, 也就是说可以在容器内用容器内部的用户执行程序而非主机上的用户。

== other
下面不做介绍(书中讲的也很浅)
- 控制组
- 联合文件系统
- 容器格式
- 网络


#pagebreak()

= Kubernetes
建于 Docker 之上的 Kubernetes 可以构建一个容器的调度服务.

可以透过 Kubernetes 集群来进行云端容器集群的管理，而无需进行复杂的设置工作.

== quick start
Kubernetes 依赖 *Etcd 服务* 来维护所有主节点的状态。

下面是单节点使用 Docker 快速部署一套 Kubernetes 的拓扑。

#image("img/example.png")

== basic concept

#image("img/basic.png")

- 节点（Node）：一个节点是一个运行 Kubernetes 中的主机。
- 容器组（Pod）：一个 Pod 对应于由若干容器组成的一个容器组，同个组内的容器共享一个存储卷(volume)。
- 容器组生命周期（pos-states）：包含所有容器状态集合，包括容器组状态类型，容器组生命周期，事件，重启策略，以及 replication controllers。
- Replication Controllers：主要负责指定数量的 pod 在同一时间一起运行。
- 服务（services）：一个 Kubernetes 服务是容器组逻辑的高级抽象，同时也对外提供访问容器组的策略。
- 卷（volumes）：一个卷就是一个目录，容器对其有访问权限。
- 标签（labels）：标签是用来连接一组对象的，比如容器组。标签可以被用来组织和选择对象。
- 接口权限（accessing_the_api）：端口，IP 地址和代理的防火墙规则。
- web 界面（ux）：用户可以通过 web 界面操作 Kubernetes。
- 命令行操作（cli）：kubectl 命令。

== kubectl

````kubectl
【查看状态】
  kubectl get nodes                    # 查看所有节点
  kubectl get pods                     # 查看当前命名空间的 Pod
  kubectl get pods -o wide             # 查看 Pod 详细信息（IP、节点）
  kubectl get pods -A                  # 查看所有命名空间的 Pod
  kubectl get deployments              # 查看 Deployment
  kubectl get services                 # 查看 Service
  kubectl get all                      # 查看当前命名空间所有资源
  kubectl describe pod <pod名>         # 查看 Pod 详细状态和事件

【创建与更新】
  kubectl apply -f <文件.yaml>          # 创建或更新资源（最常用）
  kubectl create -f <文件.yaml>         # 创建资源（已存在会报错）
  kubectl delete -f <文件.yaml>         # 删除资源
  kubectl set image deploy/<名称> <容器>=<新镜像>  # 更新 Deployment 镜像
  kubectl rollout status deploy/<名称>  # 查看滚动更新状态
  kubectl rollout undo deploy/<名称>    # 回滚到上一个版本

【进入与调试】
  kubectl logs <pod名>                  # 查看 Pod 日志
  kubectl logs -f <pod名>               # 实时跟踪日志
  kubectl exec -it <pod名> -- /bin/bash # 进入 Pod 容器（交互式 shell）
  kubectl port-forward <pod名> 8080:80  # 端口转发到 Pod（本地调试用）

【命名空间】
  kubectl get ns                        # 查看所有命名空间
  kubectl -n <命名空间> <命令>            # 指定命名空间执行命令
  kubectl config set-context --current --namespace=<命名空间>  # 切换默认命名空间

【删除】
  kubectl delete pod <pod名>            # 删除 Pod（会被控制器重建）
  kubectl delete deploy <名称>          # 删除 Deployment
  kubectl delete svc <名称>             # 删除 Service

【节点维护】
  kubectl cordon <节点名>              # 标记节点不可调度
  kubectl drain <节点名>               # 驱逐节点上的 Pod（维护用）
  kubectl uncordon <节点名>            # 恢复节点可调度

【资源占用（with metrics-server）】
  kubectl top nodes                    # 查看节点资源使用
  kubectl top pods                     # 查看 Pod 资源使用

【常用技巧】
  # 快速重启 Deployment
  kubectl rollout restart deploy/<名称>

  # 强制删除 Pod
  kubectl delete pod <pod名> --force --grace-period=0

  # 导出资源 YAML
  kubectl get pod <pod名> -o yaml > backup.yaml
````
