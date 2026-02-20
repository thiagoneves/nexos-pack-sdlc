---
task: qa-run-tests
agent: qa
workflow: story-development-cycle (qa-gate)
inputs:
  - target (required, string - test target or story reference)
  - criteria (required, array - validation criteria from config)
  - strict (optional, boolean, default: true)
outputs:
  - validation_result (boolean)
  - errors (array)
  - qa report (file, using qa-gate template)
---

# Run Tests (with Code Quality Gate)

## Purpose
Execute the test suite and validate code quality before marking tests complete. Combines automated test execution with static code analysis to provide a comprehensive quality assessment with a clear pass/fail signal.

## Prerequisites
- Test framework is installed and configured (e.g., Jest)
- Code quality tools are available
- Validation rules are loaded and target is available for validation
- Project dependencies are installed

## Steps

### 1. Run Unit Tests
```bash
npm run test
```

**Expected:** All tests pass, coverage >= 80%.

Record results: pass/fail counts, coverage percentages (lines, branches, functions), duration.

### 2. Run Integration Tests
```bash
npm run test:integration
```

Record results if available. Skip gracefully if command does not exist.

### 3. Code Quality Review
Run static analysis on the code that was tested:

```bash
# Review uncommitted code for quality issues
```

**Parse output by severity:**
- CRITICAL or HIGH issues found: **FAIL**
- Only MEDIUM/LOW issues: **WARN** but **PASS**

### 4. Generate QA Report
Use the QA gate report template. Include:
- Test results (pass/fail, coverage percentage)
- Code quality summary (issues by severity)
- Recommendation (approve or reject story)

### 5. Update Story Status

**If all pass:**
- Mark story testing complete
- Add QA approval comment
- Move to "Ready for Deploy"

**If failures:**
- Document failures in story
- Create tech debt issues for MEDIUM severity items
- Request fixes from development

## Code Quality Integration
Static code analysis assists the QA process by:
- Catching issues tests might miss (logic errors, race conditions)
- Validating security patterns (SQL injection, hardcoded secrets)
- Enforcing coding standards automatically
- Generating quality metrics

## Configuration

```yaml
codeQuality:
  enabled: true
  severity_threshold: high
  auto_fix: false  # QA reviews but does not auto-fix
  report_location: docs/qa/coderabbit-reports/
```

## Error Handling
- **Validation Criteria Missing:** Ensure validation criteria loaded from config; use default validation rules and log warning
- **Invalid Schema:** Update schema or fix target structure; provide detailed validation error report
- **Dependency Missing:** Install missing dependencies; abort with clear dependency list
- **Test Timeout:** Log timeout, report partial results, mark as incomplete
- **Build Required First:** If tests fail due to missing build, recommend running build before tests
