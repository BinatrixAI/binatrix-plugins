---
name: cmux
description: >
  Control cmux terminal multiplexer — manage workspaces, panes, splits, browser automation,
  sidebar metadata, notifications, and terminal I/O. Use this skill whenever the user mentions
  cmux, terminal splits, browser panes, cmux notifications, sidebar status, progress bars,
  multi-agent workflows, reading terminal output, sending keys, screen capture, cmux hooks,
  or any task involving programmatic control of cmux terminal windows. Also trigger when
  working with split panes, browser automation in terminal, workspace management, or when
  $CMUX_WORKSPACE_ID is set. Even for "open a browser", "split the terminal", "show progress",
  or "notify me when done" — if cmux is available, use this skill.
---

# cmux Terminal Multiplexer Skill

Control cmux — a native macOS terminal built on Ghostty — for managing AI coding agent workflows with split panes, browser automation, sidebar metadata, and notifications.

## Detection

cmux is available when:
- `$CMUX_WORKSPACE_ID` environment variable is set (auto-set in cmux terminals)
- Socket exists at `/tmp/cmux.sock` (or `$CMUX_SOCKET_PATH`)
- `cmux ping` returns successfully

**Environment variables** (auto-set in cmux terminals):
- `CMUX_WORKSPACE_ID` — current workspace ID (used as default `--workspace`)
- `CMUX_SURFACE_ID` — current surface/tab ID (used as default `--surface`)
- `CMUX_TAB_ID` — optional tab alias
- `CMUX_SOCKET_PATH` — override default socket path

## Handle Formats

cmux supports three handle formats:
- **Refs** (default): `window:1/workspace:2/pane:3/surface:4`
- **UUIDs**: full UUID strings
- **Indexes**: numeric (0-based)

Pass `--id-format uuids` or `--id-format both` to include UUIDs in output.

---

## Core CLI Commands

### Workspaces

```bash
# List all workspaces
cmux list-workspaces

# Current workspace info
cmux current-workspace

# Create new workspace (optionally with a command)
cmux new-workspace [--command "npm run dev"]

# Select/switch workspace
cmux select-workspace --workspace workspace:2

# Rename workspace
cmux rename-workspace --workspace workspace:1 "My Project"

# Close workspace
cmux close-workspace --workspace workspace:2

# Reorder workspace
cmux reorder-workspace --workspace workspace:2 --index 0
cmux reorder-workspace --workspace workspace:2 --after workspace:1
```

### Windows

```bash
cmux list-windows
cmux current-window
cmux new-window
cmux focus-window --window window:2
cmux close-window --window window:1
cmux rename-window "Dev Window"

# Move workspace to different window
cmux move-workspace-to-window --workspace workspace:1 --window window:2
```

### Panes & Splits

```bash
# List panes in workspace
cmux list-panes [--workspace workspace:1]

# Create new split (direction relative to current pane)
cmux new-split right                    # split right of current pane
cmux new-split down --pane pane:1       # split below specific pane

# Create new pane (terminal or browser)
cmux new-pane --type terminal --direction right
cmux new-pane --type browser --url https://example.com --direction right

# Focus a pane
cmux focus-pane --pane pane:2

# Resize pane
cmux resize-pane --pane pane:1 -R --amount 20   # expand right by 20
cmux resize-pane --pane pane:1 -D --amount 10   # expand down by 10

# Swap panes
cmux swap-pane --pane pane:1 --target-pane pane:2

# Close a surface (tab within a pane)
cmux close-surface --surface surface:3
```

### Surfaces (Tabs within Panes)

```bash
# List surfaces in a pane
cmux list-pane-surfaces --pane pane:1

# Create new surface (tab) in existing pane
cmux new-surface --type terminal --pane pane:1
cmux new-surface --type browser --pane pane:1 --url https://docs.example.com

# Move surface between panes
cmux move-surface --surface surface:2 --pane pane:3

# Rename tab
cmux rename-tab --surface surface:1 "API Server"

# Drag surface to create a new split
cmux drag-surface-to-split --surface surface:2 right
```

---

## Terminal I/O

### Reading Terminal Output

```bash
# Read current visible screen
cmux read-screen

# Read with scrollback history
cmux read-screen --scrollback

# Read specific number of lines
cmux read-screen --lines 50

# Read from specific surface
cmux read-screen --surface surface:2

# tmux-compatible alias
cmux capture-pane [--scrollback] [--lines 100]
```

### Sending Input

```bash
# Send text to terminal (as if typed)
cmux send "npm run build"

# Send text + Enter
cmux send "npm run build\n"

# Send special keys
cmux send-key enter
cmux send-key ctrl-c
cmux send-key ctrl-d
cmux send-key tab
cmux send-key escape
cmux send-key up
cmux send-key down

# Send to specific surface
cmux send --surface surface:2 "git status"

# Send to a panel
cmux send-panel --panel panel:1 "command"
cmux send-key-panel --panel panel:1 enter

# Pipe terminal output to a command
cmux pipe-pane --command "tee /tmp/output.log"
```

### Signaling

```bash
# Wait for a named signal (blocks until signaled or timeout)
cmux wait-for build-done --timeout 30

# Signal a waiting process
cmux wait-for --signal build-done
```

