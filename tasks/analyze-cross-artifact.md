---
task: analyze-cross-artifact
agent: qa
workflow: standalone (invokable by any agent)
inputs: [scope, optional story ID, project artifact files]
outputs: [cross-artifact analysis report to stdout]
---

# Cross-Artifact Consistency Analysis

## Purpose

Perform a read-only consistency analysis across all project artifacts -- PRD, architecture documents, stories, and specifications -- to identify coverage gaps, inconsistencies, ambiguities, and compliance violations. Produce a consolidated report with severity-ranked findings and actionable recommendations.

This task never modifies files. It analyzes and reports only.

## Prerequisites

- At least one project artifact exists (PRD, architecture doc, story, or spec).
- Artifacts follow the expected directory conventions for the project.
- The executor has read access to all relevant documentation directories.

## Execution Modes

### Autopilot (default for this task)

- No user interaction required.
- Analyze all artifacts in scope and produce the report.
- Best for: routine consistency checks, CI integration, pre-implementation validation.

### Interactive

- Pause after each analysis pass to present intermediate findings.
- Allow the user to narrow scope or skip passes.
- Best for: targeted investigation of specific inconsistencies.

### Pre-Flight

- Present the list of artifacts to be analyzed and the passes to run.
- Confirm scope and severity threshold before execution.
- Best for: first-time analysis of a large project.

## Severity Levels

| Severity | Description | Action |
|----------|-------------|--------|
| **CRITICAL** | Violates project standards, blocks progress | MUST fix before continuing |
| **HIGH** | Significant gap, high risk | SHOULD fix before implementation |
| **MEDIUM** | Moderate inconsistency | Consider fixing |
| **LOW** | Quality improvement opportunity | Nice to have |

## Steps

### 1. Determine Analysis Scope

Identify which artifacts to include based on the `scope` parameter:

| Scope | Artifacts Included |
|-------|--------------------|
| `all` (default) | PRD, architecture, stories, specs |
| `prd` | PRD documents only |
| `architecture` | Architecture documents only |
| `stories` | Story files only |
| `specs` | Specification files only |
| `prd,architecture` | PRD and architecture combined |

If a `storyId` is provided, narrow the analysis to that story and its related artifacts (parent epic, referenced PRD sections, related specs).

Locate artifacts by scanning standard project locations:
- `docs/prd.md` or `docs/prd/**/*.md`
- `docs/architecture.md` or `docs/architecture/**/*.md`
- `docs/stories/**/*.md`
- `docs/specs/**/*.md` or `docs/stories/**/spec/**`

If a category of artifacts is not found, log a warning and continue with available artifacts.

### 2. Parse and Extract Structure

For each artifact found, extract structured data:

**From PRD documents:**
- Functional requirements (FR-*)
- Non-functional requirements (NFR-*)
- Constraints (CON-*)
- User stories referenced
- Feature descriptions

**From architecture documents:**
- Technology decisions
- Component definitions
- Integration points
- Data models
- Non-functional design choices

**From story files:**
- Acceptance criteria
- Task checklists
- Scope (IN/OUT)
- Dependencies
- Status

**From specifications:**
- Detailed requirements mapping
- Open questions
- Assumptions
- Traceability matrix entries

Record the total count of each extracted element for the report summary.

### 3. Execute Analysis Pass 1 -- Coverage Gaps

Identify requirements without implementation and vice versa:

**Check 1.1: Requirements without tasks**
- For each FR-*, NFR-*, CON-* in the PRD, verify at least one story or spec addresses it.
- Severity: HIGH for unaddressed functional requirements, MEDIUM for non-functional.

**Check 1.2: Tasks without requirements**
- For each story task, verify it traces to a PRD requirement, spec item, or documented decision.
- Severity: MEDIUM (may indicate scope creep or undocumented decisions).

**Check 1.3: Acceptance criteria without tests**
- For stories with testable acceptance criteria, check if test files or test descriptions exist.
- Severity: HIGH (acceptance criteria should be verifiable).

**Check 1.4: Stories without specifications**
- For stories above a complexity threshold, check if a specification document exists.
- Severity: MEDIUM (simple stories may not need specs).

### 4. Execute Analysis Pass 2 -- Consistency Check

Detect contradictions and misalignments between artifacts:

**Check 2.1: PRD versus architecture**
- Verify PRD features have corresponding architecture coverage.
- Check for features described in PRD but absent from architecture.
- Check for architecture components with no PRD justification.
- Severity: HIGH.
- Sources: `docs/prd.md`, `docs/prd/`, `docs/architecture.md`, `docs/architecture/`.

**Check 2.2: Architecture versus stories**
- Verify architectural decisions are reflected in story implementations.
- Check for stories that contradict architectural constraints.
- Severity: MEDIUM.

**Check 2.3: Spec versus story**
- Compare spec details with story acceptance criteria.
- Detect divergence where spec and story disagree.
- Severity: HIGH (spec and story must align).

**Check 2.4: Terminology drift**
- Identify the same concept referred to by different names across artifacts.
- Build a terminology map and flag inconsistencies.
- Severity: LOW (confusing but not blocking).

### 5. Execute Analysis Pass 3 -- Ambiguity Detection

Identify under-specified or vague areas:

**Check 3.1: Vague requirements**
- Scan for ambiguous language patterns:
  - "should be fast", "user-friendly", "as needed", "etc.", "TBD", "TODO"
  - "appropriate", "reasonable", "adequate", "various"
- Severity: MEDIUM.

**Check 3.2: Missing acceptance criteria**
- Flag stories without measurable, testable acceptance criteria.
- Severity: HIGH (stories must have clear done conditions).

