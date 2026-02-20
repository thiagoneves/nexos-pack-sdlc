---
task: spec-critique
agent: qa
workflow: spec-pipeline (phase 5)
inputs: [spec.md, requirements.json, complexity assessment, research findings]
outputs: [critique report with verdict]
skip_conditions: never (this phase is always mandatory)
---

# Critique Specification

## Purpose

Review the specification document for accuracy, completeness, consistency, feasibility,
and alignment. Produce a structured critique with dimension scores and a verdict that
determines whether the spec proceeds to implementation planning (APPROVED), needs
revision (NEEDS_REVISION), or is fundamentally flawed (BLOCKED).

The critique phase is the quality gate of the spec pipeline. It ensures that the spec
is grounded in requirements, technically sound, internally consistent, and ready to
guide implementation. This phase also enforces the No Invention rule (Constitutional
Article IV) by independently verifying traceability.

This phase is **mandatory** and never skipped, regardless of complexity class.

---

## Prerequisites

- Specification document from phase 4 is available (REQUIRED).
- Requirements document from phase 1 for traceability validation (REQUIRED).
- Complexity assessment from phase 2 for expected depth context (optional).
- Research findings from phase 3 for technical validation (optional).
- This phase is always mandatory.

---

## Critique Dimensions

The spec is evaluated across 5 dimensions, each scored 1-5.

### Dimension 1: Accuracy (Weight: 25%)

Does the spec accurately reflect the requirements?

**Checks:**

| ID | Check | Severity | Question |
|----|-------|----------|----------|
| ACC-1 | Requirement Coverage | HIGH | Every FR-* from requirements is addressed in the spec? |
| ACC-2 | No Phantom Requirements | HIGH | Spec does not include features not in requirements? |
| ACC-3 | Priority Mapping | MEDIUM | P0/MUST requirements are prominent, P2/COULD are optional? |
| ACC-4 | NFR Addressed | MEDIUM | All NFR-* have corresponding spec sections? |
| ACC-5 | Constraint Reflection | MEDIUM | All CON-* are reflected in the technical approach? |

**Scoring:**

| Score | Meaning |
|-------|---------|
| 5 | All requirements accurately represented, no omissions |
| 4 | Minor omissions, no misrepresentations |
| 3 | Some requirements unclear or incompletely addressed |
| 2 | Significant gaps or misrepresentations |
| 1 | Major accuracy issues, spec does not reflect requirements |

---

### Dimension 2: Completeness (Weight: 25%)

Does the spec have all necessary sections filled?

**Checks:**

| ID | Check | Severity | Question |
|----|-------|----------|----------|
| COMP-1 | All Sections Present | HIGH | Overview, Requirements, Approach, Dependencies, Files, Testing, Risks all present? |
| COMP-2 | Testing Coverage | HIGH | Every FR has at least one test scenario? |
| COMP-3 | Dependencies Listed | MEDIUM | All external dependencies identified with versions? |
| COMP-4 | Files Identified | MEDIUM | New and modified files listed with purposes? |
| COMP-5 | Risks Documented | LOW | At least potential risks have been considered? |
| COMP-6 | Traceability Matrix | HIGH | Matrix present mapping spec sections to requirements? |

**Scoring:**

| Score | Meaning |
|-------|---------|
| 5 | Comprehensive, nothing missing, all sections thorough |
| 4 | Minor gaps in non-critical sections |
| 3 | Some sections incomplete or thin |
| 2 | Multiple sections missing or empty |
| 1 | Severely incomplete, not usable for implementation |

---

### Dimension 3: Consistency (Weight: 20%)

Is the spec internally consistent?

**Checks:**

| ID | Check | Severity | Question |
|----|-------|----------|----------|
| CON-1 | ID References Valid | HIGH | All FR-*/NFR-* references in the spec exist in requirements? |
| CON-2 | Dependency Consistency | MEDIUM | Dependencies mentioned in approach match the dependencies section? |
| CON-3 | Complexity Alignment | LOW | Spec depth matches the complexity class level? |
| CON-4 | No Contradictions | HIGH | No conflicting statements between different sections? |
| CON-5 | Terminology Consistent | MEDIUM | Terms used consistently throughout the spec? |

**Scoring:**

| Score | Meaning |
|-------|---------|
| 5 | Fully consistent throughout, no contradictions |
| 4 | Minor inconsistencies that do not affect understanding |
| 3 | Some contradictions or mismatches that need attention |
| 2 | Multiple inconsistencies that could cause confusion |
| 1 | Fundamentally inconsistent, contradicts itself |

---

### Dimension 4: Feasibility (Weight: 15%)

Is the spec technically feasible?

**Checks:**

