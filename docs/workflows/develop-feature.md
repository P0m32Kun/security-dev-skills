# 功能开发 Workflow（说明书）

> **Agent 执行入口**：`skills/develop-feature/SKILL.md`  
> 本页仅供人类理解流程；触发、HARD-GATE、Red Flags 以 skill 正文为准。

## 定位

`develop-feature` 是 **Orchestrator skill**：不替代各阶段 skill，而是定义顺序、阻断条件与回退规则。

## 引用的阶段 skill

| 阶段 | Skill | 产出 |
|------|-------|------|
| Research | `brainstorming` | 调研报告 |
| Design | `openspec`（主）、`bdd`、`writing-plans` | spec、REQ-x、场景、tasks |
| Implement | `test-strategy` → `tdd` → `e2e-write` | 代码 + 测试 |
| Implement（可选） | `subagent-driven-development` / `dispatching-parallel-agents` | 多任务并行 |
| Doc-Sync | `doc-sync` | 更新后的文档 |
| Verify | `verify` | 验收报告 |
| Release | `deploy` | 发布产物 |
| Retrospective | `retrospective` | 复盘与改进项 |

## 流程图

```
Research → Design → Implement → Doc-Sync → Verify → Release → Retrospective
   │          │          │           │          │         │          │
brainstorming  │       tdd       doc-sync    verify    deploy    retrospective
               │          │                      │
          openspec    test-strategy              │
               │      e2e-write                   │
              bdd                               │
          writing-plans                         │
```

## 何时不用本 orchestrator

- 单纯修 bug → `fix-bug`
- 只写测试 → `tdd`
- 只讨论方案 → `brainstorming`
- 只发布 → `deploy`

## 小需求

Research + Design 可合并；Doc-Sync + Verify 可合并。  
**不能**跳过各阶段核心检查项。
