---
description: Initialize headless browser environment for screenshots
---

Initialize headless browser environment for the current project:

**Step 1: Create screenshots directory**
Create a `.opencode/screenshots/` directory in the current working directory if it doesn't exist.

**Step 2: Update .gitignore**
Add `opencode.json` and `.opencode/` to `.gitignore` if not already present (create `.gitignore` if it doesn't exist).

**Step 3: Add project MCP config (chrome-devtools)**
Add a `chrome-devtools` MCP entry to the project's `opencode.json` (not the global one). Use platform-appropriate commands:

- macOS:
  ```json
  {
    "mcp": {
      "chrome-devtools": {
        "type": "local",
        "command": ["npx", "-y", "chrome-devtools-mcp@latest", "--headless"],
        "enabled": true
      }
    }
  }
  ```
- Linux:
  ```json
  {
    "mcp": {
      "chrome-devtools": {
        "type": "local",
        "command": [
          "npx",
          "-y",
          "chrome-devtools-mcp@latest",
          "--headless",
          "--executable-path=/usr/bin/google-chrome",
          "--chrome-arg=--no-sandbox",
          "--chrome-arg=--disable-setuid-sandbox"
        ],
        "enabled": true
      }
    }
  }
  ```
  After editing `opencode.json`, restart OpenCode so the `chrome-devtools` tool appears.

**Step 4: Update AGENTS.md**
Add a screenshots section to `AGENTS.md` if not already present:

```markdown
## Screenshots

The `.opencode/screenshots/` directory is used by the headless browser for storing screenshots.
This folder is git-ignored.

### Taking Screenshots

When using chrome-devtools MCP, always specify the full path to save screenshots in this folder:

- Use: `.opencode/screenshots/screenshot-name.png` or `{cwd}/.opencode/screenshots/screenshot-name.png`
- Example names: `.opencode/screenshots/homepage.png`, `.opencode/screenshots/error-state.png`, `.opencode/screenshots/2024-01-15-bug.png`
```

**Step 5: Report status**
After initialization, report:

- Whether the screenshots folder was created or already existed
- Whether .gitignore was updated
- Whether AGENTS.md was updated
- Whether the MCP entry was added to project `opencode.json`

**Important Notes:**

- The chrome-devtools `take_screenshot` tool requires a `path` parameter
- Always use relative paths from project root: `.opencode/screenshots/filename.png`
- Use descriptive filenames that indicate what the screenshot shows
- For debugging sessions, include timestamps: `.opencode/screenshots/2024-01-15-issue-123.png`

If the browser connection fails, suggest troubleshooting steps like restarting OpenCode or checking the MCP configuration.
