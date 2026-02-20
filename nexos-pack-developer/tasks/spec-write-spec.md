---
task: spec-write-spec
agent: pm
workflow: spec-pipeline (phase 4)
inputs: [requirements.json, complexity assessment, research findings]
outputs: [spec.md]
skip_conditions: never (this phase is always mandatory)
---

# Write Specification

## Purpose

Transform gathered requirements, complexity assessment, and research findings into a
formal, traceable specification document. The spec.md is the definitive document that
guides implementation. Every statement in the spec must trace to a requirement (FR-*,
NFR-*, CON-*) or a verified research finding.

**Constitutional Rule: No Invention (Article IV)**
The spec writer MUST NOT invent or assume anything not present in the inputs.
No features, technologies, or acceptance criteria may appear in the spec unless they
are directly derived from the requirements document or research findings. When something
is unclear, it must be placed in the Open Questions section rather than assumed.

This phase is **mandatory** and never skipped, regardless of complexity class.

---

## Prerequisites

- Requirements document from phase 1 is available (REQUIRED).
- Complexity assessment from phase 2 is available (optional for SIMPLE class).
- Research findings from phase 3 are available (optional, skipped for SIMPLE class).
- The executing agent has access to the project codebase for context.
- This phase is always mandatory.

---

## The No Invention Rule

> **Severity:** BLOCK -- violations halt spec completion.

Every statement in spec.md must trace back to one of:
- A functional requirement (FR-*)
- A non-functional requirement (NFR-*)
- A constraint (CON-*)
- A verified research finding
- An assumption (ASM-*) explicitly documented in requirements

**Violations include:**
- Adding features not present in requirements.
- Assuming implementation details not validated by research.
- Specifying technologies not verified in the research phase.
- Creating acceptance criteria not derived from the requirements.
- Making architectural decisions not supported by evidence.

**When unclear:**
- Add to the Open Questions section instead of assuming.
- Flag as a RECOMMENDATION with explicit note that it is not requirement-derived.

**Enforcement:**
- Self-review after spec generation: verify every section traces to inputs.
- The critique phase (phase 5) will independently verify traceability.

---

## Spec Structure by Complexity Class

The spec document structure varies by complexity class:

### SIMPLE Class

Streamlined spec with essential sections only:

1. Overview (goals, non-goals)
2. Requirements Mapping (FR/NFR/CON table)
3. Technical Approach (brief)
4. Acceptance Criteria (Given/When/Then)
5. Implementation Checklist

### STANDARD Class

Full specification with all sections:

1. Overview (goals, non-goals, context)
2. Requirements Summary (FR, NFR, CON tables)
3. Technical Approach (architecture, components, data flow)
4. Dependencies (external and internal)
5. Files to Modify/Create
6. Data Model (if applicable)
7. API Design (if applicable)
8. Error Handling
9. Testing Strategy (unit, integration, acceptance)
10. Risks and Mitigations
11. Open Questions
12. Implementation Checklist
13. Traceability Matrix

### COMPLEX Class

Full specification plus additional sections:

1-13. All STANDARD sections, plus:
14. Alternatives Analysis (approaches considered and rejected)
15. Migration Plan (if modifying existing functionality)
16. Rollback Strategy
17. Phased Delivery Plan
18. Proof-of-Concept Recommendations

---

## Steps

### Step 1: Load All Inputs

Gather all upstream artifacts.

**Substeps:**

1. **Load requirements** (REQUIRED):
   - Parse all FR-*, NFR-*, CON-*, ASM-*, DM-*, INT-*, EC-*, TERM-* items.
   - Build a checklist of all items that must be addressed in the spec.

2. **Load complexity assessment** (optional):
   - Determine the complexity class (SIMPLE/STANDARD/COMPLEX).
   - Note flags and recommendations from the assessment.
   - Default to STANDARD if not available.

3. **Load research findings** (optional):
   - Parse verified dependencies and their patterns.
   - Note unverified claims (these become risks).
   - Note recommendations.

4. **Check for existing context:**
   - Look for existing specs or architecture docs in the project.
   - Check codebase structure for patterns to follow.

**Error:** If requirements document is not found, HALT. Phase 1 must complete first.

---

### Step 2: Plan the Spec Structure

Determine what sections the spec will contain.

**Substeps:**

1. Select the appropriate structure template based on complexity class.
2. For each section, identify which inputs will feed it:
   - Overview: FR-* descriptions synthesized.
   - Requirements Summary: Direct mapping from requirements.
   - Technical Approach: Research patterns + complexity dimensions.
   - Dependencies: Research verified dependencies.
   - Files: Complexity scope analysis + codebase patterns.
   - Testing: FR acceptance criteria converted to test scenarios.
   - Risks: Complexity flags + research unverified claims.
   - Open Questions: Requirements open questions + analysis gaps.
3. Identify any gaps where inputs are insufficient for a section.
4. In interactive/preflight mode, present the plan for approval.

---

### Step 3: Generate Each Section

Write each spec section by deriving content from inputs.

**Section generation rules:**

