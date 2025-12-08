---
description: Initialize database connection by reading project config files and creating project-specific MCP config
---

You are initializing the database connection for this project. Follow these steps:

**Step 1: Detect the project type and find database configuration**

Search for database credentials in the following locations based on project type:

| Project Type | Config Files to Check |
|--------------|----------------------|
| **Java Spring Boot** | `application.yaml`, `application.yml`, `application.properties`, `application-*.yaml` |
| **Go** | `.env`, `config.yaml`, `config.json` |
| **Node.js** | `.env`, `.env.local`, `config.json`, `database.json` |
| **Python** | `.env`, `settings.py`, `config.py`, `.flaskenv` |
| **Docker** | `docker-compose.yaml`, `docker-compose.yml`, `.env` |
| **Rails** | `config/database.yml`, `.env` |

**Step 2: Extract database credentials**

**IMPORTANT: For `.env` files, do NOT attempt to read them directly.** These files often contain sensitive credentials and may be blocked by security rules.

**If only `.env` files are found:**
- Do NOT try to read the `.env` file
- Ask the user to paste their `DATABASE_URL` connection string:
  ```
  I found a .env file but cannot read it directly for security reasons.

  Please paste your DATABASE_URL connection string:
  Example: postgresql://username:password@localhost:5432/database
  ```
- Wait for the user to provide the connection string before proceeding

**For other config files** (application.yaml, docker-compose.yaml, config.json, settings.py, etc.):
- Read and extract credentials normally

Look for these common patterns in non-.env files:

```
# Pattern 1: Individual fields (in YAML/JSON/Python configs)
DB_HOST / DATABASE_HOST / POSTGRES_HOST
DB_PORT / DATABASE_PORT / POSTGRES_PORT
DB_NAME / DATABASE_NAME / POSTGRES_DB
DB_USER / DATABASE_USER / POSTGRES_USER
DB_PASSWORD / DATABASE_PASSWORD / POSTGRES_PASSWORD

# Pattern 2: Full connection string
DATABASE_URL
DB_URL
JDBC_DATABASE_URL

# Pattern 3: Spring Boot JDBC URL
spring.datasource.url (extract host, port, database from jdbc:postgresql://host:port/database)
spring.datasource.username
spring.datasource.password

# Pattern 4: Docker Compose environment
services.*.environment.POSTGRES_*
services.*.environment.DATABASE_URL
```

**Step 3: Construct the PostgreSQL connection string**

If individual fields are found, construct:
```
postgresql://USERNAME:PASSWORD@HOST:PORT/DATABASE
```

Example transformations:
- `.env` with `DB_HOST=localhost`, `DB_PORT=5432`, `DB_NAME=myapp`, `DB_USER=admin`, `DB_PASSWORD=secret123`
  → `postgresql://admin:secret123@localhost:5432/myapp`

- `application.yaml` with:
  ```yaml
  spring:
    datasource:
      url: jdbc:postgresql://localhost:5432/myapp
      username: admin
      password: secret123
  ```
  → `postgresql://admin:secret123@localhost:5432/myapp`

**Step 4: Create or update the project's opencode.json**

IMPORTANT: This step creates a project-specific MCP configuration so the PostgreSQL connection works for this folder.

Check if `opencode.json` exists in the current project directory:

**If opencode.json does NOT exist**, create it with:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "postgres": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "@modelcontextprotocol/server-postgres",
        "CONNECTION_STRING_HERE"
      ],
      "enabled": true
    }
  }
}
```

**If opencode.json already exists**, read it and:
- If it has an `mcp` section, add or update the `postgres` entry
- If it doesn't have an `mcp` section, add the entire `mcp` block
- Preserve all other existing configuration (theme, keybinds, other mcp servers, etc.)

Replace `CONNECTION_STRING_HERE` with the actual connection string constructed in Step 3.

**Step 5: Add opencode.json to .gitignore**

IMPORTANT: Automatically add `opencode.json` to `.gitignore` to prevent committing sensitive credentials.

Check if `.gitignore` exists in the project root:

**If .gitignore exists:**
- Read the file and check if `opencode.json` is already listed
- If NOT listed, append `opencode.json` to the end of the file (with a newline before it if needed)
- Add a comment above it: `# OpenCode config (contains database credentials)`

**If .gitignore does NOT exist:**
- Create `.gitignore` with:
```
# OpenCode config (contains database credentials)
opencode.json
```

**Step 6: Inform the user about the config change**

Tell the user:
```
OpenCode Project Config Updated
================================
File: opencode.json
Added: PostgreSQL MCP configuration

Connection String: postgresql://[user]:[hidden]@[host]:[port]/[database]

Security: Added opencode.json to .gitignore

IMPORTANT: You need to restart OpenCode for the new MCP config to take effect.
Run: exit and re-run opencode in this directory
```

**Step 7: Test the connection (if MCP is already available)**

If the PostgreSQL MCP tool is available in the current session, test the connection:

```sql
SELECT version();
```

Then show basic database info:

```sql
SELECT
  current_database() as database,
  current_user as user,
  inet_server_addr() as host,
  inet_server_port() as port;
```

**Step 8: Report final summary**

Present a summary:

```
Database Initialization Complete
================================
Project Type:    [detected type]
Config Source:   [file where credentials were found]
Host:            [host]
Port:            [port]
Database:        [database name]
User:            [username]
Connection:      [Tested OK / Restart Required]

Files Modified:
  - opencode.json [Created / Updated]
  - .gitignore    [Updated / Created]

Tables Found:    [count] (if connection tested)
```

If connection cannot be tested (MCP not yet loaded), remind user to restart OpenCode.

**Step 9: (Optional) List available tables**

If connected successfully, show available tables:

```sql
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

---

## Security Notes

The command automatically:
- Adds `opencode.json` to `.gitignore` to prevent committing credentials
- Alternative: Use `{env:DATABASE_URL}` syntax if you set DATABASE_URL in your shell environment