| ID | Check | Severity | Question |
|----|-------|----------|----------|
| FEAS-1 | Dependencies Available | HIGH | All listed dependencies exist and are compatible? |
| FEAS-2 | Technical Approach Sound | HIGH | Proposed architecture is achievable with stated resources? |
| FEAS-3 | Reasonable Scope | MEDIUM | Work fits within typical story scope for the complexity class? |
| FEAS-4 | No Impossible Requirements | HIGH | All requirements are technically possible as described? |
| FEAS-5 | Research-Backed | MEDIUM | Technical decisions supported by research findings? |

**Scoring:**

| Score | Meaning |
|-------|---------|
| 5 | Clearly feasible, well-supported by research |
| 4 | Feasible with minor concerns or assumptions |
| 3 | Questionable feasibility in some areas |
| 2 | Significant feasibility issues identified |
| 1 | Not feasible as specified, fundamental redesign needed |

---

### Dimension 5: Alignment (Weight: 15%)

Does the spec align with project standards and conventions?

**Checks:**

| ID | Check | Severity | Question |
|----|-------|----------|----------|
| ALIGN-1 | Tech Stack Alignment | MEDIUM | Technologies match project preferences and existing stack? |
| ALIGN-2 | Pattern Alignment | MEDIUM | Proposed patterns match existing codebase conventions? |
| ALIGN-3 | Naming Conventions | LOW | File and component names follow project naming conventions? |
| ALIGN-4 | Architecture Fit | HIGH | Design fits within the existing architecture? |
| ALIGN-5 | Testing Conventions | LOW | Test approach follows project testing patterns? |

**Scoring:**

| Score | Meaning |
|-------|---------|
| 5 | Perfect alignment with project standards |
| 4 | Minor deviations with clear justification |
| 3 | Some misalignments that need discussion |
| 2 | Significant deviations from project standards |
| 1 | Fundamentally misaligned with project architecture |

---

## Verdict Logic

Calculate the weighted average of all 5 dimension scores.

### Verdict Rules

| Verdict | Conditions | Meaning | Next Action |
|---------|------------|---------|-------------|
| **APPROVED** | Average >= 4.0 AND no HIGH severity failures AND all dimensions >= 3 | Spec ready for implementation | Proceed to implementation planning (phase 6) |
| **NEEDS_REVISION** | Average 3.0-3.9 OR has MEDIUM severity issues OR any dimension < 3 (but no HIGH failures) | Spec needs improvements | Return to phase 4 (spec-write) with specific feedback |
| **BLOCKED** | Average < 3.0 OR has HIGH severity failures OR any dimension <= 1 | Spec has critical issues | Escalate to @architect or return to phase 1 (gather) |

### Weighted Average Calculation

```
average = (accuracy * 0.25) + (completeness * 0.25) + (consistency * 0.20)
        + (feasibility * 0.15) + (alignment * 0.15)
```

---

## Constitutional Compliance Check

**Article IV -- No Invention**

This is a critical check performed as part of the Accuracy dimension but
deserving special attention.

**Verification steps:**

1. Check the traceability matrix for completeness.
2. For each spec section, verify that content traces to FR-*, NFR-*, CON-*,
   or research findings.
3. Look for features described in the spec that do not appear in requirements.
4. Look for technical decisions not supported by research.
5. Check for acceptance criteria not derived from the requirements.

**If invention is detected:**
- Flag as HIGH severity accuracy issue.
- This alone can downgrade a verdict from APPROVED to NEEDS_REVISION.
- Document exactly what was invented and what input it should trace to.

---

## Steps

### Step 1: Load All Artifacts

Gather all spec pipeline artifacts for review.

**Substeps:**

1. Load spec.md (REQUIRED).
2. Load requirements document (REQUIRED).
3. Load complexity assessment (optional, for context).
4. Load research findings (optional, for technical validation).
5. Build a requirements checklist: all FR-*, NFR-*, CON-* IDs.

**Error:** If spec.md or requirements are not found, HALT.

---

### Step 2: Run Dimension Checks

For each of the 5 dimensions, execute all checks.

**Substeps:**

1. For each dimension:
   a. Execute each check in the dimension.
   b. Record finding: PASS or FAIL.
   c. For failures, assign severity (HIGH/MEDIUM/LOW).
   d. Document the specific issue and location in the spec.
   e. Provide an actionable recommendation for fixing.
   f. Note whether the issue is auto-fixable.
2. Calculate the dimension score based on check results.

---

### Step 3: Generate Issues List

For each failed check, create a structured issue entry.

**Issue structure:**

```yaml
issue:
  id: "CRIT-{n}"
  severity: "{HIGH|MEDIUM|LOW}"
  category: "{accuracy|completeness|consistency|feasibility|alignment}"
  check_id: "{ACC-1|COMP-2|...}"
  description: "{what is wrong}"
  location: "spec.md#{section or line reference}"
  suggestion: "{specific, actionable fix recommendation}"
  auto_fixable: true|false
```

