---
task: qa-create-fix-request
agent: qa
workflow: qa-loop (fix request phase)
inputs: [QA review report with REJECT verdict, story file]
outputs: [fix request document, issue summary]
---

# Create Fix Request

## Purpose

Generate a structured fix request document for @dev based on QA review findings. This task parses the QA review report, extracts all issues by severity, and produces a clear, actionable document that tells @dev exactly what to fix, where to fix it, and how to verify the fix. The fix request serves as the contract between @qa and @dev in the QA loop: @dev fixes only what is listed, nothing more.

## Prerequisites

- A QA review report exists for the story (produced by `qa-review-story` or `qa-gate`).
- The review verdict is REJECT or FAIL, indicating issues that must be addressed.
- The story is in `InReview` status.
- The QA loop has been initiated or is in progress.

## Steps

### 1. Load QA Review Report

Locate and read the QA review report for the story:

- Check the story's QA results section for inline findings.
- Check `{qa-location}/reports/{story-id}-report.md` for standalone reports.
- Check `{qa-location}/assessments/` for related assessment files.
- Parse the report to extract:
  - Story metadata (ID, title, review date, iteration number).
  - Verdict (REJECT or FAIL with reason).
  - Issue list with severity levels.
  - Failed acceptance criteria.
  - Test failures if any.
  - Reviewer notes and recommendations.

If no QA report is found, halt and inform the user. Suggest running `@qa *review-story {story-id}` first.

### 2. Extract and Classify Issues

For each finding in the QA report, extract the issue details and classify by severity:

**Severity levels:**

| Severity | Inclusion | Description |
|----------|-----------|-------------|
| **CRITICAL** | Always include | Broken functionality, security vulnerability, data loss risk. Must fix before merge. |
| **HIGH** | Always include | Missing AC, failing test, significant code quality issue. Should fix before merge. |
| **MEDIUM** | Include if flagged | Suboptimal pattern, missing edge case, minor quality concern. Document as tech debt if deferred. |
| **LOW** | Exclude by default | Style nit, minor documentation gap, cosmetic issue. Handle via `qa-backlog-add-followup`. |

For each issue, extract or derive:

```yaml
issue:
  id: "FIX-{story-id}-{SEQ}"  # e.g., "FIX-3.2-001"
  severity: "CRITICAL | HIGH | MEDIUM"
  title: "{short description of the problem}"
  category: "code | tests | requirements | performance | security | docs"
  location:
    file: "{file path}"
    line: "{line number or range if available}"
    function: "{function or method name if applicable}"
  problem:
    description: "{what is wrong}"
    code_snippet: "{problematic code if available}"
  expected:
    description: "{what it should be}"
    code_snippet: "{suggested fix if available}"
  verification:
    - "{step to verify the fix}"
    - "{additional verification}"
  related_ac: "{AC reference if applicable}"
  related_check: "{QA check number: 1-7}"
```

### 3. Prioritize and Order Issues

Order the issues for @dev to address:

1. **CRITICAL issues first** -- These block approval and must be resolved.
2. **HIGH issues second** -- These also block approval.
3. **MEDIUM issues last** -- Include only if specifically requested; otherwise note as deferrable.

Within the same severity, order by:
- Issues with clear code fixes before issues requiring investigation.
- Issues in the same file grouped together (reduces context switching).
- Issues related to the same AC grouped together.

### 4. Generate Fix Recommendations

For each issue, provide actionable guidance:

- **Code issues:** Include the problematic code snippet and a suggested fix or pattern to follow. Reference existing code in the project that demonstrates the correct approach.
- **Test issues:** Specify which tests to add or fix, what assertions are needed, and what edge cases to cover.
- **Security issues:** Reference the specific vulnerability pattern and the standard remediation. Include OWASP references where applicable.
- **Performance issues:** Describe the performance concern, the expected behavior, and how to verify the improvement.
- **Documentation issues:** Specify what needs to be documented and where.

Do not provide full implementations -- give enough direction for @dev to fix efficiently without dictating every line.

### 5. Define Constraints

Add a constraints section that explicitly scopes @dev's work:

- Fix ONLY the listed issues.
- Do NOT add new features.
- Do NOT refactor unrelated code.
- Run the full test suite before marking fixes complete.
- Run linting and type checking before marking fixes complete.
- Update the story's File List if new files are created.
- Do NOT change existing test assertions to make tests pass (fix the code, not the tests).

### 6. Generate Fix Request Document

Produce the fix request document using the template below. Save it to the story's QA directory.

### 7. Summarize and Notify

Output a summary for the user:

```
Fix Request Generated: {file-path}
Issues: {critical-count} CRITICAL, {high-count} HIGH, {medium-count} MEDIUM
Next: @dev applies fixes, then @qa re-reviews with *qa-loop-review
```

## Output Format

### Primary Output: Fix Request Document

Save to: `{story-directory}/qa/QA_FIX_REQUEST.md` or `{qa-location}/fix-requests/{story-id}-fix-request-{YYYYMMDD}.md`

