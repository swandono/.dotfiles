---
description: Initialize oh-my-opencode config for this project
---

Initialize oh-my-opencode for the current project.

**Step 1: Confirm project root**
This command assumes you are running in the project root.

- If you are not in the project root, switch to it before continuing.

**Step 2: Ensure .opencode directory exists**
Create `.opencode/` in the project root if it does not already exist.

**Step 3: Create project oh-my-opencode config**
Create `.opencode/oh-my-opencode.json` using the exact contents of:

- `~/.config/opencode/omo-ref.json`

**Step 4: Create or update project opencode.json**
Check for `opencode.json` in the project root.

- If `opencode.json` does NOT exist, create it with:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["oh-my-opencode@latest"]
}
```

- If `opencode.json` exists, ensure it has a `plugin` array (not `plugins`) and add `"oh-my-opencode"` if missing.
- Preserve all other configuration (mcp, providers, instructions, etc.).

**Step 5: Update .gitignore**
Ensure `.gitignore` contains:

```
# OpenCode config
opencode.json
.opencode/
```

If `.gitignore` does not exist, create it with the above content.
If it exists, add any missing entries.

**Step 6: Report status**
Provide a short summary:

```
Oh-My-OpenCode Project Configured
===============================

- opencode.json: [created/updated]
- .opencode/oh-my-opencode.json: [created/updated]
- .gitignore: [created/updated/skipped]

Restart OpenCode if you added the plugin to opencode.json.
```
