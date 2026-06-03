---
name: continuous-learning
description: >
  Use when reviewing learned patterns, triggering instinct evolution, or checking skill improvement memory.
  Use when user says "学习模式", "learned patterns", "evolve", "查看学习", "改进记忆", "什么改进有效".
---

# 持续学习系统

> 两个互补的子系统，让 agent 从经验中持续改进。

## 系统架构

```
持续学习
├── Instincts（本能模式）— 文件和工具使用模式
└── Meta Memory（元记忆）— Skill 编辑效果追踪

存储位置: ~/.p-skills/learning/
├── instincts.jsonl          — 本能模式记录
├── meta-observations.jsonl  — Skill 编辑观察
└── meta.md                  — 自动生成的分析报告
```

## 子系统 1：Instincts（本能模式）

### 是什么

从重复行为中提取的模式，让 agent 在遇到相似场景时自动应用已学到的偏好。

### 记录格式

```json
{
  "pattern": "在 Next.js 项目中优先使用 app/ 而非 pages/",
  "confidence": 0.8,
  "evidence_count": 5,
  "last_seen": "2026-06-03T10:00:00Z",
  "context": "nextjs, routing",
  "source": "observed"
}
```

### 工作方式

1. agent 在工作中观察到重复行为模式
2. 记录到 `instincts.jsonl`，初始 confidence = 0.5
3. 每次再次观察到，confidence += 0.1（上限 1.0）
4. 高 confidence 的模式在相关场景自动提示

### 命令

```bash
# 查看所有本能模式
cat ~/.p-skills/learning/instincts.jsonl | jq .

# 查看高置信度模式
cat ~/.p-skills/learning/instincts.jsonl | jq 'select(.confidence > 0.7)'

# 按上下文过滤
cat ~/.p-skills/learning/instincts.jsonl | jq 'select(.context | contains("nextjs"))'
```

## 子系统 2：Meta Memory（元记忆）

### 是什么

追踪 skill 文件的编辑历史和效果，回答"哪些改进是有效的"。

### 记录格式

```jsonl
{"timestamp":"2026-06-03T10:00:00Z","file":"skills/fix-bug/SKILL.md","edit_type":"Edit","section":"流程总览","session_id":"abc123"}
```

### 自动生成的分析

`meta-skill-update.js` hook 自动记录每次 skill 编辑，每 10 次触发一次分析，生成 `meta.md`：

- 按编辑类型统计频率
- 按文件统计编辑频率
- 识别趋势（近期最常编辑的部分）

### 手动触发分析

```bash
node ~/.p-skills/skills/claude-code/hooks/scripts/meta-skill-update.js --analyze
```

## 查询命令

```bash
# 查看学习数据目录
ls -la ~/.p-skills/learning/

# 查看本能模式
cat ~/.p-skills/learning/instincts.jsonl 2>/dev/null || echo "暂无数据"

# 查看元观察记录
cat ~/.p-skills/learning/meta-observations.jsonl 2>/dev/null || echo "暂无数据"

# 查看分析报告
cat ~/.p-skills/learning/meta.md 2>/dev/null || echo "暂无数据"

# 查看记录总数
wc -l ~/.p-skills/learning/*.jsonl 2>/dev/null
```

## 隐私与安全

- **所有数据存储在本地** — `~/.p-skills/learning/`，不上传
- **不记录代码内容** — 只记录文件路径、编辑类型、时间戳
- **不记录对话内容** — 只记录工具使用模式
- **用户可随时清除** — `rm ~/.p-skills/learning/*`
- **不跨设备同步** — 每台机器独立学习

## 红线

| 行为 | 为什么有问题 |
|------|------------|
| 记录敏感信息（密码、token、密钥） | 安全风险 |
| 过度信任低 confidence 模式 | confidence < 0.6 的模式仅供参考 |
| 把学习数据推到 Git 仓库 | 隐私泄露 |
| 在学习数据中记录对话内容 | 不必要的隐私风险 |
| 盲目应用学到的模式而不验证 | 模式可能已过时或不适用当前场景 |

## 进化路径

当前系统（v1）：
- JSONL 文件存储
- 简单的 confidence 评分
- 手动查询

未来可能（v2）：
- 自动模式检测和置信度调整
- 跨会话的模式持久化
- 与 skill 系统的深度集成
- 团队共享学习成果（opt-in）
