#!/bin/bash

###############################################################################
# 工具调用 API 测试脚本（流式）
# 严格按照 features/tool-calling.mdx 文档示例编写
# 用于验证文档准确性和实际 API 行为（SSE 流式响应）
# 使用真实的生产数据结构
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

# 使用真实生产数据结构的请求
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
      "preferredBrand": "来伊份",
      "configData": {
        "city": "上海",
        "defaultBrand": "来伊份",
        "stores": [
          {
            "id": "store_307958",
            "name": "沪亭北路六店",
            "location": "上海市-松江区-九里亭街道沪亭北路260号松江公交(九里亭公交枢纽站)",
            "district": "松江区",
            "subarea": "沪亭北路六",
            "coordinates": {
              "lat": 31.1988,
              "lng": 121.3874
            },
            "transportation": "地铁9号线九亭站，步行10分钟",
            "brand": "来伊份",
            "positions": [
              {
                "id": "pos_523940",
                "name": "基础店员",
                "timeSlots": [
                  "15:00~22:00",
                  "09:00~16:00"
                ],
                "salary": {
                  "base": 24,
                  "memo": "结算周期是T+7，举例本周一出勤的工时，下周一结算"
                },
                "workHours": "7",
                "benefits": {
                  "items": [
                    "五险一金",
                    "员工折扣"
                  ]
                },
                "requirements": [
                  "工作认真负责",
                  "团队合作精神",
                  "有相关工作经验者优先"
                ],
                "urgent": false,
                "scheduleType": "flexible",
                "attendancePolicy": {
                  "punctualityRequired": false,
                  "lateToleranceMinutes": 15,
                  "attendanceTracking": "flexible",
                  "makeupShiftsAllowed": true
                },
                "availableSlots": [
                  {
                    "slot": "15:00~22:00",
                    "maxCapacity": 3,
                    "currentBooked": 1,
                    "isAvailable": true,
                    "priority": "high"
                  },
                  {
                    "slot": "09:00~16:00",
                    "maxCapacity": 2,
                    "currentBooked": 1,
                    "isAvailable": true,
                    "priority": "medium"
                  }
                ],
                "schedulingFlexibility": {
                  "canSwapShifts": true,
                  "advanceNoticeHours": 24,
                  "partTimeAllowed": true,
                  "weekendRequired": false,
                  "holidayRequired": false
                },
                "minHoursPerWeek": 20,
                "maxHoursPerWeek": 40,
                "attendanceRequirement": {
                  "minimumDays": 3,
                  "requiredDays": [],
                  "description": "每周至少3天"
                }
              }
            ]
          }
        ],
        "brands": {
          "来伊份": {
            "templates": {
              "initial_inquiry": [
                "你好，来伊份在上海各区有兼职，排班{hours}小时，时薪{salary}元。"
              ],
              "location_inquiry": [
                "离你比较近在{location}的来伊份门店有空缺，排班{schedule}，时薪{salary}元，有兴趣吗？"
              ],
              "no_location_match": [
                "你附近暂时没岗位，{alternative_location}的门店考虑吗？{transport_info}"
              ],
              "interview_request": [
                "可以帮你和店长约面试，加我微信吧，需要几个简单的个人信息。"
              ],
              "salary_inquiry": [
                "基本薪资是{salary}元/小时，每周工作{min_hours}到{max_hours}小时。结算周期是T+7。"
              ],
              "schedule_inquiry": [
                "排班比较灵活，一般是7小时一班，具体可以和店长商量。"
              ],
              "general_chat": [
                "好的，有什么其他问题可以问我。"
              ],
              "age_concern": [
                "我们招聘18-50岁，你的年龄没问题的。"
              ],
              "insurance_inquiry": [
                "有五险一金，还有商业保险。"
              ],
              "followup_chat": [
                "这家门店不合适也没关系，以后还有其他店空缺的，到时候可以再报名。"
              ],
              "attendance_inquiry": [
                "出勤要求是每周至少{minimum_days}天，比较灵活的，可以和店长协商。"
              ],
              "flexibility_inquiry": [
                "排班很灵活，支持换班，也接受兼职。"
              ],
              "attendance_policy_inquiry": [
                "考勤要求不严格，最多可以迟到15分钟，也可以补班。"
              ],
              "work_hours_inquiry": [
                "每周工作20-40小时，可以根据你的时间来安排。"
              ],
              "availability_inquiry": [
                "{time_slot}班次还有{available_spots}个位置，{priority}优先级，可以报名。"
              ],
              "part_time_support": [
                "完全支持兼职，时间可以和其他工作错开安排。"
              ]
            },
            "screening": {
              "age": {
                "min": 18,
                "max": 50,
                "preferred": [20, 30, 40]
              },
              "blacklistKeywords": ["骗子", "不靠谱"],
              "preferredKeywords": ["经验", "稳定", "长期"]
            }
          }
        }
      },
      "replyPrompts": {
        "general_chat": "你是来伊份招聘助手，请用简洁友好的语气与候选人沟通。",
        "initial_inquiry": "介绍来伊份的兼职岗位，时薪24元，工作时间灵活。",
        "salary_inquiry": "说明时薪24元/小时，T+7结算，每周20-40小时，有五险一金和员工折扣。",
        "location_inquiry": "告知松江区沪亭北路门店位置，地铁9号线九亭站可达。",
        "schedule_inquiry": "说明排班灵活，有早班和晚班可选，每班7小时。",
        "age_concern": "说明年龄要求18-50岁。",
        "insurance_inquiry": "说明有五险一金和商业保险。",
        "followup_chat": "保持友好耐心的态度，询问是否还有其他问题。"
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

event_count=$(wc -l < $EVENTS_FILE | tr -d ' ')
echo "提取到的事件数量: $event_count"
echo ""

# 统计事件类型
echo "📊 事件类型统计："
if [ "$event_count" -gt 0 ]; then
  cat $EVENTS_FILE | jq -r '.type' 2>/dev/null | sort | uniq -c | while read count type; do
    echo "   $type: $count 个"
  done
else
  echo "   (无事件)"
fi

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
  if [ -n "$input_event" ]; then
    input_call_id=$(echo "$input_event" | jq -r '.toolCallId')
    if [ "$tool_call_id" = "$input_call_id" ]; then
      echo "   ✅ toolCallId 与 input 事件一致: \"$tool_call_id\""
    else
      echo "   ❌ toolCallId 不一致"
      echo "      input 事件: \"$input_call_id\""
      echo "      output 事件: \"$tool_call_id\""
    fi
  else
    echo "   ⚠️  无法验证 toolCallId 一致性（未找到 input 事件）"
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

# 检查是否成功调用工具
if [ -n "$input_event" ] && [ -n "$output_event" ]; then
  echo "✅ 工具调用成功（input 和 output 事件都存在）"
  echo "✅ 流式响应中包含完整的工具调用流程"
else
  echo "❌ 工具调用不完整"
  if [ -z "$input_event" ]; then
    echo "   - 缺失 tool-input-available 事件"
  fi
  if [ -z "$output_event" ]; then
    echo "   - 缺失 tool-output-available 事件"
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
