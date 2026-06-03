# 跨 Agent 工具等价表

> 本文件是**适配层**，让 p-skills 的内容对任何 coding agent 都能工作。
>
> Skill 正文使用**通用术语**（"skill 加载工具"、"文件读取工具"），agent 自己把术语映射到本地工具名。

## 为什么需要这个表

p-skills 不绑定任何 agent。Skill 文件用自然语言描述意图，不引用具体工具名。下表帮助 agent 在运行时找到对应的本地工具。

| 通用术语 | Claude Code | Codex CLI | Cursor | OpenCode | Gemini CLI | Qoder CLI | Aider | pi |
|---------|:-----------:|:---------:|:------:|:--------:|:----------:|:---------:|:-----:|:--:|
| **Skill 加载** | `Skill` | `skill` | rules 系统 | AGENTS.md 引用 | `activate_skill` | 内置发现 | `--read` | 内置发现 |
| **读文件** | `Read` | `shell(cat)` | read_file | Read | `read_file` | `Read` | `read` | `Read` |
| **写/改文件** | `Edit` / `Write` | `shell(sed)` | write / edit | Edit | `write_file` | `Edit` / `Write` | `edit` | `Edit` / `Write` |
| **执行命令** | `Bash` | `shell` | terminal | Bash | `run_shell_command` | `Bash` | `run` | `Bash` |
| **搜索文件** | `Glob` | `shell(find)` | glob | Glob | `search_files` | `Glob` | `find` | `Glob` |
| **搜索内容** | `Grep` | `shell(grep)` | grep | Grep | `search_content` | `Grep` | `grep` | `Grep` |
| **网络访问** | `WebFetch` | `shell(curl)` | fetch | WebFetch | `fetch_url` | `WebFetch` | — | `WebFetch` |
| **网络搜索** | `WebSearch` | `shell(curl)` | search | WebSearch | `google_search` | `WebSearch` | — | `WebSearch` |
| **TODO / 状态** | `TodoWrite` | — | todo | TodoWrite | — | `TodoWrite` | — | `TodoWrite` |
| **派 subagent** | `Task` / `Agent` | — | — | Agent | — | `Agent` | — | `Agent` |
| **问用户** | `AskUserQuestion` | — | — | AskUser | — | `AskUserQuestion` | — | `AskUserQuestion` |
| **计划模式** | `EnterPlanMode` | — | — | Plan | — | `EnterPlanMode` | — | `EnterPlanMode` |
| **Git worktree** | `EnterWorktree` | — | — | — | — | `EnterWorktree` | — | `EnterWorktree` |

## 使用方式

### 给 Agent 看

如果你是一个 coding agent 加载 p-skills，看到类似以下描述时：

> "使用 skill 加载工具读取 `skills/fix-bug/SKILL.md`"

请映射到你本地的工具：
- Claude Code → `Skill`
- Codex → `skill`
- Gemini → `activate_skill`
- 其他 → 你的 skill/rules 加载机制

### 给 Skill 作者看

写 skill 时**只用通用术语**：

```markdown
# ❌ 坏：绑定特定 agent
使用 Skill 工具读取 fix-bug。

# ❌ 坏：绑定特定工具
使用 Read 工具打开文件。

# ✅ 好：agent-agnostic
加载 fix-bug skill。
读取文件。
```

只有在必须区分工具能力时，才引用本表：

```markdown
如果你需要执行命令（参考工具等价表中的 "执行命令" 行），确保在沙盒中。
```

## 适配新 Agent

如果 p-skills 要支持新 agent：

1. 在本表中加一列
2. 在 `install.sh` 的 `get_agent_skill_dir` 加一行
3. 在对应 agent 的 plugin manifest 目录加 manifest（参考 `.claude-plugin/`）
4. 在 `tests/triggering/` 跑一遍触发测试验证集成

**不要**为了适配新 agent 修改任何 skill 内容 — skill 是 agent-agnostic 的。

## MCP 服务器的跨 agent 性

p-skills 推荐的 MCP 服务器（Semble、CodeGraph、AgentMemory）本身就是 agent-agnostic 的 — MCP 协议被各 agent 统一支持。

配置方式因 agent 而异（参考 `DEPENDENCIES.md` 的 MCP 配置节），但 MCP 服务本身对所有 agent 提供相同的工具名和 schema。

## 参考

- [obra/superpowers](https://github.com/obra/superpowers) — 同样的 agent-agnostic 设计，references 目录按 agent 提供工具映射
- [MCP 协议](https://modelcontextprotocol.io/) — 跨 agent 的工具协议标准
