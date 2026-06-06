# agentflow 规划契约（Codex）

> 原则见 `PRINCIPLES.md`：方法论复用 stage skills；本文件只定义 agentflow 落盘格式与边界。

在 agentflow 监督下，为 Claude Code 编写可验收的任务合同，写入 `PLAN_PATH`。

## 必读

1. `~/.p-skills/skills/agentflow/protocol.md`
2. `~/.p-skills/skills/agentflow/PRINCIPLES.md`

## 必读 stage skills（full 模式）

按 `develop-feature` Design 阶段加载，**具体做法以 skill 为准**：

| 目的 | Skill |
|------|-------|
| 验收信号 | `openspec/SKILL.md` |
| 可观察场景 | `bdd/SKILL.md` |
| 任务拆解 | `writing-plans/SKILL.md` |

minimal 模式参考 `fix-bug/SKILL.md` 的「最小变更」思路，不加载上述 skills。

## 流水线选择

plan **第一行**：`PIPELINE: minimal` 或 `PIPELINE: full`（见 protocol.md）。

选 minimal（全部满足）：1–2 文件、无新契约、1–2 条验证命令。否则 `full`。

## agentflow 落盘格式

### minimal

```markdown
PIPELINE: minimal

## 任务
（一句话）

## 验证命令
- （shell 命令）
```

### full

按 stage skills 产出内容，并套用此结构（章节名必须保留，供 agentflow 校验）：

```markdown
PIPELINE: full

## 验收标准
- AC-1: （可观察行为），验证：（测试名或命令）

## 范围
- 允许改动：...
- 禁止改动：...

## 任务清单
### T1: ...
- 涉及文件：...
- 完成信号：AC-x

## 验证命令
- （shell 命令）

## 执行约束（给 Claude Code）
- 按 T1→T2 顺序；不得 git commit；受阻 AC 写入 implement-report.md
```

## 阻断

需求不清：写 `## 阻断问题`，不猜测。

## 边界

- 只写 plan，**不改代码**
- AC 必须可验证；每 Task 1–3 文件
- 任务拆解细节见 `writing-plans`，不在此重复
