---
task: db-domain-modeling
agent: data-engineer
inputs:
  - domain_description (string, required): Business domain context or PRD reference
  - entities (array, optional): Pre-identified core entities
  - db_type (string, optional): Target database type (default: postgresql)
outputs:
  - schema_design (file): Schema design document (docs/schema-design.yaml)
  - migration_file (file): Initial schema migration SQL file
  - erd_document (file): Entity relationship diagram in markdown
---

# Domain Modeling Session

## Purpose
Interactive session to model a business domain into a well-structured database schema. Translates business requirements into entities, relationships, constraints, indexes, and RLS policies through a guided domain-driven design process.

## Prerequisites
- Business domain or PRD is available for reference
- Database project is initialized (run `setup-database` first if needed)
- Database connection is established and accessible

## Steps

### 1. Understand the Domain

Gather comprehensive domain information from the user:

```
1. What is the business domain? (e.g., e-commerce, social media, SaaS)
2. Who are the main actors? (e.g., users, admins, customers)
3. What are the core entities? (e.g., products, orders, posts)
4. What are the key relationships? (e.g., users have orders, posts belong to users)
5. What are the critical business rules? (e.g., orders cannot be deleted, users must verify email)
6. What are the main use cases? (e.g., user creates post, admin approves content)
7. What is the expected scale? (e.g., 1K users, 100K orders/month)
8. Are there any compliance requirements? (e.g., GDPR, HIPAA)
```

### 2. Identify Core Entities

For each entity, gather details:

- **Description:** What is it?
- **Attributes:** Required fields, optional fields, computed fields
- **Identifier:** UUID (recommended for distributed systems), serial integer, or natural key
- **Lifecycle:** Immutable, mutable, or soft-deletable
- **Access patterns:** By ID, by user, by date range, full-text search, aggregations

### 3. Map Relationships

For each pair of entities, determine:

- **Relationship type:** One-to-One (1:1), One-to-Many (1:N), Many-to-Many (M:N)
- **Ownership:** Who owns the relationship? Can it exist independently?
- **Cardinality:** Optional or required? Min/max constraints?
- **Cascade behavior:** What happens on delete? What happens on update?

Examples:
```
- User -> Posts (1:N, user owns, CASCADE delete)
- Post <-> Tags (M:N, junction table, no cascade)
- User -> Profile (1:1, user owns, CASCADE delete)
```

### 4. Design Tables

For each entity, create the table definition:

```sql
CREATE TABLE {entity_name} (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Foreign Keys (relationships)
  {parent}_id UUID REFERENCES {parent}(id) ON DELETE CASCADE,

  -- Required Attributes
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Optional Attributes
  description TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Audit Fields
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,  -- For soft deletes

  -- Constraints
  CONSTRAINT valid_name CHECK (LENGTH(name) > 0),
  CONSTRAINT valid_dates CHECK (created_at <= COALESCE(updated_at, NOW()))
);

-- Indexes (based on access patterns)
CREATE INDEX idx_{entity}_parent ON {entity}({parent}_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_{entity}_created ON {entity}(created_at DESC);

-- Comments (documentation)
COMMENT ON TABLE {entity} IS 'Stores {business description}';
```

### 5. Handle Many-to-Many Relationships

Create junction tables for M:N relationships:

```sql
CREATE TABLE {entity1}_{entity2} (
  {entity1}_id UUID NOT NULL REFERENCES {entity1}(id) ON DELETE CASCADE,
  {entity2}_id UUID NOT NULL REFERENCES {entity2}(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY ({entity1}_id, {entity2}_id)
);

CREATE INDEX idx_{entity1}_{entity2}_1 ON {entity1}_{entity2}({entity1}_id);
CREATE INDEX idx_{entity1}_{entity2}_2 ON {entity1}_{entity2}({entity2}_id);
```

### 6. Apply Business Rules

Translate business rules into database constraints:

