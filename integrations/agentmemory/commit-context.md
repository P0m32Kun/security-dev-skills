---
name: commit-context
description: 将文件、函数或行追溯到产生其当前提交的 agent 会话。用户问 "why is this code here" 时触发。
argument-hint: "[file, function, or line]"
user-invocable: true
---

用户想要以下内容的提交上下文：$ARGUMENTS

对目标文件、函数或行运行 `git blame`（或 `git log -L`）以提取最近触及它的提交 SHA。
- 当给定行范围时使用 `git blame -L <start>,<end> <file>`
- 当给定函数名时使用 `git log -L :<function>:<file>`
- 当只给定路径时使用 `git log -n 1 -- <file>`

获得 SHA 后，通过 `memory_commit_lookup` MCP 工具查找关联的 agent 会话，使用 `sha: "<full-sha>"`。如果 MCP 工具不可用，回退到 HTTP：
- `GET $AGENTMEMORY_URL/agentmemory/session/by-commit?sha=<sha>`
- 使用 `Authorization: Bearer $AGENTMEMORY_SECRET`（如果设置了）

结果展示为：
- 提交 SHA、短 SHA、分支、作者、消息
- 关联的会话：id、项目、开始/结束时间戳、观察计数、摘要（如果有）
- 来自该会话的最重要观察结果的简短列表（importance >= 7），通过 `memory_recall` 获取

不要编造意图。如果提交没有关联的会话，如实告知并只展示 `git show` 显示的内容。如果 `memory_commit_lookup` 返回空的 `commit: null` 主体，意味着提交早于会话链接 — 不要编造会话。

## 依赖

- AgentMemory MCP 服务器
- Git
- GitHub: https://github.com/rohitg00/agentmemory
