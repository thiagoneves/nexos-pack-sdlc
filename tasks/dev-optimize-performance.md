---
task: dev-optimize-performance
agent: dev
inputs:
  - target path or file
  - optimization focus (optional)
  - threshold level (optional)
outputs:
  - performance analysis report
  - optimized code (if approved)
  - before/after metrics
---

# Optimize Performance

## Purpose

Analyze code for performance bottlenecks and provide actionable optimization suggestions. This task performs static analysis across multiple performance dimensions -- algorithm complexity, memory usage, async patterns, database queries, bundle size, caching opportunities, and framework-specific concerns. Optimizations can be reviewed, selectively applied, and validated with before/after measurements.

This task operates on existing code and is independent of story-driven development. It can be run at any time to identify and resolve performance concerns proactively.

## Prerequisites

- Target files or directories exist and are accessible.
- The project has a working development environment (dependencies installed).
- Version control is initialized so changes can be reviewed and reverted.
- For database analysis: schema or ORM models are accessible.
- For bundle analysis: build tooling is configured (webpack, vite, rollup, etc.).

## Execution Modes

### Autopilot Mode (autonomous)
- 0-1 prompts. Analyze all files and produce the performance report automatically.
- Do NOT auto-apply optimizations (performance changes are higher risk).
- Present report with prioritized recommendations.
- **Best for:** Generating a performance audit report for team review.

### Interactive Mode (default)
- 5-10 prompts. Present issues grouped by category and severity.
- For each optimization with a concrete suggestion, offer to apply it.
- Confirm before applying any transformation.
- **Best for:** Iterative optimization sessions, learning performance patterns.

### Pre-Flight Mode (plan-first)
- Full analysis phase: scan all files, catalog all issues.
- Present complete optimization plan with estimated impact per change.
- User approves specific optimizations before code is modified.
- Execute sequentially with verification after each.
- **Best for:** Production codebases, high-risk changes, team consensus needed.

## Steps

### Step 1: Parse Input and Configuration

- **Target:** File or directory to analyze.
- **Focus:** Specific category to concentrate on (or all).
- **Threshold:** Minimum severity for reported issues (`low`, `medium`, `high`; default: `low`).
- **Recursive:** Process subdirectories (default: true).
- **Exclude:** File patterns to skip.
- **Report path:** Where to save the report (optional).

### Step 2: Discover Files

Identify all source files to analyze. Apply exclusion patterns. Skip test files, build artifacts, vendor code, minified files. For database focus: include migration files and ORM models. For bundle focus: include build config files.

### Step 3: Analyze Performance

For each file, run applicable analyzers:

| Category | What It Detects | Severity Range |
|----------|----------------|---------------|
| `algorithm` | O(n^2)+ loops, unnecessary iterations, inefficient sorting, brute-force searches | medium-critical |
| `memory` | Memory leaks, excessive object creation, missing cleanup, growing arrays in loops | medium-critical |
| `async` | Sequential awaits that could be parallel, unhandled rejections, blocking main thread | medium-high |
| `database` | N+1 queries, missing indexes (heuristic), unbounded queries, queries inside loops | high-critical |
| `bundle` | Large imports, missing dynamic imports, duplicate dependencies | low-high |
| `caching` | Repeated expensive computations, redundant API calls, missing HTTP cache headers | low-medium |
| `react` | Missing React.memo, inline function/object in render, missing key props, unnecessary state | medium-high |
| `general` | Synchronous file I/O, string concat in loops, regex compilation in loops, unnecessary deep cloning | low-high |

For each issue: assign unique ID, record file, line range, category, description, severity, estimated impact. Generate optimization suggestion with before/after code.

### Step 4: Calculate Performance Scores

For each file, calculate score (0-100): start at 100, deduct per issue (critical: -25, high: -15, medium: -8, low: -3). Floor at 0.

Calculate overall project score as weighted average.

### Step 5: Prioritize Recommendations

