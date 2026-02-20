# {project_name} — Architecture Document

**Version:** {version}
**Author:** @architect
**Status:** Draft
**Created:** {date}
**PRD Reference:** {path_to_prd}

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| {date} | 0.1 | Initial draft | @architect |

---

## 1. Introduction

{Brief paragraph: system overview, relationship to PRD, architectural goals}

### Starter Template / Existing Project *(optional)*
{If based on a starter template or existing codebase, document it here. Otherwise "N/A"}

---

## 2. High-Level Architecture

### Technical Summary
{3-5 sentences: architecture style, key components, primary patterns, how it supports PRD goals}

### Overview
- **Architecture Style:** {Monolith | Microservices | Serverless | Event-Driven}
- **Repository Structure:** {Monorepo | Polyrepo}
- **Primary Data Flow:** {description}

### Architecture Diagram
```
{ASCII or Mermaid diagram showing major components and their relationships}
```

### Architectural Patterns

| Pattern | Description | Rationale |
|---------|-------------|-----------|
| {pattern} | {description} | {why this fits the project} |
| {pattern} | {description} | {rationale} |

---

## 3. Tech Stack

### Cloud Infrastructure *(optional)*
- **Provider:** {provider}
- **Key Services:** {services}
- **Regions:** {regions}

### Technology Stack

| Category | Technology | Version | Purpose | Rationale |
|----------|-----------|---------|---------|-----------|
| Language | {tech} | {ver} | {purpose} | {why} |
| Runtime | {tech} | {ver} | {purpose} | {why} |
| Framework | {tech} | {ver} | {purpose} | {why} |
| Database | {tech} | {ver} | {purpose} | {why} |
| ORM/Query | {tech} | {ver} | {purpose} | {why} |
| Testing | {tech} | {ver} | {purpose} | {why} |
| Linting | {tech} | {ver} | {purpose} | {why} |
| Auth | {tech} | {ver} | {purpose} | {why} |

---

## 4. Data Models

### {model_name}

**Purpose:** {what this entity represents}

**Key Attributes:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| {attribute} | {type} | {yes/no} | {description} |
| {attribute} | {type} | {yes/no} | {description} |

**Relationships:**
- {model_name} → {related_model}: {relationship_type} ({description})

### Entity Relationship Diagram *(optional)*
```
{ASCII or Mermaid ER diagram}
```

---

## 5. Components

### {component_name}

**Responsibility:** {what this component does}

**Key Interfaces:**
- `{interface}` — {description}

**Dependencies:** {other components}

**Technology:** {specific tech for this component from Tech Stack}

### Component Diagram *(optional)*
```
{ASCII or Mermaid diagram showing component relationships}
```

---

## 6. External APIs *(optional)*

### {api_name}

| Field | Value |
|-------|-------|
| Purpose | {why this API is needed} |
| Documentation | {url} |
| Base URL | {url} |
| Authentication | {API key / OAuth / JWT / etc.} |
| Rate Limits | {requests per second/minute} |

**Key Endpoints:**

| Method | Path | Purpose |
|--------|------|---------|
| {GET/POST/etc.} | {path} | {what it does} |

**Integration Notes:** {error handling, retry strategy, fallbacks}

---

## 7. Core Workflows

### {workflow_name}

```
{Sequence diagram or step-by-step flow showing component interactions}
```

**Error Path:** {what happens when this workflow fails}

---

## 8. REST API Spec *(optional)*

### {resource_name}

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | /api/{resource} | {description} | {yes/no} |
| POST | /api/{resource} | {description} | {yes/no} |
| GET | /api/{resource}/:id | {description} | {yes/no} |
| PUT | /api/{resource}/:id | {description} | {yes/no} |
| DELETE | /api/{resource}/:id | {description} | {yes/no} |

**Request/Response Examples:** *(optional)*

```json
// POST /api/{resource}
// Request
{request_body}

// Response 201
{response_body}
```

**Error Responses:**

| Status | Code | Description |
|--------|------|-------------|
| 400 | VALIDATION_ERROR | {description} |
| 401 | UNAUTHORIZED | {description} |
| 404 | NOT_FOUND | {description} |

---

## 9. Database Schema

```sql
{DDL or document structure showing tables, indexes, constraints, RLS policies}
```

### Migration Strategy *(optional)*
{How database changes will be managed: migration tool, versioning approach}

---

## 10. Source Tree

