---
description: Safe development with approval-based changes
mode: primary
prompt: "{file:../prompts/safe-build.txt}"
permission:
  edit: ask
  bash:
    "git push*": deny
    "git commit": ask
    "npm start": ask
    "npm run dev": ask
    "yarn start": ask
    "pnpm start": ask
    "*": allow
---

This is the safe build agent that requires approval before making code changes.
