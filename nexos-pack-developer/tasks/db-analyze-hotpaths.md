---
task: db-analyze-hotpaths
agent: data-engineer
inputs:
  - queries_file (optional): Path to file with labeled queries to analyze
outputs:
  - performance_report: Markdown report at supabase/docs/performance-analysis-{timestamp}.md
  - index_recommendations: List of CREATE INDEX statements
---

# Analyze Hot Query Paths

## Purpose
Run EXPLAIN ANALYZE on common or critical queries to identify performance issues, generate index recommendations, and produce a detailed performance analysis report.

## Prerequisites
- pg_stat_statements extension enabled (default in Supabase)
- Sufficient database activity to populate statistics
- For index_advisor: index_advisor extension (Supabase Pro+)
- `SUPABASE_DB_URL` environment variable set
- PostgreSQL client tools (psql) installed

## Steps

### 1. Enable Required Extensions

Ensure performance monitoring is available:

```bash
echo "Enabling performance extensions..."

psql "$SUPABASE_DB_URL" << 'EOF'
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS index_advisor;
SELECT 'Extensions ready' AS status;
EOF

echo "Extensions enabled"
```

### 2. Identify Hot Queries

If no `queries_file` is provided, find slowest queries from pg_stat_statements:

```bash
echo "Finding slow queries from pg_stat_statements..."

psql "$SUPABASE_DB_URL" << 'EOF'
SELECT
  query,
  calls,
  ROUND(total_exec_time::numeric, 2) AS total_time_ms,
  ROUND(mean_exec_time::numeric, 2) AS mean_time_ms,
  ROUND(max_exec_time::numeric, 2) AS max_time_ms,
  ROUND((100 * total_exec_time / SUM(total_exec_time) OVER ())::numeric, 2) AS pct_total_time
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
  AND query NOT LIKE '%pg_catalog%'
ORDER BY mean_exec_time DESC
LIMIT 20;
EOF
```

Prompt user to select query numbers to analyze (comma-separated) or type 'all' to analyze all.

### 3. Run EXPLAIN ANALYZE with BUFFERS

For each selected query, run comprehensive analysis:

```bash
psql "$SUPABASE_DB_URL" << 'EOF'
EXPLAIN (
  ANALYZE true,
  BUFFERS true,
  VERBOSE true,
  COSTS true,
  TIMING true
)
{actual_query};
EOF
```

**BUFFERS Legend:**
- `shared hit` = blocks found in buffer cache (good)
- `shared read` = blocks read from disk (bad if high)
- `temp read/written` = temporary files (bad if present)

### 4. Generate Index Recommendations

Use index_advisor extension (Supabase-specific):

```bash
psql "$SUPABASE_DB_URL" << 'EOF'
SELECT *
FROM index_advisor('{actual_query}');
EOF
```

### 5. Analyze Results

Identify common performance issues using this checklist:

| Issue | Look For | Problem If | Fix |
|-------|----------|-----------|-----|
| Sequential Scans | `Seq Scan on table_name` | Large tables (>1000 rows) + filter removes many rows | Add index on filter columns |
| Row Count Mismatches | `rows=XXXX` (estimated) vs `actual rows=YYYY` | Estimate differs by >10x from actual | `ANALYZE table_name;` (update statistics) |
| Buffer Cache Misses | `shared read` in BUFFERS output | High compared to `shared hit` | Increase shared_buffers, optimize query, add indexes |
| Temporary Files | `temp read` or `temp written` in BUFFERS | Query using disk for sorting/hashing | Increase work_mem, optimize query, add indexes |
| Nested Loops | `Nested Loop` with high row counts | Loops=10000+ iterations | Add indexes on join columns, consider Hash Join |

### 6. Create Analysis Report

Generate markdown report with findings at `supabase/docs/performance-analysis-{timestamp}.md`:

