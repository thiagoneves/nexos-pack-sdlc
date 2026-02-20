---
task: po-manage-backlog
agent: po
workflow: support
inputs: [story files, backlog file, epic context, user directives]
outputs: [prioritized backlog, updated story metadata, backlog health report]
---

# Manage Backlog

## Purpose

Product Owner's backlog management task. Review, prioritize, and organize
stories and backlog items. Ensure the backlog is healthy, prioritized, and
aligned with epic goals. This task gives the @po agent visibility into the
overall state of work and the ability to shape what gets developed next.

The backlog is the single source of truth for what work exists, what order it
should be done in, and what state each item is in. A healthy backlog is the
foundation of productive development.

---

## Prerequisites

- Stories directory exists with at least one story file
- Epic context is available (epic documents or user-provided context)
- Agent has @po authority (story metadata updates, prioritization)
- Configuration file (`config.yaml`) present with `storiesDir` path
- Backlog file exists at configured location (default: `docs/STORY-BACKLOG.md`) or will be created

---

## Execution Modes

### 1. Autopilot Mode -- Fast, Autonomous (0-2 prompts)

- Scan all stories, compute health, auto-prioritize based on dependencies and epic order
- Generate the full report without interactive review
- Apply auto-fixable recommendations (flag stale items, update priority fields)
- Log all prioritization decisions in `backlog-review-{date}.md`
- **Best for:** Routine weekly reviews, automated health checks, CI-triggered audits

### 2. Interactive Mode -- Balanced, Educational (5-10 prompts) **[DEFAULT]**

- Walk through each backlog section with the user
- Confirm priority changes before applying
- Present trade-offs for competing priorities
- Explain recommendations with context
- Offer to create new stories for identified gaps
- **Best for:** Sprint planning, stakeholder alignment, learning the backlog

### 3. Pre-Flight Mode -- Comprehensive Analysis

- Full scan of all stories, epics, and backlog items before any action
- Dependency graph analysis with visual representation
- Velocity estimation based on completed stories
- Capacity planning suggestions
- Risk assessment for each prioritization option
- Require user approval of complete prioritization plan before applying changes
- **Best for:** Quarterly planning, major re-prioritization, new team onboarding

**Default mode:** Interactive

---

## Steps

### 1. Scan All Stories

Load all story files from the configured stories directory. Parse each file to
extract:

| Field | Source | Required |
|-------|--------|----------|
| Story ID | Filename or frontmatter | Yes |
| Title | Story heading | Yes |
| Status | Status field | Yes |
| Epic | Epic reference | No |
| Priority | Priority field | No |
| Complexity | Points or T-shirt size | No |
| Dependencies | Dependencies section | No |
| Last modified | File system metadata | Yes |
| Acceptance criteria count | AC section | No |

**Parsing rules:**
- Accept both numeric IDs (e.g., `3.2`) and string IDs (e.g., `STORY-042`)
- If status field is missing, infer from content (has ACs = Draft, has code = InProgress)
- If priority is missing, mark as "Unassigned"
- Collect parsing errors without stopping the scan

### 2. Load Backlog Items

If a backlog file exists at the configured location:

1. Parse all backlog items with their IDs, status, priority, and source story
2. Categorize by type:
   - **F** -- Follow-up tasks from QA reviews or development
   - **O** -- Optimization opportunities
   - **T** -- Technical debt items
3. Note any items with expired target sprints or stale statuses

If no backlog file exists, note this and proceed with story-only analysis.

**Backlog Item ID Format:** `[{story_id}-{type}{sequential_number}]`
- Example: `[STORY-013-F1]` (first follow-up from STORY-013)
- Example: `[STORY-013-O2]` (second optimization from STORY-013)

### 3. Categorize Stories

Group the stories along multiple dimensions:

**By Status:**

| Status | Expected Actions |
|--------|-----------------|
| Draft | Needs validation by @po |
| Ready | Available for development -- monitor queue depth |
| InProgress | Active work -- monitor for staleness |
| InReview | QA pending -- monitor for bottleneck |
| Done | Complete -- available for archival |

**By Epic:**
- Group stories under their parent epic
- Calculate epic progress (done/total)
- Identify orphan stories (no epic association)
- Flag epics with all stories Done (epic may be closeable)

**By Type (if typed):**
- Feature -- New capabilities
- Bug -- Defect corrections
- Tech-Debt -- Internal quality improvements
- Improvement -- Enhancements to existing features
- Documentation -- Documentation-only changes

**By Priority (if assigned):**
- Must Have / P0
- Should Have / P1
- Could Have / P2
- Won't Have (this iteration) / P3

