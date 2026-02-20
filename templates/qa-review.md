# QA Review Report

**Story:** {epicNum}.{storyNum} — {title}
**Reviewer:** @qa
**Date:** {date}
**Iteration:** {number} of {max}
**Context:** {QA Loop | Brownfield Discovery | Standalone}

---

## Review Scope

### Files Reviewed

| File | Changes | Risk |
|------|---------|------|
| `{path}` | {summary of changes} | {Low/Medium/High} |

### Acceptance Criteria Reviewed

| AC | Description | Status | Evidence |
|----|-------------|--------|----------|
| AC-1 | {criterion} | {Met | Not Met | Partial} | {how verified} |
| AC-2 | {criterion} | {status} | {evidence} |

---

## Findings

### Critical

| # | Finding | Location | Recommendation |
|---|---------|----------|---------------|
| C-1 | {description} | `{file:line}` | {how to fix} |

### High

| # | Finding | Location | Recommendation |
|---|---------|----------|---------------|
| H-1 | {description} | `{file:line}` | {how to fix} |

### Medium *(document as tech debt)*

| # | Finding | Location | Notes |
|---|---------|----------|-------|
| M-1 | {description} | `{file:line}` | {context} |

### Low *(informational)*

| # | Finding | Notes |
|---|---------|-------|
| L-1 | {description} | {context} |

---

## Test Results

| Type | Passed | Failed | Skipped | Coverage |
|------|--------|--------|---------|----------|
| Unit | {count} | {count} | {count} | {percentage} |
| Integration | {count} | {count} | {count} | {percentage} |
| E2E | {count} | {count} | {count} | — |

---

## Verdict

**Decision:** {APPROVE | REJECT | BLOCKED}

### Verdict Rationale
{1-2 sentences explaining the decision}

### Conditions *(if APPROVE with observations)*
- {condition or observation for future work}

### Required Fixes *(if REJECT)*
| Priority | Finding | Expected Resolution |
|----------|---------|-------------------|
| {Must/Should} | {reference to finding ID} | {what "fixed" looks like} |

### Blockers *(if BLOCKED)*
- {what prevents review from completing — escalate immediately}

---

## Previous Iterations *(if iteration > 1)*

| Iteration | Date | Verdict | Issues Found | Issues Resolved |
|-----------|------|---------|-------------|----------------|
| {num} | {date} | {verdict} | {count} | {count} |

---

## Recommendations

- {suggestion for code quality, even if approving}
- {tech debt to track for future sprints}
