---
task: db-bootstrap
agent: data-engineer
inputs:
  - project_name: Name of the project (e.g., "my-platform")
  - template_level: Setup level - 'minimal', 'standard', or 'full'
outputs:
  - supabase_directory: Complete Supabase project structure under supabase/
  - config_files: Configuration files (config.toml, .gitignore)
  - baseline_migration: Initial schema migration (full template only)
---

# Bootstrap Supabase Project

## Purpose
Create a standard Supabase project directory structure with migrations, seeds, tests, rollback scripts, snapshots, and documentation, ready for database development workflows.

## Prerequisites
- Write access to the project root directory
- Node.js 18+ (for Supabase CLI, if used)
- `SUPABASE_DB_URL` environment variable (can be set after bootstrap)

## Steps

### 1. Confirm Project Setup

Prompt for:
- **Project name** (e.g., "my-platform")
- **Template level:**
  1. **Minimal** - Directories only
  2. **Standard** - Directories + READMEs + config
  3. **Full** - Everything + baseline schema example

### 2. Create Directory Structure

```bash
mkdir -p supabase/{migrations,seeds,tests,rollback,snapshots,docs}

echo "Created directories:
  supabase/migrations/    - Schema migrations
  supabase/seeds/         - Seed data
  supabase/tests/         - Smoke tests
  supabase/rollback/      - Rollback scripts
  supabase/snapshots/     - Schema snapshots
  supabase/docs/          - Documentation"
```

### 3. Create Core Files

#### supabase/migrations/README.md
Document migration naming convention (`YYYYMMDDHHMMSS_description.sql`) and ordering rules:
1. Extensions
2. Tables + Constraints
3. Functions
4. Triggers
5. RLS (enable + policies)
6. Views

#### supabase/seeds/README.md
Document seed types: Required, Test, Reference. Use idempotent pattern with `ON CONFLICT DO NOTHING`.

#### supabase/tests/README.md
Document smoke tests: tables exist, RLS enabled, policies installed, functions callable, basic queries work.

#### supabase/rollback/README.md
Document snapshot-based and manual rollback procedures.

#### supabase/.gitignore
```gitignore
.env
.env.local
.branches
.temp
.DS_Store
Thumbs.db
```

### 4. Generate config.toml (Standard and Full)

```toml
[api]
enabled = true
port = 54321

[db]
port = 54322
shadow_port = 54320
major_version = 15

[db.pooler]
enabled = true
port = 54329
pool_mode = "transaction"

[studio]
enabled = true
port = 54323

[auth]
enabled = true
site_url = "http://localhost:3000"
```

### 5. Create Baseline Schema (Full Only)

#### supabase/migrations/00000000000000_baseline.sql

```sql
BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

GRANT USAGE ON SCHEMA public TO authenticated, anon;
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;

COMMIT;
```

### 6. Create Initial Smoke Test

#### supabase/tests/smoke_test.sql

```sql
SET client_min_messages = warning;

\echo 'Checking tables...'
SELECT COUNT(*) AS tables FROM information_schema.tables
WHERE table_schema='public';

\echo 'Checking RLS...'
SELECT COUNT(*) AS rls_enabled FROM pg_tables
WHERE schemaname='public' AND rowsecurity=true;

\echo 'Checking policies...'
SELECT COUNT(*) AS policies FROM pg_policies
WHERE schemaname='public';

\echo 'Smoke test complete'
```

### 7. Create Migration Log

#### supabase/docs/migration-log.md

Track each migration with version, filename, status, changes, and rollback info.

## Project Options Summary

| Option | Includes |
|--------|----------|
| **Minimal** | Directories only |
| **Standard** | + README files, config.toml, .gitignore, migration-log.md |
| **Full** | + baseline.sql migration, smoke_test.sql, example profiles table, RLS policies |

## Environment Setup

Create `.env` file in project root:

```bash
# Pooler (recommended for migrations)
SUPABASE_DB_URL="postgresql://postgres.[PASSWORD]@[PROJECT-REF].supabase.co:6543/postgres?sslmode=require"

# Direct (for backups/analysis)
# SUPABASE_DB_URL="postgresql://postgres.[PASSWORD]@[PROJECT-REF].supabase.co:5432/postgres?sslmode=require"
```

**Security:** Added to .gitignore, use pooler (port 6543), require SSL.

## Next Steps After Bootstrap

1. Set `SUPABASE_DB_URL` in `.env`
2. Run environment check to validate setup
3. Design schema or use existing
4. Apply baseline migration
5. Run smoke tests
6. Create initial snapshot
7. Update migration-log.md

## Error Handling
- **Directory already exists:** Back up existing `supabase/` directory, then bootstrap fresh and merge as needed
- **No permission to create directories:** Verify you are in the project root with write access
- **Config conflicts with existing Supabase project:** Bootstrap is compatible with Supabase CLI; keep existing config and use bootstrap for organizational structure only
- **Baseline migration fails:** Check that auth.users table exists (requires Supabase), verify extensions are available
