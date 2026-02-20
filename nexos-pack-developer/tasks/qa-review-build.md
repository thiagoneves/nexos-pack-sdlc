---
task: qa-review-build
agent: qa
workflow: story-development-cycle (qa-gate)
inputs:
  - storyId (required, format: "{epic}.{story}")
  - spec (file: docs/stories/{storyId}/spec/spec.md)
  - implementation (file: docs/stories/{storyId}/implementation/implementation.yaml, optional)
  - storyFile (file: docs/stories/{storyId}*.md)
outputs:
  - qa_report.md (file: docs/stories/{storyId}/qa/qa_report.md)
  - status.json update (.aios/status.json)
  - signal (APPROVE or REJECT)
---

# QA Review Build: 10-Phase Quality Assurance Review

## Purpose
Execute a structured 10-phase quality assurance review of a completed build. This comprehensive review validates implementation against spec, runs automated tests, performs browser/database verification, conducts code review, checks for regressions, and produces a detailed QA report with a clear APPROVE/REJECT signal.

## Prerequisites
- Story exists in docs/stories/
- Story status is "Review" or "In Progress"
- Spec file exists and is readable
- Story file exists and contains acceptance criteria

## Steps

### Phase 0: Load Context
Load all relevant artifacts to understand what was built.

**Actions:**
1. Read spec file: `docs/stories/{storyId}/spec/spec.md` (required)
2. Read implementation plan: `docs/stories/{storyId}/implementation/implementation.yaml` (optional)
3. Read story file: `docs/stories/{storyId}*.md` (required)
4. Read requirements: `docs/stories/{storyId}/spec/requirements.json` (optional)
5. Check for previous QA reports: `docs/stories/{storyId}/qa/qa_report.md` (optional)

**Validation:**
- spec.md exists and is readable
- Story file exists and contains acceptance criteria

### Phase 1: Verify Subtasks Completed
Ensure all implementation subtasks are marked complete. This phase is **blocking**.

**Actions:**
1. Extract checklist from implementation.yaml to verify subtask statuses
2. Check git log for commits referencing storyId
3. Verify File List section in story is populated

**Sub-phase 1.2: Evidence Requirements Check**
Verify required evidence is present for the PR type. Runs the `qa-evidence-requirements` task.
- Detect PR type from story title, commit messages, acceptance criteria
- Evaluate evidence checklist against available sources
- Verify minimum evidence score is met for the detected type
- Ensure no CRITICAL evidence items are missing

**Checks:**
- All subtasks must have status: completed (HIGH)
- Git log contains commits referencing storyId (HIGH)
- File List section is not empty (MEDIUM)

### Phase 2: Initialize Environment
Prepare environment for testing. This phase is **blocking**.

**Actions:**
1. Run `npm install` (timeout: 120s)
2. Run `npm run build` (timeout: 300s)
3. Verify environment: Node.js >= 18.0.0, npm >= 9.0.0, env file exists

**Checks:**
- npm install exits with code 0 (HIGH)
- npm run build exits with code 0 (HIGH)
- Build output contains no type errors (HIGH)

### Phase 3: Automated Testing
Run all automated test suites. This phase is **blocking**.

**Actions:**
1. Run unit tests: `npm run test` (timeout: 300s)
2. Run integration tests: `npm run test:integration` (timeout: 600s, optional)
3. Run e2e tests: `npm run test:e2e` (timeout: 900s, optional)
4. Collect coverage summary from test output

**Checks:**
- Unit tests pass (HIGH)
- Integration tests pass or command not found (MEDIUM)
- E2E tests pass or command not found (MEDIUM)
- Coverage >= 80% or no coverage threshold defined (LOW)

### Phase 4: Browser Verification
Manual or automated browser-based verification. **Non-blocking**, conditional on UI components existing.

**Sub-phase 4.2: Browser Console Check**
Runs the `qa-browser-console-check` task. **Blocking** within this phase.
- Start dev server and wait for ready signal
- Capture console errors, warnings, uncaught exceptions, unhandled rejections
- Monitor network for status >= 400, timeouts, failed requests
- Block on critical console errors (Uncaught Error, TypeError, ReferenceError)

**Actions:**
1. Detect if UI files were changed (tsx, jsx, vue, html, css)
2. Run Playwright tests if configured (timeout: 600s, optional)
3. Compare visual regression screenshots (optional)
4. Run accessibility check with axe-core (optional)

**Checks:**
- No console errors during render (MEDIUM)
- UI works on mobile/tablet/desktop viewports (LOW)
- No critical accessibility violations (MEDIUM)

### Phase 5: Database Validation
Verify database schema and data integrity. **Non-blocking**, conditional on database components existing.

