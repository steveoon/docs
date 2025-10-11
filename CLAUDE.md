# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Mintlify-based documentation site. Mintlify is a modern documentation platform that uses MDX (Markdown + JSX) files for content and a `docs.json` configuration file for site structure and settings.

## Development Workflow

### Local Development
```bash
# Install Mintlify CLI globally (requires Node.js 19+)
npm i -g mint

# Start local preview server (runs on port 3000 by default)
mint dev

# Use custom port if needed
mint dev --port 3333

# Update CLI to latest version
mint update

# Validate all links in documentation
mint broken-links
```

### Local Preview
- Development server runs at `http://localhost:3000`
- Changes auto-reload in the browser
- The `docs.json` file must exist in the directory where you run `mint dev`

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

1. **Guides Tab**:
   - **Getting started** (group)
     - Introduction → `index.mdx`
     - Quickstart → `quickstart.mdx`
     - Development → `development.mdx`
   - **Customization** (group)
     - Global Settings → `essentials/settings.mdx`
     - Navigation → `essentials/navigation.mdx`
   - **Writing content** (group)
     - Markdown syntax → `essentials/markdown.mdx`
     - Code blocks → `essentials/code.mdx`
     - Images and embeds → `essentials/images.mdx`
     - Reusable snippets → `essentials/reusable-snippets.mdx`
   - **AI tools** (group)
     - Cursor → `ai-tools/cursor.mdx`
     - Claude Code → `ai-tools/claude-code.mdx`
     - Windsurf → `ai-tools/windsurf.mdx`

2. **API Reference Tab**:
   - **API documentation** (group)
     - Introduction → `api-reference/introduction.mdx`
   - **Endpoint examples** (group)
     - GET → `api-reference/endpoint/get.mdx`
     - POST → `api-reference/endpoint/create.mdx`
     - DELETE → `api-reference/endpoint/delete.mdx`
     - Webhook → `api-reference/endpoint/webhook.mdx`

**Key Mapping Rule:**
- Path in `docs.json` WITHOUT `.mdx` extension maps to actual file
- Example: `"essentials/settings"` → `essentials/settings.mdx`
- Example: `"index"` → `index.mdx`

### File Types
- **`.mdx` files**: Content pages using MDX (Markdown with React components)
- **`docs.json`**: Site configuration
- **`openapi.json`**: OpenAPI specification for auto-generated API documentation
- **`/snippets`**: Reusable content snippets that can be included across multiple pages
- **`/images` and `/logo`**: Static assets

## Content Editing Guidelines

### Navigation Updates
To add/remove pages or change navigation:
1. Edit the `navigation` object in `docs.json`
2. Add page file path (without `.mdx` extension) to appropriate `pages` array
3. The file path in `docs.json` corresponds to the actual file location
   - Example: `"index"` → `index.mdx`
   - Example: `"essentials/settings"` → `essentials/settings.mdx`

### Creating New Pages
1. Create `.mdx` file in appropriate directory
2. Add frontmatter with `title` and `description`:
   ```mdx
   ---
   title: "Page Title"
   description: "Page description"
   ---
   ```
3. Add the page path (without `.mdx` extension) to the appropriate `pages` array in `docs.json`
4. Use Mintlify components (Card, Accordion, Tip, Note, etc.) for rich content

**Example - Adding a new page under "Getting started":**
1. Create file: `installation.mdx`
2. Edit `docs.json` at line 18-22:
   ```json
   "pages": [
     "index",
     "quickstart",
     "installation",  // Add this line
     "development"
   ]
   ```

### API Documentation
- Edit `api-reference/openapi.json` to update API specifications
- Mintlify auto-generates API documentation from this OpenAPI spec
- API endpoint pages in `api-reference/endpoint/` demonstrate the documentation structure

## Deployment

- Changes are automatically deployed via Mintlify GitHub app
- Install the app from: https://dashboard.mintlify.com/settings/organization/github-app
- Pushing to the default branch triggers automatic production deployment
- Successful deployments show "All checks have passed" message

## Troubleshooting

### Preview Server Issues
```bash
# If preview isn't running, update CLI
mint update

# If page loads as 404, ensure you're in directory with docs.json
cd /path/to/docs

# macOS ARM (M1/M2) sharp module error
npm remove -g mint
# Upgrade to Node v19+
npm i -g mint
```

### Unknown Errors
Delete the Mintlify cache and restart:
```bash
rm -rf ~/.mintlify
mint dev
```
