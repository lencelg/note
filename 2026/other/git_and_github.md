- [Git Introduction](#git-introduction)
  - [Basic Commands](#basic-commands)
    - [Configuration](#configuration)
    - [Create and Clone Repositories](#create-and-clone-repositories)
    - [Check Status and Diff](#check-status-and-diff)
    - [Add and Commit](#add-and-commit)
    - [Branches](#branches)
    - [Merge](#merge)
    - [Remote Repositories](#remote-repositories)
    - [Pull and Push](#pull-and-push)
    - [Undo and Reset](#undo-and-reset)
    - [Stash](#stash)
    - [Tags](#tags)
    - [Common Workflow Example](#common-workflow-example)
- [Git Merge Strategies](#git-merge-strategies)
  - [Fast-Forward](#fast-forward)
    - [Before Merge](#before-merge)
    - [Command](#command)
    - [After Merge](#after-merge)
  - [Non-Fast-Forward](#non-fast-forward)
    - [Before Merge](#before-merge-1)
    - [Command](#command-1)
    - [After Merge](#after-merge-1)
  - [Rebase](#rebase)
    - [Before Merge](#before-merge-2)
    - [Command](#command-2)
    - [After Rebase](#after-rebase)
  - [Squash](#squash)
    - [Before Merge](#before-merge-3)
    - [Command](#command-3)
    - [After Merge](#after-merge-2)
  - [Cherry-Picking](#cherry-picking)
    - [Before Merge](#before-merge-4)
    - [Command](#command-4)
    - [After Merge](#after-merge-3)
  - [Comparison Table](#comparison-table)
- [Github Introduction](#github-introduction)
  - [Core Functionalities](#core-functionalities)
  - [Use Cases](#use-cases)
- [Collaboration on GitHub](#collaboration-on-github)
  - [Two Basic Collaboration Modes](#two-basic-collaboration-modes)
    - [Collaborators](#collaborators)
    - [Fork + Pull Request](#fork--pull-request)
  - [Core Collaboration Components](#core-collaboration-components)
    - [Repository](#repository)
    - [Branch](#branch)
    - [Issue](#issue)
    - [Pull Request](#pull-request)
    - [Code Review](#code-review)
    - [Discussions](#discussions)
  - [Communication Tools](#communication-tools)
  - [Classic Team Workflow](#classic-team-workflow)
  - [Open-sources Collaboration Workflow](#open-sources-collaboration-workflow)
- [Github Actions](#github-actions)
  - [Core Concepts](#core-concepts)
  - [A Simple Example](#a-simple-example)
  - [Common Use Cases](#common-use-cases)
  - [Pros](#pros)
  - [Cons](#cons)
- [Git Hooks and GitHub Webhooks](#git-hooks-and-github-webhooks)
  - [Git Hooks](#git-hooks)
  - [GitHub Webhooks](#github-webhooks)
- [Github Advanced Features](#github-advanced-features)

# Git Introduction

git是版本控制工具

.gitignore管理git追踪文件的规则

## Basic Commands

Git 的基本命令可以按日常开发流程来记忆。

git核心的日常命令：

```bash
git clone
git status
git add
git commit
git pull
git push
git branch
git switch
git merge
git log
git diff
git stash
```

### Configuration

```bash
# 设置用户名和邮箱（全局）
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"

# 查看配置
git config --list

# 设置默认编辑器
git config --global core.editor "vim"
```

### Create and Clone Repositories

```bash
git init
git clone <url>

# 克隆到指定目录
git clone <url> myproject

# 克隆并递归初始化子模块
git clone --recurse-submodules <url>
```

### Check Status and Diff

```bash
# 查看当前状态
git status

# 查看未暂存的修改
git diff

# 查看已暂存的修改
git diff --staged

# 查看提交历史
git log

# 简洁历史
git log --oneline

# 图形化历史
git log --oneline --graph --decorate --all
```

### Add and Commit

```bash
git add file

# 添加所有已跟踪文件的修改
git add -u

# 提交
git commit -m "提交信息"

# 添加并提交（已跟踪文件）
git commit -am "提交信息"

# 修改最近一次提交
git commit --amend
```
### Branches

```bash
# 查看分支
git branch

# 查看所有分支（包括远程）
git branch -a

# 创建分支
git branch feature

# 切换分支
git checkout feature
# 或现代写法
git switch feature

# 创建并切换
git checkout -b feature
# or
git switch -c feature

# 删除分支
git branch -d feature

# 强制删除
git branch -D feature

# 重命名分支
git branch -m new-name
```

### Merge
```bash
# 把 feature 合并到当前分支
git merge feature

# 禁用快进，生成合并提交
git merge --no-ff feature

# 只允许快进
git merge --ff-only feature

# 中断合并
git merge --abort
```

### Remote Repositories

```bash
# 查看远程
git remote -v

# 添加远程
git remote add origin <url>

# 修改远程 URL
git remote set-url origin <new-url>

# 删除远程
git remote remove origin
```

### Pull and Push

```bash
# 拉取远程更新并合并
git pull

# 拉取指定分支
git pull origin main

# 拉取并变基
git pull --rebase

# 只拉取，不合并
git fetch

# 推送
git push

# 首次推送并设置上游
git push -u origin main

# 推送所有分支
git push --all origin

# 推送标签
git push --tags
```

### Undo and Reset

```bash
# 撤销工作区修改（未暂存）
git checkout -- file.txt
# 或
git restore file.txt

# 取消暂存
git reset HEAD file.txt
# 或
git restore --staged file.txt

# 撤销最近一次提交，保留修改在暂存区
git reset --soft HEAD~1

# 撤销最近一次提交，保留修改在工作区
git reset HEAD~1

# 彻底回退到某个提交（危险）
git reset --hard <commit>

# 创建一个反向提交来撤销某个提交（安全）
git revert <commit>
```

### Stash

```bash
# 暂存当前修改
git stash

# 查看暂存列表
git stash list

# 恢复最近一次暂存并删除记录
git stash pop

# 恢复但不删除记录
git stash apply

# 删除暂存
git stash drop
```

### Tags

```bash
# 查看标签
git tag

# 创建轻量标签
git tag v1.0.0

# 创建附注标签
git tag -a v1.0.0 -m "版本 1.0.0"

# 推送标签
git push origin v1.0.0
git push origin --tags

# 删除本地标签
git tag -d v1.0.0

# 删除远程标签
git push origin --delete v1.0.0
```

### Common Workflow Example

```bash
# 1. 克隆仓库
git clone <url>
cd repo

# 2. 创建功能分支
git switch -c feature-login

# 3. 修改代码
git status
git diff
git add .
git commit -m "feat: add login"

# 4. 同步主分支
git switch main
git pull

# 5. 合并功能分支
git switch feature-login
git rebase main
git switch main
git merge feature-login

# 6. 推送
git push origin main
```

# Git Merge Strategies

## Fast-Forward

快进合并只适用于 **当前分支没有新提交** 的情况。  

假设 `main` 停在 `B`，`feature` 有 `D`、`E`：

### Before Merge

```text
A---B  main
     \
      D---E  feature
```

### Command

```bash
git checkout main
git merge feature
```

### After Merge

```text
A---B---D---E  main, feature
```

`main` 指针直接向前移动到 `E`，没有产生新的合并提交，历史是一条直线。

## Non-Fast-Forward

如果 `main` 有自己的新提交 `C`，就不能快进，会生成一个合并提交。

### Before Merge

```text
A---B---C  main
     \
      D---E  feature
```

### Command

```bash
git checkout main
git merge --no-ff feature
```

### After Merge

```text
A---B---C-------M  main
     \         /
      D---E----  feature
```

`M` 是合并提交，有两个父提交：`C` 和 `E`。

保留了分支历史，能清楚看到“这里合并了一个功能分支”。  

如果只想在能快进时也强制生成合并提交，用 `--no-ff`。

## Rebase

Rebase 把 `feature` 的提交“搬到” `main` 的最新提交之后，重写历史。

### Before Merge

```text
A---B---C  main
     \
      D---E  feature
```

### Command

```bash
git checkout feature
git rebase main
```

### After Rebase

```text
A---B---C  main
         \
          D'---E'  feature
```

`D`、`E` 被替换为 `D'`、`E'`，哈希值改变，历史变成线性。

之后通常再快进 `main`：

```bash
git checkout main
git merge feature   # 此时可以快进
```

最终：

```text
A---B---C---D'---E'  main, feature
```

历史线性、干净，但重写了 `feature` 的提交哈希。  

**不要对已经推送到公共分支的提交做 rebase。**

## Squash

Squash 把 `feature` 上的所有提交压缩成一个提交，再合并到 `main`。

### Before Merge

```text
A---B---C  main
     \
      D---E  feature
```

### Command

```bash
git checkout main
git merge --squash feature
git commit -m "feat: add feature X"
```

### After Merge

```text
A---B---C---S  main
```

`S` 包含了 `D` 和 `E` 的全部改动，但只有一个提交，没有合并提交，`feature` 的详细历史被丢弃。

主分支历史非常干净，适合一个功能分支有很多琐碎提交的情况。

## Cherry-Picking

只把 `feature` 上的某一个提交（例如 `E`）复制到 `main`。

### Before Merge

```text
A---B---C  main
     \
      D---E  feature
```

### Command

```bash
git checkout main
git cherry-pick E
```

### After Merge

```text
A---B---C---E'  main
     \
      D---E  feature
```

`E'` 是 `E` 的副本，内容相同，哈希不同。`D` 没有被带过来。

灵活，但容易产生重复提交，后续合并可能冲突。

## Comparison Table

| 策略 | 合并前 | 合并后 | 是否重写历史 | 典型场景 |
|---|---|---|---|---|
| Fast-Forward | `main` 停在分叉点 | 指针直接前移，线性 | 否 | 本地小分支 |
| Non-FF | `main` 有新提交 | 生成合并提交 `M` | 否 | 保留功能分支记录 |
| Rebase | 分叉 | 线性，提交哈希改变 | 是 | 整理本地历史 |
| Squash | 分叉 | 压缩成一个提交 `S` | 是（对 feature） | 主分支保持干净 |
| Cherry-pick | 分叉 | 只复制某个提交 | 否（生成新提交） | 挑单个修复 |
| 冲突处理 | 任意 | 解决后继续 | 取决于操作 | 所有集成方式 |

# Github Introduction

GitHub 是托管 Git 仓库的在线平台，并围绕它提供了完整的开发者协作生态。

GitHub 是一个基于 Web 的 Git 仓库托管平台，用于代码托管、版本控制和团队协作。它让开发者可以把 Git 仓库放到云端，方便多人协作、代码审查、问题追踪和自动化。

## Core Functionalities

| 功能 | 说明 |
|---|---|
| **仓库（Repository）** | 存放项目代码、历史、分支 |
| **分支（Branch）** | 并行开发，不影响主分支 |
| **Pull Request（PR）** | 请求合并代码，支持审查和讨论 |
| **Issue** | 记录 Bug、任务、需求 |
| **Actions** | CI/CD 自动化，测试、构建、部署 |
| **Projects** | 项目管理，看板、表格、路线图 |
| **Wiki** | 项目文档 |
| **Pages** | 免费静态网站托管 |
| **Packages** | 包托管，npm、Maven、Docker 等 |
| **Copilot** | AI 编程助手 |
| **Codespaces** | 云端开发环境 |
| **Security** | 依赖扫描、代码扫描、秘密扫描 |
| **Sponsors** | 接受赞助，支持开源维护者 |

## Use Cases

- **开源项目**：托管代码，接受外部贡献。
- **团队协作**：分支开发，PR 审查，Issue 跟踪。
- **CI/CD**：用 GitHub Actions 自动测试、构建、部署。
- **文档与网站**：用 GitHub Pages 发布静态网站。
- **包管理**：用 GitHub Packages 发布库。
- **学习与作品集**：展示代码，参与开源。
- **企业开发**：私有仓库、权限控制、安全扫描。

# Collaboration on GitHub

GitHub 的协作核心是：**围绕一个远程 Git 仓库，多人通过分支、Issue、Pull Request、评论和审查来共同开发、讨论和合并代码。**

## Two Basic Collaboration Modes

### Collaborators
适用于团队内部、私有仓库或有写入权限的人。

- 被添加为协作者后，可以直接向仓库推送分支。
- 通常从主仓库拉分支，开发完发 Pull Request。
- 适合公司团队、内部项目。

流程：
```text
克隆仓库 → 创建分支 → 开发 → push 分支 → 发起 PR → 审查 → 合并
```

### Fork + Pull Request

适用于开源项目、外部贡献者、没有写入权限的人。

- 先 Fork 原仓库到自己账号下。
- 克隆自己的 Fork，开发并推送。
- 向原仓库发起 Pull Request。
- 维护者审查后决定是否合并。

流程：
```text
Fork 原仓库 → 克隆自己的 Fork → 创建分支 → 开发 → push → 向原仓库发 PR → 审查 → 合并
```

## Core Collaboration Components

### Repository

项目的中心，存放代码、历史、分支、标签、Issue、PR 等。

### Branch
每个人在自己的分支上开发，避免直接修改主分支。

常见约定：
- `main` / `master`：稳定主分支
- `develop`：开发分支
- `feature/xxx`：功能分支
- `fix/xxx`：修复分支
- `release/xxx`：发布分支

### Issue
用来记录 Bug、需求、任务、讨论。

可以：
- 分配负责人
- 打标签
- 设置里程碑
- 关联 PR
- 引用其他 Issue

### Pull Request
请求把一个分支的改动合并到另一个分支， 是 GitHub 协作的核心。

PR 中可以：
- 查看代码差异
- 评论、审查
- 请求修改
- 运行 CI
- 关联 Issue
- 合并或关闭

### Code Review
在 PR 中，其他成员可以：
- 评论某一行代码
- 提出修改建议
- 批准或请求修改
- 使用 `Suggest change` 直接建议代码

### Discussions
比 Issue 更开放的论坛式空间，适合：
- Q&A
- 公告
- 想法讨论
- 社区交流

## Communication Tools

| 工具 | 作用 |
|---|---|
| **Commenting** | 在 Issue/PR 下讨论 |
| **Labelling** | 给 Issue/PR 分类，如 `bug`、`enhancement` |
| **Saved Replies** | 保存常用回复模板，提高效率 |
| **Projects** | 看板、表格、路线图管理任务 |
| **Milestones** | 按版本或目标分组 Issue/PR |
| **Notifications** | 订阅和接收更新 |

## Classic Team Workflow

```text
1. 从 main 拉最新代码
2. 创建功能分支 feature/login
3. 开发并提交
4. push 到远程
5. 发起 Pull Request
6. 指定审查者
7. CI 自动运行测试
8. 审查者评论、请求修改
9. 修改后再次 push
10. 审查通过，合并到 main
11. 删除功能分支
```

命令示例：
```bash
git switch main
git pull
git switch -c feature/login

# 开发...
git add .
git commit -m "feat: add login"
git push -u origin feature/login
```

然后在 GitHub 网页上创建 PR。

## Open-sources Collaboration Workflow

```text
1. Fork 原仓库
2. 克隆自己的 Fork
3. 添加上游仓库 upstream
4. 同步 upstream/main
5. 创建分支开发
6. push 到自己的 Fork
7. 向原仓库发起 PR
8. 维护者审查、讨论
9. 合并或关闭
```

命令示例：
```bash
git clone https://github.com/yourname/repo.git
cd repo
git remote add upstream https://github.com/original/repo.git

git fetch upstream
git switch main
git merge upstream/main

git switch -c fix/bug-123
# 开发...
git push origin fix/bug-123
```

# Github Actions

**GitHub Actions** 是 GitHub 内置的 **CI/CD 和自动化平台**

可以在仓库里用 YAML 定义“工作流”，让 GitHub 在特定事件发生时自动执行任务，比如测试、构建、部署、发通知等。

## Core Concepts

| 概念 | 含义 |
|---|---|
| **Workflow（工作流）** | 一个自动化流程，定义在 `.github/workflows/*.yml` |
| **Event（事件）** | 触发条件，如 `push`、`pull_request`、`schedule`、`workflow_dispatch` |
| **Job（任务）** | 工作流中的一个执行单元，可并行或串行 |
| **Step（步骤）** | Job 中的一步，执行命令或调用 Action |
| **Action（动作）** | 可复用的自动化单元，如 `actions/checkout` |
| **Runner（运行器）** | 执行 Job 的机器，GitHub 托管或自托管 |

## A Simple Example

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt
      - run: pytest
```

## Common Use Cases

- **CI**：自动跑测试、lint、类型检查。
- **CD**：构建 Docker 镜像、部署到服务器或云平台。
- **发布**：打标签时自动创建 GitHub Release。
- **代码质量**：依赖扫描、安全扫描、自动评论 PR。
- **自动化任务**：定时清理、发通知、管理 Issue。
- **静态网站部署**：构建并发布到 GitHub Pages。

## Pros

- 与 GitHub 深度集成，无需额外 CI 服务。
- 公共仓库免费，私有仓库有免费额度。
- 支持 Linux、Windows、macOS。
- Marketplace 有大量现成 Action。
- 支持矩阵构建、缓存、Secrets、自托管 Runner。

## Cons

- 复杂 YAML 可能难维护。
- 调试不如本地方便。
- 私有仓库超出免费额度需付费。
- 对超大型项目，性能可能不如专用 CI。

# Git Hooks and GitHub Webhooks

“hooks” 有两种常见含义
- **Git 自带的本地钩子（Git Hooks）**
- **GitHub 平台的事件回调（GitHub Webhooks）**。

## Git Hooks

Git 在仓库的关键动作前后，会自动执行 `.git/hooks/` 目录下的脚本，这些脚本就是 hooks。

| 钩子 | 触发时机 |
|---|---|
| `pre-commit` | `git commit` 之前，可用来跑 lint / 格式化，非 0 退出则提交被阻止 |
| `prepare-commit-msg` | 生成提交信息前，可预填模板 |
| `commit-msg` | 提交信息写好后，可校验格式（如 Conventional Commits） |
| `post-commit` | 提交完成后，做通知之类的收尾 |
| `pre-push` | `git push` 之前，可跑测试 |
| `pre-rebase` | rebase 之前 |
| `post-checkout` / `post-merge` | 切换分支 / 合并后 |

关键点：

- 仓库初始化时，`.git/hooks/` 里只有 `*.sample` 示例文件，**默认不生效**；去掉 `.sample` 后缀并 `chmod +x` 才启用。
- **hooks 不进版本控制**，`git clone` 不会带给别人，所以要通过 `core.hooksPath` 或 husky、pre-commit 这类工具来共享。
- 因为是本地脚本，**可以被 `--no-verify` 跳过**，只能算“提醒/约束”，不能当作安全边界。

```bash
# 把 hooks 目录指到仓库内（可提交、团队共享）
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit

# 跳过钩子
git commit --no-verify
```

## GitHub Webhooks

在仓库 / 组织 / GitHub App 的设置页配置：**当某个事件发生，GitHub 主动向指定 URL 发一个 HTTP POST**，body 是 JSON payload。

- 触发事件：`push`、`pull_request`、`issues`、`release`、`workflow_run`、`star` 等。
- 典型用途：通知 Slack / Discord、触发 Jenkins 或自建 CI、同步到其他系统、更新部署面板。
- 安全：配置 `secret` 后，请求头带 `X-Hub-Signature-256`，接收方用 HMAC-SHA256 校验，防止伪造。
- 每次投递有记录，失败会重试，`ping` 事件用于测试连通性。

# Github Advanced Features

- Github Packages — 包托管（npm、Maven、NuGet、Docker/GHCR）
- Github Codespaces — 云端开发环境，浏览器里写代码
- Github Copilot — AI 编程助手
- Github Copilot Chat — 对话式编程助手
- Github Copilot Code Review — AI 自动审查 PR
- Github Models — 在平台内试用和调用各种大模型
- Github Spark — 用自然语言构建小应用
- Github CLI（`gh`）— 命令行操作 GitHub
- Github Pages — 静态网站托管
- Github Actions — CI/CD 与自动化
- Github Marketplace — Actions、Apps 的应用市场
- Github Apps — 官方推荐的集成应用形式
- OAuth Apps — 传统第三方授权应用
- Github Discussions — 论坛式讨论区
- Github Projects — 看板、表格、路线图
- Github Wiki — 项目文档
- Github Releases — 发布版本、附带构建产物
- Github Container Registry（GHCR）— Docker 镜像仓库
- Github Advanced Security — 代码扫描、秘密扫描
- Dependabot — 依赖更新与漏洞告警
- Code Scanning（CodeQL）— 静态代码安全分析
- Secret Scanning — 检测泄露的密钥
- Code Search — 全站代码搜索
- Rulesets — 分支/标签保护规则集
- Branch Protection Rules — 分支保护
- CODEOWNERS — 按路径指定审查者
- Merge Queue — 合并队列，保证主分支始终通过 CI
- Environments & Secrets — 部署环境与密钥管理
- OIDC — 免长期密钥的云厂商认证
- Self-hosted Runners — 自托管 Actions 运行器
- Issue / PR Templates — 模板
- Labels & Milestones — 标签、里程碑
- Sub-issues — 子任务
- Tasklists — Issue 内任务清单
- Gists — 代码片段分享
- Github Sponsors — 赞助开源维护者
- Github Classroom — 教学与作业管理
- Github Enterprise — 企业版（云 / 自托管）
- Enterprise Managed Users（EMU）— 企业统一账号管理
- Dev Containers — 开发容器配置
- Github Certifications — 官方认证考试
