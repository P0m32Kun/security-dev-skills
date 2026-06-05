---
name: openspec
description: >
  Use when doing spec-driven development, starting a new feature with specs
  first, proposing changes, or following the propose-apply-archive workflow.
  Use when user says "spec-driven", "SDD", "OpenSpec", "先写 spec",
  "文档驱动开发", "propose", "opsx", "先定方案再实现".
---

# Spec-Driven Development (OpenSpec)

> Spec 是真理源，代码是可再生的实现 — 先就"构建什么"达成共识，再动手编码。

## 概述

Spec-Driven Development（SDD）是一种轻量级开发方法论，核心工作流为 **Propose → Apply → Archive** 三层循环。与 TDD 和 BDD 互补，SDD 在更高层级确保"做什么"先被明确。

```
SDD（外层）：定义"构建什么" — spec 驱动
  └── BDD（中层）：定义"行为是什么" — 示例驱动
        └── TDD（内层）：定义"代码怎么写" — 测试驱动
```

### 与 p-skills 的关系

SDD 填补了 p-skills 流程的前端空白：

```
p-skills: Research → Design → [SDD] → Implement → Doc-Sync → Verify → Release → Retrospective
                    ↑                          ↑
              调研用                          SDD 的 propose 阶段产出 spec/design/tasks
              产出 spec                        Apply 执行 tasks 时嵌套 TDD 红绿重构
```

- **Research 阶段的产出**可以直接作为 SDD 的 proposal / spec 输入
- **Propose 阶段**产出 `proposal.md` + `spec/` + `design.md` + `tasks.md`
- **Apply 阶段**内部可嵌套使用 `tdd` skill 实现具体代码
- **Doc-Sync 阶段**对应 SDD 的 `sync` 步骤

## When to Use

**触发场景：**
- 开启一个新功能，需要先写 spec 对齐预期
- 对需求存在不确定性，需要先做 proposal 评审
- 重构现有功能，需要先明确变更范围
- 团队分散或异步协作，需要一份稳定的真理源
- 希望构建"活文档"体系 — spec 就是持续的文档

**何时不用：**
- 极简单的修改（改文案、修 typo、微调样式）— 直接改
- 紧急修复线上故障 — 用 `fix-bug` skill
- 纯探索性工作（spike、技术验证）— 用 `brainstorming` skill
- 需求已经在别处（PRD、Jira）明确写好，只需同步到 spec

## 核心原则

1. **Spec 即真理源** — spec 描述系统当前行为，代码是基于 spec 的实现
2. **先共识后编码** — 任何变更都先写 proposal，对齐后再动手
3. **Delta 增量** — 每个变更只描述与当前 spec 的差异，不重写全文
4. **可归档** — 每个完成变更归档到 archive，spec 是常青的当前状态
5. **轻量不重量** — 不必一开始就写完整 spec，按需逐步完善

## 工作流

### 核心三阶段

```
Propose ──→ Apply ──→ Archive
   │            │          │
   ├ proposal.md ├ 实现 tasks  ├ 归档到 archive/
   ├ spec/       │ 输出代码    │ 更新 spec
   ├ design.md   │ 标记完成    │ 清理 changes/
   └ tasks.md    └            └
```

### Phase 1: Propose（提议）

创建一个变更提议，包含所有规划产物：

**产出物（位于 `openspec/changes/<change-name>/`）：**

```
openspec/changes/<change-name>/
├── proposal.md        # 为什么做、做什么、影响范围
├── specs/             # 需求与场景（按领域组织）
│   └── <domain>/spec.md
├── design.md          # 技术方案、架构决策
└── tasks.md           # 实施清单（可逐步执行）
```

**proposal.md 模板：**
```markdown
# <Change Name> — Proposal

## 动机
为什么需要这个变更？

## 范围
- 包含：...
- 不包含：...

## 影响
- 影响哪些模块/接口
- 是否需要数据迁移

## 风险
- 已知风险：...
```
**spec.md 要素：**
- Purpose — 领域/功能定位
- Requirements — 每个需求带 Scenarios（Given-When-Then）
- 验收标准

**tasks.md 格式：**
```markdown
## 实施清单

### 阶段 1: 基础设施
- [ ] 1.1 创建数据库表
- [ ] 1.2 添加模型定义

### 阶段 2: 业务逻辑
- [ ] 2.1 实现核心逻辑
- [ ] 2.2 错误处理

### 阶段 3: 前端/接口
- [ ] 3.1 API 端点
- [ ] 3.2 UI 组件
```