**Check 3.3: Unresolved questions**
- Find open questions in specs and stories that remain unanswered.
- Severity: MEDIUM (must be resolved before implementation).

**Check 3.4: Unvalidated assumptions**
- Find documented assumptions without validation evidence.
- Severity: LOW (should be validated but not blocking).

### 6. Execute Analysis Pass 4 -- Project Standards Compliance

Verify adherence to project-defined standards and practices:

**Check 4.1: Story structure compliance**
- Verify stories follow the expected template (title, description, AC, scope, tasks).
- Severity: MEDIUM.

**Check 4.2: Naming convention compliance**
- Check file naming, story numbering, and identifier patterns.
- Severity: LOW.

**Check 4.3: Traceability chain completeness**
- Verify the chain: PRD requirement -> spec -> story -> implementation -> test.
- Flag broken links in the chain.
- Severity: HIGH for missing links in critical paths.

**Check 4.4: Scope creep detection**
- Compare story scope against PRD and epic boundaries.
- Detect stories that address requirements not in the PRD.
- Severity: MEDIUM (may be valid but should be acknowledged).

### 7. Aggregate Findings

Consolidate all findings from the 4 passes:
- Group by severity: CRITICAL, HIGH, MEDIUM, LOW.
- Remove duplicates (same issue detected by multiple checks).
- Count totals per severity level.
- Determine overall health status:

| Condition | Health Status |
|-----------|--------------|
| No CRITICAL or HIGH findings | HEALTHY |
| No CRITICAL, some HIGH | CONCERNS |
| CRITICAL findings exist | AT_RISK |
| Multiple CRITICAL findings | BLOCKED |

### 8. Generate Report

Output the report in markdown format to stdout. Do NOT save to a file unless explicitly requested.

Use the following report structure:

```markdown
# Cross-Artifact Analysis Report

> **Generated:** {timestamp}
> **Scope:** {scope}
> **Analyzed:** {file_count} files

---

## Executive Summary

| Severity | Count |
|----------|-------|
| CRITICAL | {n} |
| HIGH | {n} |
| MEDIUM | {n} |
| LOW | {n} |

**Overall Health:** {HEALTHY | CONCERNS | AT_RISK | BLOCKED}

---

## Critical Findings

### Finding C{n}: {title}
- **Pass:** {coverage | consistency | ambiguity | compliance}
- **Check:** {check_id}
- **Location:** {file path or artifact reference}
- **Description:** {details}
- **Recommendation:** {specific action to resolve}

---

## High Priority Findings

### Finding H{n}: {title}
- **Pass:** {pass_name}
- **Check:** {check_id}
- **Location:** {location}
- **Description:** {details}
- **Recommendation:** {action}

---

## Coverage Metrics

| Metric | Value | Target |
|--------|-------|--------|
| Requirements with tasks | {n}% | 100% |
| Tasks with requirements | {n}% | 100% |
| Acceptance criteria with tests | {n}% | 80% |
| Stories with specs | {n}% | varies |

---

## Medium and Low Findings

{Grouped list of remaining findings with brief descriptions.}

---

## Recommendations

1. **Immediate:** {critical fixes that block progress}
2. **Before implementation:** {high-priority fixes to prevent rework}
3. **Improvement:** {medium/low fixes to improve quality}

---

## Files Analyzed

- {file1}
- {file2}
- ...
```

### 9. Present Results

Inform the user:
- Overall health status and finding counts.
- Summary of critical and high findings (if any).
- Top 3 recommendations.
- Suggest re-running analysis after fixes are applied.

## Checklist Integration

This analysis aggregates and references existing quality checklists:

| Checklist | Usage in Analysis |
|-----------|-------------------|
| Architect review checklist | Pass 2: PRD vs Architecture |
| Story draft checklist | Pass 3: Ambiguity in stories |
| Story definition of done | Pass 1: Coverage gaps |
| PM checklist | Pass 2: PRD consistency |
| PO master checklist | Pass 1: Story coverage |

## Output Format

The report is written to stdout in markdown format. It is not persisted to disk unless the user explicitly requests it. If requested, save to `{project_docs}/reports/cross-artifact-analysis-{timestamp}.md`.

## Error Handling

- **No PRD found:** Warn and continue analysis with available artifacts. Coverage checks against PRD will be skipped.
- **No stories found:** Warn and limit analysis to PRD and architecture documents.
- **No artifacts found at all:** HALT with message: "No analyzable artifacts found. Verify project structure and artifact locations."
- **Parse error in artifact:** Report the error for the specific file, skip it, and continue analysis with remaining files.
- **Empty analysis (no findings):** Report HEALTHY status with a confirmation that all checks passed.
- **Scope parameter invalid:** Default to `all` and warn the user.

## Examples

**Full project analysis:**
```
*analyze-cross-artifact
```

**Analyze only stories:**
```
*analyze-cross-artifact --scope stories
```

**Analyze a specific story and its related artifacts:**
```
*analyze-cross-artifact --story 2.1
```

**Analyze PRD against architecture:**
```
*analyze-cross-artifact --scope prd,architecture
```

**Analyze and save report to file:**
```
*analyze-cross-artifact --save
```

## Notes

- This task is strictly read-only. It MUST NOT modify any project files.
- Any agent can invoke this task, but @qa is the designated owner for workflow integration.
- The analysis is most valuable when run before starting implementation (pre-development validation) or before a major milestone review.
- For projects with many artifacts, consider using the `--scope` parameter to run focused analyses and reduce noise.
- Findings from this task can feed directly into story creation (coverage gaps become new stories) or spec revision (consistency issues become revision items).
