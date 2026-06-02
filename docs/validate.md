---
name: doc-validate
description: 校验文档与代码的一致性
version: 1.0.0
tags: [docs, validate, ci]
triggers:
  - "文档校验"
  - "PR 提交前"
  - "CI 检查"
outputs:
  - name: validation_report
    description: 一致性校验报告
---

# 文档一致性校验

## 前置条件
- 代码变更已完成
- 文档已同步（`doc-sync` 已执行）

## 流程

### 1. 时间戳对比

检查文档的 `last_updated` 是否晚于代码最后修改时间：

```
对每个文档文件：
  文档时间 = 文档.frontmatter.last_updated
  代码时间 = git log -1 --format=%ai -- <相关代码文件>
  
  if 文档时间 < 代码时间:
    标记为"过期"
```

### 2. 字段反向索引检查

验证文档中提到的代码元素是否仍然存在：

| 文档内容 | 检查方式 |
|---------|---------|
| API 端点 | 检查代码中是否存在对应路由 |
| 函数名 | 检查代码中是否存在该函数 |
| 配置项 | 检查配置文件中是否存在该字段 |
| 数据库字段 | 检查 schema 中是否存在该字段 |

### 3. Frontmatter 完整性

检查每个文档的 frontmatter 是否包含必填字段：

```yaml
# 必填字段
title: 文档标题
last_updated: 2026-06-02
related_code: [相关代码文件列表]
```

### 4. 输出校验报告

```markdown
## 文档校验报告

### 过期文档
- [ ] docs/api.md — last_updated: 2026-05-01, 代码最后修改: 2026-06-02

### 引用不存在的代码
- [ ] docs/architecture.md:15 — 引用了 `getUserById()`，但代码中已重命名为 `fetchUser()`

### Frontmatter 缺失
- [ ] docs/config.md — 缺少 `related_code` 字段

### 校验通过
- [x] docs/feature.md
- [x] docs/dependencies.md
```

## 完成标准
- [ ] 零过期文档
- [ ] 零无效代码引用
- [ ] 所有文档 frontmatter 完整
- [ ] 校验报告已输出

## 参考
- `docs/sync.md` — 文档同步
- 项目 CI 配置中的文档校验步骤
