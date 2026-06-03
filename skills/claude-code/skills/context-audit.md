---
name: context-audit
description: >
  Use when context window is getting full or token consumption seems high.
  Use when user says "上下文审计", "context audit", "token usage", "优化上下文".
---

# 上下文审计

> 系统化分析当前上下文窗口的使用情况，识别浪费，优化 token 效率。

## 核心洞察

**MCP 工具是最大的杠杆点** — 每个 MCP 工具定义约占 500 tokens。10 个未使用的 MCP 工具 = 浪费 5000 tokens。减少 MCP 工具数量是最有效的上下文优化手段。

## 四阶段审计流程

### 阶段 1：Inventory（盘点）

盘点当前上下文的组成部分：

| 组成部分 | 典型占用 | 可优化程度 |
|---------|---------|-----------|
| 系统提示 | 1-3k tokens | 低 |
| MCP 工具定义 | 500 tokens/工具 | **高** |
| CLAUDE.md / 项目配置 | 500-2k tokens | 中 |
| Skill 文件 | 200-1k tokens/skill | 中 |
| 对话历史 | 持续增长 | 高 |
| 文件内容（Read 结果） | 变化大 | 中 |

操作步骤：
1. 估算当前总 token 占用
2. 列出所有已加载的 MCP 工具
3. 列出所有已注入的 skill 文件
4. 检查对话轮次数

### 阶段 2：Classify（分类）

将每个上下文组成部分分为三类：

- **Essential（必需）**：当前任务直接需要
- **Useful（有用）**：可能用到，但不是当前必需
- **Waste（浪费）**：当前任务完全不需要

分类标准：
- 最近 10 轮对话中是否用到？→ Essential
- 最近 30 轮对话中是否用到？→ Useful
- 更久或从未用到？→ Waste

### 阶段 3：Detect Issues（检测问题）

常见问题清单：

| 问题 | 检测方法 | 影响 |
|------|---------|------|
| MCP 工具过多 | 工具数量 > 15 | 5k+ tokens 浪费 |
| Skill 文件过大 | 单文件 > 1k tokens | 挤占有效上下文 |
| 对话历史过长 | 轮次 > 50 | 信息密度下降 |
| 重复读取同一文件 | 同一文件 Read > 3 次 | token 浪费 |
| 大文件未截断 | Read 结果 > 500 行 | 噪声淹没信号 |
| 未使用的 CLAUDE.md 配置 | 配置了但从未触发 | 500+ tokens 浪费 |

### 阶段 4：Report（报告）

输出审计报告：

```
## 上下文审计报告

### 占用估算
- 系统提示: ~Xk tokens
- MCP 工具 (N 个): ~Xk tokens
- 项目配置: ~Xk tokens
- 对话历史 (M 轮): ~Xk tokens
- 估计总计: ~Xk tokens / 窗口上限 Yk

### 优化建议（按影响力排序）
1. [高] 移除未使用的 MCP 工具: <工具列表>
2. [高] 压缩对话: 使用 /compact
3. [中] 精简 CLAUDE.md: <具体建议>
4. [低] 优化 skill 注入: <具体建议>

### 预计节省
- 移除 MCP 工具: ~Xk tokens
- 压缩对话: ~Xk tokens
- 总计可节省: ~Xk tokens (Z%)
```

## 快速检查命令

不需要完整审计时，做快速检查：

1. **MCP 工具数量** — 超过 15 个？考虑移除不常用的
2. **对话轮次** — 超过 50 轮？考虑 /compact
3. **最近 10 轮用了哪些工具** — 有从未用到的 MCP 工具吗？

## 优化手段优先级

| 手段 | 节省量 | 副作用 |
|------|--------|--------|
| 移除未使用 MCP 工具 | 500 tokens/工具 | 需要时重新加载 |
| /compact 压缩对话 | 30-70% | 可能丢失部分上下文 |
| 精简 CLAUDE.md | 100-1k tokens | 需要精确配置 |
| 使用 --resume 复用会话 | 避免重复初始化 | 跨会话状态 |
| 分拆大 skill 文件 | 200-500 tokens | 需要重构 skill |

## 红线

- **不要为了省 token 而移除安全相关的配置**
- **不要在关键任务中途做审计** — 先完成任务
- **不要手动编辑对话历史** — 用 /compact
