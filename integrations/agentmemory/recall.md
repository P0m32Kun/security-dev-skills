---
name: recall
description: 搜索 agentmemory 中的历史观察、会话和学习成果。用户说 "recall"、"remember"、"what did we do" 时触发。
argument-hint: "[search query]"
user-invocable: true
---

用户想要回忆关于以下内容的过去上下文：$ARGUMENTS

使用 `memory_smart_search` MCP 工具，将用户的查询作为 `query` 参数，`limit: 10`。该工具对捕获的观察结果运行混合 BM25 + 向量 + 图谱扩展搜索，返回排名结果。

以可读格式向用户展示返回的结果：
- 按会话分组
- 对于每个观察结果显示其类型、标题和叙述
- 突出显示最重要的观察结果（importance >= 7）
- 如果没有返回结果，建议用户尝试 2-3 个替代搜索词

**不要编造或幻觉观察结果。** 只展示 MCP 工具实际返回的内容。如果 `memory_smart_search` 不可用，说明 stdio MCP shim 没有启动 — 告诉用户：
1. 检查 AgentMemory MCP 服务器是否已配置
2. 重启 coding agent（MCP 配置只在启动时读取）
3. 检查 MCP 服务器连接状态

## 依赖

- AgentMemory MCP 服务器
- GitHub: https://github.com/rohitg00/agentmemory
