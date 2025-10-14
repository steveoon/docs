# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **花卷智能体 (HuaJune Agent) API documentation site**, built with Mintlify. It documents a Chinese AI agent API service specialized for blue-collar recruitment scenarios. The documentation is entirely in Chinese and covers intelligent conversation, recruitment tools, interview scheduling, and job information queries.

**Key characteristics:**
- All content is in **Chinese** - maintain this language when editing documentation
- Focused on **recruitment/HR use cases** (面试预约, 岗位查询, 订单管理, etc.)
- Built with **Mintlify** - a modern documentation platform using MDX files and `docs.json` configuration

## Development Workflow

### Local Development
```bash
# Install Mintlify CLI globally (requires Node.js 19+)
npm i -g mint

# Start local preview server (runs on port 3000 by default)
mint dev

# Update CLI to latest version
mint update

# Validate all links in documentation
mint broken-links
```

### API Testing
The project includes test scripts in `scripts/` that **exactly match the code examples in quickstart.mdx**:

```bash
cd scripts/

# Test non-streaming API (corresponds to quickstart.mdx step 2)
./test-non-stream.sh

# Test streaming API (corresponds to quickstart.mdx step 4)
./test-stream.sh

# Test with custom API URL and key
API_URL="https://huajune.duliday.com" API_KEY="your_key" ./test-non-stream.sh
```

**Important**: After updating API examples in documentation, always run these scripts to verify accuracy.

## Architecture & Structure

### Configuration System
- **`docs.json`**: Central configuration file controlling:
  - Site metadata (name, theme, colors, favicon)
  - Navigation structure (tabs, groups, pages)
  - Logo configuration (light/dark modes)
  - Navbar and footer settings
  - Contextual menu options (copy, view, AI integrations)

### Content Organization
Documentation is organized into tabbed sections defined in `docs.json`:

**Navigation Hierarchy:**
```
Tab (标签页)
  └─ Group (分类/组)
       └─ Pages (页面列表)
```

**Current Structure:**

1. **指南 (Guides) Tab**:
   - **快速开始** (Getting started)
     - `index.mdx` - Introduction to HuaJune Agent
     - `quickstart.mdx` - Quick start guide with API examples
     - `authentication.mdx` - API authentication guide
   - **核心概念** (Core concepts)
     - `concepts/models.mdx` - Available AI models
     - `concepts/tools.mdx` - Built-in recruitment tools
     - `concepts/messages.mdx` - Message format
     - `concepts/system-prompts.mdx` - System prompt configuration
     - `concepts/context.mdx` - Context management
   - **功能指南** (Features)
     - `features/text-chat.mdx` - Text conversation
     - `features/tool-calling.mdx` - Tool invocation
     - `features/streaming.mdx` - Streaming responses (SSE)
     - `features/message-pruning.mdx` - Message history optimization
     - `features/error-handling.mdx` - Error handling
   - **最佳实践** (Best practices)
     - `best-practices/performance.mdx`
     - `best-practices/debugging.mdx`
     - `best-practices/faq.mdx`

2. **API 参考 (API Reference) Tab**:
   - **API 概览** (API overview)
     - `api-reference/introduction.mdx` - API overview
     - `api-reference/request-response.mdx` - Request/response formats
     - `api-reference/error-codes.mdx` - Error code reference
   - **端点详解** (Endpoints)
     - `api-reference/endpoint/chat.mdx` - POST /chat (main endpoint)
     - `api-reference/endpoint/models.mdx` - GET /models
     - `api-reference/endpoint/tools.mdx` - GET /tools
     - `api-reference/endpoint/prompt-types.mdx` - GET /prompt-types
     - `api-reference/endpoint/config-schema.mdx` - GET /config-schema

**Key Mapping Rule:**
- Path in `docs.json` WITHOUT `.mdx` extension maps to actual file
- Example: `"concepts/models"` → `concepts/models.mdx`
- Example: `"index"` → `index.mdx`