#### 3a. Overview
- **Source:** FR-* descriptions synthesized into a cohesive narrative.
- **Goals:** Derived from the primary functional requirements.
- **Non-Goals:** Explicitly out-of-scope items from requirements or constraints.
- **Rule:** No new goals may be invented. Only requirements-derived content.

#### 3b. Requirements Summary
- **Source:** Direct copy from requirements document with formatting.
- **Tables:** FR, NFR, CON each in their own table with ID, description, priority.
- **Rule:** Preserve all IDs for traceability. Do not rewrite or reinterpret.

#### 3c. Technical Approach
- **Source:** Research patterns + complexity scope analysis.
- **Architecture:** Based on research findings and existing codebase patterns.
- **Components:** Derived from scope analysis (which modules are affected).
- **Data Flow:** Based on interactions (INT-*) and domain model (DM-*).
- **Rule:** Every technical choice must trace to research. No invented architecture.

#### 3d. Dependencies
- **Source:** Research findings (verified dependencies).
- **Format:** Table with name, version, purpose, and verification status.
- **Rule:** Mark unverified dependencies with a warning indicator.

#### 3e. Files to Modify/Create
- **Source:** Complexity scope analysis + codebase patterns.
- **New files:** Path, purpose, template if applicable.
- **Modified files:** Path, what changes, risk level.
- **Rule:** Based on codebase analysis, not invented.

#### 3f. Data Model (if applicable)
- **Source:** Domain model items (DM-*) from requirements.
- **Content:** Entities, relationships, key fields, constraints.
- **Rule:** Only entities documented in requirements.

#### 3g. API Design (if applicable)
- **Source:** FR-* items that involve API endpoints.
- **Content:** Endpoints, methods, request/response schemas, error codes.
- **Rule:** Derived from functional requirements, not invented.

#### 3h. Error Handling
- **Source:** Edge cases (EC-*) from requirements.
- **Content:** Error scenarios, response format, recovery strategies.
- **Rule:** Based on documented edge cases.

#### 3i. Testing Strategy
- **Source:** Acceptance criteria from FR-* items.
- **Unit tests:** One test per FR minimum, covering key logic.
- **Integration tests:** For component interactions.
- **Acceptance tests:** Convert Given/When/Then to Gherkin scenarios.
- **Performance tests:** From NFR-* measurable criteria.
- **Rule:** Every FR must have at least one test scenario.

#### 3j. Risks and Mitigations
- **Source:** Complexity flags + research unverified claims + high-risk assumptions.
- **Format:** Table with risk, probability, impact, mitigation.
- **Rule:** Derived from actual findings, not speculative.

#### 3k. Open Questions
- **Source:** Requirements open questions + any gaps found during spec writing.
- **Format:** Table with ID, question, blocking status, assigned to.
- **Rule:** Anything unclear goes here instead of being assumed.

#### 3l. Implementation Checklist
- **Source:** Synthesized from all spec sections.
- **Format:** Checkbox list of concrete tasks.
- **Rule:** Each checklist item should be independently completable.

#### 3m. Traceability Matrix
- **Source:** Cross-reference of spec sections to requirement IDs.
- **Format:** Table mapping each spec section to the requirements it addresses.
- **Rule:** Every spec section must map to at least one requirement.

---

### Step 4: Validate the Spec (Self-Review)

Before finalizing, verify the spec's integrity.

**Validation checks:**

1. **Completeness:** All FR-* referenced in the spec.
2. **NFR coverage:** All NFR-* addressed in testing or design sections.
3. **Constraint reflection:** All CON-* reflected in the technical approach.
4. **Dependency inclusion:** All research dependencies included.
5. **No invention:** Every statement traces to an input (traceability check).
6. **Testability:** Every FR has at least one test scenario.
7. **Internal consistency:** No contradictions between sections.

**Output of validation:**
- Valid: true/false
- Missing items: list of requirement IDs not addressed
- Warnings: list of potential issues

**If validation fails:** Fix the issues before saving. If unable to fix (missing
information), add items to Open Questions.

---

### Step 5: Write the Spec File

Save the spec document.

**Substeps:**

1. Format the spec as Markdown following the template structure.
2. Reference template: `templates/spec-template.md` (if available).
3. Save to: `docs/specs/spec-{feature-name}.md` or the configured spec directory.
4. Record metadata: generation date, inputs used, iteration number.

---

### Step 6: Present for Review

Inform the user about the generated spec.

**Substeps:**

1. **Document location and size:** Where the spec was saved, approximate length.
2. **Requirements coverage:** How many FR/NFR/CON are addressed vs total.
3. **Gaps (if any):** Requirements that could not be fully addressed with reasons.
4. **Open questions count:** Number of unresolved items.
5. **Complexity context:** Which class informed the spec depth.
6. **Next step:** `spec-critique` (phase 5) for quality review.

---

## Pipeline Integration

```yaml
pipeline:
  phase: spec
  previous_phase: research (or assess for SIMPLE)
  next_phase: critique

  requires:
    - requirements.json

  optional:
    - complexity assessment
    - research findings

  pass_to_next:
    - spec.md
    - requirements.json
    - complexity assessment
    - research findings
```

---

## Error Handling

