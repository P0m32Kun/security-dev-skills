---
name: code-review
description: >
  Use when reviewing code changes, evaluating recent commits, or assessing
  code quality. Use when user says "评审", "review", "代码审查", "检查修改",
  "看看改动", "code review".
---

# 代码评审

## Overview

只读分析代码变更，输出结构化评审报告。**绝不修改代码。**

## When to Use

- 评审最近的修改或 commits
- 检查代码质量、风格一致性
- 评估架构合理性
- PR 合并前审查

## Process

1. **收集变更**
   - 确定评审范围（文件、commit、分支 diff）
   - 读取相关上下文（被修改文件的周边代码）

2. **多维度分析**
   - 正确性：逻辑是否正确、边界条件是否处理
   - 可读性：命名、注释、代码结构
   - 设计：职责划分、耦合度、抽象层次
   - 性能：明显的性能问题
   - 安全：注入、越权、信息泄露

3. **输出评审报告**

   ```markdown
   ## 评审报告

   ### 概要
   - 范围：[评审了什么]
   - 总体评价：[好 / 需改进 / 有严重问题]

   ### 问题
   | 严重度 | 文件:行号 | 描述 | 建议 |
   |--------|-----------|------|------|
   | 🔴 严重 | ... | ... | ... |
   | 🟡 建议 | ... | ... | ... |
   | 🟢 备注 | ... | ... | ... |

   ### 亮点
   - [做得好的地方]

   ### 总结建议
   - [核心改进方向]
   ```

## Red Flags — STOP

- ❌ "这个小问题我直接帮你改了" → **只读，不改**
- ❌ "看起来没问题，跳过细节" → **每个维度都要检查**
- ❌ "这个文件太长了，跳过" → **范围内的文件都要覆盖**

## Common Rationalizations

| 借口 | 现实 |
|------|------|
| "改一下很快的" | 评审和修改是两个职责，混在一起容易出错 |
| "都是小改动不用看" | 小改动最容易引入回归 bug |
| "代码能跑就行" | 能跑不等于正确、安全、可维护 |

## Completion Checklist

- [ ] 评审范围已明确
- [ ] 每个维度都已分析
- [ ] 评审报告已输出
- [ ] 严重问题已标注
- [ ] 没有修改任何代码

## References

- [Google Engineering Practices](https://google.github.io/eng-practices/review/) — Google 工程实践
- [The Art of Code Review](https://mtlynch.io/code-review-love/) — 代码评审的艺术
- [obra/superpowers](https://github.com/obra/superpowers) — code-review skill 设计
- `skills/fix-bug/` — 修复发现的 bug
- `skills/develop-feature/` — 完整开发流程
