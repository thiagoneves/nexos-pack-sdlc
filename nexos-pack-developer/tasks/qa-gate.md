---
task: qa-gate
agent: qa
inputs:
  - story file (InProgress status, all tasks complete)
  - implemented code
  - test results
  - gate template
outputs:
  - gate verdict file (.yml)
  - updated story status
  - QA report in story file
---

# QA Gate

## Purpose

Perform a comprehensive quality review of a completed story implementation using 7 quality checks. Produce a gate verdict (PASS, CONCERNS, FAIL, WAIVED) with a structured gate file, update the story's QA Results section, and transition the story status based on the verdict.

The QA Gate is the final checkpoint before a story is considered Done. It verifies that the implementation meets acceptance criteria, follows quality standards, introduces no regressions, and is secure, performant, and documented.

This task is Phase 4 of the Story Development Cycle (SDC).

## Prerequisites

- [ ] Story is in `InProgress` status with all task checkboxes marked `[x]`.
- [ ] Implementation code has been committed locally (or changes are visible).
- [ ] Tests (lint, typecheck, unit tests) pass as reported by @dev.
- [ ] The story's File List is populated with all created/modified files.
- [ ] The Dev Agent Record has been completed by @dev.

## Execution Modes

### 1. Autopilot Mode -- Fast, Autonomous (0-1 prompts)
- Runs all 7 quality checks automatically. Applies the verdict algorithmically.
- **Best for:** Routine stories with clear ACs and straightforward implementations.

### 2. Interactive Mode -- Balanced, Thorough (3-5 prompts) **[DEFAULT]**
- Presents each quality check result. Asks for confirmation on subjective assessments.
- **Best for:** Standard QA review where human judgment adds value.

### 3. Pre-Flight Mode -- Deep Analysis (5-10 prompts)
- Extended analysis: full code walkthrough, detailed security review, performance profiling, architecture compliance.
- **Best for:** High-risk stories, security-sensitive code, performance-critical paths.

## Steps

### Step 0: Load Story and Implementation Context

#### 0.1 Load Story File
Extract: story ID, title, ACs, scope, dev notes, task checklist (verify all `[x]`), File List, Dev Agent Record, tech debt items.

#### 0.2 Validate Readiness
- If not all tasks are `[x]`: HALT with list of incomplete tasks.
- If status is not `InProgress`: warn and advise correct flow.

#### 0.3 Load Configuration
Determine QA output directory, testing commands, project-specific quality standards.

### Step 1: Automated Pre-Review (Code Review Tool)

#### 1.1 Configuration
```yaml
mode: full
max_iterations: 3
severity_filter: [CRITICAL, HIGH]
```

#### 1.2 Self-Healing Loop
```
iteration = 0
WHILE iteration < 3:
    1. Run code review on changes.
    2. Parse output for severity levels.

    IF no CRITICAL or HIGH issues:
        - Document MEDIUM issues as tech debt.
        - BREAK -> proceed to Step 2.

    IF CRITICAL issues found:
        - Auto-fix CRITICAL and HIGH issues.
        - iteration++

IF iteration == 3 AND CRITICAL issues remain:
    - Document as blocking issue (contributes to FAIL in Check 1).
```

#### 1.3 Severity Handling (QA Phase)

| Severity | Behavior | Notes |
|----------|----------|-------|
| CRITICAL | Auto-fix (max 3 attempts) | Security vulnerabilities, breaking bugs |
| HIGH | Auto-fix (max 3 attempts) | Significant quality issues |
| MEDIUM | Document as tech debt | Should fix in future |
| LOW | Ignore | Cosmetic, not blocking |

#### 1.4 Tool Not Available
Skip. Note in report: "Automated pre-review skipped -- tool not available." This is NOT a FAIL condition.

### Step 2: Execute 7 Quality Checks

#### Check 1: Code Review
Review all files in File List for: patterns/consistency, readability/maintainability, error handling, no hardcoded secrets or debug artifacts, coding standards compliance, proper use of existing utilities, no unnecessary dependencies, appropriate comments.

