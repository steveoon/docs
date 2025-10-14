#!/bin/bash

###############################################################################
# 工具调用 API 测试脚本（非流式）
# 严格按照 features/tool-calling.mdx 文档示例编写
# 用于验证文档准确性和实际 API 行为
###############################################################################

# 配置项（可通过环境变量覆盖）
API_URL="${API_URL:-http://localhost:3001}"
API_KEY="${API_KEY:-your_api_key_here}"
OUTPUT_FILE="/tmp/tool-calling-non-stream-output.json"

echo "================================================"
echo "测试：工具调用 API（非流式）"
echo "来源：features/tool-calling.mdx 文档"
echo "================================================"
echo "API URL: $API_URL"
echo "输出文件: $OUTPUT_FILE"
echo "------------------------------------------------"
echo ""

# 完全按照文档示例的请求（参考 features/tool-calling.mdx 基础用法）
# 显式设置 stream: false
echo "📤 发送请求（stream: false）..."
curl -X POST ${API_URL}/api/v1/chat \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-3-7-sonnet-20250219",
    "stream": false,
    "messages": [
      {
        "role": "user",
        "content": "候选人问：你们薪资待遇怎么样？"
      }
    ],
    "allowedTools": ["zhipin_reply_generator"],
    "contextStrategy": "skip",
    "context": {
      "preferredBrand": "蜀地源冒菜",
      "configData": {
        "city": "上海",
        "brands": {
          "蜀地源冒菜": {
            "templates": {
              "salary_inquiry": ["基本工资4000-6000元，另有全勤奖、绩效奖等"]
            }
          }
        }
      },
      "replyPrompts": {
        "salary_inquiry": "用礼貌的语气说明薪资待遇，避免承诺无法兑现的条件"
      }
    }
  }' 2>/dev/null | tee $OUTPUT_FILE | jq '.'

echo ""
echo "================================================"
echo "📋 验证响应结构（对照文档）"
echo "================================================"
echo ""

# 验证函数
verify_field() {
  local field=$1
  local expected=$2
  local actual=$(jq -r "$field" $OUTPUT_FILE 2>/dev/null)

  if [ "$actual" = "null" ] || [ -z "$actual" ]; then
    echo "❌ 缺失字段: $field"
    return 1
  elif [ -n "$expected" ] && [ "$actual" != "$expected" ]; then
    echo "❌ 字段值不匹配: $field"
    echo "   期望: $expected"
    echo "   实际: $actual"
    return 1
  else
    echo "✅ $field: $actual"
    return 0
  fi
}

# 验证基础响应结构
echo "1️⃣ 基础响应结构"
verify_field ".success" "true"
verify_field ".data" ""

echo ""
echo "2️⃣ 消息数组"
msg_count=$(jq '.data.messages | length' $OUTPUT_FILE 2>/dev/null)
echo "   消息数量: $msg_count"

if [ "$msg_count" -gt 0 ]; then
  echo "   ✅ 包含 messages 数组"
else
  echo "   ❌ messages 数组为空"
fi

echo ""
echo "3️⃣ dynamic-tool 结构验证（核心）"
# 查找包含 dynamic-tool 的消息
has_dynamic_tool=$(jq '[.data.messages[].parts[] | select(.type == "dynamic-tool")] | length' $OUTPUT_FILE 2>/dev/null)

if [ "$has_dynamic_tool" -gt 0 ]; then
  echo "   ✅ 找到 dynamic-tool part"

  # 提取第一个 dynamic-tool part
  tool_part=$(jq '[.data.messages[].parts[] | select(.type == "dynamic-tool")][0]' $OUTPUT_FILE 2>/dev/null)

  # 验证 dynamic-tool 的必需字段
  echo ""
  echo "   📦 dynamic-tool 字段验证："

  tool_type=$(echo "$tool_part" | jq -r '.type')
  tool_name=$(echo "$tool_part" | jq -r '.toolName')
  tool_call_id=$(echo "$tool_part" | jq -r '.toolCallId')
  tool_state=$(echo "$tool_part" | jq -r '.state')

  # 验证 type
  if [ "$tool_type" = "dynamic-tool" ]; then
    echo "   ✅ type: \"dynamic-tool\""
  else
    echo "   ❌ type 错误: \"$tool_type\"（期望: \"dynamic-tool\"）"
  fi

  # 验证 toolName
  if [ "$tool_name" = "zhipin_reply_generator" ]; then
    echo "   ✅ toolName: \"zhipin_reply_generator\""
  else
    echo "   ❌ toolName 错误: \"$tool_name\""
  fi

  # 验证 toolCallId
  if [ "$tool_call_id" != "null" ] && [ -n "$tool_call_id" ]; then
    echo "   ✅ toolCallId: \"$tool_call_id\""
  else
    echo "   ❌ toolCallId 缺失或为 null"
  fi

  # 验证 state
  if [ "$tool_state" = "output-available" ] || [ "$tool_state" = "input-available" ]; then
    echo "   ✅ state: \"$tool_state\""
  else
    echo "   ❌ state 错误: \"$tool_state\"（期望: \"output-available\" 或 \"input-available\"）"
  fi

  # 验证 input 字段
  has_input=$(echo "$tool_part" | jq 'has("input")' 2>/dev/null)
  if [ "$has_input" = "true" ]; then
    echo "   ✅ input: 存在"

    # 检查是否使用 snake_case
    input_keys=$(echo "$tool_part" | jq -r '.input | keys[]' 2>/dev/null)
    echo "   📝 input 字段命名："
    echo "$input_keys" | while read key; do
      if echo "$key" | grep -q "_"; then
        echo "      ✅ $key (snake_case)"
      else
        echo "      ⚠️  $key (可能不是 snake_case)"
      fi
    done
  else
    echo "   ❌ input: 缺失"
  fi

  # 验证 output 字段（仅当 state 为 output-available 时）
  if [ "$tool_state" = "output-available" ]; then
    has_output=$(echo "$tool_part" | jq 'has("output")' 2>/dev/null)
    if [ "$has_output" = "true" ]; then
      echo "   ✅ output: 存在"
    else
      echo "   ❌ output: 缺失（state 为 output-available 时应该存在）"
    fi
  fi

  echo ""
  echo "   📄 完整 dynamic-tool 结构："
  echo "$tool_part" | jq '.'

