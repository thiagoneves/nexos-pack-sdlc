---
task: db-schema-audit
agent: data-engineer
workflow: brownfield-discovery (phase 2)
inputs: [system-architecture.md, database schema, migration files]
outputs: [SCHEMA.md, DB-AUDIT.md]
---

# Database Schema Audit

## Purpose

Audit the existing database schema for completeness, consistency, performance issues, and security concerns. This is the second phase of brownfield discovery and produces two documents: a schema reference (`SCHEMA.md`) and an audit report (`DB-AUDIT.md`) with prioritized findings and remediation recommendations.

This task evaluates the database against industry best practices across five dimensions: structural design, performance optimization, security posture, data integrity, and naming conventions. The output enables informed decision-making about schema improvements and provides a baseline for future development.

## Prerequisites

- System architecture document from phase 1 (`system-architecture.md`) is available.
- A database exists in the project (detected during phase 1).
- Access to schema definitions through at least one of: migration files, ORM model files, SQL DDL scripts, schema config files (Prisma, Mongoose, etc.), or direct database connection.
- If no database is detected, skip this task entirely and proceed to phase 3.

## Steps

### 1. Verify Database Existence

Check the phase 1 architecture document for database detection:
- If no database was found, skip this task. Inform the user: "No database detected in phase 1. Skipping schema audit. Proceeding to phase 3 (UX scan)."
- If a database was found, identify:
  - Database type and version (PostgreSQL, MySQL, MongoDB, SQLite, etc.)
  - ORM or query builder in use (Prisma, Sequelize, TypeORM, Knex, Drizzle, Mongoose, etc.)
  - Connection configuration location.

### 2. Locate Schema Sources

Find schema definitions in order of preference and reliability:

| Priority | Source | Reliability | Examples |
|----------|--------|-------------|----------|
| 1 | **Migration files** | Highest | Prisma migrations, Knex migrations, Flyway, Alembic, TypeORM migrations |
| 2 | **Schema config** | High | `schema.prisma`, Mongoose schemas, TypeORM entities |
| 3 | **ORM model files** | Medium | Sequelize models, Django models, ActiveRecord models |
| 4 | **Raw SQL files** | Medium | DDL scripts, seed files, `init.sql` |
| 5 | **Direct DB access** | Highest (runtime) | Live connection to inspect `information_schema` |

Document which sources were found and used. Note any discrepancies between sources (e.g., migrations out of sync with models).

### 3. Document the Schema

For each table or collection, document:

#### 3a. Table Catalog

- **Table name** and purpose (inferred from name, context, or comments).
- **Columns/fields:** Name, data type, nullable, default value, constraints.
- **Primary keys** and unique constraints.
- **Foreign keys** with relationship type (1:1, 1:N, N:M).
- **Indexes:** Name, columns, type (B-tree, GIN, GiST, unique, partial).
- **Triggers and functions:** If any are defined.
- **Row-Level Security (RLS):** Policies if applicable.

#### 3b. Relationship Diagram

Produce a text-based relationship diagram showing table connections:

```
users 1--N posts
users 1--N comments
posts  1--N comments
posts  N--M tags (via post_tags)
```

#### 3c. Schema Statistics

Compile summary statistics:
- Total number of tables/collections.
- Total number of columns across all tables.
- Total number of foreign key relationships.
- Total number of indexes.
- Tables with the most columns (potential complexity indicators).
- Tables with no relationships (potential orphans).

### 4. Audit for Issues

Evaluate the schema against five audit categories. For each finding, assign a severity:

- **CRITICAL:** Data loss risk, security vulnerability, broken functionality.
- **HIGH:** Missing essential constraint, significant performance issue.
- **MEDIUM:** Best practice violation, minor performance concern.
- **LOW:** Naming convention issue, cosmetic improvement.

#### 4a. Structural Design Audit

