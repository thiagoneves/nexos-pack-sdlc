---
task: create-epic
agent: pm
workflow: support
inputs: [user requirements, project context, existing epics]
outputs: [epic document, story candidates, execution plan]
---

# Create Epic

## Purpose

Create a new epic that defines a large body of work, then break it down into
individual stories that can be developed through the Story Development Cycle.
This task is owned by the @pm agent and results in a structured epic document
plus a set of story candidates ready for creation by @sm.

An epic bridges the gap between high-level goals and implementable stories. It
establishes scope, identifies dependencies, sequences work into a logical order,
and provides the foundation for all downstream development activity.

---

## Prerequisites

- User has a feature, initiative, or body of work to define
- Project structure is initialized (stories and epics directories exist or can be created)
- @pm agent has authority for epic creation (per agent-authority rules)
- Configuration file (`config.yaml`) present with `storiesDir` and `epicsDir` paths

---

## When to Use This Task

**Use this task when:**
- The initiative requires 3-10 stories to complete
- Multiple areas of the codebase or system will be affected
- Work needs to be sequenced with dependencies between stories
- Stakeholder alignment on scope is needed before development starts
- The initiative is large enough to benefit from structured planning

**Use a single story instead when:**
- The work can be completed in 1-2 development sessions
- The change is isolated to a single area
- No dependency management is needed

**Use the Spec Pipeline first when:**
- Requirements are unclear or ambiguous
- Significant research is needed before planning
- Technical feasibility is uncertain
- The initiative involves unfamiliar technology or integrations

---

## Execution Modes

### 1. Autopilot Mode -- Fast, Autonomous (1-3 prompts)

- Gather minimal context from the user (goal + constraints)
- Auto-generate the epic structure based on stated goals
- Apply standard story breakdown patterns:
  - Foundation stories first (setup, infrastructure, data model)
  - Feature stories next (core functionality)
  - Integration stories (connecting components)
  - Polish stories last (UX, performance, documentation)
- Present the complete epic for approval with a single confirmation
- **Best for:** Well-understood features, experienced teams, rapid iteration

### 2. Interactive Mode -- Balanced, Educational (5-12 prompts) **[DEFAULT]**

- Structured conversation to gather context (Step 1)
- Collaborative scope definition with trade-off discussions
- Interactive story breakdown with rationale explanations
- Present epic plan and iterate based on feedback
- **Best for:** New features, scope negotiation, team alignment

### 3. Pre-Flight Mode -- Comprehensive Upfront Planning

- Deep requirements gathering (10-15 questions)
- Full context analysis (existing code, architecture, related epics)
- Risk assessment for each story candidate
- Dependency analysis with critical path identification
- Resource estimation and timeline projection
- Complete epic plan with alternatives for user review
- **Best for:** Large initiatives, high-risk features, executive-facing plans

**Default mode:** Interactive

---

## Steps

### 1. Gather Epic Context

Conduct a structured conversation with the user to understand the initiative.
Adapt the questions based on what the user has already provided -- skip questions
that are already answered.

#### Core Questions (always ask)

| Question | Purpose |
|----------|---------|
| What is the desired outcome? | Define the epic's goal |
| What problem does this solve? Who benefits? | Establish business value |
| What are the hard constraints? (timeline, technology, budget) | Set boundaries |

#### Contextual Questions (ask as needed)

| Question | When to Ask |
|----------|-------------|
| Who are the target users? What are their needs? | User-facing features |
| What existing functionality does this touch? | Brownfield enhancements |
| Are there related PRDs, specs, or prior discussions? | When references exist |
| What does success look like? How will it be measured? | When metrics matter |
| Are there regulatory or compliance requirements? | Regulated domains |
| What is the technical starting point? (existing code, stack) | New team members |

#### Information Capture Format

```yaml
epic_context:
  goal: {1-2 sentence statement of the desired outcome}
  problem: {what problem this solves}
  target_users: {who benefits}
  business_value: {why this is worth doing}
  success_metrics:
    - {metric 1}
    - {metric 2}
  constraints:
    timeline: {if any}
    technology: {if any}
    budget: {if any}
    compliance: {if any}
  existing_context:
    - {reference 1}
    - {reference 2}
```

**In Autopilot mode:**
- Accept what the user provides without additional questions
- Fill gaps with reasonable defaults and flag them as assumptions