**PASS:** Clean, well-structured. **CONCERN:** Minor issues. **FAIL:** Significant quality issues, secrets, major violations.

#### Check 2: Unit Tests
Verify: tests exist for new functions, all tests pass, tests are meaningful (not trivially passing), edge cases covered, clear test names, no flaky tests, coverage meets standards.

**PASS:** Comprehensive and passing. **CONCERN:** Pass but thin coverage. **FAIL:** Tests fail, missing for critical paths.

#### Check 3: Acceptance Criteria
For each AC: map to implementation code, verify full satisfaction, confirm Given/When/Then scenarios are tested, check no gold-plating.

Report format:
```
AC-1: "Given X, When Y, Then Z"  -> MET (src/api/users.ts:45)
AC-2: "Given A, When B, Then C"  -> NOT MET (missing error case)
```

**PASS:** All ACs fully met. **CONCERN:** Met but mapping unclear. **FAIL:** One or more ACs not met.

#### Check 4: No Regressions
Verify: all existing tests pass, modified files don't break existing functionality, import/export changes have no unintended side effects, public API contracts preserved, no unintentional behavior changes.

**PASS:** No regressions. **CONCERN:** Minor behavioral changes. **FAIL:** Existing tests fail or functionality broken.

#### Check 5: Performance
Review for: unnecessary loops, missing pagination, unbounded queries, large file reads without streaming, synchronous operations that should be async, N+1 queries, missing caching, oversized payloads.

**PASS:** No concerns. **CONCERN:** Potential issues to monitor. **FAIL:** Clear problems that impact users.

#### Check 6: Security
Review for: injection vectors, input validation, data exposure in logs/errors/APIs, authentication checks, authorization enforcement, hardcoded credentials, vulnerable dependencies.

**PASS:** OWASP basics covered. **CONCERN:** Minor improvements. **FAIL:** Vulnerability identified.

#### Check 7: Documentation
Review: docs updated for API/behavior changes, README reflects new functionality, code comments for complex logic, JSDoc/TSDoc for public functions, configuration changes documented, migration instructions.

**PASS:** Up to date. **CONCERN:** Could improve. **FAIL:** Missing for significant new functionality.

### Step 3: Score and Determine Verdict

| Verdict | Criteria | Action |
|---------|----------|--------|
| **PASS** | All 7 checks PASS | Approve. Story is Done. |
| **CONCERNS** | All PASS or CONCERN (no FAIL) | Approve with observations as tech debt. |
| **FAIL** | One or more FAIL | Return to @dev with specific feedback. |
| **WAIVED** | FAIL items explicitly accepted | Approve with documented waiver. Requires user approval. |

### Step 4: Produce Gate File

#### 4.1 Location and Naming
Location from `config.yaml` (typically `docs/qa/gates/`).
File name: `{epicNum}.{storyNum}-{slug}.yml`
Slug rules: lowercase, replace spaces with hyphens, strip punctuation.

#### 4.2 Gate File Schema

```yaml
storyId: "{epicNum}.{storyNum}"
storyTitle: "{title}"
reviewer: "@qa"
date: "{ISO-8601 timestamp}"
iteration: {N}
verdict: "{PASS | CONCERNS | FAIL | WAIVED}"
score: "{passed}/7"
summary: "{1-2 sentence assessment}"
checks:
  code_review:
    status: "{PASS | CONCERN | FAIL}"
    notes: "{findings}"
  unit_tests:
    status: "{PASS | CONCERN | FAIL}"
    coverage: "{percentage or N/A}"
    notes: "{findings}"
  acceptance_criteria:
    status: "{PASS | CONCERN | FAIL}"
    notes: "{AC mapping summary}"
  no_regressions:
    status: "{PASS | CONCERN | FAIL}"
    notes: "{findings}"
  performance:
    status: "{PASS | CONCERN | FAIL}"
    notes: "{findings}"
  security:
    status: "{PASS | CONCERN | FAIL}"
    notes: "{findings}"
  documentation:
    status: "{PASS | CONCERN | FAIL}"
    notes: "{findings}"
issues:
  - id: "{PREFIX-NNN}"
    severity: "{low | medium | high}"
    category: "{code | tests | requirements | performance | security | docs}"
    description: "{what is wrong}"
    location: "{file:line or component}"
    recommendation: "{how to fix}"
waiver:
  active: false
  reason: ""
  approved_by: ""
```