| Check | What to Look For | Severity if Found |
|-------|-----------------|-------------------|
| Missing primary keys | Tables without PK definition | CRITICAL |
| Missing timestamps | No `created_at` / `updated_at` where expected | MEDIUM |
| Inconsistent naming | Mixed snake_case and camelCase | MEDIUM |
| Orphaned tables | Tables with no relationships and no apparent use | LOW |
| Denormalization without justification | Duplicated data across tables | MEDIUM |
| Overly wide tables | Tables with 30+ columns | MEDIUM |
| Missing soft-delete patterns | Hard deletes on important data | LOW |
| Improper use of data types | Using VARCHAR for dates, TEXT for booleans | HIGH |

#### 4b. Performance Audit

| Check | What to Look For | Severity if Found |
|-------|-----------------|-------------------|
| Missing FK indexes | Foreign key columns without indexes | HIGH |
| Tables without indexes | Tables with data but no indexes at all | MEDIUM |
| Over-indexing | Write-heavy tables with excessive indexes | MEDIUM |
| Unused indexes | Indexes with zero scans (if stats available) | LOW |
| Duplicate indexes | Two indexes covering the same columns | LOW |
| Large tables without partitioning | Tables > 1GB without partition strategy | MEDIUM |
| Large text/blob columns | Stored inline without separate storage | LOW |
| N+1 query patterns | Detectable from ORM usage patterns | HIGH |

**SQL Reference -- Detecting Performance Issues (PostgreSQL):**

```sql
-- Foreign keys without indexes
SELECT fk.table_name, fk.column_name, fk.foreign_table
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage fk ON tc.constraint_name = fk.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
  AND NOT EXISTS (
    SELECT 1 FROM pg_indexes idx
    WHERE idx.tablename = fk.table_name
      AND idx.indexdef LIKE '%' || fk.column_name || '%'
  );

-- Unused indexes (0 scans, size > 1MB)
SELECT schemaname, tablename, indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) AS size, idx_scan
FROM pg_stat_user_indexes
WHERE schemaname = 'public' AND idx_scan = 0
  AND indexname NOT LIKE '%_pkey'
  AND pg_relation_size(indexrelid) > 1024*1024;

-- Duplicate indexes
SELECT a.tablename, a.indexname AS index1, b.indexname AS index2
FROM pg_indexes a JOIN pg_indexes b
  ON a.tablename = b.tablename AND a.indexname < b.indexname AND a.indexdef = b.indexdef
WHERE a.schemaname = 'public';

-- Large tables that might benefit from partitioning
SELECT tablename, pg_size_pretty(pg_total_relation_size('public.' || tablename)) AS size
FROM pg_tables WHERE schemaname = 'public'
  AND pg_total_relation_size('public.' || tablename) > 1024*1024*1024
ORDER BY pg_total_relation_size('public.' || tablename) DESC;
```

#### 4c. Security Audit

| Check | What to Look For | Severity if Found |
|-------|-----------------|-------------------|
| Missing RLS policies | Multi-tenant tables without row-level security | HIGH |
| RLS enabled but no policies | RLS turned on but no actual policies defined | CRITICAL |
| Plaintext sensitive data | Passwords, tokens, PII stored unencrypted | CRITICAL |
| Overly permissive grants | Public or anonymous access to sensitive tables | HIGH |
| SQL injection patterns | Raw string concatenation in query files | CRITICAL |
| PII without classification | Columns like SSN, passport, credit card without protection | HIGH |

**SQL Reference -- Detecting Security Issues (PostgreSQL):**