**Severity assignment rules:**
- **HIGH:** Missing requirement coverage, phantom features (invention),
  technical infeasibility, fundamental contradictions.
- **MEDIUM:** Incomplete sections, minor inconsistencies, non-preferred
  technology choices, missing tests for some requirements.
- **LOW:** Naming convention issues, formatting problems, missing risk
  documentation, minor alignment deviations.

---

### Step 4: Calculate Verdict

Determine the final verdict from dimension scores and issues.

**Substeps:**

1. Calculate weighted average score.
2. Count issues by severity (HIGH, MEDIUM, LOW).
3. Check minimum dimension scores (any dimension <= 1 = BLOCKED).
4. Apply verdict rules from the Verdict Logic section.
5. Determine next action based on verdict.

---

### Step 5: Generate Critique Report

Compile the complete critique report.

**Output structure:**

```yaml
critique:
  date: "{YYYY-MM-DD}"
  reviewer: "@qa"
  spec_document: "spec-{name}.md"

  verdict: "{APPROVED|NEEDS_REVISION|BLOCKED}"
  verdict_reason: "{summary of why this verdict}"

  scores:
    accuracy: { score: N, notes: "..." }
    completeness: { score: N, notes: "..." }
    consistency: { score: N, notes: "..." }
    feasibility: { score: N, notes: "..." }
    alignment: { score: N, notes: "..." }
  average_score: N.N

  issues:
    - id: "CRIT-1"
      severity: "{HIGH|MEDIUM|LOW}"
      category: "{dimension}"
      description: "..."
      location: "spec.md#{section}"
      suggestion: "..."
      auto_fixable: false
    # ... more issues

  summary:
    high_issues: N
    medium_issues: N
    low_issues: N
    auto_fixable: N
    total_checks_passed: N
    total_checks_failed: N

  strengths: ["...", "..."]

  next_action: "{what to do based on verdict}"

  auto_fixes:
    - issue_id: "CRIT-{n}"
      location: "{spec section}"
      original: "{current text}"
      suggested: "{replacement text}"
```

Save the critique report to the project's docs or spec directory.

---

### Step 6: Present Results

Inform the user of the critique outcome.

**Substeps:**

1. **Verdict and score:**
   - Show the verdict prominently (APPROVED/NEEDS_REVISION/BLOCKED).
   - Show the weighted average score.
   - Show per-dimension score breakdown.

2. **Strengths:**
   - Highlight what the spec does well (2-3 items).

3. **Critical issues (if any):**
   - List HIGH severity issues that must be addressed.
   - For each, show the location and specific recommendation.

4. **Auto-fixable items (if any):**
   - List issues that can be automatically corrected.
   - Offer to apply auto-fixes if the user approves.

5. **Next step based on verdict:**
   - **APPROVED:** "Spec is approved. Proceeding to implementation planning."
   - **NEEDS_REVISION:** "Spec returns to @pm for revision. Issues: [list].
     Critique report saved for reference."
   - **BLOCKED:** "Spec has critical issues. Escalating to @architect for
     fundamental design review. Critique report saved."

---

## Revision Cycle

When the verdict is NEEDS_REVISION, the spec enters a revision cycle.

**Revision flow:**
```
Critique (verdict: NEEDS_REVISION)
  -> Return to spec-write (phase 4) with critique.json
  -> Spec writer addresses issues
  -> Re-run critique (phase 5)
  -> New verdict
```

**Revision limits:**
- Maximum 3 revision cycles before escalation.
- Each revision should address ALL issues from the previous critique.
- Spec version number increments with each revision.

**Escalation triggers:**
- 3 revision cycles without reaching APPROVED.
- Same HIGH severity issue persists across 2 revisions.
- Average score not improving between revisions.

**On escalation:** Escalate to @architect or @master. The spec may need to
be restarted from phase 1 (gather requirements).

---

## Pipeline Integration

```yaml
pipeline:
  phase: critique
  previous_phase: spec
  next_phase: plan (if APPROVED)

  requires:
    - spec.md
    - requirements.json

  optional:
    - complexity assessment
    - research findings

  gate: true  # This is a blocking gate

  on_verdict:
    APPROVED:
      action: continue_to_plan
    NEEDS_REVISION:
      action: return_to_spec_write
      pass: [critique report, auto_fixes]
    BLOCKED:
      action: halt_and_escalate
```

---

## Error Handling

| Error | Condition | Action | Blocking |
|-------|-----------|--------|----------|
| Missing spec | spec.md not found | HALT, phase 4 must complete first | YES |
| Missing requirements | Requirements not found | HALT, cannot validate accuracy/traceability | YES |
| Malformed spec | spec.md cannot be parsed | Log parse issues, attempt partial critique of readable sections | NO |
| Missing complexity | Complexity assessment not found | Skip alignment depth check, note limited context | NO |
| Missing research | Research findings not found | Skip feasibility research-backed check, note limited context | NO |
| Borderline score | Average is exactly 3.0 or 4.0 | Present assessment transparently, ask user for final verdict | NO |
| Revision limit | 3+ revision cycles without APPROVED | Escalate to @architect or @master | YES |
| Auto-fix failure | Auto-fix cannot be applied cleanly | Document the issue, mark as manual-fix-required | NO |

