# API 测试脚本

这些脚本**严格按照 quickstart.mdx 文档示例编写**，用于验证文档的可用性和准确性。

## 文件说明

- `test-non-stream.sh` - 非流式 API 调用测试（对应 quickstart.mdx 第二步）
- `test-stream.sh` - 流式 API 调用测试（对应 quickstart.mdx 第四步）

## 快速使用

### 1. 本地开发环境测试

```bash
# 测试非流式输出
./test-non-stream.sh

# 测试流式输出
./test-stream.sh
```

默认配置：
- API URL: `http://localhost:3001`
- API Key: `31ad14.b2wPZkLb-Ci93tQy5pjjRQ.iAVKWqYQRMVMA-6x`

### 2. 生产环境测试

```bash
# 设置生产环境 URL 和 API Key
export API_URL="https://huajune.duliday.com"
export API_KEY="your_production_api_key"

# 运行测试
./test-non-stream.sh
./test-stream.sh
```

### 3. 一次性指定参数

```bash
# 非流式测试
API_URL="https://huajune.duliday.com" API_KEY="sk_xxx" ./test-non-stream.sh

# 流式测试
API_URL="https://huajune.duliday.com" API_KEY="sk_xxx" ./test-stream.sh
```

## 验证文档准确性

这些脚本的主要目的是确保 quickstart.mdx 文档中的示例代码可以直接使用。

### 检查要点

#### 非流式输出 (test-non-stream.sh)

✅ 响应应包含：
- `success: true` 字段
- `data.messages` 数组
- `data.usage` 对象（包含 `inputTokens`, `outputTokens`, `totalTokens`）
- `data.tools` 对象

#### 流式输出 (test-stream.sh)

✅ 输出应包含：
- 以 `data: ` 开头的 SSE 格式行
- `{"type":"text.delta","delta":"..."}` 文本增量事件
- `{"type":"finish"}` 消息完成事件
- `data: [DONE]` 流结束标记

## 故障排查

### 连接失败

```bash
curl: (7) Failed to connect to localhost port 3001: Connection refused
```

**解决方法**：
1. 确保开发服务正在运行
2. 检查端口号是否正确
3. 尝试使用生产环境 URL

### 401 未授权错误

```bash
{"error":"Unauthorized","message":"API key invalid"}
```

**解决方法**：
1. 检查 API Key 是否正确
2. 确认 API Key 状态为"已激活"
3. 在 [Wolian AI 平台](https://wolian.cc/platform/clients-management) 查看密钥状态

### 403 禁止访问错误

```bash
{"error":"Forbidden","message":"Model not allowed"}
```

**解决方法**：
1. 使用 `GET /api/v1/models` 查看可用模型列表
2. 确认账户有权限使用该模型

## 注意事项

⚠️ **请勿提交包含真实生产 API Key 的脚本到版本控制系统**

这些脚本使用环境变量来管理敏感信息，确保：
- 生产环境 API Key 仅通过环境变量传递
- 不要修改脚本中的默认 API Key（开发环境专用）
- 使用 `.gitignore` 忽略包含敏感信息的配置文件

## 贡献指南

如果发现文档与实际 API 行为不一致：

1. 运行这些测试脚本验证问题
2. 记录实际响应与文档描述的差异
3. 提交 Issue 或 PR 修复文档

保持这些脚本与 quickstart.mdx 文档同步是确保文档质量的关键！
