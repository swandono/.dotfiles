---
description: Initialize headless browser environment for screenshots
---

Initialize headless browser environment for the current project:

1. Create a `screenshots/` directory in the current working directory if it doesn't exist
2. Add `screenshots/` to `.gitignore` if not already present (create `.gitignore` if it doesn't exist)
3. Update `AGENTS.md` to document the screenshots folder (add a section about the screenshots directory if not already present)
4. Test the browser MCP connection by listing pages or creating a new page (works with either Playwright MCP or Chrome DevTools MCP)

For the AGENTS.md update, add something like:
```
## Screenshots

The `screenshots/` directory is used by the headless browser for storing screenshots.
This folder is git-ignored.
```

After initialization, report the status:
- Whether the screenshots folder was created or already existed
- Whether .gitignore was updated
- Whether AGENTS.md was updated
- Whether the headless browser connection is working

If the browser connection fails, suggest troubleshooting steps like restarting OpenCode or checking the MCP configuration.
