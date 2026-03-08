# cmux Plugin for Claude Code

Control [cmux](https://cmux.dev) — a native macOS terminal built on Ghostty — from Claude Code sessions.

## Features

- **Terminal Management**: Workspaces, panes, splits, surfaces
- **Terminal I/O**: Read screen output, send text/keys, capture panes
- **Browser Automation**: Full browser control in split panes
- **Sidebar Metadata**: Status badges, progress bars, activity logs
- **Notifications**: Desktop notifications via CLI
- **Hooks**: Auto-notify on session/agent completion

## Installation

This plugin is part of the binatrix-plugins marketplace. Enable it in Claude Code settings:

```json
{
  "enabledPlugins": {
    "cmux@binatrix-plugins": true
  }
}
```

## Skills

- **cmux** — Full cmux terminal multiplexer control

## References

- `references/browser.md` — Browser automation commands
- `references/shortcuts.md` — Keyboard shortcuts
- `references/hooks.md` — Hooks & notification setup
