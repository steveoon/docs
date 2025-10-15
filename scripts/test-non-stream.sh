#!/bin/bash

###############################################################################
# 非流式 API 测试脚本
# 严格按照 features/text-chat.mdx "基础对话" 示例编写
# 用于验证文档的准确性和 API 响应的完整性
###############################################################################

# 配置项（可通过环境变量覆盖）
API_URL="${API_URL:-http://localhost:3001}"
API_KEY="${API_KEY:-your_api_key_here}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "================================================"
echo "测试：非流式 API 调用（基础对话）"
echo "来源：features/text-chat.mdx 基础对话示例"
echo "================================================"
echo "API URL: $API_URL"
echo "输出文件: /tmp/test-non-stream-output.json"
echo "------------------------------------------------"
echo ""

# 临时文件
OUTPUT_FILE="/tmp/test-non-stream-output.json"

# 完全按照 text-chat.mdx 基础对话示例的 cURL 命令
echo "📤 发送请求（stream: false）..."
curl -s -X POST ${API_URL}/api/v1/chat \
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
  }' > "$OUTPUT_FILE"

echo ""
echo "================================================"
echo "📋 验证响应结构（对照 text-chat.mdx 文档）"
echo "================================================"
echo ""

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  jq 未安装，跳过自动验证${NC}"
    echo "完整响应已保存到: $OUTPUT_FILE"
    echo ""
    echo "手动检查响应内容："
    cat "$OUTPUT_FILE"
    exit 0
fi

# 验证函数
check_field() {
    local field=$1
    local description=$2
    local value=$(jq -r "$field" "$OUTPUT_FILE" 2>/dev/null)

    if [ "$value" != "null" ] && [ -n "$value" ]; then
        echo -e "${GREEN}✅ $description${NC}"
        return 0
    else
        echo -e "${RED}❌ 缺失字段: $field${NC}"
        return 1
    fi
}

check_field_optional() {
    local field=$1
    local description=$2
    local value=$(jq -r "$field" "$OUTPUT_FILE" 2>/dev/null)

    if [ "$value" != "null" ] && [ -n "$value" ]; then
        echo -e "${GREEN}✅ $description (值: $value)${NC}"
    else
        echo -e "${YELLOW}⚠️  $description (未返回，属于可选字段)${NC}"
    fi
}

# 1. 基础响应结构
echo "1️⃣ 基础响应结构"
check_field ".success" "success 字段"
check_field ".data" "data 对象"
echo ""

# 2. 消息数组
echo "2️⃣ 消息数组"
message_count=$(jq '.data.messages | length' "$OUTPUT_FILE" 2>/dev/null)
if [ "$message_count" -gt 0 ]; then
    echo -e "${GREEN}✅ 消息数量: $message_count${NC}"

    # 检查第一条消息的结构
    check_field ".data.messages[0].id" "消息 ID"
    check_field ".data.messages[0].role" "消息 role"

    role=$(jq -r '.data.messages[0].role' "$OUTPUT_FILE" 2>/dev/null)
    if [ "$role" = "assistant" ]; then
        echo -e "${GREEN}✅ role 为 'assistant'${NC}"
    else
        echo -e "${RED}❌ role 应为 'assistant'，实际为: $role${NC}"
    fi

    # 检查 parts 数组
    parts_count=$(jq '.data.messages[0].parts | length' "$OUTPUT_FILE" 2>/dev/null)
    if [ "$parts_count" -gt 0 ]; then
        echo -e "${GREEN}✅ parts 数量: $parts_count${NC}"

        # 检查 part 结构
        part_type=$(jq -r '.data.messages[0].parts[0].type' "$OUTPUT_FILE" 2>/dev/null)
        part_state=$(jq -r '.data.messages[0].parts[0].state' "$OUTPUT_FILE" 2>/dev/null)

        if [ "$part_type" = "text" ]; then
            echo -e "${GREEN}✅ part.type 为 'text'${NC}"
        else
            echo -e "${RED}❌ part.type 应为 'text'，实际为: $part_type${NC}"
        fi

        if [ "$part_state" = "done" ]; then
            echo -e "${GREEN}✅ part.state 为 'done'${NC}"
        else
            echo -e "${YELLOW}⚠️  part.state 应为 'done'，实际为: $part_state${NC}"
        fi

        check_field ".data.messages[0].parts[0].text" "part.text 内容"
    else
        echo -e "${RED}❌ parts 数组为空${NC}"
    fi
