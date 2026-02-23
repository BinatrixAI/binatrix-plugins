# Monday.com Plugin

A Monday.com management plugin for [Claude Code](https://claude.com/product/claude-code). Covers board CRUD, item management, CRM architecture, column value formatting, dashboards, automations, and workspace operations via the Monday.com GraphQL API.

## Installation

```bash
/plugin install monday-com@binatrix-plugins
```

## What It Does

This plugin gives Claude deep knowledge of Monday.com's API and architecture:

- **Board & Item Management** — Create, read, update, delete boards, items, subitems, groups, and columns
- **CRM Architecture** — Full 4-board CRM setup (Leads/Deals/Contacts/Accounts) with connected boards and mirror columns
- **Column Value Formatting** — Exact JSON formats for all 30+ column types, including escaping rules
- **Dashboard & Widget Patterns** — Numbers, charts, battery, table, and Gantt widget configurations
- **Automation Recipes** — Common automation patterns for CRM, project management, and operations
- **Error Handling** — Complete error code reference with troubleshooting steps
- **Rate Limit Management** — Complexity budget awareness and pagination best practices

## Skills

| Skill | What It Covers |
|-------|----------------|
| `monday-com` | Full Monday.com API knowledge — authentication, CRUD operations, column formatting, CRM patterns, error handling, and rate limits |

## Data Sources

**Included MCP connections:**
- monday.com — Board management, item operations, and workspace administration

See [CONNECTORS.md](CONNECTORS.md) for details.

## Reference Files

The skill includes detailed reference documentation:
- `column-types.md` — Every column type's JSON format with edge cases
- `common-patterns.md` — CRM templates, board architectures, dashboard widgets, automations
- `api-reference.md` — Complete GraphQL reference, webhooks, file uploads, error codes
