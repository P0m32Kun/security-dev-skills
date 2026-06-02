---
name: doc-sync
description: 代码变更后自动同步相关文档
version: 1.0.0
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

## 流程

### 1. 检测变更范围

获取本次代码变更的文件列表：
- 使用 `git diff --name-only` 获取变更文件
- 或记录 agent 的编辑操作

### 2. 匹配受影响文档

根据变更文件，确定需要更新的文档：

| 变更类型 | 受影响文档 |
|---------|-----------|
| API 接口变更 | `docs/api.md` |
| 数据库 schema 变更 | `docs/architecture.md` |
| 配置项变更 | `docs/config.md` |
| 新增/删除模块 | `docs/architecture.md` |
| 用户流程变更 | `docs/feature.md` |
| 依赖变更 | `docs/dependencies.md` |

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
- [ ] docs/api.md — 更新了用户接口字段
- [ ] docs/architecture.md — 新增认证模块说明

### 未受影响的文档
- docs/config.md
- docs/feature.md
```

## 完成标准
- [ ] 所有受影响文档已识别
- [ ] 所有受影响文档内容已更新
- [ ] 所有 `last_updated` 时间戳已更新
- [ ] 变更清单已输出

## 参考
- 项目 CLAUDE.md 中的文档同步约束
- `docs/validate.md` — 文档一致性校验
