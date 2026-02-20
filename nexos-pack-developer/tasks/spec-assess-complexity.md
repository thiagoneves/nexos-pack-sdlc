---
task: spec-assess-complexity
agent: architect
workflow: spec-pipeline (phase 2)
inputs: [requirements.json from phase 1]
outputs: [complexity assessment with class and dimension scores]
skip_conditions: [source explicitly marked as simple (override available)]
---

# Assess Complexity

## Purpose

Evaluate the complexity of the proposed work across 5 dimensions (Scope, Integration,
Infrastructure, Knowledge, Risk), assign a complexity class (SIMPLE, STANDARD, COMPLEX),
and determine which subsequent spec pipeline phases are required. The assessment directly
controls the pipeline flow -- SIMPLE skips research and uses a streamlined spec,
STANDARD runs the full pipeline, and COMPLEX adds revision cycles.

This phase may be skipped only if the requirement source is explicitly marked as simple,
but can always be forced with an override.

---

## Prerequisites

- Requirements document from `spec-gather-requirements` (phase 1) is available.
- Understanding of the current project architecture and codebase.
- Access to project documentation for context.
- The executing agent can read the codebase to estimate scope.

---

## Complexity Dimensions

### Dimension 1: Scope (1-5)

How many files, components, or modules will be affected?

| Score | Description | Indicators |
|-------|-------------|------------|
| 1 | 1-2 files, isolated change | Single function or component |
| 2 | 3-5 files, single module | One feature module |
| 3 | 6-10 files, multiple modules | Cross-module feature |
| 4 | 11-20 files, cross-cutting concern | Affects multiple features |
| 5 | 20+ files, system-wide change | Architecture-level modification |

**Analysis method:**
1. Parse functional requirements for components/modules mentioned.
2. Search codebase for related files.
3. Count unique files that will need modification.
4. Check for similar features to estimate pattern.

---

### Dimension 2: Integration (1-5)

How many external integrations are required?

| Score | Description | Indicators |
|-------|-------------|------------|
| 1 | No external dependencies | Pure internal logic |
| 2 | 1 well-documented internal API | Existing, stable API |
| 3 | 1-2 external APIs or new internal API | New integration point |
| 4 | 3+ external services or poorly documented APIs | Multiple integration points |
| 5 | Complex multi-service orchestration | Distributed system coordination |

**Analysis method:**
1. Identify external services mentioned in requirements.
2. Check for authentication/authorization requirements.
3. Assess data flow complexity between services.
4. Check if similar integrations exist in codebase.

---

### Dimension 3: Infrastructure (1-5)

What infrastructure changes are needed?

| Score | Description | Indicators |
|-------|-------------|------------|
| 1 | No infrastructure changes | Code-only change |
| 2 | Minor configuration changes | Environment variables, feature flags |
| 3 | New database tables or indexes | Schema migration needed |
| 4 | New services, queues, or deployment changes | New infrastructure component |
| 5 | Major architecture or platform changes | New server, container, platform |

**Analysis method:**
1. Check for database changes in requirements.
2. Identify new services or infrastructure needed.
3. Assess deployment impact.
4. Check for environment or configuration changes.

---

### Dimension 4: Knowledge (1-5)

What level of knowledge is required to implement?

| Score | Description | Indicators |
|-------|-------------|------------|
| 1 | Well-known patterns, existing in codebase | Copy-paste with adaptation |
| 2 | Familiar technology, minor learning curve | Known tech, new pattern |
| 3 | Some new concepts or libraries | New library with good docs |
| 4 | Significant new technology | Unfamiliar tech stack |
| 5 | Completely unfamiliar domain or tech | Research-heavy, spike needed |

**Analysis method:**
1. Check existing patterns in codebase for similar implementations.
2. Identify new technologies mentioned in requirements.
3. Assess learning curve for unfamiliar concepts.
4. Check if documentation exists for new technologies.

---

### Dimension 5: Risk (1-5)

What is the risk of negative impact?

| Score | Description | Indicators |
|-------|-------------|------------|
| 1 | Low impact if failure, easily reversible | Isolated feature, no data changes |
| 2 | Minor user impact, quick recovery | Small user segment, rollback easy |
| 3 | Moderate user impact, data handling involved | Important feature, data at stake |
| 4 | High user impact, financial or security implications | Many users, security-sensitive |
| 5 | Critical system, irreversible actions, compliance risk | Core system, regulatory |

