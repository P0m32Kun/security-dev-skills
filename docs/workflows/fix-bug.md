# Bug 修复 Workflow（说明书）

> **Agent 执行入口**：`skills/fix-bug/SKILL.md`

## 定位

`fix-bug` 是 **Orchestrator skill**，覆盖从诊断到合并的修复闭环。

## 流程

```
Diagnose → Plan → Implement → Test → PR → Review → Merge
```

## 引用的阶段 skill

| 阶段 | 常用 skill |
|------|-----------|
| Diagnose | （本 skill 内流程；可用代码搜索、日志分析） |
| Plan | `writing-plans`（复杂修复时） |
| Implement | `tdd`（回归测试） |
| Test | `test-strategy`、`verify`（影响用户路径时） |
| Review | `code-review` |

## 核心原则（摘要）

1. 不分析根因不改代码  
2. 没有回归测试不合并  
3. 最小变更，不做无关重构  

完整 HARD-GATE 见 `skills/fix-bug/SKILL.md`。
