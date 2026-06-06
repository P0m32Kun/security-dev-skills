# 发布部署 Workflow（说明书）

> **Agent 执行入口**：`skills/deploy/SKILL.md`

## 定位

`deploy` 既可独立触发（用户说「发布」「deploy」），也可作为 `develop-feature` 的 Release 阶段被引用。

## 前置条件（摘要）

- 测试通过  
- 文档已同步  
- 代码已审查  

## 典型步骤

1. 确定版本号  
2. 构建与测试  
3. 发布（Docker / npm / pip / 二进制等）  
4. 验证发布结果  

项目类型与具体命令见 `skills/deploy/SKILL.md`。
