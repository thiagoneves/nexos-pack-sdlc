---
task: document-project
agent: architect
workflow: brownfield-discovery (phase 1)
inputs: [existing codebase, project files, configuration]
outputs: [system-architecture.md]
---

# Document Project Architecture

## Purpose

Analyze an existing codebase to produce a comprehensive brownfield architecture document that captures the ACTUAL state of the system. This is the first phase of brownfield discovery and provides the foundation for all subsequent assessment phases (database audit, UX scan, technical debt analysis).

The resulting document is optimized for AI development agents, enabling them to understand project context, conventions, constraints, and technical debt before contributing to the codebase. It documents reality -- including workarounds, inconsistencies, and legacy decisions -- not an idealized architecture.

## Prerequisites

- Access to the existing project codebase.
- The project has files to analyze (not an empty repository).
- No prior architecture documentation is required -- this task creates it.
- If a PRD or requirements document exists, it should be available for focused analysis.

## Steps

### 1. Initial Project Assessment

**Determine the analysis scope by checking for requirements context.**

#### 1a. Check for PRD or Requirements Context

If a PRD, requirements document, or enhancement description exists in context:
- Review it to understand what enhancement or feature is planned.
- Identify which modules, services, or areas will be affected.
- Focus documentation primarily on these relevant areas.
- Skip unrelated parts of the codebase to keep documentation lean and actionable.

If NO PRD or requirements context exists:
- Present the user with options:
  1. **Create a PRD first** -- Offer to help create a brownfield PRD before documenting.
  2. **Provide existing requirements** -- Accept a requirements document, epic, or feature description.
  3. **Describe the focus** -- Accept a brief description of the planned work to narrow scope.
  4. **Document everything** -- Proceed with comprehensive documentation (warn about volume for large projects).

#### 1b. Survey the Project Structure

Scan the top-level directory structure:
- Identify the project type: monorepo, single application, library, microservices, etc.
- Map the directory hierarchy (up to 3 levels deep).
- Identify the primary programming language(s) and framework(s).
- Locate key configuration files: `package.json`, `tsconfig.json`, `Dockerfile`, `.env.example`, CI/CD configs, etc.
- Note any unusual or non-standard directory organization.

#### 1c. Elicitation Questions

Ask the user these questions to better understand the project:

- What is the primary purpose of this project?
- Are there specific areas of the codebase that are particularly complex or important?
- What types of tasks do you expect AI agents to perform? (bug fixes, features, refactoring, testing)
- Are there existing documentation standards or formats you prefer?
- What level of technical detail should the documentation target?
- Is there a specific feature or enhancement you are planning?

### 2. Technology Stack Identification

From configuration files and code analysis, determine:

| Category | What to Identify |
|----------|-----------------|
| **Runtime** | Node.js, Python, Go, Java, .NET, etc. with version |
| **Framework** | Next.js, Express, Django, Spring, Rails, etc. |
| **Database** | PostgreSQL, MongoDB, SQLite, etc. (check ORM configs, migration folders) |
| **Frontend** | React, Vue, Angular, Svelte, static HTML, etc. |
| **Styling** | Tailwind, CSS Modules, styled-components, SASS, etc. |
| **Build tools** | Webpack, Vite, esbuild, Turbopack, etc. |
| **Testing** | Jest, Vitest, Pytest, Mocha, Cypress, Playwright, etc. |
| **Deployment** | Docker, Kubernetes, Vercel, AWS, Netlify, etc. |
| **Package manager** | npm, yarn, pnpm, poetry, etc. |
| **State management** | Redux, Zustand, MobX, Context API, Pinia, etc. |
| **API style** | REST, GraphQL, gRPC, tRPC, etc. |

Record actual versions from lock files and config where possible -- not assumed versions.

### 3. Deep Codebase Analysis

#### 3a. Map Entry Points and Core Architecture

- **Entry points:** Main application files, server startup, CLI entry, worker processes.
- **Modules/components:** Major functional areas and their boundaries.
- **Data flow:** How data moves through the system (request/response, events, queues, pub/sub).
- **External integrations:** APIs, services, third-party libraries with significant roles.
- **Shared code:** Utilities, types, constants, helpers used across modules.

#### 3b. Analyze Code Organization Patterns

Document the ACTUAL patterns in use (not theoretical best practices):

