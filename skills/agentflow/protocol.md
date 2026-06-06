# agentflow 协作协议（机器层）

本文档定义 agentflow CLI 状态机依赖的**机器可读标记**与**审计产物**。
流程方法论见各 `*-contract.md`；协议格式变更须同步更新 `agentflow/internal/plan`。

## 设计原则

见 `PRINCIPLES.md`。摘要：

- **白盒**：每步落盘，可回放、可审计、可调优
- **复用**：方法论在 stage skills；contract 只定义协作格式；agentflow CLI 只编排
- **演进**：p-skills 持续打磨；skill 质量不够则优化 skill，不在 contract 里重写

## 审计产物（`.agent-runs/<run-id>/`）

| 文件 | 步骤 | 作者 | 用途 |
|------|------|------|------|
| `plan.md` | plan | codex | 任务合同 |
| `implement-report.md` | implement/fix | Claude Code | 执行自证 |
| `implement-*.log` | implement | Claude Code | 原始日志 |
| `verify-*.log` | verify | agentflow | 客观验证 |
| `diff-stat.txt` | review | agentflow | 变更摘要 |
| `review-*.md` | review | codex | 合同验收 |
| `fix-*.log` | fix | Claude Code | 修复日志 |
| `events.jsonl` | 全程 | agentflow | 状态事件 |
| `state.json` | 全程 | agentflow | 当前状态 |

## 机器可读标记

### plan.md 第一行

```
PIPELINE: full
```
或
```
PIPELINE: minimal
```

缺省视为 `full`。

### review-*.md 判定行（必须各出现一行）

```
REVIEW_STATUS: PASS
```
或
```
REVIEW_STATUS: BLOCKED
```

## plan 结构校验（agentflow 执行）

### minimal 必需章节

- `## 任务`
- `## 验证命令`（至少一条 `- ` 命令）

### full 必需章节

- `## 验收标准`
- `## 范围`
- `## 任务`（任务清单或任务）
- `## 验证命令`（至少一条 `- ` 命令）

## 验证命令合并

plan `## 验证命令` 中的命令优先，其后追加 `.agentflow.yaml` 的 `commands.verify`，去重。

## 流水线路由

| PIPELINE | verify 通过后 |
|----------|---------------|
| `minimal` | 直接 Succeeded（跳过 codex review） |
| `full` | 进入 codex review |