**In Interactive mode:**
- Ask questions one at a time or in small groups
- Summarize understanding after each answer to confirm

**In Pre-Flight mode:**
- Ask all questions upfront in a structured questionnaire
- Then present a comprehensive context summary for approval

### 2. Check Existing Epics

Before creating a new epic, check for related existing work:

1. Scan the epics directory for existing epic documents
2. For each existing epic, check for:
   - Overlapping scope (goals or features that intersect)
   - Dependency relationships (new epic depends on or extends existing)
   - Conflicts (mutually exclusive approaches or features)
3. If overlaps are found, present them to the user:
   ```
   Related existing epic found:
     Epic 3: "User Authentication System"
     Overlap: Both include password reset functionality

   Options:
     1. Merge new scope into Epic 3 (extend existing)
     2. Create new epic, exclude overlapping scope
     3. Create new epic, accept overlap (intentional duplication)
   ```

### 3. Define Epic Scope

Establish clear boundaries for the epic:

#### In Scope

List the specific capabilities, features, or changes included. Be concrete:

```markdown
**IN Scope:**
- {Capability 1}: {brief description of what is included}
- {Capability 2}: {brief description}
- {Minimum viable scope}: {what must be in the first iteration}
```

#### Out of Scope

Explicitly list what this epic does NOT cover. This is critical for preventing
scope creep during development:

```markdown
**OUT of Scope:**
- {Item 1}: {why excluded, when it might be addressed}
- {Item 2}: {why excluded}
- {Deferred items}: {explicitly noted for future consideration}
```

**Scope validation checklist:**
- [ ] Every In Scope item maps to the epic goal
- [ ] Every Out of Scope item has a reason for exclusion
- [ ] The minimum viable scope is clearly identified
- [ ] No In Scope item duplicates existing epic scope

### 4. Identify and Structure Stories

Break the epic into discrete, implementable stories using a systematic approach:

#### 4.1 Identify Functional Areas

Map the In Scope items to functional areas:

| Functional Area | Scope Items | Story Candidates |
|-----------------|-------------|-----------------|
| {area 1} | {items from scope} | {1-3 stories} |
| {area 2} | {items from scope} | {1-3 stories} |

#### 4.2 Apply Story Breakdown Patterns

Use these patterns to ensure complete coverage:

**Layer-based breakdown (for full-stack features):**
1. Data model / schema story
2. Backend / API story
3. Frontend / UI story
4. Integration / end-to-end story

**Flow-based breakdown (for user journeys):**
1. Happy path story
2. Error handling story
3. Edge cases story

**Maturity-based breakdown (for iterative delivery):**
1. Foundation / MVP story
2. Enhancement story
3. Polish / optimization story

#### 4.3 Size Each Story

Each story should be completable in 1-3 development sessions. Use this guide:

| Size | Points | Sessions | Characteristics |
|------|--------|----------|----------------|
| S | 1-2 | 1 | Single file change, clear requirements |
| M | 3-5 | 1-2 | Multi-file change, well-understood domain |
| L | 8 | 2-3 | Cross-cutting change, some ambiguity |
| XL | 13+ | 3+ | **Too large -- must be split** |

If any story is XL, split it into smaller stories before proceeding.

#### 4.4 Map Dependencies

For each story, identify:
- **Depends on:** Stories that must complete before this one can start
- **Blocks:** Stories that cannot start until this one completes
- **Can parallel:** Stories that can be developed simultaneously

**Dependency rules:**
- Minimize dependencies -- prefer independent stories where possible
- Data model stories typically must come first
- UI stories can often parallel backend stories
- Integration stories depend on their component stories

**Detect circular dependencies:**
If A depends on B and B depends on A, flag immediately and restructure.

#### 4.5 Assign Priority

For each story:

| Priority | Meaning | Criteria |
|----------|---------|----------|
| Must | Required for the epic to deliver value | Core functionality, blocking others |
| Should | Important but epic functions without it | Enhancements, secondary flows |
| Could | Nice to have, include if time permits | Polish, optimization |
| Won't | Explicitly excluded from this iteration | Future work |

#### 4.6 Plan Execution Waves (for large epics)

If the epic has 5+ stories, organize into execution waves:

