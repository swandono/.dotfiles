---
description: Take a screenshot of a URL and save to screenshots folder
---

Take a screenshot of the specified URL: $ARGUMENTS

Note: This command requires a browser MCP (for example, Chrome DevTools MCP configured via `/hb-init`).

Steps:

1. First check if `.opencode/screenshots/` folder exists in the current project. If not, create it and add `.opencode/` (or `.opencode/screenshots/`) to `.gitignore`
2. Navigate to the URL using the browser MCP (prefer Chrome DevTools MCP if available)
3. Wait for the page to fully load (wait for network idle or a reasonable timeout)
4. Take a screenshot using the browser MCP screenshot tool
5. Save the screenshot to the `.opencode/screenshots/` folder with a descriptive filename based on the URL and timestamp (e.g., `localhost-3000_2025-12-08_061500.png`)

If no URL is provided, default to `http://127.0.0.1:3000`

Report:

- The URL that was captured
- The filename (and relative path) where the screenshot was saved
- Any errors encountered
