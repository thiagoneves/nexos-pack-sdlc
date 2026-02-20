---
task: dev-suggest-refactoring
agent: dev
inputs:
  - target path or file
  - refactoring patterns (optional)
  - impact threshold (optional)
outputs:
  - refactoring suggestions report
  - applied refactorings (if approved)
  - updated code files
---

# Suggest Refactoring

## Purpose

Analyze code structure and suggest refactoring opportunities to improve maintainability, readability, testability, and adherence to software design principles. Suggestions are ranked by impact and can be applied individually, selectively, or as a batch. Each suggestion includes a clear rationale, before/after preview, and risk assessment.

Unlike `dev-improve-code-quality` (syntax and style) or `dev-optimize-performance` (runtime efficiency), this task targets structural improvements -- extracting methods, decomposing classes, simplifying conditionals, removing duplication, and improving overall architecture.

## Prerequisites

- Target files or directories exist and are accessible.
- The project has a working development environment (dependencies installed).
- Version control is initialized so changes can be reviewed and reverted.
- Tests exist for the code being refactored (strongly recommended; refactoring without tests is risky).

## Execution Modes

### Autopilot Mode (autonomous)
- 0-1 prompts. Analyze all files and produce the suggestions report automatically.
- Do NOT auto-apply refactorings (structural changes require human judgment).
- Present suggestions ranked by impact with before/after previews.
- **Best for:** Generating a refactoring backlog for team planning.

### Interactive Mode (default)
- 5-10 prompts. Present suggestions grouped by file with impact scores and previews.
- For each suggestion: Apply / Skip / Show details / Dry-run.
- Confirm each refactoring before applying.
- **Best for:** Incremental refactoring sessions, pair-programming with AI.

### Pre-Flight Mode (plan-first)
- Full analysis: scan all files, catalog all opportunities.
- Present complete refactoring plan organized by priority and dependency order.
- Include risk assessment and effort estimates.
- User approves before any code is modified.
- Execute in dependency order.
- **Best for:** Large-scale refactoring, tech debt sprints, team alignment.

## Steps

### Step 1: Parse Input and Configuration

- **Target:** File or directory to analyze.
- **Patterns:** Which refactoring patterns to check (default: all applicable).
- **Threshold:** Minimum impact score (1-10, default: 3).
- **Limit:** Maximum suggestions per file (default: 10).
- **Recursive:** Process subdirectories (default: true).
- **Exclude:** File patterns to skip.
- **Dry-run:** Show changes without modifying files (default: false).
- **Report path:** Where to save the report (optional).

### Step 2: Discover Files

Identify source files. Apply exclusion patterns. Skip test files (by default), minified files, generated code, third-party code. Report total file count.

### Step 3: Analyze Code Structure

For each file, compute code metrics and run pattern detectors:

**Code Metrics:**
- Cyclomatic complexity per function.
- Lines of code per function/class/file.
- Nesting depth (maximum indent level).
- Parameter count per function.
- Coupling (imports/dependencies per file).
- Duplication (similar code blocks across files).

**Refactoring Patterns:**

| Pattern | Trigger | Impact Range |
|---------|---------|-------------|
| `extract-method` | Function > 30 lines or complexity > 10 | 5-9 |
| `extract-variable` | Complex expressions repeated or deeply nested | 3-6 |
| `introduce-parameter-object` | Function with > 4 parameters | 4-7 |
| `replace-conditional` | Long if/else or switch (> 4 branches) with polymorphic behavior | 6-9 |
| `inline-temp` | Single-use variables adding no clarity | 2-4 |
| `remove-dead-code` | Unreachable blocks, unused exports, orphan functions | 3-7 |
| `consolidate-duplicates` | Code blocks with > 70% similarity across files | 6-9 |
| `simplify-conditionals` | Nested conditionals > 3 levels, guard clause opportunities | 4-7 |
| `replace-magic-numbers` | Numeric/string literals in logic without named constants | 3-5 |
| `decompose-class` | Class > 300 lines or > 10 public methods (SRP violation) | 7-10 |
| `move-to-module` | Utility functions that belong in a shared module | 4-6 |
| `encapsulate-field` | Direct field access that should use getters/setters | 3-5 |

For each suggestion: assign unique ID, record file, line range, pattern, description, impact score (1-10), priority (high/medium/low), risk level, rationale, before/after preview.

### Step 4: Compute Dependencies Between Suggestions

Some refactorings depend on others:
- `extract-method` before `decompose-class` (smaller methods clarify decomposition).
- `consolidate-duplicates` before `move-to-module` (consolidate first, then relocate).
- `replace-magic-numbers` can happen independently.

