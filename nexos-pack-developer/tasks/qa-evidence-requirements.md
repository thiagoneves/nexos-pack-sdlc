---
task: qa-evidence-requirements
agent: qa
workflow: story-development-cycle (qa-gate, phase 1.2)
inputs:
  - story_id (required, string)
  - issue_type (optional: bug_fix, feature, dependency_update, refactor - auto-detected if omitted)
outputs:
  - evidence_checklist (file: docs/stories/{story-id}/qa/evidence_checklist.md)
  - evidence_status (object: { complete: boolean, missing: string[] })
---

# Evidence Requirements

## Purpose
Enforce evidence-based QA with mandatory proof of fix and verification. Detects the type of change (bug fix, feature, dependency update, refactor), generates the appropriate evidence checklist, and verifies that required evidence is present before allowing approval.

## Prerequisites
- Story file exists with acceptance criteria
- Commits exist for the story
- QA report or test results are available for evaluation

## Steps

### 1. Detect Issue Type
Identify the type of change from available signals:

**Bug Fix patterns:** Story title contains "fix", "bug", "issue"; commit messages contain "fix", "bug"; linked issue is type "bug".

**Feature patterns:** Story title contains "add", "implement", "create"; acceptance criteria present.

**Dependency Update patterns:** Changes in package.json or package-lock.json; story mentions "update", "upgrade", "dependency".

**Refactor patterns:** Story title contains "refactor", "cleanup", "reorganize"; no new features in acceptance criteria.

### 2. Generate Checklist
Load the appropriate evidence template based on detected type, evaluate conditional items, and create `evidence_checklist.md` in the story QA folder.

### 3. Verify Evidence
For each checklist item: check if evidence exists, validate evidence quality, mark as complete or missing.

Output: `{ complete: boolean, missing: string[], blocking: boolean }` -- blocking is true if any CRITICAL item is missing.

## Evidence Checklists by Issue Type

### Bug Fix Evidence

**Required:**
| ID | Name | Description | Severity |
|---|---|---|---|
| original-error | Original Error Documented | Screenshot, log, or reproduction steps of the bug | CRITICAL |
| root-cause | Root Cause Identified | Clear explanation of why the bug occurred | HIGH |
| before-after | Before/After Comparison | Code diff showing the fix with explanation | HIGH |
| regression-test | Regression Test Added | Test case that would catch this bug if reintroduced | CRITICAL |

**Optional:**
| ID | Name | Description | Severity |
|---|---|---|---|
| related-issues | Related Issues Checked | Similar code patterns checked for same bug | LOW |

### Feature Implementation Evidence

**Required:**
| ID | Name | Description | Severity |
|---|---|---|---|
| acceptance-verified | All Acceptance Criteria Verified | Each criterion has proof of completion | CRITICAL |
| edge-cases | Edge Cases Tested | Boundary conditions and error states verified | HIGH |
| happy-path | Happy Path Demonstrated | Primary use case works as expected | CRITICAL |

**Conditional:**
| ID | Name | Condition | Severity |
|---|---|---|---|
| cross-platform | Cross-Platform Tested | Feature has UI component | MEDIUM |
| performance-impact | Performance Impact Assessed | Feature is performance-critical | HIGH |

### Dependency Update Evidence

**Required:**
| ID | Name | Description | Severity |
|---|---|---|---|
| security-check | Security Vulnerabilities Checked | npm audit or equivalent shows no new vulnerabilities | CRITICAL |
| license-check | License Compatibility Verified | New dependency license is compatible with project | HIGH |
| breaking-changes | Breaking Changes Handled | Changelog reviewed and breaking changes addressed | CRITICAL |

**Conditional:**
| ID | Name | Condition | Severity |
|---|---|---|---|
| bundle-size | Bundle Size Impact | Frontend dependency | MEDIUM |

### Refactor Evidence

**Required:**
| ID | Name | Description | Severity |
|---|---|---|---|
| behavior-preserved | Behavior Preserved | Tests pass before and after refactor | CRITICAL |
| no-new-features | No New Features Added | Refactor is purely structural | HIGH |

**Optional:**
| ID | Name | Description | Severity |
|---|---|---|---|
| performance-improvement | Performance Improvement | Benchmarks showing improvement if claimed | LOW |

## Blocking Rules
- Any CRITICAL evidence missing: **REJECT**
- 2+ HIGH evidence missing: **REJECT**
- Only MEDIUM/LOW missing: **APPROVE** with notes

## Evidence Checklist Template

The generated checklist includes for each item:
- Status (Complete / Missing)
- Description of what is needed
- Evidence location (link to screenshot, test file, commit, or explanation)
- Verified by (reviewer name and date)

Summary table showing required/provided/missing counts by severity, with a verdict of COMPLETE or INCOMPLETE.

## Command
```
*evidence-check {story-id} [--type bug_fix|feature|dependency_update|refactor]
```

## Integration with QA Review
**Trigger:** During `*review-build` Phase 1.2 (Evidence Requirements Check) and Phase 8 (Report Generation).

**Workflow:**
1. Detect issue type from story/commits
2. Generate evidence checklist
3. Verify each evidence item
4. Include in qa_report.md
5. Block if CRITICAL evidence missing

## Error Handling
- **Story file not found:** Log warning, generate generic checklist with all items marked as missing
- **Issue type ambiguous:** Default to feature type and note the ambiguity
- **Evidence location inaccessible:** Mark item as missing with note about inaccessible location
- **Multiple issue types detected:** Use the most restrictive checklist (combine requirements)
