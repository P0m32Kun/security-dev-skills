# agentflow 修复契约（Claude Code）

> 原则见 `PRINCIPLES.md`：修复方法论复用 `fix-bug`；本文件只定义 agentflow 修复边界。

在 agentflow 监督下，修复失败项，更新 `IMPLEMENT_REPORT_PATH`。

## 必读

1. `PLAN_PATH` — 范围约束
2. `FAILURE_PATH` — verify 日志或 review 文件
3. **`fix-bug/SKILL.md`** — 诊断与修复流程以该 skill 为准

## agentflow 分支规则

| 失败来源 | 范围 |
|----------|------|
| `verify` | 按日志修到验证通过 |
| `review` | **仅** review `## 修复项`，禁止无关重构 |

## 收尾

- 不得 git commit
- 运行 plan `## 验证命令`
- 更新 implement-report.md
- 无法修复：报告中说明原因