Build dependency graph. Determine optimal application order.

### Step 5: Filter and Rank Suggestions

- Filter below threshold.
- Apply per-file limit.
- Rank by: priority (high > medium > low), then impact (descending), then effort (ascending).

### Step 6: Present Suggestions

- **Autopilot:** Generate full report with top suggestions.
- **Interactive:** Show summary, walk through each file's suggestions (ID, pattern, description, impact bar, preview). User selects.
- **Pre-Flight:** Present full plan with dependency order, effort/risk estimates. User approves.

### Step 7: Apply Refactorings (if approved)

For each approved suggestion, in dependency order:
1. **Backup** the target file.
2. **Apply** the structural transformation.
3. **Validate:** parse check, lint, typecheck, run relevant tests.
4. **Record** the applied refactoring.

If a refactoring causes failures: revert, log reason, skip dependent suggestions, continue with independent ones.

**Dry-run mode:** Show before/after diff without writing files.

### Step 8: Run Full Validation

```bash
npm run lint        # if available
npm run typecheck   # if available
npm test            # if available
```

All must pass. If failures traced to specific refactorings, revert those.

### Step 9: Generate Suggestions Report

```yaml
refactoring-report:
  timestamp: "{timestamp}"
  target: "{target_path}"
  files_analyzed: {count}
  total_suggestions: {count}
  applied: {count}
  skipped: {count}
  failed: {count}
  statistics:
    average_impact: {value}/10
    by_priority:
      high: {count}
      medium: {count}
      low: {count}
    by_pattern:
      - pattern: "{name}"
        count: {count}
        average_impact: {value}
  suggestions:
    - id: "{ref-id}"
      file: "{relative_path}"
      lines: "{start}-{end}"
      pattern: "{pattern}"
      description: "{description}"
      rationale: "{why_this_improves_code}"
      impact: {score}/10
      priority: high | medium | low
      risk: low | medium | high
      status: applied | skipped | failed | pending
      depends_on: ["{ref-id}"]
  validation:
    lint: PASS | FAIL | SKIPPED
    typecheck: PASS | FAIL | SKIPPED
    tests: PASS | FAIL | SKIPPED
```

### Step 10: Report Results

Inform user of: summary (files, suggestions, patterns), top suggestions with impact and effort, applied refactorings, validation status, and next steps (review with `git diff`, run tests, commit, re-run to see updated metrics, follow up with `dev-improve-code-quality` for style cleanup).

## Error Handling

| Error | Resolution |
|-------|------------|
| Target path does not exist | HALT: "Target path not found: {path}." |
| No files found | Warn: "No source files found after exclusions." |
| No suggestions above threshold | Report: "No suggestions above threshold {N}. Consider lowering." |
| Refactoring breaks tests | Revert specific refactoring. Log which tests failed. Continue. |
| Refactoring breaks dependent suggestion | Skip dependent. Log dependency chain failure. |
| Circular dependency in suggestions | Detect and report. Apply independently where possible. |
| File changed between analysis and apply | Re-analyze. If still applies, proceed. Otherwise skip. |
| Cannot determine code metrics | Skip metric-dependent patterns for that file. Log reason. |
| Test suite missing | Warn: "Refactoring without tests is high risk. Proceed with caution." Do not auto-apply. |
| Git not initialized | Warn: rollback depends on backups only. |

## Acceptance Criteria

- [ ] All applicable refactoring patterns checked for target code.
- [ ] Each suggestion includes rationale, impact score, and before/after preview.
- [ ] Suggestions ranked by priority and impact.
- [ ] Dependencies between suggestions identified and respected.
- [ ] Applied refactorings do not break tests, lint, or typecheck.
- [ ] Structured report generated documenting all suggestions and status.
- [ ] Execution mode respected throughout.
- [ ] Dry-run mode shows changes without modifying files.
- [ ] Failed refactorings reverted cleanly and logged.
- [ ] No refactorings applied below impact threshold.

## Notes

- Refactoring should be behavior-preserving. Same inputs must produce same outputs.
- Tests before refactoring are essential for safety. If no tests exist, recommend writing tests first or use Pre-Flight mode with manual verification.
- Small, focused refactorings are safer than sweeping changes. Prefer many small commits.
- Autopilot mode generates a refactoring backlog that feeds into sprint planning.
- Pairs well with `dev-improve-code-quality` (run quality first, then structural refactoring) and `dev-optimize-performance` (structural improvements often improve performance).
- For legacy codebases, consider running the Brownfield Discovery workflow first to understand system architecture.