### 4. Check Backlog Health

Evaluate the backlog against health indicators:

| Indicator | Healthy | Warning | Critical |
|-----------|---------|---------|----------|
| Ready stories available | >= 3 | 1-2 | 0 |
| Stale Draft stories (> 14 days) | 0 | 1-2 | > 2 |
| Blocked stories | 0 | 1 | > 1 |
| InProgress stories | 1-2 | 3 | > 3 or 0 |
| Epic coverage | All active epics have stories | Some epics sparse | Active epic with 0 stories |
| Unassigned priority | < 20% of stories | 20-50% | > 50% |
| Backlog item staleness | All < 30 days | Some 30-60 days | Items > 60 days old |
| Dependency cycles | 0 | N/A | Any cycle detected |

**Health score calculation:**
- Start at 100
- Each Warning: -10
- Each Critical: -25
- Score >= 80: **Healthy**
- Score 50-79: **Needs Attention**
- Score < 50: **At Risk**

### 5. Analyze Dependencies

Build a dependency graph of all stories:

1. For each story, identify what it depends on and what depends on it
2. Detect circular dependencies (A depends on B depends on A)
3. Identify critical path: the longest dependency chain through the backlog
4. Find bottleneck stories: stories with the most dependents

**Dependency analysis output:**
```
Dependency Graph:
  3.1 -> 3.2 -> 3.4
              -> 3.5
  3.3 -> 3.5
       -> 3.6

Critical Path: 3.1 -> 3.2 -> 3.5 (3 stories deep)
Bottleneck: Story 3.2 (blocks 2 stories)
Cycles: None detected
```

If circular dependencies are found:
- Flag them as Critical health items
- Suggest how to break the cycle (which dependency to remove or reverse)

### 6. Prioritize

Apply prioritization to stories that are in Draft or Ready status:

#### 6.1 Priority Framework

Score each story on these dimensions (1-5 scale):

| Dimension | Description | Weight |
|-----------|-------------|--------|
| Business Value | Impact on users/business | 3x |
| Urgency | Time sensitivity | 2x |
| Unblocking Power | How many stories does this unblock? | 2x |
| Risk of Delay | Cost of not doing this now | 1x |
| Effort (inverse) | Lower effort = higher score | 1x |

**Weighted score** = (BV * 3) + (U * 2) + (UP * 2) + (RD * 1) + (E_inv * 1)

#### 6.2 MoSCoW Classification

Apply MoSCoW labels based on weighted score and context:

| Classification | Criteria |
|---------------|----------|
| **Must Have** | Required for current iteration. Weighted score >= 35 or blocking critical stories |
| **Should Have** | Important but not critical. Weighted score 25-34 |
| **Could Have** | Desirable if time permits. Weighted score 15-24 |
| **Won't Have** | Explicitly deferred. Weighted score < 15 or user decision |

#### 6.3 Ordering

Within each priority level, order by:
1. Dependency chain position (blockers first)
2. Weighted score (highest first)
3. Epic order (maintain epic story sequence)
4. Complexity (smaller stories first if all else equal -- maximize throughput)

**In Interactive mode:**
- Present the proposed ordering to the user
- Highlight any re-ordering from the current state
- Explain the rationale for each significant change
- Allow the user to override with justification

**In Autopilot mode:**
- Apply the ordering automatically
- Log the rationale for each priority assignment

### 7. Identify Gaps

Check for missing coverage:

| Gap Type | How to Detect |
|----------|--------------|
| Epic requirements without stories | Compare epic scope items to existing story titles/ACs |
| Implied work from ACs | ACs that reference capabilities not covered by other stories |
| Technical dependencies | Stories that need setup/infrastructure not yet planned |
| Non-functional requirements | Performance, security, accessibility not yet addressed |
| Testing gaps | Features without corresponding test stories or QA items |
| Documentation gaps | New features without documentation stories |

For each identified gap, create a gap record:

```yaml
gap:
  type: {epic_coverage / implied_work / tech_dependency / nfr / testing / docs}
  description: {what is missing}
  related_to: {epic or story that reveals the gap}
  suggested_action: {create story / add to backlog / add to existing story}
  priority: {estimated priority if it were a story}
```

In Interactive mode, present gaps and ask if the user wants to:
1. Create stories for the gaps now (delegate to @sm)
2. Add them as backlog items
3. Acknowledge and defer

### 8. Update Story Metadata

For stories that need updates based on the review:

**Allowed updates by @po:**
- Priority field (set or change)
- MoSCoW classification
- Backlog review notes (append only)
- Dependency mappings (add newly identified dependencies)
- Flags (stale, blocked, needs-attention)

