#import "@preview/scholia:0.1.0": *

#show: scholia.with(
  // theme: "dark",   // light (default) | dark (slate)
  // prose: "book",   // notes (default, no indent) | book (first-line indent)
)

#cover( "learn cc",
  author: "lencelg from Arcadia Bay",
  date: "2026 autumn",
)

#text(size: 30pt)[
learn from #link("https://github.com/shareAI-lab/learn-claude-code")[#text(fill: blue)[Learn Claude Code]]]

\
\
= Tool & Execution 

== Agent Loop

#set text(size: 8pt)

#note([
  The smallest useful agent is a loop that calls the model, runs tools, and feeds results back.
])

#image("img/simple_idea.png")

#h(165pt) #keyword[simple idea]

simple code as below:

````python
# 前面是一些简单的readline和anthropic的api key设置

# ── Tool definition: just bash ────────────────────────────
TOOLS = [{
    "name": "bash",
    "description": "Run a shell command.",
    "input_schema": {
        "type": "object",
        "properties": {"command": {"type": "string"}},
        "required": ["command"],
    },
}]




# ── Tool execution ────────────────────────────────────────
def run_bash(command: str) -> str:
    dangerous = ["rm -rf /", "sudo", "shutdown", "reboot", "> /dev/"]
    if any(d in command for d in dangerous):
        return "Error: Dangerous command blocked"
    try:
        r = subprocess.run(command, shell=True, cwd=os.getcwd(),
                           capture_output=True, text=True, timeout=120)
        out = (r.stdout + r.stderr).strip()
        return out[:50000] if out else "(no output)"
    except subprocess.TimeoutExpired:
        return "Error: Timeout (120s)"
    except (FileNotFoundError, OSError) as e:
        return f"Error: {e}"
# ── The core pattern: a while loop that calls tools until the model stops ──
def agent_loop(messages: list):
    while True:
        response = client.messages.create(
            model=MODEL, system=SYSTEM, messages=messages,
            tools=TOOLS, max_tokens=8000,
        )
        # Append assistant turn
        messages.append({"role": "assistant", "content": response.content})
        # If the model didn't call a tool, we're done
        if response.stop_reason != "tool_use":
            return
        # Execute each tool call, collect results
        results = []
        for block in response.content:
            if block.type == "tool_use":
                print(f"\033[33m$ {block.input['command']}\033[0m")
                output = run_bash(block.input["command"])
                print(output[:200])
                results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": output,
                })
        # Feed tool results back, loop continues
        messages.append({"role": "user", "content": results})
# ── Entry point ──────────────────────────────────────────
if __name__ == "__main__":
    print("s01: Agent Loop")
    print("输入问题，回车发送。输入 q 退出。\n")
    history = []
    while True:
        try:
            query = input("\033[36ms01 >> \033[0m")
        except (EOFError, KeyboardInterrupt):
            break
        if query.strip().lower() in ("q", "exit", ""):
            break
        history.append({"role": "user", "content": query})
        agent_loop(history)
        # Print the model's final text response
        response_content = history[-1]["content"]
        if isinstance(response_content, list):
            for block in response_content:
                if getattr(block, "type", None) == "text":
                    print(block.text)
        print()
````

== Tool Use
instead of using the simplest run bash, define #keyword([dispatch table]) for tool use

- bash
- read_file
- write_file
- edit_file

````python

# ═══════════════════════════════════════════════════════════
#  NEW: 工具定义（s01 只有一个 bash，现在扩展到 5 个）
# ═══════════════════════════════════════════════════════════
TOOLS = [
    {"name": "bash", "description": "Run a shell command.", "input_schema": {"type": "object", "properties": {"command": {"type": "string"}}, "required": ["command"]}},
    {"name": "read_file", "description": "Read file contents.", "input_schema": {"type": "object", "properties": {"path": {"type": "string"}, "limit": {"type": "integer"}}, "required": ["path"]}},
    {"name": "write_file", "description": "Write content to a file.", "input_schema": {"type": "object", "properties": {"path": {"type": "string"}, "content": {"type": "string"}}, "required": ["path", "content"]}},
    {"name": "edit_file", "description": "Replace exact text in a file once.", "input_schema": {"type": "object", "properties": {"path": {"type": "string"}, "old_text": {"type": "string"}, "new_text": {"type": "string"}}, "required": ["path", "old_text", "new_text"]}},
    {"name": "glob", "description": "Find files matching a glob pattern.", "input_schema": {"type": "object", "properties": {"pattern": {"type": "string"}}, "required": ["pattern"]}},
]