```
Wave 1: Foundation
  - Story 1: {title} (no dependencies)
  - Story 2: {title} (no dependencies)
  -> Can run in parallel

Wave 2: Core Features
  - Story 3: {title} (depends on Story 1)
  - Story 4: {title} (depends on Story 2)
  -> Can run in parallel after Wave 1

Wave 3: Integration
  - Story 5: {title} (depends on Stories 3, 4)
  -> Must wait for Wave 2
```

### 5. Create Epic Document

Assemble the epic document using `templates/epic.md`:

```markdown
# Epic {epicNum}: {Title}

**Status:** Planning
**Owner:** @pm
**Created:** {date}
**PRD Reference:** {path or "N/A"}

---

## Objective

{2-3 sentences: what this epic delivers and why it matters}

## Business Value

{How this epic delivers value -- quantifiable if possible}

---

## Scope

**IN:**
- {in_scope_1}
- {in_scope_2}

**OUT:**
- {out_scope_1}
- {out_scope_2}

---

## Stories

| ID | Title | Points | Priority | Status | Dependencies |
|----|-------|--------|----------|--------|-------------|
| {epicNum}.1 | {title} | {estimate} | {Must/Should/Could} | Draft | -- |
| {epicNum}.2 | {title} | {estimate} | {Must/Should/Could} | Draft | {epicNum}.1 |

**Total Points:** {total}

---

## Execution Waves

### Wave 1: {name}
- Stories: {list}
- Parallel: {yes/no}
- Gate: {what to verify before next wave}

### Wave 2: {name}
- Stories: {list}
- Dependencies: Wave 1 complete
- Gate: {verification}

---

## Compatibility Requirements

- [ ] Existing APIs remain unchanged (if brownfield)
- [ ] Database schema changes are backward compatible
- [ ] UI changes follow existing patterns
- [ ] Performance impact is minimal

## Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {risk} | {Low/Medium/High} | {Low/Medium/High} | {mitigation} |

**Rollback Plan:** {how to undo changes if needed}

---

## Success Criteria

- [ ] {criterion_1}
- [ ] {criterion_2}
- [ ] {criterion_3}

---

## Dependencies

**Depends on:**
- {dependency_1}

**Blocks:**
- {blocked_item_1}

---

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| {date} | 1.0 | Epic created | @pm |
```

Save the epic document at: `{epicsDir}/epic-{epicNum}-{slug}/INDEX.md`

### 6. Present Epic Plan

Display the complete epic plan to the user:

```
=== Epic Plan: {Title} ===

Goal: {1-sentence goal}
Stories: {count} across {wave count} waves
Total Points: {total}
Estimated Effort: {rough estimate based on points}

Story Breakdown:
  Wave 1: {name}
    {epicNum}.1 -- {title} ({size}, Must) -- No dependencies
    {epicNum}.2 -- {title} ({size}, Must) -- No dependencies

  Wave 2: {name}
    {epicNum}.3 -- {title} ({size}, Should) -- Depends on .1
    {epicNum}.4 -- {title} ({size}, Should) -- Depends on .2

  Wave 3: {name}
    {epicNum}.5 -- {title} ({size}, Could) -- Depends on .3, .4

Risks:
  - {risk 1}: {mitigation}
  - {risk 2}: {mitigation}

Approve this plan? (approve / modify / cancel)
```

**In Autopilot mode:**
- Present the plan once and wait for approval

**In Interactive mode:**
- Present the plan and offer to modify specific sections
- Accept feedback and iterate until the user approves

**In Pre-Flight mode:**
- Present the plan with alternative options for structure/ordering
- Include detailed risk analysis for each alternative
- Require explicit approval of the final plan

### 7. Handle Modifications

If the user requests changes:

| Change Type | Action |
|-------------|--------|
| Add a story | Add to the breakdown, update dependencies and waves |
| Remove a story | Remove and update dependent stories |
| Reorder stories | Adjust wave assignments and dependencies |
| Change scope | Return to Step 3, preserve valid stories |
| Split a story | Create two stories from one, reassign dependencies |
| Merge stories | Combine, verify the result is not XL |
| Change priority | Update priority, may affect wave ordering |

After modifications, re-present the updated plan for approval.

### 8. On Approval -- Create Artifacts

Once the user approves the epic plan:

#### 8.1 Create Epic Directory

```
{epicsDir}/epic-{epicNum}-{slug}/
  INDEX.md          <- Epic document (created in Step 5)
  EXECUTION.yaml    <- Execution plan (for wave-based execution)
```

