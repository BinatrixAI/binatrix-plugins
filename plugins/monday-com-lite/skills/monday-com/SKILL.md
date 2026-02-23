---
name: monday-com
description: >
  Manage Monday.com boards, items, columns, groups, workspaces via GraphQL API. Use when user
  mentions Monday.com, boards, items, statuses, CRM setup, workspace management, column config,
  dashboards, automations, subitems, connected boards, mirror columns, or any Monday-specific
  terminology. Also trigger on "update my board", "check tasks", "create items" when Monday.com
  is the user's project tool.
---

# Monday.com Skill

Manage Monday.com via GraphQL API at `https://api.monday.com/v2`.

## Auth
```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type:application/json" \
  -H "Authorization:$MONDAY_API_TOKEN" \
  -H "API-Version:2024-10" \
  -d '{"query":"GRAPHQL_HERE"}'
```

## Core Queries

**List boards:** `{ boards(limit:25) { id name columns { id title type settings_str } groups { id title } } }`

**Board items (paginated):**
```graphql
{ boards(ids:[ID]) { items_page(limit:50) { cursor items {
  id name group { id title }
  column_values { id type text value
    ...on StatusValue { label } ...on DateValue { date time }
    ...on NumbersValue { number } ...on PeopleValue { persons_and_teams { id kind } }
    ...on DropdownValue { values { id name } } ...on BoardRelationValue { linked_item_ids }
  }
  subitems { id name column_values { id text value } }
}}}}
```

**Next page:** `{ next_items_page(limit:50, cursor:"CURSOR") { cursor items { id name column_values { id text } } } }`

**Filter items:**
```graphql
{ boards(ids:[ID]) { items_page(limit:50, query_params: {
  rules:[{column_id:"status", compare_value:["Done"], operator:any_of}], operator:and
}) { cursor items { id name } } } }
```
Operators: `any_of`, `not_any_of`, `is_empty`, `is_not_empty`, `greater_than`, `lower_than`, `between`, `contains_text`, `within_the_next`, `within_the_last`

**Users:** `{ users(limit:50) { id name email } }`
**Me:** `{ me { id name email } }`
**Workspaces:** `{ workspaces { id name kind } }`

## Core Mutations

**Create board:** `mutation { create_board(board_name:"Name", board_kind:public, workspace_id:WS) { id } }`

**Create column:** `mutation { create_column(board_id:ID, title:"Priority", column_type:status, defaults:"{\"labels\":{\"0\":\"High\",\"1\":\"Med\",\"2\":\"Low\"}}") { id } }`

**Create item:** `mutation { create_item(board_id:ID, group_id:"group", item_name:"Task", column_values:"{\"status\":{\"label\":\"Working on it\"},\"date\":{\"date\":\"2026-03-15\"}}", create_labels_if_missing:true) { id } }`

**Create subitem:** `mutation { create_subitem(parent_item_id:ID, item_name:"Sub", column_values:"{...}") { id } }`

**Update columns:** `mutation { change_multiple_column_values(board_id:ID, item_id:ID, column_values:"{\"status\":{\"label\":\"Done\"}}", create_labels_if_missing:true) { id } }`

**Move/archive/delete:**
- `mutation { move_item_to_group(item_id:ID, group_id:"grp") { id } }`
- `mutation { archive_item(item_id:ID) { id } }`
- `mutation { delete_item(item_id:ID) { id } }`

**Create group:** `mutation { create_group(board_id:ID, group_name:"Sprint 3", group_color:"#00c875") { id } }`

**Create update:** `mutation { create_update(item_id:ID, body:"<p>Comment here</p>") { id } }`

**Create workspace:** `mutation { create_workspace(name:"WS", kind:open) { id } }`

**Webhook:** `mutation { create_webhook(board_id:ID, url:"https://...", event:change_column_value, config:"{\"columnId\":\"status\"}") { id } }`

## Column Value Formats

`column_values` must be a **JSON string** (escaped). Key formats:

| Type | Format |
|---|---|
| status | `{"label":"Done"}` |
| text | `"value"` |
| numbers | `42` |
| date | `{"date":"2026-03-15"}` or `{"date":"2026-03-15","time":"09:00:00"}` |
| email | `{"email":"a@b.com","text":"Name"}` |
| phone | `{"phone":"+1234","countryShortName":"US"}` |
| link | `{"url":"https://...","text":"Label"}` |
| people | `{"personsAndTeams":[{"id":123,"kind":"person"}]}` |
| dropdown | `{"labels":["Opt A","Opt B"]}` |
| checkbox | `{"checked":"true"}` |
| timeline | `{"from":"2026-01-01","to":"2026-03-31"}` |
| long_text | `{"text":"content"}` |
| connect_boards | `{"item_ids":[123,456]}` |
| rating | `{"rating":4}` |
| country | `{"countryCode":"US","countryName":"United States"}` |
| location | `{"lat":40.71,"lng":-74.00,"address":"NYC"}` |
| tags | `{"tag_ids":[1,2]}` |

**Read-only (cannot set):** mirror, formula, auto_number, creation_log, last_updated, item_id, time_tracking

## Critical Rules

1. **Always query board schema first** to get column IDs — they're auto-generated (`status4`, `date_1`, `text_mkrc`)
2. **column_values is a JSON string**, not object — double-escape in curl
3. **Status uses `label` not `index`** for human-readable values
4. **Paginate always** — use `limit` (25-50) + `cursor`, never fetch all
5. **Rate limit:** 5M complexity/min. Add 500ms delay between mutations in loops
6. **HTTP 200 on errors** — always check for `errors`/`error_code` in response body
7. **Mirror columns** — read-only, configured via UI only
8. **Formula columns** — cannot set via API, Monday-specific syntax configured in UI

## References

For detailed patterns beyond the above, read these files:
- `references/column-types.md` — Edge cases, clearing values, file uploads, escaping
- `references/patterns.md` — CRM architecture, board templates, dashboard widgets, automations
