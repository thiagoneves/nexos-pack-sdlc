---
task: db-verify-order
agent: data-engineer
inputs:
  - path: Path to SQL migration file
outputs:
  - validation_result: Pass/fail with section analysis and ordering issues
---

# Verify DDL Ordering

## Purpose
Lint a DDL migration file for safe execution order to avoid dependency errors. Detects common ordering problems like functions before tables, RLS before table creation, and triggers before functions -- without requiring a database connection.

## Prerequisites
- A SQL migration file to validate
- No database connection required (static analysis only)

## Steps

### 1. Extract DDL Sections

Parse migration file and identify sections:

```bash
awk 'BEGIN{IGNORECASE=1}
  /create extension|alter extension/ {print "EXT:", NR, $0}
  /create table/ {print "TAB:", NR, $0}
  /create or replace function|create function/ {print "FUN:", NR, $0}
  /create trigger/ {print "TRG:", NR, $0}
  /enable row level security|create policy/ {print "RLS:", NR, $0}
  /create .* view/ {print "VIEW:", NR, $0}
' {path} > /tmp/ddl_order.txt

echo "=== DDL Section Analysis ==="
cat /tmp/ddl_order.txt
```

### 2. Analyze Ordering

Display recommended order vs actual order:

**Recommended Execution Order:**
1. Extensions (`CREATE EXTENSION`)
2. Tables & Constraints (`CREATE TABLE`, `ALTER TABLE`)
3. Functions (`CREATE FUNCTION`)
4. Triggers (`CREATE TRIGGER`)
5. RLS (`ENABLE RLS`, `CREATE POLICY`)
6. Views & Materialized Views (`CREATE VIEW`)

### 3. Run Heuristic Checks

Detect common ordering problems:

```bash
# Check: Functions before tables
FIRST_TAB=$(grep '^TAB:' /tmp/ddl_order.txt | head -1 | cut -d: -f2)
FIRST_FUN=$(grep '^FUN:' /tmp/ddl_order.txt | head -1 | cut -d: -f2)

if [ -n "$FIRST_TAB" ] && [ -n "$FIRST_FUN" ] && [ "$FIRST_FUN" -lt "$FIRST_TAB" ]; then
  echo "Functions appear before tables. Reorder recommended."
  exit 2
fi

# Check: RLS before tables exist
FIRST_RLS=$(grep '^RLS:' /tmp/ddl_order.txt | head -1 | cut -d: -f2)
if [ -n "$FIRST_RLS" ] && [ -n "$FIRST_TAB" ] && [ "$FIRST_RLS" -lt "$FIRST_TAB" ]; then
  echo "RLS commands before table creation. Reorder required."
  exit 2
fi

# Check: Triggers before functions
FIRST_TRG=$(grep '^TRG:' /tmp/ddl_order.txt | head -1 | cut -d: -f2)
if [ -n "$FIRST_TRG" ] && [ -n "$FIRST_FUN" ] && [ "$FIRST_TRG" -lt "$FIRST_FUN" ]; then
  echo "Triggers before functions. May fail if trigger calls function."
fi

echo "Ordering looks reasonable by heuristics"
```

### 4. Report Results

**If all checks pass:**
```
DDL Ordering Validation Passed

Sections found:
  - Extensions: X
  - Tables: Y
  - Functions: Z
  - Triggers: N
  - RLS: M
  - Views: V

Order appears correct. Safe to proceed with dry-run.
```

**If issues found:**
```
DDL Ordering Issues Detected

Problems:
  - Functions defined before tables (line X vs line Y)
  - Triggers reference functions not yet created

Recommended fixes:
  1. Move CREATE EXTENSION to top
  2. Group CREATE TABLE statements
  3. Then CREATE FUNCTION
  4. Then CREATE TRIGGER
  5. Then ENABLE RLS + policies
  6. Finally CREATE VIEW

After fixing, re-run verification.
```

## Correct Ordering Examples

### Good Order
```sql
-- 1. Extensions first
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Tables and constraints
CREATE TABLE users (...);
CREATE TABLE fragments (...);
ALTER TABLE fragments ADD CONSTRAINT fk_user ...;

-- 3. Functions
CREATE OR REPLACE FUNCTION current_user_id() ...;
CREATE OR REPLACE FUNCTION update_timestamp() ...;

-- 4. Triggers
CREATE TRIGGER set_timestamp
BEFORE UPDATE ON users ...;

-- 5. RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_all" ON users ...;

-- 6. Views
CREATE VIEW user_fragments_view AS ...;
```

### Bad Order (Will Fail)
```sql
-- Function before table it references
CREATE FUNCTION get_user_name(user_id UUID)
RETURNS TEXT AS $$
  SELECT name FROM users WHERE id = user_id;  -- users doesn't exist yet!
$$ LANGUAGE sql;

CREATE TABLE users (...);

-- Policy on table that may not exist yet
CREATE POLICY "users_policy" ON users ...;
```

## Common Dependency Patterns

### Functions Calling Other Functions
**Order:** Base functions first, then composite functions.

### Tables with Foreign Keys
**Order:** Referenced (parent) tables first, then referencing (child) tables.

### Views on Views
**Order:** Base views first, then derived views.

### RLS Using Functions
**Order:** Tables first, then helper functions, then RLS policies using those functions.

## Manual Review Checklist

After automated checks, manually verify:

- [ ] All CREATE EXTENSION at top
- [ ] Foreign key references come after parent tables
- [ ] Triggers reference existing functions
- [ ] RLS policies reference existing tables
- [ ] Views reference existing tables/views
- [ ] Functions called by other functions defined first
- [ ] No circular dependencies

## Integration with Workflow

Typical validation workflow:
1. Write migration
2. Verify DDL ordering (this task)
3. Fix any issues found
4. Dry-run the migration
5. Apply migration if dry-run passes

## Limitations

This is a heuristic check, not a full SQL parser:

- **Catches:** Most common ordering issues
- **Fast:** Runs in < 1 second
- **Safe:** No database connection needed
- **Misses:** Complex cross-file dependencies, dynamic SQL, subtle type dependencies

For 100% validation, use a dry-run against a test database.

## Error Handling
- **File not found:** Verify the migration file path is correct
- **Empty file:** Migration file has no DDL statements; check if the correct file was specified
- **All sections missing:** File may not contain standard DDL; review manually
- **Heuristic false positive:** Override with manual review if the ordering is intentional (e.g., `CREATE OR REPLACE FUNCTION` that doesn't reference tables)