#### 8.2 Generate Execution Plan (EXECUTION.yaml)

```yaml
execution:
  epicId: {epicNum}
  title: {title}
  storyBasePath: {storiesDir}
  template: story-development-cycle

  stories:
    {epicNum}.1:
      title: {title}
      file: {epicNum}.1.story.md
      complexity: {S/M/L}
      priority: {Must/Should/Could}
      branch: feat/{slug}-{story-slug}
      key_files: [{estimated files to be changed}]

  waves:
    1:
      name: {wave name}
      stories: [{story IDs}]
      parallel: {true/false}
      dependencies: []
      gate:
        focus: {what to verify}
    2:
      name: {wave name}
      stories: [{story IDs}]
      dependencies: [1]
      gate:
        focus: {what to verify}
```

#### 8.3 Hand Off Stories to @sm

For each story in the approved plan:
1. Delegate to @sm to create the story file using `create-next-story`
2. Pass: epic context, story title, story description, ACs, dependencies, priority
3. Stories are created in the wave order
4. Each story references the parent epic

#### 8.4 Log Creation

Add a Change Log entry to the epic document:
```
| {date} | 1.0 | Epic created with {N} stories across {M} waves | @pm |
```

### 9. Post-Creation Report

After all artifacts are created, report to the user:

```
=== Epic Created: {Title} ===

Epic document: {path to INDEX.md}
Execution plan: {path to EXECUTION.yaml}

Stories created:
  {epicNum}.1 -- {title} (Draft)
  {epicNum}.2 -- {title} (Draft)
  ...

Next Steps:
  1. Validate stories: @po *validate {epicNum}.1 (then .2, .3, etc.)
  2. Start development: @master *orchestrate (after stories are Ready)
  3. Or execute the epic plan: @pm *execute-epic {path to EXECUTION.yaml}
```

---

## Constraints

### Story Count Limits

| Count | Action |
|-------|--------|
| 1-2 stories | Consider if this needs to be an epic at all. May be better as standalone stories. |
| 3-10 stories | Ideal epic size. Proceed normally. |
| 11-15 stories | Large epic. Consider splitting into 2 epics with clear boundaries. |
| 16+ stories | Must split. Too large for effective management. |

### Scope Boundaries

- Every story MUST trace back to an In Scope item
- No story may address an Out of Scope item
- If implementation reveals needed scope changes, update the epic document first

### Dependency Limits

- Maximum dependency chain depth: 5 (if deeper, restructure)
- Maximum stories depending on a single story: 4 (if more, it is a bottleneck -- consider splitting)
- No circular dependencies allowed

---

## Quality Assurance Strategy

Proactive quality planning during epic creation reduces risk:

- **All stories** should include pre-commit review tasks
- **Database stories** should include schema validation and migration safety checks
- **API stories** should include contract validation and backward compatibility checks
- **Deployment stories** should include configuration validation and rollback readiness
- **Each story** should include a task to verify existing functionality still works

**Quality gate alignment with risk:**

| Risk Level | Quality Gates |
|-----------|--------------|
| LOW | Pre-commit validation only |
| MEDIUM | Pre-commit + pre-PR validation |
| HIGH | Pre-commit + pre-PR + pre-deployment validation |

---

## Error Handling

- **Scope too large** -- If the story count exceeds 10 or complexity is overwhelming, suggest splitting into multiple epics. Help the user identify natural boundaries: by functional area, by user journey, by technical layer, or by priority tier.

- **Circular dependencies** -- Flag the cycle visually: "Story A -> B -> C -> A". Work with the user to break it by redefining story boundaries or introducing a shared foundation story.

- **User changes scope mid-creation** -- Return to Step 3 with the updated scope. Preserve any story definitions that remain valid under the new scope. Discard invalidated stories. Report what changed.

- **Insufficient information** -- If the user cannot answer key questions in Step 1, document the gaps as assumptions in the epic document. Flag each assumption as a risk. Mark affected stories as having assumption-based scope.

- **Epics directory not found** -- Create it at the configured or default path. Log the directory creation. Proceed normally.

- **Duplicate epic detected** -- If an existing epic has >70% scope overlap with the proposed epic, present the overlap and ask: "Merge into the existing epic or create a separate one?"

