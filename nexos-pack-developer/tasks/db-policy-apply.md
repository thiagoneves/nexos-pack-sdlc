---
task: db-policy-apply
agent: data-engineer
inputs:
  - table: Target table name
  - mode: Policy type - 'kiss' or 'granular'
outputs:
  - migration_file: SQL migration at supabase/migrations/{TS}_rls_{mode}__{table}.sql
  - applied_policies: List of RLS policies created on the table
---

# Apply RLS Policy Template

## Purpose
Install KISS (single policy for all operations) or granular (per-operation) RLS policies on a specified table, with performance-optimized auth.uid() caching and automatic migration file generation.

## Prerequisites
- Table must exist in the `public` schema
- Table must have a `user_id UUID` column (for user-based policies) or `tenant_id` column (for tenant-based policies)
- Indexes on all policy filter columns (e.g., `CREATE INDEX idx_{table}_user_id ON {table}(user_id);`)
- `SUPABASE_DB_URL` environment variable set
- PostgreSQL client tools (psql) installed

## Steps

### 1. Validate Inputs

Check table exists and mode is valid:

```bash
echo "Validating inputs..."

psql "$SUPABASE_DB_URL" -c \
"SELECT EXISTS (
  SELECT 1 FROM information_schema.tables
  WHERE table_schema = 'public' AND table_name = '{table}'
);" | grep -q t || {
  echo "Table '{table}' not found"
  exit 1
}

if [[ "{mode}" != "kiss" && "{mode}" != "granular" ]]; then
  echo "Invalid mode: {mode}. Use 'kiss' or 'granular'"
  exit 1
fi
```

### 2. Check Existing Policies

Display current RLS status:

```bash
psql "$SUPABASE_DB_URL" << EOF
SELECT
  schemaname, tablename, policyname, permissive,
  roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = '{table}';
EOF

psql "$SUPABASE_DB_URL" -c \
"SELECT relrowsecurity FROM pg_class WHERE relname = '{table}';"
```

### 3. Confirm Policy Application

Present the policy that will be applied based on mode.

**If mode = 'kiss':**
- Enable RLS
- Single policy: users can only access their own rows
- Uses: `(select auth.uid()) = user_id` (performance optimized)
- Applies to: SELECT, INSERT, UPDATE, DELETE

**If mode = 'granular':**
- Enable RLS
- Separate policies for each operation (SELECT, INSERT, UPDATE, DELETE)
- Fine-grained control per operation

### 4. Generate Policy SQL

**KISS Mode:**
```sql
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "{table}_policy" ON {table};

CREATE POLICY "{table}_policy"
  ON {table}
  FOR ALL
  TO authenticated
  USING (
    (select auth.uid()) IS NOT NULL AND
    (select auth.uid()) = user_id
  )
  WITH CHECK (
    (select auth.uid()) IS NOT NULL AND
    (select auth.uid()) = user_id
  );

COMMENT ON POLICY "{table}_policy" ON {table} IS
  'KISS policy: users can only access their own rows (performance optimized with cached auth.uid())';
```

**Granular Mode (Performance Optimized):**
```sql
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "{table}_select" ON {table};
DROP POLICY IF EXISTS "{table}_insert" ON {table};
DROP POLICY IF EXISTS "{table}_update" ON {table};
DROP POLICY IF EXISTS "{table}_delete" ON {table};

CREATE POLICY "{table}_select"
  ON {table} FOR SELECT TO authenticated
  USING ((select auth.uid()) IS NOT NULL AND (select auth.uid()) = user_id);

CREATE POLICY "{table}_insert"
  ON {table} FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) IS NOT NULL AND (select auth.uid()) = user_id);

CREATE POLICY "{table}_update"
  ON {table} FOR UPDATE TO authenticated
  USING ((select auth.uid()) IS NOT NULL AND (select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) IS NOT NULL AND (select auth.uid()) = user_id);

CREATE POLICY "{table}_delete"
  ON {table} FOR DELETE TO authenticated
  USING ((select auth.uid()) IS NOT NULL AND (select auth.uid()) = user_id);
```

