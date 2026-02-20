---
task: db-snapshot
agent: data-engineer
inputs:
  - label (string, required): Snapshot label/name (e.g., "baseline", "pre_migration", "v1_2_0")
  - database_url (string, required): PostgreSQL connection URL (from environment)
  - include_data (boolean, optional): Include data in snapshot, not just schema (default: false)
  - tables (array, optional): Specific tables to snapshot (default: all public tables)
outputs:
  - snapshot_file (file): The SQL snapshot file
  - metadata_file (file): Metadata file with snapshot details and restore instructions
---

# Create Database Snapshot

## Purpose
Create a schema-only (or optionally data-inclusive) snapshot of the database using `pg_dump` for rollback capability, schema versioning, and comparison workflows.

## Prerequisites
- Database connection is established and accessible via `$DATABASE_URL`
- `pg_dump` is available on the system and version-compatible with the database
- Sufficient disk space for the snapshot file

## Steps

### 1. Confirm Snapshot Details

Ask the user:
- Snapshot label: `{label}`
- Purpose of this snapshot (e.g., "before adding user_roles table")
- Include data? (schema-only is default -- safer and faster)

### 2. Create Snapshots Directory

```bash
mkdir -p supabase/snapshots
```

### 3. Generate Snapshot

```bash
TS=$(date +%Y%m%d_%H%M%S)
LABEL="{label}"
FILENAME="supabase/snapshots/${TS}_${LABEL}.sql"

echo "Creating snapshot: $FILENAME"

pg_dump "$DATABASE_URL" \
  --schema-only \
  --clean \
  --if-exists \
  --no-owner \
  --no-privileges \
  > "$FILENAME"

if [ $? -eq 0 ]; then
  echo "Snapshot created: $FILENAME"
  ls -lh "$FILENAME"
else
  echo "Snapshot failed"
  exit 1
fi
```

### 4. Verify Snapshot

Run sanity checks on the generated file:

```bash
# Check file is not empty
if [ ! -s "$FILENAME" ]; then
  echo "WARNING: Snapshot file is empty"
  exit 1
fi

# Count schema objects
echo "=== Snapshot Contents ==="
echo "Tables: $(grep -c 'CREATE TABLE' "$FILENAME")"
echo "Functions: $(grep -c 'CREATE FUNCTION' "$FILENAME")"
echo "Policies: $(grep -c 'CREATE POLICY' "$FILENAME")"
```

### 5. Create Snapshot Metadata

```bash
cat > "supabase/snapshots/${TS}_${LABEL}.meta" <<EOF
Snapshot: ${TS}_${LABEL}
Created: $(date -Iseconds)
Label: ${LABEL}
Purpose: [user provided purpose]
File: ${FILENAME}
Size: $(ls -lh "$FILENAME" | awk '{print $5}')

To restore:
  db-rollback supabase/snapshots/${TS}_${LABEL}.sql

Or manually:
  psql "\$DATABASE_URL" -f "${FILENAME}"
EOF
```

## Snapshot Options

### Schema-Only (Default)
- Fast (seconds), small file size, safe to apply to any environment
- Does NOT preserve data
- **Use for:** Migration rollback, schema versioning

### Schema + Data
```bash
pg_dump "$DATABASE_URL" \
  --clean --if-exists --no-owner --no-privileges \
  > "$FILENAME"
```
- Slower (minutes to hours), large file, data may conflict on restore
- **Use for:** Disaster recovery, environment cloning

### Specific Tables Only
```bash
pg_dump "$DATABASE_URL" \
  --schema-only \
  --table="users" \
  --table="profiles" \
  > "$FILENAME"
```
- Targeted and smaller file
- **Use for:** Testing specific table changes

## Snapshot Naming Best Practices

**Good names:**
- `baseline` -- Initial schema state
- `pre_migration` -- Before any migration
- `pre_v1_2_0` -- Before version deployment
- `working_state` -- Known good state

**Bad names:**
- `backup` -- Too generic
- `test` -- Unclear purpose
- `snapshot1` -- No context

## Retention Guidelines

- Last 7 days: Keep all snapshots
- Last 30 days: Keep daily snapshots
- Last year: Keep monthly snapshots
- Forever: Keep major version snapshots

```bash
# Cleanup: keep last 10 snapshots
cd supabase/snapshots
ls -t *.sql | tail -n +11 | xargs rm -f
```

## Integration with Workflow

### Pre-Migration Workflow
```bash
db-snapshot pre_migration       # Create rollback point
db-dry-run migration.sql        # Test safely
db-apply-migration migration.sql  # Apply
db-snapshot post_migration      # Capture new state
```

### Comparison Workflow
```bash
db-snapshot before_changes
# ... make changes ...
db-snapshot after_changes
diff -u supabase/snapshots/*_before_changes.sql \
     supabase/snapshots/*_after_changes.sql
```

## Security Notes

Snapshots may contain sensitive schema information (table names reveal business logic, function names expose features, comments may contain internal notes).

**In public repos:**
- Consider adding snapshots to `.gitignore`
- Sanitize snapshots before committing
- Use private repos only for schema versioning

**Never commit:**
- Snapshots with data included
- Files containing passwords or secrets
- Connection strings in metadata

## Acceptance Criteria
- Snapshot file is created and is non-empty
- Schema object counts are reported (tables, functions, policies)
- Metadata file is created with restore instructions
- File path and size are displayed to the user

## Error Handling
- **"pg_dump: error: connection failed":** Check DATABASE_URL; verify network connectivity and credentials
- **"pg_dump: error: permission denied":** Use a connection string with sufficient privileges (typically the database owner)
- **Snapshot File Is Empty:** Verify database has tables (`SELECT * FROM pg_tables WHERE schemaname='public';`); check pg_dump version compatibility
- **Snapshot Is Unexpectedly Large:** Ensure `--schema-only` flag is used; data may have been included unintentionally
- **Disk Space Insufficient:** Check available disk space before running; clean up old snapshots first
