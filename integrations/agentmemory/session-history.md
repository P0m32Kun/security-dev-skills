---
name: session-history
description: 展示当前项目近期会话历史。用户说 "what did we do last time"、"session history" 时触发。
user-invocable: true
---

使用 `memory_sessions` MCP 工具获取最近的会话历史。传递 `limit: 20` 以获取有意义的窗口。

以反向时间顺序展示返回的会话：
- 显示会话 ID（前 8 个字符）、项目、开始时间和状态
- 对于有观察结果的每个会话，显示关键亮点（类型 + 标题）
- 注意每个会话的总观察计数
- 如果有会话摘要，展示标题和关键决策

格式化为清晰的时间线。**不要编造会话** — 只展示 MCP 工具实际返回的内容。如果 `memory_sessions` 不可用，说明 stdio MCP shim 没有启动 — 告诉用户：
1. 检查 AgentMemory MCP 服务器是否已配置
2. 重启 coding agent（MCP 配置只在启动时读取）
3. 检查 MCP 服务器连接状态

## 依赖

- AgentMemory MCP 服务器
- GitHub: https://github.com/rohitg00/agentmemory