### 5. Create Migration File

Save policy SQL to migration file:

```bash
TS=$(date +%Y%m%d%H%M%S)
MIGRATION_FILE="supabase/migrations/${TS}_rls_${mode}__${table}.sql"
mkdir -p supabase/migrations
```

Wrap the generated SQL in a `BEGIN; ... COMMIT;` block and write to the migration file.

### 6. Apply Migration

Execute the migration against the database. Create snapshots before applying and verify after.

### 7. Test Policies

Verify policies work correctly:

```bash
# Test 1: Anonymous user should see nothing
psql "$SUPABASE_DB_URL" << EOF
SET ROLE anon;
SELECT COUNT(*) AS anon_count FROM {table};
RESET ROLE;
EOF

# Test 2: Authenticated user should see only their rows
# Manual testing recommended for each operation (SELECT, INSERT, UPDATE, DELETE)
```

## Common Patterns

### Public Read, Authenticated Write (Performance Optimized)
```sql
CREATE POLICY "{table}_select" ON {table}
  FOR SELECT TO public
  USING (true);

CREATE POLICY "{table}_write" ON {table}
  FOR ALL TO authenticated
  USING (
    (select auth.uid()) IS NOT NULL AND
    (select auth.uid()) = user_id
  )
  WITH CHECK (
    (select auth.uid()) IS NOT NULL AND
    (select auth.uid()) = user_id
  );
```

### Tenant-Based (Performance Optimized)
```sql
CREATE POLICY "{table}_tenant" ON {table}
  FOR ALL TO authenticated
  USING (
    (select auth.uid()) IS NOT NULL AND
    tenant_id IN (
      SELECT tenant_id FROM user_tenants
      WHERE user_id = (select auth.uid())
    )
  );
```

## Performance Tips

**Critical Performance Optimization -- always wrap `auth.uid()` in a SELECT statement:**
```sql
-- SLOW (called for EVERY row)
USING (auth.uid() = user_id)

-- FAST (cached per statement)
USING ((select auth.uid()) = user_id)
```

Without SELECT, PostgreSQL calls `auth.uid()` for every row. With SELECT, PostgreSQL caches the result for the entire statement, yielding up to 10,000x improvement on large tables.

**Index Recommendations:**
- Always index columns used in policies (e.g., `user_id`, `tenant_id`)
- `CREATE INDEX idx_{table}_user_id ON {table}(user_id);`

## Security Warnings

### Do NOT Use raw_user_meta_data in Policies
```sql
-- DANGEROUS - User can modify this data!
USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- SAFE - Only server can modify app_metadata
USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
```

### Auth NULL Check
Always check if user is authenticated:
```sql
-- Missing NULL check (fails silently for anon users)
USING (auth.uid() = user_id)

-- Explicit authentication check
USING (
  (select auth.uid()) IS NOT NULL AND
  (select auth.uid()) = user_id
)
```

## KISS vs Granular

| Aspect | KISS | Granular |
|--------|------|----------|
| Policies | Single for all operations | Separate per operation |
| Simplicity | Easier to understand | More verbose |
| Flexibility | Less flexible | Fine-grained control per operation |

## Error Handling
- **Table not found:** Verify table name and schema; check spelling
- **Missing user_id column:** Table must have a `user_id` column for user-based policies; adapt column name for tenant-based patterns
- **Existing policy conflict:** Existing policies with same names will be dropped and recreated
- **auth.uid() not available:** Verify Supabase auth is configured; check that the connection uses the correct role
- **Migration rollback needed:** Use rollback scripts or `ALTER TABLE {table} DISABLE ROW LEVEL SECURITY;` (dev only)

## RLS Debugging (Dev Only)
```sql
-- Temporarily disable RLS for debugging (DANGEROUS - dev only!)
ALTER TABLE {table} DISABLE ROW LEVEL SECURITY;

-- Re-enable when done
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;
```
