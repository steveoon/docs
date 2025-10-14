#!/bin/bash

###############################################################################
# 流式输出 API 测试脚本
# 严格按照 quickstart.mdx 第四步示例编写
# 用于验证文档可用性
###############################################################################

# 配置项（可通过环境变量覆盖）
API_URL="${API_URL:-http://localhost:3001}"
API_KEY="${API_KEY:-your_api_key_here}"

echo "================================================"
echo "测试：流式 API 调用"
echo "来源：quickstart.mdx 第四步示例"
echo "================================================"
echo "API URL: $API_URL"
echo "------------------------------------------------"
echo ""

# 完全按照文档示例的请求（仅替换 URL 和 API Key）
# 注意：使用 -N 参数禁用缓冲，确保实时显示流式输出
curl -N -X POST ${API_URL}/api/v1/chat \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-3-7-sonnet-20250219",
    "messages": [
      {
        "role": "user",
        "content": "作为餐饮招聘助手，介绍一下服务员岗位"
      }
    ],
    "stream": true
  }'

echo ""
echo ""
echo "================================================"
echo "测试完成"
echo "================================================"
echo ""
echo "预期输出特征（参考 quickstart.mdx 第四步）："
echo "1. 响应以 'data: ' 开头的 SSE 格式行"
echo "2. 包含 {\"type\":\"text.delta\",\"delta\":\"...\"} 事件"
echo "3. 包含 {\"type\":\"finish\"} 消息完成事件"
echo "4. 以 'data: [DONE]' 结束"
