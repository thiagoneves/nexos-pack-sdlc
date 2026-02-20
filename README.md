# nexos-pack-software-dev

**Your AI Development Team. Always Online.**

A complete agile software development pack for [nexos](https://github.com/thiagoneves/nexos) — 11 specialized agents, 4 workflows, and 20 tasks that orchestrate the full software development lifecycle.

---

## What's Inside

| | Content | Count |
|---|---------|-------|
| 🤖 | **Agents** — Full agile team, each with defined authority | 11 |
| 📋 | **Tasks** — Step-by-step executable instructions | 20 |
| 🔄 | **Workflows** — Multi-phase orchestrated pipelines | 4 |
| 📄 | **Templates** — Story template with all standard sections | 1 |
| 📏 | **Rules** — Lifecycle, authority, and integration rules | 4 |

---

## Quick Start

```bash
# 1. Initialize your project
nexos init --tool claude-code

# 2. Install this pack
nexos install thiagoneves/nexos-pack-software-dev

# 3. Start working — activate any agent
@dev *develop story-1.1
```

---

## How It Works

### Execution Flow

How a story goes from "Ready" to "Done" — the 4 steps every @dev follows:

```
📖 Step 1                ⚡ Step 2                ✋ Step 3                🔍 Step 4
@dev receives story      Implements task          Marks Ready for         @qa validates
                         by task                  Review
─────────────────────    ─────────────────────    ─────────────────────   ─────────────────────
Dev reads the story.     For each task:           When all tasks are      QA reads ACs, reviews
Everything needed is     implement, test, mark    [x], updates status     code, runs tests.
in Dev Notes — no        [x], update File List.   to InReview. STOPS      Creates gate file
need to read PRD or      One at a time.           and waits for QA.       with PASS or FAIL.
architecture docs.
```

> **Zero context-switching.** Dev Notes contains the source tree, patterns, and testing standards extracted from architecture docs. The developer never needs to leave the story file.

---

### Handoff Between Agents

Each agent receives exactly the context it needs — no questions, no ambiguity.

```
📋 PRD → 🏗️ Architecture                     📝 Story → 💻 Dev
───────────────────────────                    ───────────────────────────
@architect reads PRD automatically.            @dev only reads the story.
Extracts NFRs, tech constraints, user          Dev Notes has everything:
flows. Doesn't ask anything already            source tree, patterns, testing
in the PRD.                                    standards. Zero context switch.

🏗️ Architecture → 📝 Stories                  💻 Dev → 🧪 QA
───────────────────────────────                ───────────────────────────
@sm reads PRD + Architecture.                  @qa reads the same story.
Extracts stories from PRD,                     ACs = validation criteria.
contextualizes with Architecture               File List = what was created.
patterns. Creates Dev Notes with               QA never asks "what did you
source tree and testing standards.              do?" — it's all in the story.
```

**The chain of trust:**
```
PRD  ──▶  Architecture  ──▶  Story  ──▶  Code  ──▶  QA Gate
 @pm      @architect         @sm         @dev        @qa
          reads PRD          reads both  reads story  reads story
```

> Every artifact builds on the previous one. No information is lost, no context is invented.

---

### Story Anatomy

A story is a self-contained unit of work. Each section has a clear purpose and owner.

```
┌─────────────────────────────────────────────────────────────┐
│  # Story 1.3: Implement User Authentication                 │
│                                                             │
│  ┌─ Status & Metadata ────────────────────────────────────┐ │
│  │ Status: Ready  |  Epic: Auth  |  Executor: @dev        │ │
│  │ @sm creates → @po approves → status transitions        │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ Story Statement ──────────────────────────────────────┐ │
│  │ "As a user, I want to log in, so that I can access     │ │
│  │  my dashboard."                                         │ │
│  │ Extracted directly from PRD. Defines the WHY.          │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ Acceptance Criteria ──────────────────────────────────┐ │
│  │ 1. Given valid credentials, When I submit, Then I see  │ │
│  │    the dashboard.                                       │ │
│  │ Testable. Numbered. @qa uses these to validate.        │ │
│  │ 📌 Owned by @po — only @po can edit ACs.              │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ Scope ────────────────────────────────────────────────┐ │
│  │ IN: Login form, JWT tokens, session management          │ │
│  │ OUT: Password reset, OAuth, 2FA                         │ │
│  │ Prevents scope creep. Clear boundaries.                 │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ Tasks / Subtasks ────────────────────────────────────┐  │
│  │ - [x] Create login endpoint (AC: 1)                   │  │
│  │   - [x] Add JWT generation                            │  │
│  │   - [x] Add password hashing                          │  │
│  │ - [ ] Create login form (AC: 1, 2)                    │  │
│  │ Checkboxes @dev marks. Subtasks are granular.          │  │
│  │ Each task references which AC it satisfies.            │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─ Dev Notes ────────────────────────────────────────────┐ │
│  │ Source tree, architecture patterns, data models, API   │ │
│  │ specs, testing standards. Everything @dev needs.       │ │
│  │ 📌 @dev edits this section during implementation.     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ File List ────────────────────────────────────────────┐ │
│  │ | File          | Action  | Description              | │ │
│  │ | src/auth.ts   | Created | JWT auth module           | │ │
│  │ | src/login.tsx | Created | Login form component      | │ │
│  │ 📌 @dev updates as files are created/modified.       │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ Dev Agent Record ────────────────────────────────────┐  │
│  │ Model: claude-opus | Mode: interactive                │  │
│  │ Debug Log: logs/1.3-debug.md                          │  │
│  │ 📌 @dev fills during implementation.                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─ QA Results ───────────────────────────────────────────┐ │
│  │ Verdict: PASS | Issues: 0 critical, 1 minor           │ │
│  │ 📌 Only @qa can write in this section.               │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ Change Log ───────────────────────────────────────────┐ │
│  │ | 2026-02-20 | @sm  | Story created (Draft)          | │ │
│  │ | 2026-02-20 | @po  | Validated → Ready              | │ │
│  │ | 2026-02-21 | @dev | Implementation complete         | │ │
│  │ 📌 Any agent can append. Append-only.                │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Section Ownership:**

| Section | Owner | Who Can Edit |
|---------|-------|-------------|
| Status & Metadata | Transition owner | Agent responsible for the transition |
| Story Statement | @po | @po only |
| Acceptance Criteria | @po | @po only |
| Scope (IN/OUT) | @po | @po only |
| Tasks / Subtasks | @dev | @dev only (checkboxes) |
| Dev Notes | @dev | @dev only |
| File List | @dev | @dev only |
| Dev Agent Record | @dev | @dev only |
| QA Results | @qa | @qa only |
| Change Log | Shared | Any agent (append-only) |

---

## The Team

| | Agent | Role | Activate | When to Use |
|---|-------|------|----------|-------------|
| 💻 | **@dev** | Developer | `@dev` | Code implementation, debugging, testing |
| ✅ | **@qa** | QA Engineer | `@qa` | Quality gates, code review, QA loops |
| 🌊 | **@sm** | Scrum Master | `@sm` | Story creation, sprint planning |
| 🎯 | **@po** | Product Owner | `@po` | Story validation, backlog management |
| 📋 | **@pm** | Product Manager | `@pm` | Epic creation, PRD, requirements |
| 🏗️ | **@architect** | Technical Architect | `@architect` | Architecture, tech decisions, complexity |
| 🚀 | **@devops** | DevOps Engineer | `@devops` | Git push, PRs, CI/CD, releases |
| 🗄️ | **@data-engineer** | Data Engineer | `@data-engineer` | Schema design, migrations, queries |
| 🔍 | **@analyst** | Business Analyst | `@analyst` | Research, competitive analysis |
| 🎨 | **@ux-designer** | UX Designer | `@ux-designer` | UI/UX design, accessibility, wireframes |
| 🎭 | **@master** | Framework Orchestrator | `@master` | Workflow orchestration, conflict resolution |

> After activating any agent, use `*help` to see available commands.

---

### 💻 @dev — Developer

Expert senior engineer that implements stories following validated specifications. Works in three execution modes depending on complexity and risk.

**When to use:**
- Code implementation and debugging
- Refactoring and optimization
- Running tests and applying QA fixes

**Commands:**

```
*develop {story-id} [mode]   Implement story (autopilot | interactive | preflight)
*develop-autopilot {story-id}  Autonomous mode — 0-1 prompts
*apply-qa-fixes              Apply fixes from QA feedback
*run-tests                   Run lint, typecheck, and tests
*coderabbit-review           Pre-commit automated review
```

**Execution Modes:**

| Mode | Prompts | Best For |
|------|---------|----------|
| **Autopilot** | 0-1 | Simple, deterministic tasks. Decisions logged automatically. |
| **Interactive** | 5-10 | Default. Confirmations at key decision points. |
| **Pre-Flight** | 10-15 | Ambiguous or critical work. All questions upfront, then zero-ambiguity execution. |

**Authority:**
- ✅ `git add`, `git commit`, `git branch`, `git checkout` (local operations)
- ✅ Update checkboxes, File List, Dev Notes, Change Log in stories
- ❌ `git push`, `gh pr create` → delegate to **@devops**
- ❌ Edit story Title, Description, AC, Scope → owned by **@po**

> **Activate:** `@dev` — then `*help` for commands.

---

### ✅ @qa — QA Engineer

Test architect with quality advisory authority. Goes deep on risk signals, stays concise when risk is low. Provides thorough quality assessment with actionable recommendations.

**When to use:**
- Quality gate reviews and code review
- Test strategy design
- Iterative QA loops (review-fix cycles)

**Commands:**

```
*qa-gate {story-id}          Execute 7-point quality gate
*code-review {story-id}      Comprehensive code review
*qa-loop {story-id}          Start iterative review-fix cycle (max 5)
*test-strategy {story-id}    Design test approach
*stop-qa-loop                Pause and save state
*resume-qa-loop              Resume from saved state
```

**7-Point Quality Gate:**

| # | Check | What's Verified |
|---|-------|-----------------|
| 1 | Code review | Patterns, readability, maintainability |
| 2 | Unit tests | Coverage, all passing |
| 3 | Acceptance criteria | All ACs met per story |
| 4 | No regressions | Existing functionality preserved |
| 5 | Performance | Within acceptable limits |
| 6 | Security | OWASP basics verified |
| 7 | Documentation | Updated if necessary |

**Gate Decisions:**

| Verdict | Meaning | Next Step |
|---------|---------|-----------|
| **PASS** | All checks OK | Proceed to @devops for push |
| **CONCERNS** | Minor issues | Approve with observations documented |
| **FAIL** | Critical issues | Return to @dev with specific feedback |
| **WAIVED** | Issues accepted | Approve with waiver (rare) |

> **Activate:** `@qa` — then `*help` for commands.

---

### 🌊 @sm — Scrum Master

Creates detailed, actionable stories from epics and PRDs that developers can implement without confusion. Bridges the gap between planning and execution.

**When to use:**
- Creating user stories from epic/PRD
- Breaking down epics into stories
- Sprint planning and story refinement

**Commands:**

```
*create {epic-id}     Create next story from epic
*draft {story-id}     Draft or refine a story
*list-stories         List all stories
*branch {name}        Create local git branch
```

**Authority:**
- ✅ Create story files, read PRD/architecture/epic docs
- ✅ Local git branch operations (`checkout -b`, `branch`)
- ❌ Validate stories → **@po**
- ❌ Implement code → **@dev**

> **Activate:** `@sm` — then `*help` for commands.

---

### 🎯 @po — Product Owner

Validates artifact cohesion using a rigorous 10-point checklist and ensures development aligns with product goals. The gatekeeper between planning and implementation.

**When to use:**
- Story validation (GO / NO-GO decisions)
- Backlog management and prioritization
- Acceptance criteria refinement

**Commands:**

```
*validate {story-id}          Validate with 10-point checklist
*backlog-add {type}           Add item to backlog
*backlog-list                 Show current backlog
*prioritize                   Re-prioritize backlog items
*story-context {epic-id}      Show story context within epic
```

**10-Point Validation Checklist:**

| # | Criterion | What's Checked |
|---|-----------|----------------|
| 1 | Clear title | Objective and descriptive |
| 2 | Complete description | Problem/need explained with context |
| 3 | Testable ACs | Given/When/Then format preferred |
| 4 | Defined scope | IN and OUT clearly listed |
| 5 | Dependencies | Prerequisite stories/resources mapped |
| 6 | Complexity estimate | Points or T-shirt sizing |
| 7 | Business value | Benefit to user/business clear |
| 8 | Risks | Potential problems identified |
| 9 | Criteria of Done | Clear definition of complete |
| 10 | PRD/Epic alignment | Consistency with source docs |

**Decision:** GO (≥7/10) or NO-GO (<7/10 with required fixes)

> **Critical rule:** When verdict is GO, @po MUST update story status from `Draft → Ready`. A story left in Draft after a GO verdict is a process violation.

> **Activate:** `@po` — then `*help` for commands.

---

### 📋 @pm — Product Manager

Transforms business needs into clear requirements and manages epic-level execution. Deeply understands the "why" behind every feature.

**When to use:**
- Epic creation and management
- PRD writing and requirements gathering
- Feature specification and spec pipeline

**Commands:**

```
*create-epic {name}          Create new epic
*execute-epic {id}           Start epic execution
*gather-requirements         Interactive requirements session
*write-spec {feature}        Write feature specification
*create-prd                  Create Product Requirements Document
```

**Authority:**
- ✅ Epic creation/management, PRD creation, requirements gathering, spec writing
- ❌ Story creation → **@sm**
- ❌ Story validation → **@po**

> **Activate:** `@pm` — then `*help` for commands.

---

### 🏗️ @architect — Technical Architect

Makes technology decisions, designs scalable and maintainable systems, and assesses project complexity. Views every component as part of a larger system.

**When to use:**
- Architecture decisions and technology selection
- High-level system design
- Complexity assessment (5 dimensions)

**Commands:**

```
*design {feature}               Create architectural design
*review {story-id}              Review implementation alignment
*assess-complexity              Assess project complexity (5 dimensions)
*tech-decision {topic}          Document technology decision
*document-architecture          Create/update architecture docs
```

**Complexity Assessment — 5 Dimensions (scored 1-5):**

| Dimension | What's Measured |
|-----------|----------------|
| **Scope** | Number of files/components affected |
| **Integration** | External APIs and service dependencies |
| **Infrastructure** | Infrastructure changes needed |
| **Knowledge** | Team familiarity with technology |
| **Risk** | Criticality and failure impact |

| Total Score | Class | Workflow Impact |
|-------------|-------|-----------------|
| ≤ 8 | **SIMPLE** | Spec Pipeline skips phases 2-3 |
| 9-15 | **STANDARD** | All phases execute |
| ≥ 16 | **COMPLEX** | All phases + revision cycle |

> **Activate:** `@architect` — then `*help` for commands.

---

### 🚀 @devops — DevOps Engineer

Has **exclusive authority** over remote git operations — no other agent can push code or create PRs. Repository integrity guardian.

**When to use:**
- Git push and PR creation/merge
- CI/CD pipeline management
- Release management and deployments

**Commands:**

```
*push {branch}           Push branch to remote
*create-pr {title}       Create pull request
*merge-pr {number}       Merge pull request
*release {version}       Create tagged release
*ci-status               Check CI/CD pipeline status
*deploy {env}            Deploy to environment
```

**Pre-Push Checklist (automated):**
1. `npm run lint` — no errors
2. `npm run typecheck` — no errors
3. `npm test` — all tests pass
4. `npm run build` — successful build
5. No CRITICAL CodeRabbit issues
6. Story status is InReview or Done

> **Exclusive operations:** `git push`, `git push --force`, `gh pr create`, `gh pr merge`, MCP management, CI/CD pipelines, release management. These are **blocked** for all other agents.

> **Activate:** `@devops` — then `*help` for commands.

---

### 🗄️ @data-engineer — Data Engineer

Implements data architecture. Translates high-level decisions from @architect into optimized schemas, queries, and migrations. Guardian of data integrity.

**When to use:**
- Schema design and database migrations
- Query optimization and index strategy
- RLS policies and security at the data layer

**Commands:**

```
*schema-design {feature}     Design schema for feature
*schema-audit                Audit existing database schema
*optimize-queries            Analyze and optimize slow queries
*create-migration {name}     Create database migration
*rollback-plan {migration}   Create rollback procedure
```

**Authority:**
- ✅ Detailed DDL, query optimization, RLS policies, index strategy, migrations
- ❌ System architecture → **@architect**
- ❌ Application code → **@dev**

> **Activate:** `@data-engineer` — then `*help` for commands.

---

### 🔍 @analyst — Business Analyst

Gathers evidence-based information to support product and architecture decisions. Asks probing questions to uncover underlying truths.

**When to use:**
- Market research and competitive analysis
- Dependency research and feasibility assessment
- Strategic analysis and project briefing

**Commands:**

```
*research {topic}            Conduct focused research
*analyze-dependencies        Analyze dependencies and risks
*competitive-analysis        Research competitive landscape
*feasibility {feature}       Assess feature feasibility
```

**Authority:**
- ✅ Research, read all project docs, produce analysis reports
- ❌ Architecture decisions → **@architect**
- ❌ Code implementation → **@dev**

> **Activate:** `@analyst` — then `*help` for commands.

---

### 🎨 @ux-designer — UX Designer

Creates intuitive, accessible, consistent interfaces. Combines user empathy with systems thinking. WCAG 2.1 AA compliance as baseline.

**When to use:**
- UI/UX design and wireframing
- Frontend audits and accessibility reviews
- Design system management

**Commands:**

```
*design-ui {feature}         Create UI design specification
*scan-frontend               Audit frontend for UX issues
*design-system               Review/update design system
*accessibility-review        Check WCAG compliance
*wireframe {screen}          Create wireframe specification
```

**Authority:**
- ✅ UI/UX specs, frontend audits, design system docs, accessibility reviews
- ❌ Code implementation → **@dev**
- ❌ Backend design → **@architect**

> **Activate:** `@ux-designer` — then `*help` for commands.

---

### 🎭 @master — Framework Orchestrator

The authority of last resort. Orchestrates multi-agent workflows, resolves conflicts between agents, and enforces framework governance. Can execute **any task directly** when needed.

**When to use:**
- Workflow orchestration and coordination
- Cross-agent conflict resolution
- Framework governance and overrides

**Commands:**

```
*orchestrate {workflow}    Start a full workflow
*status                    Show workflow/story status
*delegate {agent} {task}   Delegate to specific agent
*resolve {conflict}        Mediate agent conflicts
```

> **@master can override any agent boundary** when necessary for framework health.

> **Activate:** `@master` — then `*help` for commands.

---

## Workflows

### 1. Story Development Cycle (SDC) — Primary

The main workflow for all development work. Every feature, bug fix, or enhancement flows through these 4 phases.

```
┌─────────┐     ┌──────────┐     ┌───────────┐     ┌──────────┐
│  @sm     │────▶│  @po     │────▶│  @dev     │────▶│  @qa     │
│  Create  │     │ Validate │     │ Implement │     │  Review  │
└─────────┘     └──────────┘     └───────────┘     └──────────┘
                     │                                    │
                   NO-GO                                FAIL
                     │                                    │
                     ▼                                    ▼
                 @sm fixes                           @dev fixes
```

| Phase | Agent | Task | Output | Decision |
|-------|-------|------|--------|----------|
| **Create** | @sm | `create-next-story` | Story file (Draft) | — |
| **Validate** | @po | `validate-next-story` | Story (Ready) | GO (≥7/10) or NO-GO |
| **Implement** | @dev | `dev-develop-story` | Working code | Mode: autopilot/interactive/preflight |
| **Review** | @qa | `qa-gate` | QA verdict | PASS / CONCERNS / FAIL / WAIVED |

**Story Status Progression:**
```
Draft → Ready → InProgress → InReview → Done
  @sm    @po       @dev         @qa      @devops
```

---

### 2. Spec Pipeline — Pre-Implementation

Transforms informal requirements into executable specifications. Adapts to complexity — simple features skip assessment and research phases.

```
┌─────────┐     ┌────────────┐     ┌───────────┐     ┌─────────┐     ┌──────────┐
│  @pm    │────▶│ @architect │────▶│ @analyst  │────▶│  @pm    │────▶│  @qa     │
│ Gather  │     │  Assess    │     │ Research  │     │  Spec   │     │ Critique │
└─────────┘     └────────────┘     └───────────┘     └─────────┘     └──────────┘
                     │                                                      │
                   SIMPLE ─────────────────────▶ @pm Spec           NEEDS_REVISION
                   (skip)                                                   │
                                                                           ▼
                                                                      @pm revise
```

| Complexity | Score | Phases | Duration |
|------------|-------|--------|----------|
| **SIMPLE** | ≤ 8 | Gather → Spec → Critique | 3 phases |
| **STANDARD** | 9-15 | All 5 phases | Full pipeline |
| **COMPLEX** | ≥ 16 | All 5 + revision cycle | Extended |

**Critique Verdicts:**

| Verdict | Avg Score | Next Step |
|---------|-----------|-----------|
| **APPROVED** | ≥ 4.0 | Ready for implementation |
| **NEEDS_REVISION** | 3.0-3.9 | Return to @pm for spec revision |
| **BLOCKED** | < 3.0 | Escalate to @architect |

---

### 3. Brownfield Discovery — Legacy Assessment

Multi-phase technical debt assessment for existing codebases. Data collection phases run in **parallel** for efficiency.

```
┌── @architect scan ──┐
│                     │
├── @data-eng audit  ─┤────▶ @architect draft ────▶ @qa review ────▶ @pm epics
│                     │              │                    │
└── @ux-designer scan─┘          NEEDS_WORK ◀──── NEEDS_WORK
```

| Phase | Agent | Task | Parallel | Output |
|-------|-------|------|----------|--------|
| **Architecture Scan** | @architect | `document-project` | ✅ | `system-architecture.md` |
| **Database Audit** | @data-engineer | `db-schema-audit` | ✅ | `SCHEMA.md` + `DB-AUDIT.md` |
| **Frontend Scan** | @ux-designer | `ux-scan-artifact` | ✅ | `frontend-spec.md` |
| **Draft Assessment** | @architect | `document-project` | — | `technical-debt-DRAFT.md` |
| **QA Review** | @qa | `qa-gate` | — | APPROVED or NEEDS_WORK |
| **Create Epics** | @pm | `create-epic` | — | Epic + stories |

---

### 4. QA Loop — Iterative Review

Automated review-fix cycle after the initial QA gate. Runs a maximum of 5 iterations before escalation.

```
┌──────────┐     ┌──────────┐
│  @qa     │────▶│  @dev    │──┐
│  Review  │     │   Fix    │  │
└──────────┘     └──────────┘  │
     ▲                         │
     └─────────────────────────┘
          (max 5 iterations)

     APPROVE → Done
     BLOCKED → @master escalation
```

| Verdict | Action |
|---------|--------|
| **APPROVE** | Complete — story moves to Done |
| **REJECT** | @dev fixes, then re-review |
| **BLOCKED** | Immediate escalation to @master |

**Escalation Triggers:**
- `max_iterations_reached` — 5 review-fix cycles without resolution
- `verdict_blocked` — QA identifies a systemic issue
- `fix_failure` — @dev cannot resolve the issue
- `manual_escalate` — User forces escalation via `*escalate-qa-loop`

---

## Authority Matrix

Who can do what — clear boundaries prevent conflicts.

| Operation | @dev | @qa | @sm | @po | @pm | @architect | @devops | @master |
|-----------|:----:|:---:|:---:|:---:|:---:|:----------:|:-------:|:-------:|
| Write code | ✅ | — | — | — | — | — | — | ✅ |
| `git commit` | ✅ | — | — | — | — | — | — | ✅ |
| `git push` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Create PR | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Create story | — | — | ✅ | — | — | — | — | ✅ |
| Validate story | — | — | — | ✅ | — | — | — | ✅ |
| Create epic | — | — | — | — | ✅ | — | — | ✅ |
| QA verdict | — | ✅ | — | — | — | — | — | ✅ |
| Arch decisions | — | — | — | — | — | ✅ | — | ✅ |
| Schema DDL | — | — | — | — | — | — | — | ✅ |

> **@devops** has **exclusive** authority over remote git operations. **@master** can override any boundary when necessary for framework health.

---

## Tasks Reference

### Story Development Cycle

| Task | Agent | Purpose |
|------|-------|---------|
| `create-next-story` | @sm | Create a story from epic/PRD |
| `validate-next-story` | @po | Validate with 10-point checklist |
| `dev-develop-story` | @dev | Implement the story (3 modes) |
| `qa-gate` | @qa | Execute 7-point quality gate |

### Spec Pipeline

| Task | Agent | Purpose |
|------|-------|---------|
| `spec-gather-requirements` | @pm | Interactive requirements gathering |
| `spec-assess-complexity` | @architect | Score complexity across 5 dimensions |
| `spec-research-dependencies` | @analyst | Research dependencies and risks |
| `spec-write-spec` | @pm | Write formal specification |
| `spec-critique` | @qa | Review spec quality and completeness |

### Brownfield Discovery

| Task | Agent | Purpose |
|------|-------|---------|
| `document-project` | @architect | Scan and document system architecture |
| `db-schema-audit` | @data-engineer | Audit database schema and data model |
| `ux-scan-artifact` | @ux-designer | Audit frontend for UX and accessibility |

### QA Loop

| Task | Agent | Purpose |
|------|-------|---------|
| `qa-review-story` | @qa | Detailed code review with verdict |
| `dev-apply-qa-fixes` | @dev | Apply fixes from QA feedback |
| `qa-backlog-add-followup` | @qa | Add follow-up items to backlog |

### Support

| Task | Agent | Purpose |
|------|-------|---------|
| `orchestrate` | @master | Start/manage a workflow |
| `orchestrate-status` | @master | Check workflow progress |
| `orchestrate-resume` | @master | Resume paused workflow |
| `po-manage-backlog` | @po | Manage and prioritize backlog |
| `create-epic` | @pm | Create a new epic with stories |

---

## Squad Presets

Pre-configured team compositions for different project needs.

| Squad | Agents | Best For |
|-------|--------|----------|
| **minimal** | @dev, @qa | Quick fixes, small tasks |
| **sdc-core** | @sm, @po, @dev, @qa | Standard story development |
| **full-stack** | @sm, @po, @dev, @qa, @architect, @devops | Full feature development with architecture |
| **complete** | All 11 agents | Complex projects, brownfield discovery |

---

## Commands Cheat Sheet

All agent commands use the `*` prefix. Activate an agent first (`@agent`), then run commands.

| Agent | Command | Description |
|-------|---------|-------------|
| **@dev** | `*develop {story} [mode]` | Implement story (autopilot/interactive/preflight) |
| | `*develop-autopilot {story}` | Autonomous implementation (0-1 prompts) |
| | `*apply-qa-fixes` | Apply fixes from QA feedback |
| | `*run-tests` | Run lint, typecheck, and tests |
| | `*coderabbit-review` | Pre-commit automated review |
| **@qa** | `*qa-gate {story}` | Execute 7-point quality gate |
| | `*code-review {story}` | Comprehensive code review |
| | `*qa-loop {story}` | Start review-fix cycle (max 5) |
| | `*test-strategy {story}` | Design test approach |
| | `*stop-qa-loop` | Pause and save loop state |
| | `*resume-qa-loop` | Resume from saved state |
| **@sm** | `*create {epic}` | Create next story from epic |
| | `*draft {story}` | Draft or refine a story |
| | `*list-stories` | List all stories |
| | `*branch {name}` | Create local git branch |
| **@po** | `*validate {story}` | Validate with 10-point checklist |
| | `*backlog-add {type}` | Add item to backlog |
| | `*backlog-list` | Show current backlog |
| | `*prioritize` | Re-prioritize backlog |
| | `*story-context {epic}` | Show story context within epic |
| **@pm** | `*create-epic {name}` | Create new epic |
| | `*execute-epic {id}` | Start epic execution |
| | `*gather-requirements` | Interactive requirements session |
| | `*write-spec {feature}` | Write feature specification |
| | `*create-prd` | Create Product Requirements Document |
| **@architect** | `*design {feature}` | Create architectural design |
| | `*review {story}` | Review implementation alignment |
| | `*assess-complexity` | Assess complexity (5 dimensions) |
| | `*tech-decision {topic}` | Document technology decision |
| | `*document-architecture` | Create/update architecture docs |
| **@devops** | `*push {branch}` | Push branch to remote |
| | `*create-pr {title}` | Create pull request |
| | `*merge-pr {number}` | Merge pull request |
| | `*release {version}` | Create tagged release |
| | `*ci-status` | Check CI/CD pipeline status |
| | `*deploy {env}` | Deploy to environment |
| **@data-engineer** | `*schema-design {feature}` | Design schema for feature |
| | `*schema-audit` | Audit existing database schema |
| | `*optimize-queries` | Analyze and optimize queries |
| | `*create-migration {name}` | Create database migration |
| | `*rollback-plan {migration}` | Create rollback procedure |
| **@analyst** | `*research {topic}` | Conduct focused research |
| | `*analyze-dependencies` | Analyze dependencies and risks |
| | `*competitive-analysis` | Research competitive landscape |
| | `*feasibility {feature}` | Assess feature feasibility |
| **@ux-designer** | `*design-ui {feature}` | Create UI design specification |
| | `*scan-frontend` | Audit frontend for UX issues |
| | `*design-system` | Review/update design system |
| | `*accessibility-review` | Check WCAG compliance |
| | `*wireframe {screen}` | Create wireframe specification |
| **@master** | `*orchestrate {workflow}` | Start a full workflow |
| | `*status` | Show workflow/story status |
| | `*delegate {agent} {task}` | Delegate to specific agent |
| | `*resolve {conflict}` | Mediate agent conflicts |

---

## CodeRabbit Integration

Automated code review integrated into the development workflow.

**Dev Phase (@dev):**
- Mode: light | Max iterations: 2
- CRITICAL → auto-fix | HIGH → auto-fix or document | MEDIUM/LOW → ignore

**QA Phase (@qa):**
- Mode: full | Max iterations: 3
- CRITICAL/HIGH → auto-fix | MEDIUM → document as tech debt | LOW → ignore

---

## Project Structure

After running `nexos init --tool claude-code` and installing this pack, your project looks like this:

```
my-project/
├── .nexos/                          # nexos local config
│   ├── config.yaml                  # Tool, packs, project settings
│   └── lock.yaml                    # Pinned pack versions
│
├── .claude/                         # Generated by Claude Code adapter
│   ├── CLAUDE.md                    # Agent system + rules (auto-generated)
│   └── rules/                       # Pack rules (auto-generated)
│       ├── story-lifecycle.md
│       ├── workflow-execution.md
│       ├── agent-authority.md
│       └── coderabbit-integration.md
│
├── AGENTS.md                        # Universal agent reference (always generated)
│
├── docs/
│   ├── prd/                         # Product Requirements Documents
│   │   └── my-feature-prd.md
│   ├── architecture/                # Architecture docs
│   │   └── system-architecture.md
│   └── stories/                     # Story files
│       ├── epics/
│       │   └── epic-auth/
│       │       └── EPIC.md
│       └── 1.1.setup.story.md       # Individual stories
│
├── gates/                           # QA gate files
│   └── 1.1-setup.yml
│
└── src/                             # Your application code
    └── ...
```

> The `.claude/` folder is auto-generated by `nexos generate`. For Gemini CLI it generates `GEMINI.md` + `.gemini/`. For Antigravity it generates `.agent/`.

---

## Glossary

| Term | Definition |
|------|-----------|
| **Story** | Self-contained unit of work with ACs, tasks, and clear ownership. The primary development artifact. |
| **Epic** | Collection of related stories that deliver a larger feature or capability. |
| **PRD** | Product Requirements Document — the source of truth for business requirements. |
| **AC** | Acceptance Criteria — testable conditions (Given/When/Then) that define when a story is complete. |
| **SDC** | Story Development Cycle — the 4-phase primary workflow (Create → Validate → Implement → Review). |
| **Quality Gate** | Mandatory validation checkpoint before progressing to the next phase. |
| **Spec Pipeline** | Pre-implementation workflow that transforms informal requirements into formal specifications. |
| **Brownfield** | Existing project that needs assessment, migration, or improvement. |
| **Greenfield** | New project built from scratch. |
| **Dev Notes** | Section in each story containing all technical context a developer needs (source tree, patterns, testing standards). |
| **Gate File** | YAML file produced by @qa containing verdict (PASS/FAIL), issues, and recommendations. |
| **Pack** | Domain-specific content package for nexos (agents, tasks, workflows, rules). Installable from a Git repo. |
| **Adapter** | Generator that translates pack content into tool-specific configuration files (Claude Code, Gemini CLI, etc.). |
| **QA Loop** | Iterative review-fix cycle (max 5 iterations) between @qa and @dev after initial QA gate. |
| **File List** | Table in each story tracking every file created, modified, or deleted during implementation. |
| **Change Log** | Append-only history in each story recording every agent action and status transition. |

---

## Installation

```bash
nexos install thiagoneves/nexos-pack-software-dev
```

**Requirements:**
- [nexos](https://github.com/thiagoneves/nexos) CLI installed
- Project initialized with `nexos init --tool <tool>`

**Supported Tools:**
- Claude Code (`nexos init --tool claude-code`)
- Gemini CLI (`nexos init --tool gemini-cli`)
- Antigravity (`nexos init --tool antigravity`)

---

## License

MIT
