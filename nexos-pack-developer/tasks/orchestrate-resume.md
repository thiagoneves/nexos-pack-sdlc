---
task: orchestrate-resume
agent: master
workflow: support
inputs: [saved workflow state, project files, user confirmation]
outputs: [resumed workflow execution, updated state]
---

# Orchestrate Resume

## Purpose

Resume a previously interrupted workflow from its saved state. Handles workflow
continuity across sessions by locating saved state, validating it against the
current project, and restarting execution from the correct point.

Workflows can be interrupted by: session end, user command, errors, timeouts,
or intentional pauses. This task ensures no work is lost and execution picks up
cleanly from where it stopped.

---

## Prerequisites

- A workflow was previously started and interrupted (manually or by session end)
- Saved state exists in one or more of these forms:
  - Workflow state files
  - QA loop status file
  - Epic execution state files
  - Stories with InProgress or InReview status
- Referenced story files and artifacts are still accessible on disk
- The project has not been fundamentally restructured since the interruption

---

## Execution Modes

### 1. Autopilot Mode -- Fast, Autonomous (0-1 prompts)

- Find the most recent saved state automatically
- If only one state exists, resume without confirmation
- If multiple states exist, resume the most recently updated one
- Log the resume decision for audit
- **Best for:** Resuming after clean session ends, automated pipelines

### 2. Interactive Mode -- Balanced, Confirmatory (2-5 prompts) **[DEFAULT]**

- Present the saved state summary to the user before resuming
- If multiple states exist, let the user choose which to resume
- Confirm the resume plan before executing
- Report any validation warnings and let the user decide
- **Best for:** Standard resume after interruption, uncertain state

### 3. Pre-Flight Mode -- Comprehensive Validation

- Perform full state validation before any action
- Compare saved state against current project in detail:
  - File-by-file comparison of referenced artifacts
  - Status field verification for all stories involved
  - Dependency chain integrity check
- Present a detailed resume plan with risks identified
- Require explicit approval before starting
- **Best for:** Long-interrupted workflows (days/weeks), high-risk work

**Default mode:** Interactive

---

## Steps

### 1. Find Saved State

Search for workflow state indicators in the following locations, in order of
priority:

| Location | State Type | Priority |
|----------|-----------|----------|
| Epic execution state files | Epic orchestration state | 1 (most specific) |
| QA loop status file (`qa/loop-status.json`) | QA loop iteration state | 2 |
| Workflow state files (if orchestrate saved state) | General workflow state | 3 |
| Stories with InProgress status | Implied active SDC | 4 |
| Stories with InReview status | Implied active QA review | 5 |
| Spec pipeline artifacts in progress | Implied active Spec Pipeline | 6 |

Search each location in priority order. Collect all candidates found. If no
saved states are found, report to the user and stop (see Error Handling).

### 2. Validate State

For each saved state found, perform validation:

#### 2.1 File Integrity Check

Verify that all referenced files still exist:
- Story files referenced in the state
- Artifacts produced by completed phases
- Configuration files needed for remaining phases
- Template files referenced by the workflow

For each missing file, record the path, which phase requires it, and whether it
is critical (workflow cannot proceed without it).

#### 2.2 Status Consistency Check

For stories referenced in the state:
- Compare the status in the state file with the status in the actual story file
- Flag discrepancies (e.g., state says InProgress but story says Done)

Possible discrepancies:

| State Says | Story Says | Interpretation |
|-----------|------------|----------------|
| InProgress | InProgress | Consistent -- safe to resume |
| InProgress | Done | Story was completed outside this workflow |
| InProgress | Draft | Story was reset -- state is stale |
| InReview | Done | QA completed outside this workflow |
| pending | Ready | Valid -- story was validated while paused |

#### 2.3 Conflict Detection

Check for conditions that would make resume problematic:
- Another workflow was started for the same story since the interruption
- The story's acceptance criteria or scope changed since the interruption
- Files modified by the interrupted workflow were changed by other work
- New dependencies were introduced that the saved state does not account for

Flag each conflict with severity:
- **Blocking:** Cannot resume without resolution
- **Warning:** Can resume but user should be aware
- **Info:** Minor difference, safe to proceed

#### 2.4 Age Assessment

Calculate how long ago the workflow was interrupted:

| Age | Assessment | Recommendation |
|-----|-----------|----------------|
| < 1 hour | Fresh | Resume safely |
| 1-24 hours | Recent | Resume with quick validation |
| 1-7 days | Moderate | Resume with careful validation |
| > 7 days | Stale | Consider restarting -- project may have changed significantly |

### 3. Determine Resume Point

Based on the validated state, build a resume plan:

#### 3.1 Identify Last Completed Phase

For each workflow type:

**SDC:**
- Check which phase completed last (Create, Validate, Implement, QA)
- The next phase is the resume point

