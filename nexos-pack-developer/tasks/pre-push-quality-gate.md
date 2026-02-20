---
task: pre-push-quality-gate
agent: devops
inputs:
  - repository path
  - story file (optional)
  - configuration
outputs:
  - quality gate verdict (PASS / CONCERNS / FAIL)
  - gate report
  - push approval
---

# Pre-Push Quality Gate

## Purpose

Execute comprehensive quality checks before pushing code to the remote repository. This task acts as a local quality gate that verifies code quality, test health, type safety, build integrity, security posture, and optionally story status before any code leaves the developer's machine. The gate produces a verdict (PASS, CONCERNS, FAIL) and only allows pushing when quality standards are met.

Run this task every time before pushing code to the remote, regardless of whether the changes are story-driven or standalone.

## Prerequisites

- Git repository with committed changes to push.
- No uncommitted changes (clean working tree).
- A `package.json` (or equivalent) with available quality scripts.
- The task gracefully handles missing scripts -- it skips checks that have no corresponding command.

## Steps

### 1. Repository Context Detection

Detect the repository and project context:
- Verify `.git` directory exists.
- Detect the current branch name.
- Detect the remote URL and name.
- Identify the project type from project files (package.json, pyproject.toml, go.mod, Cargo.toml, etc.).
- Determine which quality scripts are available by inspecting the project configuration.

Report the context:
```
Repository: {remote_url}
Branch:     {branch_name}
Project:    {project_name} v{version}
Available:  lint, typecheck, test, build
```

### 2. Check for Uncommitted Changes

Verify the working tree is clean:
- Run `git status --porcelain`.
- If output is not empty: report FAIL with the list of uncommitted files.
- Suggest: "Commit or stash changes before pushing."

### 3. Check for Merge Conflicts

Verify no conflict markers remain in the codebase:
- Run `git diff --check` against staged and committed files.
- If conflicts are detected: report FAIL with the conflicting files.
- Suggest: "Resolve all merge conflicts before pushing."

### 4. Run Linting

Execute the project's linting command:
- Detect the lint command (e.g., `npm run lint`, `python -m pylint`, `golint ./...`).
- If the lint script does not exist: SKIP with a warning.
- If lint passes: mark as PASS.
- If lint fails: mark as FAIL, report the specific errors.

### 5. Run Type Checking

Execute the project's type checking command:
- Detect the typecheck command (e.g., `npm run typecheck`, `mypy`, etc.).
- If the typecheck script does not exist: SKIP with a warning.
- If typecheck passes: mark as PASS.
- If typecheck fails: mark as FAIL, report the specific type errors.

### 6. Run Tests

Execute the project's test suite:
- Detect the test command (e.g., `npm test`, `pytest`, `go test ./...`, `cargo test`).
- If the test script does not exist: SKIP with a warning.
- If all tests pass: mark as PASS.
- If tests fail: mark as FAIL, report failing test names and error summaries.

### 7. Run Build

Execute the project's build command:
- Detect the build command (e.g., `npm run build`, `go build`, `cargo build`).
- If the build script does not exist: SKIP with a warning.
- If build succeeds: mark as PASS.
- If build fails: mark as FAIL, report the build errors.

### 8. Run Security Scan

Perform basic security checks:

**Dependency Audit:**
- Run `npm audit` (Node.js), `pip audit` (Python), `cargo audit` (Rust), or equivalent.
- Categorize findings: critical, high, moderate, low.
- If critical vulnerabilities exist: mark as FAIL.
- If only high vulnerabilities: mark as CONCERNS.
- If moderate/low only: mark as PASS with notes.
- If no audit tool is available: SKIP with a warning.

**Secret Detection:**
- Scan committed files for patterns that look like secrets:
  - API keys, tokens, passwords in code or configuration.
  - `.env` files that should not be committed.
  - Private keys or certificates.
- If secrets detected: mark as FAIL.
- If no secrets detected: mark as PASS.

**Security Lint Rules (if available):**
- Check for common security anti-patterns (SQL injection vectors, eval usage, etc.).
- If security lint config exists, run it.
- If not available: SKIP.

### 9. Verify Story Status (Optional)

If a story file path is provided or can be inferred from the branch name:
- Read the story file.
- Check the status field.
- Expected status for push: `Done` or `InReview`.
- If status is `InProgress` or `Ready`: mark as CONCERNS with a note that the story may not be complete.
- If status is `Draft`: mark as CONCERNS with a stronger warning.
- If no story file is found: SKIP without penalty.

### 10. Compile Gate Verdict

Aggregate all check results into an overall verdict:

| Verdict | Criteria | Action |
|---------|----------|--------|
| **PASS** | All checks PASS or SKIP. No FAIL, no CONCERNS. | Ready to push. |
| **CONCERNS** | No FAIL checks. At least one CONCERNS. | Warn user. Push allowed with acknowledgment. |
| **FAIL** | At least one FAIL check. | Block push. Must fix before pushing. |

