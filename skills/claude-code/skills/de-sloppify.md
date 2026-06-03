---
name: de-sloppify
description: >
  Use when implementation is done and code needs cleanup before review.
  Use when user says "清理代码", "code cleanup", "de-sloppify", "清理".
---

# 代码清理清单（De-Sloppify）

> 实现完成后的系统化清理流程，确保代码达到 review 标准。

## 核心原则

1. **先完成再完美** — 实现阶段允许临时代码，清理阶段必须全部处理
2. **清单驱动** — 逐项检查，不靠记忆
3. **不留痕迹** — 清理后的代码不应能看出"这里曾经是临时代码"

## 清理清单（10 步）

### 第 1 步：移除调试语句

- 删除所有 `console.log`、`print`、`debugger`、`println!`、`fmt.Println` 等调试输出
- 删除临时的 `// DEBUG`、`// TODO: remove`、`// HACK` 标记
- 如果调试日志有保留价值，替换为正式的日志框架调用

### 第 2 步：移除注释掉的代码

- 删除所有被注释掉的代码块（`// old code`、`/* disabled */`）
- 如果需要保留历史，Git 已经记录了，不需要注释
- 唯一例外：带有 `NOTE:` 或 `WHY:` 前缀的解释性注释

### 第 3 步：处理 TODO/FIXME

- 每个 TODO 必须关联一个 issue 编号，或当场解决
- 没有 issue 编号的 TODO 要么创建 issue 并补上编号，要么直接解决
- 清理后不应有孤立的 TODO

### 第 4 步：检查未使用的导入

- 移除所有未使用的 import/require/include
- 按语言惯例排序导入（stdlib → third-party → local）
- 不要留"以防万一"的导入

### 第 5 步：检查未使用的变量和函数

- 移除或以下划线前缀标记未使用的变量
- 移除未被调用的私有函数/方法
- 检查函数参数是否都被使用

### 第 6 步：统一命名风格

- 同一作用域内命名风格一致（camelCase 或 snake_case，不混用）
- 变量名准确反映用途（不用 `temp`、`data`、`obj`、`val` 等模糊名）
- 缩写保持一致（`ctx` vs `context`，选一个贯穿全文）

### 第 7 步：确保错误处理

- 所有 async 调用有 catch/错误处理
- 所有可能失败的 I/O 操作有错误处理
- 错误信息包含足够上下文（不要只抛 `Error("failed")`）
- 不吞异常（空 catch 块）

### 第 8 步：确保类型标注

- 公开 API 有完整的类型标注
- 函数签名有返回类型标注
- 复杂数据结构有类型定义
- 不用 `any` / `Object` / `*` 除非有充分理由

### 第 9 步：运行 linter

```bash
# 按项目配置执行
<项目 linter 命令>
```

- 所有 linter 警告必须修复或明确抑制（附理由）
- 不允许新增 linter 警告

### 第 10 步：运行 formatter

```bash
# 按项目配置执行
<项目 formatter 命令>
```

- 格式化后不应有 diff（说明之前格式不对）
- 如果 formatter 产生 diff，重新检查前 9 步

## 完成标准

- [ ] 10 步清单全部通过
- [ ] `git diff` 中无调试代码残留
- [ ] 无新增 linter 警告
- [ ] 代码格式统一
- [ ] 所有 TODO 有 issue 编号或已解决

## 反模式

| 行为 | 为什么有问题 |
|------|------------|
| "这个 log 留着方便调试" | 用正式日志框架，不要 console.log |
| "注释掉的代码以后可能用到" | Git 有完整历史，不需要注释 |
| "TODO 以后再处理" | 以后 = 永远不会，要么做要么建 issue |
| "any 类型先凑合" | 类型安全是底线，不是可选项 |
| "格式化等 CI 搞" | 本地就能做的事不要推给 CI |
| "这个变量以后会用到" | YAGNI — 用到时再加 |
