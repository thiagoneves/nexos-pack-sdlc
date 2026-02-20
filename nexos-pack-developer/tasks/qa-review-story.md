---
task: qa-review-story
agent: qa
workflow: qa-loop (review phase)
inputs: [story file, implementation code, test results]
outputs: [review verdict: APPROVE/REJECT/BLOCKED, QA results in story, gate file]
---

# QA Review Story

## Purpose

Conduct a comprehensive, risk-aware quality review of a story's implementation as part of the QA loop. This task produces a structured verdict (APPROVE, REJECT, or BLOCKED) that determines whether the developer needs to fix issues or the story can proceed to completion.

The review covers seven quality dimensions: code quality, test adequacy, acceptance criteria traceability, regression safety, performance, security, and documentation. It also produces a detailed gate file for audit trail and a QA Results section appended to the story file.

## Prerequisites

- Story is in `InProgress` or `InReview` status with implementation complete.
- All task checkboxes in the story file are marked `[x]`.
- Tests (lint, typecheck, unit tests) have been run by @dev.
- The QA loop has been initiated with the appropriate command or workflow trigger.
- Access to the story file, all files listed in the story's File List, and the project test suite.

## Steps

### 1. Automated Code Quality Scan (Pre-Review)

Before manual review, run automated code quality scanning with self-healing:

**Configuration:** Full self-healing (max 3 iterations, CRITICAL + HIGH issues)

**Flow:**

1. Run automated code scanner against committed changes.
2. Parse output for severity levels (CRITICAL, HIGH, MEDIUM, LOW).
3. If no CRITICAL or HIGH issues found:
   - Create tech debt items for MEDIUM issues.
   - Proceed to manual review.
4. If CRITICAL or HIGH issues found:
   - Attempt auto-fix for each issue.
   - Re-run scan (up to 3 iterations).
5. If issues persist after 3 iterations:
   - Set gate to FAIL.
   - Halt and require manual intervention.

**Severity Handling:**

| Severity | Behavior | Notes |
|----------|----------|-------|
| CRITICAL | Auto-fix (max 3 attempts) | Security vulnerabilities, breaking bugs |
| HIGH | Auto-fix (max 3 attempts) | Significant quality problems |
| MEDIUM | Create tech debt issue | Document for future sprint |
| LOW | Note in review | Informational, no action required |

**Timeout:** 30 minutes per scan run, ~90 minutes total for 3 iterations.

If self-healing fails, the gate is automatically set to FAIL, `top_issues` is populated from remaining issues, and `status_reason` includes "Automated self-healing exhausted."

### 2. Load Story Context

Read the story file and gather all review context:

#### 2a. Parse Story Content

- Parse the title, description, acceptance criteria, scope (IN/OUT), and dev notes.
- Review the File List to identify all created and modified files.
- Read the story's Dev Notes for implementation decisions and context.
- Identify any referenced standards documents (coding standards, testing strategy, etc.).

#### 2b. Load QA Loop State

- Check for QA loop status (e.g., `qa/loop-status.json` or equivalent tracking file).
- Note the current iteration count. If iteration > 1, load previous review findings for comparison.
- If this is a re-review, verify that previously identified CRITICAL and HIGH issues have been addressed.

#### 2c. Determine Review Depth

Auto-escalate to deep review when any of these conditions apply:

| Condition | Reason |
|-----------|--------|
| Auth, payment, or security files touched | High-risk domain |
| No tests added despite new functionality | Quality gap |
| Diff > 500 lines | Large change surface |
| Previous iteration verdict was REJECT | Unresolved concerns |
| Story has > 5 acceptance criteria | Complex requirements |
| Data migration or schema changes | Data integrity risk |
| External API integration | Integration failure risk |

If none of these conditions apply, a standard-depth review is sufficient.

### 3. Review Code Changes

#### 3a. Identify All Changes

- Read the story's File List for all modified and created files.
- Use version control diff against the branch base to see all changes.
- For each file, read the full content to understand context beyond the diff.
- Flag any files changed that are NOT listed in the story's File List.
- Flag any files in the File List that do NOT appear to have changes.

