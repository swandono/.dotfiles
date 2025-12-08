---
description: Initialize all MCP connections (database + headless browser)
---

Run both MCP initialization commands in sequence:

1. First, execute the database initialization: `/db-init`
2. Then, execute the headless browser initialization: `/hb-init`

After both complete, provide a combined summary:

```
MCP Initialization Complete
===========================

DATABASE:
  [Summary from db-init]

HEADLESS BROWSER:
  [Summary from hb-init]

All MCP connections initialized. Restart OpenCode if any new configurations were added.
```