# ═══════════════════════════════════════════════════════════
#  NEW: 工具分发映射（s01 是硬编码 run_bash，现在改为查表）
# ═══════════════════════════════════════════════════════════

TOOL_HANDLERS = {
    "bash": run_bash, "read_file": run_read, "write_file": run_write,
    "edit_file": run_edit, "glob": run_glob,
}

# ═══════════════════════════════════════════════════════════
#  agent_loop 与 s01 结构完全一致，只改了工具执行那部分
#  - s01: output = run_bash(block.input["command"])
#  - s02: output = TOOL_HANDLERS[block.name](**block.input)
# ═══════════════════════════════════════════════════════════
````

\
so the flow update as follow:

#image("img/dispatch.png")

== Permission
#keyword([工具执行前先做权限判断])

执行命令之前首先要评估，于是加上三道闸门

*三道闸门对应三种决策:*

#v(1em)

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, left),
  inset: (x: 14pt, y: 8pt),
  stroke: none,
  
  table.hline(stroke: 1pt),
  
  text(weight: "bold")[闸门], 
  text(weight: "bold")[作用], 
  text(weight: "bold")[命中后],
  
  table.hline(stroke: 0.5pt),
  
  [1. 拒绝列表], 
  [永远禁止的操作（#raw("rm -rf /")、#raw("sudo")）], 
  [直接拒绝，不执行],
  
  table.hline(stroke: 0.5pt),
  
  [2. 规则匹配], 
  [取决于上下文的操作（写工作区外、#raw("rm") 文件）], 
  [交给闸门 3],
  
  table.hline(stroke: 0.5pt),
  
  [3. 用户审批], 
  [闸门 2 命中后，暂停等用户确认], 
  [用户决定允许或拒绝],
  
  table.hline(stroke: 1pt),
)

````python
def check_permission(block) -> bool:
    # 闸门 1: 硬拒绝
    if block.name == "bash":
        reason = check_deny_list(block.input.get("command", ""))
        if reason:
            print(f"\n⛔ {reason}")
            return False

    # 闸门 2 + 3: 规则匹配 → 用户审批
    reason = check_rules(block.name, block.input)
    if reason:
        decision = ask_user(block.name, block.input, reason)
        if decision == "deny":
            return False

    return True

# 在 agent_loop 中——s02 的循环只加了一行：
for block in response.content:
    if block.type == "tool_use":
        if not check_permission(block):           # ← 新增
            results.append({... "content": "Permission denied."})
            continue
        output = TOOL_HANDLERS[block.name](**block.input)  # s02 原有
        results.append(...)
````

== Hook
hook 是外部的扩展调用, agent cycle 分为四个hook event

cc 中的hook时间有27个，教学版里面只有四个

#table(
  columns: (auto, 1fr, 1.5fr),
  align: (left, left, left),
  inset: (x: 14pt, y: 8pt),
  stroke: none,
  
  table.hline(stroke: 1pt),

  text(weight: "bold")[事件],
  text(weight: "bold")[触发时机],
  text(weight: "bold")[典型用途],
  
  table.hline(stroke: 0.5pt),
  
  raw("UserPromptSubmit"),
  [用户输入提交后、进入 LLM 前],
  [输入验证、注入上下文],
  
  table.hline(stroke: 0.5pt),
  
  raw("PreToolUse"),
  [工具执行前],
  [权限检查、日志记录],
  
  table.hline(stroke: 0.5pt),
  
  raw("PostToolUse"),
  [工具执行后],
  [副作用（自动 #raw("git add") 等）、输出检查],
  
  table.hline(stroke: 0.5pt),
  
  raw("Stop"),
  [循环即将退出时],
  [收尾清理（CC 还支持强制续跑）],
  
  table.hline(stroke: 1pt),
)

#v(1em)

扩展通过 #text(fill: blue, "register_hook()") 添加，循环只调用 #text(fill: blue, "trigger_hooks()")。

\
循环不再直接调用任何检查函数，改为 #text(fill: blue)[trigger_hooks("PreToolUse", block)]，由注册表决定跑什么。


#pagebreak()

= Planning & Coordination

== TodoWrite
使用todo能够保持agent的注意力

在hook系统新增todo和reminder机制

\

教学版的代码如下，就是维护了一个列表

----------------------
````python
# 这里只是update了todo的内容，并没有真正的跑bash代码

CURRENT_TODOS: list[dict] = []

def run_todo_write(todos: list) -> str:
    global CURRENT_TODOS
    CURRENT_TODOS = todos

    lines = ["\n## Current Tasks"]
    for t in CURRENT_TODOS:
        icon = {"pending": " ", "in_progress": "▸", "completed": "✓"}[t["status"]]
        lines.append(f"  [{icon}] {t['content']}")
    print("\n".join(lines))
    return f"Updated {len(CURRENT_TODOS)} tasks"
````


----------------------

CC 中有两套任务系统并存：
- #keyword([TodoWrite])（V1）：一个简单的列表工具，数据在内存 AppState 中维护, 教学版也保存在进程内存里，退出后清空
- #keyword([Task System])（V2）：文件持久化、依赖图、并发锁、ownership


== SubAgent

#keyword([idea]): 大任务拆小, 每个小任务干净的上下文

#figure(
  image("img/subagent.png", width: 88%),
  caption: "SubAgent"
)