**Spec Pipeline:**
- Check completed phases (Gather, Assess, Research, Write, Critique)
- The next phase is the resume point

**QA Loop:**
- Check the iteration number and last verdict
- Resume from the current iteration

**Epic Execution:**
- Check the current wave and story statuses
- Resume from the current wave's first incomplete story

#### 3.2 Verify Phase Prerequisites

For the identified next phase:
- Check that all inputs required by the phase are available
- Check that the responsible agent is configured
- Check that any precondition artifacts from previous phases exist

If prerequisites are missing:
1. List exactly what is missing
2. Determine if the previous phase needs to be re-run
3. Include this in the resume plan

#### 3.3 Build Resume Plan

Assemble a resume plan containing: workflow type, state source path, state age,
last completed phase (name, agent, output), resume-from phase (name, agent,
inputs), validation status (clean/warnings/conflicts with details), and
estimated remaining phases.

### 4. Present Context to User

**In Autopilot mode:**
- If state is clean and < 24 hours old: resume immediately, log the decision
- If warnings exist: resume but log warnings
- If conflicts exist: halt and switch to Interactive mode

**In Interactive mode:**

Present a clear summary:

```
=== Resume: {Workflow Type} ===

Interrupted: {time ago}
State source: {file path}

Completed Phases:
  1. {phase} -- @{agent} -- Done
  2. {phase} -- @{agent} -- Done

Resume Point:
  -> Phase {N}: {phase name} -- @{agent}
  Input: {what will be passed from previous phases}

{If warnings:}
Warnings:
  - {warning 1}
  - {warning 2}

{If conflicts:}
Conflicts (must resolve before resuming):
  - {conflict 1}
  - {conflict 2}

Resume this workflow? (yes / restart from scratch / cancel)
```

**If multiple saved states exist:**

```
=== Multiple Interrupted Workflows Found ===

  1. SDC for story 3.2 -- Interrupted 2 hours ago -- Phase 3 (Implement)
  2. QA Loop for story 2.1 -- Interrupted 1 day ago -- Iteration 3/5
  3. Epic Execution for Epic 5 -- Interrupted 3 days ago -- Wave 2

Which would you like to resume? (1-3, or "none" to start fresh)
```

**In Pre-Flight mode:**
- Present the full validation report with all checks
- Include file-by-file comparison if relevant
- Show the complete execution plan from resume point to completion
- Require explicit "proceed" confirmation

### 5. Resume Execution

On user confirmation (or automatic in Autopilot mode):

1. **Restore context** -- Load the workflow context from the saved state
2. **Update state** -- Mark the workflow as `active` (no longer `interrupted`)
3. **Set up agent context** -- Prepare the inputs for the next phase's agent
4. **Handoff** -- Delegate to the `orchestrate` task for continued monitoring:
   - Pass the restored context
   - Pass the resume point (which phase, which agent)
   - Pass any artifacts from completed phases
5. **Log the resume** -- Record in the orchestration log:
   ```
   [timestamp] Workflow resumed: {type}
   State source: {file}
   Resume point: Phase {N} -- @{agent}
   Interruption duration: {time}
   Validation: {clean/warnings/conflicts}
   ```

### 6. Handle Invalid or Stale State

If the saved state cannot be validated or is too stale to resume:

#### 6.1 Unrecoverable State

When critical files are missing or state is fundamentally inconsistent:

```
=== Cannot Resume: {Workflow Type} ===

Reason: {specific reason}
  - {missing file or inconsistency 1}
  - {missing file or inconsistency 2}

Options:
  1. Start the workflow from scratch (preserves existing artifacts)
  2. Start from a specific phase (if some phases are still valid)
  3. Clean up the stale state and cancel

Which would you prefer?
```

#### 6.2 Partially Recoverable State

When some phases are valid but others are not:

```
=== Partial Resume Possible: {Workflow Type} ===

Valid phases (can be preserved):
  - Phase 1: {name} -- Output still valid
  - Phase 2: {name} -- Output still valid

Invalid phases (must be re-run):
  - Phase 3: {name} -- Referenced files changed

Suggestion: Resume from Phase 3, using Phase 1-2 outputs.
Proceed? (yes / restart from scratch / cancel)
```

#### 6.3 State Cleanup

When the user decides not to resume:
- Remove or archive the stale state file
- Reset any story statuses that were left in transitional states
- Log the cleanup action
- Offer to start a fresh workflow

---

## Output Format

### Resume Confirmation

```
=== Resuming: {Workflow Type} ===
Story: {story ID} (if applicable)
Phase: {N} -- {phase name}
Agent: @{agent}
State age: {duration}
Validation: {clean / N warnings}

Handing off to @{agent}...
```

### Resume Failure

