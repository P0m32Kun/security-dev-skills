---
name: security-research
description: 安全工具/方案调研
version: 1.0.0
tags: [security, research, tools]
triggers:
  - "安全调研"
  - "安全工具选型"
  - "安全方案"
inputs:
  - name: research_goal
    description: 调研目标
    required: true
  - name: constraints
    description: 约束条件（预算、环境、团队能力）
    required: false
outputs:
  - name: research_report
    description: 调研报告 + 推荐方案
---

# 安全工具/方案调研

## 前置条件
- 明确调研目标和范围
- 了解项目技术栈和环境约束

## 流程

### 1. 明确调研目标

确定调研的具体问题：

| 调研类型 | 示例问题 |
|---------|---------|
| 工具选型 | 选择 SAST 工具（Semgrep vs SonarQube） |
| 方案设计 | 实现 API 认证方案 |
| 漏洞防护 | 防御 SQL 注入的最佳实践 |
| 合规要求 | 满足 GDPR 数据保护要求 |

### 2. 搜索市面上的工具/方案

#### 搜索来源
- GitHub trending / awesome-security
- OWASP 项目
- 安全社区博客（FreeBuf、先知、安全客）
- 厂商文档（AWS、Azure、GCP 安全服务）
- 学术论文（如涉及前沿技术）

#### 搜索关键词
```
[需求类型] + [技术栈] + [场景]
示例：SAST tool Go API security
```

### 3. 对比分析

创建对比矩阵：

| 维度 | 工具 A | 工具 B | 工具 C |
|------|--------|--------|--------|
| 功能完整性 | ★★★★ | ★★★★★ | ★★★ |
| 易用性 | ★★★★★ | ★★★ | ★★★★ |
| 社区活跃度 | ★★★★ | ★★★★★ | ★★★ |
| 文档质量 | ★★★ | ★★★★★ | ★★★★ |
| 集成难度 | ★★ | ★★★★ | ★★★★★ |
| 成本 | 免费 | 付费 | 免费 |

#### 关键评估点

**功能维度**
- 支持的语言/框架
- 检测规则覆盖度
- 误报率/漏报率
- 自定义规则能力

**工程维度**
- CI/CD 集成
- API 接口
- 配置复杂度
- 性能影响

**生态维度**
- 社区活跃度
- 文档完整性
- 更新频率
- 厂商支持

### 4. 输出调研报告

```markdown
## 安全调研报告

### 调研背景
- 目标：选择适合项目的 SAST 工具
- 时间：2026-06-02
- 调研人：xxx

### 调研范围
- 评估工具：Semgrep, SonarQube, CodeQL
- 评估维度：功能、易用性、集成、成本

### 工具分析

#### Semgrep
- **优势**：规则灵活、社区活跃、轻量级
- **劣势**：高级功能需付费
- **适用场景**：快速集成、自定义规则

#### SonarQube
- **优势**：功能全面、企业级、多语言支持
- **劣势**：部署复杂、资源占用大
- **适用场景**：大型项目、企业环境

#### CodeQL
- **优势**：GitHub 原生集成、深度分析
- **劣势**：学习曲线陡、仅支持 GitHub
- **适用场景**：GitHub 项目、深度安全分析

### 推荐方案

**推荐**：Semgrep

**理由**：
1. 与现有 CI/CD 流程集成简单
2. 社区规则库丰富
3. 自定义规则学习成本低
4. 免费版满足当前需求

**实施计划**：
1. Phase 1：集成到 CI，使用社区规则
2. Phase 2：编写自定义规则
3. Phase 3：定期更新规则库
```

## 完成标准
- [ ] 调研目标已明确
- [ ] 至少评估 3 个工具/方案
- [ ] 对比矩阵已创建
- [ ] 推荐方案已确定
- [ ] 调研报告已输出

## 参考
- `security/poc.md` — PoC 编写
- `security/tool-integrate.md` — 工具集成
- [OWASP](https://owasp.org/)
- [GitHub awesome-security](https://github.com/sbilly/awesome-security)
