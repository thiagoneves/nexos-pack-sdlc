---
task: orchestrate-status
agent: master
workflow: support
inputs: [current workflow state, active stories, project configuration]
outputs: [status report]
---

# Orchestrate Status

## Purpose

Generate a comprehensive status report of all active workflows, stories in
progress, and pending tasks. Provides the team with visibility into current work,
identifies blockers, and recommends next actions.

This task is the read-only counterpart to `orchestrate`: it inspects project
state without modifying anything. The output follows the format defined in
`templates/status-report.md`.

---

## Prerequisites

- Stories directory exists and is accessible
- Story files follow the expected naming convention and contain a Status field
- QA loop status file exists if a QA loop has been initiated
- Configuration file (`config.yaml`) is present with `storiesDir` and `epicsDir` paths

---

## Execution Modes

### 1. Autopilot Mode -- Fast, Autonomous (0 prompts)

- Scan all sources, compile the full report, and present it without interaction
- Include all sections even if some are empty (mark as "No data")
- **Best for:** Quick status checks, automated dashboards, scripted queries

### 2. Interactive Mode -- Balanced, Educational (1-3 prompts) **[DEFAULT]**

- Present the full report, then offer to drill into specific sections
- Ask: "Would you like details on any section? (blockers, specific story, workflow)"
- Offer actionable suggestions with specific commands
- **Best for:** Standups, planning sessions, unfamiliar project state

### 3. Pre-Flight Mode -- Comprehensive Analysis

- Before generating the report, show what will be scanned:
  - Stories directory path and file count
  - Epic directory path and file count
  - QA loop state file location
  - Workflow state file locations
- Ask user to confirm scope of the report
- Include additional analysis: trend data, velocity estimates, health scores
- **Best for:** Sprint reviews, stakeholder presentations, detailed audits

**Default mode:** Interactive

---

## Steps

### 1. Scan Active Stories

Locate all story files in the configured stories directory (typically
`docs/stories/` or the path configured in `config.yaml` as `storiesDir`).

Collect the full list of story files matching the `*.story.md` pattern.

For each story file, extract:
- Story ID (from filename or frontmatter)
- Title
- Current status (Draft, Ready, InProgress, InReview, Done)
- Associated epic (if any)
- Priority (if assigned)
- Complexity estimate
- Dependencies on other stories
- Last modified date

### 2. Categorize Stories by Status

Group stories into their lifecycle status:

| Status | Description | Staleness Threshold |
|--------|-------------|---------------------|
| Draft | Created but not yet validated | > 14 days = stale |
| Ready | Validated by @po, available for development | > 7 days = stale |
| InProgress | Currently being implemented by @dev | > 5 days without update = stale |
| InReview | Implementation complete, under QA review | > 3 days = stale |
| Done | QA passed, fully complete | N/A |

Count the stories in each group and flag any that appear stale based on the
thresholds above.

### 3. Scan Epic Progress

If epics directory exists (typically `docs/stories/epics/` or configured as
`epicsDir`):

For each epic:
- Parse epic document
- Count total stories and completed stories
- Calculate percentage progress
- Identify the current active story (first non-Done story)
- Detect stalled epics (no story progress in > 7 days)

### 4. Check Active Workflows

Identify any running workflows by checking for:

| Indicator | Implies |
|-----------|---------|
| Stories with InProgress status | Active SDC Phase 3 |
| Stories with InReview status | Active SDC Phase 4 or QA Loop |
| Workflow state files in project | Active orchestrated workflow |
| Spec pipeline artifacts in progress | Active Spec Pipeline |
| Brownfield discovery documents in progress | Active Brownfield Discovery |
| Epic execution state files | Active Epic Execution |

For each active workflow, determine:
- Workflow type
- Current phase number and name
- Responsible agent for the current phase
- How long the current phase has been active

### 5. Check QA Loop Status

If a QA loop is active (check for QA loop status file at configured path or
`qa/loop-status.json`), report:

