---
description: Initialize database connection by reading project config files and creating project-specific MCP config
---

You are initializing the database connection for this project. Follow these steps:

**Step 1: Detect the project type and find database configuration**

Search for database credentials in the following locations based on project type:

| Project Type             | Config Files to Check                                                                               |
| ------------------------ | --------------------------------------------------------------------------------------------------- |
| **Java Spring Boot**     | `application.yaml`, `application.yml`, `application.properties`, `application-*.yaml`               |
| **Go**                   | `.env`, `config.yaml`, `config.json`                                                                |
| **Node.js**              | `.env`, `.env.local`, `config.json`, `database.json`                                                |
| **Python**               | `.env`, `settings.py`, `config.py`, `.flaskenv`                                                     |
| **Docker**               | `docker-compose.yaml`, `docker-compose.yml`, `.env`                                                 |
| **Rails**                | `config/database.yml`, `.env`                                                                       |
| **Rust**                 | `.env`, `Rocket.toml`, `config.yaml`, `config.json`                                                 |
| **Zig**                  | `.env`, `config.zig`, `config.yaml`, `config.json`                                                  |
| **SQLite (any project)** | `.env` (do not read), `settings.py`, `config.py`, `config.yaml`, `config.json`, `*.db`, `*.sqlite*` |

**Step 2: Extract database credentials**

**IMPORTANT: For `.env` files, do NOT attempt to read them directly.** These files often contain sensitive credentials and may be blocked by security rules.

**If only `.env` files are found:**

- Do NOT try to read the `.env` file
- Ask the user to paste their `DATABASE_URL` connection string:

  ```
  I found a .env file but cannot read it directly for security reasons.

  Please paste your DATABASE_URL connection string:
  Example (do not paste real credentials into chat if you can avoid it): postgresql://username:password@localhost:5432/database
  ```

- Wait for the user to provide the connection string before proceeding

**For other config files** (application.yaml, docker-compose.yaml, config.json, settings.py, etc.):

- Read and extract credentials normally

Look for these common patterns in non-.env files:

```
# Pattern 1: Individual fields (YAML/JSON/Python configs)
DB_HOST / DATABASE_HOST / POSTGRES_HOST / MYSQL_HOST
DB_PORT / DATABASE_PORT / POSTGRES_PORT / MYSQL_PORT
DB_NAME / DATABASE_NAME / POSTGRES_DB / MYSQL_DATABASE / MYSQL_DB
DB_USER / DATABASE_USER / POSTGRES_USER / MYSQL_USER
DB_PASSWORD / DATABASE_PASSWORD / POSTGRES_PASSWORD / MYSQL_PASSWORD
SQLITE_PATH / SQLITE_FILE / SQLITE_DB / SQLITE_DATABASE

# Pattern 2: Full connection string
DATABASE_URL
DB_URL
JDBC_DATABASE_URL
postgres://... or postgresql://...
sqlite://... or sqlite:///...

# Pattern 3: Spring Boot JDBC URL
spring.datasource.url (jdbc:postgresql://host:port/database or jdbc:sqlite:/path/to/file)
spring.datasource.username
spring.datasource.password

# Pattern 4: Docker Compose environment
services.*.environment.POSTGRES_*
services.*.environment.MYSQL_*
services.*.environment.DATABASE_URL
```

**Step 3: Construct the connection string**

- **PostgreSQL:**

  ```
  # Format: postgres://[user]:[password]@[host]:[port]/[database]?[options]
  ```

  Example transformation (Spring):

  ```yaml
  spring:
    datasource:
      url: jdbc:postgresql://localhost:5432/myapp
      username: admin
      password: secret123
  ```

  → `postgresql://admin:secret123@localhost:5432/myapp`

- **SQLite:**
  ```
  # Format: sqlite:///[path/to/database.db] or sqlite:///:memory:
  ```
  Notes:
  - Use the sqlite DSN form with `sqlite:///ABSOLUTE/PATH`. Example: `sqlite:///Users/you/app/data/app.db`.
  - In-memory: `sqlite:///:memory:` (ephemeral; not persisted).
  - No host/user/password/port required.
  - Ensure the file exists and is readable when using a file path.
  - Transform `jdbc:sqlite:/path/to/db.sqlite3` → `sqlite:///path/to/db.sqlite3`.

**Step 4: Create or update the project's opencode.json**

IMPORTANT: This step creates a project-specific MCP configuration so the database connection works for this folder.

Convention:
- `opencode.json` is the only file this command should create/update at the project root (besides `.gitignore` in Step 5).
- Any additional generated artifacts (for example `dbhub.toml`) should go under `.opencode/` (recommended: `.opencode/config/dbhub.toml`).

Check if `opencode.json` exists in the current project directory:

**If opencode.json does NOT exist**, create it using DBHub (handles Postgres, MySQL, SQLite, SQL Server, MariaDB) with either a single DSN or a TOML config:

