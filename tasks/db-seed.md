---
task: db-seed
agent: data-engineer
inputs:
  - path (string, required): Path to SQL seed file
  - database_url (string, required): PostgreSQL connection URL (from environment)
  - environment (string, optional): Target environment - dev, staging, production (default: dev)
outputs:
  - seed_applied (boolean): Whether seed data was applied successfully
  - pre_seed_snapshot (file, optional): Schema snapshot taken before seeding
  - seed_log_entry (string): Entry appended to seed log file
---

# Apply Seed Data

## Purpose
Safely apply seed data to the database with idempotent operations. Validates the seed file for destructive patterns, creates an optional pre-seed snapshot, applies the data, and verifies the results.

## Prerequisites
- Database connection is established and accessible via `$DATABASE_URL`
- Seed file exists at the specified path with valid SQL
- Database schema is up to date (migrations have been applied)
- Seed file uses idempotent patterns (`INSERT...ON CONFLICT` or `INSERT...WHERE NOT EXISTS`)

## Steps

### 1. Pre-Flight Checks

Confirm with the user:
- Seed file: `{path}`
- Database: `$DATABASE_URL` (display redacted)
- Environment: dev / staging / production
- Is the seed idempotent? (uses `INSERT...ON CONFLICT` or similar)

**CRITICAL**: Never seed production without explicit confirmation.

### 2. Validate Seed File

Check for dangerous and non-idempotent patterns:

```bash
echo "Validating seed file..."

# Check for destructive patterns
if grep -qi "TRUNCATE\|DELETE FROM" {path}; then
  echo "WARNING: Seed contains TRUNCATE/DELETE"
  echo "This is destructive. Continue? (yes/no)"
fi

# Check for idempotent pattern
if ! grep -qi "ON CONFLICT" {path}; then
  echo "WARNING: No ON CONFLICT detected"
  echo "Seed may not be idempotent. Continue? (yes/no)"
fi

echo "Seed file validated"
```

### 3. Create Pre-Seed Snapshot (Recommended)

```bash
TS=$(date +%Y%m%d%H%M%S)
mkdir -p supabase/snapshots

pg_dump "$DATABASE_URL" --schema-only --clean --if-exists \
  > "supabase/snapshots/${TS}_before_seed.sql"

echo "Snapshot: supabase/snapshots/${TS}_before_seed.sql"
```

### 4. Apply Seed Data

Run the seed file with error handling:

```bash
echo "Applying seed data..."

psql "$DATABASE_URL" \
  -v ON_ERROR_STOP=1 \
  -f {path}

if [ $? -eq 0 ]; then
  echo "Seed data applied successfully"
else
  echo "Seed failed"
  echo "Rollback snapshot: supabase/snapshots/${TS}_before_seed.sql"
  exit 1
fi
```

### 5. Verify Seed Data

Run basic row count verification:

```bash
echo "Verifying seed data..."

psql "$DATABASE_URL" -c \
"SELECT
  'users' AS table_name, COUNT(*) AS rows FROM users
UNION ALL
SELECT
  'categories', COUNT(*) FROM categories
ORDER BY table_name;"

echo "Verification complete"
```

### 6. Document Seed

Log what was seeded:

```bash
mkdir -p supabase/docs
cat >> supabase/docs/SEED_LOG.md << EOF

## Seed Applied: ${TS}
- File: {path}
- Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
- Environment: ${ENVIRONMENT:-unknown}
EOF

echo "Logged to supabase/docs/SEED_LOG.md"
```

## Idempotent Seed Patterns

Best practice examples for seed files:

```sql
-- GOOD: Idempotent with ON CONFLICT
INSERT INTO categories (id, name, slug)
VALUES
  ('cat-1', 'Technology', 'technology'),
  ('cat-2', 'Design', 'design')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  slug = EXCLUDED.slug;

-- GOOD: Conditional insert
INSERT INTO users (id, email, role)
SELECT 'user-1', 'admin@example.com', 'admin'
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE email = 'admin@example.com'
);

-- BAD: Not idempotent - will fail on retry
INSERT INTO categories (name, slug)
VALUES ('Technology', 'technology');
```

## Acceptance Criteria
- Seed file passes validation checks (or user explicitly overrides warnings)
- Seed data is applied without errors
- Row counts confirm data was inserted
- Seed operation is logged with timestamp and file reference
- Pre-seed snapshot is available for rollback if needed

## Error Handling
- **Seed Fails with Constraint Violation:** Check seed file for duplicate keys or missing foreign key references; fix the seed file and re-run
- **Destructive Patterns Detected:** Warn the user about TRUNCATE/DELETE operations; require explicit confirmation before proceeding
- **Non-Idempotent Seed:** Warn the user; suggest adding ON CONFLICT clauses; allow override with confirmation
- **Connection Failed:** Check connection string and credentials; retry with exponential backoff (max 3 attempts)
- **Partial Seed Application:** Restore from pre-seed snapshot if needed using `db-rollback`; fix seed file and retry
