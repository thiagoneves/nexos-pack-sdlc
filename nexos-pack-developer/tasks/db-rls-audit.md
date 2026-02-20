---
task: db-rls-audit
agent: data-engineer
inputs:
  - database_url (string, required): PostgreSQL connection URL (from environment)
outputs:
  - audit_report (string): Full RLS coverage report with tables, policies, and recommendations
  - tables_without_rls (array): List of public tables with RLS disabled
  - coverage_summary (object): Counts of total tables, RLS-enabled, and RLS-disabled
---

# RLS Audit

## Purpose
Report all public tables with their Row Level Security (RLS) status and list all associated policies. Identifies security gaps where tables lack RLS or have incomplete policy coverage, and provides actionable recommendations.

## Prerequisites
- Database connection is established and accessible via `$DATABASE_URL`
- `psql` is available on the system
- Database has public schema tables to audit

## Steps

### 1. Run Comprehensive RLS Audit

Execute the full audit query:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
\echo '=== RLS Coverage Audit ==='
\echo ''

-- Tables with/without RLS and their policies
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

\echo ''
\echo '=== Summary ==='

SELECT
  COUNT(*) AS total_tables,
  COUNT(*) FILTER (WHERE rowsecurity) AS rls_enabled,
  COUNT(*) FILTER (WHERE NOT rowsecurity) AS rls_disabled
FROM pg_tables
WHERE schemaname='public';

\echo ''
\echo '=== Tables Without RLS (Security Risk) ==='

SELECT tablename
FROM pg_tables
WHERE schemaname='public'
AND rowsecurity = false
ORDER BY tablename;

\echo ''
\echo '=== Policy Coverage ==='

SELECT
  t.tablename,
  COUNT(p.policyname) AS policy_count,
  ARRAY_AGG(p.cmd) AS commands_covered
FROM pg_tables t
LEFT JOIN pg_policies p ON p.tablename = t.tablename AND p.schemaname = 'public'
WHERE t.schemaname = 'public'
AND t.rowsecurity = true
GROUP BY t.tablename
ORDER BY policy_count, t.tablename;

SQL
```

### 2. Interpret Results

**RLS Status:**
- **ENABLED** -- Table has RLS active (good)
- **DISABLED** -- Table has no RLS (security risk)

**Policy Coverage:**
- **Good coverage:** 1 policy with `FOR ALL` (KISS approach), OR 4 policies covering SELECT, INSERT, UPDATE, DELETE (granular)
- **Incomplete coverage:** Enabled RLS but 0 policies = nobody can access; 1-3 granular policies = some operations not covered
- **No coverage:** RLS disabled = full access without restrictions

### 3. Provide Recommendations

Based on audit results, recommend fixes for each issue found.

## Common Issues and Fixes

### Table Has RLS Enabled but No Policies

**Impact:** Table is inaccessible to all users (locked down completely).

**Fix:** Add a KISS (Keep It Simple Security) policy:

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY "table_name_all"
ON table_name FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

### Table Has No RLS

**Impact:** Table is accessible without restrictions -- security vulnerability.

**Fix:** Enable RLS and add policies:

```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
-- Then add appropriate policies
```

### Incomplete Policy Coverage (Granular)

**Impact:** RLS enabled with 1-3 policies that do not cover all operations.

**Fix:** Add missing operation-specific policies or switch to the KISS approach with a single `FOR ALL` policy.

## Policy Patterns

### For Public Data (Publicly Readable)
```sql
CREATE POLICY "public_read"
ON table_name FOR SELECT
TO anon, authenticated
USING (true);

CREATE POLICY "authenticated_write"
ON table_name FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
```

### For User-Owned Data (KISS Policy)
```sql
CREATE POLICY "user_owns"
ON table_name FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

### For Multi-Tenant Data (Organization-Scoped)
```sql
CREATE POLICY "org_isolation"
ON table_name FOR ALL
TO authenticated
USING (org_id = (auth.jwt() ->> 'org_id')::uuid)
WITH CHECK (org_id = (auth.jwt() ->> 'org_id')::uuid);
```

## Best Practices

**Do:**
- Enable RLS on all tables with sensitive data
- Use KISS policies for simple owner-based access
- Document why RLS is disabled if intentional
- Test policies with real user contexts
- Index columns used in RLS policies (e.g., user_id, org_id)
- Run this audit after every migration

**Do not:**
- Enable RLS without adding at least one policy
- Use the service role to bypass RLS in application code
- Forget to test negative cases (users who should NOT have access)

## Integration with Workflow

Run the RLS audit at these points:
1. After applying migrations: `db-smoke-test` then `db-rls-audit`
2. Before production deployment: `db-rls-audit`
3. During regular security reviews: `db-rls-audit`
4. When adding new tables: `db-rls-audit`

## Acceptance Criteria
- All public tables are listed with their RLS status (enabled/disabled)
- All policies for RLS-enabled tables are listed with their commands and roles
- Summary counts are provided (total tables, RLS-enabled, RLS-disabled)
- Tables without RLS are flagged as security risks
- Actionable recommendations are provided for each issue found

## Error Handling
- **Connection Failed:** Check connection string, credentials, and network; verify database is running
- **No Public Tables Found:** Database may be empty or migrations have not been applied; suggest running migrations first
- **Permission Denied on pg_policies:** Connection may lack sufficient privileges; use a connection with at least read access to system catalogs
- **Unexpected Policy Configuration:** Report the configuration as-is and recommend manual review by a database administrator
