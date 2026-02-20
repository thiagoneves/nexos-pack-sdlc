---
task: db-run-sql
agent: data-engineer
inputs:
  - sql: Either a file path to a .sql file or an inline SQL statement
outputs:
  - execution_result: Query output, rows affected, execution time
  - output_log: Full output saved to /tmp/sql_output.txt
---

# Run SQL

## Purpose
Execute a SQL file or inline SQL statement against the database with transaction safety, destructive operation detection, and execution timing.

## Prerequisites
- `SUPABASE_DB_URL` environment variable set
- PostgreSQL client tools (psql) installed
- Database connection verified (run db-env-check first if unsure)

## Steps

### 1. Determine Input Type

Check if input is file or inline SQL:

```bash
if [ -f "{sql}" ]; then
  echo "Mode: File"
  SQL_FILE="{sql}"
  SQL_MODE="file"
else
  echo "Mode: Inline SQL"
  SQL_MODE="inline"
  SQL_CONTENT="{sql}"
fi
```

### 2. Preview SQL

Show what will be executed:

```bash
echo "=========================================="
echo "SQL TO BE EXECUTED:"
echo "=========================================="

if [ "$SQL_MODE" = "file" ]; then
  cat "$SQL_FILE"
else
  echo "$SQL_CONTENT"
fi

echo "=========================================="
```

### 3. Safety Checks

Warn about dangerous operations:

```bash
DANGEROUS_PATTERNS="DROP TABLE|TRUNCATE|DELETE FROM.*WHERE.*1=1|UPDATE.*WHERE.*1=1"

if echo "$SQL_CONTENT" | grep -Eiq "$DANGEROUS_PATTERNS"; then
  echo "WARNING: Potentially destructive operation detected!"
  echo ""
  echo "Detected patterns:"
  echo "$SQL_CONTENT" | grep -Ei "$DANGEROUS_PATTERNS"
  echo ""
  echo "Continue? Type 'I UNDERSTAND THE RISKS' to proceed:"
fi
```

### 4. Transaction Mode Selection

Choose transaction handling:

| Mode | Description | Use Case |
|------|------------|----------|
| **auto** | Wrap in BEGIN/COMMIT (rolls back on error) | Safe for modifications |
| **manual** | Execute as-is (file may have own transaction control) | Scripts with multiple transactions |
| **read** | Read-only transaction | Safe for queries/exploration |

### 5. Execute SQL

Run with selected transaction mode and timing:

```bash
if [ "$TRANSACTION_MODE" = "auto" ]; then
  (
    echo "BEGIN;"
    if [ "$SQL_MODE" = "file" ]; then cat "$SQL_FILE"; else echo "$SQL_CONTENT"; fi
    echo "COMMIT;"
  ) | psql "$SUPABASE_DB_URL" \
      -v ON_ERROR_STOP=1 \
      --echo-errors \
      2>&1 | tee /tmp/sql_output.txt

elif [ "$TRANSACTION_MODE" = "read" ]; then
  (
    echo "BEGIN TRANSACTION READ ONLY;"
    if [ "$SQL_MODE" = "file" ]; then cat "$SQL_FILE"; else echo "$SQL_CONTENT"; fi
    echo "COMMIT;"
  ) | psql "$SUPABASE_DB_URL" \
      -v ON_ERROR_STOP=1 \
      2>&1 | tee /tmp/sql_output.txt

else
  if [ "$SQL_MODE" = "file" ]; then
    psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f "$SQL_FILE" \
      2>&1 | tee /tmp/sql_output.txt
  else
    psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -c "$SQL_CONTENT" \
      2>&1 | tee /tmp/sql_output.txt
  fi
fi

EXIT_CODE=$?
```

### 6. Check Results

Display execution summary:

```bash
if [ $EXIT_CODE -eq 0 ]; then
  echo "SUCCESS"
else
  echo "FAILED (Exit code: $EXIT_CODE)"
  echo "Error output saved to: /tmp/sql_output.txt"
  exit $EXIT_CODE
fi
```

Parse rows affected and execution time from output if available.

## Usage Examples

### Run SQL File
```bash
# Execute a migration file
db-run-sql supabase/migrations/20240101_add_users.sql
```

### Inline Query
```bash
db-run-sql "SELECT COUNT(*) FROM users WHERE created_at > NOW() - INTERVAL '7 days'"
```

### Multi-Line Inline
```bash
db-run-sql "
  UPDATE users
  SET last_login = NOW()
  WHERE id = 'user-123'
  RETURNING *;
"
```

### Complex Script
```bash
db-run-sql "
  DO $$
  DECLARE
    user_count INTEGER;
  BEGIN
    SELECT COUNT(*) INTO user_count FROM users;
    RAISE NOTICE 'Total users: %', user_count;
  END $$;
"
```

## Safety Features

### Destructive Operation Detection
Automatically warns for: `DROP TABLE`, `TRUNCATE`, `DELETE FROM ... WHERE 1=1`, `UPDATE ... WHERE 1=1`

### Transaction Modes
- **Auto Mode (Recommended):** Wraps in BEGIN/COMMIT with automatic rollback on error
- **Manual Mode:** For files with their own transaction control or multiple transactions
- **Read Mode:** Read-only transaction, cannot modify data

### Error Handling
- `ON_ERROR_STOP=1` stops on first error
- Transaction rolls back on error (auto mode)
- Full error output preserved

## Advanced Options

### Enable Timing
```bash
psql "$SUPABASE_DB_URL" << 'EOF'
\timing on
{your_sql_here}
EOF
```

### Verbose Output
```bash
psql "$SUPABASE_DB_URL" --echo-all -f script.sql
```

### Save Output to File
```bash
psql "$SUPABASE_DB_URL" -f script.sql > output.txt 2>&1
```

## Common SQL Operations

### Query Data
```sql
SELECT id, email, created_at
FROM users
WHERE created_at > NOW() - INTERVAL '1 day'
ORDER BY created_at DESC
LIMIT 10;
```

### Update Records
```sql
UPDATE users
SET last_login = NOW(), login_count = login_count + 1
WHERE id = 'user-123'
RETURNING *;
```

### Data Analysis
```sql
SELECT
  DATE_TRUNC('day', created_at) AS day,
  COUNT(*) AS new_users,
  COUNT(*) FILTER (WHERE email_verified) AS verified
FROM users
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY day
ORDER BY day DESC;
```

## psql Meta-Commands

Useful commands when in psql interactive mode:

```
\dt              -- List tables
\d table_name    -- Describe table
\df              -- List functions
\dv              -- List views
\l               -- List databases
\timing on       -- Enable query timing
\x on            -- Expanded display mode
\q               -- Quit
\?               -- Help
```

## Error Handling
- **Syntax error:** Review SQL syntax; check for missing semicolons, unmatched quotes, or reserved word conflicts
- **Relation does not exist:** Table or view not found; check spelling and schema qualification
- **Column does not exist:** Verify column name against table definition
- **Permission denied:** Ensure the connection role has appropriate grants
- **Transaction rollback:** Check constraint violations; review the error message for specifics
- **Connection timeout:** Verify SUPABASE_DB_URL and network connectivity

## Security Notes

- Never run untrusted SQL without review
- Use read-only mode for untrusted queries
- Be careful with dynamic SQL
- Consider using prepared statements for user input

## References

- [PostgreSQL psql Documentation](https://www.postgresql.org/docs/current/app-psql.html)
- [PostgreSQL SQL Commands](https://www.postgresql.org/docs/current/sql-commands.html)
