# Binatrix Plugins

Plugin marketplace for [Claude Code](https://claude.com/product/claude-code) — Monday.com management, cmux terminal control, Typst PDF generation, CRM architecture, and workflow automation.

## Available Plugins

| Plugin | Description | Size |
|--------|-------------|------|
| **[monday-com](./plugins/monday-com)** | Full Monday.com management — boards, items, CRM, column types, API reference | ~1,500 lines |
| **[monday-com-lite](./plugins/monday-com-lite)** | Same coverage, optimized for minimal token usage | ~280 lines |
| **[cmux](./plugins/cmux)** | cmux terminal multiplexer — workspaces, splits, browser automation, sidebar metadata, notifications | ~300 lines + references |
| **[typst](./plugins/typst)** | Typst PDF generation — résumés / cover letters via `@preview/modern-cv`, plus touying presentations and handout templates | ~300 lines + 9 references |

## Installation

```bash
# Add marketplace
/plugin marketplace add BinatrixAI/binatrix-plugins

# Install plugins
/plugin install monday-com@binatrix-plugins
/plugin install monday-com-lite@binatrix-plugins
/plugin install cmux@binatrix-plugins
/plugin install typst@binatrix-plugins
```

Or add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "cmux@binatrix-plugins": true,
    "monday-com@binatrix-plugins": true,
    "typst@binatrix-plugins": true
  }
}
```

## Plugins

### monday-com / monday-com-lite

Manage Monday.com boards, items, columns, groups, automations, and workspaces via the GraphQL API.

- **monday-com** — Full reference with detailed examples and complete API docs
- **monday-com-lite** — ~70% fewer tokens with the same operational coverage

### cmux

Control [cmux](https://cmux.dev) — a native macOS terminal built on Ghostty — from Claude Code sessions:

- **Terminal management**: Workspaces, panes, splits, surfaces
- **Terminal I/O**: Read screen output, send text/keys, capture panes
- **Browser automation**: Full browser control in split panes (navigate, click, fill, snapshot)
- **Sidebar metadata**: Status badges, progress bars, activity logs
- **Notifications**: Desktop notifications + Claude Code hooks integration
- **Multi-agent workflows**: Coordinate multiple agents across split panes

### typst

Generate PDFs from Typst — primary path is résumés / cover letters via [`@preview/modern-cv`](https://typst.app/universe/package/modern-cv) (the Awesome-CV look ported to Typst), with full fallback templates for handouts, reports, essays, and touying presentations.

- **Activation**: "make me a resume", "convert to PDF", "PDF version", "render as PDF", or any `.typ` editing
- **Default template**: `@preview/modern-cv` for résumés + cover letters; `@preview/neat-cv` as the colourful sidebar alternative
- **Font preflight**: bundled `scripts/preflight-fonts.sh` diagnoses missing Roboto / Source Sans Pro / FontAwesome on macOS and prints brew remediation
- **Visual handout patterns**: "AT A GLANCE" exec-summary callouts, side-by-side comparison cards, green Result callouts, stat cards, eyebrow titles — paste-runnable helpers for any prose-to-PDF work
- **Presentations**: touying 0.6.x API (metropolis, university, stargazer, dewdrop themes)
- **9 reference files**: `resume.md`, `errors.md`, `syntax.md`, `templates.md`, `touying.md`, `packages.md`, `math.md`, `symbols.md`, `verification.md`

Requires Typst 0.14+ installed locally (`brew install typst`).

## Plugin Structure

Each plugin follows the standard Claude Code plugin format:

```
plugins/<name>/
├── skills/<skill>/SKILL.md      # Skill knowledge file
├── skills/<skill>/references/   # Detailed reference docs
├── README.md                    # Plugin docs
└── LICENSE                      # MIT
```

## License

MIT
