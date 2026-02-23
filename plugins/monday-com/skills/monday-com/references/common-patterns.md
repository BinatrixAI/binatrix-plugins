# Monday.com Common Patterns & Templates

Reusable board architectures, CRM setups, dashboard configurations, and automation recipes.

## Table of Contents
- [CRM Architecture](#crm-architecture)
- [Project Management Board](#project-management-board)
- [Dashboard Widgets](#dashboard-widgets)
- [Automation Recipes](#automation-recipes)
- [Board Templates](#board-templates)
- [Multi-Board Relationships](#multi-board-relationships)

---

## CRM Architecture

### Standard Sales CRM (4-Board Setup)

**Board 1: Leads (🎯 לידים)**
| Column | Type | Purpose |
|---|---|---|
| Lead Name | name | Contact/company name |
| Status | status | New / Contacted / Qualified / Converted / Lost |
| Source | dropdown | Website / Referral / LinkedIn / Cold Call / Event |
| Contact Email | email | Primary email |
| Contact Phone | phone | Primary phone |
| Owner | people | Assigned sales rep |
| Company | text | Company name |
| Est. Value | numbers | Estimated deal value |
| Next Follow-up | date | Scheduled follow-up |
| Notes | long_text | Conversation notes |
| Deal Link | connect_boards | → Deals board |

**Board 2: Deals (💰 עסקאות)**
| Column | Type | Purpose |
|---|---|---|
| Deal Name | name | Deal/opportunity name |
| Stage | status | Discovery / Proposal / Negotiation / Closed Won / Closed Lost |
| Amount | numbers | Deal value |
| Close Date | date | Expected close |
| Probability | numbers | Win probability % |
| Account | connect_boards | → Accounts board |
| Contact | connect_boards | → Contacts board |
| Lead Source | connect_boards | → Leads board |
| Owner | people | Deal owner |
| Priority | status | High / Medium / Low |
| Timeline | timeline | Deal duration |

**Board 3: Contacts (👥 אנשי קשר)**
| Column | Type | Purpose |
|---|---|---|
| Name | name | Full name |
| Email | email | Email address |
| Phone | phone | Phone number |
| Company | connect_boards | → Accounts board |
| Title | text | Job title |
| Last Contact | date | Last interaction date |
| Type | dropdown | Customer / Prospect / Partner / Vendor |
| Notes | long_text | Contact notes |

**Board 4: Accounts (🏢 חשבונות)**
| Column | Type | Purpose |
|---|---|---|
| Company | name | Company name |
| Industry | dropdown | Industry vertical |
| Size | dropdown | 1-10 / 11-50 / 51-200 / 201-500 / 500+ |
| Website | link | Company website |
| Annual Revenue | numbers | Revenue |
| Account Manager | people | Assigned manager |
| Status | status | Active / Churned / Prospect |
| Contacts | connect_boards | → Contacts board |
| Deals | connect_boards | → Deals board |

### Connected Board Setup

To create a connect_boards column linking Board A → Board B:
```graphql
mutation {
  create_column(
    board_id: BOARD_A_ID
    title: "Related Deals"
    column_type: board_relation
    defaults: "{\"boardIds\":[BOARD_B_ID]}"
  ) { id }
}
```

Then create the mirror columns via UI to display data from connected items.

### CRM Groups (Pipeline Stages)

Use groups as pipeline stages for visual Kanban:
```graphql
mutation { create_group(board_id: BOARD_ID, group_name: "🆕 New Leads", group_color: "#579bfc") { id } }
mutation { create_group(board_id: BOARD_ID, group_name: "📞 Contacted", group_color: "#fdab3d") { id } }
mutation { create_group(board_id: BOARD_ID, group_name: "⭐ Qualified", group_color: "#ffcb00") { id } }
mutation { create_group(board_id: BOARD_ID, group_name: "🤝 Negotiation", group_color: "#ff642e") { id } }
mutation { create_group(board_id: BOARD_ID, group_name: "✅ Won", group_color: "#00c875") { id } }
mutation { create_group(board_id: BOARD_ID, group_name: "❌ Lost", group_color: "#df2f4a") { id } }
```

---

## Project Management Board

### Task Board Template
| Column | Type | Purpose |
|---|---|---|
| Task | name | Task name |
| Status | status | Not Started / In Progress / Review / Done / Blocked |
| Priority | status | Critical / High / Medium / Low |
| Assignee | people | Responsible person(s) |
| Due Date | date | Deadline |
| Timeline | timeline | Start-to-end date range |
| Est. Hours | numbers | Estimated effort |
| Actual Hours | numbers | Time spent |
| Sprint | dropdown | Sprint 1 / Sprint 2 / Sprint 3 |
| Dependencies | dependency | Blocked by items |
| Files | file | Attachments |
| Description | long_text | Task details |

### Sprint Groups
```graphql
mutation { create_group(board_id: BOARD_ID, group_name: "📋 Backlog") { id } }
mutation { create_group(board_id: BOARD_ID, group_name: "🏃 Current Sprint") { id } }
mutation { create_group(board_id: BOARD_ID, group_name: "✅ Completed") { id } }
```

---

## Dashboard Widgets

Dashboards are created separately and link to source boards. Common widget patterns:

### Numbers Widget
Shows a single aggregate number (count, sum, average).
- Total deal value: SUM of Amount column, filtered by Stage = "Closed Won"
- Open leads count: COUNT of items where Status ≠ "Closed"
- Average deal size: AVERAGE of Amount column

### Chart Widget
- **Pie chart:** Status distribution (how many items per status)
- **Bar chart:** Deal value by owner / by month
- **Line chart:** New leads over time

### Battery Widget
Shows completion percentage. Useful for:
- Sprint progress (Done vs total)
- Pipeline health (stages distribution)

### Table Widget
Displays filtered items from one or more boards. Useful for:
- Overdue items (Date < today, Status ≠ Done)
- My tasks (Assignee = current user)
- High-priority items

### Gantt Widget
Visual timeline from timeline columns. Best for project scheduling.

---

## Automation Recipes

Monday.com automations follow a trigger → condition → action pattern. These must be configured via the UI, but understanding them helps plan board architecture.

### Common CRM Automations
1. **Lead assignment rotation:** When a new lead is created → assign to the next person in rotation
2. **Follow-up reminder:** When date arrives on "Next Follow-up" → notify the owner
3. **Status change notification:** When Stage changes to "Closed Won" → notify channel, update dashboard
4. **Auto-move:** When Status changes to "Converted" → create item in Deals board, connect to lead
5. **Overdue alert:** Every day at 9am → find items with overdue dates → notify owners

### Common Project Automations
1. **Dependency alerts:** When item status changes to "Done" → notify dependent item owners
2. **Sprint cleanup:** When status changes to "Done" → move to "Completed" group
3. **New item defaults:** When item created → set Status to "Not Started", set Date to today
4. **Recurring tasks:** Every Monday at 9am → create item "Weekly Standup" in Sprint group

### Automation via API (Webhooks)
While you can't create automations via API, you can set up webhooks:
```graphql
mutation {
  create_webhook(
    board_id: BOARD_ID
    url: "https://your-server.com/webhook"
    event: change_column_value
    config: "{\"columnId\":\"status\"}"
  ) { id }
}
```
Events: `change_column_value`, `change_status_column_value`, `create_item`, `create_update`, `delete_item`, `edit_update`

---

## Board Templates

### Invoice Tracking Board
| Column | Type | Notes |
|---|---|---|
| Invoice # | auto_number | Sequential |
| Client | connect_boards | → Accounts |
| Amount | numbers | Invoice total |
| Currency | dropdown | USD / EUR / ILS |
| Issue Date | date | When sent |
| Due Date | date | Payment due |
| Status | status | Draft / Sent / Paid / Overdue / Cancelled |
| Payment Date | date | When received |
| VAT | formula | `{Amount} * 0.17` |
| Total with VAT | formula | `{Amount} * 1.17` |

### Meeting/Activity Log
| Column | Type | Notes |
|---|---|---|
| Activity | name | Meeting subject |
| Type | status | Call / Meeting / Email / Demo |
| Date | date | When it happened |
| Contact | connect_boards | → Contacts |
| Deal | connect_boards | → Deals |
| Attendees | people | Who was there |
| Duration | numbers | Minutes |
| Outcome | long_text | Notes and outcomes |
| Follow-up | date | Next action date |

---

## Multi-Board Relationships

### Architecture Pattern: Hub and Spoke
Central board (Accounts) connects to multiple satellite boards:
```
Accounts (hub)
  ├── → Contacts (1:many)
  ├── → Deals (1:many)
  ├── → Invoices (1:many)
  └── → Activities (1:many)
```

### Architecture Pattern: Linear Pipeline
Items flow through boards representing stages:
```
Leads → Deals → Projects → Invoices
```
Each transition creates a new item in the next board and links back.

### Mirror Column Best Practices
- Mirror columns display data from connected boards without duplication
- **Must be configured via UI** — the API cannot set mirror column sources
- Use mirrors to show: Account name on Deals, Deal value on Contacts, etc.
- Keep mirrors read-only (they are by nature)
- Limit mirror columns per board — each adds to query complexity

### Formula Column Patterns

Common formulas (configured via UI only):
```
// Weighted pipeline value
{Amount} * {Probability} / 100

// Days until due
DAYS({Due Date}, TODAY())

// Status-based calculation
IF({Status}="Closed Won", {Amount}, 0)

// Concatenation
CONCATENATE({First Name}, " ", {Last Name})

// Conditional formatting helper
IF({Days Overdue} > 0, "⚠️ OVERDUE", "✅ On Track")
```

---

## Workspace Organization

### Recommended Structure
```
Workspace: [Client Name]
├── 📁 CRM
│   ├── 🎯 Leads
│   ├── 💰 Deals
│   ├── 👥 Contacts
│   └── 🏢 Accounts
├── 📁 Operations
│   ├── 📋 Projects
│   ├── ✅ Tasks
│   └── 📅 Calendar
├── 📁 Finance
│   ├── 🧾 Invoices
│   └── 💳 Expenses
└── 📊 Dashboards
    ├── CEO Overview
    ├── Sales Pipeline
    └── Financial Summary
```

### Board Naming Conventions
- Use emojis for visual identification
- Include Hebrew names for RTL clients: `🎯 לידים - Leads`
- Keep names short but descriptive
- Use consistent patterns across workspaces
