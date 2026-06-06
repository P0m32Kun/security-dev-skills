# Workflows — 人类可读的流程说明

> **给 Agent 执行的 workflow 是 skill，不是本目录。**  
> 本目录只供人类阅读：流程图、总览、映射关系。不承担触发规则、HARD-GATE 或完成标准。

## 核心原则

```
skills/          → 可执行行为单元（Agent 唯一执行入口）
docs/workflows/  → 说明书（引用 skill，不替代 skill）
```

| 概念 | 位置 | 谁读 | 承担行为约束 |
|------|------|------|-------------|
| 阶段 skill | `skills/openspec/`、`skills/tdd/` 等 | Agent | ✅ |
| Orchestrator skill（workflow） | `skills/develop-feature/`、`skills/fix-bug/` 等 | Agent | ✅ |
| 流程说明书 | `docs/workflows/`（本目录） | 人类 | ❌ |

**不要**新建 `workflows/*.md` 或 `prompts/*.md` 作为 Agent 平行入口——会失去 frontmatter 触发、HARD-GATE 和 Completion Checklist，并与 `skills/` 漂移。

## Skill 分层

### 阶段 skill（Stage）

单阶段能力，可独立触发，也可被 orchestrator 引用：

| Skill | 职责 |
|-------|------|
| `brainstorming` | Research — 需求澄清、方案探索 |
| `openspec` | Design — SDD、验收信号 REQ-x |
| `bdd` | Design — Gherkin 场景、FT-/E2E- |
| `writing-plans` | Design — 任务拆解 |
| `test-strategy` | Implement — 选择测试层级 |
| `tdd` | Implement — 红绿重构 |
| `e2e-write` | Implement — 端到端测试 |
| `doc-sync` | Doc-Sync — 文档同步 |
| `verify` | Verify — 用户视角验收 |
| `deploy` | Release — 发布部署 |
| `retrospective` | Retrospective — 复盘 |
| `code-review` | 代码评审（可嵌入 fix-bug 等流程） |

### Orchestrator skill（Workflow）

串联多个阶段 skill，定义顺序、阻断条件、回退规则：

| Skill | 对应说明书 | 典型场景 |
|-------|-----------|---------|
| `develop-feature` | [develop-feature.md](./develop-feature.md) | 新功能完整生命周期 |
| `fix-bug` | [fix-bug.md](./fix-bug.md) | Bug 修复与 hotfix |
| `deploy` | [deploy.md](./deploy.md) | 发布部署（常作为 develop-feature 末段） |
| `agentflow` | — | 更高层 CLI 编排（plan → implement → verify → review） |

### 辅助编排 skill

在 Implement 阶段按需插入，非完整 lifecycle：

| Skill | 用途 |
|-------|------|
| `subagent-driven-development` | 按 plan 顺序派 subagent |
| `dispatching-parallel-agents` | 并行派多个独立 subagent |

## 生命周期总览

详见 [lifecycle.md](./lifecycle.md)。

## 历史文档

`docs/archive/workflow/` 保留重构前的编排文档，**仅供查阅**，Agent 应加载 `skills/` 下的对应 SKILL.md。