else
  echo "   ❌ 未找到 dynamic-tool part"
  echo "   ⚠️  这与文档描述不符！"
  echo ""
  echo "   📋 实际返回的 part types:"
  jq '[.data.messages[].parts[].type] | unique' $OUTPUT_FILE 2>/dev/null
fi

echo ""
echo "4️⃣ Usage 统计"
verify_field ".data.usage.inputTokens" ""
verify_field ".data.usage.outputTokens" ""
verify_field ".data.usage.totalTokens" ""

echo ""
echo "5️⃣ Tools 信息"
tools_used=$(jq '.data.tools.used' $OUTPUT_FILE 2>/dev/null)
tools_skipped=$(jq '.data.tools.skipped' $OUTPUT_FILE 2>/dev/null)

if [ "$tools_used" != "null" ]; then
  echo "   ✅ tools.used: $tools_used"
else
  echo "   ⚠️  tools.used: 缺失"
fi

if [ "$tools_skipped" != "null" ]; then
  echo "   ✅ tools.skipped: $tools_skipped"
else
  echo "   ⚠️  tools.skipped: 缺失"
fi

echo ""
echo "================================================"
echo "📊 文档一致性检查总结"
echo "================================================"
echo ""

# 关键检查项
echo "关键验证项（对照 features/tool-calling.mdx）："
echo ""

# 1. 是否使用 dynamic-tool 而非 tool-call/tool-result
has_tool_call=$(jq '[.data.messages[].parts[] | select(.type == "tool-call")] | length' $OUTPUT_FILE 2>/dev/null)
has_tool_result=$(jq '[.data.messages[].parts[] | select(.type == "tool-result")] | length' $OUTPUT_FILE 2>/dev/null)

if [ "$has_tool_call" -gt 0 ] || [ "$has_tool_result" -gt 0 ]; then
  echo "❌ 文档错误: 响应包含 tool-call 或 tool-result"
  echo "   文档应该描述为 dynamic-tool，而非分离的 tool-call/tool-result"
fi

# 2. 是否使用 args 而非 input
has_args=$(jq '[.data.messages[].parts[] | select(.args != null)] | length' $OUTPUT_FILE 2>/dev/null)
if [ "$has_args" -gt 0 ]; then
  echo "❌ 文档错误: 响应使用 args 字段"
  echo "   文档描述应该是 input 字段"
fi

# 3. 是否有单独的 role: tool 消息
has_tool_role=$(jq '[.data.messages[] | select(.role == "tool")] | length' $OUTPUT_FILE 2>/dev/null)
if [ "$has_tool_role" -gt 0 ]; then
  echo "❌ 文档错误: 响应包含 role: \"tool\" 的消息"
  echo "   文档应该说明所有内容都在 role: \"assistant\" 中"
fi

# 4. 参数命名约定
if [ "$has_dynamic_tool" -gt 0 ]; then
  snake_case_count=$(echo "$tool_part" | jq '[.input | keys[] | select(test("_"))] | length' 2>/dev/null)
  if [ "$snake_case_count" -gt 0 ]; then
    echo "✅ 参数使用 snake_case 命名（与文档一致）"
  fi
fi

echo ""
echo "================================================"
echo "测试完成"
echo "================================================"
echo ""
echo "💡 提示："
echo "1. 检查上述验证结果中的 ❌ 标记"
echo "2. 如果发现文档与实际不符，需要更新文档"
echo "3. 完整响应已保存到: $OUTPUT_FILE"
echo ""