```sql
-- Rule: Email must be unique
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

-- Rule: Orders cannot be negative
ALTER TABLE orders ADD CONSTRAINT positive_total CHECK (total >= 0);

-- Rule: Published posts must have title
ALTER TABLE posts ADD CONSTRAINT published_has_title
  CHECK (status != 'published' OR (title IS NOT NULL AND LENGTH(title) > 0));

-- Rule: Soft-deleted records are read-only
CREATE OR REPLACE FUNCTION prevent_update_deleted()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.deleted_at IS NOT NULL THEN
    RAISE EXCEPTION 'Cannot update deleted record';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 7. Design for Access Patterns

Create indexes based on query patterns:

```sql
-- User-specific data (multi-tenant)
CREATE INDEX idx_posts_user ON posts(user_id) WHERE deleted_at IS NULL;

-- Time-based queries
CREATE INDEX idx_posts_created ON posts(created_at DESC) WHERE deleted_at IS NULL;

-- Status filtering
CREATE INDEX idx_posts_status ON posts(status, created_at DESC);

-- Full-text search
CREATE INDEX idx_posts_search ON posts USING gin(to_tsvector('english', title || ' ' || content));

-- JSONB queries
CREATE INDEX idx_posts_metadata ON posts USING gin(metadata jsonb_path_ops);

-- Composite (multiple filters)
CREATE INDEX idx_posts_user_status ON posts(user_id, status, created_at DESC);
```

### 8. Add RLS Policies

Implement Row Level Security (for PostgreSQL/Supabase):

```sql
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;

-- Users see only their own data
CREATE POLICY "{table}_users_own"
  ON {table} FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Admins see everything
CREATE POLICY "{table}_admins_all"
  ON {table} FOR ALL TO authenticated
  USING ((auth.jwt() ->> 'role') = 'admin');
```

### 9. Generate Schema Document

Create the schema design document using the project template, filling in:
- domain_context
- entities (all identified entities)
- relationships (all relationships)
- access_patterns, constraints, indexes, rls_policies

### 10. Generate Migration

Create the initial migration file:

```bash
TS=$(date +%Y%m%d%H%M%S)
MIGRATION_FILE="supabase/migrations/${TS}_initial_schema.sql"
```

Wrap all DDL in a single transaction (`BEGIN; ... COMMIT;`) containing:
- Table definitions
- Index definitions
- Constraint definitions
- RLS policies
- Comment statements

## Common Domain Patterns

### Multi-Tenancy
```sql
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL
);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  email TEXT NOT NULL UNIQUE,
  UNIQUE (organization_id, email)
);
```

### Audit Trail
```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  operation TEXT NOT NULL, -- INSERT, UPDATE, DELETE
  old_data JSONB,
  new_data JSONB,
  user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Hierarchical Data
```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES categories(id),
  name TEXT NOT NULL,
  path TEXT[] -- Materialized path for fast queries
);
```

## Best Practices
1. **Start simple** - Begin with core entities, add complexity incrementally
2. **Use standard patterns** - id (UUID), created_at, updated_at, deleted_at, user_id
3. **Document everything** - Table comments, column comments, descriptive constraint names
4. **Think about scale** - Anticipate table growth, common queries, hot paths
5. **Design for change** - Use JSONB for flexible attributes, soft deletes for history
6. **Security first** - RLS by default, constraints enforce integrity, foreign keys prevent orphans

## Acceptance Criteria
- All identified entities have corresponding table definitions
- Relationships are properly mapped with foreign keys and cascade rules
- Business rules are enforced via constraints and triggers
- Indexes cover identified access patterns
- RLS policies defined for tables with user-scoped data
- Schema document and migration file are generated

## Error Handling
- **Connection Failed:** Check connection string, credentials, and network; retry with exponential backoff (max 3 attempts)
- **Query Syntax Error:** Validate SQL syntax before execution; return detailed error with suggested fix
- **Constraint Violation:** Review entity relationships and business rules; adjust constraints as needed
- **Missing Dependencies:** Ensure dependent tables are created before referencing tables; reorder DDL statements
