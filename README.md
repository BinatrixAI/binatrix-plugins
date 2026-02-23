# Binatrix Plugins

Plugin marketplace for [Claude Code](https://claude.com/product/claude-code) — Monday.com management, CRM architecture, and workflow automation.

## Available Plugins

| Plugin | Description | Size |
|--------|-------------|------|
| **[monday-com](./plugins/monday-com)** | Full Monday.com management — boards, items, CRM, column types, API reference | ~1,500 lines |
| **[monday-com-lite](./plugins/monday-com-lite)** | Same coverage, optimized for minimal token usage | ~280 lines |

## Installation

```bash
# Add marketplace
/plugin marketplace add BinatrixAI/binatrix-plugins

# Install a plugin
/plugin install monday-com@binatrix-plugins

# Or the lite version (lower token usage)
/plugin install monday-com-lite@binatrix-plugins
```

## Which version should I use?

- **monday-com** — Full reference with detailed examples, edge cases, and complete API documentation. Best when you need comprehensive Monday.com coverage.
- **monday-com-lite** — ~70% fewer tokens with the same operational coverage. Best for everyday use when context window space matters.

## Plugin Structure

Each plugin follows the standard Claude Code plugin format:

```
plugins/<name>/
├── .claude-plugin/plugin.json   # Plugin metadata
├── skills/<skill>/SKILL.md      # Skill knowledge file
├── skills/<skill>/references/   # Detailed reference docs
├── .mcp.json                    # MCP connections (if any)
├── CONNECTORS.md                # Tool category mappings
├── README.md                    # Plugin docs
└── LICENSE                      # MIT
```

## License

MIT