```
=== Resume Failed ===
Workflow: {type}
Reason: {description}
State file: {path}

Recommended action: {specific suggestion}
```

---

## Error Handling

- **No saved state found** -- Inform the user that no interrupted workflows were detected. Offer alternatives:
  1. Run `orchestrate-status` to see current project state
  2. Start a new workflow with `orchestrate`
  Do not treat this as a failure -- it simply means nothing was interrupted.

- **Referenced files deleted** -- Report exactly which files are missing and which phases they affect. Categorize each as critical (blocks resume) or non-critical (can proceed without). Suggest restarting the workflow if critical files are gone, or continuing if only non-critical artifacts are absent.

- **Multiple saved states** -- Present a numbered list with details for each:
  ```
  1. {workflow type} -- {story ID} -- Phase {N} -- {age}
  2. {workflow type} -- {story ID} -- Phase {N} -- {age}
  ```
  Ask the user to select one. In Autopilot mode, select the most recently updated.

- **State conflicts** -- If the project has changed significantly since the interruption (e.g., story was completed by another process, new stories added to an epic), report the conflict clearly and recommend starting fresh. Never silently resume over conflicting state.

- **Corrupted state file** -- Report the corruption. Attempt to reconstruct state from:
  1. Story file statuses (most reliable)
  2. File system artifacts (completed phase outputs)
  3. Change log entries in story files
  Present the reconstructed state for user confirmation before using it.

- **Permission errors** -- If state files cannot be read or written, report the exact path and error. Suggest checking file permissions.

- **Concurrent resume attempt** -- If a workflow appears to be actively running (not just interrupted), warn the user and block the resume to prevent duplicate execution.

---

## Examples

### Example 1: Clean Resume

```
User: "resume"

Orchestrator:
  -> Found saved state: SDC for story 4.2, Phase 3 (Implement), 45 minutes ago
  -> Validation: clean, all files present, status consistent
  -> Presents: "Resume SDC for story 4.2? Implementation was in progress."
  -> User: "yes"
  -> Restores context, hands off to @dev with dev-develop-story
```

### Example 2: Stale State with Warnings

```
User: "continue where I left off"

Orchestrator:
  -> Found saved state: QA Loop for story 2.1, Iteration 3/5, 3 days ago
  -> Validation: 1 warning -- story 2.1 was modified since interruption
  -> Presents: "QA Loop for story 2.1 was interrupted 3 days ago at iteration 3.
    Warning: The story file was modified since then (Dev Notes section updated).
    This may affect the QA review. Resume anyway?"
  -> User: "yes, the changes are compatible"
  -> Resumes QA loop from iteration 3
```

### Example 3: Multiple States

```
User: "resume"

Orchestrator:
  -> Found 3 saved states
  -> Presents:
    "Multiple interrupted workflows found:
      1. SDC -- story 4.2 -- Phase 3 (Implement) -- 1 hour ago
      2. QA Loop -- story 3.1 -- Iteration 4/5 -- 2 days ago
      3. Spec Pipeline -- login feature -- Phase 4 (Write Spec) -- 5 days ago
    Which would you like to resume? (1-3, or 'none')"
  -> User: "1"
  -> Resumes SDC for story 4.2
```

### Example 4: Unrecoverable State

```
User: "resume"

Orchestrator:
  -> Found saved state: Epic Execution for Epic 3, Wave 2, 14 days ago
  -> Validation: 2 blocking conflicts
    - Story 3.4 was marked Done (state says InProgress)
    - Story 3.5 file was deleted
  -> Presents: "Cannot resume Epic Execution for Epic 3.
    Conflicts found:
      - Story 3.4 was completed outside this workflow
      - Story 3.5 file no longer exists
    Options: (1) restart epic execution, (2) clean up state and cancel"
```

---

## Notes

- The resume task NEVER modifies project files (stories, code, etc.) -- it only restores workflow state and hands off to the appropriate task/agent.
- State age is a heuristic for staleness. The actual risk depends on how much the project changed, not just elapsed time.
- When resuming in Autopilot mode, all decisions are logged. The log should capture why the state was considered safe to resume.
- Resume preserves the execution mode of the original workflow. If the workflow was started in Pre-Flight mode, it resumes in Pre-Flight mode.
- If the user frequently resumes workflows, consider suggesting they use `orchestrate-status` first to get a full picture before deciding what to resume.

---

## Related Tasks

| Task | Relationship |
|------|-------------|
| `orchestrate` | Receives handoff after successful resume |
| `orchestrate-status` | Provides current state data used in validation |
| `dev-develop-story` | SDC Phase 3 resume target |
| `qa-gate` | QA review resume target |
| `qa-review-story` | QA loop resume target |

## Related Templates

| Template | Usage |
|----------|-------|
| `templates/status-report.md` | Used when offering status as alternative to resume |