```markdown
# QA Fix Request: {story-id}

**Generated:** {timestamp}
**QA Report Source:** {qa-report-path}
**Reviewer:** @qa
**QA Loop Iteration:** {iteration-number}

---

## Instructions for @dev

Fix ONLY the issues listed below. Do not add features or refactor unrelated code.

**Process:**
1. Read each issue carefully.
2. Fix the specific problem described.
3. Verify using the verification steps provided.
4. Mark the issue as fixed in this document.
5. Run all tests before marking complete.

---

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | {count} | Must fix before merge |
| HIGH | {count} | Must fix before merge |
| MEDIUM | {count} | Fix if included, otherwise defer |

---

## Issues to Fix

### 1. [{severity}] {title}

**Issue ID:** FIX-{story-id}-{SEQ}
**Category:** {category}
**Related AC:** {AC reference}
**Related Check:** {Check number and name}

**Location:** `{file-path}:{line-number}`

**Problem:**
{problem-description}

```{language}
{problematic-code-snippet}
```

**Expected:**
{expected-description}

```{language}
{suggested-fix-snippet}
```

**Verification:**
- [ ] {verification step 1}
- [ ] {verification step 2}
- [ ] {verification step 3}

**Status:** [ ] Fixed

---

[Repeat for each issue...]

## Constraints

**@dev must follow these constraints:**

- [ ] Fix ONLY the issues listed above
- [ ] Do NOT add new features
- [ ] Do NOT refactor unrelated code
- [ ] Do NOT change test assertions to make tests pass
- [ ] Run all tests before marking complete
- [ ] Run linting before marking complete
- [ ] Run type checking before marking complete
- [ ] Update story File List if new files created

---

## After Fixing

1. Mark each issue as fixed in this document.
2. Update the story's Dev Notes with a summary of fixes applied.
3. Add a Change Log entry with the fixes.
4. Request QA re-review: `@qa *qa-loop-review`
```

### Secondary Output: Gate Integration

If the fix request is generated as part of a QA loop, update the loop status:

```yaml
fix_request:
  generated: "{timestamp}"
  iteration: {number}
  issues:
    critical: {count}
    high: {count}
    medium: {count}
  path: "{fix-request-file-path}"
  status: "pending_dev"
```

## Error Handling

- **QA report not found:** Halt and inform the user. Provide the expected report locations. Suggest running `@qa *review-story {story-id}`.
- **QA report has no findings:** Inform the user that no fix request is needed. The story may be ready for approval. Suggest re-running the review if this is unexpected.
- **QA report format unrecognized:** Attempt to extract findings from any structured content. If the report is completely unstructured, list the raw content and ask the user to identify the issues to include.
- **All issues are LOW severity:** Inform the user that no fix request is warranted for LOW-only findings. Suggest using `qa-backlog-add-followup` to track them.
- **Cannot determine file location:** Include the issue without a specific file path. Add a note asking @dev to locate the affected code based on the description.
- **Duplicate issues in QA report:** Merge duplicates into a single fix request entry. Note that multiple findings pointed to the same issue.
- **Fix request already exists for this iteration:** Warn the user that overwriting will occur. In Interactive mode, confirm before overwriting.
- **Story not in InReview status:** Warn the user but allow generation. The fix request may be created proactively.

## Examples

### Example: Fix Request for Story 3.2

```markdown
# QA Fix Request: 3.2

**Generated:** 2026-02-20T14:30:00Z
**QA Report Source:** docs/qa/assessments/3.2-review-20260220.md
**Reviewer:** @qa
**QA Loop Iteration:** 1

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 1 | Must fix before merge |
| HIGH | 2 | Must fix before merge |
| MEDIUM | 0 | -- |

## Issues to Fix

### 1. [CRITICAL] Missing input validation in user registration

**Issue ID:** FIX-3.2-001
**Category:** security
**Related AC:** AC1 (User can register with valid email)
**Related Check:** Check 6 (Security)

**Location:** `src/services/auth.ts:42`

**Problem:**
User email input is passed directly to database query without validation
or sanitization.

**Expected:**
Validate email format and sanitize input before database operation.
Use the project's existing validation utility at `src/utils/validate.ts`.

**Verification:**
- [ ] Unit test: invalid email format returns validation error
- [ ] Unit test: email with SQL injection characters is rejected
- [ ] Integration test: registration with valid email succeeds

**Status:** [ ] Fixed
```

## Acceptance Criteria

- [ ] Fix request document is generated with the correct template structure.
- [ ] All CRITICAL issues from the QA report are included.
- [ ] All HIGH issues from the QA report are included.
- [ ] Each issue has: ID, severity, title, location, problem, expected fix, verification steps.
- [ ] Issues are ordered by severity (CRITICAL first, then HIGH, then MEDIUM).
- [ ] Constraints section is present and complete.
- [ ] After-fixing instructions are present.
- [ ] Fix request file is saved to the correct location.
- [ ] Summary table accurately reflects issue counts by severity.
- [ ] Issue IDs follow the naming convention `FIX-{story-id}-{SEQ}`.

## Notes

- This task generates the fix request document. It does not apply fixes. Fixes are applied by @dev using `dev-apply-qa-fixes`.
- The fix request is a communication artifact. Its value lies in clarity and specificity. Vague fix requests lead to incomplete fixes and additional QA loop iterations.
- Include code snippets only when they add clarity. For simple issues (missing test, documentation gap), a clear description is sufficient.
- The verification steps are critical -- they tell @dev how to confirm the fix works and give @qa criteria for the re-review.
- If the QA report contains recommendations (not just issues), include them as guidance within the relevant issue entry rather than as separate items.
- The fix request should not prescribe implementation details beyond what is necessary. Tell @dev WHAT needs to change and WHY, not exactly HOW to write every line.
- MEDIUM issues included in the fix request should be clearly marked as optional if they are not blocking merge.