**NOT allowed by @po during this task:**
- Acceptance criteria changes (requires separate validation flow)
- Title or description changes (requires formal story update)
- Status changes (only through workflow transitions)
- Scope changes (requires @po validation task)

**Update logging:**
For each story updated, add to the story's Change Log:
```
[{date}] @po -- Backlog review: {description of changes}
```

### 9. Update Backlog Items

For backlog items (follow-ups, tech debt, optimizations):

1. Review each item's current relevance
2. Update priorities based on new context
3. Flag items that should be promoted to full stories
4. Flag items that are stale and should be archived
5. Update sprint assignments if applicable

**Backlog item status transitions:**
```
TODO -> IN_PROGRESS (work started)
TODO -> CANCELLED (no longer relevant)
IN_PROGRESS -> DONE (completed)
IN_PROGRESS -> BLOCKED (dependency issue)
BLOCKED -> TODO (blocker resolved)
IDEA -> TODO (approved for work)
DONE -> ARCHIVED (after configured retention period)
```

**Backlog Item Lifecycle:**
```
IDEA (proposed) -> TODO (approved) -> IN_PROGRESS (active)
  -> DONE (completed) -> ARCHIVED
  -> BLOCKED (waiting) -> TODO (unblocked)
  -> CANCELLED (dropped)
```

### 10. Present Backlog Summary

Format and display the comprehensive summary report:

```
## Backlog Summary

### Health: {Healthy / Needs Attention / At Risk} (Score: {N}/100)

### Story Counts
| Status | Count | Trend |
|--------|-------|-------|
| Draft | {count} | {up/down/stable vs last review} |
| Ready | {count} | {trend} |
| InProgress | {count} | {trend} |
| InReview | {count} | {trend} |
| Done | {count} | {trend} |
| **Total** | {count} | |

### Priority Distribution
| Priority | Count | Stories |
|----------|-------|---------|
| Must Have | {count} | {story IDs} |
| Should Have | {count} | {story IDs} |
| Could Have | {count} | {story IDs} |
| Won't Have | {count} | {story IDs} |
| Unassigned | {count} | {story IDs} |

### Epic Progress
| Epic | Progress | Next Story |
|------|----------|------------|
| {epic} | {done}/{total} ({%}) | {next story to work on} |

### Backlog Items
| Type | TODO | In Progress | Blocked | Done |
|------|------|-------------|---------|------|
| Follow-ups | {count} | {count} | {count} | {count} |
| Optimizations | {count} | {count} | {count} | {count} |
| Tech Debt | {count} | {count} | {count} | {count} |

### Health Warnings
- {warning 1}
- {warning 2}

### Gaps Identified
- {gap 1}: {suggested action}
- {gap 2}: {suggested action}

### Recommended Actions (Priority Order)
1. {most important action with specific command}
2. {second action}
3. {third action}
```

**Standard recommendations by situation:**

| Situation | Recommendation |
|-----------|---------------|
| 0 Ready stories | "Validate drafts or create new stories to feed the pipeline" |
| > 3 InProgress | "Too much WIP -- focus on completing in-progress stories" |
| Stale drafts | "Review and validate or archive: {list}" |
| Blocked stories | "Resolve blockers: {specific blockers}" |
| Empty epic | "Create stories for epic {N} or close the epic" |
| High tech debt | "Schedule tech debt sprint or prioritize {N} debt items" |
| No backlog items | "Healthy -- no outstanding follow-ups" |

---

## Backlog File Format

The backlog file follows this structure:

```markdown
# Story Backlog

**Last Updated:** {date}
**Total Items:** {count}
**Health:** {status}

## High Priority

### [{story-id}-{type}{num}] {title}
- **Source:** {QA Review / Development / Planning}
- **Priority:** HIGH
- **Effort:** {estimate}
- **Status:** {TODO / IN_PROGRESS / BLOCKED / DONE}
- **Description:** {what needs to be done}
- **Success Criteria:**
  - [ ] {criterion}

## Medium Priority
...

## Low Priority
...

## Statistics
- Total: {count}
- TODO: {count}
- In Progress: {count}
- Done: {count}
- Blocked: {count}
```

---

## Backlog Operations Quick Reference

### Add New Item
- Trigger: After QA review, during development, or PM prioritization
- Generate unique ID: `[{story_id}-{type}{sequential_number}]`
- Determine priority section, create item using template, update statistics

### Update Item Status
- Trigger: Work started, completed, or blocked
- Find item by ID, update status, add completion date if DONE, update statistics

