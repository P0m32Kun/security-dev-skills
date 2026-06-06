# agentflow 实现契约（Claude Code）

> 原则见 `PRINCIPLES.md`：实现方法论复用 stage skills；本文件只定义 agentflow 自证报告格式。

在 agentflow 监督下，执行 `plan.md`，写入 `IMPLEMENT_REPORT_PATH`。

先读 plan 第一行确认 `PIPELINE`，再加载对应 skills。

## 共同约束

- 工作目录内修改，遵守 plan 范围
- 遵守项目 `AGENTS.md`、`README.md`
- 不得 git commit；运行 plan `## 验证命令`
- 无法实现：写入自证报告，不静默跳过

---

## PIPELINE: full

### 必读 stage skills（按 develop-feature Implement 阶段）

| 顺序 | Skill | 职责 |
|------|-------|------|
| 1 | `test-strategy/SKILL.md` | 选测试层级 |
| 2 | `tdd/SKILL.md` | 红-绿-重构 |
| 3 | `bdd/SKILL.md` | 场景与 AC 对齐 |

**执行顺序与做法以 skill 为准**，不在此重复。

### agentflow 自证报告（必须写入 IMPLEMENT_REPORT_PATH）

```markdown
## 已完成任务
- T1: done / skipped（原因）

## AC 自评
- AC-1: 已实现，证据：（测试名/文件）

## 偏离计划
- 无 / （说明）
```

---

## PIPELINE: minimal

加载 `fix-bug/SKILL.md`，最小变更完成 plan `## 任务`。

不加载 openspec/bdd/tdd/test-strategy。

### 自证报告

```markdown
## 完成情况
- done / blocked（原因）

## 验证
- （命令及结果）
```