| Error | Condition | Action | Blocking |
|-------|-----------|--------|----------|
| Missing requirements | Requirements document not found | HALT, phase 1 must complete first | YES |
| Empty functional | No functional requirements in document | HALT, spec needs at least one FR | YES |
| Missing research (STANDARD+) | Research not available for STANDARD/COMPLEX | Warn, proceed but flag sections as "research-pending" | NO |
| Unverified dependency | Dependency used but not in research findings | Add warning indicator in dependencies section | NO |
| No acceptance criteria | FR has no acceptance criteria | Add to Open Questions, generate suggested criteria | NO |
| Invention detected | Self-review finds content not traced to inputs | Remove invented content or convert to labeled RECOMMENDATION | NO |
| Requirement contradiction | Two requirements conflict | Document the contradiction, propose resolution, ask user | NO |
| Scope too large | Spec exceeds reasonable single-story scope | Propose splitting into multiple specs, ask user to confirm | NO |
| Traceability gap | Spec section has no requirement mapping | Remove orphan content or add to Open Questions | NO |

---

## Quality Gates

Before the spec is considered complete, these gates must pass:

| Gate | Check | Severity |
|------|-------|----------|
| Traceability | Every spec statement traces to an input | HIGH |
| Completeness | All requirements addressed (FR count matches) | HIGH |
| Testability | Every FR has at least one test scenario | HIGH |
| No Invention | All technical choices from research/requirements | HIGH |
| Consistency | No contradictions between sections | MEDIUM |
| Format | All required sections present and non-empty | MEDIUM |

---

## Examples

### Example 1: SIMPLE Spec

**Inputs:** 2 FRs (add tooltip component), complexity SIMPLE (score 5).

**Generated spec excerpt:**
```markdown
# Spec: Tooltip Component

## Overview
Add a reusable tooltip component to the UI library.

### Goals
- Provide a configurable tooltip component (FR-001)
- Support multiple positions: top, bottom, left, right (FR-002)

### Non-Goals
- Animation transitions (not in requirements)
- Mobile-specific tooltip behavior (not in requirements)

## Acceptance Criteria
Given a UI element with a tooltip configured
When the user hovers over the element
Then the tooltip appears in the configured position

## Implementation Checklist
- [ ] Create Tooltip component
- [ ] Add position prop support
- [ ] Write unit tests for all positions
- [ ] Update component documentation
```

### Example 2: STANDARD Spec

**Inputs:** Google OAuth login, complexity STANDARD (score 13), research verified.

**Generated spec excerpt:**
```markdown
## Technical Approach

### Architecture Overview
Authentication flow using Google OAuth 2.0:
1. User clicks "Login with Google" (INT-001)
2. Redirect to Google consent screen
3. Receive authorization code
4. Exchange for tokens (server-side) (CON-001: must use OAuth 2.0)
5. Create/update user session

_Derived from FR-001 and research findings: google-auth-library_

## Dependencies

| Dependency          | Version | Purpose             | Verified |
|---------------------|---------|---------------------|----------|
| google-auth-library | ^9.0.0  | OAuth token handling| Yes      |
| @auth/core          | ^0.18.0 | Session management  | Yes      |

## Traceability Matrix

| Spec Section       | Requirement IDs     | Source          |
|--------------------|---------------------|-----------------|
| Architecture       | FR-001, CON-001     | requirements    |
| Dependencies       | FR-001              | research        |
| Testing            | FR-001, NFR-001     | requirements    |
```

---

## Acceptance Criteria for This Task

- [ ] Spec document is generated with all sections appropriate for the complexity class.
- [ ] Every FR-* is addressed somewhere in the spec.
- [ ] Every NFR-* is reflected in testing strategy or design sections.
- [ ] Every CON-* is reflected in the technical approach.
- [ ] No invented features or technologies (No Invention rule).
- [ ] Traceability matrix is present and complete.
- [ ] Testing strategy covers all functional requirements.
- [ ] Open questions are documented for anything unclear.
- [ ] Self-review validation passes.
- [ ] Spec is saved to the project's docs or spec directory.
- [ ] User is informed of coverage and next steps.

---

## Notes

- The spec is the contract between the requirements phase and implementation.
  It should be detailed enough that a developer can implement without guessing,
  but not so detailed that it prescribes implementation line-by-line.
- The No Invention rule is the most important quality constraint. It ensures the
  spec remains grounded in verified inputs. Violation of this rule is a blocking
  issue that the critique phase will catch.
- When the complexity class is SIMPLE, keep the spec concise. A 1-2 page spec is
  often sufficient. For COMPLEX, the spec may be 5-10+ pages.
- The traceability matrix is not optional. It is the mechanism that enables the
  critique phase to verify spec integrity.
- If research findings suggest a better approach than what the requirements describe,
  add it as a labeled RECOMMENDATION in the spec, clearly distinguishing it from
  requirement-derived content.
- When writing the testing strategy, prefer Given/When/Then (Gherkin) format for
  acceptance tests. This format is unambiguous and directly testable.
- The implementation checklist should be actionable. Each item should represent
  a concrete, independently completable task.