\

教学版的代码很清楚:

````python
def spawn_subagent(description: str) -> str:
    # 子 Agent 的工具：基础工具，但没有 task（禁止递归）
    sub_tools = [
        {"name": "bash", ...}, {"name": "read_file", ...},
        {"name": "write_file", ...}, {"name": "edit_file", ...},
        {"name": "glob", ...},
    ]
    messages = [{"role": "user", "content": description}]  # 全新 messages[]

    for _ in range(30):  # safety limit
        response = client.messages.create(
            model=MODEL, system=SUB_SYSTEM,
            messages=messages, tools=sub_tools, max_tokens=8000,
        )
        messages.append({"role": "assistant", "content": response.content})
        if response.stop_reason != "tool_use":
            break
        results = []
        for block in response.content:
            if block.type == "tool_use":
                blocked = trigger_hooks("PreToolUse", block)
                if blocked:
                    results.append({... "content": str(blocked)})
                    continue
                handler = SUB_HANDLERS.get(block.name)
                output = handler(**block.input) if handler else f"Unknown"
                trigger_hooks("PostToolUse", block, output)
                results.append({... "content": output})
        messages.append({"role": "user", "content": results})

    # 只返回最后的文本结论，中间过程全部丢弃
    return extract_text(messages[-1]["content"])
````


\
cc 的源码有三种subagent, 仅做了解

