---
task: architect-analyze-impact
agent: architect
workflow: standalone (invokable on demand)
inputs: [modification type, component path, analysis options]
outputs: [impact analysis report, risk assessment, recommendations]
---

# Architectural Impact Analysis

## Purpose

Analyze the potential impact of proposed changes on the system architecture. Evaluate dependency chains, predict change propagation, assess modification risks, and produce actionable recommendations. This task helps teams make informed decisions before committing to changes that may have far-reaching consequences.

## Prerequisites

- The target component or file to be analyzed must exist in the project.
- The project has a navigable directory structure (code, docs, or both).
- The proposed modification type is known (modify, deprecate, remove, or refactor).

## Steps

### 1. Validate Target Component

Verify the target component exists and is accessible:
- Resolve the component path relative to the project root.
- Confirm the path points to a file (not a directory, unless analyzing a module).
- Determine the component type based on location and content:
  - `agent` -- agent definition file
  - `task` -- task definition file
  - `workflow` -- workflow definition file
  - `template` -- template file
  - `config` -- configuration file
  - `source` -- source code file
  - `schema` -- data schema file
  - `doc` -- documentation file
  - `test` -- test file
  - `unknown` -- cannot determine type

Record the component metadata: path, type, size, last modified date.

If the component is not found, HALT with: "Component not found: {component_path}. Verify the path and try again."

### 2. Classify the Modification Type

Validate and classify the proposed modification:

| Type | Description | Typical Risk |
|------|-------------|-------------|
| `modify` | Change behavior or interface of an existing component | Medium |
| `deprecate` | Mark as deprecated, plan for future removal | Low-Medium |
| `remove` | Delete the component entirely | High |
| `refactor` | Restructure without changing external behavior | Medium |

If the modification type is not recognized, HALT with a list of valid types.

### 3. Analyze Direct Dependencies

Scan the project for direct references to the target component:

**Forward dependencies (what the target depends on):**
- Imports, references, and includes within the target component.
- Configuration files the target reads.
- Templates the target uses.
- External packages or services the target calls.

**Reverse dependencies (what depends on the target):**
- Files that import, reference, or include the target.
- Workflows that invoke the target as a step.
- Configuration files that reference the target.
- Tests that test the target.
- Documentation that references the target.

For each dependency found, record:
- File path.
- Dependency type (import, reference, workflow step, config entry, test, doc).
- Coupling strength: tight (direct import/call), medium (config reference), loose (documentation reference).

### 4. Predict Change Propagation

Based on the dependency graph, predict how changes will propagate:

**Depth levels:**

| Depth Setting | Analysis Scope |
|---------------|---------------|
| `shallow` | Direct dependencies only (depth 1) |
| `medium` | Direct + secondary dependencies (depth 2) |
| `deep` | Full transitive closure (depth 3+) |

For each level of propagation:
- Identify affected components at that level.
- Estimate the likelihood of the change requiring updates at that level.
- Classify the propagation as: certain (must update), likely (probably needs update), possible (may need update).

Build a propagation summary:
- Total affected components per level.
- Maximum propagation depth reached.
- Components with highest fan-out (most downstream dependents).
- Potential bottlenecks (components that many propagation paths pass through).

### 5. Assess Modification Risks

Evaluate risks across multiple dimensions:

**Dimension 1: Scope risk**
- How many components are affected?
- Are affected components spread across multiple modules or concentrated?
- Score: 1 (isolated) to 5 (widespread).

**Dimension 2: Coupling risk**
- How tightly coupled is the target to its dependents?
- Are interfaces well-defined or are internals exposed?
- Score: 1 (loosely coupled) to 5 (tightly coupled).

**Dimension 3: Test coverage risk**
- Do affected components have adequate test coverage?
- Will existing tests catch regressions?
- Score: 1 (well tested) to 5 (untested).

**Dimension 4: Criticality risk**
- Is the target component on a critical path (e.g., authentication, data pipeline)?
- What is the blast radius if the modification introduces a bug?
- Score: 1 (non-critical) to 5 (critical path).

**Dimension 5: Reversibility risk**
- Can the modification be easily rolled back?
- Are there database migrations or external API changes involved?
- Score: 1 (easily reversible) to 5 (irreversible).

Calculate the overall risk level:

| Average Score | Risk Level |
|---------------|-----------|
| 1.0 - 2.0 | LOW |
| 2.1 - 3.0 | MEDIUM |
| 3.1 - 4.0 | HIGH |
| 4.1 - 5.0 | CRITICAL |

### 6. Generate Recommendations

Based on the analysis, produce actionable recommendations:

**For each affected component:**
- What specific action is needed (update import, modify interface, update test, update docs).
- Priority: must-do, should-do, nice-to-do.
- Estimated effort: trivial, small, medium, large.

**General recommendations by modification type:**

For `modify`:
- List interface changes that affect consumers.
- Suggest backward-compatible approaches if applicable.
- Identify tests that need updating.

For `deprecate`:
- Propose a deprecation timeline.
- Identify all consumers that need migration.
- Suggest replacement component or pattern.

For `remove`:
- List all components that will break.
- Propose a removal sequence (dependencies first).
- Identify orphaned resources.

