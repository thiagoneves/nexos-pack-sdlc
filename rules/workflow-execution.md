# Workflow Execution Rules

## Task-First Principle

Workflows are composed of tasks connected by phases, not agents connected directly. Each task defines its inputs, outputs, and execution steps. Agents are the executors — the sequence and rules come from the workflow definitions.

## 4 Primary Workflows

### 1. Story Development Cycle (SDC) — PRIMARY

Full 4-phase workflow for all development work.

| Phase | Agent | Task | Decision |
|-------|-------|------|----------|
| Create | @sm | create-next-story.md | — |
| Validate | @po | validate-next-story.md | GO / NO-GO |
| Implement | @dev | dev-develop-story.md | — |
| QA Gate | @qa | qa-gate.md | PASS / CONCERNS / FAIL / WAIVED |

### 2. QA Loop — ITERATIVE REVIEW

Automated review-fix cycle after initial QA gate.

```
@qa review → verdict → @dev fixes → re-review (max 5 iterations)
```

**Escalation triggers:** max_iterations_reached, verdict_blocked, fix_failure, manual_escalate

### 3. Spec Pipeline — PRE-IMPLEMENTATION

Transform informal requirements into executable spec.

| Phase | Agent | Skip If |
|-------|-------|---------|
| 1. Gather | @pm | Never |
| 2. Assess | @architect | SIMPLE class |
| 3. Research | @analyst | SIMPLE class |
| 4. Write Spec | @pm | Never |
| 5. Critique | @qa | Never |

**Complexity:** SIMPLE (<=8), STANDARD (9-15), COMPLEX (>=16)

### 4. Brownfield Discovery — LEGACY ASSESSMENT

10-phase technical debt assessment for existing codebases.

**Data Collection (parallel):** @architect + @data-engineer + @ux-designer
**Assessment:** @architect drafts, @qa reviews
**Finalization:** @pm creates epics and stories

## Workflow Selection Guide

| Situation | Workflow |
|-----------|---------|
| New story from epic | Story Development Cycle |
| QA found issues, need iteration | QA Loop |
| Complex feature needs spec | Spec Pipeline → then SDC |
| Joining existing project | Brownfield Discovery |
| Simple bug fix | SDC only (autopilot mode) |