- Single database via stdio transport (direct `npx`, no extra config file). Examples:
  - Postgres:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "dbhub": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "@bytebase/dbhub",
        "--transport",
        "stdio",
        "--dsn",
        "postgresql://user:password@localhost:5432/database"
      ],
      "enabled": true
    }
  }
}
```

- SQLite (use absolute path, DSN form):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "dbhub": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "@bytebase/dbhub",
        "--transport",
        "stdio",
        "--dsn",
        "sqlite:///Users/you/path/to/app.db"
      ],
      "enabled": true
    }
  }
}
```

- Multiple databases with `dbhub.toml` (recommended location: `.opencode/config/dbhub.toml`; use `{cwd}/.opencode/config/dbhub.toml` in `opencode.json` to avoid hardcoding a machine-specific absolute path):

```toml
[[sources]]
id = "postgres-artemis3"
dsn = "postgres://postgres:postgres@127.0.0.1:5432/artemis3"
readonly = true

[[sources]]
id = "postgres-crm"
dsn = "postgres://postgres:postgres@127.0.0.1:54321/crm"
readonly = true

[[sources]]
id = "local-sqlite"
dsn = "sqlite:///Users/you/path/to/app.db"
```

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "dbhub": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "@bytebase/dbhub",
        "--transport",
        "stdio",
        "--config",
        "{cwd}/.opencode/config/dbhub.toml"
      ],
      "enabled": true
    }
  }
}
```

- The first `[[sources]]` entry becomes the default if no `id` is specified.
- `readonly = true` is recommended unless write access is required.
- DBHub configuration priority: CLI args > TOML > env vars > `.env` files. `--config` is mutually exclusive with `--dsn`, `--id`, and `--readonly` (those go in TOML).
- Default transport is `stdio`; use `--transport http --port 8080` if you need the admin console/API.

After editing `opencode.json`, restart OpenCode so the MCP servers load and the tools (e.g., `mcp__dbhub__...`) appear in the session.

**If opencode.json already exists**, read it and:

- If it has an `mcp` section, add or update the `dbhub` entry (single DSN or `--config` pointing to `dbhub.toml`)
- If it doesn't have an `mcp` section, add the entire `mcp` block
- Preserve all other existing configuration (theme, keybinds, other mcp servers, etc.)

Replace `CONNECTION_STRING_HERE` with the actual connection string constructed in Step 3.

**Step 5: Add opencode.json to .gitignore**

IMPORTANT: Automatically add `opencode.json` to `.gitignore` to prevent committing sensitive credentials.

If you created a DBHub TOML config (recommended location: `.opencode/config/dbhub.toml`), add that to `.gitignore` too (either ignore `.opencode/` or the specific file).

Check if `.gitignore` exists in the project root:

**If .gitignore exists:**

- Read the file and check if `opencode.json` is already listed
- If NOT listed, append it to the end of the file (with a newline before it if needed)
- Add a comment above it: `# OpenCode config (contains database credentials)`
- If you created `.opencode/config/dbhub.toml`, also add `.opencode/` (preferred) or `.opencode/config/dbhub.toml`

**If .gitignore does NOT exist:**

- Create `.gitignore` with:

```
# OpenCode config (contains database credentials)
opencode.json

# OpenCode artifacts (may contain credentials)
.opencode/
```

**Step 6: Inform the user about the config change**

Tell the user:

```
OpenCode Project Config Updated
================================
File: opencode.json
Added: Database MCP configuration

Connection String: postgresql://[user]:[hidden]@[host]:[port]/[database] (redacted)
(or sqlite:///absolute/path/to/database.sqlite3)

Security: Added opencode.json to .gitignore

IMPORTANT: You need to restart OpenCode for the new MCP config to take effect.
Run: exit and re-run opencode in this directory
```

**Step 7: Test the connection (if MCP is already available)**

- **PostgreSQL:**
  ```sql
  SELECT version();
  SELECT
    current_database() as database,
    current_user as user,
    inet_server_addr() as host,
    inet_server_port() as port;
  ```
- **SQLite:**
  ```sql
  SELECT sqlite_version();
  PRAGMA database_list;
  ```

**Step 8: Report final summary**

Present a summary:

```
Database Initialization Complete
================================
Project Type:    [detected type]
Config Source:   [file where credentials were found]
Host:            [host] (Postgres only)
Port:            [port] (Postgres only)
Database:        [database name or sqlite file path]
User:            [username] (Postgres only)
Connection:      [Tested OK / Restart Required]

Files Modified:
  - opencode.json [Created / Updated]
  - .gitignore    [Updated / Created]

Tables Found:    [count] (if connection tested)
```

If connection cannot be tested (MCP not yet loaded), remind user to restart OpenCode.

**Step 9: (Optional) List available tables**

- **PostgreSQL:**
  ```sql
  SELECT table_name, table_type
  FROM information_schema.tables
  WHERE table_schema = 'public'
  ORDER BY table_name;
  ```
- **SQLite:**
  ```sql
  SELECT name as table_name, type as table_type
  FROM sqlite_master
  WHERE type IN ('table','view')
  ORDER BY name;
  ```

---

## Security Notes

The command automatically:

- Adds `opencode.json` to `.gitignore` to prevent committing credentials
- Alternative: Use `{env:DATABASE_URL}` syntax if you set DATABASE_URL in your shell environment
