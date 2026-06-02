---
name: commit-history
description: 列出与 agent 会话关联的近期 git 提交，可按分支或仓库过滤。用户说 "show agent commits"、"what has the agent shipped" 时触发。
argument-hint: "[branch=... repo=... limit=...]"
user-invocable: true
---

用户想要 agent 关联提交的列表。过滤参数：$ARGUMENTS

解析 `$ARGUMENTS` 中的可选 `branch=<name>`、`repo=<url-or-fragment>` 和 `limit=<n>` 标记。裸数字标记成为 limit。默认值：无分支过滤、无仓库过滤、limit 100、最大 500。

调用 `memory_commits` MCP 工具，包含解析的过滤器。如果 MCP 工具不可用，回退到 HTTP：
- 构建 `GET $AGENTMEMORY_URL/agentmemory/commits`
- 将每个过滤器作为 URL 编码的查询参数附加
- 使用 `Authorization: Bearer $AGENTMEMORY_SECRET`（如果设置了）

以反向时间顺序渲染结果：
- 短 SHA、分支、提交时间戳
- 提交消息第一行
- 关联的会话 id（每个前 8 个字符）和观察计数（如果存在）
- 当提供 `files` 时显示文件计数

如果结果为空，告诉用户过滤器没有匹配的提交，并建议删除分支/仓库过滤器。不要编造提交。

## 依赖

- AgentMemory MCP 服务器
- Git
- GitHub: https://github.com/rohitg00/agentmemory
