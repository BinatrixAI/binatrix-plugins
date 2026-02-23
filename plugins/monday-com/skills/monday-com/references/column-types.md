# Monday.com Column Types Reference

Complete formatting guide for every column type in the Monday.com API. Use this when constructing `column_values` for `create_item` or `change_multiple_column_values` mutations.

## Table of Contents
- [Text-based Columns](#text-based-columns)
- [Numeric Columns](#numeric-columns)
- [Date & Time Columns](#date--time-columns)
- [Status & Selection Columns](#status--selection-columns)
- [People & Team Columns](#people--team-columns)
- [Contact Columns](#contact-columns)
- [Relationship Columns](#relationship-columns)
- [File & Link Columns](#file--link-columns)
- [Location & Country Columns](#location--country-columns)
- [Other Columns](#other-columns)
- [Read-Only Columns](#read-only-columns)

---

## Text-based Columns

### text
Simple text value.
```json
{"text_column_id": "Hello world"}
```

### long_text
Rich text content. Supports basic HTML.
```json
{"long_text_column_id": {"text": "This is a long description with\nnewlines supported"}}
```

### name (item name)
Set via `item_name` parameter in mutations, not via `column_values`.

---

## Numeric Columns

### numbers
Numeric value as number or string.
```json
{"numbers_column_id": 42}
{"numbers_column_id": "42.5"}
```

### rating
Integer from 1 to the configured max (default 5).
```json
{"rating_column_id": {"rating": 4}}
```

---

## Date & Time Columns

### date
Date with optional time.
```json
{"date_column_id": {"date": "2026-03-15"}}
{"date_column_id": {"date": "2026-03-15", "time": "14:30:00"}}
```
To clear: `{"date_column_id": null}` or `{"date_column_id": {}}`

### timeline
Date range with from/to.
```json
{"timeline_column_id": {"from": "2026-01-01", "to": "2026-03-31"}}
```

### week
Week selection.
```json
{"week_column_id": {"week": {"startDate": "2026-01-06", "endDate": "2026-01-12"}}}
```

### hour
Time of day.
```json
{"hour_column_id": {"hour": 14, "minute": 30}}
```

### time_tracking
Cannot be set via API directly. Read-only tracking data.

---

## Status & Selection Columns

### status
Must use the label text (not index) for simple values.
```json
{"status_column_id": {"label": "Done"}}
```
Can also set by index:
```json
{"status_column_id": {"index": 1}}
```

**Finding available labels:** Query the board's columns and parse `settings_str`:
```json
{
  "labels": {
    "0": "Working on it",
    "1": "Done",
    "2": "Stuck"
  },
  "labels_colors": {
    "0": {"color": "#fdab3d", "border": "#e99729", "var_name": "orange"},
    "1": {"color": "#00c875", "border": "#00b461", "var_name": "green-shadow"},
    "2": {"color": "#df2f4a", "border": "#ce3048", "var_name": "red-shadow"}
  }
}
```

### dropdown
Use label names (not IDs) for setting values.
```json
{"dropdown_column_id": {"labels": ["Option A", "Option B"]}}
```
To set by IDs:
```json
{"dropdown_column_id": {"ids": [1, 3]}}
```

### color_picker
```json
{"color_column_id": {"color": "#FF5AC4"}}
```

### checkbox
```json
{"checkbox_column_id": {"checked": "true"}}
```
To uncheck: `{"checked": "false"}`

### tags
Must use existing tag IDs from the account.
```json
{"tags_column_id": {"tag_ids": [123, 456]}}
```

---

## People & Team Columns

### people
Array of person and/or team IDs.
```json
{"people_column_id": {"personsAndTeams": [{"id": 12345, "kind": "person"}]}}
```
Multiple people:
```json
{"people_column_id": {"personsAndTeams": [
  {"id": 12345, "kind": "person"},
  {"id": 67890, "kind": "person"}
]}}
```
Teams:
```json
{"people_column_id": {"personsAndTeams": [{"id": 111, "kind": "team"}]}}
```

**Getting user IDs:** Query users first:
```graphql
query { users { id name email } }
```

---

## Contact Columns

### email
```json
{"email_column_id": {"email": "john@example.com", "text": "John Doe"}}
```
The `text` is the display label.

### phone
```json
{"phone_column_id": {"phone": "+14155551234", "countryShortName": "US"}}
```

---

## Relationship Columns

### connect_boards (Board Relation)
Link items from connected boards.
```json
{"connect_column_id": {"item_ids": [123456, 789012]}}
```
To clear: `{"connect_column_id": {"item_ids": []}}`

**Important:** The connected board must be configured in the column settings first (via UI or `create_column` with appropriate settings).

### dependency
Same format as connect_boards — links items within the same board.
```json
{"dependency_column_id": {"item_ids": [ITEM_ID_1, ITEM_ID_2]}}
```

### mirror
**Cannot be written via API.** Mirror columns reflect data from connected boards. They are read-only and configured through the UI. When queried, they return the mirrored value from the source board.

---

## File & Link Columns

### link
```json
{"link_column_id": {"url": "https://example.com", "text": "Example Site"}}
```

### file
Files cannot be uploaded via simple column_values. Use the `add_file_to_column` mutation:
```graphql
mutation ($file: File!) {
  add_file_to_column(
    item_id: ITEM_ID
    column_id: "files"
    file: $file
  ) { id }
}
```
This requires a multipart form upload.

---

## Location & Country Columns

### location
```json
{"location_column_id": {"lat": 40.7128, "lng": -74.0060, "address": "New York, NY"}}
```

### country
```json
{"country_column_id": {"countryCode": "US", "countryName": "United States"}}
```

### world_clock
```json
{"world_clock_column_id": {"timezone": "America/New_York"}}
```

---

## Other Columns

### auto_number
Read-only. Automatically assigned sequential number.

### formula
**Cannot be set via API.** Computed from other columns. Read-only.
Formula syntax uses Monday.com-specific functions:
- `IF({Status}="Done", "Complete", "Pending")`
- `{Numbers Column} * 1.17` (VAT calculation)
- `DAYS({Date}, TODAY())`
- `CONCATENATE({Text1}, " - ", {Text2})`
- `ROUND({Numbers} * 100, 2)`

### creation_log / last_updated
Read-only. Automatically tracked.

### item_id
Read-only. The item's unique identifier.

### vote
```json
{"vote_column_id": {"votersIds": [12345, 67890]}}
```

---

## Read-Only Columns

These columns cannot be set via the API:
- `auto_number` — Sequential numbering
- `creation_log` — Created date/user
- `last_updated` — Last modified date/user
- `formula` — Calculated values
- `mirror` — Reflected values from connected boards
- `item_id` — System identifier
- `time_tracking` — Time tracking data (can only be started/stopped via specific mutations)
- `button` — Trigger automations only

---

## Column Value Escaping

The `column_values` parameter expects a **JSON string**. This means the JSON must be escaped when embedded in GraphQL:

**In GraphQL string literal:**
```graphql
column_values: "{\"status\":{\"label\":\"Done\"},\"text\":\"Hello\"}"
```

**In curl with bash:**
```bash
-d '{"query": "mutation { create_item(board_id: 123, item_name: \"Test\", column_values: \"{\\\"status\\\":{\\\"label\\\":\\\"Done\\\"}}\") { id } }"}'
```

**In JavaScript:**
```javascript
const columnValues = JSON.stringify({
  status: { label: "Done" },
  text: "Hello"
});
// columnValues is already a JSON string, pass directly
```

## Clearing Column Values

To clear/reset a column value, set it to `null` or `{}`:
```json
{"date_column_id": null}
{"date_column_id": {}}
{"people_column_id": {"personsAndTeams": []}}
{"connect_column_id": {"item_ids": []}}
{"text_column_id": ""}
```