---

## Examples

### Example 1: APPROVED Verdict

**Input:** Well-written spec for Google OAuth login.

**Critique result:**
```yaml
verdict: APPROVED
average_score: 4.4
scores:
  accuracy: 5
  completeness: 4
  consistency: 5
  feasibility: 4
  alignment: 4
issues: []
strengths:
  - "Complete traceability matrix with all requirements mapped"
  - "Thorough testing strategy with Gherkin scenarios for every FR"
  - "Technical approach well-supported by research findings"
next_action: "Proceed to implementation planning"
```

### Example 2: NEEDS_REVISION Verdict

**Input:** Spec missing test coverage for 2 functional requirements.

**Critique result:**
```yaml
verdict: NEEDS_REVISION
average_score: 3.6
scores:
  accuracy: 5
  completeness: 3
  consistency: 4
  feasibility: 4
  alignment: 4
issues:
  - id: CRIT-1
    severity: HIGH
    category: completeness
    description: "FR-001 (Google OAuth) has no test scenarios"
    location: "spec.md#testing-strategy"
    suggestion: "Add Given-When-Then test for OAuth flow"
    auto_fixable: true
  - id: CRIT-2
    severity: MEDIUM
    category: completeness
    description: "Dependencies section missing version numbers"
    location: "spec.md#dependencies"
    suggestion: "Add specific version ranges from research findings"
    auto_fixable: true
summary:
  high_issues: 1
  medium_issues: 1
  auto_fixable: 2
next_action: "Return to spec-write with critique report"
```

### Example 3: BLOCKED Verdict

**Input:** Spec that invented features not in requirements and has infeasible architecture.

**Critique result:**
```yaml
verdict: BLOCKED
average_score: 2.2
scores:
  accuracy: 1
  completeness: 3
  consistency: 2
  feasibility: 2
  alignment: 3
issues:
  - id: CRIT-1
    severity: HIGH
    category: accuracy
    description: "Spec includes real-time notifications feature not in requirements (Article IV violation)"
    location: "spec.md#technical-approach"
    suggestion: "Remove invented feature or trace to a specific FR-*"
  - id: CRIT-2
    severity: HIGH
    category: feasibility
    description: "Proposed microservice architecture requires infrastructure not available"
    location: "spec.md#architecture"
    suggestion: "Redesign to fit existing monolith architecture per CON-002"
next_action: "Escalate to @architect for fundamental design review"
```

---

## Acceptance Criteria for This Task

- [ ] All 5 critique dimensions are scored with rationale.
- [ ] Weighted average is calculated correctly.
- [ ] Verdict matches the verdict rules (APPROVED/NEEDS_REVISION/BLOCKED).
- [ ] Every failed check has a documented issue with severity and recommendation.
- [ ] Constitutional compliance (No Invention rule) is explicitly verified.
- [ ] Traceability matrix in the spec is validated.
- [ ] Strengths of the spec are highlighted (not just problems).
- [ ] Auto-fixable issues are identified where possible.
- [ ] Critique report is saved to docs or spec directory.
- [ ] User is informed of verdict, scores, key issues, and next steps.
- [ ] Revision cycle limits are tracked if this is a re-critique.

---

## Notes

- The critique should be constructive, not just fault-finding. Always highlight
  what the spec does well alongside issues found.
- Severity classification matters. Do not inflate severity -- a missing risk
  section is LOW, not HIGH. A missing requirement is HIGH, not MEDIUM.
- The No Invention check is the single most important check. A spec that invents
  features will create scope creep, misaligned expectations, and wasted effort.
- When calculating the verdict, weighted averages can mask issues. A spec with
  scores of 5,5,5,5,1 averages to 4.2 (APPROVED), but the dimension at 1 should
  trigger BLOCKED. This is why the "any dimension <= 1 = BLOCKED" rule exists.
- Auto-fixes should be conservative. Only suggest auto-fixes for clearly
  mechanical issues (adding a missing ID reference, filling in a version number).
  Do not auto-fix architectural or design decisions.
- The critique report is a permanent artifact. It serves as documentation of the
  quality review process and can be referenced during implementation.
- For COMPLEX specs, consider conducting the critique in preflight mode to ensure
  thorough discussion of each dimension.
- If the same spec goes through 3 revision cycles without reaching APPROVED,
  the problem is likely not the spec but the requirements or the approach.
  Escalation at this point saves time compared to continued revision.