**Analysis method:**
1. Assess user impact if the feature fails.
2. Check for security implications.
3. Evaluate reversibility (can we roll back?).
4. Check for financial or regulatory implications.

---

## Classification Thresholds

Sum all 5 dimension scores to get the total (range: 5-25).

| Total Score | Class | Pipeline Phases | Typical Effort |
|-------------|-------|-----------------|----------------|
| 5-8 | **SIMPLE** | Gather -> Write Spec -> Critique | < 1 day |
| 9-15 | **STANDARD** | Gather -> Assess -> Research -> Write Spec -> Critique -> Plan | 1-3 days |
| 16-25 | **COMPLEX** | All phases + revision cycle (Critique -> Revise -> Re-critique) | 3+ days |

**COMPLEX class additional flags:**
- Requires architectural review before implementation.
- Consider breaking into smaller stories.
- A spike or proof-of-concept may be needed.

---

## Steps

### Step 1: Load Requirements

Read the requirements output from phase 1.

**Substeps:**

1. Load the requirements document (JSON or structured format).
2. Parse all functional requirements (FR-*).
3. Parse all non-functional requirements (NFR-*).
4. Parse all constraints (CON-*).
5. Note open questions and assumptions.
6. Validate that the document is not empty (at least 1 FR).

**Error:** If requirements document is not found, HALT and instruct to run
`spec-gather-requirements` first.

---

### Step 2: Analyze Codebase Context

If an existing codebase is present, analyze it for context.

**Substeps:**

1. **Estimate affected files:**
   - Parse functional requirements for component/module mentions.
   - Search codebase for related files and patterns.
   - Count unique files likely to be modified or created.

2. **Check existing patterns:**
   - Extract key concepts from requirements.
   - Search for similar implementations in the codebase.
   - Assess reusability of existing patterns.

3. **Identify integrations:**
   - Parse requirements for external service mentions.
   - Check existing integrations in the codebase.
   - Identify new connections needed.

4. **Review technical debt:**
   - Check test coverage in affected areas.
   - Note existing technical debt that may complicate work.
   - Identify fragile or poorly documented areas.

**Note:** If no codebase context is available, score Knowledge and Scope based
on requirements alone and note the limited context in the assessment.

---

### Step 3: Score Each Dimension

For each of the 5 dimensions:

**Substeps:**

1. Apply the scoring criteria from the dimension tables above.
2. Document the rationale for the score (specific evidence).
3. Assign a score from 1 to 5.
4. Note any uncertainty in the scoring.

---

### Step 4: Calculate Classification

**Substeps:**

1. Sum all 5 dimension scores.
2. Apply classification thresholds:
   - Total <= 8: SIMPLE
   - Total 9-15: STANDARD
   - Total >= 16: COMPLEX
3. Check for manual override (if provided, use override but log the discrepancy).
4. Determine which pipeline phases are required based on the class.

**Edge cases:** When the total is exactly 8 or exactly 15, present both possible
classifications and let the user decide.

---

### Step 5: Document the Assessment

Produce the complexity assessment output.

**Output structure:**

```yaml
complexity_assessment:
  date: "{YYYY-MM-DD}"
  assessed_by: "@architect"
  requirements_source: "requirements.json"

  dimensions:
    scope: { score: N, rationale: "..." }
    integration: { score: N, rationale: "..." }
    infrastructure: { score: N, rationale: "..." }
    knowledge: { score: N, rationale: "..." }
    risk: { score: N, rationale: "..." }

  total_score: N
  class: "{SIMPLE|STANDARD|COMPLEX}"
  overridden: false
  required_phases: ["{phase1}", "{phase2}", "..."]
  estimated_effort: "{typical time}"

  flags: ["..."]        # Warnings or recommendations
  notes: "..."          # Additional context
  recommendations: "..."  # Suggested approach
```

Save to the project's docs or spec directory.

---

### Step 6: Present Results and Next Steps

Inform the user of the assessment results.

**Substeps:**

1. **Show the classification:**
   - Total complexity score and class (SIMPLE/STANDARD/COMPLEX).
   - Visual breakdown per dimension with rationale.

2. **Show the pipeline path:**
   - Which spec pipeline phases will be executed.
   - Estimated effort for the full pipeline.

