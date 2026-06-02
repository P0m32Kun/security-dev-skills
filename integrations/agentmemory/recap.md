---
name: recap
description: 总结当前项目的最近 N 个 agent 会话，按日期分组。用户说 "recap"、"what have we been doing"、"this week"、"today" 时触发。
argument-hint: "[last N | today | this week]"
user-invocable: true
---

用户想要回顾。时间窗口参数：$ARGUMENTS

解析 `$ARGUMENTS` 以确定窗口：
- `today` -> 在当前本地日期开始的会话
- `this week` -> 在过去 7 天内开始的会话
- `last <n>` -> 最近的 N 个会话
- 裸数字 -> 视为 `last <n>`
- 空 -> 默认为 `last 10`

调用 `memory_sessions` MCP 工具，然后过滤到当前项目（通过 `cwd` 与工作目录匹配）。应用时间窗口。按 `startedAt` 降序排序。

按本地日历日期（YYYY-MM-DD）分组会话。对于每个日期：
- 列出每个会话：id（前 8 个字符）、标题或第一个提示、观察计数、状态
- 缩进两三个每个会话的高亮观察结果（importance >= 7），通过 `memory_recall` 查询获取，limit 3

以单行总计结束："N 个会话跨 M 天，K 个观察结果。"

如果 MCP 工具不可用，回退到 HTTP：
- `GET $AGENTMEMORY_URL/agentmemory/sessions`
- `POST $AGENTMEMORY_URL/agentmemory/recall`
- 使用 `Authorization: Bearer $AGENTMEMORY_SECRET`（如果设置了）

不要编造会话；如果窗口为空，如实告知。

## 依赖

- AgentMemory MCP 服务器
- GitHub: https://github.com/rohitg00/agentmemory
