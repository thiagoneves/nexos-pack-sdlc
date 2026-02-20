---
task: db-load-csv
agent: data-engineer
inputs:
  - table: Target table name
  - csv_file: Path to CSV file
outputs:
  - import_summary: Row count, duration, validation results
---

# Load CSV Data Safely

## Purpose
Import CSV data into a PostgreSQL table using the COPY command with a staging table for validation, data type casting, and idempotent upsert merging.

## Prerequisites
- Target table must exist in the `public` schema
- CSV file must be UTF-8 encoded with a header row
- `SUPABASE_DB_URL` environment variable set
- PostgreSQL client tools (psql) installed

## Steps

### 1. Validate Inputs

Check file exists and table exists:

```bash
echo "Validating inputs..."

[ -f "{csv_file}" ] || {
  echo "File not found: {csv_file}"
  exit 1
}

psql "$SUPABASE_DB_URL" -c \
"SELECT EXISTS (
  SELECT 1 FROM information_schema.tables
  WHERE table_schema = 'public' AND table_name = '{table}'
);" | grep -q t || {
  echo "Table '{table}' not found"
  exit 1
}

ROW_COUNT=$(wc -l < "{csv_file}" | tr -d ' ')
echo "CSV file: {csv_file} ($ROW_COUNT rows)"
echo "Target table: {table}"
```

### 2. Preview CSV Structure

Show first few rows for confirmation:

```bash
echo "CSV Preview (first 5 rows):"
head -n 5 "{csv_file}"
```

Confirm with user before proceeding.

### 3. Create Staging Table

Import to staging first for validation:

```bash
psql "$SUPABASE_DB_URL" << 'EOF'
CREATE TEMP TABLE {table}_staging (LIKE {table} INCLUDING ALL);
SELECT 'Staging table created' AS status;
EOF
```

### 4. COPY Data to Staging

Use PostgreSQL COPY command (fastest method):

```bash
psql "$SUPABASE_DB_URL" << 'EOF'
\copy {table}_staging FROM '{csv_file}' WITH (
  FORMAT csv,
  HEADER true,
  DELIMITER ',',
  QUOTE '"',
  ESCAPE '"',
  NULL 'NULL'
);
EOF
```

For server-side files, use `COPY ... FROM '/path/to/file.csv'` instead of `\copy`.

### 5. Validate Data

Run validation checks before merging:

```bash
psql "$SUPABASE_DB_URL" << 'EOF'
-- Check row count
SELECT COUNT(*) AS staged_rows FROM {table}_staging;

-- Check for NULL in required columns
SELECT COUNT(*) AS null_ids FROM {table}_staging WHERE id IS NULL;

-- Check for duplicates
SELECT id, COUNT(*) AS duplicates
FROM {table}_staging
GROUP BY id
HAVING COUNT(*) > 1;

-- Validation summary
SELECT
  CASE
    WHEN EXISTS (SELECT 1 FROM {table}_staging WHERE id IS NULL) THEN
      'FAIL: NULL ids found'
    WHEN EXISTS (SELECT 1 FROM {table}_staging GROUP BY id HAVING COUNT(*) > 1) THEN
      'FAIL: Duplicate ids found'
    ELSE
      'PASS: All validations passed'
  END AS validation_status;
EOF
```

Confirm with user before proceeding to merge.

### 6. Merge to Target Table

Use UPSERT pattern for idempotency:

```bash
psql "$SUPABASE_DB_URL" << 'EOF'
BEGIN;

INSERT INTO {table} (id, name, created_at, ...)
SELECT
  id::uuid,
  name,
  created_at::timestamptz,
  ...
FROM {table}_staging
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  created_at = EXCLUDED.created_at,
  updated_at = NOW();

SELECT
  (SELECT COUNT(*) FROM {table}) AS final_count,
  (SELECT COUNT(*) FROM {table}_staging) AS imported_count;

COMMIT;
EOF
```

### 7. Cleanup

Drop staging table:

```bash
psql "$SUPABASE_DB_URL" << 'EOF'
DROP TABLE IF EXISTS {table}_staging;
EOF
```

## CSV Format Requirements

- UTF-8 encoding
- Consistent delimiters (comma recommended)
- Header row with column names matching target table
- Quoted strings if they contain delimiters

**Example:**
```csv
id,name,email,created_at
"user-1","John Doe","john@example.com","2024-01-01 00:00:00"
"user-2","Jane Smith","jane@example.com","2024-01-02 00:00:00"
```

## Handling Large Files

For CSV files > 100MB or > 1M rows:

1. **Split the file:**
   ```bash
   split -l 100000 large.csv chunk_
   ```

2. **Import in batches:**
   ```bash
   for file in chunk_*; do
     # run load-csv for each chunk
   done
   ```

3. **Or use streaming COPY:**
   ```bash
   cat large.csv | psql "$SUPABASE_DB_URL" -c \
     "COPY {table} FROM STDIN WITH (FORMAT csv, HEADER true);"
   ```

## Data Type Conversion

Always cast from TEXT to proper types in the SELECT during merge:

```sql
SELECT
  id::uuid,
  amount::numeric(10,2),
  created_at::timestamptz,
  is_active::boolean,
  metadata::jsonb
FROM {table}_staging
```

## Performance Tips

1. **Disable triggers during bulk load:**
   ```sql
   ALTER TABLE {table} DISABLE TRIGGER ALL;
   -- Load data
   ALTER TABLE {table} ENABLE TRIGGER ALL;
   ```

2. **Drop indexes, load, recreate:**
   ```sql
   DROP INDEX idx_name;
   -- Load data
   CREATE INDEX CONCURRENTLY idx_name ON {table}(column);
   ```

3. **Use UNLOGGED tables for staging:**
   ```sql
   CREATE UNLOGGED TABLE {table}_staging (...);
   ```

4. **Batch commits for very large loads**

## Security Notes

- Never COPY from untrusted sources without validation
- Always use staging table first
- Validate data types and constraints before merging
- COPY is inherently safe against SQL injection
- Consider row-level security (RLS) when loading to Supabase

## Error Handling
- **Character encoding error (`invalid byte sequence for encoding "UTF8"`):** Convert the file with `iconv -f ISO-8859-1 -t UTF-8 input.csv > output.csv`
- **Unterminated CSV quoted field:** Adjust COPY parameters -- change DELIMITER, QUOTE, or ESCAPE characters
- **NOT NULL constraint violation:** Check CSV for empty values in required columns; define NULL representation in COPY with `NULL ''`
- **Duplicate key violation during merge:** The UPSERT pattern handles this; if using INSERT without ON CONFLICT, check for duplicates in staging first
- **File not found:** Verify the CSV file path; for `\copy` use client-side paths, for `COPY` use server-side paths

## References

- [PostgreSQL COPY Documentation](https://www.postgresql.org/docs/current/sql-copy.html)
- [psql \copy Command](https://www.postgresql.org/docs/current/app-psql.html)