**完成标准：** proposal 已评审通过，spec 已对齐，tasks 可执行。

### Phase 2: Apply（实现）

按 tasks.md 逐一实现，每个 task 完成后标记 `[x]`。

**规则：**
- 严格按 tasks.md 的顺序逐个实现
- 每个 task 实现前，先确认 spec 和 design 中对应的描述
- 实现过程中可以嵌套使用其他 p-skills（`tdd`、`develop-feature` 等）
- 遇到实现与 spec 不一致时，优先更新 tasks 或 spec，不绕过

### Phase 3: Archive（归档）

变更完成后的收尾步骤：

1. **Sync** — 把变更中的 spec delta 合并回主 spec
2. **Archive** — 将整个 change 目录移入 `openspec/changes/archive/`
3. **清理** — 删除临时产物，确认主 spec 已反映变更

## SDD 与 BDD/TDD 的衔接

### SDD → BDD

SDD 的 spec.md 中的 Given-When-Then 场景，可直接转化为 BDD 的 Gherkin feature 文件：

```
spec.md 场景         →  BDD feature 文件
  用户登录场景       →  features/login.feature
  密码重置场景       →  features/password-reset.feature
```

### SDD → TDD

SDD 的 tasks.md 中的每个 task，在 Apply 阶段实现时：

```
Apply task 1.1       →  加载 tdd skill
                        RED: 写测试
                        GREEN: 写最少代码
                        REFACTOR: 优化
Apply task 1.2       →  重复 TDD 循环
```

### 三级驱动联动示例

```yaml
# 1. SDD — 定义要构建什么
openspec/changes/user-auth/proposal.md  # 动机：需要用户认证系统
openspec/changes/user-auth/specs/auth/spec.md  # 场景：登录、注册、重置密码
openspec/changes/user-auth/tasks.md  # 任务清单

# 2. BDD — 定义行为是什么（从 spec 衍生）
features/auth/login.feature  # Gherkin: Given-When-Then
features/auth/register.feature

# 3. TDD — 定义代码怎么写
internal/auth/login_test.go  # RED→GREEN→REFACTOR
internal/auth/register_test.go
```

## Red Flags — STOP

- "这个功能很简单，没必要写 spec" — 简单的功能更该写，因为成本最低
- "先写代码试试，之后再补 spec" — "之后"通常永远不会发生
- "spec 写好了，但实现发现不一样" — 更新 spec，不是绕过 spec
- "我们团队就我一个人，不需要对齐" — spec 是给未来的自己和 agent 看的
- "spec 太长了，没人会读" — 按领域拆分，每个 spec 只覆盖一个 bounded context

## Common Rationalizations

| 借口 | 现实 |
|------|------|
| "先写个快速原型，再回来补 spec" | 原型跑起来了，没人会回补 spec；spec 应该先于原型 |
| "需求会变，写 spec 浪费" | Spec 是活的，变化就更新 spec，而不是把 spec 扔掉 |
| "代码本身就是文档" | 代码描述"怎么做"，spec 描述"做什么"，两者缺一不可 |
| "写 spec 的时间不如用来写代码" | 写 spec 发现的问题，远比代码写完后重构的成本低 |

## Completion Checklist

- [ ] proposal.md 已写：说明动机、范围、影响、风险
- [ ] spec 已写：每个需求有 Given-When-Then 场景
- [ ] design.md 已写：技术方案清晰
- [ ] tasks.md 已写：可逐项执行
- [ ] Apply 阶段按 tasks.md 顺序完成
- [ ] 每个 task 实现后标记 `[x]`
- [ ] Sync 已完成：change 中的 spec delta 合并回主 spec
- [ ] Archive 已完成：change 移入 archive/
- [ ] 主 spec 反映当前系统行为

## 参考

- [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) — Spec-Driven Development 的 CLI 实现（`npm install -g @fission-ai/openspec`）
- p-skills `skills/tdd/SKILL.md` — TDD 红绿重构 skill
- p-skills `skills/bdd/SKILL.md` — BDD 行为驱动开发 skill
- p-skills `skills/writing-plans/SKILL.md` — 编写实施计划

