# nvim

重新打开vim tutor进行学习

- d$ 删除直到行尾的内容
- de 删除直到单词的末尾，但是不包含最后一个字符
- U 和 <C-r>
- ce 和 c$
- 输入 `<C-g>`{normal} 来显示你在文件中的位置和文件状态。
- 输入 `{count}G`{normal} 来移动到文件中的第 {count} 行。
- 要反向搜索一个短语，使用 [?](?) 而不是 `/`{normal}。
- 输入 `%`{normal} 来查找匹配的 ), ], }。


输入 `:%s/old/new/g` 可以在整个文件中进行替换。

输入 `:%s/old/new/gc` 可以在整个文件中查找所有出现，并对每一次替换进行确认。

```
NOTE: 你也可以读取一个外部命令的输出。例如：

        `:r !ls`{vim}

      会读取 `ls` 命令的输出，并将其放在光标下方。
```

- :w 文件名              将当前 Neovim 文件以“文件名”这个名字写入磁盘。
- v  移动  :w 文件名     将可视模式选中的行保存到文件“文件名”中。
- :r 文件名              读取磁盘文件“文件名”的内容，并将其放在光标位置的下方。
- :r !ls                 读取 ls 命令的输出，并将其放在光标位置的下方。

Q 添加一个光标，可以进行多光标编辑

## Editing more than one file

For example:

```vim
vim one.c two.c three.c
```

This command starts Vim and tells it that you will be editing three files. Vim displays just the first file. 

After you have done your thing in this file, to edit the next file you use this command:

```vim
:next
```

If you have unsaved changes in the current file, you will get an error message and the ":next" will not work. 

This is the same problem as with ":edit" mentioned in the previous section. To abandon the changes:

```vim
:next!
```

But mostly you want to save the changes and move on to the next file. There is a special command for this:

```vim
:wnext
```

This does the same as using two separate commands:

```vim
:write
:next
```

WHERE AM I?

To see which file in the argument list you are editing, look in the window title. It should show something like "(2 of 3)". This means you are editing the second file out of three files.

If you want to see the list of files, use this command:

````vim
:args
````

This is short for "arguments".  The output might look like this:

````vim
one.c [two.c] three.c
````

These are the files you started Vim with.  The one you are currently editing, "two.c", is in square brackets.

To go back one file:

```vim
:previous
```

This is just like the ":next" command, except that it moves in the other
direction.  Again, there is a shortcut command for when you want to write the
file first:

```vim
:wprevious
```

To move to the very last file in the list:
```vim :last
```

And to move back to the first one again:

```vim
:first
```

There is no ":wlast" or ":wfirst" command though!

You can use a count for ":next" and ":previous".  To skip two files forward:

```vim
:2next
```

To quickly *jump between two files*, press `CTRL-^` (on English-US keyboards the `^` is above the 6 key).

## split windows
Neovim 的窗口操作核心快捷键前缀是 `Ctrl + w`

### 1. 创建分屏 (Split)
你可以通过命令或快捷键来创建分屏：

*   **上下分屏（水平分割）**
    *   命令：`:split` 或 `:sp` （可跟文件名，如 `:sp file2.txt`）
    *   快捷键：`Ctrl + w` 然后按 `s`
*   **左右分屏（垂直分割）**
    *   命令：`:vsplit` 或 `:vsp` （可跟文件名，如 `:vsp file3.txt`）
    *   快捷键：`Ctrl + w` 然后按 `v`
*   **在新分屏中打开当前行/光标下的文件**
    *   快捷键：`Ctrl + w` 然后按 `Ctrl + ]`

### 2. 在分屏间移动 (Navigation)
创建分屏后，你的光标需要在这些窗口间穿梭：

*   **向指定方向移动**（最常用）：
    *   `Ctrl + w` 然后按 `h`（向左）
    *   `Ctrl + w` 然后按 `j`（向下）
    *   `Ctrl + w` 然后按 `k`（向上）
    *   `Ctrl + w` 然后按 `l`（向右）
*   **循环切换**：`Ctrl + w` 然后按 `w`（在所有窗口间按顺序切换）
*   **切换到上一个窗口**：`Ctrl + w` 然后按 `p`

### 3. 调整窗口大小 (Resize)
*   增加高度：`Ctrl + w` 然后按 `+` (或 `=`)
*   减少高度：`Ctrl + w` 然后按 `-`
*   增加宽度：`Ctrl + w` 然后按 `>`
*   减少宽度：`Ctrl + w` 然后按 `<`
*   **所有窗口等宽等高**：`Ctrl + w` 然后按 `=` (等号)

