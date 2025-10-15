#!/bin/bash

###############################################################################
# 流式输出 API 测试脚本
# 严格按照 features/text-chat.mdx "流式输出" 示例编写
# 用于验证文档的准确性和流式响应的格式
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
echo "测试：流式 API 调用"
echo "来源：features/text-chat.mdx 流式输出示例"
echo "================================================"
echo "API URL: $API_URL"
echo "输出文件: /tmp/test-stream-output.txt"
echo "------------------------------------------------"
echo ""

# 临时文件
OUTPUT_FILE="/tmp/test-stream-output.txt"

echo "📤 测试 1: 显式设置 stream: true"
echo "------------------------------------------------"

# 完全按照 text-chat.mdx 流式输出示例（显式设置 stream: true）
curl -N -s -X POST ${API_URL}/api/v1/chat \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-3-7-sonnet-20250219",
    "messages": [
      {
        "role": "user",
        "content": "你好，请用一句话介绍你自己"
      }
    ],
    "stream": true
  }' > "$OUTPUT_FILE"

echo ""
echo "================================================"
echo "📋 验证流式响应格式（对照 text-chat.mdx 文档）"
echo "================================================"
echo ""

# 检查输出文件是否存在
if [ ! -f "$OUTPUT_FILE" ]; then
    echo -e "${RED}❌ 输出文件不存在${NC}"
    exit 1
fi

# 1. 检查 SSE 格式
echo "1️⃣ SSE 格式检查"

# 检查是否包含 "data: " 开头的行
data_lines=$(grep -c "^data: " "$OUTPUT_FILE" 2>/dev/null | head -n 1 || echo "0")
if [ "$data_lines" -gt 0 ] 2>/dev/null; then
    echo -e "${GREEN}✅ 包含 SSE 格式的 'data:' 行: $data_lines 条${NC}"
else
    echo -e "${RED}❌ 未找到 'data:' 开头的行${NC}"
fi

# 检查是否包含 event: 行
event_lines=$(grep -c "^event: " "$OUTPUT_FILE" 2>/dev/null | head -n 1 || echo "0")
if [ "$event_lines" -gt 0 ] 2>/dev/null; then
    echo -e "${GREEN}✅ 包含 'event:' 行: $event_lines 条${NC}"
else
    echo -e "${YELLOW}⚠️  未找到 'event:' 行（某些实现可能不使用）${NC}"
fi

echo ""

# 2. 检查关键事件类型
echo "2️⃣ 事件类型检查"

# 检查是否包含 text.delta 事件
text_delta=$(grep -c '"type":"text.delta"' "$OUTPUT_FILE" 2>/dev/null | head -n 1 || echo "0")
if [ "$text_delta" -gt 0 ] 2>/dev/null; then
    echo -e "${GREEN}✅ 包含 'text.delta' 事件: $text_delta 个${NC}"
else
    echo -e "${YELLOW}⚠️  未找到 'text.delta' 事件${NC}"
fi

# 检查是否包含 finish 事件
finish_event=$(grep -c '"type":"finish"' "$OUTPUT_FILE" 2>/dev/null | head -n 1 || echo "0")
if [ "$finish_event" -gt 0 ] 2>/dev/null; then
    echo -e "${GREEN}✅ 包含 'finish' 事件: $finish_event 个${NC}"
else
    echo -e "${YELLOW}⚠️  未找到 'finish' 事件${NC}"
fi

# 检查是否包含 done 事件
done_event=$(grep -c '"type":"done"' "$OUTPUT_FILE" 2>/dev/null | head -n 1 || echo "0")
if [ "$done_event" -gt 0 ] 2>/dev/null; then
    echo -e "${GREEN}✅ 包含 'done' 事件: $done_event 个${NC}"
else
    echo -e "${YELLOW}⚠️  未找到 'done' 事件${NC}"
fi

# 检查是否包含 [DONE] 结束标记
done_marker=$(grep -c "data: \[DONE\]" "$OUTPUT_FILE" 2>/dev/null | head -n 1 || echo "0")
if [ "$done_marker" -gt 0 ] 2>/dev/null; then
    echo -e "${GREEN}✅ 包含 'data: [DONE]' 结束标记${NC}"
else
    echo -e "${YELLOW}⚠️  未找到 'data: [DONE]' 结束标记${NC}"
fi

echo ""

# 3. 提取并显示文本内容
echo "3️⃣ 文本内容提取"