- **Design patterns:** MVC, Clean Architecture, hexagonal, event-driven, domain-driven, etc.
- **Naming conventions:** File naming (kebab-case, camelCase, PascalCase), variable/function naming, export patterns.
- **Error handling:** Centralized vs. distributed, custom error classes, error boundary patterns.
- **Configuration management:** How config and environment variables are loaded and used.
- **Logging:** What logging framework is used, log levels, structured logging.
- **Authentication/Authorization:** Patterns for auth middleware, session management, token handling.

#### 3c. Analyze Dependencies

Review the dependency graph:
- **Direct dependencies:** List major dependencies and their purpose.
- **Outdated dependencies:** Note any significantly outdated packages.
- **Security concerns:** Flag known vulnerable dependencies if detectable.
- **Circular dependencies:** Identify any circular import patterns.
- **Heavy dependencies:** Note unusually large dependencies that affect bundle size or startup time.

#### 3d. Identify Technical Debt and Workarounds

**This is critical for brownfield documentation.** Look for:

- Inconsistent patterns between different parts of the codebase.
- Legacy code that appears frozen or untouchable.
- Hardcoded values that should be configurable.
- TODO/FIXME/HACK comments in the code.
- Workarounds with comments explaining why.
- Dead code or unused exports.
- Missing error handling in critical paths.
- Areas where conventions differ from the rest of the codebase.

### 4. Compile the Architecture Document

Write `system-architecture.md` following this structure:

```markdown
# {Project Name} -- System Architecture

## Introduction

This document captures the CURRENT STATE of the {Project Name} codebase,
including technical debt, workarounds, and real-world patterns. It serves
as a reference for AI agents and developers working on enhancements.

### Document Scope

{If PRD provided: "Focused on areas relevant to: {enhancement description}"}
{If no PRD: "Comprehensive documentation of entire system"}

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| {date} | 1.0 | Initial brownfield analysis | {agent} |

## Quick Reference -- Key Files and Entry Points

### Critical Files for Understanding the System

- **Main Entry:** {path}
- **Configuration:** {paths}
- **Core Business Logic:** {paths}
- **API Definitions:** {paths}
- **Database Models:** {paths}
- **Key Algorithms:** {paths with descriptions}

### Enhancement Impact Areas (if PRD provided)

{Files and modules that will be affected by the planned enhancement}

## Technology Stack

| Category | Technology | Version | Notes |
|----------|------------|---------|-------|
| Runtime | {tech} | {version} | {constraints or notes} |
| Framework | {tech} | {version} | {notes} |
| ... | ... | ... | ... |

## Directory Structure

{Annotated tree of the project layout, noting purpose of each directory
and any inconsistencies or unusual organization}

## Architecture and Data Flow

### Architecture Style

{Description of the overall architecture pattern}

### Data Flow

{How requests/data move through the system -- from entry to response}

### Component Relationships

{Textual description or ASCII diagram of component relationships}

## Key Components

### {Component Name}

- **Location:** {path}
- **Purpose:** {description}
- **Pattern:** {architectural pattern used}
- **Dependencies:** {what it depends on}
- **Consumers:** {what depends on it}
- **Notes:** {any gotchas or constraints}

{Repeat for each major component}

## Data Models and APIs

{Reference actual model files rather than duplicating content}

- **Models:** See {paths}
- **API Spec:** See {path} (if exists)
- **Types:** See {paths}

## External Integrations

| Service | Purpose | Integration Type | Key Files |
|---------|---------|------------------|-----------|
| {name} | {purpose} | {REST/SDK/etc.} | {paths} |

## Technical Debt and Known Issues

### Critical Technical Debt

{List with file references, impact descriptions, and context}

### Workarounds and Gotchas

{List of non-obvious behaviors, workarounds, and their reasons}

## Development and Deployment

### Local Development Setup

{Actual steps that work, including known issues}

### Build and Deploy

{Commands, environments, CI/CD pipeline description}

### Testing

{Current test coverage, test commands, testing strategy in practice}

## Observations and Recommendations

{Initial observations about architecture health, improvement opportunities}
```

### 5. Document Delivery

#### In IDE Environment
- Create the document as `docs/system-architecture.md` (or equivalent project docs directory).
- Inform the user that the document is complete and contains all architectural findings.

