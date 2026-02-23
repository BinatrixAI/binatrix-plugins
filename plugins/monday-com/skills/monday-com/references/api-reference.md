# Monday.com GraphQL API Reference

Complete reference for queries, mutations, and advanced operations. API endpoint: `https://api.monday.com/v2`

## Table of Contents
- [Authentication](#authentication)
- [Boards](#boards)
- [Items](#items)
- [Columns](#columns)
- [Groups](#groups)
- [Users & Teams](#users--teams)
- [Workspaces](#workspaces)
- [Updates (Comments)](#updates-comments)
- [Files](#files)
- [Webhooks](#webhooks)
- [Documents (Monday Docs)](#documents-monday-docs)
- [Tags](#tags)
- [Complexity & Rate Limits](#complexity--rate-limits)
- [Error Codes](#error-codes)

---

## Authentication

### Bearer Token
```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_TOKEN" \
  -H "API-Version: 2024-10" \
  -d '{"query": "{ me { id name email } }"}'
```

### Token Types
- **Personal API Token:** Found in Profile → Admin → API. Full account access.
- **OAuth Token:** For apps/integrations. Scoped permissions.
- **Scopes:** `boards:read`, `boards:write`, `workspaces:read`, `workspaces:write`, `users:read`, `users:write`, `account:read`, `updates:read`, `updates:write`, `webhooks:write`, `tags:read`

---

## Boards

### Query boards
```graphql
# By workspace
query { boards(workspace_ids: [WS_ID], limit: 50) {
  id name board_kind state description
  permissions columns { id title type } groups { id title }
}}

# By IDs
query { boards(ids: [ID1, ID2]) { id name columns { id title type settings_str } }}

# Search by name
query { boards(limit: 10) { id name } }
```
Note: There is no native name-search filter. Query all and filter client-side, or use the `items_page_by_column_values` approach on a known board.

### Create board
```graphql
mutation {
  create_board(
    board_name: "New Board"
    board_kind: public      # public | private | share
    workspace_id: WS_ID     # optional, defaults to main workspace
    template_id: TEMPLATE_ID # optional, clone from template
  ) { id }
}
```

### Update board
```graphql
mutation {
  update_board(board_id: BOARD_ID, board_attribute: name, new_value: "Renamed Board") { }
}
```
Attributes: `name`, `description`, `communication`

### Delete/archive board
```graphql
mutation { archive_board(board_id: BOARD_ID) { id } }
mutation { delete_board(board_id: BOARD_ID) { id } }
```

### Duplicate board
```graphql
mutation {
  duplicate_board(
    board_id: BOARD_ID
    duplicate_type: duplicate_board_with_structure  # or duplicate_board_with_structure_and_items
    board_name: "Copy of Board"
    workspace_id: TARGET_WS_ID
  ) { board { id } }
}
```

---

## Items

### Query items (paginated)
```graphql
query {
  boards(ids: [BOARD_ID]) {
    items_page(limit: 50, query_params: {
      rules: [{ column_id: "status", compare_value: ["Done"], operator: any_of }]
      operator: and
    }) {
      cursor
      items {
        id name created_at updated_at
        group { id title }
        column_values { id type text value
          ... on StatusValue { label index }
          ... on DateValue { date time }
          ... on NumbersValue { number }
          ... on PeopleValue { persons_and_teams { id kind } }
          ... on CheckboxValue { checked }
          ... on EmailValue { email label }
          ... on PhoneValue { phone country_short_name }
          ... on LinkValue { url url_text }
          ... on TimelineValue { from to }
          ... on DropdownValue { values { id name } }
          ... on BoardRelationValue { linked_item_ids }
          ... on LongTextValue { text }
        }
        subitems { id name column_values { id text value } }
      }
    }
  }
}
```

### Query params operators
- `any_of` — matches any value in array
- `not_any_of` — excludes values
- `is_empty` — column is blank
- `is_not_empty` — column has value
- `greater_than` / `lower_than` — numeric/date comparison
- `between` — range (dates/numbers)
- `contains_text` / `not_contains_text` — text search
- `starts_with` / `ends_with` — text matching
- `within_the_next` / `within_the_last` — relative date (e.g., `{"value": 7, "unit": "days"}`)

### Create item
```graphql
mutation {
  create_item(
    board_id: BOARD_ID
    group_id: "topics"           # optional, defaults to top group
    item_name: "New item"
    column_values: "{...}"       # JSON string
    create_labels_if_missing: true  # auto-create dropdown/status labels
  ) { id name }
}
```

### Create subitem
```graphql
mutation {
  create_subitem(
    parent_item_id: PARENT_ITEM_ID
    item_name: "Sub-task"
    column_values: "{...}"
    create_labels_if_missing: true
  ) { id }
}
```

### Update item
```graphql
mutation {
  change_multiple_column_values(
    board_id: BOARD_ID
    item_id: ITEM_ID
    column_values: "{...}"
    create_labels_if_missing: true
  ) { id }
}
```

### Move item
```graphql
mutation { move_item_to_group(item_id: ITEM_ID, group_id: "new_group") { id } }
mutation { move_item_to_board(item_id: ITEM_ID, board_id: NEW_BOARD_ID) { id } }
```

### Delete / archive
```graphql
mutation { delete_item(item_id: ITEM_ID) { id } }
mutation { archive_item(item_id: ITEM_ID) { id } }
```

### Duplicate item
```graphql
mutation {
  duplicate_item(
    board_id: BOARD_ID
    item_id: ITEM_ID
    with_updates: true  # copy comments too
  ) { id }
}
```

---

## Columns

### Create column
```graphql
mutation {
  create_column(
    board_id: BOARD_ID
    title: "Priority"
    column_type: status
    defaults: "{\"labels\":{\"0\":\"High\",\"1\":\"Medium\",\"2\":\"Low\"},\"labels_colors\":{\"0\":{\"color\":\"#df2f4a\"},\"1\":{\"color\":\"#fdab3d\"},\"2\":{\"color\":\"#579bfc\"}}}"
    description: "Task priority level"
  ) { id title }
}
```

### Column types enum
`auto_number`, `board_relation`, `button`, `checkbox`, `color_picker`, `country`, `creation_log`, `date`, `dependency`, `doc`, `dropdown`, `email`, `file`, `formula`, `group`, `hour`, `item_id`, `last_updated`, `link`, `location`, `long_text`, `mirror`, `name`, `numbers`, `people`, `phone`, `progress`, `rating`, `status`, `subtasks`, `tags`, `team`, `text`, `time_tracking`, `timeline`, `vote`, `week`, `world_clock`

### Change column metadata
```graphql
mutation {
  change_column_metadata(
    board_id: BOARD_ID
    column_id: "status4"
    column_property: title
    value: "New Title"
  ) { id }
}
```
Properties: `title`, `description`

### Delete column
```graphql
mutation { delete_column(board_id: BOARD_ID, column_id: "column_id") { id } }
```

### Change column value (single)
```graphql
mutation {
  change_simple_column_value(
    board_id: BOARD_ID
    item_id: ITEM_ID
    column_id: "status"
    value: "Done"
  ) { id }
}
```

---

## Groups

### Query groups
```graphql
query { boards(ids: [BOARD_ID]) { groups { id title color position archived deleted } } }
```

### Create group
```graphql
mutation {
  create_group(
    board_id: BOARD_ID
    group_name: "New Group"
    group_color: "#00c875"
    position_relative_method: before_at  # or after_at
    relative_to: "existing_group_id"
  ) { id }
}
```

### Update group
```graphql
mutation {
  update_group(board_id: BOARD_ID, group_id: "GROUP_ID", group_attribute: title, new_value: "Renamed") { id }
}
```
Attributes: `title`, `color`, `position`, `relative_position_after`, `relative_position_before`

### Archive / delete group
```graphql
mutation { archive_group(board_id: BOARD_ID, group_id: "GROUP_ID") { id } }
mutation { delete_group(board_id: BOARD_ID, group_id: "GROUP_ID") { id } }
```

---

## Users & Teams

### Query current user
```graphql
query { me { id name email account { id name } teams { id name } } }
```

### Query users
```graphql
query {
  users(limit: 50) {
    id name email phone title location
    birthday created_at
    is_admin is_guest is_verified enabled
    teams { id name }
    account { id name }
  }
}
```

### Query teams
```graphql
query { teams { id name users { id name } } }
```

---

## Workspaces

### Query
```graphql
query { workspaces(limit: 25) { id name kind description account_product { id } } }
```

### Create
```graphql
mutation { create_workspace(name: "New WS", kind: open, description: "Desc") { id } }
```
Kinds: `open` (anyone can join), `closed` (invite-only)

### Update
```graphql
mutation { update_workspace(id: WS_ID, attributes: { name: "New Name", description: "Updated" }) { id } }
```

### Delete
```graphql
mutation { delete_workspace(workspace_id: WS_ID) { id } }
```

---

## Updates (Comments)

### Query updates on item
```graphql
query {
  items(ids: [ITEM_ID]) {
    updates(limit: 25) {
      id body text_body created_at updated_at
      creator { id name email }
      replies { id body creator { id name } created_at }
      assets { id name url public_url }
    }
  }
}
```

### Create update
```graphql
mutation {
  create_update(
    item_id: ITEM_ID
    body: "<p>This is a <strong>comment</strong> with HTML support.</p>"
  ) { id }
}
```
Body supports HTML: `<p>`, `<strong>`, `<em>`, `<a>`, `<br>`, `<ul>`, `<li>`, `<ol>`, `<h1>`-`<h6>`, `<blockquote>`, `<code>`

### Reply to update
```graphql
mutation {
  create_update(
    item_id: ITEM_ID
    parent_id: UPDATE_ID
    body: "This is a reply"
  ) { id }
}
```

### Delete update
```graphql
mutation { delete_update(id: UPDATE_ID) { id } }
```

---

## Files

### Upload file to column
Requires multipart form POST:
```bash
curl -s -X POST https://api.monday.com/v2/file \
  -H "Authorization: $MONDAY_API_TOKEN" \
  -F 'query=mutation ($file: File!) { add_file_to_column(item_id: ITEM_ID, column_id: "files", file: $file) { id } }' \
  -F 'map={"image":"variables.file"}' \
  -F 'image=@/path/to/file.pdf'
```

### Upload file to update
```bash
curl -s -X POST https://api.monday.com/v2/file \
  -H "Authorization: $MONDAY_API_TOKEN" \
  -F 'query=mutation ($file: File!) { add_file_to_update(update_id: UPDATE_ID, file: $file) { id } }' \
  -F 'map={"image":"variables.file"}' \
  -F 'image=@/path/to/file.png'
```

### Query file assets
```graphql
query {
  items(ids: [ITEM_ID]) {
    assets { id name url public_url file_size file_extension created_at }
  }
}
```

---

## Webhooks

### Create webhook
```graphql
mutation {
  create_webhook(
    board_id: BOARD_ID
    url: "https://your-endpoint.com/webhook"
    event: change_column_value
    config: "{\"columnId\":\"status\"}"
  ) { id }
}
```

### Events
- `change_column_value` — Any column changes
- `change_status_column_value` — Status column specifically
- `change_subitem_column_value` — Subitem column change
- `create_item` — New item created
- `create_subitem` — New subitem created
- `create_update` — New comment/update
- `edit_update` — Comment edited
- `delete_item` — Item deleted

### Delete webhook
```graphql
mutation { delete_webhook(id: WEBHOOK_ID) { id } }
```

---

## Documents (Monday Docs)

### Create document
```graphql
mutation {
  create_doc(
    location: { workspace: { workspace_id: WS_ID, name: "My Doc", kind: public } }
  ) { id }
}
```

### Create doc block
```graphql
mutation {
  create_doc_block(
    doc_id: DOC_ID
    type: normal_text
    content: "{\"deltaFormat\":[{\"insert\":\"Hello World\"}]}"
  ) { id }
}
```

Block types: `normal_text`, `large_title`, `medium_title`, `small_title`, `bulleted_list`, `numbered_list`, `check_list`, `code`, `quote`, `divider`, `image`, `video`, `table`

---

## Tags

### Query tags
```graphql
query { tags { id name color } }
```

### Create/assign tags
Tags must be created first (via UI or API), then assigned to items via the tags column:
```graphql
mutation {
  change_simple_column_value(
    board_id: BOARD_ID
    item_id: ITEM_ID
    column_id: "tags"
    value: "{\"tag_ids\":[TAG_ID_1, TAG_ID_2]}"
  ) { id }
}
```

---

## Complexity & Rate Limits

### Complexity System
- **Budget:** 5,000,000 points per minute
- Each field/object in a query has a complexity cost
- Nested objects (items → column_values → ...) increase cost multiplicatively
- Use `complexity` field to check query cost:
```graphql
query { complexity { query before after } boards(ids: [ID]) { name } }
```

### Best Practices
1. **Paginate:** Always use `limit` (25-50 recommended) and `cursor`
2. **Select fields:** Only request columns you need
3. **Avoid nesting:** Don't nest items → subitems → column_values deep in one query
4. **Batch reads:** Read multiple boards in one query when possible
5. **Throttle writes:** 500ms delay between mutations
6. **Cache schemas:** Query board columns once, reuse for subsequent operations

### Rate Limit Headers
Response headers include:
- `X-Complexity-Cost` — Cost of this query
- `X-Complexity-Budget` — Remaining budget
- `X-Complexity-After` — Budget after this query

---

## Error Codes

| Code | Meaning | Solution |
|---|---|---|
| `InvalidColumnIdException` | Column ID doesn't exist on board | Query board columns first |
| `ColumnValueException` | Malformed column value | Check format in column-types.md |
| `InvalidUserIdException` | User ID not found | Query users first |
| `InvalidBoardIdException` | Board not found | Verify board ID |
| `ResourceNotFoundException` | Item/board/group not found | Check if archived/deleted |
| `ItemsLimitationException` | Too many items on board | Archive old items |
| `CreateBoardException` | Board creation failed | Check workspace permissions |
| `CorrectedValueException` | Value was auto-corrected | Review returned value |
| `ComplexityException` | Query too expensive | Reduce fields, add pagination |
| `UserUnauthorizedException` | Insufficient permissions | Check token scopes |
| `IPRestrictedException` | IP not allowed | Check account IP restrictions |

### Error Response Format
```json
{
  "error_code": "ColumnValueException",
  "status_code": 200,
  "error_message": "invalid value, please check our API documentation for more information",
  "error_data": { "column_id": "status4", "column_type": "color" }
}
```

Note: Monday.com returns HTTP 200 even for errors — always check for `errors` or `error_code` in the response body.