- **Story creation failure** -- If @sm fails to create a story file, log the failure, continue with remaining stories, and report the failures at the end. Offer to retry failed stories.

- **Naming conflicts** -- If a story ID conflicts with an existing story, auto-increment the ID and note the adjustment.

---

## Examples

### Example 1: Feature Epic (Interactive Mode)

```
User: "I want to add a payment processing feature"

@pm: "Let me gather context for the payment processing epic.
  1. What payment methods need to be supported?
  2. Is there an existing checkout flow to integrate with?
  3. Any compliance requirements (PCI-DSS, etc.)?"

User: "Credit cards and PayPal. Yes, we have a checkout page. PCI compliance needed."

@pm creates epic:
  Epic 5: Payment Processing
  Scope: Credit card + PayPal integration with existing checkout
  Stories:
    5.1 -- Payment data model and secure storage (M, Must)
    5.2 -- Credit card processor integration (L, Must)
    5.3 -- PayPal integration (M, Must)
    5.4 -- Checkout flow integration (M, Must, depends on 5.2, 5.3)
    5.5 -- Payment confirmation and receipts (S, Should)
    5.6 -- Refund handling (M, Should, depends on 5.4)
  Waves: [5.1] -> [5.2, 5.3] -> [5.4] -> [5.5, 5.6]
```

### Example 2: Small Enhancement (Autopilot Mode)

```
User: "Create an epic for adding dark mode support"

@pm auto-generates:
  Epic 8: Dark Mode Support
  Stories:
    8.1 -- Theme configuration and CSS variables (M, Must)
    8.2 -- Theme toggle component (S, Must)
    8.3 -- Apply theme to existing components (L, Must, depends on 8.1)
    8.4 -- Persist theme preference (S, Should, depends on 8.2)
  Waves: [8.1, 8.2] -> [8.3, 8.4]

  "Approve this plan? (approve / modify / cancel)"
```

### Example 3: Scope Too Large

```
User: "I want to rebuild the entire authentication system, add social login,
       implement RBAC, add audit logging, and build an admin dashboard"

@pm: "This scope maps to approximately 15-20 stories. I recommend splitting
  into 2-3 epics:
    Epic A: Authentication Rebuild (core auth + social login) -- 6 stories
    Epic B: Authorization and RBAC -- 5 stories (depends on Epic A)
    Epic C: Admin Dashboard and Audit -- 5 stories (depends on Epic B)

  Shall I create these as separate epics with dependencies?"
```

### Example 4: Brownfield Enhancement

```
User: "Add a notifications system to our existing app"

@pm gathers context:
  - Existing system: Node.js/React with PostgreSQL
  - Integration points: user service, email service
  - Constraint: must not break existing APIs

@pm creates epic:
  Epic 6: Notifications System - Brownfield Enhancement
  Compatibility Requirements:
    - Existing user API unchanged
    - Database changes backward compatible
    - No regression in existing features
  Stories:
    6.1 -- Notifications data model (M, Must)
    6.2 -- Notification service API (M, Must, depends on 6.1)
    6.3 -- Email integration (S, Should, depends on 6.2)
  Rollback Plan: Database migration includes down script, feature flag for UI
```

---

## Notes

- The @pm agent owns epic creation exclusively. Other agents may request epics but cannot create them directly.
- Stories created from epics are always in Draft status. They must go through @po validation before development.
- The execution plan (EXECUTION.yaml) is optional. It enables wave-based execution but is not required for manual story-by-story development.
- When creating stories for a brownfield (existing codebase) enhancement, always include compatibility requirements: existing APIs unchanged, database changes backward compatible, no regressions.
- Each story should include a verification task that confirms existing functionality still works after the story's changes.
- The epic document is a living document. Update it as stories progress and scope evolves.

---

## Related Tasks

| Task | Relationship |
|------|-------------|
| `create-next-story` | @sm creates individual stories from the epic breakdown |
| `validate-next-story` | @po validates stories created from the epic |
| `po-manage-backlog` | @po manages the backlog including epic-sourced stories |
| `orchestrate` | Routes epic execution requests |
| `dev-develop-story` | @dev implements individual stories from the epic |

## Related Templates

| Template | Usage |
|----------|-------|
| `templates/epic.md` | Epic document structure |
| `templates/story.md` | Story document structure (used by @sm during handoff) |
