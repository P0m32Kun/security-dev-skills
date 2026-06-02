---
name: remember
description: 显式保存洞察、决策或学习到 agentmemory 的长期存储。用户说 "remember this"、"save this" 时触发。
argument-hint: "[what to remember]"
user-invocable: true
---

用户想要将以下内容保存到长期记忆：$ARGUMENTS

使用 `memory_save` MCP 工具将其持久化。

步骤：
1. 分析用户想要记住的内容 — 提取核心洞察、决策或事实。
2. 提取 2-5 个可搜索的 `concepts`（小写关键词短语），捕捉记忆的内容。优先使用具体术语而非通用术语（`"jwt-refresh-rotation"` 优于 `"auth"`）。
3. 提取任何相关的 `files` — 记忆引用的绝对或仓库相对路径。
4. 调用 `memory_save`，包含以下字段：
   - `content` — 要记住的完整文本（尽可能保留用户的措辞）
   - `concepts` — 提取的概念列表
   - `files` — 提取的文件列表（如果没有则为空数组）
5. 向用户确认记忆已保存，并展示你标记的概念，以便用户知道哪些术语可以检索它。

如果 `memory_save` 不可用，说明 stdio MCP shim 没有启动 — 告诉用户：
1. 检查 AgentMemory MCP 服务器是否已配置
2. 重启 coding agent（MCP 配置只在启动时读取）
3. 检查 MCP 服务器连接状态

## 依赖

- AgentMemory MCP 服务器
- GitHub: https://github.com/rohitg00/agentmemory
