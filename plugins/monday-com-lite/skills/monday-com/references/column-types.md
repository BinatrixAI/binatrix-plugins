# Column Types — Extended Reference

Only edge cases and details beyond SKILL.md's quick table.

## Escaping in curl
```bash
-d '{"query":"mutation{create_item(board_id:123,item_name:\"Test\",column_values:\"{\\\"status\\\":{\\\"label\\\":\\\"Done\\\"}}\"){id}}"}'
```
In JS: `JSON.stringify({status:{label:"Done"}})` — already a string, pass directly.

## Status — Finding Labels
Query `settings_str` from board columns. Parse JSON:
```json
{"labels":{"0":"Working on it","1":"Done","2":"Stuck"},"labels_colors":{"0":{"color":"#fdab3d"}}}
```
Set by index: `{"index":1}` — but `{"label":"Done"}` is safer.

## Dropdown — By ID vs Label
By label: `{"labels":["Opt A"]}` | By ID: `{"ids":[1,3]}`

## People — Multiple
```json
{"personsAndTeams":[{"id":111,"kind":"person"},{"id":222,"kind":"person"},{"id":333,"kind":"team"}]}
```

## File Upload (multipart)
```bash
curl -s -X POST https://api.monday.com/v2/file \
  -H "Authorization:$MONDAY_API_TOKEN" \
  -F 'query=mutation($file:File!){add_file_to_column(item_id:ID,column_id:"files",file:$file){id}}' \
  -F 'map={"image":"variables.file"}' \
  -F 'image=@/path/to/file.pdf'
```

## Connect Boards — Setup
Create relation column: `create_column(board_id:A, title:"Deals", column_type:board_relation, defaults:"{\"boardIds\":[B_ID]}")`
Clear: `{"item_ids":[]}`

## Clearing Values
`null`, `{}`, or type-specific: `""` (text), `{"personsAndTeams":[]}` (people), `{"item_ids":[]}` (connect)

## Hour
`{"hour":14,"minute":30}`

## Week
`{"week":{"startDate":"2026-01-06","endDate":"2026-01-12"}}`

## World Clock
`{"timezone":"America/New_York"}`

## Color Picker
`{"color":"#FF5AC4"}`

## Vote
`{"votersIds":[123,456]}`

## Formula Syntax (UI only)
`IF({Status}="Done",{Amount},0)` | `DAYS({Due Date},TODAY())` | `{Numbers}*1.17` | `CONCATENATE({A}," ",{B})` | `ROUND({N}*100,2)`
