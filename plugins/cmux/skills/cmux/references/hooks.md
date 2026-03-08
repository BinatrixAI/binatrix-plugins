# cmux Hooks & Notifications Setup

Configure Claude Code hooks to send cmux desktop notifications when sessions complete or subagents finish.

---

## Hook Script

The hook script at `~/.claude/hooks/cmux-notify.sh` handles Claude Code lifecycle events:

```bash
#!/bin/bash
# ~/.claude/hooks/cmux-notify.sh
# Sends cmux notifications for Claude Code events

# Exit silently if not in cmux
[ -z "$CMUX_WORKSPACE_ID" ] && exit 0
command -v cmux >/dev/null 2>&1 || exit 0

# Read event from stdin
EVENT=$(cat)
HOOK_NAME="${CLAUDE_HOOK_EVENT_NAME:-unknown}"

case "$HOOK_NAME" in
  Stop)
    cmux notify --title "Session Complete" --body "Claude Code session finished"
    cmux claude-hook stop
    ;;
  PostToolUse)
    TOOL=$(echo "$EVENT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)
    if [ "$TOOL" = "Task" ] || [ "$TOOL" = "Agent" ]; then
      cmux notify --title "Agent Finished" --body "Subagent task completed"
    fi
    ;;
esac

exit 0
```

---

## Claude Code Settings

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/cmux-notify.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Agent",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/cmux-notify.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Built-in Claude Hook Command

cmux has a built-in `claude-hook` command for standardized lifecycle events:

```bash
cmux claude-hook session-start    # signal session started
cmux claude-hook stop             # signal session stopped
cmux claude-hook notification     # generic notification
```

These integrate with cmux's sidebar and notification system automatically.

---

## Custom Notification Command

In cmux **Settings > Notifications**, you can configure a custom notification command that runs for every notification. This can trigger OS-level notifications, sounds, or external webhooks.

---

## OSC Notification Protocols

cmux supports standard terminal notification escape sequences:

```bash
# OSC 777 (used by many terminals)
printf '\e]777;notify;%s;%s\e\\' "Title" "Body"

# OSC 99 (kitty notification protocol)
printf '\e]99;i=1:d=0;%s\e\\' "Notification text"
```

These work from any process running in a cmux terminal — no `cmux` CLI needed.

---

## Shell Helper Function

Add to your `.bashrc` or `.zshrc`:

```bash
# Run a command and notify when done
notify-after() {
  "$@"
  local status=$?
  if [ -n "$CMUX_WORKSPACE_ID" ] && command -v cmux >/dev/null 2>&1; then
    if [ $status -eq 0 ]; then
      cmux notify --title "Command Complete" --body "$1 finished successfully"
    else
      cmux notify --title "Command Failed" --body "$1 exited with code $status"
    fi
  fi
  return $status
}

# Usage: notify-after npm run build
```

---

## Verification

```bash
# Test notification
cmux notify --title "Test" --body "Hooks configured"

# Verify hook script is executable
ls -la ~/.claude/hooks/cmux-notify.sh

# Test hook script manually
echo '{}' | CLAUDE_HOOK_EVENT_NAME=Stop CMUX_WORKSPACE_ID=test ~/.claude/hooks/cmux-notify.sh
```