- Target story ID
- Current iteration number (out of maximum, default max = 5)
- Last verdict (APPROVE, REJECT, BLOCKED)
- Iteration history (if available)
- Any escalation flags
- Time since last iteration

### 6. Check Backlog Health

Scan backlog status if a backlog file exists:

| Health Indicator | Healthy | Warning | Critical |
|------------------|---------|---------|----------|
| Ready stories available | >= 3 | 1-2 | 0 |
| Stale Draft stories | 0 | 1-2 | > 2 |
| Blocked stories | 0 | 1 | > 1 |
| InProgress stories | 1-2 | 3 | > 3 or 0 |
| Epic coverage | All epics have stories | Some epics empty | Active epic with no stories |

Compute an overall health score:
- **Healthy** -- No warnings or critical items
- **Needs Attention** -- 1-2 warnings, no critical items
- **At Risk** -- Any critical items or 3+ warnings

### 7. Compile Status Report

Assemble the report using the `templates/status-report.md` template structure.

Fill in these sections:

#### Section 1: Summary Dashboard

```
## Project Status Report

**Generated:** {date and time}
**Health:** {Healthy / Needs Attention / At Risk}
**Active Workflow:** {workflow type or "None"}
```

#### Section 2: Stories by Status

```
### Stories by Status

| Status | Count | Stories |
|--------|-------|---------|
| Draft | {count} | {comma-separated story IDs} |
| Ready | {count} | {comma-separated story IDs} |
| InProgress | {count} | {comma-separated story IDs} |
| InReview | {count} | {comma-separated story IDs} |
| Done | {count} | {comma-separated story IDs} |

**Total:** {total stories}
```

#### Section 3: Epic Progress

```
### Epic Progress

| Epic | Stories | Done | Progress | Current Story |
|------|---------|------|----------|---------------|
| {epic ID} | {total} | {done} | {percentage}% | {current story ID} |
```

#### Section 4: Active Workflows

```
### Active Workflows

| Workflow | Phase | Agent | Task | Since |
|----------|-------|-------|------|-------|
| {workflow type} | {phase N: name} | @{agent} | {task name} | {timestamp} |
```

If no active workflows: "No active workflows."

#### Section 5: QA Loop Status

```
### QA Loop

| Field | Value |
|-------|-------|
| Story | {story ID} |
| Iteration | {current} / {max} |
| Last Verdict | {verdict} |
| Escalation | {Yes/No} |
```

If no active QA loop: "No active QA loop."

#### Section 6: Blockers and Warnings

```
### Blockers and Warnings

| Severity | Item | Details | Suggested Action |
|----------|------|---------|------------------|
| {Critical/Warning} | {story or workflow} | {description} | {recommended action} |
```

#### Section 7: Stale Items

```
### Stale Items

| Story | Status | Days Since Update | Recommendation |
|-------|--------|-------------------|----------------|
| {story ID} | {status} | {days} | {validate / archive / resume / investigate} |
```

#### Section 8: Recommended Next Actions

```
### Recommended Next Actions

1. {Most urgent action with specific command}
2. {Second priority action}
3. {Third priority action}
```

Generate recommendations based on current state:

| Situation | Recommendation |
|-----------|---------------|
| 0 Ready stories, Drafts exist | "Validate draft stories: `@po *validate {story-id}`" |
| 0 Ready stories, no Drafts | "Create stories: `@sm *create` or `@pm *create-epic`" |
| InProgress story stale > 5 days | "Check on story {id}: may be blocked or abandoned" |
| InReview story stale > 3 days | "Complete QA review: `@qa *qa-gate {story-id}`" |
| QA loop at max iterations | "QA loop escalation needed for {story-id}" |
| No active workflow | "Start development: `@master *orchestrate`" |
| Blocked stories exist | "Resolve blockers before starting new work" |

### 8. Present Report

Display the formatted report to the user.

**In Interactive mode:**
- After the report, ask: "Would you like to drill into any section, or shall I take action on a recommendation?"
- If the user selects a recommendation, delegate to the appropriate task

