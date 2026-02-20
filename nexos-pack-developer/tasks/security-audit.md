---
task: security-audit
agent: data-engineer
inputs:
  - scope: Audit scope - 'rls', 'schema', or 'full'
outputs:
  - audit_report: RLS coverage, schema quality findings, and security best practices assessment
  - risk_items: Categorized list of critical, high, and medium priority issues
---

# Security Audit

## Purpose
Perform a comprehensive database security and quality audit covering RLS policy coverage, schema design quality, and security best practices. Consolidates RLS audit and schema audit into a single configurable task.

## Prerequisites
- `SUPABASE_DB_URL` environment variable set
- PostgreSQL client tools (psql) installed
- Database connection verified
- Tables exist in the `public` schema

## Steps

### 1. Select Audit Scope

Prompt user to select scope:

| Scope | Description | Duration |
|-------|------------|----------|
| **rls** | RLS policy coverage only | Quick |
| **schema** | Schema design quality only | Quick |
| **full** | Complete security audit (RLS + schema + best practices) | Comprehensive |

### 2. RLS Audit (scope: rls or full)

Report tables with/without RLS and list all policies:

```sql
-- Tables with/without RLS
WITH t AS (
  SELECT tablename, rowsecurity
  FROM pg_tables WHERE schemaname='public'
)
SELECT
  tablename,
  CASE WHEN rowsecurity THEN 'ENABLED' ELSE 'DISABLED' END AS rls_status,
  (SELECT json_agg(json_build_object(
    'policy', policyname,
    'cmd', cmd,
    'roles', roles,
    'qual', qual,
    'with_check', with_check
  ))
   FROM pg_policies p
   WHERE p.tablename=t.tablename
   AND p.schemaname='public') AS policies
FROM t
ORDER BY rowsecurity DESC, tablename;

-- RLS Summary
SELECT
  COUNT(*) AS total_tables,
  COUNT(*) FILTER (WHERE rowsecurity) AS rls_enabled,
  COUNT(*) FILTER (WHERE NOT rowsecurity) AS rls_disabled
FROM pg_tables
WHERE schemaname='public';

-- Tables Without RLS (Security Risk)
SELECT tablename
FROM pg_tables
WHERE schemaname='public'
AND rowsecurity = false
ORDER BY tablename;

-- Policy Coverage by Command
SELECT
  tablename,
  COUNT(*) FILTER (WHERE cmd='SELECT') AS select_policies,
  COUNT(*) FILTER (WHERE cmd='INSERT') AS insert_policies,
  COUNT(*) FILTER (WHERE cmd='UPDATE') AS update_policies,
  COUNT(*) FILTER (WHERE cmd='DELETE') AS delete_policies
FROM pg_policies
WHERE schemaname='public'
GROUP BY tablename
ORDER BY tablename;
```

### 3. Schema Audit (scope: schema or full)

Validate schema design quality and best practices:

```sql
-- 1. Tables Without Primary Keys (CRITICAL)
SELECT t.tablename
FROM pg_tables t
LEFT JOIN pg_constraint c ON c.conrelid = (t.schemaname||'.'||t.tablename)::regclass
  AND c.contype = 'p'
WHERE t.schemaname = 'public'
  AND c.conname IS NULL
ORDER BY t.tablename;

-- 2. Missing NOT NULL on Required Fields
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND is_nullable = 'YES'
  AND column_name IN ('email', 'user_id', 'created_at', 'updated_at', 'status')
ORDER BY table_name, column_name;

-- 3. Missing Foreign Key Constraints
SELECT
  c.table_name, c.column_name,
  'Missing FK to ' || REPLACE(c.column_name, '_id', 's') AS suggestion
FROM information_schema.columns c
LEFT JOIN information_schema.table_constraints tc
  ON tc.table_name = c.table_name AND tc.constraint_type = 'FOREIGN KEY'
LEFT JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_name = tc.constraint_name AND kcu.column_name = c.column_name
WHERE c.table_schema = 'public'
  AND c.column_name LIKE '%_id'
  AND c.column_name != 'id'
  AND kcu.column_name IS NULL
ORDER BY c.table_name, c.column_name;

-- 4. Missing Audit Timestamps (created_at, updated_at)
SELECT
  t.tablename,
  CASE WHEN created_col.column_name IS NULL THEN 'No created_at' ELSE 'OK' END AS created,
  CASE WHEN updated_col.column_name IS NULL THEN 'No updated_at' ELSE 'OK' END AS updated
FROM pg_tables t
LEFT JOIN information_schema.columns created_col
  ON created_col.table_name = t.tablename
  AND created_col.column_name = 'created_at' AND created_col.table_schema = 'public'
LEFT JOIN information_schema.columns updated_col
  ON updated_col.table_name = t.tablename
  AND updated_col.column_name = 'updated_at' AND updated_col.table_schema = 'public'
WHERE t.schemaname = 'public'
  AND (created_col.column_name IS NULL OR updated_col.column_name IS NULL)
ORDER BY t.tablename;

-- 5. Missing Indexes on Foreign Keys
SELECT
  t.tablename, c.column_name,
  'CREATE INDEX idx_' || t.tablename || '_' || c.column_name || ' ON ' || t.tablename || '(' || c.column_name || ');' AS suggested_index
FROM pg_tables t
JOIN information_schema.columns c ON c.table_name = t.tablename
LEFT JOIN pg_indexes i ON i.tablename = t.tablename
  AND i.indexdef LIKE '%' || c.column_name || '%'
WHERE t.schemaname = 'public'
  AND c.table_schema = 'public'
  AND c.column_name LIKE '%_id'
  AND c.column_name != 'id'
  AND i.indexname IS NULL
ORDER BY t.tablename, c.column_name;

-- Schema Audit Summary
SELECT
  (SELECT COUNT(*) FROM pg_tables WHERE schemaname='public') AS total_tables,
  (SELECT COUNT(DISTINCT tablename) FROM pg_policies WHERE schemaname='public') AS tables_with_policies,
  (SELECT COUNT(*) FROM pg_constraint WHERE contype='f') AS foreign_keys,
  (SELECT COUNT(*) FROM pg_indexes WHERE schemaname='public') AS total_indexes;
```

