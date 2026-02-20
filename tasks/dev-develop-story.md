---
task: dev-develop-story
agent: dev
inputs:
  - story file (Ready status)
  - config.yaml
  - devLoadAlwaysFiles (context files)
outputs:
  - implemented code
  - updated story file (checkboxes, File List, Dev Record, Change Log)
  - test results
  - decision-log (autopilot mode)
---

# Develop Story

## Purpose

Implement a validated story by executing its tasks sequentially, writing tests, performing code review, and updating the story file with progress. This task supports three execution modes to accommodate different story complexities, developer preferences, and automation levels.

The developer agent takes a story from `Ready` to implementation-complete, producing working code that satisfies all acceptance criteria, passes all tests, and is ready for quality review.

This task is Phase 3 of the Story Development Cycle (SDC).

## Prerequisites

- [ ] Story is in `Ready` status (validated by @po). Do NOT begin if status is `Draft`.
- [ ] Story file contains all necessary context: acceptance criteria, scope, dev notes, task checklist.
- [ ] Development environment is set up: dependencies installed, tools available, project builds cleanly.
- [ ] Story dependencies (other stories) are in `Done` status.
- [ ] The project `config.yaml` is accessible.

## Execution Modes

### 1. Autopilot Mode -- Fast, Autonomous (0-1 prompts)

- Reads the story file completely and executes all tasks without user interaction.
- Makes all decisions autonomously: architecture, library selections, algorithms, testing approaches.
- Every decision logged with rationale and alternatives in ADR format.
- Only prompts if a blocking issue is encountered.
- **Best for:** Simple, deterministic tasks with clear ACs and detailed Dev Notes.

### 2. Interactive Mode -- Balanced, Educational (5-10 prompts) **[DEFAULT]**

- Presents summary of tasks and ACs, confirms understanding with user.
- Prompts at key decision points: architecture, library selections, algorithms, testing, scope clarifications.
- Provides educational explanations of trade-offs before and after decisions.
- Shows results before marking tasks complete.
- **Best for:** Standard development, moderate complexity, learning framework patterns.

### 3. Pre-Flight Mode -- Comprehensive Upfront Planning (10-15 prompts then 0)

- Analyzes the story completely before writing code.
- Identifies all ambiguities, missing decisions, and potential blockers.
- Generates a comprehensive questionnaire and presents it for batch answers.
- Creates a detailed execution plan, presents for approval.
- Executes with zero ambiguity -- no additional prompts.
- **Best for:** Ambiguous requirements, critical work, complex multi-system stories.

## Steps

### Step 1: Load and Validate Story File

#### 1.1 Parse Story Content
Extract: title, description, acceptance criteria (numbered), scope, dev notes, task checklist, dependencies, testing standards, change log.

#### 1.2 Validate Story Status
- **Draft:** HALT. Must be validated by @po first.
- **Ready:** Proceed. Update status to `InProgress`.
- **InProgress:** Ask if resuming. Skip to first unchecked task.
- **Done:** HALT. No further development needed.

#### 1.3 Update Story Status
- Update from `Ready` to `InProgress`.
- Add Change Log entry: `| {date} | @dev | Development started. Status: Ready -> InProgress. |`

### Step 2: Load Configuration and Context Files

#### 2.1 Load Project Configuration
Read `config.yaml` for testing commands, coding standards references, project-specific settings.

#### 2.2 Load Context Files
If `devLoadAlwaysFiles` is configured, load those context files (coding standards, architecture overview, shared types, etc.).

#### 2.3 Mode-Specific Initialization

**Autopilot:** Initialize decision logging. Log story ID, start time, mode.

**Interactive:** Present story summary (title, AC count, task count, complexity). Confirm readiness.

**Pre-Flight:** Analyze story for ambiguities, generate questionnaire, collect responses, generate execution plan, get user approval.

### Step 3: Execute Tasks Sequentially

For each task in the story's task checklist:

#### 3.1 Read and Understand
Parse description and subtasks. Identify which ACs this task addresses. Check prerequisite tasks.

#### 3.2 Check Dependencies
Verify prerequisite tasks are marked `[x]`. If not, HALT with message.

#### 3.3 Plan the Approach
- **Autopilot:** Decide autonomously, log decisions.
- **Interactive:** Present approach, confirm if significant decisions involved.
- **Pre-Flight:** Follow pre-approved execution plan.

#### 3.4 Implement
- Follow existing code patterns and conventions.
- Write clean, self-documenting code with proper error handling.
- Add or update unit tests for every new function or behavior.
- Keep functions focused, small, and testable.
- Apply REUSE > ADAPT > CREATE (check for existing utilities first).
- Do NOT add unnecessary dependencies.

#### 3.5 Verify Locally
- Does the implementation work as expected?
- Do existing tests still pass?
- Does the code follow coding standards?

#### 3.6 Mark Task Complete
Only if ALL verifications pass: update checkbox `[ ]` -> `[x]`, update subtask checkboxes, update File List.

#### 3.7 Repeat
Move to next task. Repeat until all tasks are complete.

### Step 4: Blocking Conditions (All Modes)

**HALT and ask the user if:**
- An unapproved dependency is needed.
- A requirement is ambiguous after consulting Dev Notes.
- 3 consecutive failures attempting to implement or fix something.
- Missing configuration or environment setup.
- A regression test fails with unclear root cause.
- Implementation requires changes outside the story's scope.

