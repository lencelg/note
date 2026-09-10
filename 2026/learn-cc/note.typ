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
  inset: (x: 14pt, y: 10pt),
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
  inset: (x: 14pt, y: 10pt),
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
