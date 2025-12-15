---
description: Initialize all MCP connections (database + headless browser)
---

Run MCP initialization commands as needed:

1. If the project uses a database and you want DB access: run `/db-init`
2. If you want screenshots/headless browser tools: run `/hb-init`

If unsure, ask the user which ones they want enabled.

After running the selected commands, provide a combined summary.

Note: If a command updates project `opencode.json`, OpenCode needs a restart for new MCP tools to appear.

```
MCP Initialization Complete
===========================

DATABASE:
  [Summary from db-init]

HEADLESS BROWSER:
  [Summary from hb-init]

All MCP connections initialized. Restart OpenCode if any new configurations were added.
```