else
    echo -e "${RED}❌ messages 数组为空${NC}"
fi
echo ""

# 3. Usage 统计（根据 text-chat.mdx 文档）
echo "3️⃣ Usage 统计"
check_field ".data.usage.inputTokens" "inputTokens"
check_field ".data.usage.outputTokens" "outputTokens"
check_field ".data.usage.totalTokens" "totalTokens"

# 可选字段（根据更新后的文档）
check_field_optional ".data.usage.reasoningTokens" "reasoningTokens (可选)"
check_field_optional ".data.usage.cachedInputTokens" "cachedInputTokens (可选)"
echo ""

# 4. Tools 信息（根据更新后的文档，这是必需字段）
echo "4️⃣ Tools 信息"
check_field ".data.tools" "tools 对象"
check_field ".data.tools.used" "tools.used 数组"
check_field ".data.tools.skipped" "tools.skipped 数组"

tools_used=$(jq -r '.data.tools.used | length' "$OUTPUT_FILE" 2>/dev/null)
tools_skipped=$(jq -r '.data.tools.skipped | length' "$OUTPUT_FILE" 2>/dev/null)

if [ "$tools_used" != "null" ]; then
    echo -e "${BLUE}   tools.used 数量: $tools_used${NC}"
fi
if [ "$tools_skipped" != "null" ]; then
    echo -e "${BLUE}   tools.skipped 数量: $tools_skipped${NC}"
fi
echo ""

# 5. 提取回复文本（验证访问路径）
echo "5️⃣ 提取回复文本（验证文档中的访问路径）"
reply_text=$(jq -r '.data.messages[0].parts[0].text' "$OUTPUT_FILE" 2>/dev/null)

if [ "$reply_text" != "null" ] && [ -n "$reply_text" ] && [ "$reply_text" != "" ]; then
    echo -e "${GREEN}✅ 成功提取回复文本${NC}"
    echo -e "${BLUE}回复内容预览:${NC}"
    echo "$reply_text" | head -c 200
    if [ ${#reply_text} -gt 200 ]; then
        echo "..."
    fi
else
    echo -e "${RED}❌ 无法提取回复文本${NC}"
fi
echo ""

echo "================================================"
echo "📊 文档一致性检查总结"
echo "================================================"
echo ""

# 关键验证项
echo "关键验证项（对照 features/text-chat.mdx）："
echo ""

success=$(jq -r '.success' "$OUTPUT_FILE" 2>/dev/null)
has_messages=$(jq '.data.messages | length' "$OUTPUT_FILE" 2>/dev/null)
has_usage=$(jq '.data | has("usage")' "$OUTPUT_FILE" 2>/dev/null)
has_tools=$(jq '.data | has("tools")' "$OUTPUT_FILE" 2>/dev/null)

if [ "$success" = "true" ] && [ "$has_messages" -gt 0 ] && [ "$has_usage" = "true" ] && [ "$has_tools" = "true" ]; then
    echo -e "${GREEN}✅ 响应结构完全符合 text-chat.mdx 文档描述${NC}"
    echo -e "${GREEN}✅ 包含所有必需字段（success, messages, usage, tools）${NC}"
    echo -e "${GREEN}✅ 文档示例代码可用${NC}"
else
    echo -e "${RED}❌ 响应结构与文档不一致${NC}"
    echo -e "${YELLOW}请检查：${NC}"
    echo "   - success: $success (期望: true)"
    echo "   - messages 数量: $has_messages (期望: > 0)"
    echo "   - 包含 usage: $has_usage (期望: true)"
    echo "   - 包含 tools: $has_tools (期望: true)"
fi

echo ""
echo "================================================"
echo "测试完成"
echo "================================================"
echo ""
echo "💡 提示："
echo "1. 完整响应已保存到: $OUTPUT_FILE"
echo "2. 可使用 'jq . $OUTPUT_FILE' 查看格式化的 JSON"
echo "3. 如果测试失败，请对照 features/text-chat.mdx 检查 API 实现"
echo ""