```markdown
# Query Performance Analysis

**Date**: {date}
**Database**: [redacted]

## Executive Summary
- Queries analyzed: {count}
- Avg execution time: {avg_time}ms
- Indexes recommended: {index_count}

## Detailed Findings

### Query 1: {query_label}
**Current Performance:**
- Mean execution time: {mean_time}ms
- Calls: {calls}
- % of total time: {pct_time}%

**EXPLAIN ANALYZE Output:**
{explain_output}

**Issues Identified:**
1. {issue_1}
2. {issue_2}

**Recommended Indexes:**
{recommended_indexes}

**Expected Improvement:** {estimated_improvement}

## Action Items
- [ ] Create migration for recommended indexes
- [ ] Update statistics: ANALYZE {tables}
- [ ] Re-run analysis after changes
- [ ] Monitor with pg_stat_statements
```

## Common Query Patterns to Check

### Pattern 1: User-Specific Data
```sql
SELECT * FROM posts WHERE user_id = 'xxx';
-- Check: Index on user_id exists?
-- Verify: (select auth.uid()) = user_id is wrapped in SELECT for RLS performance
```

### Pattern 2: Joins
```sql
SELECT p.*, u.name
FROM posts p
JOIN users u ON p.user_id = u.id;
-- Check: Index on posts(user_id)? Index on users(id) should exist (PK)
```

### Pattern 3: Filters + Sorts
```sql
SELECT * FROM posts
WHERE status = 'published'
ORDER BY created_at DESC
LIMIT 10;
-- Check: Index on (status, created_at DESC)?
```

### Pattern 4: Aggregations
```sql
SELECT user_id, COUNT(*)
FROM posts
GROUP BY user_id;
-- Check: Index on user_id? Or denormalize count?
```

## BUFFERS Output Interpretation

**Good (Cached):**
```
Buffers: shared hit=100
```
= 100 blocks found in cache (no disk I/O)

**Bad (Disk Reads):**
```
Buffers: shared hit=10 read=990
```
= Only 10 blocks cached, 990 read from disk

**Very Bad (Temp Files):**
```
Buffers: temp read=5000 written=5000
```
= Query spilled to disk (work_mem too small)

**Target:** Maximize "shared hit", minimize "shared read", zero "temp"

## Supabase-Specific Notes

### Using with Supabase Client (PostgREST)

Enable explain in SQL editor first (dev only):
```sql
ALTER DATABASE postgres SET app.settings.explain TO 'on';
```

Then use in code:
```javascript
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .explain({ analyze: true, buffers: true })
```

### Supabase Studio Integration

- Navigate to **Query Performance Report**
- Select slow query
- Click **"indexes" tab** for index_advisor recommendations
- One-click to create migration

## Best Practices

1. **Always use BUFFERS**: `EXPLAIN (ANALYZE, BUFFERS)`
2. **Look for patterns**: One slow query often indicates a systemic issue
3. **Update statistics**: Run `ANALYZE` after significant data changes
4. **Test indexes**: Create indexes CONCURRENTLY in production
5. **Re-measure**: After optimizations, re-run this analysis
6. **RLS Performance**: Wrap auth functions in SELECT for significant speedup

## Error Handling
- **Connection Failed:** Check SUPABASE_DB_URL, credentials, and network connectivity
- **Extension Not Available:** pg_stat_statements requires superuser to enable; index_advisor requires Supabase Pro+
- **Empty pg_stat_statements:** Insufficient database activity; run workload first then re-analyze
- **Query Timeout on EXPLAIN ANALYZE:** Set statement_timeout before running; reduce query complexity

## References

- [PostgreSQL EXPLAIN Documentation](https://www.postgresql.org/docs/current/sql-explain.html)
- [Supabase Query Optimization](https://supabase.com/docs/guides/database/query-optimization)
- [Supabase RLS Performance](https://supabase.com/docs/guides/troubleshooting/rls-performance-and-best-practices-Z5Jjwv)
- [index_advisor Extension](https://supabase.com/docs/guides/database/extensions/index_advisor)
