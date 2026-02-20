---
task: db-dry-run
agent: data-engineer
inputs:
  - path (string, required): Path to SQL migration file
  - database_url (string, required): PostgreSQL connection URL (from environment)
outputs:
  - validation_result (boolean): Whether the dry-run passed or failed
  - error_details (string, optional): Error message and line number if failed
---

# Migration Dry-Run

## Purpose
Execute a migration inside a `BEGIN...ROLLBACK` transaction to validate SQL syntax, dependency ordering, and constraint correctness without making any permanent changes to the database.

## Prerequisites
- Database connection is established and accessible via `$DATABASE_URL`
- Migration file exists at the specified path
- `psql` is available on the system

## Steps

### 1. Confirm Migration File

Ask the user to confirm:
- Migration file path: `{path}`
- Purpose of this migration
- Expected changes (tables, functions, triggers, etc.)

### 2. Execute Dry-Run

Run the migration inside a transaction that will be rolled back:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
BEGIN;
\echo 'Starting dry-run...'
\i {path}
\echo 'Dry-run completed successfully - rolling back...'
ROLLBACK;
SQL
```

### 3. Report Results

**If successful:**
```
Dry-run completed without errors
- Migration syntax is valid
- No dependency or ordering issues detected
```

**If failed:**
```
Dry-run failed
Error: [error message]
Line: [line number if available]
Fix the migration and try again
```

## What This Validates

- SQL syntax correctness
- Object dependencies exist (referenced tables, types, etc.)
- Execution order is valid (tables before foreign keys, functions before triggers)
- No constraint violations with existing data

**Does NOT validate:**
- Data correctness after migration
- Query performance impact
- Application compatibility

## Next Steps After Success

1. Review the migration file one more time
2. Take a snapshot: `db-snapshot` with label `pre_migration`
3. Apply the migration: `db-apply-migration {path}`
4. Run smoke tests: `db-smoke-test`

## Acceptance Criteria
- Migration executes fully within the BEGIN...ROLLBACK block without errors
- No changes are persisted to the database after the dry-run
- Clear pass/fail result is reported with error details on failure

## Error Handling
- **"relation does not exist":** Missing table or view dependency; check if dependent objects need to be created first or are in a separate migration file
- **"function does not exist":** Function is called before its creation statement; reorder: tables, then functions, then triggers
- **"syntax error":** Check SQL syntax against PostgreSQL version; verify that dialect-specific features are supported
- **Connection Failed:** Check connection string, credentials, and network; retry with exponential backoff (max 3 attempts)
- **Transaction Rollback Error:** If the ROLLBACK itself fails, the connection will be terminated and no changes are persisted
