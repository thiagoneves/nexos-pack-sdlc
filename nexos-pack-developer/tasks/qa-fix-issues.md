---
task: qa-fix-issues
agent: dev
workflow: qa-loop (fix-phase)
inputs:
  - storyId (string, required) - Story ID e.g. "6.4" or "story-6.4"
  - fixRequestPath (file) - Path to QA_FIX_REQUEST.md
  - qaReportPath (file, optional) - Path to full QA report
outputs:
  - fixResult (object) - storyId, status, issuesFixed, verificationResults, commitHash
  - signalReReview (boolean) - Signal to QA that fixes are ready for re-review
---

# QA Issue Fixer

## Purpose
Fix issues reported in QA review following a structured 8-phase workflow. This task is triggered when QA identifies issues that need to be addressed before the story can be approved.

## Prerequisites
- QA_FIX_REQUEST.md exists at `docs/stories/{storyId}/qa/QA_FIX_REQUEST.md`
- Story file exists at `docs/stories/{storyId}.md`
- On correct git branch for the story

## Critical Constraints
- **Minimal changes only** - Fix ONLY what is in the fix request
- **No scope creep** - Do NOT refactor or add features
- **No new features** - Do NOT fix issues not in the list
- **Run ALL verification steps** from the fix request
- **Commit with proper references** to issue IDs

## Steps

### 0. Load Context
1. Load `docs/stories/{storyId}/qa/QA_FIX_REQUEST.md` (required)
2. Load `docs/stories/{storyId}/qa/qa_report.md` (optional, use fix request only if absent)
3. Load `docs/stories/{storyId}.md` (required)
4. Validate that the fix request file exists and is valid markdown

### 1. Parse Requirements
1. Extract from the fix request: issues list, severity levels, affected files, verification steps
2. Create a fix checklist with entries containing: issueId, description, severity, file, fixApproach, status (pending)
3. Prioritize by severity: CRITICAL first, then MAJOR, then MINOR
4. Validate at least one issue was extracted

### 2. Start Development
1. Verify you are on the correct branch for the story (e.g., `feat/{storyId}`)
2. If not on the correct branch, check it out
3. Verify the working directory is clean or has only expected changes
4. Record the current commit hash, branch name, and timestamp for rollback reference

### 3. Fix Issues Sequentially
For each issue in the checklist, ordered by severity:
1. Read the affected file
2. Locate the issue based on its description
3. Apply the minimal fix following the suggested approach
4. Update the checklist entry status to "fixed"
5. Log the change: "Fixed {issueId}: {description}"

**Scope enforcement:** Fix ONLY what is explicitly listed. Do not refactor surrounding code, add features, fix unreported issues, or improve code style beyond what is required.

### 4. Run Tests
1. Run `npm run lint` (required, timeout 60s)
2. Run `npm run test` (required, timeout 300s)
3. Run `npm run typecheck` (if TypeScript project, timeout 60s)
4. If tests fail, return to Step 3 to fix and retry (max 3 attempts)
5. If tests still fail after 3 attempts, halt for manual intervention

### 5. Self-Verification
1. Extract all verification steps from the fix request
2. Execute each verification step based on its type:
   - **command**: Run CLI command and check output
   - **api**: Make API call and verify response
   - **browser**: Use playwright to verify UI
   - **e2e**: Run end-to-end test
   - **manual**: Document manual verification
3. Document results for each step (stepId, passed, actual, notes)
4. If any verification step fails, return to Step 3

### 6. Commit Fixes
1. Stage only the files that were modified for fixes
2. Generate commit message:
   ```
   fix(qa): resolve {issueIds}

   Issues fixed:
   - {issueId}: {description}
   ...

   Story: {storyId}
   ```
3. Create the commit

### 7. Update Plan and Signal
1. Update `QA_FIX_REQUEST.md` with a "Fix Results" section marking each issue as fixed with commit reference and timestamp
2. Update story file Dev Agent Record with completion note referencing the fix request
3. Create signal file at `docs/stories/{storyId}/qa/READY_FOR_REREVIEW.md` containing:
   - Story ID, timestamp, commit hash
   - List of issues fixed (with checkmarks)
   - Verification results for each step
   - Next step instruction for QA re-review

## Error Handling
- **Fix request not found:** Halt. No fix request found - run QA review first.
- **No issues found:** Halt. No issues to fix - story may already be passing.
- **Scope creep detected:** Halt. Only fix issues from QA_FIX_REQUEST.md.
- **Tests failing after fixes:** Escalate. Fixes caused test failures - review approach.
- **Verification failed:** Retry from Step 3 (max 3 retries), then halt.
- **Cannot locate issue:** Log and continue - issue may already be fixed.
- **Fix requires major changes:** Halt. Issue requires scope beyond minimal fix.

## QA Loop Integration
- **Triggered by:** QA review identifies issues and creates QA_FIX_REQUEST.md
- **Triggers next:** READY_FOR_REREVIEW.md signals QA for re-review
- **Handoff format:** QA sends QA_FIX_REQUEST.md, dev returns READY_FOR_REREVIEW.md
- **Loop continues** until QA verdict is PASS or WAIVED

## Acceptance Criteria
- All issues from QA_FIX_REQUEST.md are addressed
- All verification steps pass
- Tests pass (lint, unit, typecheck)
- Commit references all fixed issue IDs
- Signal file created for QA re-review
