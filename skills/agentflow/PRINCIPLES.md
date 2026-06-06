# agentflow × p-skills 原则

## p-skills 是唯一能力库

`~/.p-skills/` 是我们持续打磨的开发流程仓库——借鉴优秀 skills，转化成自己的能力，随实践不断演进。

- **优先复用**已有 stage skill，不在 contract 里重写方法论
- **质量不够**时优化对应 `SKILL.md`，而不是在 agentflow 或 contract 里打补丁
- **agentflow contract** 只定义协作特有据：落盘格式、交接路径、机器协议、步骤边界

## contract 与 stage skill 的分工

| 层级 | 职责 | 示例 |
|------|------|------|
| **stage skill** | 怎么做（方法论） | `tdd`、`openspec`、`code-review` |
| **agentflow contract** | 何时做、产出什么格式 | `plan-contract.md`、`review-contract.md` |
| **protocol.md** | 机器可解析的标记 | `PIPELINE:`、`REVIEW_STATUS:` |
| **agentflow CLI** | 编排与校验 | 状态机、verify 执行 |

## 与 develop-feature 对齐

agentflow 是 `develop-feature` 在 **codex ↔ Claude Code 自动化**场景的子集。阶段 skill 引用与其保持一致：

| agentflow 步 | 复用 skill |
|--------------|------------|
| plan (full) | `openspec`、`bdd`、`writing-plans` |
| plan (minimal) | `fix-bug`（思路：最小变更） |
| implement (full) | `test-strategy` → `tdd` |
| implement (minimal) | `fix-bug` |
| review | `code-review`（补充）、合同 AC 对照（contract） |
| fix | `fix-bug` |

完整生命周期（Research、Doc-Sync、Release 等）见 `develop-feature/SKILL.md`。

## 维护检查清单

新增或修改 contract 时：

- [ ] 是否已有 stage skill 可复用？
- [ ] contract 是否只保留 agentflow 特有格式，未重复 skill 内步骤？
- [ ] 若发现 skill 质量不足，是否已标注待优化 skill 而非在 contract 扩写？
- [ ] `protocol.md` 与 `internal/plan` 是否仍一致？