```sql
-- Tables without RLS enabled
SELECT schemaname, tablename, rowsecurity
FROM pg_tables WHERE schemaname = 'public' AND rowsecurity = false;

-- Tables with RLS but no policies
SELECT t.schemaname, t.tablename
FROM pg_tables t WHERE t.schemaname = 'public' AND t.rowsecurity = true
  AND NOT EXISTS (
    SELECT 1 FROM pg_policies p
    WHERE p.schemaname = t.schemaname AND p.tablename = t.tablename
  );

-- RLS policy coverage by table
SELECT t.tablename, t.rowsecurity AS rls_enabled,
  COUNT(p.policyname) AS policy_count,
  STRING_AGG(DISTINCT p.cmd, ', ') AS operations
FROM pg_tables t LEFT JOIN pg_policies p
  ON t.tablename = p.tablename AND t.schemaname = p.schemaname
WHERE t.schemaname = 'public'
GROUP BY t.tablename, t.rowsecurity ORDER BY t.tablename;

-- Potential PII columns (consider encryption/hashing)
SELECT table_name, column_name, data_type
FROM information_schema.columns WHERE table_schema = 'public'
  AND (column_name ILIKE '%ssn%' OR column_name ILIKE '%tax_id%'
    OR column_name ILIKE '%passport%' OR column_name ILIKE '%credit_card%'
    OR column_name ILIKE '%password%');
```

#### 4d. Data Integrity Audit

| Check | What to Look For | Severity if Found |
|-------|-----------------|-------------------|
| Missing NOT NULL on required fields | Nullable columns that should be required | HIGH |
| Missing CHECK constraints | Bounded values without validation (status, role, etc.) | MEDIUM |
| Soft foreign keys | References enforced only in application code | MEDIUM |
| Inconsistent data types | Same concept using different types across tables | MEDIUM |
| Missing default values | Required columns without sensible defaults | LOW |
| Orphaned records potential | FK relationships without ON DELETE rules | MEDIUM |
| Tables without any constraints | No PK, FK, unique, or check constraints at all | HIGH |

**SQL Reference -- Detecting Integrity Issues (PostgreSQL):**

```sql
-- Tables without primary keys
SELECT table_name FROM information_schema.tables t
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = t.table_schema AND table_name = t.table_name
      AND constraint_type = 'PRIMARY KEY'
  );

-- Tables without created_at timestamp
SELECT table_name FROM information_schema.tables t
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = t.table_schema AND table_name = t.table_name
      AND column_name IN ('created_at', 'createdat')
  );

-- Suspicious nullable columns (id, *_id, email, created_at)
SELECT table_name, column_name, data_type
FROM information_schema.columns WHERE table_schema = 'public' AND is_nullable = 'YES'
  AND (column_name = 'id' OR column_name = 'email'
    OR column_name = 'created_at' OR column_name LIKE '%_id');

-- Tables without any constraints
SELECT table_name FROM information_schema.tables t
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
  AND NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = t.table_schema AND table_name = t.table_name
  );
```

#### 4e. Naming Convention Audit

| Check | What to Look For | Severity if Found |
|-------|-----------------|-------------------|
| Inconsistent case style | Mixing snake_case and camelCase in table/column names | LOW |
| Unnamed constraints | Auto-generated constraint names instead of descriptive ones | LOW |
| Ambiguous column names | `status`, `type`, `data` without table context | LOW |
| Inconsistent FK naming | Some use `user_id`, others use `userId` or `uid` | MEDIUM |
| Table pluralization inconsistency | Some tables plural, some singular | LOW |

**Named Constraints Best Practice:**

Use descriptive constraint names instead of auto-generated ones. Informative constraint names make error messages actionable:

```sql
-- Auto-generated (cryptic errors)
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE,
  age INTEGER CHECK (age >= 18)
);
-- Error: "violates check constraint users_age_check"

-- Named constraints (clear errors)
CREATE TABLE users (
  id UUID CONSTRAINT users_pkey PRIMARY KEY,
  email TEXT CONSTRAINT users_email_unique UNIQUE,
  age INTEGER CONSTRAINT users_age_must_be_adult CHECK (age >= 18),
  status TEXT CONSTRAINT users_status_valid CHECK (status IN ('active', 'suspended', 'deleted'))
);
-- Error: "violates check constraint users_age_must_be_adult"
```

**Naming convention:** `{table}_{column}_{type}` where type is: pkey, fkey, unique, check, idx.

**Query to detect unnamed constraints:**

