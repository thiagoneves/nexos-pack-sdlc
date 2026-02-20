---
task: dev-improve-code-quality
agent: dev
inputs:
  - target path or file
  - improvement patterns (optional)
  - configuration (optional)
outputs:
  - improved code files
  - quality report
  - backup files (if enabled)
---

# Improve Code Quality

## Purpose

Analyze and improve code quality across multiple dimensions including formatting consistency, linting compliance, modern syntax adoption, import organization, dead code elimination, naming conventions, error handling patterns, and type safety. Changes are applied incrementally with backup support and full transparency into what was modified and why.

This task operates on existing code and is independent of story-driven development. It can be run at any time against any part of the codebase.

## Prerequisites

- Target files or directories exist and are accessible.
- The project has a working development environment (dependencies installed).
- Linting and formatting tools are configured (e.g., ESLint, Prettier) if pattern-specific improvements are requested.
- Version control is initialized so changes can be reviewed and reverted.

## Execution Modes

### Autopilot Mode (autonomous)
- 0-1 prompts. Analyze and apply all safe improvements automatically.
- Only apply changes with confidence >= threshold (default: 0.8).
- Log every change to the quality report.
- **Best for:** Well-tested codebases, formatting-only passes, CI pipelines.

### Interactive Mode (default)
- 5-10 prompts at key decision points.
- Present discovered improvements grouped by file, with confidence scores.
- User selects which improvements to apply (checkbox-style).
- Pre-check high-confidence improvements (>= 0.9).
- **Best for:** First-time quality pass, unfamiliar codebase, learning.

### Pre-Flight Mode (plan-first)
- Full analysis phase: scan all files, catalog all improvements.
- Present complete improvement plan organized by pattern and impact.
- User approves or modifies the plan before any code changes.
- **Best for:** Large codebases, team review, risk-averse environments.

## Steps

### Step 1: Parse Input and Configuration

Read the target path and options:
- **Target:** File or directory to improve.
- **Patterns:** Which improvement patterns to apply (default: all applicable).
- **Recursive:** Process subdirectories (default: false for single dir, true for project root).
- **Exclude:** File patterns to skip (e.g., `*.test.*`, `dist/`, `node_modules/`).
- **Confidence threshold:** Minimum for auto-apply (0.0-1.0, default: 0.8).
- **Backup:** Create backups before changes (default: true).

If a project-level quality config file exists, load and merge with provided options.

### Step 2: Discover Files

- If target is a single file, process it only.
- If target is a directory, discover all source files (`.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`, `.vue`, `.svelte`).
- Apply exclusion patterns. Skip `node_modules/`, `.git/`, `dist/`, `build/`.
- Report total file count.

### Step 3: Analyze Files for Improvements

Run applicable improvement pattern analyzers on each file:

| Pattern | Description | Confidence Range |
|---------|-------------|-----------------|
| `formatting` | Consistent formatting (indentation, spacing, semicolons) | 0.95-1.0 |
| `linting` | ESLint rule compliance, auto-fixable violations | 0.85-1.0 |
| `modern-syntax` | ES6+ upgrades (arrow functions, template literals, destructuring, optional chaining) | 0.80-0.95 |
| `imports` | Import sorting, unused import removal, grouping | 0.85-0.95 |
| `dead-code` | Unreachable code, unused variables, commented-out blocks | 0.70-0.90 |
| `naming` | Variable/function naming convention consistency | 0.60-0.85 |
| `error-handling` | Try/catch patterns, error propagation, missing handlers | 0.65-0.85 |
| `async-await` | Promise chain to async/await, sequential-to-parallel | 0.70-0.90 |
| `type-safety` | Type annotations, removing `any`, null checks | 0.60-0.80 |
| `documentation` | Missing JSDoc/TSDoc for public functions, outdated comments | 0.50-0.75 |

For each improvement found: assign unique ID, record file, line range, pattern, description, confidence, before/after preview. Filter by confidence threshold.

### Step 4: Create Backups (if enabled)

Create timestamped backup directory. Copy each file to be modified. Record backup paths in report.

### Step 5: Present Improvements

- **Autopilot:** Skip to Step 6 with all above-threshold improvements selected.
- **Interactive:** Group by file. List with ID, pattern, description, confidence, preview. Pre-select high-confidence items. User confirms.
- **Pre-Flight:** Present full plan with statistics, organized by pattern. User approves.

### Step 6: Apply Improvements

For each selected improvement:
1. Read current file content.
2. Apply transformation at specified location.
3. Validate: ensure file still parses correctly, run formatter if available.
4. Write updated file. Track in results list.

If an improvement fails to apply cleanly: skip it, log the failure, continue.

### Step 7: Run Validation

```bash
npm run lint        # if available
npm run typecheck   # if available
npm test            # if available
```

If any fails: review which improvements caused it, revert those specific changes, re-run. After 2 failed revert-and-retry cycles, HALT.

### Step 8: Generate Quality Report

```yaml
quality-report:
  timestamp: "{timestamp}"
  target: "{target_path}"
  files_analyzed: {count}
  improvements_found: {count}
  improvements_applied: {count}
  improvements_skipped: {count}
  patterns_summary:
    - pattern: "{name}"
      found: {count}
      applied: {count}
      average_confidence: {value}
  files_modified:
    - path: "{relative_path}"
      improvements_applied: {count}
      patterns: ["{pattern1}", "{pattern2}"]
  backup_location: "{backup_path}"
  validation:
    lint: PASS | FAIL | SKIPPED
    typecheck: PASS | FAIL | SKIPPED
    tests: PASS | FAIL | SKIPPED
```

### Step 9: Report Results

Inform user of: files analyzed, improvements found vs applied, breakdown by pattern, validation status, backup location, and next steps (review with `git diff`, run full tests, commit if satisfied).

## Error Handling

| Error | Resolution |
|-------|------------|
| Target path does not exist | HALT: "Target path not found: {path}." |
| No files found after filtering | Warn: suggest checking exclude patterns. |
| Formatter/linter not configured | Skip pattern-specific improvements. Warn which patterns skipped. |
| Improvement breaks syntax | Revert specific improvement automatically. Log failure. Continue. |
| All improvements fail to apply | Report analysis results without changes. Suggest Pre-Flight mode. |
| Validation fails after improvements | Attempt targeted reverts. If unable, revert all from backup. |
| Backup creation fails | HALT before applying any changes. Report error. |
| Git not initialized | Warn: rollback depends on backups only. |

## Acceptance Criteria

- [ ] All selected improvements applied without introducing syntax errors.
- [ ] Lint, typecheck, and tests pass after improvements (or failures isolated and reverted).
- [ ] Quality report generated documenting all changes.
- [ ] Backups created before modifications (when enabled).
- [ ] No improvements applied below confidence threshold.
- [ ] Execution mode preference respected throughout.
- [ ] Excluded files never modified.
- [ ] Original functionality preserved (no behavioral changes).

## Notes

- This task focuses on non-behavioral changes. Improvements should not alter what the code does, only how it is written.
- When in doubt about a transformation's safety, prefer lower confidence and let the user decide.
- For large codebases, consider running pattern-by-pattern for reviewable changes.
- Test files excluded by default. Override with explicit inclusion.
- Pairs well with `dev-suggest-refactoring` (structural improvements) and `dev-optimize-performance` (runtime optimizations).
