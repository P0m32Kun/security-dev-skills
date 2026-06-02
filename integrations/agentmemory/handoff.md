---
name: handoff
description: 恢复当前工作目录最近的 agent 会话。用户说 "where were we"、"resume"、"handoff"、"pick up where I left off" 时触发。
argument-hint: "[optional cwd override]"
user-invocable: true
---

用户想要恢复工作。可选的 cwd 覆盖：$ARGUMENTS

确定当前项目路径：如果提供了 `$ARGUMENTS`，将其解析为绝对、规范化的路径（接受相对输入）；否则使用当前工作目录。

调用 `memory_sessions` MCP 工具。从结果中，选择最近的会话，其规范化 `cwd` 与项目路径匹配（使用目录边界检查 — 相等或 `session.cwd.startsWith(projectPath + path.sep)` 或 `projectPath.startsWith(session.cwd + path.sep)`）。不要使用原始字符串前缀匹配：它会在共享路径前缀的不相关仓库之间产生误报。优先选择状态为 `completed` 的会话而非 `abandoned`。如果没有匹配，回退到整体最近的单个会话。

选择会话后：
1. 如果会话以未回答的用户面向问题结束，首先将该问题作为引领导出。在 `summary` 或最后几个观察结果中查找它（类型为 `conversation`，`narrative` 以 `?` 结尾）。
2. 然后总结会话：标题/摘要、接触的关键文件、关键决策或错误。使用 `memory_recall` 查询，从会话的顶级概念派生，获取支持性观察结果，limit 10。
3. 以用户可以操作的简短"下一步？"指针结束。

如果两个 MCP 工具都不可用，回退到 HTTP：
- `GET $AGENTMEMORY_URL/agentmemory/sessions`
- `POST $AGENTMEMORY_URL/agentmemory/recall`
- 使用 `Authorization: Bearer $AGENTMEMORY_SECRET`（如果设置了）

不要编造观察结果。如果最近的会话有零个观察结果，如实告知并提供重新开始的选项。

## 依赖

- AgentMemory MCP 服务器
- GitHub: https://github.com/rohitg00/agentmemory
