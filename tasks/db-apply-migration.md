---
task: db-apply-migration
agent: data-engineer
inputs:
  - path (string, required): Path to SQL migration file
  - database_url (string, required): PostgreSQL connection URL (from environment)
outputs:
  - pre_snapshot (file): Schema-only snapshot taken before migration
  - post_snapshot (file): Schema-only snapshot taken after migration
  - diff_patch (file): Unified diff between pre and post snapshots
---

# Apply Migration

## Purpose
Safely apply a SQL migration with pre/post schema snapshots and an exclusive advisory lock to prevent concurrent migrations. Ensures rollback capability by automatically capturing the database state before and after changes.

## Prerequisites
- Database connection is established and accessible via `$DATABASE_URL`
- Migration file exists and has valid SQL syntax
- Dry-run has been completed successfully (recommended)
- `pg_dump` and `psql` are available on the system
- Sufficient disk space for snapshots

## Steps

### 1. Pre-Flight Checks

Confirm with the user:
- Migration file: `{path}`
- Database: `$DATABASE_URL` (display redacted)
- Dry-run completed? (yes/no)
- Backup/snapshot taken? (will be done automatically)

**CRITICAL**: If dry-run was not done, stop and recommend running `db-dry-run` first.

### 2. Acquire Advisory Lock

Ensure no concurrent migrations are running:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
"SELECT pg_try_advisory_lock(hashtext('migration:apply')) AS got" \
| grep -q t || { echo "Another migration is running"; exit 1; }

echo "Migration lock acquired"
```

### 3. Pre-Migration Snapshot

Create a schema-only snapshot before applying changes:

```bash
TS=$(date +%Y%m%d%H%M%S)
mkdir -p supabase/snapshots supabase/rollback

pg_dump "$DATABASE_URL" --schema-only --clean --if-exists \
  > "supabase/snapshots/${TS}_before.sql"

echo "Pre-migration snapshot: supabase/snapshots/${TS}_before.sql"
```

### 4. Apply Migration

Run the migration with error stopping enabled:

```bash
echo "Applying migration..."
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f {path}

if [ $? -eq 0 ]; then
  echo "Migration applied successfully"
else
  echo "Migration failed - rolling back..."
  # Advisory lock will be released on disconnect
  exit 1
fi
```

### 5. Post-Migration Snapshot

Capture the schema state after the migration:

```bash
pg_dump "$DATABASE_URL" --schema-only --clean --if-exists \
  > "supabase/snapshots/${TS}_after.sql"

echo "Post-migration snapshot: supabase/snapshots/${TS}_after.sql"
```

### 6. Generate Diff

Create a unified diff between pre and post snapshots:

```bash
diff -u "supabase/snapshots/${TS}_before.sql" \
        "supabase/snapshots/${TS}_after.sql" \
  > "supabase/snapshots/${TS}_diff.patch" || true

echo "Diff saved: supabase/snapshots/${TS}_diff.patch"
```

### 7. Release Advisory Lock

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
"SELECT pg_advisory_unlock(hashtext('migration:apply'));"

echo "Migration lock released"
```

### 8. Post-Migration Actions

Present options to the user:

1. **Run smoke tests** - `db-smoke-test`
2. **Check RLS coverage** - `db-rls-audit`
3. **Verify query performance** - analyze hot paths
4. **Done for now**

## Success Output

```
Migration Applied Successfully

Timestamp: {TS}
Migration: {path}
Snapshots:
  - Before: supabase/snapshots/{TS}_before.sql
  - After:  supabase/snapshots/{TS}_after.sql
  - Diff:   supabase/snapshots/{TS}_diff.patch

Next steps:
  db-smoke-test      - Validate migration
  db-rls-audit       - Check security
  db-rollback {TS}   - Undo if needed
```

## Safety Features
- Advisory lock prevents concurrent migrations
- Pre/post snapshots for comparison and rollback
- ON_ERROR_STOP prevents partial application
- Transaction-wrapped execution
- Automatic diff generation
- Rollback instructions provided

## Acceptance Criteria
- Migration SQL executes without errors
- Pre-migration snapshot is created before any changes
- Post-migration snapshot captures the final state
- Diff patch is generated comparing the two snapshots
- Advisory lock is acquired before and released after migration

## Error Handling
- **Migration Fails Mid-Execution:** PostgreSQL rolls back the transaction automatically; advisory lock released on disconnect; pre-migration snapshot remains available; database is unchanged
- **Lock Already Held:** Another migration is running; display advisory lock diagnostic query: `SELECT * FROM pg_locks WHERE locktype = 'advisory';`
- **Snapshot Creation Fails:** Check disk space, verify pg_dump version compatibility, check database permissions
- **Connection Failed:** Check connection string, credentials, and network; retry with exponential backoff (max 3 attempts)
