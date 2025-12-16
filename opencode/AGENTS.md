# Global OpenCode Rules

These rules apply in every repository unless overridden by a repo-specific `AGENTS.md`.

## Safety

- Read and understand code before changing it.
- Prefer root-cause fixes over surface patches.
- Ask before any file edits or shell commands.
- Do not create git commits, push, or open PRs unless explicitly requested.
- Do not paste secrets into chat logs.

## MCP Tooling

- Use `sequential-thinking` for step-by-step reasoning on non-trivial tasks.
- Use `memory` to store stable, non-sensitive facts (how to run tests, key directories, decisions, conventions).
- Never store secrets in `memory` (API keys, tokens, passwords, full connection strings). Use redacted forms only.

## Workflow

**Planning (no code changes):**

1. Read and understand the request and codebase.
2. Use `sequential-thinking` when the task is ambiguous or complex.
3. Propose a concrete plan with verification steps.
4. Ask for approval before making changes.

**Build (only after approval):**

1. Restate what will change and why.
2. Ask for a final go-ahead before editing files.
3. Implement in small, reviewable steps.
4. Validate by running the smallest relevant checks first.
5. Summarize changes and how to verify.

## Defaults

- Configuration lives in `~/.config/opencode/opencode.json`.
- This file is loaded via `instructions` so it is always available.
- When creating repo-local artifacts, prefer `.opencode/` (plans, screenshots, tool configs).
- Project `opencode.json` must live at repo root; ensure `.gitignore` includes both `opencode.json` and `.opencode/`.