#### 3b. Understand Change Scope

- Map each change to the relevant acceptance criterion.
- Identify changes that are refactoring vs. feature implementation.
- Note any out-of-scope changes (both positive improvements and scope creep).

### 4. Execute 7 Quality Checks

Run the full quality check suite. For each check, record findings with severity, description, recommendation, file path, and line number.

#### Check 1: Code Quality Review

- Architecture and design pattern adherence.
- Code readability, naming clarity, function size.
- Error handling: appropriate try/catch, meaningful error messages, no swallowed errors.
- No secrets, credentials, or debug artifacts (console.log, debugger statements).
- No hardcoded values that should be configurable.
- Code duplication or missed abstraction opportunities.
- Proper use of language/framework features.

#### Check 2: Test Adequacy

- Run the test suite to verify all tests pass.
- Verify test coverage for new functionality (each new function/method should have tests).
- Check edge cases: boundary values, empty inputs, error paths, null/undefined handling.
- Assess test quality: meaningful assertions (not just "does not throw"), clear test names.
- Verify test isolation: no shared mutable state between tests.
- Check for missing test types: if story adds an API endpoint, are there integration tests?

#### Check 3: Acceptance Criteria Traceability

- Map EACH acceptance criterion to its implementation and validating tests.
- For each AC, verify:
  - Implementation exists and is complete.
  - At least one test validates the AC (ideally in Given/When/Then structure).
  - Edge cases implied by the AC are covered.
- Flag any ACs that lack clear traceability.
- Flag any implementation that does not trace to an AC (scope creep indicator).

#### Check 4: Regression Safety

- All existing tests pass (no regressions).
- Modified files: check that callers and dependents are not broken.
- Shared utilities: verify that changes are backward-compatible.
- API contracts: verify no unintended breaking changes.
- If a file was modified that is used by other stories/modules, verify no side effects.

#### Check 5: Performance Assessment

- No unnecessary loops, especially nested loops on unbounded data.
- No unbounded queries (missing LIMIT, missing pagination).
- No blocking synchronous operations in async contexts.
- No unnecessary re-renders in frontend components.
- Efficient data structures and algorithms for the task.
- Large data operations handle streaming or pagination.
- If performance-critical path: check for caching, memoization, or indexing.

#### Check 6: Security Review

- **Input validation:** All user inputs validated before use.
- **Injection prevention:** No string concatenation in queries, templates, or commands.
- **Authentication:** Auth checks in place for protected resources.
- **Authorization:** Proper role/permission checks where needed.
- **Data protection:** Sensitive data not logged or exposed in responses.
- **Credentials:** No secrets in code, proper use of environment variables.
- **Dependencies:** No known vulnerable dependencies introduced.

#### Check 7: Documentation

- Public API changes documented (new endpoints, changed signatures).
- Complex logic has explanatory comments.
- README updated if setup or usage changed.
- Inline documentation for non-obvious business rules.
- Story file accurately reflects what was implemented.

### 5. Active Refactoring (When Appropriate)

The QA reviewer may perform minor refactoring when:
- The fix is safe, localized, and improves code quality.
- Tests can verify the change does not break functionality.
- The change is well within the reviewer's expertise.

For each refactoring performed:
- Document WHAT was changed, WHY, and HOW it improves the code.
- Run tests after the change to verify safety.
- Record the change in the QA Results section.

Do NOT refactor when:
- The change is risky or affects multiple modules.
- The change alters business logic.
- The change requires architectural discussion.

### 6. Standards Compliance Check

- Verify adherence to coding standards documentation.
- Check compliance with project structure guidelines.
- Validate testing approach against testing strategy documentation.
- Ensure all guidelines mentioned in the story are followed.

### 7. Determine Verdict

Apply the verdict rules in this priority order:

#### Verdict Decision Tree

```
1. Any CRITICAL findings?
   YES -> REJECT (unless specific waiver exists)
   NO  -> Continue

2. Any HIGH findings?
   YES -> REJECT
   NO  -> Continue

3. Any AC not fully met?
   YES -> REJECT (with AC gap listed)
   NO  -> Continue

4. Any MEDIUM findings?
   YES -> APPROVE with CONCERNS noted
   NO  -> Continue

5. All checks pass cleanly?
   YES -> APPROVE
```

