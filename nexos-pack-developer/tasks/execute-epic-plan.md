---
task: execute-epic-plan
agent: pm
inputs:
  - execution_plan_path (required, string, path to EXECUTION.yaml file)
  - action (optional, string, start|continue|status|skip-story|abort, default: start)
  - mode (optional, string, yolo|interactive|preflight, default: interactive)
  - wave (optional, number, wave number to resume from)
outputs:
  - epic_state (object, persisted to .aios/epic-{epicId}-state.yaml)
  - wave_report (object, current wave execution results)
  - next_steps (string, recommended next actions)
---

# Execute Epic Plan

## Purpose
Orchestrate the execution of an epic by reading a project-specific EXECUTION.yaml plan, processing stories in wave-based parallel execution, running each story through the full development cycle (validate, implement, self-heal, review, push), managing wave quality gates, and persisting state for resume across sessions.

## Prerequisites
- Execution plan YAML exists (e.g., `docs/stories/epics/{epic}/EPIC-{ID}-EXECUTION.yaml`)
- Epic orchestration workflow template exists
- Development cycle workflow exists
- All story files referenced in the plan exist
- Git working tree is clean (no uncommitted changes)

## Steps

### 1. Action: Start

Initialize epic execution and begin Wave 1.

**Read and parse the execution plan:**
- Extract epicId, storyBasePath, template reference, stories map, waves list, final gate criteria, and bug verification checklist

**Validate all references:**
- Verify each story file exists at the specified path
- Verify each story executor and quality gate are valid agent IDs
- Verify quality gate agent differs from executor agent
- Verify all story IDs in each wave exist in the stories map
- Verify wave dependencies reference valid previous waves
- Verify required workflow templates exist

**Pre-flight analysis (if mode=preflight):**
- For each wave, list key files across stories and identify overlapping files
- Flag conflict risks
- Estimate total complexity
- Show dependency chain
- Display full analysis and ask user to confirm before proceeding

**Initialize state file (`.aios/epic-{epicId}-state.yaml`):**
- Record epicId, execution plan path, mode, timestamps
- Set status to `active`, current wave to 1
- Initialize all wave and story statuses to `pending`

**Display epic header** with plan overview, then execute Wave 1.

### 2. Action: Continue

Resume epic execution from persisted state.

- Load state from `.aios/epic-{epicId}-state.yaml`
- Verify status is `active`
- Determine resume point:
  - If current wave is `in_progress`: resume wave (some stories may already be done)
  - If current wave is `gate_review`: resume gate review
  - If current wave is `completed`: advance to next wave
  - If all waves completed: run final gate
- Execute from resume point and save state

### 3. Action: Status

Show epic progress without executing any work:
- Display wave-by-wave progress with story completion status
- Show gate verdicts for completed waves
- Show bug verification status
- Display next command to run

### 4. Action: Skip-Story

Skip a specific story within the current wave:
- Verify the story is in the current wave and is not critical priority
- Mark story as skipped with reason
- If all other stories in the wave are done, proceed to wave gate
- Save state

### 5. Action: Abort

Abort epic execution:
- Set status to `aborted`
- Generate abort report listing completed work, in-progress items, and created branches
- Save state (allows future resume with `continue`)

### 6. Wave Executor (Core Algorithm)

For each wave:

**Execute stories:**
- If wave allows parallel execution, spawn all stories simultaneously
- If sequential, execute stories one at a time
- Each story runs the full development cycle:
  1. Validate the story draft
  2. Implement code changes
  3. Self-heal (fix lint/test/typecheck errors)
  4. Quality gate review (by different agent than executor)
  5. Create branch and push

**Handle failures:**
- If any stories fail, present options: Retry / Proceed / Abort

**Wave gate (integration review):**
- Spawn a gate agent for cross-story integration review
- Review checklist: integration compatibility, file conflicts, combined tests, regressions, architecture consistency
- If APPROVED: merge wave branches in specified order
- If REJECTED: display issues, ask user for action

**Wave checkpoint (interactive mode):**
- Display wave completion summary
- Ask user: GO (next wave) / PAUSE (save state) / REVIEW (detailed summary) / ABORT

### 7. Final Gate

After all waves complete:
- Run epic-level sign-off
- Execute bug verification checklist
- If approved: mark epic as completed, apply final tag
- Optionally run retrospective

### 8. State Persistence

State is saved after every significant action:
- Wave start, story completion, gate verdict, checkpoint decision
- State file persists on disk for cross-session resume

## Error Handling
- **Story development cycle fails:** Retry internally (max 3 attempts), then mark as blocked and continue with other stories in the wave
- **Wave gate fails:** Gate agent identifies specific issues; create fix tasks, re-run affected stories, re-submit gate
- **Merge conflict between wave branches:** Follow merge order from execution plan; resolve conflicts manually if needed, re-run tests
- **State file corrupted:** Restore from backup (`.aios/epic-{epicId}-state.yaml.bak`), which is created before each write
- **Execution plan not found:** Exit with clear error and path suggestion
- **Git working tree dirty:** Exit with message to commit or stash changes first
