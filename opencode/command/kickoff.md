---
description: Initialize project with safe development rules
agent: build
---

You are initializing this project with safe development practices. Follow these steps.

While doing this:

- Use `sequential-thinking` to reason step-by-step (especially when the codebase is non-trivial or ambiguous).
- Use `memory` to persist **stable, non-sensitive** facts you discover (project name, how to run tests, key directories, important conventions, special safety constraints).
- Do NOT store secrets in `memory` (API keys, tokens, passwords, full connection strings). Store redacted forms only.

**Step 1: Run OpenCode project initialization (`/init`)**
Run the built-in OpenCode initializer to generate a baseline `AGENTS.md`.

- Execute: `/init`
- If you are currently in a subdirectory, run it from the project root.

**Step 2: Verify (and only if needed, supplement) `AGENTS.md`**

1. Read `AGENTS.md`.
2. If `AGENTS.md` exists:
   - Keep the project-specific content produced by `/init` (build/lint/test commands, code style, and any Cursor/Copilot instructions).
   - If obvious, important details are missing, add them (avoid removing useful existing guidance).
3. If `AGENTS.md` does NOT exist:
   - First, confirm you are in the project root and re-run `/init`.
   - If `AGENTS.md` still does not exist, ask the user to confirm the correct project root.
   - Only if the user confirms `/init` cannot be used for this repo, analyze the project structure, tech stack, and conventions (similar to what `/init` does) and create `AGENTS.md` with **Section A** (below).

Use `memory` to store the final, verified project facts (eg. test commands, lint commands, key directories) so future sessions start faster.

**Plan artifacts (optional)**
If you create a detailed plan (especially for multi-day work), save it as a Markdown file in the repo:

- Directory: `.opencode/plans/`
- Filename: `YYYYMMDD-HHMM_short-title.md` (example: `20251216-0930_auth-refactor.md`)
- Prefer adding `.opencode/` to `.gitignore` unless the team explicitly wants to commit these files.

**Step 3: Add safe rules + MCP tools to `AGENTS.md` (idempotent)**

Update `AGENTS.md` as follows (append new sections at the end of the file):

- If it does not already contain a heading `## Safe Development Rules`, append **Section B**.
- If it does not already contain a heading `## MCP Tools Available`, append **Section C**.
- Do not duplicate these sections if they already exist.

If you had to create `AGENTS.md` in Step 2, include **Section A** first, then append **Section B** and **Section C**.

**Section A - Project Information** (Generate based on the codebase):

- Project name and description
- Tech stack and frameworks
- Project structure and key directories
- Build/lint/test commands (especially how to run a single test)
- Code conventions and patterns you observed
- Any important notes about the project

**Section B - Safe Development Rules** (Use this content):

```markdown
## Safe Development Rules

This project uses OpenCode's safe agent for careful development.

### Core Principles

1. Always READ and UNDERSTAND code before making changes
2. NEVER make assumptions - investigate thoroughly first
3. Use `sequential-thinking` for step-by-step analysis on non-trivial tasks
4. Use `memory` to store stable project facts and decisions
5. ASK for approval before creating or modifying code
6. Present findings and recommendations clearly
7. Run tests to validate changes

### What the AI CAN do:

- ✅ Use `sequential-thinking` for explicit step-by-step reasoning
- ✅ Use `memory` to store stable project facts and decisions
- ✅ Read and analyze code across multiple files
- ✅ Investigate issues systematically
- ✅ Present findings and recommendations
- ✅ Create/modify code files AFTER APPROVAL
- ✅ Run compilation and build processes
- ✅ Run unit tests and integration tests
- ✅ Validate database migrations (dry-run)
- ✅ Check code quality and linting
- ✅ Generate test reports

### What the AI CANNOT do:

- ❌ Make assumptions without reading code first
- ❌ Make code changes without explicit user approval
- ❌ Create git commits (unless explicitly requested)
- ❌ Push to remote repositories
- ❌ Start application servers in production mode
- ❌ Run applications in production mode
- ❌ Modify git configuration
- ❌ Create pull requests (unless explicitly requested)

### Workflow

**Planning (no code changes):**

1. READ → Understand the codebase and the request
2. THINK → Use `sequential-thinking` to reason step-by-step
3. ANALYZE → Identify root causes, risks, and impacts
4. RECOMMEND → Propose a plan with clear steps and verification
5. ASK → Get approval before making any code changes

**Build (only after approval):**

1. CONFIRM → Briefly restate what will change and why
2. ASK → Request a final “go ahead” before editing files
3. IMPLEMENT → Make the changes in small, reviewable steps
4. VALIDATE → Run tests/lint/typecheck and verify behavior
5. REPORT → Summarize changes and how to validate
6. REMEMBER → Save stable facts/decisions in `memory` (no secrets)
```

**Section C - Available MCP Servers** (Use this content):

```markdown
## MCP Tools Available

Note: This is the standard MCP toolset. Tools may require enabling/configuring in `opencode.json` for the current project.

| Tool                    | Description                                                                               |
| ----------------------- | ----------------------------------------------------------------------------------------- |
| **filesystem**          | Read, write, and manage files on the server.                                              |
| **docker**              | List, inspect, start, stop containers and view logs.                                      |
| **github**              | Manage repos, issues, PRs, branches, and code search.                                     |
| **chrome-devtools**     | Headless browser - screenshots, page interaction, UI debugging. Run `/hb-init` to setup.  |
| **context7**            | Search official documentation for libraries and frameworks.                               |
| **gh_grep**             | Search real-world code examples from GitHub repositories.                                 |
| **sequential-thinking** | Step-by-step problem solving and analysis.                                                |
| **memory**              | Persistent knowledge graph for storing context across sessions.                           |
| **dbhub**               | Universal DB MCP (Postgres/MySQL/SQLite/MariaDB/SQL Server). Run `/db-init` to configure. |
```

**Step 4: Inform the user**
After creating/updating the file:

- Use `memory` to store stable, reusable details you just learned (especially test/lint/typecheck commands and CI entrypoints), without secrets.
- Tell the user:
  - What you learned/confirmed about the project
  - That `AGENTS.md` has been created/updated with both project info and safe rules
  - They should commit `AGENTS.md` to Git so the whole team benefits
  - These rules will now apply to ALL agents in this project
  - They can modify `AGENTS.md` for project-specific customization
