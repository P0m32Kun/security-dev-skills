---
name: codegraph-usage
description: CodeGraph MCP 使用指南 — 何时使用哪个工具进行代码图谱分析
user-invocable: false
always-apply: true
---

## CodeGraph

本项目配置了 CodeGraph MCP 服务器（`codegraph_*` 工具）。CodeGraph 是一个 tree-sitter 解析的知识图谱，包含每个符号、边和文件。读取是亚毫秒级的，返回 grep 无法获得的结构信息。

### 何时优先使用 codegraph 而非原生搜索

对于**结构性**问题使用 codegraph — 谁调用谁、改变什么会破坏什么、X 定义在哪里、X 的签名是什么。仅对**字面文本**查询（字符串内容、注释、日志消息）或在你已经有特定文件打开后使用原生 grep/read。

| 问题 | 工具 |
|---|---|
| "X 定义在哪里？" / "查找名为 X 的符号" | `codegraph_search` |
| "谁调用了函数 Y？" | `codegraph_callers` |
| "Y 调用了谁？" | `codegraph_callees` |
| "X 如何到达/变成 Y？/ 追踪从 X 到 Y 的流" | `codegraph_trace`（一次调用 = 整个路径，包括回调/React/JSX 动态跳转） |
| "如果我改变 Z，什么会破坏？" | `codegraph_impact` |
| "展示 Y 的签名/源码/文档字符串" | `codegraph_node` |
| "给我任务/区域的聚焦上下文" | `codegraph_context` |
| "一次查看多个相关符号的源码" | `codegraph_explore` |
| "path/ 下有哪些文件" | `codegraph_files` |
| "索引健康吗？" | `codegraph_status` |

### 经验法则

- **直接回答 — 不要委托探索。** 对于 "X 如何工作" / 架构问题，用 2-3 个 codegraph 调用回答：先 `codegraph_context`，然后一个 `codegraph_explore` 获取它表面的符号的源码。对于特定的**流**（"X 如何到达 Y"）从 `codegraph_trace` from→to 开始 — 一次调用返回整个路径，动态跳转已桥接 — 然后一个 `codegraph_explore` 获取主体；不要用 `codegraph_search` + `codegraph_callers` 重建路径。Codegraph 是预构建的索引，所以启动单独的文件读取子任务/agent — 或运行 grep + read 循环 — 重复了 codegraph 已经完成的工作，成本更高。
- **信任 codegraph 结果。** 它们来自完整的 AST 解析。不要用 grep 重新验证它们 — 那更慢、更不准确、浪费上下文。
- **不要先 grep** 当按名称查找符号时。`codegraph_search` 更快，一次调用返回 kind + 位置 + 签名。
- **不要链式调用 `codegraph_search` + `codegraph_node`** 当你只想要上下文时 — `codegraph_context` 是一次调用。
- **不要对多个符号循环 `codegraph_node`** — 一次 `codegraph_explore` 调用返回多个符号的源码，分组在单个有上限的调用中，而每个单独的 node/Read 调用重新读取整个上下文，成本更高。
- **索引延迟 — 检查过时横幅，不要猜测等待。** 当 codegraph 响应以 "⚠️ Some files referenced below were edited since the last index sync…" 开头时，列出的文件待重新索引 — 读取这些特定文件以获取准确内容。不在该横幅中的文件是新鲜的，codegraph 对它们是权威的。`codegraph_status` 也在 "Pending sync" 下列出待处理文件。

### 如果 `.codegraph/` 不存在

MCP 服务器返回 "not initialized."。询问用户：*"我注意到这个项目没有初始化 CodeGraph。你想让我运行 `codegraph init -i` 来构建索引吗？"*

## 依赖

- CodeGraph MCP 服务器
- GitHub: https://github.com/colbymchenry/codegraph
- 安装: `npm install -g @colbymchenry/codegraph`
- 初始化: `codegraph init -i`
