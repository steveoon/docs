#!/bin/bash

###############################################################################
# 工具调用 API 测试脚本（流式）
# 严格按照 features/tool-calling.mdx 文档示例编写
# 用于验证文档准确性和实际 API 行为（SSE 流式响应）
###############################################################################

# 配置项（可通过环境变量覆盖）
API_URL="${API_URL:-http://localhost:3001}"
API_KEY="${API_KEY:-your_api_key_here}"
OUTPUT_FILE="/tmp/tool-calling-stream-output.txt"
EVENTS_FILE="/tmp/tool-calling-stream-events.jsonl"

echo "================================================"
echo "测试：工具调用 API（流式）"
echo "来源：features/tool-calling.mdx 文档"
echo "================================================"
echo "API URL: $API_URL"
echo "输出文件: $OUTPUT_FILE"
echo "事件文件: $EVENTS_FILE"
echo "------------------------------------------------"
echo ""

# 完全按照文档示例的请求（参考 features/tool-calling.mdx 流式响应部分）
# 显式设置 stream: true（或依赖默认行为）
echo "📤 发送请求（stream: true）..."
curl -X POST ${API_URL}/api/v1/chat \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-3-7-sonnet-20250219",
    "stream": true,
    "messages": [
      {
        "role": "user",
        "content": "候选人问：你们薪资待遇怎么样？"
      }
    ],
    "allowedTools": ["zhipin_reply_generator"],
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
  }' 2>/dev/null | tee $OUTPUT_FILE

echo ""
echo "================================================"
echo "📋 解析 SSE 事件流"
echo "================================================"
echo ""

# 解析 SSE 事件，提取 data: 后面的 JSON
grep "^data: " $OUTPUT_FILE | sed 's/^data: //' > $EVENTS_FILE

echo "提取到的事件数量: $(wc -l < $EVENTS_FILE)"
echo ""

# 统计事件类型
echo "📊 事件类型统计："
cat $EVENTS_FILE | jq -r '.type' 2>/dev/null | sort | uniq -c | while read count type; do
  echo "   $type: $count 个"
done

echo ""
echo "================================================"
echo "📋 验证工具调用事件（对照文档）"
echo "================================================"
echo ""

# 查找 tool-input-available 事件
echo "1️⃣ tool-input-available 事件"
input_event=$(cat $EVENTS_FILE | jq -c 'select(.type == "tool-input-available")' 2>/dev/null | head -n 1)

if [ -n "$input_event" ]; then
  echo "   ✅ 找到 tool-input-available 事件"

  tool_name=$(echo "$input_event" | jq -r '.toolName')
  tool_call_id=$(echo "$input_event" | jq -r '.toolCallId')
  has_input=$(echo "$input_event" | jq 'has("input")')

  echo ""
  echo "   📦 字段验证："

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

  # 验证 input 字段
  if [ "$has_input" = "true" ]; then
    echo "   ✅ input: 存在"

    # 检查参数命名
    echo ""
    echo "   📝 input 字段命名："
    input_keys=$(echo "$input_event" | jq -r '.input | keys[]' 2>/dev/null)
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

  echo ""
  echo "   📄 完整 tool-input-available 事件："
  echo "$input_event" | jq '.'

else
  echo "   ❌ 未找到 tool-input-available 事件"
fi

echo ""
echo "2️⃣ tool-output-available 事件"
output_event=$(cat $EVENTS_FILE | jq -c 'select(.type == "tool-output-available")' 2>/dev/null | head -n 1)

if [ -n "$output_event" ]; then
  echo "   ✅ 找到 tool-output-available 事件"

  tool_call_id=$(echo "$output_event" | jq -r '.toolCallId')
  has_output=$(echo "$output_event" | jq 'has("output")')

  echo ""
  echo "   📦 字段验证："

  # 验证 toolCallId 与 input 事件一致
  input_call_id=$(echo "$input_event" | jq -r '.toolCallId')
  if [ "$tool_call_id" = "$input_call_id" ]; then
    echo "   ✅ toolCallId 与 input 事件一致: \"$tool_call_id\""
  else
    echo "   ❌ toolCallId 不一致"
    echo "      input 事件: \"$input_call_id\""
    echo "      output 事件: \"$tool_call_id\""
  fi

  # 验证 output 字段
  if [ "$has_output" = "true" ]; then
    echo "   ✅ output: 存在"
  else
    echo "   ❌ output: 缺失"
  fi

  echo ""
  echo "   📄 完整 tool-output-available 事件："
  echo "$output_event" | jq '.'

else
  echo "   ❌ 未找到 tool-output-available 事件"
fi

echo ""
echo "================================================"
echo "📊 文档一致性检查总结"
echo "================================================"
echo ""

echo "关键验证项（对照 features/tool-calling.mdx）："
echo ""

# 1. 检查事件类型命名
has_tool_start=$(cat $EVENTS_FILE | jq 'select(.type == "tool.start")' 2>/dev/null | wc -l)
has_tool_complete=$(cat $EVENTS_FILE | jq 'select(.type == "tool.complete")' 2>/dev/null | wc -l)

if [ "$has_tool_start" -gt 0 ] || [ "$has_tool_complete" -gt 0 ]; then
  echo "⚠️  发现 tool.start 或 tool.complete 事件"
  echo "   文档示例使用这些事件名，但实际 API 返回的是："
  echo "   - tool-input-available（对应 tool.start）"
  echo "   - tool-output-available（对应 tool.complete）"
  echo ""
fi

# 2. 检查是否有 args 字段
has_args=$(cat $EVENTS_FILE | jq 'select(.args != null)' 2>/dev/null | wc -l)
if [ "$has_args" -gt 0 ]; then
  echo "❌ 文档错误: 事件包含 args 字段"
  echo "   文档描述应该是 input 字段"
  echo ""
fi

# 3. 检查参数命名约定
if [ -n "$input_event" ]; then
  snake_case_count=$(echo "$input_event" | jq '[.input | keys[] | select(test("_"))] | length' 2>/dev/null)
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
echo "2. 流式响应包含多种事件类型（start, tool-input-available, tool-output-available, done）"
echo "3. 完整响应已保存到: $OUTPUT_FILE"
echo "4. 解析后的事件已保存到: $EVENTS_FILE"
echo ""
