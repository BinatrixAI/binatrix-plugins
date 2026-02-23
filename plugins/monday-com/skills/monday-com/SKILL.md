---
name: monday-com
description: >
  Manage Monday.com boards, items, columns, groups, automations, and workspaces via the Monday.com
  GraphQL API. Use this skill whenever the user mentions Monday.com, monday, board management,
  work OS, project tracking on Monday, CRM in Monday, creating boards, updating items, managing
  columns, checking board status, Monday dashboards, Monday automations, or any task involving
  reading or writing data in Monday.com. Also trigger when the user references workspace setup,
  item creation, column configuration, board templates, Monday integrations, subitems, connected
  boards, mirror columns, Monday formulas, timeline management, or any Monday.com-specific
  terminology like "pulse", "board view", or "Monday widget". Even if the user just says
  "update my board" or "check my tasks" and Monday.com is their known project management tool,
  use this skill.
---

# Monday.com Management Skill

Manage Monday.com boards, items, columns, workspaces, and automations via the GraphQL API. This skill covers all core CRUD operations, CRM configurations, dashboard setup, and workflow automation patterns.

## How to Use

1. User asks to interact with their Monday.com account (read boards, create items, update statuses, etc.)
2. Authenticate using the `MONDAY_API_TOKEN` environment variable
3. Execute GraphQL queries/mutations against `https://api.monday.com/v2`
4. Return formatted, human-readable results

**Example prompts:**
- "Show me all my Monday boards"
- "Create a new item in my Sales Pipeline board"
- "Update the status of task X to Done"
- "Set up a new CRM board with leads, deals, and contacts"
- "What items are overdue on my project board?"
- "Add a people column to my board"
- "Create a workspace for my new client"

## Authentication

All API calls use a bearer token:

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_TOKEN" \
  -H "API-Version: 2024-10" \
  -d '{"query": "<GRAPHQL_QUERY>"}'
```

**Important:** Always include the `API-Version: 2024-10` header for the latest stable API behavior.

## Core Operations

### Reading Data

#### List boards
```graphql
query {
  boards(limit: 25) {
    id name description board_kind state
    workspace { id name }
    columns { id title type settings_str }
    groups { id title color }
    owners { id name }
  }
}
```

#### Get board items with column values
```graphql
query {
  boards(ids: [BOARD_ID]) {
    items_page(limit: 50) {
      cursor
      items {
        id name created_at updated_at
        group { id title }
        column_values {
          id type text value
          ... on StatusValue { label }
          ... on PeopleValue { persons_and_teams { id kind } }
          ... on DateValue { date time }
          ... on NumbersValue { number }
          ... on DropdownValue { values { id name } }
        }
      }
    }
  }
}
```

#### Paginate through items (cursor-based)
```graphql
query {
  next_items_page(limit: 50, cursor: "CURSOR_FROM_PREVIOUS") {
    cursor
    items { id name column_values { id text value } }
  }
}
```

#### Search items across boards
```graphql
query {
  items_page_by_column_values(
    board_id: BOARD_ID
    limit: 50
    columns: [{ column_id: "status", column_values: ["Done"] }]
  ) {
    cursor
    items { id name column_values { id text } }
  }
}
```

### Creating Data

#### Create a board
```graphql
mutation {
  create_board(
    board_name: "My New Board"
    board_kind: public
    workspace_id: WORKSPACE_ID
  ) { id }
}
```

#### Create columns
```graphql
mutation {
  create_column(
    board_id: BOARD_ID
    title: "Priority"
    column_type: status
    defaults: "{\"labels\":{\"0\":\"High\",\"1\":\"Medium\",\"2\":\"Low\"}}"
  ) { id title }
}
```

#### Create items with column values
```graphql
mutation {
  create_item(
    board_id: BOARD_ID
    group_id: "topics"
    item_name: "New Task"
    column_values: "{\"status\":{\"label\":\"Working on it\"},\"date\":{\"date\":\"2026-03-15\"},\"numbers\":42,\"text\":\"Some notes\"}"
  ) { id }
}
```

#### Create subitems
```graphql
mutation {
  create_subitem(
    parent_item_id: PARENT_ID
    item_name: "Sub-task"
    column_values: "{\"status\":{\"label\":\"Done\"}}"
  ) { id }
}
```

### Updating Data

#### Change column values
```graphql
mutation {
  change_multiple_column_values(
    board_id: BOARD_ID
    item_id: ITEM_ID
    column_values: "{\"status\":{\"label\":\"Done\"},\"date\":{\"date\":\"2026-02-20\"}}"
  ) { id }
}
```

#### Move item to group
```graphql
mutation {
  move_item_to_group(item_id: ITEM_ID, group_id: "new_group") { id }
}
```

#### Archive/delete items
```graphql
mutation { archive_item(item_id: ITEM_ID) { id } }
mutation { delete_item(item_id: ITEM_ID) { id } }
```

### Groups
```graphql
mutation {
  create_group(board_id: BOARD_ID, group_name: "Sprint 3", group_color: "#00c875") { id }
}
mutation {
  move_item_to_group(item_id: ITEM_ID, group_id: "GROUP_ID") { id }
}
```

### Workspaces
```graphql
query { workspaces { id name description } }
mutation {
  create_workspace(name: "Client Project", kind: open, description: "Workspace for client X") { id }
}
```

## Column Value Formatting

This is critical — Monday's API expects specific JSON formats per column type. See `references/column-types.md` for the complete reference.

**Quick reference for common types:**

| Column Type | Format | Example |
|---|---|---|
| `status` | `{"label": "VALUE"}` | `{"label": "Done"}` |
| `text` | `"string value"` | `"Hello world"` |
| `numbers` | `number` | `42` or `"42"` |
| `date` | `{"date": "YYYY-MM-DD"}` | `{"date": "2026-03-15"}` |
| `date` + time | `{"date": "YYYY-MM-DD", "time": "HH:MM:SS"}` | `{"date": "2026-03-15", "time": "09:30:00"}` |
| `email` | `{"email": "a@b.com", "text": "label"}` | `{"email": "john@co.com", "text": "John"}` |
| `phone` | `{"phone": "number", "countryShortName": "XX"}` | `{"phone": "+1234567890", "countryShortName": "US"}` |
| `link` | `{"url": "https://...", "text": "label"}` | `{"url": "https://x.com", "text": "Site"}` |
| `people` | `{"personsAndTeams": [{"id": ID, "kind": "person"}]}` | (use user IDs) |
| `dropdown` | `{"labels": ["val1", "val2"]}` | `{"labels": ["Option A"]}` |
| `checkbox` | `{"checked": "true"}` | `{"checked": "true"}` |
| `timeline` | `{"from": "YYYY-MM-DD", "to": "YYYY-MM-DD"}` | `{"from": "2026-01-01", "to": "2026-03-31"}` |
| `long_text` | `{"text": "content"}` | `{"text": "Long description"}` |
| `rating` | `{"rating": 5}` | `{"rating": 3}` |
| `country` | `{"countryCode": "XX", "countryName": "Name"}` | `{"countryCode": "US", "countryName": "United States"}` |
| `connect_boards` | `{"item_ids": [ID1, ID2]}` | `{"item_ids": [123456]}` |

**Critical gotcha:** The entire `column_values` parameter must be a **JSON string** (escaped), not a JSON object. In curl, double-escape:
```bash
column_values: "{\\\"status\\\":{\\\"label\\\":\\\"Done\\\"}}"
```

## Common Workflows

### CRM Board Setup
See `references/common-patterns.md` for full CRM architecture patterns including:
- Leads -> Deals -> Contacts -> Accounts pipeline
- Connected boards with mirror columns
- Dashboard widget configurations
- Formula column patterns

### Batch Operations
When creating multiple items, use a loop. The API does not support batch item creation natively:
```bash
for item in "${items[@]}"; do
  curl -s -X POST https://api.monday.com/v2 \
    -H "Content-Type: application/json" \
    -H "Authorization: $MONDAY_API_TOKEN" \
    -H "API-Version: 2024-10" \
    -d "{\"query\": \"mutation { create_item(board_id: $BOARD_ID, item_name: \\\"$item\\\") { id } }\"}"
  sleep 0.5  # respect rate limits