---

## Sidebar Metadata

Display status, progress, and logs in the cmux sidebar for the current workspace.

### Status Badges

```bash
# Set a status key-value with optional icon and color
cmux set-status "task" "building" --icon "hammer" --color "#f59e0b"
cmux set-status "tests" "passing" --icon "checkmark.circle" --color "#22c55e"
cmux set-status "deploy" "staging" --icon "cloud" --color "#3b82f6"

# Clear a specific status
cmux clear-status "task"

# List all status entries
cmux list-status
```

### Progress Bar

```bash
# Set progress (0.0 to 1.0) with optional label
cmux set-progress 0.5 --label "Building (50%)"
cmux set-progress 0.75 --label "Tests running..."
cmux set-progress 1.0 --label "Complete"

# Clear progress bar
cmux clear-progress
```

### Activity Log

```bash
# Log messages at different levels
cmux log "Starting build process"
cmux log --level info "Compiled 42 files"
cmux log --level warn "Deprecated API usage detected"
cmux log --level error "Build failed: missing dependency"
cmux log --level info --source "test" "All 128 tests passed"

# List recent log entries
cmux list-log --limit 20

# Clear log
cmux clear-log

# Get full sidebar state
cmux sidebar-state
```

---

## Notifications

```bash
# Send a desktop notification
cmux notify --title "Build Complete" --body "All tests passed"
cmux notify --title "Error" --subtitle "Build" --body "TypeScript compilation failed"

# List recent notifications
cmux list-notifications

# Clear notifications
cmux clear-notifications

# Claude Code hook (built-in notification events)
cmux claude-hook session-start
cmux claude-hook stop
cmux claude-hook notification
```

---

## Browser Automation

cmux includes a full browser automation engine in split panes. See [references/browser.md](references/browser.md) for complete documentation.

### Quick Reference

```bash
# Open browser in new split
cmux browser open https://example.com

# Navigate
cmux browser goto https://new-url.com

# Get DOM snapshot (for AI analysis)
cmux browser snapshot
cmux browser snapshot --interactive    # include interactive elements
cmux browser snapshot --selector "main"

# Interact
cmux browser click "#submit-btn"
cmux browser fill "#email" "user@example.com"
cmux browser type "#search" "query text"
cmux browser select "#country" "US"

# Read page data
cmux browser get url
cmux browser get title
cmux browser get text "#result"
cmux browser get html "#content"

# Wait for conditions
cmux browser wait --selector ".loaded"
cmux browser wait --text "Success"
cmux browser wait --url-contains "/dashboard"

# Execute JavaScript
cmux browser eval "document.title"
```

---

## Keyboard Shortcuts

See [references/shortcuts.md](references/shortcuts.md) for the complete shortcuts reference.

---

## Hooks Integration

See [references/hooks.md](references/hooks.md) for setting up Claude Code hooks with cmux notifications.

---

## Common Patterns

### Multi-Agent Workflow

```bash
# Set up workspace with multiple agent panes
cmux rename-workspace "Multi-Agent"

# Create splits for parallel agents
cmux new-split right
cmux new-split down --pane pane:1

# Track progress in sidebar
cmux set-status "agent-1" "refactoring" --icon "hammer"
cmux set-status "agent-2" "testing" --icon "testtube.2"
cmux set-progress 0.33 --label "1/3 agents complete"

# Monitor output from any pane
cmux read-screen --surface surface:2
```

### Build Monitoring

```bash
# Start build in a split
cmux new-split right
cmux send --surface surface:2 "npm run build 2>&1\n"

# Update sidebar with progress
cmux set-status "build" "running" --icon "hammer" --color "#f59e0b"
cmux log --source "build" "Build started"

# Check output
cmux read-screen --surface surface:2

# On completion
cmux set-status "build" "passed" --icon "checkmark.circle" --color "#22c55e"
cmux set-progress 1.0 --label "Build complete"
cmux notify --title "Build" --body "Build completed successfully"
```

### Browser-Assisted Development

```bash
# Open docs alongside terminal
cmux new-pane --type browser --url https://docs.cloudflare.com --direction right

# Check app in browser
cmux browser open http://localhost:3000

# Wait for page load then snapshot
cmux browser wait --selector "#app"
cmux browser snapshot --interactive

# Fill a form for testing
cmux browser fill "#username" "testuser"
cmux browser fill "#password" "testpass"
cmux browser click "#login-btn"
cmux browser wait --url-contains "/dashboard"
cmux browser snapshot
```

### Progress Tracking Pattern

```bash
# At task start
cmux set-status "task" "starting" --icon "play" --color "#3b82f6"
cmux set-progress 0.0 --label "Starting..."
cmux log "Task initiated"

# During work
cmux set-progress 0.5 --label "Processing files..."
cmux log --level info "Processed 50/100 files"

# On completion
cmux set-status "task" "complete" --icon "checkmark.circle" --color "#22c55e"
cmux set-progress 1.0 --label "Done"
cmux log --level info "Task completed successfully"
cmux notify --title "Task Complete" --body "All files processed"

# Cleanup
cmux clear-progress
cmux clear-status "task"
```