```
{project_name}/
├── {directory}/          # {purpose}
│   ├── {subdirectory}/   # {purpose}
│   │   └── {file}        # {purpose}
│   └── {file}            # {purpose}
├── {directory}/          # {purpose}
├── {test_directory}/     # {purpose}
└── {config_file}         # {purpose}
```

---

## 11. Infrastructure & Deployment *(optional)*

### Environments

| Environment | Purpose | URL | Deploy Trigger |
|-------------|---------|-----|----------------|
| dev | Development | {url} | Push to dev branch |
| staging | Pre-production | {url} | Push to main |
| production | Live | {url} | Manual / tag |

### CI/CD Pipeline
- **Platform:** {GitHub Actions / GitLab CI / etc.}
- **Pipeline Config:** {path to config file}

### Deployment Strategy
- **Strategy:** {Blue-Green | Rolling | Canary | Direct}
- **IaC Tool:** {Terraform / CDK / Pulumi / etc.}

### Rollback Strategy
- **Method:** {revert deploy / database rollback / feature flags}
- **Recovery Time Objective:** {target time}

---

## 12. Error Handling

### General Approach
- **Error Model:** {custom exceptions / Result type / error codes}
- **Logging Library:** {library}
- **Log Format:** {structured JSON | plain text}
- **Correlation ID:** {how requests are traced across services}

### External API Errors
- **Retry Policy:** {exponential backoff / fixed interval / none}
- **Circuit Breaker:** {threshold and reset configuration}
- **Timeout:** {default timeout for external calls}
- **Fallback:** {what happens when external service is down}

### Business Logic Errors
- **Custom Exceptions:** {hierarchy or types}
- **User-Facing Format:** {how errors are presented to users}
- **Error Codes:** {code system if used, e.g., ERR-001}

### Data Consistency
- **Transaction Strategy:** {database transactions / saga / event sourcing}
- **Idempotency:** {approach for retry-safe operations}

---

## 13. Coding Standards

### Core Standards
- **Style & Linting:** {linter + config file}
- **Formatting:** {formatter + config}
- **Test Organization:** {convention for test files}

### Critical Rules
- {project-specific rule the AI agent must follow}
- {rule that prevents common mistakes in this stack}
- {naming or pattern rule specific to this project}

### Naming Conventions *(optional)*

| Element | Convention | Example |
|---------|-----------|---------|
| {files} | {convention} | {example} |
| {functions} | {convention} | {example} |
| {components} | {convention} | {example} |
| {database} | {convention} | {example} |

---

## 14. Testing Strategy

### Overview
- **Approach:** {TDD | test-after}
- **Coverage Target:** {percentage}

### Test Types

| Type | Framework | Location | Coverage |
|------|-----------|----------|----------|
| Unit | {framework} | {path} | {target %} |
| Integration | {framework} | {path} | {target %} |
| E2E | {framework} | {path} | {scope} |

### Test Infrastructure *(optional)*
- **Database:** {in-memory / testcontainers / separate instance}
- **External APIs:** {mocks / stubs / sandbox}
- **Test Data:** {fixtures / factories / seeding strategy}

### Continuous Testing
- **CI Integration:** {what runs on PR / merge / deploy}
- **Performance Tests:** {approach or "N/A"}

---

## 15. Security

### Authentication & Authorization
- **Auth Method:** {JWT / session / OAuth / etc.}
- **Session Management:** {approach}
- **Role-Based Access:** {roles and permissions model}

### Input Validation
- **Library:** {validation library}
- **Strategy:** {validate at API boundary / middleware / both}

### Secrets Management
- **Development:** {.env / vault / etc.}
- **Production:** {cloud secrets manager / vault}
- **Rule:** Never hardcode secrets, never log secrets

### API Security
- **Rate Limiting:** {implementation}
- **CORS Policy:** {origins allowed}
- **Security Headers:** {HSTS, CSP, etc.}
- **HTTPS:** {enforcement approach}

### Data Protection
- **Encryption at Rest:** {approach}
- **Encryption in Transit:** {TLS version}
- **PII Handling:** {rules for personal data}

### Dependency Security
- **Scanning Tool:** {dependabot / snyk / etc.}
- **Update Policy:** {frequency}

---

## 16. Next Steps

### Handoff Instructions
{Who gets this document next and what they should do with it}

### Frontend Architecture *(optional)*
{If project has significant UI, hand off to @architect for separate frontend architecture document}

### Implementation Start
{Instructions for @sm to begin story creation from the PRD epics}
