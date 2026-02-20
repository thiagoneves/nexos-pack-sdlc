---
task: qa-migration-validation
agent: qa
workflow: story-development-cycle (qa-gate, phase 6.2)
inputs:
  - story_id (required, format: "{epic}.{story}")
  - framework (optional: supabase, prisma, drizzle, django, rails, sequelize - auto-detected if omitted)
outputs:
  - migration_report (object with validation results)
  - issues_found (number)
  - report_file (file: docs/stories/{story-id}/qa/migration_validation.json)
---

# Migration Validation

## Purpose
Validate that database migrations are properly created and applied for schema changes. Detects the database framework in use, identifies schema changes in the diff, validates that corresponding migration files exist and are correct, and checks for reversibility, RLS policies, and data safety.

## Prerequisites
- Database framework detected in project (one of: supabase, prisma, drizzle, django, rails, sequelize)
- Schema changes detected in diff (informational - task may still run for audit purposes)

## Steps

### 1. Detect Framework
Check for framework indicators in the project:

| Framework | Detection Files |
|---|---|
| Supabase | `supabase/config.toml`, `supabase/migrations` |
| Prisma | `prisma/schema.prisma` |
| Drizzle | `drizzle.config.ts`, `drizzle/schema.ts` |
| Django | `manage.py`, `*/models.py` |
| Rails | `db/schema.rb`, `Gemfile` |
| Sequelize | `.sequelizerc`, `migrations/*.js` |

If multiple detected, prefer: explicit `--framework` flag, then most recent migration timestamp, then prompt user.

### 2. Detect Schema Changes
Get modified files and identify schema-related changes:

```bash
git diff --name-only HEAD~1
```

Categorize changes: new tables/models, modified columns, new indexes, new constraints, RLS policies (Supabase).

### 3. Validate Migrations
For each detected schema change:

1. **Check migration exists:** Is there a corresponding migration file? Does the migration timestamp match the schema change?
2. **Validate migration content:** Does the migration match the schema change? Are all columns/types correct? Are indexes included? Are constraints defined?
3. **Check reversibility:** Does a down migration exist? Are reversible operations used? Is data preservation considered?
4. **Test locally:** Run migration forward; run migration backward (if reversible); check for errors.

### 4. Additional Checks

**For Supabase specifically:**
- RLS policies exist for new tables
- Grant statements for roles
- Edge function permissions

**For all frameworks:**
- Foreign key indexes
- NOT NULL constraints with defaults
- Data migration for existing rows
- Enum type handling

### 5. Generate Report

```json
{
  "timestamp": "...",
  "story_id": "...",
  "framework": "...",
  "summary": {
    "schema_changes": 3,
    "migrations_found": 2,
    "missing_migrations": 1,
    "issues": 2
  },
  "validation": {...},
  "issues": [...],
  "recommendations": [...]
}
```

## Supported Frameworks

### Supabase
**Validation commands:**
```bash
supabase db diff          # Check for pending schema changes
supabase migration list   # List migrations status
supabase db lint          # Lint SQL migrations
```
**Checks:** Migration SQL exists, migration applied locally, no pending schema diff, RLS policies included for new tables, rollback migration exists.

### Prisma
**Validation commands:**
```bash
npx prisma migrate status     # Check migration status
npx prisma validate           # Validate schema
npx prisma db pull --preview  # Compare with DB
```
**Checks:** schema.prisma updated, migration generated, migration applied locally, no drift, indexes for foreign keys.

### Drizzle
**Validation commands:**
```bash
npx drizzle-kit generate  # Generate migrations
npx drizzle-kit check     # Check schema
```
**Checks:** Schema file updated, migration SQL generated, types exported correctly.

### Django
**Validation commands:**
```bash
python manage.py makemigrations --dry-run  # Check pending
python manage.py showmigrations            # List status
python manage.py migrate --plan            # Show plan
```
**Checks:** Migration files created, migrations apply without errors, no unapplied migrations, reversible migrations.

### Rails
**Validation commands:**
```bash
rails db:migrate:status   # Check status
rails db:migrate:redo     # Test reversibility
```
**Checks:** Migration file exists, runs forward, runs backward, schema.rb updated.

### Sequelize
**Validation commands:**
```bash
npx sequelize-cli db:migrate:status  # Check status
```
**Checks:** Migration file created, up and down methods defined, migration applies successfully.

## Severity Mapping

| Issue Type | Severity | Blocking |
|---|---|---|
| Missing migration for schema change | CRITICAL | Yes |
| Migration does not match schema | CRITICAL | Yes |
| Non-reversible destructive migration | HIGH | Recommended |
| Missing index on foreign key | MEDIUM | No |
| Missing RLS policy (Supabase) | HIGH | Recommended |
| Migration not tested locally | HIGH | Recommended |
| No down migration | MEDIUM | No |

## Migration Checklist Template

**Existence:** Migration file exists, timestamp is recent, naming follows convention.
**Content:** SQL/code matches schema change, column types correct, constraints defined, defaults specified.
**Indexes:** Primary keys defined, foreign key indexes created, query-pattern indexes added.
**Security:** RLS policies for new tables (Supabase), grants/permissions configured, sensitive columns protected.
**Reversibility:** Down migration exists, down migration tested, data preservation considered.
**Testing:** Migration runs locally, migration is idempotent, existing data preserved/migrated.

## Command
```
*validate-migrations {story-id} [--framework supabase|prisma|drizzle|django|rails|sequelize]
```

**Trigger:** Automatically called during `*review-build` (Phase 6.2) if schema changes detected.
**Manual:** Can be run standalone via `*validate-migrations`.

## Error Handling
- **No database framework detected:** Report pre-condition failure with list of expected indicators
- **No schema changes found:** Log info and optionally skip validation
- **Migration test failure:** Report as HIGH severity issue with the specific error
- **Framework command not available:** Log warning, perform file-based validation only
- **Multiple frameworks detected:** Prompt user or use the one with most recent activity

## Exit Criteria
- Database framework detected
- All schema changes identified
- Migration files validated against changes
- Missing migrations reported
- RLS policies checked (if Supabase)
- Reversibility assessed
- Report generated with severity classification
- Blocking recommendation provided