#### 4.3 Issue ID Prefixes

| Prefix | Category |
|--------|----------|
| `SEC-` | Security |
| `PERF-` | Performance |
| `REL-` | Reliability |
| `TEST-` | Testing gaps |
| `MNT-` | Maintainability |
| `ARCH-` | Architecture |
| `DOC-` | Documentation |
| `REQ-` | Requirements |

#### 4.4 Severity Scale (Fixed)
- `low`: Minor, cosmetic.
- `medium`: Should fix soon, not blocking.
- `high`: Critical, should block release.

### Step 5: Update Story File

#### 5.1 Update QA Results Section
Populate with: review date, reviewer, verdict, score, check results table, gate file reference, issues list, tech debt items.

#### 5.2 Update Story Status

| Verdict | New Status | Change Log Entry |
|---------|-----------|-----------------|
| PASS | `Done` | QA Gate: PASS. InProgress -> Done. |
| CONCERNS | `Done` | QA Gate: CONCERNS. Observations documented. InProgress -> Done. |
| FAIL | `InReview` | QA Gate: FAIL. Issues listed. InProgress -> InReview. |
| WAIVED | `Done` | QA Gate: WAIVED. Reason documented. InProgress -> Done. |

### Step 6: Report Results

Present verdict, score, check details, issues, gate file path, status transition, and next steps:
- PASS/CONCERNS: `@devops *push`
- FAIL: `@dev *apply-qa-fixes {story-id}`
- WAIVED: `@devops *push`

## QA Loop Integration

On FAIL, the story enters the QA Loop for iterative review-fix cycles (max 5 iterations). Each iteration increments the `iteration` field. Previous data is preserved. If max iterations reached, escalate to user.

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| Story not in InProgress | Wrong status | Warn. Advise correct flow. |
| Incomplete tasks | Not all checkboxes [x] | HALT. List incomplete tasks. |
| File List missing | @dev did not populate | Warn. Attempt to infer from git diff. |
| Tests fail during QA | Regressions in code | Record as Check 2/4 FAIL. Do NOT fix code. |
| Code review tool unavailable | Not installed | Skip. Proceed with manual checks. |
| Gate file write fails | Permission error | Provide content in output for manual save. |
| Story update fails | Write error | Instruct user to update manually. |

## Acceptance Criteria

- [ ] All 7 quality checks executed with PASS/CONCERN/FAIL status.
- [ ] Verdict determined (PASS, CONCERNS, FAIL, or WAIVED).
- [ ] Gate file created at configured location.
- [ ] Story QA Results section populated.
- [ ] Story status updated according to verdict.
- [ ] Change Log entry added.
- [ ] Issues documented with IDs, severity, and recommendations.
- [ ] User informed of verdict, issues, and next steps.

## Notes

- **Independence:** QA reviews but does NOT fix code. Issues return to @dev.
- **Objectivity:** Apply checks consistently regardless of who developed the story.
- **Iteration Tracking:** Gate file `iteration` field tracks review cycles.
- **WAIVED is Rare:** Only with explicit user approval for time-critical releases.
- **Gate File as Record:** Permanent quality record. Previous files should be preserved.
- **Status Ownership:** @qa transitions InProgress -> Done (PASS/CONCERNS/WAIVED) and InProgress -> InReview (FAIL).
- **Scope of Review:** Review ONLY what is in story's scope. Do not fail for pre-existing issues.
- **Regression Sensitivity:** A story introducing regressions should always FAIL.
- **Security Priority:** A high-severity security finding should FAIL regardless of other checks.
