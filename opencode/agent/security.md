---
description: Security auditing and vulnerability detection
mode: subagent
prompt: "{file:../prompts/security.txt}"
temperature: 0.1
tools:
  write: false
  edit: false
permission:
  bash: ask
---

Security agent for identifying vulnerabilities and security best practices.
