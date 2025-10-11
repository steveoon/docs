# 花卷智能体 API 文档

花卷智能体（HuaJune Agent）开放 API 文档，基于 Mintlify 构建。

## 项目结构

```
docs/
├── api-reference/      # API 端点参考文档
├── best-practices/     # 最佳实践指南
├── concepts/          # 核心概念说明
├── features/          # 功能特性文档
├── scripts/           # API 测试脚本
├── index.mdx          # 文档首页
├── quickstart.mdx     # 快速开始指南
└── docs.json          # Mintlify 配置文件
```

## 本地开发

### 1. 安装 Mintlify CLI

```bash
npm i -g mint
```

### 2. 启动预览服务

在 `docs.json` 所在目录运行：

```bash
mint dev
```

文档预览地址：`http://localhost:3000`

### 3. 更新 CLI

如果遇到问题，更新到最新版本：

```bash
mint update
```

## API 测试

项目包含测试脚本用于验证文档的可用性和准确性。

### 快速测试

```bash
# 进入脚本目录
cd scripts/

# 测试非流式 API
./test-non-stream.sh

# 测试流式 API
./test-stream.sh
```

### 使用说明

这些脚本**严格按照 quickstart.mdx 文档示例编写**，确保文档中的代码可以直接使用。

详细使用方法请查看：[scripts/README.md](./scripts/README.md)

**默认配置**：
- API URL: `http://localhost:3001`（需要先启动开发服务）
- API Key: 开发环境测试密钥

**生产环境测试**：
```bash
export API_URL="https://huajune.duliday.com"
export API_KEY="your_api_key"
./test-non-stream.sh
```

## 部署

文档通过 Mintlify GitHub App 自动部署：

1. 在 [Mintlify Dashboard](https://dashboard.mintlify.com/settings/organization/github-app) 安装 GitHub App
2. 推送到默认分支自动触发部署
3. 部署完成后文档自动更新

## 文档质量保证

### 验证文档准确性

在更新文档后，务必运行测试脚本验证：

```bash
# 验证 quickstart.mdx 中的示例
cd scripts/
./test-non-stream.sh
./test-stream.sh
```

### 保持同步

- ✅ 文档示例代码应与实际 API 行为一致
- ✅ 测试脚本应严格复制文档示例
- ✅ 发现不一致时优先更新文档

## 故障排查

### 预览服务无法启动

```bash
mint update  # 更新到最新版本
```

### 页面显示 404

确认当前目录包含有效的 `docs.json` 文件。

### API 测试失败

1. 确认开发服务正在运行（`http://localhost:3001`）
2. 检查 API Key 是否有效
3. 查看详细错误信息

## 参考资源

- [Mintlify 官方文档](https://mintlify.com/docs)
- [花卷智能体 API 文档](https://docs.huajune.com)（部署后的地址）
- [API 规范说明](./API_SPEC.md)