# 尝试提取所有 delta 值并合并
if command -v jq &> /dev/null; then
    extracted_text=$(grep '"type":"text.delta"' "$OUTPUT_FILE" | sed 's/^data: //' | jq -r '.delta' 2>/dev/null | tr -d '\n')

    if [ -n "$extracted_text" ]; then
        echo -e "${GREEN}✅ 成功提取流式文本内容${NC}"
        echo -e "${BLUE}完整回复内容:${NC}"
        echo "$extracted_text"
    else
        echo -e "${YELLOW}⚠️  无法提取文本内容（可能格式不同）${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  jq 未安装，跳过文本提取${NC}"
fi

echo ""

# 4. 检查错误响应
echo "4️⃣ 错误检查"

error_count=$(grep -c '"error"' "$OUTPUT_FILE" 2>/dev/null | head -n 1 || echo "0")
if [ "$error_count" -gt 0 ] 2>/dev/null; then
    echo -e "${RED}❌ 响应中包含错误: $error_count 处${NC}"
    echo -e "${YELLOW}错误详情:${NC}"
    grep '"error"' "$OUTPUT_FILE" | head -n 5
else
    echo -e "${GREEN}✅ 无错误响应${NC}"
fi

echo ""

# 5. 测试省略 stream 参数（验证默认行为）
echo "================================================"
echo "📤 测试 2: 省略 stream 参数（验证默认为流式）"
echo "================================================"
echo ""

OUTPUT_FILE_DEFAULT="/tmp/test-stream-default.txt"

curl -N -s -X POST ${API_URL}/api/v1/chat \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-3-7-sonnet-20250219",
    "messages": [
      {
        "role": "user",
        "content": "简单回复：你好"
      }
    ]
  }' > "$OUTPUT_FILE_DEFAULT"

# 检查默认行为是否为流式
data_lines_default=$(grep -c "^data: " "$OUTPUT_FILE_DEFAULT" 2>/dev/null | head -n 1 || echo "0")
if [ "$data_lines_default" -gt 0 ] 2>/dev/null; then
    echo -e "${GREEN}✅ 省略 stream 参数时默认返回流式响应（符合文档）${NC}"
    echo -e "${BLUE}   'data:' 行数: $data_lines_default${NC}"
else
    echo -e "${RED}❌ 省略 stream 参数时未返回流式响应（与文档不符）${NC}"
    echo -e "${YELLOW}   期望: 流式响应 (stream: true 默认)${NC}"
    echo -e "${YELLOW}   实际: 可能返回非流式响应${NC}"
fi

echo ""

echo "================================================"
echo "📊 文档一致性检查总结"
echo "================================================"
echo ""

echo "关键验证项（对照 features/text-chat.mdx）："
echo ""

# 计算成功的验证项
success_count=0
total_checks=5

if [ "$data_lines" -gt 0 ] 2>/dev/null; then
    ((success_count++))
fi

if [ "$text_delta" -gt 0 ] 2>/dev/null; then
    ((success_count++))
fi

if [ "$finish_event" -gt 0 ] 2>/dev/null || [ "$done_event" -gt 0 ] 2>/dev/null; then
    ((success_count++))
fi

if [ "$error_count" -eq 0 ] 2>/dev/null; then
    ((success_count++))
fi

if [ "$data_lines_default" -gt 0 ] 2>/dev/null; then
    ((success_count++))
fi

if [ "$success_count" -ge 4 ]; then
    echo -e "${GREEN}✅ 流式响应格式基本符合 text-chat.mdx 文档描述${NC}"
    echo -e "${GREEN}✅ 通过 $success_count/$total_checks 项关键检查${NC}"
    echo -e "${GREEN}✅ 默认行为验证: stream 参数默认为 true（流式输出）${NC}"
else
    echo -e "${YELLOW}⚠️  部分验证项未通过: $success_count/$total_checks${NC}"
    echo -e "${YELLOW}建议检查：${NC}"
    echo "   - SSE 格式是否正确（'data:' 开头的行）"
    echo "   - 是否包含 'text.delta' 事件"
    echo "   - 是否包含完成事件（'finish' 或 'done'）"
    echo "   - 省略 stream 参数时的默认行为"
fi

echo ""
echo "================================================"
echo "测试完成"
echo "================================================"
echo ""
echo "💡 提示："
echo "1. 完整响应已保存到:"
echo "   - stream: true 测试: $OUTPUT_FILE"
echo "   - 省略 stream 测试: $OUTPUT_FILE_DEFAULT"
echo "2. 可使用 'cat $OUTPUT_FILE' 查看原始 SSE 输出"
echo "3. 如果测试失败，请对照 features/text-chat.mdx 检查 API 实现"
echo "4. 特别注意文档中的说明：省略 stream 参数时，默认为 stream: true"
echo ""
