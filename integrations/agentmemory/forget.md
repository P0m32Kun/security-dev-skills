---
name: forget
description: 从 agentmemory 中删除特定观察或会话。用户说 "forget this"、"delete memory" 时触发。
argument-hint: "[what to forget - session ID, file path, or search term]"
user-invocable: true
---

用户想要从 agentmemory 中删除数据：$ARGUMENTS

**重要**：这是破坏性操作。始终在删除前与用户确认。

步骤：

1. 首先使用 `memory_smart_search` MCP 工具搜索匹配的观察结果。使用用户输入作为 `query`，`limit: 20`。
2. 向用户展示找到的内容 — 会话 ID、观察 ID、标题 — 并在删除前请求明确确认。
3. 确认后，调用 `memory_governance_delete`，包含：
   - `memoryIds: [<id>, ...]` — 步骤 1 中搜索返回的记忆 ID 数组（或逗号分隔的字符串）
   - `reason: "<short reason>"` — 可选，默认为 `"plugin skill request"`

   如果用户想要删除整个会话的观察结果，收集该会话中的每个记忆 ID 并通过 `memoryIds` 传递它们。独立 MCP 不接受裸 `sessionId` 参数 — 它只按记忆 ID 删除。
4. 向用户确认删除计数。

**未经用户明确确认，切勿删除。** 如果 MCP 工具不可用，说明 stdio MCP shim 没有启动 — 告诉用户：
1. 检查 AgentMemory MCP 服务器是否已配置
2. 重启 coding agent（MCP 配置只在启动时读取）
3. 检查 MCP 服务器连接状态

## 依赖

- AgentMemory MCP 服务器
- GitHub: https://github.com/rohitg00/agentmemory
