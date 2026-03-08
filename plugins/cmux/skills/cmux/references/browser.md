# cmux Browser Automation Reference

Full reference for `cmux browser` commands. Browser panes use a built-in automation engine.

## Surface Targeting

Most browser commands accept a surface handle:
```bash
cmux browser --surface surface:2 <subcommand>
cmux browser surface:2 <subcommand>       # positional shorthand
```

If omitted, uses `$CMUX_SURFACE_ID` or the focused browser surface.

---

## Navigation

```bash
# Open browser (new split or navigate existing)
cmux browser open [url]
cmux browser open-split [url]              # always creates new split

# Navigate
cmux browser goto <url>                    # alias: navigate
cmux browser back
cmux browser forward
cmux browser reload

# Get current URL
cmux browser url                           # alias: get-url
```

All navigation commands support `--snapshot-after` to auto-capture DOM after action.

---

## Waiting

```bash
# Wait for element
cmux browser wait --selector ".my-class"

# Wait for text to appear
cmux browser wait --text "Loading complete"

# Wait for URL change
cmux browser wait --url-contains "/dashboard"

# Custom timeout (default varies)
cmux browser wait --selector "#result" --timeout-ms 10000
```

---

## DOM Interaction

### Clicking & Hovering

```bash
cmux browser click "#submit-btn"           # click element
cmux browser dblclick ".item"              # double-click
cmux browser hover ".dropdown-trigger"     # hover
```

### Text Input

```bash
# Type text (simulates keystrokes, triggers events)
cmux browser type "#search" "query text"

# Fill input (sets value directly, faster)
cmux browser fill "#email" "user@example.com"
cmux browser fill "#email"                 # empty = clear input

# Press keys
cmux browser press Enter
cmux browser press Tab
cmux browser keydown Shift
cmux browser keyup Shift
```

### Form Controls

```bash
# Select dropdown
cmux browser select "#country" "US"

# Scroll
cmux browser scroll --dy 500               # scroll down 500px
cmux browser scroll --selector ".list" --dy 200  # scroll within element
cmux browser scroll --dx -100              # scroll left
```

All interaction commands support `--snapshot-after`.

---

## Inspection

### DOM Snapshot

```bash
# Basic snapshot (text content)
cmux browser snapshot

# Interactive snapshot (includes form elements, buttons, links)
cmux browser snapshot --interactive
cmux browser snapshot -i                   # shorthand

# With cursor position
cmux browser snapshot --cursor

# Compact output
cmux browser snapshot --compact

# Limit depth
cmux browser snapshot --max-depth 3

# Snapshot specific section
cmux browser snapshot --selector "main"
cmux browser snapshot --selector "#content"
```

### Reading Page Data

```bash
# Page-level properties
cmux browser get url
cmux browser get title

# Element text/HTML
cmux browser get text "#result"
cmux browser get html "#content"

# Form values
cmux browser get value "#email-input"

# Element attributes
cmux browser get attr "#link" href

# Count matching elements
cmux browser get count ".list-item"

# Bounding box
cmux browser get box "#element"

# Computed styles
cmux browser get styles "#element"
```

### Element State

```bash
cmux browser is visible "#modal"
cmux browser is enabled "#submit-btn"
cmux browser is checked "#agree-checkbox"
```

### Finding Elements

```bash
cmux browser find role button
cmux browser find text "Sign In"
cmux browser find label "Email address"
cmux browser find placeholder "Enter your email"
cmux browser find testid "submit-button"
cmux browser find alt "Company logo"
cmux browser find title "Close dialog"
cmux browser find first ".items"
cmux browser find last ".items"
cmux browser find nth ".items" 3
```

### Highlighting

```bash
# Highlight element (visual debug aid)
cmux browser highlight "#target-element"
```

---

## JavaScript Execution

```bash
# Evaluate expression and return result
cmux browser eval "document.title"
cmux browser eval "document.querySelectorAll('a').length"
cmux browser eval "JSON.stringify(localStorage)"

# Add init script (runs on every navigation)
cmux browser addinitscript "window.__TEST__ = true"

# Add script tag
cmux browser addscript "console.log('injected')"

# Add stylesheet
cmux browser addstyle "body { outline: 1px solid red; }"
```

---

## State Management

### Cookies

```bash
cmux browser cookies get
cmux browser cookies set <name> <value> [--domain <domain>]
cmux browser cookies clear
```

### Storage

```bash
cmux browser storage local get [key]
cmux browser storage local set <key> <value>
cmux browser storage local clear

cmux browser storage session get [key]
cmux browser storage session set <key> <value>
cmux browser storage session clear
```

### Save/Load State

```bash
# Save browser state (cookies, storage) to file
cmux browser state save /tmp/browser-state.json

# Load state from file
cmux browser state load /tmp/browser-state.json
```

---

## Tabs

```bash
cmux browser tab list
cmux browser tab new [url]
cmux browser tab switch <index>
cmux browser tab close [index]
cmux browser tab 0                         # switch by index
```

---

## Console & Errors

```bash
# View console messages
cmux browser console list
cmux browser console clear

# View page errors
cmux browser errors list
cmux browser errors clear
```

---

## Frames

```bash
# Switch to iframe
cmux browser frame "#my-iframe"

# Switch back to main frame
cmux browser frame main
```

---

## Dialogs

```bash
# Accept dialog (alert/confirm/prompt)
cmux browser dialog accept
cmux browser dialog accept "input text"    # for prompt dialogs

# Dismiss dialog
cmux browser dialog dismiss
```

---

## Downloads

```bash
# Wait for download to complete
cmux browser download wait --timeout-ms 30000

# Specify download path
cmux browser download wait --path /tmp/downloads/
```

---

## Viewport & Geo (Chromium only)

These return `not_supported` on WKWebView:

```bash
cmux browser viewport 1920 1080
cmux browser geolocation 37.7749 -122.4194
cmux browser geo 37.7749 -122.4194        # alias
cmux browser offline true                  # simulate offline
cmux browser offline false
```

---

## Network (Chromium only)

```bash
cmux browser network route <pattern> [response]
cmux browser network unroute <pattern>
cmux browser network requests
```

---

## Workflow Patterns

### Form Testing

```bash
cmux browser open http://localhost:3000/signup
cmux browser wait --selector "form"
cmux browser fill "#name" "Test User"
cmux browser fill "#email" "test@example.com"
cmux browser fill "#password" "SecurePass123"
cmux browser select "#role" "admin"
cmux browser click "#submit"
cmux browser wait --text "Welcome"
cmux browser snapshot
```

### Page Content Extraction

```bash
cmux browser goto https://example.com/api/docs
cmux browser wait --selector ".api-reference"
cmux browser snapshot --selector ".api-reference" --compact
```

### Multi-Page Navigation

```bash
cmux browser goto https://app.example.com/login
cmux browser fill "#email" "user@test.com"
cmux browser fill "#password" "pass"
cmux browser click "#login"
cmux browser wait --url-contains "/dashboard"
cmux browser snapshot --interactive
cmux browser click "a[href='/settings']"
cmux browser wait --selector ".settings-form"
cmux browser snapshot
```

### State Persistence Across Sessions

```bash
# Save authenticated state
cmux browser state save /tmp/auth-state.json

# Later: restore state
cmux browser state load /tmp/auth-state.json
cmux browser goto https://app.example.com/dashboard
# Should still be logged in
```