### 4. 移动与重排窗口 (Move)
*   **当前窗口与下一个窗口互换位置**：`Ctrl + w` 然后按 `r`
*   **把当前窗口移到最左侧/最右侧/最上方/最下方**：`Ctrl + w` 然后按 `H` / `L` / `J` / `K`（大写的 HJKL）

### 5. 关闭分屏 (Close)
*   关闭当前窗口：`:q` （如果有未保存修改用 `:q!` 或 `:wq`）
*   快捷键关闭：`Ctrl + w` 然后按 `c`
*   **只保留当前窗口（关闭其他所有分屏）**：`:only` 或快捷键 `Ctrl + w` 然后按 `o`

### 进阶
1.  **分屏后同步滚动**：在 Vim 中，分屏默认是各自独立滚动的。如果你想让两个窗口同步滚动（比如对比两个文件），可以在两个窗口分别执行 `:set scrollbind`。
2.  **`:windo` 命令**：如果你想把命令应用到所有打开的窗口，可以使用 `:windo`。比如 `:windo set wrap` 让所有窗口开启自动换行。
3.  **更现代的窗口管理插件**：
    *   **`nvim-window-picker`**：如果你觉得记住方向键太麻烦，这个插件会在每个窗口上显示一个字母，你按下对应字母就能瞬间跳转过去。
    *   **`smart-splits.nvim`**：允许你在 NeoVim 分屏和终端（如 tmux）分屏之间无缝使用 `Ctrl + h/j/k/l` 穿梭。
    

## tab split

*   **`:tab split` (或 `:tab sp`)**
    *   **作用**：将当前所在的窗口（连同正在编辑的文件），复制一份到新的 Tab 中。原来的 Tab 布局保持不变。
    *   **场景**：你正在一个非常拥挤的分屏里看代码，突然想全屏只看这个文件，但不想破坏现在的布局。
*   **`:tabnew` (或 `:tabe`)**
    *   **作用**：新建一个空的 Tab。
    *   **进阶**：你可以直接在后面跟文件名，如 `:tabnew file.txt` 或 `:tabedit file.txt`。
*   **`:tab split {file}`**
    *   **作用**：直接在新 Tab 中打开指定的文件。
*   **`:tabclose` (或 `:tabc`)**
    *   **作用**：关闭当前 Tab 及其内部的所有窗口。
*   **`:tabonly` (或 `:tabo`)**
    *   **作用**：关闭除了当前 Tab 之外的所有 Tab。

在 Tab 之间切换（快捷键）

使用普通模式下的 `g` 开头的快捷键：

*   `gt`：切换到**下一个** Tab（循环）。
*   `gT`：切换到**上一个** Tab（循环）。
*   `{数字}gt`：直接跳转到第 N 个 Tab。例如 `1gt` 跳到第一个，`3gt` 跳到第三个。
*   `Ctrl + w` 然后按 `T`：将当前所在的窗口**移动**到一个新 Tab 中（相当于关闭当前窗口并在新 Tab 打开）。

Vim 的分层：
1.  **Buffer（缓冲区）**：内存中打开的文件
2.  **Window / Split（窗口 / 分屏）**：用来查看 Buffer 的视口
3.  **Tab（标签页）**：用来装 Window 的容器（不同布局的工作区）


## 插入快速修正

在**插入模式**下，你可以使用以下按键快速修正正在输入的文本：

| 按键 | 作用 |
| :--- | :--- |
| `<BS>` (退格键) | 删除光标前的一个字符 |
| `<Del>` (删除键) | 删除光标所在位置的一个字符 |
| `CTRL-W` | 删除光标前的一个单词 |
| `CTRL-U` | 删除光标前至行首的所有内容 |

`CTRL-W` 的 W 代表 Word（单词），`CTRL-U` 的 U 代表 Up（向上，即删到行首）。

## 24.4 插入模式下的其他命令

*   `CTRL-T` 和 `CTRL-D`：
    *   在插入模式下增加或减少当前行的缩进。非常实用。
*   `CTRL-A`：
    *   插入你**上一次在插入模式中输入的文本**。比如你刚刚写了一个很长的变量名，按几下 Esc 退出再按 `i` 重新进入后，按下 `CTRL-A` 就能再次打出那个变量名。
*   `CTRL-@`：
    *   插入上一次输入的文本，**并且直接退出插入模式**。
*   `CTRL-V`：
    *   插入特殊字符。按 `CTRL-V` 然后按数字（比如 `65`），会插入对应的 ASCII 码字符（`A`）。你也可以按 `CTRL-V` 然后按 `Tab` 键，可以插入真正的制表符，防止被转换成空格。