**In Autopilot mode:**
- Display the report and stop
- If Critical items exist, highlight them at the top with a visual separator

**In Pre-Flight mode:**
- Display the report with additional trend analysis
- Include comparison to last status report (if available)
- Offer to export the report as a file

---

## Output Format

### Compact Summary (for quick checks)

```
Status: {Health} | Stories: {draft}/{ready}/{inprog}/{review}/{done} | Workflow: {type or None} | Blockers: {count}
```

### Full Report

Uses the `templates/status-report.md` template with all sections filled.
See Step 7 above for the complete structure.

---

## Error Handling

- **No stories found** -- Report an empty project state. Suggest creating the first story with `@sm *create` or starting with an epic via `@pm *create-epic`. Do not treat this as a failure.

- **Stories directory missing** -- Report that the stories directory was not found at the configured path. Suggest initializing the project structure. Include the expected path in the error message.

- **Status file corrupted or unparseable** -- Skip the corrupted file, include it in a "Could not parse" section of the report, and rebuild status from remaining files. Never let one bad file prevent the report from generating.

- **Mixed or inconsistent states** -- Flag the inconsistency in the report. Examples:
  - Story marked Done but with no QA results
  - Story marked InReview but no associated QA loop
  - Story marked InProgress but unchanged for 14+ days
  Recommend investigation for each inconsistency.

- **QA loop status file missing** -- Skip the QA Loop section. Note in the report that QA loop status could not be determined.

- **Configuration missing** -- Use default paths (`docs/stories/`, `docs/stories/epics/`). Note in the report that configuration was not found and defaults were used.

- **Large project (>50 stories)** -- Truncate per-status story lists to the 10 most recent. Include a count and offer to show the full list on request.

---

## Examples

### Example 1: Healthy Project

```
User: "status"

== Project Status Report ==
Health: Healthy
Generated: 2026-02-20

Stories: Draft(1) Ready(3) InProgress(1) InReview(0) Done(8)
Active Workflow: SDC Phase 3 -- @dev implementing story 4.2
Blockers: None

Recommended: Continue development on story 4.2
```

### Example 2: Project Needing Attention

```
User: "@master status"

== Project Status Report ==
Health: Needs Attention

WARNINGS:
  - Story 2.3 has been InProgress for 6 days (stale threshold: 5)
  - Only 1 story in Ready status (threshold: >= 3)

Stories: Draft(2) Ready(1) InProgress(1) InReview(1) Done(5)
Active QA Loop: Story 3.1, iteration 3/5, last verdict: REJECT

Recommended Actions:
  1. Complete QA review for story 3.1: `@qa *qa-loop-review`
  2. Validate draft stories: `@po *validate 4.1` and `@po *validate 4.2`
  3. Check on stale story 2.3 -- may need assistance
```

### Example 3: Empty Project

```
User: "what's the status?"

== Project Status Report ==
Health: At Risk -- No stories found

The project has no stories in the stories directory.

Recommended Actions:
  1. Create an epic to plan your work: `@pm *create-epic`
  2. Or create a story directly: `@sm *create`
```

---

## Notes

- This task is strictly read-only. It does NOT modify any files or state.
- The status report format follows `templates/status-report.md`.
- Staleness thresholds are guidelines. Projects may override these in their configuration.
- When called from within the `orchestrate` task, the report is returned inline. When called directly, it is displayed to the user.
- For epic-level status with wave progress, delegate to the epic execution status action rather than duplicating that logic here.
- The health score is a heuristic. Do not present it as an absolute measure -- present it with the supporting data that led to the assessment.

---

## Related Tasks

| Task | Relationship |
|------|-------------|
| `orchestrate` | Parent task, delegates status queries here |
| `orchestrate-resume` | Uses status data to identify resumable workflows |
| `po-manage-backlog` | Produces backlog health data consumed by this task |
| `qa-gate` | QA loop status consumed by this task |

## Related Templates

| Template | Usage |
|----------|-------|
| `templates/status-report.md` | Report structure and format |
