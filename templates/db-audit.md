# Database Audit Report

**Project:** {project_name}
**Author:** @data-engineer
**Date:** {date}
**Database:** {database_type} {version}
**Context:** {Brownfield Discovery | Standalone Audit}

---

## 1. Schema Overview

### Database Summary

| Metric | Value |
|--------|-------|
| Database Type | {PostgreSQL / MySQL / MongoDB / etc.} |
| Total Tables/Collections | {count} |
| Total Indexes | {count} |
| Total Relationships | {count} |
| Estimated Data Volume | {size} |
| Schema Version / Migration | {current version} |

### Entity Relationship Diagram

```
{ASCII or Mermaid ER diagram showing tables and relationships}
```

---

## 2. Tables / Collections

### {table_name}

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| {column} | {type} | {yes/no} | {default} | {purpose} |

**Primary Key:** {column(s)}
**Indexes:** {list with type — unique, btree, gin, etc.}
**Foreign Keys:** {references to other tables}
**Row Count:** {approximate}
**RLS Policies:** {list or "None"}

---

## 3. Index Analysis

| Table | Index | Columns | Type | Usage | Recommendation |
|-------|-------|---------|------|-------|---------------|
| {table} | {index_name} | {columns} | {btree/hash/gin/etc.} | {High/Medium/Low/Unused} | {Keep/Drop/Modify} |

### Missing Indexes *(recommended)*

| Table | Columns | Rationale |
|-------|---------|-----------|
| {table} | {columns} | {why this index would help} |

---

## 4. Security Assessment

### Row-Level Security (RLS)

| Table | RLS Enabled | Policies | Assessment |
|-------|-------------|----------|------------|
| {table} | {yes/no} | {count} | {Adequate/Needs Work/Missing} |

### Sensitive Data

| Table | Column | Data Type | Protection |
|-------|--------|-----------|------------|
| {table} | {column} | {PII/PHI/Financial/etc.} | {encrypted/hashed/plain} |

### Recommendations
- {security improvement}

---

## 5. Performance Assessment

### Slow Queries *(if identified)*

| Query Pattern | Avg Time | Frequency | Root Cause |
|--------------|----------|-----------|------------|
| {pattern} | {ms} | {per hour/day} | {missing index / full scan / etc.} |

### Table Size Concerns

| Table | Row Count | Size | Growth Rate | Action |
|-------|-----------|------|-------------|--------|
| {table} | {count} | {MB/GB} | {per month} | {partition/archive/none} |

---

## 6. Data Integrity

### Constraints Audit

| Table | Constraint Type | Columns | Status |
|-------|----------------|---------|--------|
| {table} | {FK/unique/check} | {columns} | {Valid/Violated/Missing} |

### Orphaned Records *(if found)*

| Parent Table | Child Table | Orphaned Rows | Fix |
|-------------|-------------|---------------|-----|
| {parent} | {child} | {count} | {add FK / clean up / etc.} |

---

## 7. Migration Status

| Migration | Date | Description | Status |
|-----------|------|-------------|--------|
| {version} | {date} | {what changed} | {Applied/Pending/Failed} |

### Migration Risks
- {risk associated with pending or future migrations}

---

## 8. Technical Debt

| # | Issue | Severity | Effort | Recommendation |
|---|-------|----------|--------|---------------|
| 1 | {issue description} | {Critical/High/Medium/Low} | {hours/days} | {how to fix} |

---

## 9. Recommendations Summary

### Immediate Actions *(Critical/High)*
1. {action}

### Short-Term Improvements *(Medium)*
1. {action}

### Long-Term Considerations *(Low)*
1. {action}
