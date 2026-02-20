---
task: setup-database
agent: data-engineer
inputs:
  - project_path (string, required): Target directory path for database setup
  - db_type (string, optional): Database type - supabase, postgresql, mongodb, mysql, sqlite
  - options (object, optional): Initialization options and configuration overrides
outputs:
  - initialized_project (string): Path to initialized database project
  - config_created (boolean): Whether configuration files were created successfully
---

# Setup Database

## Purpose
Interactive database project setup supporting multiple database engines (Supabase, PostgreSQL, MongoDB, MySQL, SQLite). Detects the database type from project configuration or prompts the user to select one, then scaffolds the full project structure with migrations, seeds, and configuration.

## Prerequisites
- Target directory exists and is writable
- Directory is empty or force flag is set
- Required CLI tools installed for chosen database (e.g., `supabase` CLI, `psql`, `mongosh`, `sqlite3`)
- Node.js 18+ available

## Steps

### 1. Detect or Prompt for Database Type

Auto-detect from PRD or tech stack configuration files:

```bash
# Auto-detect from PRD or tech stack if available
if grep -qiE "supabase|postgres" docs/prd/*.yaml docs/architecture/*.yaml 2>/dev/null; then
  DETECTED_DB="postgresql"
elif grep -qiE "mongodb|mongo" docs/prd/*.yaml docs/architecture/*.yaml 2>/dev/null; then
  DETECTED_DB="mongodb"
elif grep -qiE "mysql|mariadb" docs/prd/*.yaml docs/architecture/*.yaml 2>/dev/null; then
  DETECTED_DB="mysql"
elif grep -qiE "sqlite" docs/prd/*.yaml docs/architecture/*.yaml 2>/dev/null; then
  DETECTED_DB="sqlite"
else
  DETECTED_DB=""
fi
```

If not detected, prompt the user:

```
Select database type:

1. supabase    - PostgreSQL + RLS + Realtime + Edge Functions
2. postgresql  - Standard PostgreSQL (self-hosted or managed)
3. mongodb     - NoSQL document database
4. mysql       - MySQL or MariaDB relational database
5. sqlite      - Embedded SQLite database

Which database? [supabase/postgresql/mongodb/mysql/sqlite]:
```

### 2. Supabase Setup

**When:** User selects `supabase`

1. **Install Supabase CLI** (if not present):
   ```bash
   if command -v supabase &> /dev/null; then
     echo "Supabase CLI already installed: $(supabase --version)"
   else
     # macOS
     brew install supabase/tap/supabase
     # Linux
     curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar -xz
     sudo mv supabase /usr/local/bin/
   fi
   ```

2. **Initialize Supabase project:**
   ```bash
   supabase init
   ```

3. **Create standard directories:**
   ```bash
   mkdir -p supabase/migrations supabase/seed.sql supabase/tests supabase/functions
   ```

4. **Create starter migration** with UUID extension, example users table, RLS policy, and updated_at trigger:
   ```sql
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

   CREATE TABLE IF NOT EXISTS users (
     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
     email TEXT UNIQUE NOT NULL,
     created_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW()
   );

   ALTER TABLE users ENABLE ROW LEVEL SECURITY;

   CREATE POLICY "Users can read own data"
     ON users FOR SELECT
     USING (auth.uid() = id);
   ```

5. **Create starter seed data:**
   ```sql
   INSERT INTO users (id, email)
   VALUES ('550e8400-e29b-41d4-a716-446655440000', 'test@example.com')
   ON CONFLICT (email) DO NOTHING;
   ```

6. **Start local development:**
   ```bash
   supabase start
   ```

### 3. PostgreSQL Setup

**When:** User selects `postgresql`

1. Create project structure: `database/migrations`, `database/seeds`, `database/scripts`
2. Create `.env.example` with connection config (host, port, db, user, password, DATABASE_URL)
3. Create initial migration with users table, updated_at trigger function
4. Create migration runner script (`database/scripts/migrate.sh`)

### 4. MongoDB Setup

**When:** User selects `mongodb`

1. Create project structure: `database/migrations`, `database/seeds`, `database/schemas`
2. Create `.env.example` with MongoDB connection config
3. Create initial JSON schema validator for users collection
4. Create seed data in JSON format

### 5. MySQL Setup

**When:** User selects `mysql`

1. Create project structure: `database/migrations`, `database/seeds`, `database/scripts`
2. Create `.env.example` with MySQL connection config
3. Create initial migration with users table using InnoDB, utf8mb4

### 6. SQLite Setup

**When:** User selects `sqlite`

1. Create project structure: `database/migrations`, `database/seeds`
2. Create initial migration with users table and updated_at trigger
3. Create the database file:
   ```bash
   sqlite3 database/myapp_development.db < database/migrations/001_initial_schema.sql
   ```

### 7. Post-Setup Summary

Display next steps for all database types:

```
Database setup complete!

Next steps:
  1. Configure environment variables (.env file)
  2. Create your schema design
  3. Generate migrations
  4. Apply migrations
  5. Set up RLS policies (Supabase/PostgreSQL only)
  6. Add seed data
```

## Acceptance Criteria
- Project structure is correct for selected database type
- All configuration files are valid and present
- Starter migration is syntactically correct
- Environment template (.env.example) is created

## Error Handling
- **Directory Not Empty:** Prompt for confirmation to merge or abort; use force flag to override
- **CLI Not Installed:** Provide installation instructions for the platform; attempt automatic install
- **Initialization Failed:** Check file permissions and disk space; cleanup partial initialization and log error
- **Unsupported Database Type:** Display supported types and prompt again
