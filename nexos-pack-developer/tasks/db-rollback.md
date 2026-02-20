---
task: db-rollback
agent: data-engineer
inputs:
  - target (string, required): Path to snapshot file or rollback script
  - database_url (string, required): PostgreSQL connection URL (from environment)
outputs:
  - emergency_snapshot (file): Snapshot taken before rollback for safety
  - post_rollback_snapshot (file): Snapshot taken after rollback for verification
  - rollback_success (boolean): Whether the rollback completed successfully
---

# Rollback Database

## Purpose
Restore the database to a previous state by applying a snapshot or rollback script. Includes safety measures such as an automatic emergency snapshot, exclusive advisory locking, post-rollback validation, and emergency restore if the rollback itself fails.

## Prerequisites
- Database connection is established and accessible via `$DATABASE_URL`
- Target snapshot or rollback script exists and contains valid SQL
- `pg_dump` and `psql` are available on the system
- Sufficient disk space for emergency snapshot

## Steps

### 1. Confirm Rollback

**Display critical warning before proceeding:**

```
DATABASE ROLLBACK WARNING

You are about to restore the database to a previous state.

Target: {target}

This will:
  - Drop and recreate all schema objects
  - Preserve existing data (if schema-only snapshot)
  - Lose any schema changes made after snapshot
  - Potentially break application if schema incompatible

Are you ABSOLUTELY SURE you want to proceed?
Type ROLLBACK to confirm.
```

### 2. Pre-Rollback Safety Checks

Create an emergency snapshot before any changes:

```bash
echo "Creating emergency snapshot before rollback..."
TS=$(date +%Y%m%d_%H%M%S)
EMERGENCY="supabase/snapshots/${TS}_emergency_before_rollback.sql"

pg_dump "$DATABASE_URL" \
  --schema-only \
  --clean \
  --if-exists \
  > "$EMERGENCY"

if [ $? -eq 0 ]; then
  echo "Emergency snapshot: $EMERGENCY"
else
  echo "Emergency snapshot failed - ABORTING ROLLBACK"
  exit 1
fi
```

### 3. Validate Rollback Target

```bash
TARGET="{target}"

# Check file exists
if [ ! -f "$TARGET" ]; then
  echo "Rollback target not found: $TARGET"
  exit 1
fi

# Check file contains valid SQL
if ! grep -q "CREATE\|DROP\|ALTER" "$TARGET"; then
  echo "File does not appear to be valid SQL"
  exit 1
fi

echo "Rollback target validated: $TARGET"
echo "  File size: $(ls -lh "$TARGET" | awk '{print $5}')"
```

### 4. Acquire Exclusive Lock

Prevent concurrent operations:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
"SELECT pg_try_advisory_lock(hashtext('migration:rollback')) AS got" \
| grep -q t || { echo "Another operation is running"; exit 1; }

echo "Lock acquired"
```

### 5. Execute Rollback

```bash
echo "=== EXECUTING ROLLBACK ==="
echo "Started: $(date -Iseconds)"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$TARGET"

RESULT=$?

echo "Completed: $(date -Iseconds)"

if [ $RESULT -eq 0 ]; then
  echo "ROLLBACK SUCCESSFUL"
else
  echo "ROLLBACK FAILED"
  echo "Emergency snapshot available: $EMERGENCY"
  echo "Attempting to restore from emergency snapshot..."

  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$EMERGENCY"

  if [ $? -eq 0 ]; then
    echo "Restored from emergency snapshot"
  else
    echo "Emergency restore also failed - DATABASE MAY BE INCONSISTENT"
    echo "Manual intervention required"
  fi

  exit 1
fi
```

### 6. Post-Rollback Validation

```bash
echo "=== POST-ROLLBACK VALIDATION ==="

# Count schema objects
psql "$DATABASE_URL" -t -c \
"SELECT
  (SELECT COUNT(*) FROM pg_tables WHERE schemaname='public') AS tables,
  (SELECT COUNT(*) FROM pg_policies WHERE schemaname='public') AS policies,
  (SELECT COUNT(*) FROM pg_proc WHERE pronamespace='public'::regnamespace) AS functions;"