#### Verdict Definitions

| Verdict | Criteria | Action |
|---------|----------|--------|
| **APPROVE** | No CRITICAL or HIGH issues; all ACs met. May have MEDIUM/LOW findings. | Story proceeds to completion. Deferred items sent to `qa-backlog-add-followup`. |
| **REJECT** | CRITICAL or HIGH issues found, or ACs not met. | Return to @dev with prioritized fix list via `qa-create-fix-request`. |
| **BLOCKED** | Cannot complete review due to external dependency, missing context, or environment issue. | Escalate immediately. Document what is blocking and what is needed to unblock. |

For REJECT, produce a prioritized fix list:
1. CRITICAL findings first (must fix).
2. HIGH findings second (must fix).
3. MEDIUM findings (fix if time permits or defer to backlog).

For APPROVE with MEDIUM/LOW findings, these become inputs to `qa-backlog-add-followup`.

### 8. Calculate Quality Score

```
quality_score = 100 - (20 x CRITICAL_count) - (10 x HIGH_count) - (5 x MEDIUM_count) - (1 x LOW_count)
Bounded between 0 and 100.
```

### 9. Produce Outputs

#### Output 1: Update Story File -- QA Results Section

**CRITICAL:** Only update the `## QA Results` section of the story file. Do NOT modify any other sections (title, description, ACs, scope, File List, Dev Notes).

- If `## QA Results` does not exist in the story, append it at the end of the file.
- If it exists, append a new dated entry below existing entries (preserving history).

```markdown
## QA Results

### Review Date: {date}

### Reviewed By: @qa

### Quality Score: {score}/100

### Code Quality Assessment

{Overall assessment of implementation quality -- 2-3 sentences}

### 7 Quality Checks

| Check | Result | Findings |
|-------|--------|----------|
| 1. Code Quality | PASS/CONCERNS/FAIL | {brief summary} |
| 2. Test Adequacy | PASS/CONCERNS/FAIL | {brief summary} |
| 3. AC Traceability | PASS/CONCERNS/FAIL | {brief summary} |
| 4. Regression Safety | PASS/CONCERNS/FAIL | {brief summary} |
| 5. Performance | PASS/CONCERNS/FAIL | {brief summary} |
| 6. Security | PASS/CONCERNS/FAIL | {brief summary} |
| 7. Documentation | PASS/CONCERNS/FAIL | {brief summary} |

### Findings Detail

{For each finding: severity, check number, description, file, line, recommendation}

### Refactoring Performed

{If any refactoring was done: file, change, why, how}

### Verdict: {APPROVE/REJECT/BLOCKED}

{1-2 sentence justification}

### Recommended Next Action

{For APPROVE: "Ready for completion. Deferred items: {count}"}
{For REJECT: "Fix required. See prioritized fix list: {count} CRITICAL, {count} HIGH."}
{For BLOCKED: "Blocked. Reason: {description}. Needed: {what is required}."}
```

#### Output 2: Create Gate File

Create a gate file in the project's QA directory:

```yaml
schema: 1
story: "{story-id}"
story_title: "{story title}"
gate: APPROVE | REJECT | BLOCKED
status_reason: "{1-2 sentence explanation}"
reviewer: "@qa"
updated: "{ISO-8601 timestamp}"
quality_score: {0-100}

top_issues:
  - severity: {CRITICAL|HIGH|MEDIUM|LOW}
    check: {1-7}
    description: "{finding description}"
    file: "{file path}"
    recommendation: "{suggested fix}"
    suggested_owner: dev | architect | po

evidence:
  tests_run: {true/false}
  tests_passed: {count}
  tests_failed: {count}
  ac_total: {count}
  ac_covered: {count}
  ac_gaps: [{list of AC numbers lacking coverage}]
  files_reviewed: {count}
  lines_changed: {count}

nfr_assessment:
  security:
    status: PASS | CONCERNS | FAIL
    notes: "{specific findings}"
  performance:
    status: PASS | CONCERNS | FAIL
    notes: "{specific findings}"
  reliability:
    status: PASS | CONCERNS | FAIL
    notes: "{specific findings}"
  maintainability:
    status: PASS | CONCERNS | FAIL
    notes: "{specific findings}"

recommendations:
  immediate:
    - action: "{must fix before completion}"
      files: ["{file paths}"]
  deferred:
    - action: "{can be addressed later}"
      files: ["{file paths}"]
```