```sql
SELECT conname AS constraint_name, conrelid::regclass AS table_name, contype
FROM pg_constraint WHERE connamespace = 'public'::regnamespace
  AND conname ~ '_pkey$|_key$|_fkey$|_check$|_not_null$'
  AND NOT conname ~ '^[a-z]+_[a-z_]+_(pkey|fkey|unique|check|required|valid)'
ORDER BY conrelid::regclass::TEXT, conname;
```

### 5. Generate Scoring

Calculate an overall schema health score:

```
Score = 100 - (20 x CRITICAL count) - (10 x HIGH count) - (5 x MEDIUM count) - (1 x LOW count)
Bounded between 0 and 100.
```

| Score Range | Rating | Description |
|-------------|--------|-------------|
| 90-100 | Excellent | Minor improvements only |
| 80-89 | Good | Some best practices missed |
| 70-79 | Fair | Several issues to address |
| 60-69 | Needs Work | Security or performance risks present |
| < 60 | Critical | Not production-ready without remediation |

### 6. Produce Output Documents

#### Output 1: SCHEMA.md

```markdown
# Database Schema -- {Project Name}

## Database Type
{Type and version, ORM/query builder used}

## Schema Sources
{Which sources were used for this documentation}

## Tables

### {table_name}
**Purpose:** {description}

| Column | Type | Nullable | Default | Constraints |
|--------|------|----------|---------|-------------|
| ... | ... | ... | ... | ... |

**Indexes:**
- {index_name}: {columns} ({type})

**RLS Policies:** {if applicable}

{Repeat for each table}

## Relationships
{Text-based relationship diagram}

## Schema Statistics
{Summary statistics from Step 3c}
```

#### Output 2: DB-AUDIT.md

```markdown
# Database Audit -- {Project Name}

## Executive Summary
- Tables audited: {count}
- Overall health score: {score}/100 ({rating})
- Critical issues: {count}
- High issues: {count}
- Medium issues: {count}
- Low issues: {count}

## Findings

### Critical Issues
{Each finding with: description, affected tables/columns, impact, recommended fix}

### High Issues
{Same format}

### Medium Issues
{Same format}

### Low Issues
{Same format}

## Remediation Plan

| Priority | Action | Affected | Estimated Effort |
|----------|--------|----------|-----------------|
| P0 | {action} | {tables} | {effort} |
| P1 | {action} | {tables} | {effort} |
| P2 | {action} | {tables} | {effort} |

## SQL Fix Templates

{For each remediation action, provide a template SQL command}

## Migration Considerations

{Notes for future schema changes: ordering dependencies, data migration needs, backward compatibility}
```

**SQL Fix Template Examples:**

```sql
-- Fix: Add primary keys
ALTER TABLE {table} ADD COLUMN id UUID PRIMARY KEY DEFAULT gen_random_uuid();

-- Fix: Index foreign keys
CREATE INDEX CONCURRENTLY idx_{table}_{fk} ON {table}({fk_column});

-- Fix: Enable RLS
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;
CREATE POLICY "{table}_policy" ON {table} FOR ALL TO authenticated
  USING (auth.uid() = user_id);

-- Fix: Add timestamps
ALTER TABLE {table} ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE {table} ADD COLUMN updated_at TIMESTAMPTZ;
```

### 7. Advanced Audit Recommendations

For mature or production databases, recommend these additional audit capabilities:

#### Audit Triggers (Change Tracking)

Recommend implementing audit triggers that track all changes (INSERT, UPDATE, DELETE) with who, when, and what changed. This supports compliance requirements (GDPR, SOX, HIPAA) and debugging production issues. Reference: PostgreSQL Audit Trigger pattern.

#### pgAudit Extension

For comprehensive session and object audit logging, recommend `pgaudit` extension. It logs DDL operations, DML operations, parameter values, and session information.

#### pgTAP Extension (Database Testing)

Recommend `pgtap` for unit testing the database schema, constraints, and data. Tests verify table existence, primary keys, column types, NOT NULL constraints, foreign keys, and indexes. These tests can be integrated into CI/CD pipelines.