*   `CTRL-K`：
    *   插入二合字母（Digraphs）。比如按 `CTRL-K` 然后输入 `Co`，会插入版权符号 `©`。

## 28. 折叠

当你在编辑一个很长的文件时，折叠（Folding）功能可以把一大块文本折叠成一行，让屏幕只显示你需要关注的内容，极大地提高阅读和导航的效率。

折叠是将一段连续的行隐藏起来，在屏幕上用一个占位行（如 `+-- 10 lines: ...`）代替。这不会修改文件内容，只是改变了显示方式。

Vim 提供了多种创建折叠的方式，通过 `'foldmethod'`（简写为 `fdm`）选项来设置：
*   `manual`：手动折叠（默认）。
*   `indent`：根据缩进折叠（写代码最常用）。
*   `marker`：根据特定的标记折叠（写纯文本/大纲常用）。
*   `syntax`：根据语法高亮折叠。
*   `expr`：根据自定义表达式折叠。

## 28.2 手动折叠

当 `foldmethod=manual` 时，你可以手动选择行来折叠：

1.  使用 `v` 或 `V` 选中你想要折叠的文本块。
2.  按下 **`zf`**（代表 Zip Fold）。

例如，在普通模式下输入 `3zf` 可以折叠接下来的 3 行。如果你想折叠大括号内的代码，可以把光标放在 `{` 上，输入 `zf%`。

## 28.3 打开和关闭折叠

以下快捷键用于操作光标所在的折叠：

| 按键 | 作用 |
| :--- | :--- |
| `zo` | 打开（Open）当前折叠（展开一层）。 |
| `zc` | 关闭（Close）当前折叠。 |
| `zO` | 打开当前折叠及其中**所有**嵌套的子折叠（全部展开）。 |
| `zC` | 关闭当前折叠及其中**所有**嵌套的子折叠。 |
| `za` | **切换（Toggle）** 当前折叠的状态（开着就关，关着就开）。这是最常用的快捷键。 |
| `zA` | 递归切换当前折叠的状态（包括所有子折叠）。 |

## 28.4 折叠与展开

如果你想一次性操作整个文件的所有折叠：
*   **`zr`**：减少（Reduce）折叠层级。所有折叠打开一层。
*   **`zm`**：增加（More）折叠层级。所有折叠关闭一层。
*   **`zR`**：完全展开所有折叠（相当于打开所有层级）。
*   **`zM`**：完全关闭所有折叠（相当于关闭所有层级）。
*   **`zn`**：完全禁用折叠（不显示折叠）。
*   **`zN`**：恢复折叠显示。

## 28.6 保存和恢复折叠

默认情况下，当你关闭文件时，手动创建的折叠会丢失。你可以使用 `:mkview` 和 `:loadview` 命令来保存和恢复视图（我们在第 21 章提过，视图包含了折叠状态）。
或者，在 `init.lua` 中配置自动保存视图。

## 28.7 根据缩进折叠

写代码时最常用的方式。设置 `:set foldmethod=indent`。
Vim 会根据行首的空格或 Tab 缩进来决定折叠层级。缩进相同的行会被归为同一层级。
*   `'foldlevel'` 决定了初始折叠的层级。
*   `'foldnestmax'` 限制最大折叠层数，防止嵌套过深。

## 28.8 根据标记折叠

非常适合写 Markdown 或大纲笔记。设置 `:set foldmethod=marker`。
Vim 会默认寻找 `{{{` 和 `}}}` 作为折叠的开始和结束标记。你可以自定义 `'foldmarker'` 选项。

示例：
```text
第一章 {{{
这里是内容...
这里也是内容...
}}}
```

## 删除折叠

*   **`zd`**：删除（Delete）光标下的折叠。
*   **`zD`**：递归删除当前折叠。
*   **`zE`**：删除（Eliminate）**当前窗口内的所有**手动折叠。

## 28.11 其他折叠命令

*   **`zj`** / **`zk`**：向下/向上移动到下一个/上一个折叠的开头。
*   **`[z`** / **`]z`**：移动到当前打开的折叠的开始/结束处。
*   在折叠行上按 `zy` 可以复制折叠的内容，而不需要展开它。

## 30. 编译程序

## 30.1 使用 :make 命令

你可以直接在普通模式下输入 `:make`，Vim 会在内部启动一个 Shell 来执行 `make` 命令。

```vim
:make
```

