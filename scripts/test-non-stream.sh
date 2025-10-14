#!/bin/bash

###############################################################################
# 非流式 API 测试脚本
# 严格按照 quickstart.mdx 第二步示例编写
# 用于验证文档可用性
###############################################################################

# 配置项（可通过环境变量覆盖）
API_URL="${API_URL:-http://localhost:3001}"
API_KEY="${API_KEY:-your_api_key_here}"

echo "================================================"
echo "测试：非流式 API 调用"
echo "来源：quickstart.mdx 第二步示例"
echo "================================================"
echo "API URL: $API_URL"
echo "------------------------------------------------"
echo ""

# 完全按照文档示例的 cURL 命令（仅替换 URL 和 API Key）
curl -X POST ${API_URL}/api/v1/chat \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-3-7-sonnet-20250219",
    "messages": [
      {
        "role": "user",
        "content": "你好，请介绍一下你自己"
      }
    ],
    "stream": false
  }'

echo ""
echo ""
echo "================================================"
echo "测试完成"
echo "================================================"
echo ""
echo "预期响应格式（参考 quickstart.mdx 第三步）："
echo '{'
echo '  "success": true,'
echo '  "data": {'
echo '    "messages": [{ "id": "...", "role": "assistant", "parts": [...] }],'
echo '    "usage": { "inputTokens": ..., "outputTokens": ..., "totalTokens": ... },'
echo '    "tools": { "used": [], "skipped": [] }'
echo '  }'
echo '}'