**On HALT:** Save progress, document the blocker, present options (guidance, pause, escalate).

### Step 5: Run Tests

After all tasks are complete, run the full test suite:

#### 5.1 Lint Check
```bash
npm run lint
```

#### 5.2 Type Check
```bash
npm run typecheck
```

#### 5.3 Unit Tests
```bash
npm test
```

For each: if it fails, fix and re-run. After 3 failed attempts, HALT and ask the user.

**All three checks MUST pass before proceeding.**

Note: Exact commands may vary. Check `config.yaml` for project-specific commands.

### Step 6: Self-Healing Code Review

Run automated code review on changes in a self-healing loop.

#### 6.1 Configuration
```yaml
mode: light
max_iterations: 2
timeout_per_iteration: 15 minutes
severity_filter: [CRITICAL, HIGH]
```

#### 6.2 Self-Healing Loop
```
iteration = 0
WHILE iteration < 2:
    1. Run code review on uncommitted changes.
    2. Parse output for severity levels.

    IF no CRITICAL issues:
        - Document HIGH issues in story Dev Notes as tech debt.
        - BREAK -> proceed to Step 7.

    IF CRITICAL issues found:
        - Attempt auto-fix for each CRITICAL issue.
        - Attempt auto-fix for HIGH issues (if iteration < 2).
        - iteration++

IF iteration == 2 AND CRITICAL issues remain:
    - HALT and report to user. Do NOT mark story complete.
```

#### 6.3 Severity Handling

| Severity | Behavior | Notes |
|----------|----------|-------|
| CRITICAL | Auto-fix (max 2 attempts) | Security vulnerabilities, breaking bugs |
| HIGH | Auto-fix attempt, then document | Recommend fix before QA |
| MEDIUM | Document as tech debt | QA will review |
| LOW | Ignore | Not blocking |

#### 6.4 Tool Not Available
Skip and add Change Log note: `Code review tool not available -- manual review required.`

### Step 7: Update Story File

#### 7.1 Update File List
List all created/modified/deleted files with paths relative to project root.

#### 7.2 Update Dev Agent Record
Fill in: Agent Model, Mode, Debug Log references, Completion Notes.

#### 7.3 Add Change Log Entry
`| {date} | @dev | Implementation complete. All tasks done. Tests passing. |`

#### 7.4 Sections NOT to Modify
**DO NOT modify:** Story statement, Acceptance Criteria, Scope IN/OUT, QA Results.

### Step 8: Generate Decision Log (Autopilot Mode)

**File:** `decision-log-{story-id}.md` (ADR format)

**Sections:**
1. **Context:** Story info, execution time, files modified, tests run.
2. **Decisions:** Each with type, priority, reason, alternatives considered.
3. **Implementation Changes:** Files created/modified/deleted, test results.
4. **Rollback Instructions:** Git revert commands.

### Step 9: Report Completion

Display summary: story ID, title, mode, tasks completed, test status, code review status, files changed, decision log (if autopilot), next step: `@qa *qa-gate {story-id}`.

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| Story not in Ready status | Draft or Done | HALT. Inform user to validate first or check status. |
| Story file not found | Invalid ID or missing file | HALT. List available stories. |
| Config not found | No config.yaml | Warn. Continue without context files. |
| Test failures (3 attempts) | Code does not pass | HALT. Report details, ask for guidance. |
| CRITICAL review issues persist | Auto-fix failed after 2 iterations | HALT. Document issues, request manual intervention. |
| Blocked 3 times on same task | Repeated failures | HALT. Ask user; do not loop indefinitely. |
| Unknown execution mode | Invalid mode string | Default to Interactive. Warn user. |
| User cancellation | User aborts | Save progress. Story stays InProgress; resume later. |
| Pre-flight plan rejected | User does not approve | Pause. Allow modifications and plan regeneration. |

## Acceptance Criteria

- [ ] All story tasks and subtasks marked `[x]`.
- [ ] Every acceptance criterion addressed by the implementation.
- [ ] Lint passes.
- [ ] Typecheck passes.
- [ ] All tests pass (new and existing).
- [ ] Code review passed or issues documented as tech debt.
- [ ] File List is complete and accurate.
- [ ] Dev Agent Record is populated.
- [ ] Change Log updated with start and completion entries.
- [ ] Decision log generated (autopilot mode only).
- [ ] User informed of completion and next steps.

## Notes

- **Status Ownership:** @dev can change `Ready` to `InProgress`. Does NOT set `InReview` or `Done` (those belong to @qa).
- **Scope Discipline:** Implement ONLY what is in Scope IN. If work outside scope is needed, HALT and discuss.
- **Decision Logs:** In Autopilot mode, the decision log is the primary audit trail. Must be detailed enough for another developer to understand every choice.
- **Test-Driven:** Write tests alongside implementation, not as an afterthought.
- **File List Accuracy:** Keep current after each task. Do not wait until the end.
- **REUSE > ADAPT > CREATE:** Search the codebase for existing implementations before building new ones.
- **Error Recovery:** If interrupted, progress is preserved. Resume from last unchecked task.
- **Code Review Degradation:** If review tool is not available, skip and note. Do not fail the process.
- **No Force Push:** @dev performs local git operations only (add, commit, status, diff). Pushing is handled by @devops.
