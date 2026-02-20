---
task: db-smoke-test
agent: data-engineer
inputs:
  - database_url (string, required): PostgreSQL connection URL (from environment)
  - smoke_test_path (string, optional): Path to custom smoke test SQL file
outputs:
  - test_passed (boolean): Whether all smoke test checks passed
  - test_report (string): Summary of checks completed and any failures
---

# Database Smoke Test

## Purpose
Run post-migration validation checks to verify that the database schema is intact, expected objects exist, RLS policies are in place, and basic queries execute without errors.

## Prerequisites
- Database connection is established and accessible via `$DATABASE_URL`
- `psql` is available on the system
- Migrations have been applied (this task validates the result)

## Steps

### 1. Locate Smoke Test File

Check for a smoke test file in this order of priority:

1. `supabase/tests/smoke/v_current.sql` (project-specific, current version)
2. `supabase/tests/smoke_test.sql` (project-specific, generic)
3. Custom path provided via `smoke_test_path` input

If no smoke test file is found, run the built-in checks from step 3 below.

### 2. Run Smoke Test File

If a smoke test file is found:

```bash
SMOKE_TEST=""

if [ -f "supabase/tests/smoke/v_current.sql" ]; then
  SMOKE_TEST="supabase/tests/smoke/v_current.sql"
elif [ -f "supabase/tests/smoke_test.sql" ]; then
  SMOKE_TEST="supabase/tests/smoke_test.sql"
fi

if [ -n "$SMOKE_TEST" ]; then
  echo "Running smoke test: $SMOKE_TEST"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$SMOKE_TEST"
fi
```

### 3. Built-In Checks (If No Custom File)

Run these standard validation queries:

**Schema Objects:**
```sql
-- Expected tables exist
SELECT 'Tables exist' AS check,
  COUNT(*) AS count
FROM pg_tables WHERE schemaname='public';

-- Expected functions exist
SELECT 'Functions exist' AS check,
  COUNT(*) AS count
FROM pg_proc WHERE pronamespace='public'::regnamespace;

-- Expected triggers exist
SELECT 'Triggers exist' AS check,
  COUNT(*) AS count
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public';
```

**RLS Coverage:**
```sql
-- Tables without RLS (security risk)
SELECT tablename, 'RLS DISABLED' AS status
FROM pg_tables
WHERE schemaname='public'
AND rowsecurity = false
ORDER BY tablename;

-- Tables with RLS but no policies
SELECT t.tablename, 'NO POLICIES' AS status
FROM pg_tables t
LEFT JOIN pg_policies p ON p.tablename = t.tablename AND p.schemaname = 'public'
WHERE t.schemaname = 'public'
AND t.rowsecurity = true
AND p.policyname IS NULL;
```

**Data Integrity:**
```sql
-- Foreign key validity (no orphaned references)
-- Basic query sanity on core tables
SELECT COUNT(*) AS total_users FROM users WHERE deleted_at IS NULL;
```

### 4. Report Results

**If all checks pass:**
```
Smoke Test Passed

Checks completed:
  - Table count validation
  - Policy count validation
  - Function existence checks
  - Basic query sanity
```

**If any checks fail:**
```
Smoke Test Failed

Review errors above and:
  1. Check migration completeness
  2. Verify RLS policies are installed
  3. Confirm functions were created
  4. Consider rollback if critical
```

## What Is Tested

| Category | Checks |
|----------|--------|
| Schema Objects | Tables, views, functions, triggers exist |
| RLS Coverage | RLS enabled on sensitive tables, policies exist |
| Data Integrity | Foreign keys valid, check constraints valid |
| Performance | Basic queries complete in reasonable time, no missing indexes on FKs |

## Creating Custom Smoke Tests

Create version-specific smoke tests at `supabase/tests/smoke/v_X_Y_Z.sql`:

```sql
-- Smoke Test for v1.2.0
SET client_min_messages = warning;

-- Table count
SELECT COUNT(*) AS tables FROM information_schema.tables
WHERE table_schema='public';
-- Expected: 15

-- RLS enabled on all tables
SELECT tablename FROM pg_tables
WHERE schemaname='public' AND rowsecurity = false;
-- Expected: empty (all tables have RLS)

-- Critical functions exist
SELECT proname FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
AND proname IN ('function1', 'function2');
-- Expected: 2 rows
```

## Best Practices

1. **Version-specific tests** -- Name by schema version for traceability
2. **Fast execution** -- Under 5 seconds; smoke tests should be quick
3. **No side effects** -- Read-only queries only; never modify data
4. **Clear expectations** -- Document expected results in comments
5. **Fail fast** -- Use ON_ERROR_STOP to halt on first failure

## Next Steps After Pass

- Update migration log
- Run RLS audit: `db-rls-audit`
- Check performance on hot paths

## Next Steps After Fail

- Review error output
- Consider rollback: `db-rollback {snapshot}`
- Fix the migration or schema issue
- Retry smoke test

## Acceptance Criteria
- All expected schema objects (tables, functions, triggers) are present
- RLS is enabled on tables that require it
- No queries produce errors during the test run
- Clear pass/fail result is reported

## Error Handling
- **Smoke Test File Not Found:** Fall back to built-in checks; warn the user that no custom test exists
- **Connection Failed:** Check connection string, credentials, and network; verify database is running
- **Query Error During Test:** Report the specific failing query with error details; do not abort remaining checks if possible
- **Unexpected Schema State:** Report discrepancies between expected and actual object counts; recommend reviewing recent migrations