Vim 会读取当前目录下的 `Makefile`，执行编译。整个编译过程的输出会直接显示在屏幕底部的提示区，然后自动消失。

## 30.2 处理编译错误

`:make` 最大的魔力在于，Vim 能够自动解析编译器的输出（如 GCC、Clang、Cargo 等），提取出错误信息、文件名和行号，并将其存入一个叫 **Quickfix List（快速修复列表）** 的地方。

你可以使用以下命令在错误之间跳转：

| 命令 | 作用 |
| :--- | :--- |
| `:cnext` 或 `:cn` | 跳转到**下一个**错误所在的行 |
| `:cprev` 或 `:cp` | 跳转到**上一个**错误所在的行 |
| `:cfirst` | 跳转到第一个错误 |
| `:clast` | 跳转到最后一个错误 |
| `:cc` | 显示当前错误的详细信息 |
| `:clist` 或 `:cl` | 列出所有的编译错误 |

当跳转发生时，Vim 会自动打开出错的源文件，并精准地将光标定位到那行代码上，极大地省去了手动找 Bug 的时间。

## 30.3 快速修复窗口 (Quickfix)

虽然用 `:cn` 和 `:cp` 可以逐个看错误，但为了更好的体验，你可以打开专门展示错误列表的窗口：

```vim
:copen
```
这会从屏幕底部弹出一个水平分割的窗口，里面列出了所有的报错详情（文件名、行号、错误信息）。
*   在这个窗口里，用 `j` 和 `k` 移动光标。
*   按 `<Enter>`（回车）键，上方的代码窗口就会自动跳转并打开光标所指的错误处。
*   用完之后，输入 `:cclose` 即可关闭这个列表窗口。

## 30.4 其他编译工具

除了原生的 `:make`，现代开发中常用 LSP（语言服务器协议）来提供实时的代码诊断（红线提示），有时不需要频繁手敲 `:make`。

但如果你习惯使用构建工具，你可以这样定制：
*   **`:set makeprg=cargo\ build`**：为 Rust 配置 `:make`。
*   **`:set makeprg=npm\ run\ build`**：为前端 Node.js 项目配置 `:make`。
*   **`:set errorformat`**：这是控制 Vim 如何理解编译器报错的格式表，对于非标准编译器，你可以自定义 `errorformat` 来让 Vim 正确解析报错行号。

## 32. 撤销树 (The Undo Tree)

在大多数编辑器中，撤销历史是一条直线。如果你撤销了 3 步，然后输入了新内容，那么你之前撤销的那 3 步就被永久丢弃了。

**Vim 不一样。** 当你撤销了几步，然后做了新的修改，Vim 会为你创建一个新的“分支”。

这使得撤销历史变成了一棵**树（Tree）**。所有的历史修改都被保留了下来，你可以随时切换到树的不同分支上。这是一个极其强大的容错机制。

## 32.2 撤销和重做

*   **`u`**：撤销（Undo）。回到上一个修改状态。
*   **`CTRL-R`**：重做（Redo）。如果你撤销多了，按这个可以恢复。

你可以在它们前面加上计数，例如 `3u` 撤销三步，`2CTRL-R` 重做两步。

## 32.3 在撤销树中导航

因为撤销是一棵树，所以你有两种不同的移动方式：

1.  **线性时间轴（Time-based）**：按你实际按键发生的先后顺序移动。
    *   **`g-`**：回到上一个历史状态（按时间顺序，无论它属于哪个分支）。
    *   **`g+`**：前进到下一个历史状态（按时间顺序）。
2.  **分支树结构（Tree-based）**：在当前的修改分支上移动。
    *   **`u`** 和 **`CTRL-R`** 就是基于树结构移动的（在当前这条时间线上前后穿梭）。

当你做出一个分支后，可以使用 `:earlier` 和 `:later` 命令加上时间参数来直接跳转：

```vim
:earlier 5m   " 回到 5 分钟前的状态
:later 30s    " 前进到 30 秒后的状态
:earlier 10   " 回到 10 步修改前
```

## 32.6 查看撤销树

默认情况下，你只能通过按键去“盲走”撤销树。为了看清这棵树的全貌，Neovim 社区开发了专门的插件：

*   **`mbbill/undotree`**：最经典的 Vim 插件，会在侧边栏画出一棵树状图，你可以用鼠标或光标直接点击不同节点跳转。
*   **`debugloop/telescope-undo.nvim`**：如果你是 Telescope 用户，这个插件可以在 Telescope 的模糊搜索界面中展示所有修改记录，甚至带有代码差异（Diff）预览。