### Directory Structure
```
docs/
├── api-reference/          # API endpoint documentation
│   ├── endpoint/          # Detailed endpoint specs
│   ├── introduction.mdx
│   ├── request-response.mdx
│   └── error-codes.mdx
├── best-practices/        # Best practices guides
├── concepts/              # Core concepts (models, tools, messages, etc.)
├── features/              # Feature guides (streaming, tool calling, etc.)
├── scripts/               # API test scripts matching quickstart examples
│   ├── test-non-stream.sh
│   └── test-stream.sh
├── logo/                  # Logo assets (Huajune_light.png, Huajune_dark.png)
├── docs.json             # Mintlify navigation & theme configuration
├── index.mdx             # Documentation homepage
├── quickstart.mdx        # Quick start guide (includes testable code)
└── authentication.mdx    # API authentication guide
```

### Key Files
- **`docs.json`**: Navigation structure, theme (primary: #F59E0B/amber), tabs, groups, pages
- **`.mdx` files**: Content pages with Mintlify components (Card, Accordion, ParamField, etc.)
- **`quickstart.mdx`**: Contains critical API examples that must stay synchronized with `scripts/`

## Content Editing Guidelines

### Language Requirements
- **All content must be in Chinese** - this is a Chinese-language documentation site
- Use simplified Chinese characters (简体中文)
- Technical terms should use common Chinese translations when available
- Code examples and API parameters use English (standard practice)

### Navigation Updates
To add/remove pages:
1. Edit the `navigation.tabs` array in `docs.json`
2. Add page path (without `.mdx` extension) to appropriate `pages` array under the correct group
3. Maintain logical grouping: 快速开始 (getting started) → 核心概念 (concepts) → 功能指南 (features) → 最佳实践 (best practices)

**Example - Adding a new feature guide:**
```json
{
  "group": "功能指南",
  "pages": [
    "features/text-chat",
    "features/tool-calling",
    "features/streaming",
    "features/your-new-feature"  // Add here
  ]
}
```

### Creating New Pages
1. Create `.mdx` file in the appropriate directory
2. Add Chinese frontmatter:
   ```mdx
   ---
   title: "页面标题"
   description: "页面描述"
   ---
   ```
3. Add the page path to `docs.json` navigation
4. Use Mintlify components: `<Card>`, `<Accordion>`, `<Tip>`, `<Note>`, `<ParamField>`, `<ResponseField>`, `<CodeGroup>`

### API Endpoint Documentation
- Use `<ParamField>` for request parameters with Chinese descriptions
- Use `<ResponseField>` for response fields
- Include `<CodeGroup>` with examples in cURL, JavaScript, Python
- Always include error cases and best practices sections
- See `api-reference/endpoint/chat.mdx` as the reference template

## Content Optimization Best Practices

### Progressive Disclosure Pattern

**Problem**: Long documentation pages create reading pressure and overwhelm users.

**Solution**: Use progressive disclosure to reduce initial visible content by ~70-80% while maintaining completeness.

#### When to Apply Progressive Disclosure

Use `<AccordionGroup>` when:
- **Field documentation**: 5+ fields with detailed examples → Fold each field into separate Accordion
- **Multiple strategies/modes**: 3+ configuration strategies → Each strategy in its own Accordion
- **Best practices sections**: Multiple tips/patterns → Each tip in separate Accordion
- **Error examples**: Multiple error types → Each error type folded

Use `<Tabs>` when:
- **Multiple complete examples**: 3+ full examples showing different use cases → Each example in a Tab
- **Language-specific code**: Same functionality in different languages → One tab per language
- **Environment variations**: Development vs Production configs → Separate tabs

Use **summary tables** before details:
- Add a quick reference table at the top showing all fields/options
- Follow with detailed `<AccordionGroup>` for each item
- Example pattern: "字段速查表" → detailed field explanations in Accordions

#### Example: Field Documentation Pattern

```mdx
## Context 字段速查表
| 字段 | 类型 | 使用场景 |
|------|------|---------|
| `configData` | `ZhipinData` | **`zhipin_reply_generator` 工具必需** |
| `replyPrompts` | `object` | **`zhipin_reply_generator` 工具必需** |
[...more fields]

## 字段详解
<AccordionGroup>
  <Accordion title="configData - 业务配置数据" icon="database">
    详细说明和示例...
  </Accordion>
  <Accordion title="replyPrompts - 回复提示词配置" icon="message-bot">
    详细说明和示例...
  </Accordion>
  [更多字段折叠]
</AccordionGroup>
```

#### Example: Multiple Examples Pattern

```mdx
## 完整示例
<Tabs>
  <Tab title="智能回复工具">
    完整的智能回复工具配置示例...
  </Tab>
  <Tab title="通用计算工具">
    通用计算工具配置示例...
  </Tab>
  <Tab title="沙箱工具">
    沙箱工具配置示例...
  </Tab>
</Tabs>
```

#### Example: Request/Response Pairs Pattern

```mdx
<AccordionGroup>
  <Accordion title="error 策略（默认）" icon="circle-exclamation">
    <CodeGroup>
      ```json 请求示例 icon="paper-plane"
      {...}
      ```
      ```json 响应 (400) icon="triangle-exclamation"
      {...}
      ```
    </CodeGroup>
  </Accordion>
  [更多策略折叠]
</AccordionGroup>
```

### Code Block Enhancement Guidelines

**All code blocks should have descriptive titles and semantic icons** to improve scannability and visual hierarchy.

#### Basic Enhancement

```mdx
# ❌ Bad: Plain code block
```json
{ "model": "..." }
```

# ✅ Good: Enhanced code block
```json 请求示例 icon="paper-plane"
{ "model": "..." }
```
```

#### When to Use Each Feature

| Feature | When to Use | Example |
|---------|-------------|---------|
| **Title** | Always | `请求示例`, `响应 (400)`, `配置示例` |
| **icon** | Always | `icon="paper-plane"` (requests), `icon="check"` (responses) |
| **lines** | Reference blocks, longer examples (15+ lines) | `lines` |
| **highlight** | Emphasize key lines (params, errors, config) | `highlight={2,5-7}` |
| **expandable** | Very long blocks (50+ lines) | `expandable` |
| **CodeGroup** | Request/response pairs, multi-language examples | Wrap multiple blocks |

#### Icon Selection Guidelines

Choose semantic icons that match the content type:

| Content Type | Recommended Icons |
|--------------|-------------------|
| **API Requests** | `paper-plane`, `rocket`, `right-to-bracket` |
| **API Responses** | `check`, `circle-check`, `reply` |
| **Errors** | `triangle-exclamation`, `circle-exclamation`, `ban`, `lock` |
| **Configuration** | `gear`, `sliders`, `wrench` |
| **Data/Database** | `database`, `table`, `folder` |
| **Messages/Chat** | `comments`, `message`, `comment-dots` |
| **Tools** | `screwdriver-wrench`, `hammer`, `toolbox` |
| **Events/Streaming** | `play`, `forward`, `stop`, `flag-checkered` |
| **Security** | `key`, `lock`, `shield` |
| **Commands** | `terminal`, `code`, `command` |
| **Calculations** | `calculator`, `chart-line`, `percent` |
| **Lists/Arrays** | `list`, `list-check`, `bars` |

#### Highlighting Patterns

```mdx
# Single line emphasis
```json 示例 highlight={3}
{
  "model": "...",
  "stream": true  // This line will be highlighted
}
```

# Multiple lines
```json 示例 highlight={2,5-7}
{
  "required": true,  // Line 2
  "optional": false,
  ...
  "config": {        // Lines 5-7
    "key": "value"
  }
}
```

# Error messages
```json 错误响应 highlight={2-4} icon="triangle-exclamation"
{
  "error": "BadRequest",
  "message": "Missing required context",
  "details": {...}
}
```
```

#### CodeGroup Usage Patterns

**Request/Response Pairs:**
```mdx
<CodeGroup>
  ```bash 请求 icon="terminal"
  curl -X GET https://api.example.com/endpoint
  ```

  ```json 响应 lines icon="check"
  {
    "success": true,
    "data": {...}
  }
  ```
</CodeGroup>
```

**Multi-language Examples:**
```mdx
<CodeGroup>
  ```javascript JavaScript icon="js"
  const response = await fetch(url);
  ```

  ```python Python icon="python"
  response = requests.get(url)
  ```

  ```bash cURL icon="terminal"
  curl -X GET url
  ```
</CodeGroup>
```

#### Complete Enhancement Examples

See these files for reference implementations:
- **concepts/context.mdx** - Full progressive disclosure with enhanced code blocks
- **concepts/system-prompts.mdx** - CodeGroup usage, numbered icons
- **api-reference/endpoint/chat.mdx** - Comprehensive API documentation with all techniques

### Developer-First Thinking

When organizing content, always think from a **third-party developer's perspective**:

1. **What do they need first?** → Quick reference table at top
2. **What's most common?** → Most common use case in first tab/accordion
3. **What can wait?** → Advanced options, edge cases → fold into accordions
4. **What needs comparison?** → Side-by-side → use tabs or CodeGroup
5. **What's the mental model?** → Flow (request → response) → CodeGroup pairs

**Goal**: Reduce cognitive load, enable progressive learning, make information discoverable without overwhelming.

## Critical Workflow: Documentation-Code Synchronization

**The test scripts in `scripts/` must exactly match the code examples in `quickstart.mdx`.**

When updating API examples:
1. Edit the code example in `quickstart.mdx`
2. Update the corresponding test script in `scripts/`
3. Run the test script to verify it works
4. Commit both changes together

This ensures documentation accuracy and prevents outdated examples.

## API Information

### Base URLs
- **Production**: `https://huajune.duliday.com`
- **Development**: `http://localhost:3001` (requires local API server)

### Main Endpoint
- **POST /api/v1/chat** - Primary endpoint for AI conversations (documented in `api-reference/endpoint/chat.mdx`)
  - Supports streaming (SSE) and non-streaming responses
  - Requires `Authorization: Bearer YOUR_API_KEY` header
  - Key parameters: `model`, `messages`, `stream`, `allowedTools`, `context`

### Authentication
- API keys managed at: https://wolian.cc/platform/clients-management
- Keys must be in "已激活" (activated) status
- Documented in `authentication.mdx`

## HuaJune Agent Specifics

### Recruitment-Focused Tools
The API includes built-in tools for recruitment scenarios:
- **预约面试** (Schedule interview) - Automatic interview scheduling
- **岗位信息查询** (Job information query) - Query job details
- **订单查询** (Order query) - Check recruitment order status
- **订单分析** (Order analysis) - Analyze recruitment data

### Domain Context
- Target users: 蓝领招聘 (blue-collar recruitment) companies
- Use cases: Candidate communication, interview scheduling, job matching
- Response style: Professional, helpful, recruitment-focused

## Deployment

Automatic deployment via Mintlify GitHub App:
1. Install app: https://dashboard.mintlify.com/settings/organization/github-app
2. Push to `main` branch → automatic deployment
3. Check deployment status in GitHub Actions

## Troubleshooting

### Preview Server
```bash
# Update CLI if preview doesn't work
mint update

# Ensure you're in the docs directory
cd /Users/rensiwen/Documents/跃橙/project_docs/HJ_open_api_docs/docs
mint dev

# Clear cache if experiencing issues
rm -rf ~/.mintlify
mint dev
```

### API Test Failures
```bash
# Check if API server is running
curl http://localhost:3001/api/v1/models

# Use production URL if local server unavailable
API_URL="https://huajune.duliday.com" API_KEY="your_key" ./test-non-stream.sh

# Common errors:
# - 401: Invalid API key
# - 403: Model not available for your key
# - Connection refused: API server not running
```
