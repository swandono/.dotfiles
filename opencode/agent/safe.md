---
description: Safe development with approval-based changes
mode: primary
prompt: "{file:../prompts/safe-build.txt}"
permission:
  edit: ask
  bash:
    "git push*": deny
    "git commit": ask
    # JavaScript/TypeScript
    "npm start": ask
    "npm run dev": ask
    "npm run start": ask
    "yarn start": ask
    "yarn dev": ask
    "pnpm start": ask
    "pnpm dev": ask
    "bun run start": ask
    "bun run dev": ask
    "node **/server.js": ask
    "node **/index.js": ask
    # Java
    "java -jar*": ask
    "mvn spring-boot:run": ask
    "gradle bootRun": ask
    "./gradlew bootRun": ask
    # Rust
    "cargo run --release": ask
    # Go
    "go run main.go": ask
    "go run .": ask
    # Docker (production-like environments)
    "docker-compose up": ask
    "docker compose up": ask
    "docker run*": ask
    # Allow everything else
    "*": allow
---

This is the safe build agent that requires approval before making code changes.
