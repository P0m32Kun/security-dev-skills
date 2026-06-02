---
title: "API 名称"
last_updated: "YYYY-MM-DD"
related_code: []
version: "1.0.0"
base_url: "/api/v1"
---

# API 名称

## 概述

简要描述 API 的用途。

## 认证

- 方式：Bearer Token / API Key
- 头部：`Authorization: Bearer <token>`

## 接口列表

### GET /api/v1/resource

获取资源列表。

**请求参数：**

| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| page | integer | 否 | 页码，默认 1 |
| limit | integer | 否 | 每页数量，默认 20 |

**响应：**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [],
    "total": 0,
    "page": 1,
    "limit": 20
  }
}
```

**错误码：**

| code | 描述 |
|------|------|
| 401 | 未认证 |
| 403 | 无权限 |

---

### POST /api/v1/resource

创建资源。

**请求体：**

```json
{
  "name": "string",
  "description": "string"
}
```

**响应：**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": "string",
    "name": "string",
    "created_at": "2026-06-02T00:00:00Z"
  }
}
```

---

### PUT /api/v1/resource/:id

更新资源。

### DELETE /api/v1/resource/:id

删除资源。

## 变更记录

| 日期 | 版本 | 变更内容 | 作者 |
|------|------|---------|------|
| YYYY-MM-DD | 1.0.0 | 初始版本 | — |
