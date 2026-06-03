# P-Skills 自进化系统

> 基于 SkillOpt 的 ReflACT 流水线，让 P-Skills 能够从使用经验中持续改进。

## 快速开始

### 1. 确保 hooks 已安装

```bash
# 检查 hooks.json 是否包含自进化相关的 hooks
cat ~/.claude/hooks.json | grep -E "learning-observer|session-tracker|evolution-train"
```

### 2. 环境变量控制

| 变量 | 默认值 | 作用 |
|------|--------|------|
| `P_SKILLS_LEARNING` | `on` | 设为 `off` 禁用所有学习功能 |
| `P_SKILLS_DEBUG` | `off` | 设为 `on` 启用调试输出 |

### 3. 使用方式

自进化系统是**自动运行**的，无需手动干预：

1. **数据采集**：每次使用 Edit/Write/Bash 工具时，hooks 自动采集行为数据
2. **Session 追踪**：每个 session 的工具调用、skill 触发、用户行为都被记录
3. **自动训练**：每 5 个 session 后，自动触发训练循环
4. **模式注入**：下次 session 开始时，自动加载学习到的模式

## 系统架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    自进化系统架构                                  │
├─────────────────────────────────────────────────────────────────┤
│  数据采集层（PostToolUse hooks）                                  │
│    ├── learning-observer.js    — 工具使用模式                     │
│    ├── session-tracker.js      — Session 级别指标                 │
│    └── meta-skill-update.js    — Skill 文件编辑追踪               │
├─────────────────────────────────────────────────────────────────┤
│  存储层                                                          │
│    └── ~/.p-skills/learning/                                    │
│        ├── projects/<id>/observations.jsonl   — 观察数据          │
│        ├── projects/<id>/sessions/            — Session 统计      │
│        ├── projects/<id>/epochs/              — 训练快照          │
│        └── global/evolution_log.jsonl         — 进化日志          │
├─────────────────────────────────────────────────────────────────┤
│  训练循环（evolution-train.js）                                   │
│    ① Reflect   — 分析观察数据，识别模式                           │
│    ② Propose   — 生成 skill 改进 patches                         │
│    ③ Validate  — 代理评分 + Gate 决策                             │
│    ④ Apply     — 应用验证通过的改进                               │
├─────────────────────────────────────────────────────────────────┤
│  应用层（SessionStart hook）                                     │
│    └── session-learning.js     — 加载学习模式到上下文              │
└─────────────────────────────────────────────────────────────────┘
```

## 数据格式

### 观察数据 (observations.jsonl)

```json
{
  "timestamp": "2026-06-03T16:19:23.358Z",
  "session_id": "test-001",
  "tool": "Edit",
  "file_path": "/path/to/file.js",
  "file_ext": ".js",
  "project_id": "fa816edb83e9",
  "skill_triggered": "fix-bug",
  "user_reverted": false,
  "user_manually_edited": false,
  "tool_input_size": 1234
}
```

### Session 统计 (sessions/<id>.json)

```json
{
  "session_id": "test-002",
  "started_at": "2026-06-03T16:21:37.394Z",
  "tool_calls": {
    "Edit": 5,
    "Bash": 3,
    "Read": 10
  },
  "skill_triggers": ["fix-bug"],
  "stages_completed": ["Research", "Implement"],
  "total_calls": 18,
  "user_reverts": 0,
  "user_manual_edits": 1,
  "score": {
    "completion_rate": 0.5,
    "adoption_rate": 1.0,
    "efficiency_score": 0.73,
    "composite": 0.72
  }
}
```

## 训练循环详解

### 反思阶段 (Reflect)

分析观察数据，识别：
- 频繁编辑的文件
- 常用的 skill
- 工具使用模式
- Session 分数趋势

### 提议阶段 (Propose)

基于识别的模式，生成 skill 改进：
- 添加常用文件到 skill 文档
- 记录常用 skill
- 优化频繁使用的流程

### 验证阶段 (Validate)

使用代理评分验证改进：
- 置信度阈值：0.5
- 支持数阈值：2
- Gate 决策：hard/soft 模式

### 应用阶段 (Apply)

应用验证通过的改进：
- 创建备份
- 应用 Edit 操作
- 保存 skill 快照
- 记录进化日志

## 学习率调度

```javascript
// 配置
const LR_CONFIG = {
  mode: 'cosine',        // constant | linear | cosine
  maxEdits: 4,           // 最大编辑数
  minEdits: 1,           // 最小编辑数
  totalEpochs: 20,       // 总 epoch 数
};

// 计算当前 epoch 的编辑预算
function getEditBudget(epoch) {
  // cosine 退火：从 maxEdits 逐渐减少到 minEdits
  return Math.max(
    minEdits,
    Math.round(
      minEdits + 0.5 * (maxEdits - minEdits) *
      (1 + Math.cos(Math.PI * epoch / totalEpochs))
    )
  );
}
```

## 调试

### 启用调试输出

```bash
export P_SKILLS_DEBUG=on
```

### 手动触发分析

```bash
# 分析 skill 编辑模式
node ~/.p-skills/skills/claude-code/hooks/scripts/meta-skill-update.js --analyze

# 查看分析报告
cat ~/.p-skills/learning/meta.md
```

### 手动触发训练

```bash
# 触发指定 epoch 的训练
node ~/.p-skills/skills/claude-code/hooks/scripts/evolution-train.js \
  --project <project_id> \
  --epoch <epoch_number>
```

### 查看学习数据

```bash
# 查看项目观察数据
cat ~/.p-skills/learning/projects/<project_id>/observations.jsonl

# 查看 session 统计
cat ~/.p-skills/learning/projects/<project_id>/sessions/<session_id>.json

# 查看进化日志
cat ~/.p-skills/learning/global/evolution_log.jsonl
```

## 常见问题

### Q: 如何禁用自进化系统？

```bash
export P_SKILLS_LEARNING=off
```

### Q: 训练什么时候触发？

每 5 个 session 后自动触发。可以通过修改 `session-tracker.js` 中的 `TRAINING_INTERVAL` 调整。

### Q: 需要多少数据才能开始训练？

至少需要 10 条观察数据。数据越多，训练效果越好。

### Q: 训练会影响现有 skill 吗？

会的，但：
1. 每次修改前都会创建备份
2. 只有验证通过的改进才会被应用
3. 可以随时回滚到备份版本

### Q: 如何查看训练效果？

```bash
# 查看 skill 快照
ls ~/.p-skills/learning/projects/<project_id>/epochs/

# 对比不同 epoch 的 skill
diff ~/.p-skills/learning/projects/<project_id>/epochs/epoch_001/skill_snapshot.md \
     ~/.p-skills/learning/projects/<project_id>/epochs/epoch_002/skill_snapshot.md
```

## 参考

- [SkillOpt 论文](https://arxiv.org/abs/2605.23904)
- [SkillOpt GitHub](https://github.com/microsoft/SkillOpt)
- [P-Skills 自进化系统设计文档](self-evolution-design.md)