#### In Web UI / Chat Environment
- Present the complete document in the response.
- Instruct the user to save as `docs/system-architecture.md`.
- Note that the document can be refined iteratively.

### 6. Quality Assurance

Before finalizing the document, verify:

- [ ] **Accuracy:** All technical details match the actual codebase (versions, paths, patterns).
- [ ] **Completeness:** All major system components are documented.
- [ ] **Focus:** If the user provided scope, relevant areas are emphasized.
- [ ] **Clarity:** Explanations are clear for both AI agents and developers.
- [ ] **Navigation:** Document has clear section structure with consistent formatting.
- [ ] **Reality check:** Document captures actual state including debt, not an idealized view.
- [ ] **References:** File paths are accurate and verifiable.

### 7. Handoff

Present the document summary to the user:
- Project type and technology stack.
- Number of components/modules identified.
- Key observations and initial concerns.
- Technical debt highlights.
- Recommend next steps:
  - `db-schema-audit` (phase 2) if a database is detected.
  - `ux-scan-artifact` (phase 3) if a frontend exists.
  - Phase 4 (technical debt draft) if skipping phase 2 and 3.

## Output Format

The primary output is `system-architecture.md` placed in the project's documentation directory. The document should:
- Be 200-500 lines depending on project complexity.
- Use Markdown with consistent heading hierarchy.
- Include tables for structured data (tech stack, integrations).
- Reference actual file paths rather than duplicating code.
- Include a change log for future updates.

## Error Handling

| Situation | Action |
|-----------|--------|
| **Empty project** | Report no code found. Ask user to confirm the correct directory. |
| **Monorepo with multiple apps** | Document each app's architecture separately within the same document. |
| **Minified/compiled code only** | Note that source is not available. Document what can be inferred from config files and structure. |
| **Very large codebase (100+ modules)** | Focus on top-level architecture and major modules. Create a "Modules Needing Deeper Analysis" appendix. |
| **No clear architecture pattern** | Document as-is. Note the lack of consistent patterns as a finding under Technical Debt. |
| **Cannot determine technology** | List what was detected with confidence levels. Ask user to fill gaps. |
| **Conflicting patterns across codebase** | Document all patterns found and note the inconsistency. Identify which is dominant. |
| **Missing or outdated README** | Note this as a finding. Use codebase analysis as the primary source of truth. |

## Examples

### Example: Small Express API

```
Project Type: Single application (REST API)
Stack: Node.js 18 + Express 4 + PostgreSQL 14 + Prisma ORM
Components: 4 (auth, users, orders, notifications)
Technical Debt: 3 items (missing validation middleware, inconsistent error responses, no rate limiting)
Observations: Clean architecture but missing API documentation and integration tests.
Next step: db-schema-audit (PostgreSQL detected)
```

### Example: React + Next.js Monorepo

```
Project Type: Monorepo (Turborepo)
Stack: Next.js 14 + React 18 + TypeScript + Tailwind + Supabase
Apps: 2 (web, admin-dashboard)
Packages: 3 (ui, utils, types)
Technical Debt: 7 items (mixed styling approaches, missing error boundaries, no shared component library)
Observations: Good TypeScript coverage. Frontend and backend tightly coupled through Supabase client.
Next step: db-schema-audit (Supabase/PostgreSQL detected)
```

## Acceptance Criteria

- [ ] Architecture document created with all required sections populated.
- [ ] Technology stack identified with actual versions from config files.
- [ ] Directory structure mapped and annotated.
- [ ] Key components documented with file paths and purposes.
- [ ] Technical debt and workarounds honestly documented.
- [ ] External integrations cataloged.
- [ ] Development setup and deployment process captured.
- [ ] If PRD provided: Enhancement impact areas clearly identified.
- [ ] Document enables AI agents to navigate and understand the codebase.
- [ ] Handoff includes clear next-step recommendation.

## Notes

- This task creates ONE document that captures the TRUE state of the system.
- References actual files rather than duplicating content when possible.
- Documents technical debt, workarounds, and constraints honestly -- this is a brownfield assessment, not an aspirational architecture document.
- For brownfield projects with PRD: Provides clear enhancement impact analysis.
- The goal is PRACTICAL documentation for AI agents and developers doing real work on this codebase.
- If the project has no database or no frontend, the corresponding discovery phases (2 and 3) are skipped automatically during handoff.
- This document should be updated whenever significant architectural changes occur.