For `refactor`:
- Verify behavior preservation strategy (tests, snapshots).
- List files that need synchronized renaming or restructuring.
- Suggest incremental refactoring steps.

### 7. Compile Impact Report

Assemble the full impact analysis report:

```markdown
# Architectural Impact Analysis Report

> **Generated:** {timestamp}
> **Target:** {component_path}
> **Type:** {component_type}
> **Modification:** {modification_type}
> **Analysis Depth:** {depth}

---

## Risk Summary

| Dimension | Score (1-5) |
|-----------|-------------|
| Scope | {n} |
| Coupling | {n} |
| Test Coverage | {n} |
| Criticality | {n} |
| Reversibility | {n} |
| **Average** | **{n.n}** |

**Overall Risk Level:** {LOW | MEDIUM | HIGH | CRITICAL}

---

## Affected Components

### Direct Dependencies ({count})

| Component | Type | Coupling | Action Required |
|-----------|------|----------|-----------------|
| {path} | {type} | {tight/medium/loose} | {action} |

### Propagation Summary

| Depth | Components | Likelihood |
|-------|------------|------------|
| Level 1 (direct) | {n} | Certain |
| Level 2 (secondary) | {n} | Likely |
| Level 3+ (transitive) | {n} | Possible |

**Maximum Propagation Depth:** {n}
**Total Affected Components:** {n}

---

## Critical Issues

{List of issues that MUST be addressed before proceeding.}

---

## Recommendations

### Must-Do (before modification)
1. {recommendation}

### Should-Do (during modification)
1. {recommendation}

### Nice-to-Do (after modification)
1. {recommendation}

---

## Suggested Modification Sequence

1. {step 1}
2. {step 2}
3. ...

---

## Test Impact

| Test File | Status | Action |
|-----------|--------|--------|
| {path} | {will break / needs update / unaffected} | {action} |
```

### 8. Handle High-Risk Modifications

If the overall risk level is HIGH or CRITICAL:

- Present the risk summary prominently.
- Ask the user to confirm they want to proceed.
- Suggest risk mitigation steps (feature flags, incremental rollout, backup plan).

### 9. Present Results

Inform the user:
- Overall risk level and score breakdown.
- Total number of affected components and propagation depth.
- Top 3 critical issues (if any).
- Immediate next steps based on risk level:
  - LOW: "Proceed with modification. Monitor affected tests."
  - MEDIUM: "Review recommendations before proceeding. Update tests for affected components."
  - HIGH: "Address critical issues first. Consider incremental approach."
  - CRITICAL: "Requires careful planning. Recommend detailed analysis if not already done."

## Output Format

The report is output in markdown format. Optionally save to `{project_docs}/reports/impact-analysis-{component}-{timestamp}.md` if requested.

## Error Handling

| Situation | Action |
|-----------|--------|
| **Component not found** | HALT with clear message and suggest verifying the path. |
| **Invalid modification type** | HALT with list of valid types: modify, deprecate, remove, refactor. |
| **No dependencies found** | Report the component as isolated. Risk assessment still runs (may have high criticality even if isolated). |
| **Circular dependency detected** | Report the cycle as a finding. Continue analysis but note that propagation depth may be unbounded. |
| **Very large dependency graph (100+ components)** | Warn the user. Suggest using shallow depth or narrowing scope. Continue if user confirms. |
| **Permission errors reading files** | Skip the file, log a warning, continue with accessible files. |
| **Analysis timeout (exceeds 10 minutes)** | Present partial results and suggest narrowing scope. |

## Examples

**Analyze modification of a task file:**
```
@architect *analyze-impact modify tasks/create-next-story.md --depth deep
```

**Quick shallow check for a refactoring:**
```
@architect *analyze-impact refactor src/utils/validator.js --depth shallow
```

**Analyze removal with full report saved:**
```
@architect *analyze-impact remove workflows/legacy-deploy.yaml --depth deep --save
```

**Analyze deprecation of a template:**
```
@architect *analyze-impact deprecate templates/old-story.md
```

**Include test file analysis:**
```
@architect *analyze-impact modify src/core/parser.ts --include-tests --depth medium
```

## Acceptance Criteria

- [ ] Target component is validated before analysis begins.
- [ ] Both forward and reverse dependencies are identified.
- [ ] Change propagation is predicted to the specified depth.
- [ ] Risk assessment scores all 5 dimensions with justification.
- [ ] Overall risk level is correctly calculated from dimension scores.
- [ ] Recommendations are specific, actionable, and prioritized.
- [ ] The report follows the specified markdown structure.
- [ ] HIGH and CRITICAL risk modifications produce prominent warnings.
- [ ] The task completes even when some files are inaccessible (graceful degradation).
- [ ] Invalid inputs (bad path, bad type) produce clear error messages.

## Notes

- This task is analytical and advisory. It does NOT make changes to the codebase.
- The quality of the analysis depends on the project's structural consistency. Well-organized projects with clear import paths yield more accurate results.
- Impact analysis is most valuable when run BEFORE starting implementation, during the planning phase of a story or epic.
- Results from this task can inform story creation (identified changes become tasks) and risk documentation in story files.
