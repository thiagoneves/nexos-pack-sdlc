---
task: dev-apply-qa-fixes
agent: dev
inputs:
  - QA gate report (FAIL/REJECT verdict)
  - story file (InReview status)
  - prioritized fix list
outputs:
  - fixed code
  - updated story file (Dev Notes, File List, Change Log)
  - test results
---

# Apply QA Fixes

## Purpose

Apply fixes based on QA review feedback after a FAIL/REJECT verdict. This is the fix phase of the QA loop where the developer systematically addresses specific issues identified by @qa. Each fix is verified individually, the full test suite is run to confirm no regressions, and the story file is updated before handing back for re-review.

The goal is to resolve all CRITICAL and HIGH findings efficiently while maintaining code quality and avoiding the introduction of new issues. MEDIUM findings are either fixed (if quick and safe) or documented as tech debt.

## Prerequisites

- A QA review has been completed with a FAIL/REJECT verdict and a prioritized fix list.
- The story is in `InReview` status.
- The gate file from the QA review is accessible.
- The development environment is set up (dependencies installed, tests runnable).
- Access to the full codebase, not just the changed files.

## Execution Modes

### 1. Autopilot Mode (autonomous, 0-1 prompts)

- Process all findings and apply fixes without user interaction.
- Follow existing code patterns for implementation decisions.
- Log all decisions and fixes applied.
- **Best for:** Straightforward fixes (linting, missing validation, simple tests). Iteration 2+ where patterns are established.

### 2. Interactive Mode (default, 5-10 prompts)

- Discuss approach for complex or ambiguous fixes before implementing.
- Confirm trade-offs when multiple valid approaches exist.
- Present progress after each major fix.
- **Best for:** First iteration fixes, architectural concerns, fixes requiring domain knowledge.

### 3. Pre-Flight Mode (comprehensive, 10-15 prompts)

- Review ALL findings and plan ALL fixes before implementing any.
- Identify dependencies between fixes and optimal ordering.
- Agree on approach for each fix, including deferral decisions for MEDIUM items.
- **Best for:** Large fix lists (10+ items), conflicting findings, fixes that may affect architecture.

## Steps

### Step 1: Load QA Review Report

#### 1a. Locate the Report
Find the QA review report using these sources in order:
1. Direct path provided by user or workflow.
2. Gate file referenced in the story's QA Results section.
3. Most recent gate file matching the story ID in the QA directory.

If no report is found, HALT and ask the user.

#### 1b. Parse Findings
Extract all findings: severity, quality check number, description, file path, line number, recommendation, overall quality score and verdict, current QA loop iteration number.

#### 1c. Compare with Previous Iterations (iteration 2+)
- Load findings from previous iterations.
- Identify resolved, persisting (escalation candidates), and NEW issues (potential regressions from fixes).

### Step 2: Prioritize and Plan Fixes

#### 2a. Order by Severity

| Priority | Severity | Action | Expectation |
|----------|----------|--------|-------------|
| 1 | **CRITICAL** | Must fix immediately | Blocks approval; no exceptions |
| 2 | **HIGH** | Must fix | Blocks approval |
| 3 | **MEDIUM** | Fix if quick and safe | Or document as tech debt |
| 4 | **LOW** | Do not fix in this phase | Handled by backlog follow-up |

#### 2b. Identify Fix Dependencies
- Group related findings affecting the same file or function.
- Identify fixes requiring specific order (e.g., fix interface before implementation).
- Identify independent fixes that can be applied in parallel.

#### 2c. Estimate Effort
- **Quick** (< 5 min): Linting, naming, missing null check, adding a test assertion.
- **Standard** (5-30 min): Refactoring a function, adding error handling, writing new tests.
- **Complex** (30+ min): Architectural change, new abstraction, significant test rewrite.

Flag COMPLEX fixes that may require discussion.

### Step 3: Apply Fixes Systematically

For each finding, in priority order:

#### 3a. Understand the Finding
Read the finding and recommendation carefully. Review the referenced file and surrounding code. Understand intent before modifying.

#### 3b. Plan the Fix
Determine the minimal change that addresses the issue. Ensure fix follows existing code patterns. Consider effects on callers, dependents, and tests.

#### 3c. Implement the Fix
- Follow coding standards and best practices.
- Apply related changes together when they span multiple files.
- Do NOT introduce new patterns unless the finding specifically recommends it.
- Do NOT refactor beyond what is needed.

#### 3d. Verify the Fix
- Run specific tests related to the fix.
- For missing-test findings: write the test first, verify it fails, then apply fix.
- Check for regressions in related functionality.

#### 3e. Record the Fix
```
Finding: {severity} - {description}
File: {path}:{line}
Fix Applied: {description of change}
Verified: {how verified}
Status: FIXED | DEFERRED | CANNOT_FIX
```

### Step 4: Handle MEDIUM Findings

| Decision | When | Action |
|----------|------|--------|
| **Fix** | Quick and safe (< 5 min), no regression risk | Apply following Step 3 |
| **Defer** | Significant effort, out of scope, or risky | Document as tech debt in Dev Notes |
| **Partial fix** | Can partially address now | Apply partial, document remainder |

