---
name: deploy
description: 发布部署流程
version: 1.0.0
tags: [release, deploy, docker, ci]
triggers:
  - "发布部署"
  - "版本发布"
  - "Docker 镜像"
inputs:
  - name: version_type
    description: 版本类型（PATCH/MINOR/MAJOR）
    required: true
  - name: release_notes
    description: 发布说明
    required: false
outputs:
  - name: release_artifact
    description: 发布产物（Docker 镜像/Git tag）
---

# 发布部署流程

## 前置条件
- 所有测试通过（Implement 阶段完成）
- 文档已同步（Doc-Sync 阶段完成）
- 用户验证通过（Verify 阶段完成）
- 代码已合并到主分支

## 流程

### 1. 版本号确定

遵循 [语义化版本](https://semver.org/lang/zh-CN/)：

| 版本类型 | 何时使用 | 示例 |
|---------|---------|------|
| MAJOR | 不兼容的 API 变更 | 1.0.0 → 2.0.0 |
| MINOR | 向后兼容的功能新增 | 1.0.0 → 1.1.0 |
| PATCH | 向后兼容的问题修复 | 1.0.0 → 1.0.1 |

#### 获取当前版本

```bash
# 从 Git tag 获取
git describe --tags --abbrev=0

# 从 package.json 获取
jq -r '.version' package.json

# 从 Cargo.toml 获取
grep '^version' Cargo.toml | head -1 | cut -d'"' -f2
```

#### 计算新版本

```bash
CURRENT_VERSION="1.2.3"
VERSION_TYPE="MINOR"  # PATCH, MINOR, MAJOR

# 拆分版本号
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# 根据类型递增
case $VERSION_TYPE in
  PATCH) PATCH=$((PATCH + 1)) ;;
  MINOR) MINOR=$((MINOR + 1)); PATCH=0 ;;
  MAJOR) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo "New version: $NEW_VERSION"
```

### 2. Docker 镜像构建

#### Dockerfile 最佳实践

```dockerfile
# 多阶段构建
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# 最终镜像
FROM alpine:3.18

RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/main .
COPY --from=builder /app/config ./config

EXPOSE 8080
CMD ["./main"]
```

#### 构建命令

```bash
# 构建镜像
docker build -t myapp:${NEW_VERSION} .
docker build -t myapp:latest .

# 测试镜像
docker run --rm myapp:${NEW_VERSION} --version
```

### 3. 推送到 ACR

#### Azure Container Registry

```bash
# 登录 ACR
az acr login --name myregistry

# 打标签
docker tag myapp:${NEW_VERSION} myregistry.azurecr.io/myapp:${NEW_VERSION}
docker tag myapp:${NEW_VERSION} myregistry.azurecr.io/myapp:latest

# 推送
docker push myregistry.azurecr.io/myapp:${NEW_VERSION}
docker push myregistry.azurecr.io/myapp:latest
```

#### GitHub Container Registry

```bash
# 登录 GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# 打标签
docker tag myapp:${NEW_VERSION} ghcr.io/USERNAME/myapp:${NEW_VERSION}
docker tag myapp:${NEW_VERSION} ghcr.io/USERNAME/myapp:latest

# 推送
docker push ghcr.io/USERNAME/myapp:${NEW_VERSION}
docker push ghcr.io/USERNAME/myapp:latest
```

### 4. 更新 CHANGELOG

```markdown
# Changelog

## [1.3.0] - 2026-06-02

### Added
- 新增用户认证模块
- 新增 API 限流功能

### Changed
- 优化数据库查询性能

### Fixed
- 修复登录超时问题

## [1.2.3] - 2026-05-28

### Fixed
- 修复配置文件加载错误
```

#### 自动生成 CHANGELOG

```bash
# 使用 conventional-changelog
npx conventional-changelog -p angular -i CHANGELOG.md -s

# 或使用 git log
git log --oneline --no-merges v1.2.3..HEAD
```

### 5. 创建 Git tag + GitHub Release

```bash
# 创建 Git tag
git tag -a v${NEW_VERSION} -m "Release v${NEW_VERSION}"
git push origin v${NEW_VERSION}

# 创建 GitHub Release
gh release create v${NEW_VERSION} \
  --title "Release v${NEW_VERSION}" \
  --notes-file RELEASE_NOTES.md \
  --draft=false \
  --prerelease=false
```

#### GitHub Actions 自动化

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to ACR
        uses: azure/docker-login@v1
        with:
          login-server: myregistry.azurecr.io
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}
      
      - name: Extract version
        id: version
        run: echo "version=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          push: true
          tags: |
            myregistry.azurecr.io/myapp:${{ steps.version.outputs.version }}
            myregistry.azurecr.io/myapp:latest
      
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          generate_release_notes: true
```

## 完成标准
- [ ] 版本号已确定（遵循语义化版本）
- [ ] Docker 镜像已构建并测试
- [ ] 镜像已推送到 ACR
- [ ] CHANGELOG 已更新
- [ ] Git tag 已创建
- [ ] GitHub Release 已创建

## 参考
- `workflow/develop.feature.md` — 完整需求开发流程
- [语义化版本](https://semver.org/lang/zh-CN/)
- [Docker 最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [GitHub Actions](https://docs.github.com/en/actions)