#### Gate Decision Criteria

**Deterministic rule (apply in order):**

If risk_summary exists, apply its thresholds first (>=9 -> FAIL, >=6 -> CONCERNS), then NFR statuses, then top_issues severity.

1. **Risk thresholds (if risk_summary present):**
   - If any risk score >= 9 -> Gate = FAIL (unless waived)
   - Else if any score >= 6 -> Gate = CONCERNS

2. **Test coverage gaps (if trace available):**
   - If any P0 test from test-design is missing -> Gate = CONCERNS
   - If security/data-loss P0 test missing -> Gate = FAIL

3. **Issue severity:**
   - If any `top_issues.severity == HIGH` -> Gate = FAIL (unless waived)
   - Else if any `severity == MEDIUM` -> Gate = CONCERNS

4. **NFR statuses:**
   - If any NFR status is FAIL -> Gate = FAIL
   - Else if any NFR status is CONCERNS -> Gate = CONCERNS
   - Else -> Gate = PASS

- WAIVED only when waiver.active: true with reason/approver

#### Quality Score Calculation

```text
quality_score = 100 - (20 x number of FAILs) - (10 x number of CONCERNS)
Bounded between 0 and 100
```

If project-specific preferences define custom weights, use those instead.

#### Suggested Owner Convention

For each issue in `top_issues`, include a `suggested_owner`:

- `dev`: Code changes needed
- `architect`: Architecture decision needed
- `po`: Business decision needed

### 10. Record QA Loop Status

Update or create the QA loop tracking file with:

```yaml
story_id: "{story-id}"
current_iteration: {n}
max_iterations: 5
history:
  - iteration: {n}
    date: "{ISO-8601}"
    verdict: "{APPROVE|REJECT|BLOCKED}"
    findings_count:
      critical: {count}
      high: {count}
      medium: {count}
      low: {count}
    quality_score: {score}
```

If `current_iteration >= max_iterations`, escalate regardless of verdict.

### 11. Handoff

Based on the verdict:

- **APPROVE:** Inform the user the story is approved. List any deferred items for `qa-backlog-add-followup`. Recommend proceeding to completion.
- **REJECT:** Present the prioritized fix list. Inform the user the story needs fixes before re-review. Note the current iteration count and remaining iterations.
- **BLOCKED:** Clearly state what is blocking and what is needed. Suggest who should resolve the blocker.

## Error Handling

| Situation | Action |
|-----------|--------|
| **Cannot run tests** | Record as a BLOCKED finding under Check 2. Include the error output in the finding description. |
| **Story file missing or incomplete** | Halt immediately. Inform the user and list available stories. |
| **Max iterations reached** | Escalate with full history of findings across all iterations. |
| **File List missing in story** | Attempt to infer from version control diff. Warn if unable to determine changed files. Flag as a finding. |
| **Previous loop status corrupt** | Start a fresh iteration count at 1 and warn the user. |
| **Cannot determine AC mapping** | Mark Check 3 as a HIGH finding with a note about unclear traceability. |
| **Test suite has pre-existing failures** | Distinguish between pre-existing and new failures. Only count new failures against this review. Document pre-existing failures as context. |
| **Story has no acceptance criteria** | Halt. This is a process violation. Story should not be in review without ACs. |
| **Conflicting findings from previous iterations** | Note the conflict in the review. Prioritize the most recent finding. |
| **Review scope too large (> 50 files)** | Focus on files in the File List and high-risk areas. Note files not reviewed in the gate file. |

## Examples

### Example: APPROVE Verdict