| Priority | Criteria | Action |
|----------|----------|--------|
| **P0 - Critical** | Severe degradation, worsens with scale | Fix immediately |
| **P1 - High** | Noticeable user impact | Fix in current sprint |
| **P2 - Medium** | Measurable but acceptable short-term | Plan for optimization |
| **P3 - Low** | Minor, micro-optimization | Document as tech debt |

Generate "Top 5 Recommendations" -- highest impact, lowest effort.

### Step 6: Present Results

- **Autopilot:** Generate full report and present summary.
- **Interactive:** Show summary (score, breakdown), walk through categories, offer Apply/Skip/Details for each.
- **Pre-Flight:** Present complete plan with effort/risk estimates. User approves items individually.

### Step 7: Apply Optimizations (if approved)

For each approved optimization:
1. Create backup of target file.
2. Apply code transformation.
3. Validate: run lint/typecheck, run relevant tests.
4. Measure improvement if possible.
5. Record applied optimization.

If optimization causes test failures: revert immediately, log reason, continue with remaining.

### Step 8: Run Validation

```bash
npm run lint        # if available
npm run typecheck   # if available
npm test            # if available
```

All must pass. If failures from optimizations, identify and revert.

### Step 9: Generate Performance Report

```yaml
performance-report:
  timestamp: "{timestamp}"
  target: "{target_path}"
  overall_score: {score}/100
  files_analyzed: {count}
  issues_found:
    critical: {count}
    high: {count}
    medium: {count}
    low: {count}
  optimizations_applied: {count}
  categories:
    - category: "{name}"
      issues: {count}
      top_issue: "{description}"
  top_recommendations:
    - rank: 1
      title: "{title}"
      description: "{description}"
      files_affected: {count}
      estimated_impact: "{impact}"
      effort: low | medium | high
  files:
    - path: "{relative_path}"
      score: {score}/100
      issues: {count}
  validation:
    lint: PASS | FAIL | SKIPPED
    typecheck: PASS | FAIL | SKIPPED
    tests: PASS | FAIL | SKIPPED
```

### Step 10: Report Results

Inform user of: overall score, issue breakdown, top 5 recommendations, optimizations applied, validation status, and next steps (address critical first, apply incrementally, set up monitoring, re-run to measure improvement).

## Error Handling

| Error | Resolution |
|-------|------------|
| Target path does not exist | HALT: "Target path not found: {path}." |
| No analyzable files found | Warn: "No source files found after exclusions." |
| Analysis timeout on large file | Skip file, log timeout, suggest breaking into smaller modules. |
| Optimization introduces test failure | Revert specific optimization. Log failure. Continue. |
| Optimization introduces lint/typecheck error | Revert specific change. Log details. |
| Cannot determine database patterns | Skip database category. Note in report. |
| Bundle analysis tools not configured | Skip bundle category. Note with suggestion to configure. |
| All optimizations fail | Present analysis-only report. Recommend manual review. |
| Git not initialized | Warn: rollback depends on backups only. |

## Acceptance Criteria

- [ ] Performance analysis covers all applicable categories.
- [ ] Each issue has clear description, severity, and actionable recommendation.
- [ ] Performance scores calculated consistently.
- [ ] Applied optimizations do not break tests or introduce errors.
- [ ] Report is complete, structured, and saved when requested.
- [ ] Critical and high severity issues prominently highlighted.
- [ ] Execution mode preference respected.
- [ ] No optimizations applied without approval (Autopilot is report-only).
- [ ] Excluded files never analyzed or modified.

## Notes

- Performance optimization is higher risk than code quality improvements. Always prefer correctness over speed.
- Focus on measurable bottlenecks, not micro-optimizations.
- For production systems, validate with real workload profiling, not just static analysis.
- Pairs well with `dev-improve-code-quality` (code health) and `dev-suggest-refactoring` (structural improvements).
- Consider running before major releases to catch performance regressions.
- Database optimizations may require DBA review for production systems.
