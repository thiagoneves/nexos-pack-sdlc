---
task: db-env-check
agent: data-engineer
inputs:
  - SUPABASE_DB_URL: Environment variable with PostgreSQL connection string
outputs:
  - validation_result: Pass/fail status for each environment check
---

# DB Environment Check

## Purpose
Validate the environment for database operations without leaking secrets. Checks required environment variables, client tools, SSL configuration, and database connectivity.

## Prerequisites
- Access to the shell environment where database operations will run
- PostgreSQL client tools should be installed (psql, pg_dump)

## Steps

### 1. Validate Required Environment Variables

```bash
test -n "$SUPABASE_DB_URL" || { echo "Missing SUPABASE_DB_URL"; exit 1; }
echo "SUPABASE_DB_URL present (redacted)"
```

### 2. Check SSL Mode and Pooler

```bash
case "$SUPABASE_DB_URL" in
  *"sslmode="*) echo "sslmode present";;
  *) echo "Consider adding sslmode=require";;
esac

echo "$SUPABASE_DB_URL" | grep -q "pooler" && echo "Using pooler" || echo "Consider pooler host"
```

### 3. Check Client Versions

```bash
psql --version || { echo "psql missing"; exit 1; }
pg_dump --version || { echo "pg_dump missing"; exit 1; }
echo "PostgreSQL client tools available"
```

### 4. Check Server Connectivity

```bash
PSQL="psql \"$SUPABASE_DB_URL\" -v ON_ERROR_STOP=1 -t -c"
eval $PSQL "SELECT version();" > /dev/null && echo "Database connection successful"
```

## Success Criteria

- All environment variables present
- PostgreSQL client tools installed
- Database connection successful
- SSL and pooler configuration validated

## Error Handling
- **Missing SUPABASE_DB_URL:** Set the variable in `.env` file. Get the connection string from Supabase Dashboard > Settings > Database
- **psql not installed:** Install PostgreSQL client tools via your package manager (e.g., `brew install libpq` on macOS, `apt install postgresql-client` on Ubuntu)
- **Connection failed:** Verify the connection string, check network access, ensure the database is running, and confirm SSL mode is correct
- **Missing sslmode:** Add `?sslmode=require` to the connection string for secure connections
- **Not using pooler:** Switch to the pooler connection string (port 6543) for better connection management