### 11. Present Summary Report

Display the quality gate results:

```
Pre-Push Quality Gate Summary
---------------------------------------------------------------------
Repository:  {remote_url}
Branch:      {branch_name}
Project:     {project_name} v{version}

Quality Checks:
  {icon} Uncommitted changes      {PASS|FAIL}
  {icon} Merge conflicts           {PASS|FAIL}
  {icon} Linting                   {PASS|FAIL|SKIP}
  {icon} Type checking             {PASS|FAIL|SKIP}
  {icon} Tests                     {PASS|FAIL|SKIP}
  {icon} Build                     {PASS|FAIL|SKIP}
  {icon} Security scan             {PASS|FAIL|CONCERNS|SKIP}
  {icon} Story status              {PASS|CONCERNS|SKIP}

Security Scan Details:
  Dependencies: {critical} critical, {high} high, {moderate} moderate
  Secrets: {none_detected | list_of_detected}

Overall Verdict: {PASS|CONCERNS|FAIL}
---------------------------------------------------------------------
```

**If PASS:**
- Confirm the user wants to proceed with push.
- If confirmed, the push operation can proceed (handled by the devops agent's push command).

**If CONCERNS:**
- List the specific concerns.
- Ask user: "Quality gate has concerns. Proceed with push? (y/N)"
- Default to NO -- user must explicitly confirm.
- If user declines, suggest remediation steps.

**If FAIL:**
- List all failing checks with details and error messages.
- Block push entirely.
- Provide specific action items for each failure:
  - "Fix lint errors: run `{lint_command}` and address reported issues."
  - "Fix failing tests: {list of failing tests}."
  - "Fix security issues: run `{audit_fix_command}`."
  - "Remove secrets from codebase: {files containing secrets}."

### 12. Generate Gate Report (Optional)

If requested, produce a structured gate report:

```yaml
quality-gate-report:
  timestamp: "{timestamp}"
  repository: "{remote_url}"
  branch: "{branch_name}"
  verdict: PASS | CONCERNS | FAIL
  checks:
    - name: "Uncommitted Changes"
      status: PASS | FAIL
      details: "{details}"
    - name: "Merge Conflicts"
      status: PASS | FAIL
      details: "{details}"
    - name: "Linting"
      status: PASS | FAIL | SKIP
      details: "{details}"
      errors: {count}
    - name: "Type Checking"
      status: PASS | FAIL | SKIP
      details: "{details}"
      errors: {count}
    - name: "Tests"
      status: PASS | FAIL | SKIP
      details: "{details}"
      passed: {count}
      failed: {count}
    - name: "Build"
      status: PASS | FAIL | SKIP
      details: "{details}"
    - name: "Security - Dependencies"
      status: PASS | FAIL | CONCERNS | SKIP
      vulnerabilities:
        critical: {count}
        high: {count}
        moderate: {count}
        low: {count}
    - name: "Security - Secrets"
      status: PASS | FAIL
      details: "{details}"
    - name: "Story Status"
      status: PASS | CONCERNS | SKIP
      story_id: "{id}"
      story_status: "{status}"
  action_items:
    - "{action_1}"
    - "{action_2}"
```

## Exit Codes

- `0` - All checks passed, user approved push.
- `1` - Quality gate failed (blocking).
- `2` - User declined to push.

## Error Handling

- **Git not initialized:** Halt with message: "Not a Git repository. Initialize git first."
- **No remote configured:** Warn: "No remote configured. Quality checks will run but push is not possible."
- **Quality script not found:** SKIP the check with a warning. Do not fail the entire gate because a script is missing.
- **Quality script times out:** After a configurable timeout (default: 5 minutes per check), kill the process. Mark as FAIL with timeout note. Suggest optimizing the script or increasing the timeout.
- **Security audit tool not installed:** SKIP security dependency audit. Suggest installing the audit tool.
- **Cannot read story file:** SKIP story status check. Warn that story status was not verified.
- **All checks skipped:** Warn: "No quality checks were available to run. Consider configuring lint, typecheck, and test scripts."
- **Git status command fails:** Halt with message and suggest checking git installation.

## Notes

- This task is the quality enforcement point before code reaches the remote. It is non-negotiable for production branches.
- The gate is designed to be fast (under 5 minutes for most projects). Long test suites may increase the time.
- For emergency hotfixes, a skip mechanism should exist but must be logged and audited. Do not implement bypass without team agreement.
- Works with ANY project type (Node.js, Python, Go, Rust, etc.) by detecting available commands.
- Secret detection uses pattern matching and may have false positives. Users should review flagged items.
- The push operation itself is handled separately by the devops agent. This task only determines whether the push should proceed.