Record the decision and rationale for each MEDIUM finding.

### Step 5: Update Story File

#### 5a. Update Dev Notes
Add a dated entry:
```markdown
### QA Fixes Applied -- Iteration {n} ({date})

**Findings Addressed:**
- CRITICAL: {count} fixed
- HIGH: {count} fixed
- MEDIUM: {count} fixed, {count} deferred

**Summary of Changes:**
- {Brief description of each significant fix}

**Deferred Items:**
- {Finding description} -- Reason: {why deferred}
```

#### 5b. Update File List
Add new entries for any files created or modified beyond the original File List. Do NOT remove existing entries.

#### 5c. Update Task Checkboxes
If QA identified missing tasks that were added: mark completed ones as `[x]`.

#### 5d. Add Change Log Entry
```
[{date}] @dev -- QA fixes applied (iteration {n}). Fixed {count} CRITICAL, {count} HIGH, {count} MEDIUM. Deferred {count}. Ready for re-review.
```

### Step 6: Run Full Test Suite

Execute the complete verification sequence:
1. Run linting.
2. Run type checking (if applicable).
3. Run unit tests.
4. Run integration tests (if they exist and are relevant).

For each step:
- If pass, proceed.
- If fail: investigate whether related to a fix, pre-existing, or new regression.
- After 3 failed attempts on any check, HALT and document.

**All applicable checks must pass before proceeding.**

### Step 7: Final Verification

- [ ] All CRITICAL findings addressed and verified.
- [ ] All HIGH findings addressed and verified.
- [ ] MEDIUM findings either fixed or documented as deferred with rationale.
- [ ] LOW findings left for backlog (not addressed in this phase).
- [ ] Full test suite passes (lint + typecheck + tests).
- [ ] Story file updated (Dev Notes, File List, Change Log).
- [ ] No new issues introduced by the fixes.
- [ ] Changes committed locally with descriptive message referencing QA iteration.

### Step 8: Signal Ready for Re-Review

- Confirm completion status to user.
- Summarize: "{count} findings addressed, {count} deferred, all tests passing."
- Note current iteration and remaining iterations before escalation.
- Inform that story is ready for QA re-review.

If penultimate iteration (e.g., iteration 4 of 5): warn that next review is final before auto-escalation.

## Error Handling

| Situation | Action |
|-----------|--------|
| Cannot reproduce issue | Document reproduction attempt. Ask @qa for clarification. |
| Fix introduces regression | Prioritize fixing regression. If conflicting with original fix, escalate. |
| Cannot fix without architecture change | Do NOT attempt workaround. Escalate. Document as BLOCKED. |
| All fixes applied but tests still fail | Document failing tests with full output. Hand back for joint triage. |
| QA report missing or malformed | HALT. Ask user to provide report or re-run QA review. |
| Max iterations approaching (n-1) | Warn user. Suggest proactive review of remaining concerns. |
| Conflicting findings | Document both. Ask @qa for resolution before applying either. |
| Finding references code that no longer exists | Verify current state. If resolved, mark RESOLVED_BY_OTHER_CHANGES. |
| Scope expansion from fixes | Fix only the reported issue. Create new findings for discovered problems. |

## Best Practices

- **Address root causes:** Fix underlying issues, not just symptoms.
- **Maintain test coverage:** If modifying code, update or add tests.
- **Follow patterns:** Use existing codebase patterns for consistency.
- **Document complex fixes:** Add comments explaining non-obvious changes.
- **Validate thoroughly:** Run full test suite, not just affected tests.
- **Focus the fix:** "Fix the finding, not the world" -- address the specific reported issue.
- **Test-Driven Fixing:** For missing-test findings, write the test first (verify it fails), then apply the fix.

## Common QA Issue Types

### Code Quality
Linting errors, style inconsistencies, missing error handling, unused variables/imports, overly complex functions.

### Testing
Missing test cases, failing tests, insufficient coverage, flaky tests.

### Documentation
Missing or incomplete comments, outdated docs, incomplete story file updates.

### Architecture
Coding standard violations, improper dependency usage, performance concerns, security vulnerabilities.

## Acceptance Criteria

- [ ] QA review report loaded and all findings parsed.
- [ ] Findings prioritized by severity (CRITICAL > HIGH > MEDIUM).
- [ ] Each CRITICAL finding addressed and verified with tests.
- [ ] Each HIGH finding addressed and verified with tests.
- [ ] MEDIUM findings either fixed or documented as deferred with rationale.
- [ ] No new issues introduced (verified by full test suite).
- [ ] Story file updated: Dev Notes, File List (if changed), Change Log.
- [ ] Full test suite passes: lint, typecheck, tests.
- [ ] Fix record maintained for each finding.
- [ ] Changes committed locally with descriptive message.
- [ ] Ready for re-review signaled with summary.

## Notes

- Do NOT modify the QA Results section -- that is exclusively @qa's domain. Update only Dev Notes, File List, and Change Log.
- The commit message should reference the iteration number: `fix: address QA findings iteration {n} [{story-id}]`.
- Each QA loop iteration should show clear progress. If quality score does not improve, the fix approach needs rethinking.
- Deferred MEDIUM items are tracked in the product backlog.