done
```

### Reading Updates (Comments)
```graphql
query {
  items(ids: [ITEM_ID]) {
    updates(limit: 10) {
      id body text_body created_at
      creator { id name }
    }
  }
}
```

### Creating Updates
```graphql
mutation {
  create_update(item_id: ITEM_ID, body: "This is a comment on the item.") { id }
}
```

## Rate Limits & Best Practices

- **Complexity budget:** 5,000,000 points per minute (query cost based on requested fields)
- **Pagination:** Always use cursor-based pagination, never request all items at once
- **Limit requests:** Use `limit` parameter, default to 25-50 items per page
- **Batching:** Add 500ms delay between mutations in loops
- **Error handling:** Check for `errors` array in response and `error_code` field
- **Column IDs:** Always query board schema first to get correct column IDs — they are auto-generated strings like `status4`, `date_1`, `text_mkrc`

## Error Handling

Monday API errors return in this format:
```json
{
  "errors": [{ "message": "...", "extensions": { "code": "..." } }],
  "account_id": 12345
}
```

Common errors:
- `InvalidColumnIdException` — Wrong column ID. Query the board's columns first.
- `InvalidUserIdException` — User ID doesn't exist in the account.
- `ColumnValueException` — Malformed column value JSON. Check formatting.
- `ResourceNotFoundException` — Board/item ID doesn't exist.
- `ComplexityException` — Query too expensive. Reduce fields or use pagination.
- `UserUnauthorizedException` — Token doesn't have required scopes.

**When you get an error, always:**
1. Query the board schema to verify column IDs and types
2. Verify the column value format matches the column type
3. Check that referenced IDs (boards, items, users) actually exist

## Helper: Query Board Schema

Always run this first when working with an unfamiliar board:
```graphql
query {
  boards(ids: [BOARD_ID]) {
    id name
    columns { id title type settings_str }
    groups { id title color }
    owners { id name }
  }
}
```

This returns column IDs, types, and settings (including status label mappings, dropdown options, etc.) needed to correctly format values.

## Reference Files

- `references/column-types.md` — Complete column value formatting for every column type, including edge cases and complex types like formula, mirror, and connect_boards
- `references/common-patterns.md` — CRM architecture templates, dashboard patterns, automation recipes, and common board structures
- `references/api-reference.md` — Full GraphQL query/mutation reference, webhooks, file uploads, and advanced operations

Read these when you need detailed information beyond the quick-start patterns above.
