---
name: doc-sync
description: 代码变更后自动同步相关文档
version: 1.1.0
tags: [docs, sync, automation]
triggers:
  - "代码变更后"
  - "文档同步"
  - "更新文档"
inputs:
  - name: change_scope
    description: 变更范围（git diff 或编辑记录）
    required: true
outputs:
  - name: sync_report
    description: 文档同步变更清单
---

# 文档同步

## 前置条件
- 代码已完成变更（编译通过）
- 项目有文档目录结构

## 核心原则

1. **文档即代码** — 文档和代码一样重要，必须同步更新
2. **及时性** — 代码变更后立即同步文档，不要拖延
3. **可追溯** — 文档必须有 `last_updated` 时间戳

## 流程

### 1. 检测变更范围

获取本次代码变更的文件列表：
- 使用 `git diff --name-only` 获取变更文件
- 或记录 agent 的编辑操作

### 2. 匹配受影响文档

根据变更文件，确定需要更新的文档：

| 变更类型 | 受影响文档 | 检查点 |
|---------|-----------|--------|
| API 接口变更 | `docs/api.md` | 端点、参数、响应格式 |
| 数据库 schema 变更 | `docs/architecture.md` | 表结构、字段、索引 |
| 配置项变更 | `docs/config.md` | 环境变量、配置文件 |
| 新增/删除模块 | `docs/architecture.md` | 模块职责、依赖关系 |
| 用户流程变更 | `docs/feature.md` | 用户故事、验收条件 |
| 依赖变更 | `docs/dependencies.md` | 版本号、兼容性 |

### 3. 更新文档

对每个受影响的文档：
1. 读取当前文档内容
2. 根据代码变更更新对应章节
3. 更新 `last_updated` 时间戳
4. 保持文档格式一致

### 4. 输出变更清单

```markdown
## 文档同步报告

### 更新的文档
- [x] docs/api.md — 更新了用户接口字段
- [x] docs/architecture.md — 新增认证模块说明

### 未受影响的文档
- docs/config.md
- docs/feature.md

### 同步时间
- 开始时间：2026-06-02 10:00
- 完成时间：2026-06-02 10:15
- 耗时：15 分钟
```

<HARD-GATE>
**阻断条件**：文档未同步不进入 Verify

**检查项**：
- [ ] 所有受影响文档已识别
- [ ] 所有受影响文档内容已更新
- [ ] 所有 `last_updated` 时间戳已更新
- [ ] 变更清单已输出
</HARD-GATE>

## Anti-Patterns

- ✗ "代码写完了，文档以后再补" — 文档必须同步更新
- ✗ 只更新代码注释，不更新外部文档 — 外部文档更重要
- ✗ 文档更新后不校验一致性 — 可能有遗漏
- ✗ 不更新 `last_updated` 时间戳 — 无法追溯
- ✗ 跳过文档同步直接进入验证 — 验证时会发现文档过时

## 完成标准
- [ ] 所有受影响文档已识别
- [ ] 所有受影响文档内容已更新
- [ ] 所有 `last_updated` 时间戳已更新
- [ ] 变更清单已输出

## 参考
- `docs/validate.md` — 文档一致性校验
- `workflow/develop.feature.md` — 完整需求开发流程
- `CONTEXT.md` — 领域知识