### 8. Handoff

Present the audit summary to the user:
- Number of tables/collections documented.
- Overall health score and rating.
- Issue counts by severity.
- Top 3 most critical findings with brief descriptions.
- Recommend next steps:
  - `ux-scan-artifact` (phase 3) if a frontend exists.
  - Phase 4 (technical debt draft) if no frontend.
  - Immediate remediation of CRITICAL findings if any exist.

## Error Handling

| Situation | Action |
|-----------|--------|
| **No database detected** | Skip entirely. Report skip reason and proceed to phase 3. |
| **Migration files inconsistent with models** | Document the discrepancy as a HIGH finding. Note which source appears more current. |
| **Cannot parse ORM models** | Fall back to migration files or raw SQL. Note limited coverage in the audit report. |
| **No schema source found but DB known** | Document the gap as a CRITICAL finding. Recommend obtaining DB access or exporting schema. |
| **Very large schema (50+ tables)** | Focus on core tables and relationships. Create a "Tables Needing Deeper Audit" appendix. |
| **Multiple databases in project** | Audit each separately within the same documents, clearly labeled. |
| **Schema source is in unfamiliar ORM** | Document raw findings. Note uncertainty about framework-specific conventions. |
| **No migration history available** | Note as a finding. Document current state without migration context. |
| **Read-only access to database** | Proceed with read-only analysis. Note that write-related checks (triggers, procedures) may be incomplete. |

## Examples

### Example: Clean Prisma Schema

```
Database: PostgreSQL 15 via Prisma ORM
Tables: 8 (users, posts, comments, tags, post_tags, sessions, settings, audit_logs)
Health Score: 92/100 (Excellent)
Findings: 2 MEDIUM (missing partial indexes on soft-deleted records, timestamps missing on settings table)
Next step: ux-scan-artifact (React frontend detected)
```

### Example: Legacy Express + Sequelize

```
Database: MySQL 5.7 via Sequelize
Tables: 23 (including 4 orphaned junction tables)
Health Score: 61/100 (Needs Work)
Findings: 1 CRITICAL (plaintext password storage), 3 HIGH (missing FK indexes, no constraints on status fields, inconsistent naming), 8 MEDIUM
Next step: Recommend immediate CRITICAL remediation before continuing discovery
```

## Acceptance Criteria

- [ ] Database type and version correctly identified.
- [ ] All schema sources located and documented.
- [ ] Every table cataloged with columns, types, constraints, and relationships.
- [ ] Relationship diagram produced in text format.
- [ ] All five audit categories evaluated with findings classified by severity.
- [ ] Health score calculated and rating assigned.
- [ ] SCHEMA.md produced with complete table documentation.
- [ ] DB-AUDIT.md produced with findings, remediation plan, and SQL fix templates.
- [ ] Handoff includes summary and next-step recommendation.
- [ ] Discrepancies between schema sources documented if found.

## Notes

- This task is SKIPPED entirely if no database was detected in phase 1.
- The audit evaluates the schema as-is, not against an ideal state. Findings are contextualized to the project's actual use case.
- SQL fix templates are provided as starting points, not production-ready migrations. They must be reviewed and adapted before execution.
- For databases with Row-Level Security (e.g., Supabase, PostgreSQL), the security audit includes RLS policy coverage analysis.
- The health score is a guideline, not an absolute measure. A score of 70 on a prototype may be acceptable; the same score on a production system handling PII would be concerning.
- If the project uses multiple databases (e.g., PostgreSQL for application data, Redis for caching), audit each that has a persistent schema. Skip ephemeral stores.
- Named constraints are strongly recommended over auto-generated names. The naming convention audit checks for this specifically.
- Reference materials: [PostgreSQL Best Practices](https://wiki.postgresql.org/wiki/Don't_Do_This), [Supabase RLS Best Practices](https://supabase.com/docs/guides/auth/row-level-security), [pgAudit](https://www.pgaudit.org/), [pgTAP](https://pgtap.org/).
