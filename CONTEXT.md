# Dev Workflow — 领域知识

> 本文件包含 skill 体系的领域知识，供各 skill 引用。

## 核心原则

### 1. 流程强制
- 每个阶段有明确的完成标准
- 阻断条件必须满足才能进入下一阶段
- 不能跳过任何阶段

### 2. 可验证性
- 每个输出必须可验证
- 成功标准必须具体、可测量
- 不能依赖主观判断

### 3. 持续改进
- 每次开发完成后进行回顾
- 记录问题和优化建议
- 持续迭代 skill 体系

## 术语表

| 术语 | 定义 |
|------|------|
| Skill | 一个独立的开发流程指南，包含前置条件、流程、完成标准 |
| 编排器 | 串联多个 skill 的流程定义 |
| 阻断条件 | 进入下一阶段必须满足的条件 |
| HARD-GATE | 强制检查点，不能跳过 |
| Anti-Pattern | 应该避免的错误做法 |

## 技术栈

### 开发环境
- 操作系统：macOS / Linux
- 容器化：Docker / Docker Compose
- 版本控制：Git / GitHub

### 测试工具
- 单元测试：Jest / Vitest / Go test / pytest
- E2E 测试：Playwright / Cypress
- 安全测试：Semgrep / SonarQube

### CI/CD
- GitHub Actions
- Docker 构建
- ACR / GHCR

## 常见问题

### Q: 小需求是否可以跳过某些阶段？
A: 可以合并，但不能跳过。Research + Design 可合并为一个步骤。

### Q: Verify 阶段发现问题怎么办？
A: 可回退到 Implement，修复后重新走 Doc-Sync → Verify 流程。

### Q: 如何判断 skill 是否好用？
A: 从以下维度评估：
- 是否减少了时间浪费
- 是否减少了 token 浪费
- 是否提高了代码质量
- 是否易于理解和执行

## 参考资源

### 优秀 Skill 仓库
- [superpowers](https://github.com/obra/superpowers) — 流程强制、HARD-GATE
- [gstack](https://github.com/garrytan/gstack) — 模板化、自动化
- [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) — 行为准则
- [mattpocock/skills](https://github.com/mattpocock/skills) — 分类清晰、渐进式披露

### 安全资源
- [OWASP](https://owasp.org/) — Web 安全
- [Vulhub](https://github.com/vulhub/vulhub) — 漏洞靶场
- [Semgrep](https://semgrep.dev/) — 静态分析