### 4. Security Best Practices Check (scope: full only)

Additional checks for the full audit:

```sql
-- 6. Potential PII/Sensitive Columns (Review for RLS)
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (
    column_name ILIKE '%password%'
    OR column_name ILIKE '%token%'
    OR column_name ILIKE '%secret%'
    OR column_name ILIKE '%ssn%'
    OR column_name ILIKE '%credit%'
    OR column_name ILIKE '%api_key%'
  )
ORDER BY table_name, column_name;

-- 7. Public Schema Permissions
SELECT
  schemaname, tablename, tableowner,
  hasindexes, hasrules, hastriggers
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

## Interpretation

### Critical Issues (Fix Immediately)
- **RLS Disabled:** Tables without RLS are publicly accessible
- **No Primary Keys:** Data integrity at risk
- **Sensitive Columns Exposed:** PII/secrets without RLS protection

### High Priority Issues (Fix Soon)
- **Missing Foreign Keys:** Data integrity and query performance
- **Missing NOT NULL:** Data quality issues
- **Missing Indexes on FKs:** Query performance degradation

### Medium Priority Issues (Technical Debt)
- **Missing Audit Timestamps:** Tracking challenges
- **Inconsistent Naming:** Maintainability issues

## Recommendations

**After RLS Audit:**
1. Enable RLS on all public tables: `ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;`
2. Create policies for all CRUD operations (use the db-policy-apply task)
3. Test policies with different user roles

**After Schema Audit:**
1. Add missing primary keys: `ALTER TABLE {table} ADD PRIMARY KEY (id);`
2. Add missing foreign keys: `ALTER TABLE {table} ADD FOREIGN KEY ({col}) REFERENCES {ref_table}(id);`
3. Add missing NOT NULL: `ALTER TABLE {table} ALTER COLUMN {col} SET NOT NULL;`
4. Create indexes on foreign keys: `CREATE INDEX idx_{table}_{col} ON {table}({col});`

## Sample Output

### RLS Audit
```
 tablename | rls_status |           policies
-----------+------------+-------------------------------
 users     | ENABLED    | [{"policy":"Users read own",...}]
 posts     | ENABLED    | [{"policy":"Public read",...}]
 secrets   | DISABLED   | null

 total_tables | rls_enabled | rls_disabled
--------------+-------------+--------------
           10 |           8 |            2
```

### Schema Audit
```
1. Tables Without Primary Keys (CRITICAL):
 tablename
-----------
 (0 rows)

2. Missing NOT NULL on Required Fields:
 table_name | column_name | data_type
------------+-------------+-----------
 users      | email       | text
```

## Error Handling
- **Connection failed:** Verify SUPABASE_DB_URL and network connectivity; run db-env-check first
- **Permission denied on system catalogs:** Ensure the connection role has read access to pg_tables, pg_policies, pg_constraint, and information_schema
- **Empty results for all checks:** Database may have no tables in the public schema; verify the schema name
- **Timeout on large databases:** Run individual scope (rls or schema) instead of full audit; consider filtering specific tables
