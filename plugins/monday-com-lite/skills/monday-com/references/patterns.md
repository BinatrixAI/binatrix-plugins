# Patterns — CRM, Templates, Dashboards, Automations

## CRM 4-Board Architecture

```
Leads (🎯) ──connect──→ Deals (💰) ──connect──→ Accounts (🏢)
                                    ──connect──→ Contacts (👥)
Contacts ──connect──→ Accounts
```

### Leads Board
Columns: Status(New/Contacted/Qualified/Converted/Lost), Source(dropdown: Website/Referral/LinkedIn/Cold Call), Email, Phone, Owner(people), Company(text), Est.Value(numbers), Next Follow-up(date), Notes(long_text), Deal Link(connect→Deals)

### Deals Board
Columns: Stage(Discovery/Proposal/Negotiation/Won/Lost), Amount(numbers), Close Date(date), Probability(numbers), Account(connect→Accounts), Contact(connect→Contacts), Lead(connect→Leads), Owner(people), Priority(status), Timeline(timeline)

### Contacts Board
Columns: Email, Phone, Company(connect→Accounts), Title(text), Last Contact(date), Type(dropdown: Customer/Prospect/Partner), Notes(long_text)

### Accounts Board
Columns: Industry(dropdown), Size(dropdown: 1-10/11-50/51-200/201-500/500+), Website(link), Revenue(numbers), Manager(people), Status(Active/Churned/Prospect), Contacts(connect→Contacts), Deals(connect→Deals)

## Pipeline Groups
```graphql
create_group(board_id:ID, group_name:"🆕 New", group_color:"#579bfc")
create_group(board_id:ID, group_name:"📞 Contacted", group_color:"#fdab3d")
create_group(board_id:ID, group_name:"⭐ Qualified", group_color:"#ffcb00")
create_group(board_id:ID, group_name:"🤝 Negotiation", group_color:"#ff642e")
create_group(board_id:ID, group_name:"✅ Won", group_color:"#00c875")
create_group(board_id:ID, group_name:"❌ Lost", group_color:"#df2f4a")
```

## Project Board Template
Columns: Status(Not Started/In Progress/Review/Done/Blocked), Priority(Critical/High/Medium/Low), Assignee(people), Due Date(date), Timeline(timeline), Est.Hours(numbers), Sprint(dropdown), Dependencies(dependency), Files(file), Description(long_text)

Groups: 📋 Backlog → 🏃 Current Sprint → ✅ Completed

## Invoice Board Template
Columns: Invoice#(auto_number), Client(connect→Accounts), Amount(numbers), Currency(dropdown), Issue Date(date), Due Date(date), Status(Draft/Sent/Paid/Overdue/Cancelled), Payment Date(date), VAT(formula: `{Amount}*0.17`), Total(formula: `{Amount}*1.17`)

## Dashboard Widgets
- **Numbers:** SUM/COUNT/AVG of column, filtered by status. E.g. total deal value where Stage=Won
- **Chart (pie):** Status distribution across items
- **Chart (bar):** Values grouped by owner/month/category
- **Battery:** Completion % (Done vs total)
- **Table:** Filtered item list (overdue, my tasks, high priority)
- **Gantt:** Timeline visualization from timeline columns

## Automation Patterns (UI only)
1. Lead rotation: new item → assign next person
2. Follow-up reminder: date arrives → notify owner
3. Status notification: stage changes to Won → notify channel
4. Auto-move: status changes → move to group
5. Recurring: every Monday → create standup item
6. Dependency: item Done → notify dependent owners

## Webhooks (API)
Events: `change_column_value`, `change_status_column_value`, `create_item`, `create_subitem`, `create_update`, `edit_update`, `delete_item`
```graphql
create_webhook(board_id:ID, url:"https://...", event:change_column_value, config:"{\"columnId\":\"status\"}")
```

## Workspace Structure
```
Workspace: [Client]
├── 📁 CRM (Leads, Deals, Contacts, Accounts)
├── 📁 Operations (Projects, Tasks)
├── 📁 Finance (Invoices, Expenses)
└── 📊 Dashboards (CEO Overview, Pipeline, Financial)
```

## Multi-Board Patterns
- **Hub & Spoke:** Accounts(hub) → Contacts, Deals, Invoices, Activities
- **Linear Pipeline:** Leads → Deals → Projects → Invoices (each transition creates+connects)
- **Mirror columns:** Display connected board data without duplication. UI-only config. Read-only.

## Board Naming
Use emoji prefix + Hebrew (for RTL clients): `🎯 לידים - Leads`

## Column Types Enum
`auto_number, board_relation, button, checkbox, color_picker, country, creation_log, date, dependency, doc, dropdown, email, file, formula, hour, item_id, last_updated, link, location, long_text, mirror, name, numbers, people, phone, progress, rating, status, subtasks, tags, team, text, time_tracking, timeline, vote, week, world_clock`

## Error Codes
`InvalidColumnIdException` (wrong ID) | `ColumnValueException` (bad format) | `InvalidUserIdException` (no user) | `ResourceNotFoundException` (deleted/archived) | `ComplexityException` (reduce query) | `UserUnauthorizedException` (bad scope) | `ItemsLimitationException` (archive old items)

Response always HTTP 200 — check `errors`/`error_code` in body.

## Complexity
Budget: 5M/min. Check: `{ complexity { query before after } }`. Nested items×columns costs multiply. Paginate, select only needed fields.