```
Story: 3.2 -- Add user profile endpoint
Quality Score: 92/100
Verdict: APPROVE

Checks:
1. Code Quality: PASS (clean implementation, follows existing patterns)
2. Test Adequacy: PASS (14 tests added, covers happy path and errors)
3. AC Traceability: PASS (all 3 ACs mapped to tests)
4. Regression Safety: PASS (all 47 existing tests pass)
5. Performance: PASS (pagination implemented, no N+1 queries)
6. Security: CONCERNS (rate limiting not implemented -- MEDIUM finding)
7. Documentation: PASS (API docs updated)

Deferred: 1 MEDIUM (rate limiting), 1 LOW (variable naming in test file)
Next: Proceed to completion. Deferred items to qa-backlog-add-followup.
```

### Example: REJECT Verdict

```
Story: 4.1 -- Payment processing integration
Quality Score: 48/100
Verdict: REJECT

Checks:
1. Code Quality: FAIL (error handling missing in payment callback)
2. Test Adequacy: FAIL (no tests for error paths)
3. AC Traceability: CONCERNS (AC-4 "retry on failure" not implemented)
4. Regression Safety: PASS
5. Performance: CONCERNS (synchronous HTTP call in event handler)
6. Security: FAIL (API key logged in debug output)
7. Documentation: CONCERNS (webhook endpoint undocumented)

Fix List (ordered):
1. CRITICAL: Remove API key from log output (security.ts:42)
2. HIGH: Add error handling in payment callback (payment-handler.ts:78-95)
3. HIGH: Implement AC-4 retry logic (payment-handler.ts)
4. HIGH: Add tests for error paths
5. MEDIUM: Convert sync HTTP call to async
Iteration: 1/5. Next: qa-create-fix-request.
```

## Blocking Conditions

Stop the review and request clarification if:

- Story file is incomplete or missing critical sections.
- File List is empty or clearly incomplete.
- No tests exist when they were required.
- Code changes do not align with story requirements.
- Critical architectural issues that require discussion.

## Key Principles

- Provide comprehensive quality assessment across all seven dimensions.
- Authority to improve code directly when safe and appropriate.
- Always explain changes for learning purposes.
- Balance between perfection and pragmatism.
- Focus on risk-based prioritization.
- Provide actionable recommendations with clear ownership.

## Acceptance Criteria

- [ ] Story context loaded including ACs, scope, File List, and dev notes.
- [ ] QA loop iteration tracked and previous findings loaded for re-reviews.
- [ ] Review depth determined based on risk signals.
- [ ] All 7 quality checks executed with findings documented.
- [ ] Each finding has severity, description, file reference, and recommendation.
- [ ] AC traceability verified: each AC mapped to implementation and tests.
- [ ] Verdict determined by applying the decision tree correctly.
- [ ] Quality score calculated.
- [ ] QA Results appended to story file (not replacing existing content).
- [ ] Gate file created with all required fields.
- [ ] QA loop status updated with current iteration data.
- [ ] For REJECT: prioritized fix list produced ordered by severity.
- [ ] For APPROVE: deferred items identified for backlog follow-up.
- [ ] Handoff provides clear next action.

## Notes

- The QA reviewer has authority to perform minor refactoring when safe and appropriate. This accelerates the loop by fixing trivial issues in-place rather than bouncing back to @dev.
- The 7 quality checks are comprehensive but weighted by context. A CLI utility does not need the same depth of security review as a payment processing endpoint.
- Quality score is a guideline for tracking improvement across iterations. It should trend upward with each REJECT-fix cycle.
- The gate file serves as the audit trail. It should contain enough detail for anyone to understand the review outcome without reading the full story.
- Max iterations (default 5) is a safety valve. Most stories should resolve in 1-2 iterations. Reaching 3+ iterations suggests a deeper issue (unclear requirements, skill gap, architectural mismatch).
- BLOCKED verdicts should be rare and indicate genuine impediments, not preference for different approaches.
- When re-reviewing after REJECT, prioritize verifying that previously identified CRITICAL and HIGH issues are resolved before conducting a full re-review.
