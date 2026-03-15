# Claude Code Plugin Marketplace — Creation Guide

> **Purpose**: Everything needed to create a Claude Code plugin marketplace from scratch. All schemas, file structures, and patterns are drawn from real, working marketplaces.

---

## Table of Contents

1. [Repository Structure](#1-repository-structure)
2. [marketplace.json Schema](#2-marketplacejson-schema)
3. [plugin.json Schema](#3-pluginjson-schema)
4. [Skills](#4-skills)
5. [Commands](#5-commands)
6. [Agents](#6-agents)
7. [MCP Servers](#7-mcp-servers)
8. [CONNECTORS.md](#8-connectorsmd)
9. [README.md Templates](#9-readmemd-templates)
10. [Registration & Installation](#10-registration--installation)
11. [Packaging & Distribution](#11-packaging--distribution)
12. [Token Optimization](#12-token-optimization)
13. [Complete Worked Example](#13-complete-worked-example)
14. [Pre-Publish Checklist](#14-pre-publish-checklist)

---

## 1. Repository Structure

A marketplace is a git repository with the following layout:

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # REQUIRED — marketplace index
├── plugins/
│   ├── plugin-a/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json       # REQUIRED — plugin metadata
│   │   ├── .mcp.json             # Optional — MCP server config
│   │   ├── skills/
│   │   │   └── skill-name/
│   │   │       ├── SKILL.md      # Skill definition
│   │   │       └── references/   # Optional — detailed reference docs
│   │   │           ├── api.md
│   │   │           └── patterns.md
│   │   ├── commands/
│   │   │   └── command-name.md   # Slash command definition
│   │   ├── agents/
│   │   │   └── agent-name.md     # Agent definition
│   │   ├── CONNECTORS.md         # Optional — tool-agnostic mapping
│   │   ├── README.md             # Plugin documentation
│   │   └── LICENSE               # License file
│   └── plugin-b/
│       └── ...
├── scripts/
│   └── package.sh                # Optional — build script
├── README.md                     # Marketplace documentation
├── LICENSE
└── .gitignore
```

### Key Rules

- `marketplace.json` MUST be at `.claude-plugin/marketplace.json` (repo root)
- Each plugin MUST have `.claude-plugin/plugin.json` inside its directory
- A plugin MUST have at least one of: `skills/`, `commands/`, `agents/`, or `.mcp.json`
- The `references/` directory inside a skill is automatically loaded as context when the skill activates

---

## 2. marketplace.json Schema

The marketplace index lives at `.claude-plugin/marketplace.json`. It lists all plugins available in the marketplace.

### Full Schema

```jsonc
{
  // Optional — JSON schema URL for validation
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",

  // REQUIRED — unique marketplace identifier (used in plugin@marketplace references)
  "name": "my-marketplace",

  // Optional — marketplace description shown to users
  "description": "Description of what this marketplace offers",

  // REQUIRED — marketplace owner info
  "owner": {
    "name": "Your Name",             // REQUIRED
    "email": "you@example.com",      // Optional
    "url": "https://github.com/you"  // Optional
  },

  // Optional — marketplace-level metadata
  "metadata": {
    "description": "Extended description",
    "version": "1.0.0",
    "homepage": "https://github.com/you/my-marketplace"
  },

  // REQUIRED — array of plugin entries
  "plugins": [
    // ... see Plugin Entry below
  ]
}
```

### Plugin Entry in marketplace.json

Each entry in the `plugins` array describes one plugin:

```jsonc
{
  // REQUIRED — plugin identifier (alphanumeric + hyphens)
  "name": "plugin-name",

  // REQUIRED — human-readable description
  "description": "What this plugin does",

  // REQUIRED — where to find the plugin source (see Source Variants below)
  "source": "./plugins/plugin-name",

  // Optional fields
  "version": "1.0.0",
  "category": "productivity",        // development, productivity, design, monitoring, etc.
  "keywords": ["keyword1", "keyword2"],
  "homepage": "https://github.com/...",
  "tags": ["community-managed"],      // arbitrary string tags
  "strict": true,                     // strict validation mode (default: false)

  // Optional — author override (if different from marketplace owner)
  "author": {
    "name": "Plugin Author",
    "email": "author@example.com"
  },

  // Optional — LSP server configuration (for language server plugins)
  "lspServers": {
    "server-name": {
      "command": "typescript-language-server",
      "args": ["--stdio"],
      "extensionToLanguage": {
        ".ts": "typescript",
        ".tsx": "typescriptreact",
        ".js": "javascript"
      },
      "startupTimeout": 120000        // Optional — ms before timeout
    }
  }
}
```

### Source Variants

The `source` field tells Claude Code where to find the plugin files. There are 5 source types:

#### 1. Local (relative path string)

Plugin files are inside the marketplace repo itself. This is the simplest and most common pattern.

```jsonc
{
  "name": "my-plugin",
  "source": "./plugins/my-plugin"
}
```

#### 2. GitHub (`github`)

Points to a GitHub `owner/repo`. Claude Code clones the full repo.

```jsonc
{
  "name": "external-plugin",
  "source": {
    "source": "github",
    "repo": "owner/repo-name"
  }
}
```

#### 3. Git URL (`url`)

Points to any git URL. Useful for non-GitHub repos or specific `.git` URLs.

```jsonc
{
  "name": "external-plugin",
  "source": {
    "source": "url",
    "url": "https://github.com/owner/repo.git"
  }
}
```

#### 4. Generic Git (`git`)

Same as `url` but uses the `git` source type identifier.

```jsonc
{
  "name": "external-plugin",
  "source": {
    "source": "git",
    "url": "https://github.com/owner/repo.git"
  }
}
```

#### 5. Git Subdirectory (`git-subdir`)

Points to a specific subdirectory within a git repo. Useful when one repo contains multiple plugins.

```jsonc
{
  "name": "specific-plugin",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/owner/mono-repo.git",
    "path": "plugins/specific-plugin",    // REQUIRED — subdirectory path
    "ref": "main",                        // Optional — branch/tag
    "sha": "abc123..."                    // Optional — pin to commit
  }
}
```

Short form (GitHub repos can omit `https://` prefix):

```jsonc
{
  "source": {
    "source": "git-subdir",
    "url": "owner/repo-name",
    "path": "plugins/my-plugin",
    "ref": "main",
    "sha": "d52f3741a6a33a3191d6138eb3d6c3355cb970d1"
  }
}
```

### Real-World marketplace.json Examples

**Binatrix (local sources):**

```json
{
  "name": "binatrix-plugins",
  "owner": {
    "name": "Dima",
    "url": "https://github.com/BinatrixAI"
  },
  "metadata": {
    "description": "Binatrix plugin marketplace for Claude Code",
    "version": "1.1.0",
    "homepage": "https://github.com/BinatrixAI/binatrix-plugins"
  },
  "plugins": [
    {
      "name": "monday-com",
      "source": "./plugins/monday-com",
      "version": "1.0.0",
      "description": "Manage Monday.com boards, items, columns, groups, automations, and workspaces.",
      "keywords": ["monday-com", "crm", "project-management"],
      "category": "productivity"
    }
  ]
}
```

**Superpowers (external URL sources with strict mode):**

```json
{
  "name": "superpowers-marketplace",
  "owner": {
    "name": "Jesse Vincent",
    "email": "jesse@fsck.com"
  },
  "metadata": {
    "description": "Skills, workflows, and productivity tools",
    "version": "1.0.12"
  },
  "plugins": [
    {
      "name": "superpowers",
      "source": {
        "source": "url",
        "url": "https://github.com/obra/superpowers.git"
      },
      "description": "Core skills library: TDD, debugging, collaboration patterns",
      "version": "4.1.1",
      "strict": true
    }
  ]
}
```

**Official (git-subdir with pinned SHA):**

```json
{
  "name": "semgrep",
  "description": "Semgrep catches security vulnerabilities in real-time",
  "category": "security",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/semgrep/mcp-marketplace.git",
    "path": "plugin"
  },
  "homepage": "https://github.com/semgrep/mcp-marketplace.git"
}
```

---

## 3. plugin.json Schema

Each plugin has a `.claude-plugin/plugin.json` file:

```jsonc
{
  // REQUIRED — must match the name in marketplace.json
  "name": "plugin-name",

  // REQUIRED — human-readable description
  "description": "What this plugin does",

  // Optional
  "version": "1.0.0",
  "author": {
    "name": "Author Name",
    "email": "author@example.com"  // Optional
  },
  "license": "MIT",
  "repository": "https://github.com/owner/repo",
  "keywords": ["keyword1", "keyword2"]
}
```

**Real example (monday-com):**

```json
{
  "name": "monday-com",
  "version": "1.0.0",
  "description": "Manage Monday.com boards, items, columns, groups, automations, and workspaces. Use this plugin for any Monday.com CRM, project management, or board operations.",
  "author": { "name": "Dima" },
  "license": "MIT",
  "repository": "https://github.com/BinatrixAI/binatrix-plugins",
  "keywords": ["monday-com", "crm", "project-management", "graphql", "work-os"]
}
```

---

## 4. Skills

Skills are **model-invoked** — Claude autonomously activates them based on task context. They are the most common extension type.

### File Location

```
plugins/<plugin-name>/skills/<skill-name>/SKILL.md
```

A plugin can have multiple skills, each in its own subdirectory.

### SKILL.md Format

```markdown
---
name: skill-name
description: >
  Trigger conditions for this skill. Describe when Claude should use it.
  Include specific phrases, keywords, and scenarios. This field is critical
  for activation accuracy.
version: 1.0.0
---

# Skill Title

Body content — instructions, reference material, examples, patterns.
This entire file (and any references/ files) becomes Claude's context
when the skill activates.
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (alphanumeric + hyphens) |
| `description` | Yes | Trigger conditions — tells Claude when to activate |
| `version` | No | Semantic version |
| `license` | No | License reference |

### Writing Effective Descriptions

The `description` field determines when Claude invokes the skill. Write it as a comprehensive trigger specification:

**Pattern:**
```yaml
description: >
  [Action verb] [domain]. Use this skill whenever the user mentions [keyword1],
  [keyword2], [phrase1], or [phrase2]. Also trigger when [scenario1], [scenario2],
  or when [environment condition]. Even if the user just says "[casual phrase]"
  and [context condition], use this skill.
```

**Good example (monday-com):**
```yaml
description: >
  Manage Monday.com boards, items, columns, groups, automations, and workspaces
  via the Monday.com GraphQL API. Use this skill whenever the user mentions
  Monday.com, monday, board management, work OS, project tracking on Monday,
  CRM in Monday, creating boards, updating items, managing columns, checking
  board status, Monday dashboards, Monday automations, or any task involving
  reading or writing data in Monday.com. Also trigger when the user references
  workspace setup, item creation, column configuration, board templates, Monday
  integrations, subitems, connected boards, mirror columns, Monday formulas,
  timeline management, or any Monday.com-specific terminology like "pulse",
  "board view", or "Monday widget". Even if the user just says "update my board"
  or "check my tasks" and Monday.com is their known project management tool,
  use this skill.
```

**Good example (cmux — environment-aware):**
```yaml
description: >
  Control cmux terminal multiplexer — manage workspaces, panes, splits, browser
  automation, sidebar metadata, notifications, and terminal I/O. Use this skill
  whenever the user mentions cmux, terminal splits, browser panes, cmux
  notifications, sidebar status, progress bars, multi-agent workflows, reading
  terminal output, sending keys, screen capture, cmux hooks, or any task
  involving programmatic control of cmux terminal windows. Also trigger when
  working with split panes, browser automation in terminal, workspace management,
  or when $CMUX_WORKSPACE_ID is set. Even for "open a browser", "split the
  terminal", "show progress", or "notify me when done" — if cmux is available,
  use this skill.
```

### The references/ Directory

For complex skills, split detailed content into `references/` files:

```
skills/skill-name/
├── SKILL.md                    # Core skill (always loaded)
└── references/
    ├── api-reference.md        # Detailed API docs
    ├── column-types.md         # Column type formats
    └── common-patterns.md      # Reusable patterns
```

When the skill activates, Claude gets SKILL.md plus all files in `references/`. Use this to keep SKILL.md concise while providing deep reference material.

### Skill Body Content Guidelines

1. **How to Use** — explain the workflow (authenticate → query → format)
2. **Authentication** — exact curl/SDK patterns
3. **Core Operations** — the most common things users will ask for
4. **Examples** — real, copy-pasteable code
5. **Error Handling** — common pitfalls and solutions

---

## 5. Commands

Commands are **user-invoked** via `/command-name` in the Claude Code prompt.

### File Location

```
plugins/<plugin-name>/commands/<command-name>.md
```

The filename (minus `.md`) becomes the slash command name.

### Command Format

```markdown
---
description: Short description shown in /help
argument-hint: <required-arg> [optional-arg]
allowed-tools: [Read, Glob, Grep, Bash]
model: sonnet
---

# Command Title

Instructions for what Claude should do when this command is invoked.

## Arguments

The user invoked this command with: $ARGUMENTS

## Instructions

1. Step one
2. Step two
3. Step three
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | Short text shown in `/help` output |
| `argument-hint` | No | Argument format hint shown to user (e.g., `<file> [--verbose]`) |
| `allowed-tools` | No | Pre-approved tools — reduces permission prompts |
| `model` | No | Model override: `"haiku"`, `"sonnet"`, `"opus"` |

### Variable Substitution

- `$ARGUMENTS` — replaced with whatever the user typed after the command name

### Real Example

```markdown
---
description: An example slash command that demonstrates command frontmatter options
argument-hint: <required-arg> [optional-arg]
allowed-tools: [Read, Glob, Grep, Bash]
---

# Example Command

This command demonstrates slash command structure and frontmatter options.

## Arguments

The user invoked this command with: $ARGUMENTS

## Instructions

When this command is invoked:

1. Parse the arguments provided by the user
2. Perform the requested action using allowed tools
3. Report results back to the user
```

---

## 6. Agents

Agents are **spawned by Claude** as sub-processes to handle specific tasks autonomously. They run in their own context window.

### File Location

```
plugins/<plugin-name>/agents/<agent-name>.md
```

### Agent Format

Agent definitions follow the same markdown-with-frontmatter pattern as commands, but are invoked by Claude via the `Agent` tool rather than by the user via `/command`.

```markdown
---
name: agent-name
description: >
  When to spawn this agent. Claude reads this to decide if the agent
  is appropriate for the current task.
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write]
model: sonnet
---

# Agent Name

Instructions for the agent. This becomes the agent's system context.

## Task

Describe what the agent should accomplish.

## Constraints

- Constraint 1
- Constraint 2
```

### Key Differences from Commands

| Aspect | Commands | Agents |
|--------|----------|--------|
| Invoked by | User (`/command-name`) | Claude (Agent tool) |
| Context | Main conversation | Separate sub-process |
| Variable | `$ARGUMENTS` | Task prompt from Claude |
| Visibility | User sees output | Claude receives output |

---

## 7. MCP Servers

MCP (Model Context Protocol) servers provide external tool integrations. Configure them in `.mcp.json` at the plugin root.

### File Location

```
plugins/<plugin-name>/.mcp.json
```

### Format

The file contains a JSON object where each key is a server name:

```jsonc
{
  "server-name": {
    "type": "http",                           // or "stdio"
    "url": "https://mcp.example.com/api"      // for http type
  }
}
```

**Note**: Some plugins wrap in `{"mcpServers": {...}}` but the flat format is the canonical pattern from Anthropic's example plugin.

### HTTP Server

```json
{
  "my-api": {
    "type": "http",
    "url": "https://mcp.example.com/api"
  }
}
```

### Stdio Server

```json
{
  "my-tool": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@company/mcp-server"],
    "env": {
      "API_KEY": "${API_KEY}"
    }
  }
}
```

### Empty MCP Config

If your plugin doesn't use MCP servers but you want the file for future use:

```json
{
  "mcpServers": {}
}
```

---

## 8. CONNECTORS.md

The CONNECTORS.md pattern makes plugins **tool-agnostic** by mapping abstract categories to specific tools.

### File Location

```
plugins/<plugin-name>/CONNECTORS.md
```

### Format

```markdown
# Connectors

## How tool references work

Plugin files use `~~category` as a placeholder for whatever tool the user connects
in that category. Plugins are tool-agnostic — they describe workflows in terms of
categories rather than specific products.

## Connectors for this plugin

| Category | Placeholder | Included servers | Other options |
|----------|-------------|-----------------|---------------|
| Project tracker / Work OS | `~~project tracker` | monday.com | Linear, Asana, ClickUp, Jira |
| CRM | `~~crm` | monday.com CRM | Salesforce, HubSpot |
```

### How It Works

In skill files, use `~~category` placeholders instead of product names. The connector table documents which MCP servers are included and what alternatives exist. This lets users swap tools without rewriting skills.

---

## 9. README.md Templates

### Marketplace Root README

```markdown
# Marketplace Name

Plugin marketplace for [Claude Code](https://claude.com/product/claude-code) —
brief description of what plugins are available.

## Available Plugins

| Plugin | Description | Size |
|--------|-------------|------|
| **[plugin-a](./plugins/plugin-a)** | Description | ~X lines |
| **[plugin-b](./plugins/plugin-b)** | Description | ~Y lines |

## Installation

\```bash
# Add marketplace
/plugin marketplace add owner/marketplace-repo

# Install plugins
/plugin install plugin-a@marketplace-name
/plugin install plugin-b@marketplace-name
\```

Or add to `~/.claude/settings.json`:

\```json
{
  "enabledPlugins": {
    "plugin-a@marketplace-name": true
  }
}
\```

## Plugin Structure

Each plugin follows the standard Claude Code plugin format:

\```
plugins/<name>/
├── skills/<skill>/SKILL.md      # Skill knowledge file
├── skills/<skill>/references/   # Detailed reference docs
├── README.md                    # Plugin docs
└── LICENSE                      # MIT
\```

## License

MIT
```

### Plugin README

```markdown
# Plugin Name

A description of the plugin for [Claude Code](https://claude.com/product/claude-code).

## Installation

\```bash
/plugin install plugin-name@marketplace-name
\```

## What It Does

- **Feature 1** — description
- **Feature 2** — description
- **Feature 3** — description

## Skills

| Skill | What It Covers |
|-------|----------------|
| `skill-name` | Brief description |

## Data Sources

**Included MCP connections:**
- Service name — what it provides

See [CONNECTORS.md](CONNECTORS.md) for details.

## Reference Files

The skill includes detailed reference documentation:
- `file1.md` — description
- `file2.md` — description
```

---

## 10. Registration & Installation

### How Users Add a Marketplace

```bash
# Via slash command
/plugin marketplace add owner/repo-name

# Or: /plugin marketplace add https://github.com/owner/repo.git
```

This creates an entry in `~/.claude/plugins/known_marketplaces.json`.

### known_marketplaces.json

Stores all registered marketplace sources:

```json
{
  "my-marketplace": {
    "source": {
      "source": "github",
      "repo": "owner/repo-name"
    },
    "installLocation": "/Users/you/.claude/plugins/marketplaces/my-marketplace",
    "lastUpdated": "2026-03-15T14:50:37.853Z"
  }
}
```

**Source types match marketplace.json** — `github`, `git`, `url` are all valid.

Optional fields:
- `autoUpdate: true` — auto-update on Claude Code start

### installed_plugins.json

Tracks installed plugins with version and scope:

```json
{
  "version": 2,
  "plugins": {
    "plugin-name@marketplace-name": [
      {
        "scope": "user",
        "installPath": "/Users/you/.claude/plugins/cache/marketplace-name/plugin-name/1.0.0",
        "version": "1.0.0",
        "installedAt": "2026-01-13T22:25:04.036Z",
        "lastUpdated": "2026-01-13T22:25:04.036Z",
        "gitCommitSha": "f70b65538da094ff474a855e7a679fb2c2c8064f"
      }
    ]
  }
}
```

**Scope types:**
- `"user"` — installed globally for the user
- `"local"` — installed for a specific project (includes `projectPath`)

```json
{
  "scope": "local",
  "projectPath": "/Users/you/my-project",
  "installPath": "...",
  "version": "1.0.0",
  "installedAt": "...",
  "lastUpdated": "...",
  "gitCommitSha": "..."
}
```

### Enabling/Disabling Plugins

Users toggle plugins in `~/.claude/settings.json` (user-level) or project settings:

```json
{
  "enabledPlugins": {
    "plugin-name@marketplace-name": true,
    "another-plugin@marketplace-name": false
  }
}
```

### blocklist.json

Marketplace owners can blocklist specific plugins. Claude Code fetches this from the marketplace:

```json
{
  "fetchedAt": "2026-03-15T14:50:16.336Z",
  "plugins": [
    {
      "plugin": "bad-plugin@marketplace-name",
      "added_at": "2026-02-11T03:16:31.424Z",
      "reason": "security",
      "text": "Description of why this plugin was blocked"
    }
  ]
}
```

### Plugin Reference Format

Plugins are always referenced as `plugin-name@marketplace-name`:

```
monday-com@binatrix-plugins
superpowers@superpowers-marketplace
github@claude-plugins-official
```

---

## 11. Packaging & Distribution

### package.sh Script

Optional script to create `.plugin` zip archives for offline distribution:

```bash
#!/usr/bin/env bash
# Build .plugin zip archives from plugin directories
# Usage: ./scripts/package.sh [plugin-name]
# If no plugin name given, packages all plugins in plugins/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"

mkdir -p "$DIST_DIR"

package_plugin() {
  local plugin_dir="$1"
  local plugin_name
  plugin_name="$(basename "$plugin_dir")"

  if [[ ! -f "$plugin_dir/.claude-plugin/plugin.json" ]]; then
    echo "Skipping $plugin_name — no .claude-plugin/plugin.json found"
    return
  fi

  local version
  version=$(python3 -c "import json; print(json.load(open('$plugin_dir/.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "1.0.0")

  local output="$DIST_DIR/${plugin_name}-${version}.plugin"

  echo "Packaging $plugin_name v$version..."
  (cd "$plugin_dir" && zip -r "$output" . -x '*.DS_Store' -x '__MACOSX/*')
  echo "  -> $output"
}

if [[ $# -gt 0 ]]; then
  target="$REPO_ROOT/plugins/$1"
  if [[ ! -d "$target" ]]; then
    echo "Error: Plugin directory not found: $target"
    exit 1
  fi
  package_plugin "$target"
else
  for plugin_dir in "$REPO_ROOT"/plugins/*/; do
    [[ -d "$plugin_dir" ]] && package_plugin "$plugin_dir"
  done
fi

echo ""
echo "Done. Archives in $DIST_DIR/"
ls -lh "$DIST_DIR"/*.plugin 2>/dev/null || echo "No archives found."
```

### .gitignore

```gitignore
# Build artifacts
dist/
*.plugin

# OS
.DS_Store
Thumbs.db

# Editor
.vscode/
.idea/
*.swp
*.swo

# Node (if scripts need deps later)
node_modules/
```

---

## 12. Token Optimization

Large skills consume context window tokens. The **full + lite** pattern offers both versions:

### Strategy

| Variant | Purpose | Tokens | When to Use |
|---------|---------|--------|-------------|
| `plugin-name` | Full reference with examples, edge cases, detailed API docs | ~1500 lines | Deep work, first-time setup, debugging |
| `plugin-name-lite` | Same operational coverage, compressed format | ~280 lines | Routine operations, tight context windows |

### Implementation

Create two plugin directories with the same skill name but different content depth:

```
plugins/
├── monday-com/              # Full version
│   ├── .claude-plugin/plugin.json
│   ├── skills/monday-com/
│   │   ├── SKILL.md         # Detailed with examples
│   │   └── references/
│   │       ├── column-types.md
│   │       ├── common-patterns.md
│   │       └── api-reference.md
│   └── README.md
└── monday-com-lite/          # Lite version
    ├── .claude-plugin/plugin.json
    ├── skills/monday-com/
    │   └── SKILL.md          # Compressed, no references/
    └── README.md
```

### Lite Compression Techniques

1. Remove verbose examples — keep one-liner patterns
2. Collapse reference tables — only essential fields
3. Remove error handling docs — rely on API error messages
4. Drop CRM templates — keep operation patterns only
5. Use terse bullet format instead of prose

### marketplace.json Listing

List both variants so users choose:

```json
{
  "plugins": [
    {
      "name": "monday-com",
      "source": "./plugins/monday-com",
      "version": "1.0.0",
      "description": "Full Monday.com management — boards, items, CRM, column types, API reference",
      "category": "productivity"
    },
    {
      "name": "monday-com-lite",
      "source": "./plugins/monday-com-lite",
      "version": "1.0.0",
      "description": "Lightweight Monday.com management. Same coverage, ~70% fewer tokens.",
      "category": "productivity"
    }
  ]
}
```

---

## 13. Complete Worked Example

Step-by-step creation of a marketplace called `acme-plugins` with one plugin `weather`.

### Step 1: Create Repository Structure

```bash
mkdir -p acme-plugins/.claude-plugin
mkdir -p acme-plugins/plugins/weather/.claude-plugin
mkdir -p acme-plugins/plugins/weather/skills/weather
mkdir -p acme-plugins/plugins/weather/commands
mkdir -p acme-plugins/scripts
```

### Step 2: Create marketplace.json

**File: `acme-plugins/.claude-plugin/marketplace.json`**

```json
{
  "name": "acme-plugins",
  "owner": {
    "name": "Acme Corp",
    "url": "https://github.com/acme-corp"
  },
  "metadata": {
    "description": "Acme Corp plugin marketplace for Claude Code",
    "version": "1.0.0",
    "homepage": "https://github.com/acme-corp/acme-plugins"
  },
  "plugins": [
    {
      "name": "weather",
      "source": "./plugins/weather",
      "version": "1.0.0",
      "description": "Check weather forecasts and conditions using the OpenWeatherMap API.",
      "keywords": ["weather", "forecast", "temperature", "openweathermap"],
      "category": "productivity"
    }
  ]
}
```

### Step 3: Create plugin.json

**File: `acme-plugins/plugins/weather/.claude-plugin/plugin.json`**

```json
{
  "name": "weather",
  "version": "1.0.0",
  "description": "Check weather forecasts and conditions using the OpenWeatherMap API.",
  "author": { "name": "Acme Corp" },
  "license": "MIT",
  "repository": "https://github.com/acme-corp/acme-plugins",
  "keywords": ["weather", "forecast", "temperature"]
}
```

### Step 4: Create the Skill

**File: `acme-plugins/plugins/weather/skills/weather/SKILL.md`**

```markdown
---
name: weather
description: >
  Check weather conditions and forecasts. Use this skill whenever the user asks
  about weather, temperature, forecast, rain, snow, wind, humidity, or any
  meteorological data. Trigger for phrases like "what's the weather", "will it
  rain", "temperature in [city]", or "weekend forecast".
version: 1.0.0
---

# Weather Skill

Query current weather and forecasts via the OpenWeatherMap API.

## Authentication

Use the `OPENWEATHER_API_KEY` environment variable:

\```bash
curl "https://api.openweathermap.org/data/2.5/weather?q={city}&appid=$OPENWEATHER_API_KEY&units=metric"
\```

## Operations

### Current Weather

\```bash
curl -s "https://api.openweathermap.org/data/2.5/weather?q=London&appid=$OPENWEATHER_API_KEY&units=metric" | jq '{
  city: .name,
  temp: .main.temp,
  feels_like: .main.feels_like,
  humidity: .main.humidity,
  description: .weather[0].description,
  wind_speed: .wind.speed
}'
\```

### 5-Day Forecast

\```bash
curl -s "https://api.openweathermap.org/data/2.5/forecast?q=London&appid=$OPENWEATHER_API_KEY&units=metric&cnt=5"
\```
```

### Step 5: Create a Command (optional)

**File: `acme-plugins/plugins/weather/commands/weather.md`**

```markdown
---
description: Check current weather for a city
argument-hint: <city-name>
allowed-tools: [Bash]
---

# Weather Command

Check the current weather for the specified city.

The user asked for weather in: $ARGUMENTS

Use the weather skill to fetch and display the current conditions.
```

### Step 6: Create README Files

**File: `acme-plugins/README.md`**

```markdown
# Acme Plugins

Plugin marketplace for [Claude Code](https://claude.com/product/claude-code).

## Available Plugins

| Plugin | Description |
|--------|-------------|
| **[weather](./plugins/weather)** | Check weather forecasts via OpenWeatherMap |

## Installation

\```bash
/plugin marketplace add acme-corp/acme-plugins
/plugin install weather@acme-plugins
\```
```

**File: `acme-plugins/plugins/weather/README.md`**

```markdown
# Weather Plugin

Check weather conditions using the OpenWeatherMap API.

## Installation

\```bash
/plugin install weather@acme-plugins
\```

## Requirements

Set `OPENWEATHER_API_KEY` environment variable.

## Skills

| Skill | Description |
|-------|-------------|
| `weather` | Current weather and 5-day forecasts |

## Commands

| Command | Description |
|---------|-------------|
| `/weather <city>` | Quick weather check |
```

### Step 7: Create .mcp.json (empty for this plugin)

**File: `acme-plugins/plugins/weather/.mcp.json`**

```json
{
  "mcpServers": {}
}
```

### Step 8: Initialize Git and Push

```bash
cd acme-plugins
git init
git add -A
git commit -m "feat: Initial marketplace with weather plugin"
git remote add origin https://github.com/acme-corp/acme-plugins.git
git push -u origin main
```

### Step 9: Users Install

```bash
# In Claude Code:
/plugin marketplace add acme-corp/acme-plugins
/plugin install weather@acme-plugins
```

---

## 14. Pre-Publish Checklist

Before publishing or updating your marketplace:

### Repository Level

- [ ] `.claude-plugin/marketplace.json` exists at repo root
- [ ] `marketplace.json` has `name`, `owner`, and `plugins` fields
- [ ] All plugin `source` paths resolve correctly
- [ ] `README.md` has installation instructions
- [ ] `.gitignore` excludes `dist/`, `.DS_Store`, `node_modules/`
- [ ] `LICENSE` file exists

### Per Plugin

- [ ] `.claude-plugin/plugin.json` exists and is valid JSON
- [ ] `plugin.json` `name` matches `marketplace.json` entry name
- [ ] At least one of: `skills/`, `commands/`, `agents/`, or `.mcp.json` exists
- [ ] `README.md` documents what the plugin does

### Per Skill

- [ ] `SKILL.md` exists at `skills/<name>/SKILL.md`
- [ ] Frontmatter has `name` and `description`
- [ ] `description` includes specific trigger phrases, keywords, and scenarios
- [ ] Body has actionable instructions (not just documentation)
- [ ] `references/` files (if any) are referenced from SKILL.md

### Per Command

- [ ] Command file is at `commands/<name>.md`
- [ ] Frontmatter has `description`
- [ ] `$ARGUMENTS` is used if the command accepts input
- [ ] `allowed-tools` lists only what's needed

### Per MCP Server

- [ ] `.mcp.json` is valid JSON
- [ ] Server URLs are accessible
- [ ] Environment variables are documented in README

### Validation

- [ ] `marketplace.json` parses as valid JSON
- [ ] All `plugin.json` files parse as valid JSON
- [ ] All `.mcp.json` files parse as valid JSON
- [ ] Test install: `/plugin marketplace add .` from repo root
- [ ] Test activate: verify skills trigger for expected queries
- [ ] Token count: check skill sizes fit in context window

### Version Bump

- [ ] Update `version` in `marketplace.json` metadata
- [ ] Update `version` in each changed plugin's `plugin.json`
- [ ] Update `version` in each changed plugin's marketplace entry
- [ ] Commit and tag: `git tag v1.0.0`