**Sub-phase 5.3: False Positive Detection**
Runs the `qa-false-positive-detection` task for bug fixes and security PRs.
- Execute 4-step verification protocol (revert test, baseline failure, success verification, independent variables)
- Check for confirmation bias (negative cases tested, independent verification, mechanism explained)
- Require minimum MEDIUM confidence level

**Actions:**
1. Detect if database files were changed (migrations, schema, sql, prisma)
2. Check migration status: `npm run db:migrate:status` (optional)
3. Validate schema: `npm run db:validate` (optional)
4. Check if seed data exists (optional)

**Checks:**
- All pending migrations are applied (HIGH)
- Schema validation passes (HIGH)
- Migrations do not cause data loss (HIGH)

### Phase 6: Code Review
Security review, pattern adherence, code quality, library validation. This phase is **blocking**.

**Sub-phase 6.0: Library Validation**
Runs the `qa-library-validation` task.
- Extract all third-party imports from source files
- Validate each library against Context7 documentation
- Check for correct API usage and deprecated methods

**Sub-phase 6.1: Security Checklist**
Runs the `qa-security-checklist` task. **Blocking**.
- 8-point security vulnerability scan covering: eval/Function, innerHTML/outerHTML, dangerouslySetInnerHTML, shell injection, hardcoded secrets, SQL injection, input validation, CORS

**Sub-phase 6.2: Migration Validation**
Runs the `qa-migration-validation` task (conditional on schema changes).
- Detect database framework (supabase, prisma, drizzle, django, rails, sequelize)
- Validate migration existence, correctness, and reversibility
- Check RLS policies for new tables

**Sub-phase 6.3: Code Quality and Patterns**
- Run security vulnerability scan
- Analyze code patterns (no hardcoded secrets, no console.logs in production, proper error handling, consistent naming)
- Run `npm audit` for vulnerable dependencies
- Run `npm run lint`

**Checks:**
- No hardcoded API keys, passwords, or tokens (HIGH)
- No high/critical npm audit vulnerabilities (HIGH)
- Code follows project patterns (MEDIUM)
- npm run lint exits with code 0 (MEDIUM)

### Phase 7: Regression Testing
Verify existing features still work. This phase is **blocking**.

**Actions:**
1. Analyze dependencies of changed files to identify affected areas
2. Run smoke tests: `npm run test:smoke` (optional)
3. Check for breaking API changes
4. Verify backwards compatibility

**Checks:**
- Smoke tests pass (HIGH)
- No breaking API changes without version bump (HIGH)
- Dependency updates do not break existing features (MEDIUM)

### Phase 8: Generate Report
Compile findings into comprehensive QA report. This phase is **blocking**.

**Actions:**
1. Aggregate findings from all phases (0-7)
2. Categorize issues by severity:
   - CRITICAL: Security vulnerabilities, data loss, breaking changes
   - HIGH: Test failures, build errors, major bugs
   - MEDIUM: Code quality, pattern violations, minor bugs
   - LOW: Suggestions, optimizations, style issues
3. Generate markdown report at `docs/stories/{storyId}/qa/qa_report.md`

**Report sections:** Executive summary, phase results (all 10 phases), issues by severity, recommendations, signal with reason.

### Phase 9: Update Implementation Plan
Mark story as reviewed and add issues to implementation plan. **Non-blocking**.

**Actions:**
1. Update `.aios/status.json` with qaReviewed, qaSignal, qaReviewedAt
2. Update `implementation.yaml` with qa.reviewed, qa.signal, qa.issues
3. Create fix requests for critical and high issues if signal is REJECT

### Phase 10: Signal Completion
Emit final APPROVE or REJECT signal. This phase is **blocking**.

**Signal Rules:**

APPROVE when:
- No CRITICAL issues
- No HIGH issues (or all HIGH issues resolved)
- Build succeeds
- Unit tests pass
- All subtasks completed

REJECT when:
- Any CRITICAL issue present
- Any HIGH issue unresolved
- Build fails
- Unit tests fail
- Subtasks incomplete

**Post-signal actions:**
- APPROVE: Story ready for Done status, PR can be merged, deploy to staging/production
- REJECT: Review issues in qa_report.md, fix critical and high priority issues, re-run review

## Command

```
*review-build {story-id} [--quick] [--skip-browser] [--skip-db]
```

**Flags:**
- `--quick`: Skip optional phases (4, 5)
- `--skip-browser`: Skip Phase 4 (Browser Verification)
- `--skip-db`: Skip Phase 5 (Database Validation)

## Error Handling
- **Spec not found:** HALT - Cannot review without specification (blocking)
- **Build timeout:** Log timeout, mark build as FAILED (blocking)
- **Test timeout:** Log timeout, continue with partial results (non-blocking)
- **Phase failure:** Stop review if blocking phase fails, generate partial report with REJECT signal