### Review Backlog
- Trigger: Weekly backlog review
- Generate report: items by status, priority, sprint; overdue and blocked items
- Suggest priority adjustments based on age, dependencies, sprint deadlines

### Archive Completed Items
- Trigger: Monthly or when backlog gets too large
- Collect DONE items, create archive file, remove from main backlog, update statistics

### Generate Report
- Output options: Summary, Detailed, Sprint View, Team View, Risk View

---

## Success Metrics

Track effectiveness of the backlog management:
- **Item Completion Rate**: % of backlog items completed
- **Age of Items**: How long items sit in TODO state
- **Blocked Item Resolution**: Time to unblock blocked items
- **Archive Frequency**: Regular archiving indicates healthy flow
- **Sprint Commitment Accuracy**: % of committed backlog items completed

---

## Error Handling

- **No stories found** -- Report an empty backlog. Suggest starting with `@sm *create` to create the first story, or `@pm *create-epic` to plan from an epic level. Do not treat as a failure.

- **Conflicting priorities** -- Present the trade-offs clearly. Example: "Stories 3.2 and 3.5 are both Must Have but compete for the same dependency. Which should go first?" In Autopilot mode, prioritize by weighted score and log the decision.

- **Epic context missing** -- Proceed with the information available. Note in the summary: "Epic context not available -- prioritization based on story-level data only. Consider establishing epic context for better alignment."

- **Unparseable story files** -- Skip the file, include it in a "Could not parse" list, and continue with the remaining stories. Report the parsing error with the file path.

- **Backlog file missing** -- Create the file with the standard header. Note that a new backlog file was initialized. Proceed with story-only analysis.

- **Circular dependencies detected** -- Flag as Critical. Present the cycle visually: "A -> B -> C -> A". Suggest which dependency to remove or reverse. Block prioritization of stories in the cycle until the cycle is resolved.

- **Large backlog (>100 items)** -- Truncate the per-section item lists in the summary. Offer to export the full report to a file. Focus recommendations on the top 10 most impactful actions.

- **Permission denied on story updates** -- Report which files could not be updated. Collect the updates and present them as a list of manual changes the user should make.

---

## Examples

### Example 1: Healthy Sprint Planning Review

```
User: "@po *manage-backlog"

@po scans 12 stories across 2 epics.

Backlog Summary:
  Health: Healthy (Score: 90/100)
  Ready: 3 stories (good pipeline depth)
  InProgress: 1 story (healthy WIP)
  Gaps: None identified

  Recommended: "Pipeline is healthy. Next development should pick up
  story 3.4 (Must Have, unblocks 3.5 and 3.6)."
```

### Example 2: Backlog Needing Attention

```
User: "@po review the backlog"

@po scans 18 stories across 3 epics.

Backlog Summary:
  Health: Needs Attention (Score: 60/100)
  Warnings:
    - 0 Ready stories (pipeline dry)
    - 3 Draft stories older than 14 days
    - 4 InProgress stories (high WIP)
    - Epic 4 has 0 stories

  Recommended Actions:
    1. Validate drafts: @po *validate 5.1, 5.2, 5.3
    2. Focus WIP: complete stories 3.2 and 3.4 before starting new work
    3. Create stories for Epic 4 or close the epic
```

### Example 3: Gap Discovery

```
User: "@po *manage-backlog" (Pre-Flight mode)

@po performs full analysis.

Gaps Identified:
  1. Epic 3 scope item "API rate limiting" has no story -- suggest creating
  2. Story 3.5 AC mentions "audit logging" not covered by any story
  3. No performance testing story exists for the new payment flow

  Create stories for these gaps? (yes for all / select / defer)
```

---

## Notes

- This task is interactive by default because prioritization decisions benefit from human judgment.
- The @po agent may update priority and metadata fields but NOT acceptance criteria or scope during this task. Those require the formal validation workflow.
- Backlog health indicators are guidelines. Teams should calibrate thresholds based on their velocity and team size.
- The MoSCoW classification and weighted scoring are frameworks, not absolute rules. Context and user judgment always override computed scores.
- The backlog file and story files are the sources of truth. This task does not maintain a separate database.
- Archive completed backlog items monthly to keep the backlog file manageable.

---

## Related Tasks

| Task | Relationship |
|------|-------------|
| `validate-next-story` | Moves Draft stories to Ready (resolves "0 Ready" warning) |
| `create-next-story` | Creates new stories (resolves gaps) |
| `create-epic` | Creates epics with story breakdowns |
| `qa-gate` | Produces QA verdicts that generate backlog items |
| `orchestrate-status` | Consumes health data from this task |