3. **Show recommendations:**
   - For SIMPLE: "Skipping research phase. Proceeding to spec writing."
   - For STANDARD: "Full pipeline. Research phase will investigate dependencies."
   - For COMPLEX: "Full pipeline with revision cycle. Consider breaking into
     smaller stories if possible."

4. **Recommend next step:**
   - Proceed to the next applicable phase.
   - Or suggest story decomposition for COMPLEX items.

---

## Pipeline Integration

```yaml
pipeline:
  phase: assess
  previous_phase: gather
  next_phase: research (STANDARD/COMPLEX) or spec (SIMPLE)

  requires:
    - requirements.json

  pass_to_next:
    - complexity assessment
    - requirements.json

  skip_conditions:
    - "manual override provided"  # Still runs but uses override value
```

---

## Error Handling

| Error | Condition | Action | Blocking |
|-------|-----------|--------|----------|
| Missing requirements | Requirements document not found | HALT, instruct to run phase 1 first | YES |
| Empty requirements | Functional requirements array is empty | Cannot assess, no requirements to analyze | YES |
| No codebase context | No existing codebase available | Score based on requirements alone, note limited context | NO |
| Insufficient detail | Requirements too vague for accurate scoring | Score conservatively (higher) and note uncertainty | NO |
| Override mismatch | Manual override significantly differs from calculated | Log warning but proceed with override | NO |
| Edge case score | Total is exactly 8 or 15 (boundary) | Present both classifications, ask user to decide | NO |
| User disagrees | User disagrees with a dimension score | Allow manual override with documented rationale | NO |

---

## Examples

### Example 1: Simple Feature Assessment

**Input:** Requirements for adding a tooltip to an existing button.

```
Scope:          1 (1 component file)
Integration:    1 (no external services)
Infrastructure: 1 (no infra changes)
Knowledge:      1 (tooltip pattern exists in codebase)
Risk:           1 (isolated UI change)
--------------------------------------------
Total:          5 -> SIMPLE
```

**Pipeline:** Gather -> Write Spec -> Critique (3 phases)

### Example 2: Standard Feature Assessment

**Input:** Requirements for Google OAuth login.

```
Scope:          3 (auth module, login page, user service)
Integration:    3 (Google OAuth API)
Infrastructure: 2 (env vars for OAuth credentials)
Knowledge:      2 (OAuth pattern exists in codebase)
Risk:           3 (affects all users, security-sensitive)
--------------------------------------------
Total:          13 -> STANDARD
```

**Pipeline:** Gather -> Assess -> Research -> Write Spec -> Critique -> Plan (6 phases)

### Example 3: Complex Feature Assessment

**Input:** Requirements for real-time collaborative editing.

```
Scope:          5 (entire document system, WebSocket layer, conflict resolution)
Integration:    4 (WebSocket server, operational transform library, presence API)
Infrastructure: 4 (new WebSocket server, Redis for presence, schema changes)
Knowledge:      5 (CRDT/OT algorithms, new domain)
Risk:           4 (core feature, data integrity critical)
--------------------------------------------
Total:          22 -> COMPLEX
```

**Pipeline:** All 6 phases + revision cycle. Recommendation: Consider spike first.

---

## Acceptance Criteria for This Task

- [ ] All 5 dimensions are scored with rationale documented.
- [ ] Total score is calculated correctly.
- [ ] Classification matches the threshold rules.
- [ ] Pipeline phases are correctly determined for the class.
- [ ] Assessment is saved to the docs or spec directory.
- [ ] User is informed of the classification and next steps.
- [ ] Edge cases (boundary scores) are handled with user input.
- [ ] Any manual overrides are logged with reason.

---

## Notes

- The 5-dimension model is designed to be comprehensive yet quick to evaluate.
  A full assessment should take 5-10 minutes.
- Scoring should be evidence-based when possible. Reference specific files, patterns,
  or requirements when justifying a score.
- When in doubt, score higher (more complex). It is better to over-prepare than
  to under-estimate complexity.
- The classification directly affects cost and time. SIMPLE = hours, STANDARD = days,
  COMPLEX = days to weeks.
- Manual overrides are allowed but should be rare. If the user frequently overrides,
  the scoring criteria may need calibration for the project.
- This assessment is advisory -- it guides the pipeline but does not block
  implementation if the user disagrees and overrides.