#table(
  columns: (auto, 1.3fr, 1.5fr),
  align: (left, left, left),
  inset: (x: 14pt, y: 12pt),
  stroke: none,
  
  table.hline(stroke: 1pt),
  
  text(weight: "bold")[模式],
  text(weight: "bold")[触发条件],
  text(weight: "bold")[上下文],
  
  table.hline(stroke: 0.5pt),
  
  text(weight: "bold")[Normal Subagent],
  [指定了 #raw("subagent_type") (normal path)],
  [全新 #raw("messages[]")，只有 prompt],
  
  table.hline(stroke: 0.5pt),
  
  text(weight: "bold")[Fork Subagent],
  [没指定 #raw("subagent_type")，fork gate 开启],
  [通过 #raw("buildForkedMessages()") 构造 cache-friendly 前缀，共享 prompt cache],
  
  table.hline(stroke: 0.5pt),
  
  text(weight: "bold")[General-Purpose],
  [没指定 #raw("subagent_type")，fork gate 关闭],
  [同 Normal],
  
  table.hline(stroke: 1pt),
)

== SKills
#keyword([idea: On-Demand Skill Loading])

于是添加skill loading系统，#text(fill: blue)[load_skill] 通过 #text(fill: blue)[TOOL_HANDLERS[block.name]]进行调用

#table(
  columns: (auto, auto, 1.5fr, 1.2fr),
  align: (left, left, left, left),
  inset: (x: 14pt, y: 8pt),
  stroke: none,
  
  table.hline(stroke: 1pt),
  
  text(weight: "bold")[层],
  text(weight: "bold")[位置],
  text(weight: "bold")[时机],
  text(weight: "bold")[代价],
  
  table.hline(stroke: 0.5pt),
  
  [目录],
  [system  prompt],
  [启动时注入（harness 扫描 skills/ 目录）],
  [~100 tokens/skill, 每轮都带],
  
  table.hline(stroke: 0.5pt),
  
  [内容],
  [tool_result],
  [Agent 调用 #raw("load_skill") 时；#raw("SKILL.md") 可指引后续的 #raw("read_file/bash") 调用，用于按需访问额外资源],
  [~2000 tokens/skill, 按需],
  
  table.hline(stroke: 1pt),
)

== System Prompt
System prompt 是放置在用户输入（User Prompt）之前的高优先级底层指令，用以定义 AI 的角色、行为边界、语气风格以及工具使用规则

\

PROMPT_SECTIONS: 分段定义
把一大段字符串拆成字典，每个 key 是一个主题
````python
PROMPT_SECTIONS = {
    "identity": "You are a coding agent. Act, don't explain.",
    "tools": "Available tools: bash, read_file, write_file.",
    "workspace": f"Working directory: {WORKDIR}",
    "memory": "Relevant memories are injected below when available.",
}
````

#figure(
  image("img/system_prompt.png"),
  caption: [system prompt]
)

== Error Recovery

三种最常见的故障模式
- 输出被截断
- 上下文超限
- 临时故障(429 限流 / 529 过载)

= Memory Management
== Context Compact
#note[Compression keeps the conversation usable when the context window gets crowded.]

#let blue-border = rgb("#7aa5ec")
#let blue-bg = rgb("#eaf1ff")
#let red-border = rgb("#e66767")
#let red-bg = rgb("#fbe6e6")
#let orange-border = rgb("#e08c38")
#let orange-bg = rgb("#fdf1e3")
#let gray-bg = rgb("#f4f4f4")
#let gray-text = rgb("#555555")

#let pipeline-card(title: "", right-tag: "", desc: "", trigger: "", stroke-color: black, fill-color: white, title-color: black) = {
  block(
    width: 100%,
    inset: 10pt,
    radius: 4pt,
    stroke: 1pt + stroke-color,
    fill: fill-color,
    grid(
      columns: (1fr, auto),
      align: (left, right),
      gutter: 10pt,
      {
        set par(leading: 0.6em)
        text(weight: "bold", fill: title-color)[#title]
        v(0.5em)
        text(size: 8pt)[#desc]
        v(0.3em)
        text(size: 8pt, fill: gray-text)[#trigger]
      },
      {
        align(right + top, text(size: 8pt, fill: gray-text)[#right-tag])
      }
    )
  )
}

// 封装灰色标题条
#let section-header(title) = {
  block(
    width: 100%,
    fill: gray-bg,
    inset: (x: 10pt, y: 6pt),
    radius: 2pt,
    text(fill: gray-text, size: 8pt)[#title]
  )
}

#pipeline-card(
  title: "L3 toolResultBudget",
  right-tag: "保留完整内容",
  desc: "tool_result 总和 > 200KB → 最大项落盘",
  trigger: "触发：每轮自动，必须在 microCompact 之前保留完整内容",
  stroke-color: blue-border,
  fill-color: blue-bg,
  title-color: rgb("#2b579a")
)

#pipeline-card(
  title: "L1 snipCompact",
  right-tag: "保留头尾",
  desc: "消息 > 50 条 → 裁掉中间",
  trigger: "触发：消息数超过阈值",
  stroke-color: blue-border,
  fill-color: blue-bg,
  title-color: rgb("#2b579a")
)

#pipeline-card(
  title: "L2 microCompact",
  right-tag: "压旧结果",
  desc: "旧 tool_result → 占位符（保留最近 3 条）",
  trigger: "触发：每轮自动，教学版用文本占位符模拟",
  stroke-color: blue-border,
  fill-color: blue-bg,
  title-color: rgb("#2b579a")
)

#section-header("自动压缩决策 (预处理不够时触发，1 API 调用)")

#pipeline-card(
  title: "L4 autoCompact",
  right-tag: "1 API 调用",
  desc: "token 超阈值 → LLM 全量摘要",
  trigger: "阈值：contextWindow - maxOutputTokens - 13,000 · 先尝试 sessionMemoryCompact，不够才调 LLM\n熔断：连续失败 3 次后停止重试",
  stroke-color: red-border,
  fill-color: red-bg,
  title-color: rgb("#a83232")
)

#section-header("应急兜底 (API 仍然返回 prompt_too_long 时触发)")

#pipeline-card(
  title: "应急 reactiveCompact",
  right-tag: "",
  desc: "API 返回 413 / prompt_too_long → 字节级裁剪",
  trigger: "保留最后 5 条 + 摘要，比 autoCompact 更激进",
  stroke-color: orange-border,
  fill-color: orange-bg,
  title-color: rgb("#a85e1a")
)

== Memory
索引常驻 SYSTEM prompt（可被 prompt cache 缓存），文件内容按需注入到当前 user turn（按 filename/description 匹配当前对话，不破坏 cache）。写入由每轮结束后的提取器完成：用户显式说"记住"或表达稳定偏好时，提取器会保存为记忆。文件积累多了，定期整理去重。


= PS
后面的并发和多agent平台不做处理，这次阅读算是简单了解一下概念