# Sanity checks
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
SELECT 'Tables exist' AS check, COUNT(*) > 0 AS pass
FROM pg_tables WHERE schemaname='public';

SELECT 'Functions exist' AS check, COUNT(*) > 0 AS pass
FROM pg_proc WHERE pronamespace='public'::regnamespace;
SQL
```

### 7. Release Lock and Create Post-Rollback Snapshot

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
"SELECT pg_advisory_unlock(hashtext('migration:rollback'));"

echo "Lock released"

POST_SNAPSHOT="supabase/snapshots/${TS}_post_rollback.sql"
pg_dump "$DATABASE_URL" --schema-only --clean --if-exists > "$POST_SNAPSHOT"

echo "Post-rollback snapshot: $POST_SNAPSHOT"
```

### 8. Report Results

```
DATABASE ROLLBACK COMPLETED

Rolled back to: {target}
Timestamp: {TS}

Snapshots created:
  - Emergency (before): {EMERGENCY}
  - Post-rollback (after): {POST_SNAPSHOT}

Next steps:
  1. db-smoke-test    - Validate schema
  2. db-rls-audit     - Check security
  3. Test application functionality
  4. Monitor for issues

If issues detected:
  db-rollback {EMERGENCY}  - Restore to pre-rollback state
```

## Rollback Strategies

### Strategy 1: Snapshot Restore (Recommended)
- **Use when:** Reverting schema changes
- Fast, complete schema state, tested with pg_dump
- Data preserved but may be incompatible; requires prior snapshot

### Strategy 2: Explicit Rollback Script
- **Use when:** Surgical changes to specific objects
```sql
BEGIN;
DROP TRIGGER IF EXISTS set_user_role_timestamp ON user_roles;
DROP FUNCTION IF EXISTS update_user_role_timestamp();
DROP TABLE IF EXISTS user_roles;
COMMIT;
```
- Precise control, documented undo process, can be tested
- Must be written manually, easy to miss steps

### Strategy 3: Forward Fix
- **Use when:** Rollback is dangerous, better to fix forward
- No data loss risk, maintains history, safe in production
- More work, leaves intermediate state in history

## Rollback Decision Matrix

| Situation | Strategy |
|-----------|----------|
| Migration failed mid-way | Restore snapshot |
| Schema breaks application | Restore snapshot |
| Wrong migration applied | Restore snapshot |
| Minor bug in function | Forward fix |
| Data corruption risk | Forward fix |
| Production with active users | Forward fix |

## Safety Checklist

Before executing rollback:
- [ ] Emergency snapshot created automatically
- [ ] Application stopped or in maintenance mode
- [ ] Users notified of downtime
- [ ] Team aware of rollback operation
- [ ] Rollback target validated
- [ ] Exclusive lock acquired
- [ ] Post-rollback test plan ready

## Acceptance Criteria
- Emergency snapshot is created before any rollback changes
- Rollback target file is validated before execution
- Advisory lock prevents concurrent operations
- Post-rollback validation confirms schema object counts
- Post-rollback snapshot captures the restored state
- If rollback fails, emergency snapshot restore is attempted automatically

## Error Handling
- **"relation already exists":** Snapshot file missing `DROP...IF EXISTS` statements; regenerate snapshot with `--clean --if-exists` flags
- **Rollback succeeded but application still broken:** Deploy previous application version, fix application code, or roll forward with a new migration
- **Emergency snapshot failed:** ABORT ROLLBACK immediately; do not proceed without a safety snapshot; check database connectivity and disk space
- **Rollback created orphaned objects:** Find orphaned triggers: `SELECT tgname FROM pg_trigger WHERE tgrelid NOT IN (SELECT oid FROM pg_class);`; find orphaned indexes: `SELECT indexname FROM pg_indexes WHERE tablename NOT IN (SELECT tablename FROM pg_tables);`
- **Lock already held:** Another operation is running; check for stuck locks: `SELECT * FROM pg_locks WHERE locktype = 'advisory';`
