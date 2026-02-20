---
task: qa-trace-requirements
agent: qa
workflow: story-development-cycle (verification phase)
inputs: [story file, test files, test-design document (optional), PRD (optional)]
outputs: [traceability matrix, gate YAML block, gap analysis]
---

# Trace Requirements

## Purpose

Create a requirements traceability matrix that maps every story requirement to its corresponding test coverage. This task ensures that each acceptance criterion, functional requirement, and documented edge case has been validated by at least one test. It identifies coverage gaps, highlights untested requirements, and provides a structured view of test-to-requirement relationships for quality gate decisions.

## Prerequisites

- Story file exists with clearly defined acceptance criteria.
- Implementation code has been written and test files exist.
- Story is in `InProgress` or `InReview` status.
- Access to the test files referenced in the story or located in the project test directory.
- Test design document (from `qa-test-design`) is available for cross-reference, OR the agent will trace directly from ACs to test files.

## Steps

### 1. Extract Requirements

Identify all testable requirements from the story file:

- **Acceptance Criteria (primary source):** Each AC becomes a traceable requirement. Extract the AC ID, description, and any Given/When/Then detail.
- **User story statement:** Identify any implicit requirements in the "As a... I want... So that..." statement not explicitly covered by ACs.
- **Tasks/subtasks:** Extract specific behaviors mentioned in task descriptions that are not captured in ACs.
- **Non-functional requirements (NFRs):** Identify performance, security, accessibility, or reliability requirements mentioned in the story or linked PRD.
- **Edge cases documented:** Any edge cases listed in the story's scope, dev notes, or test design.
- **Out-of-scope items:** Record these to verify no tests accidentally validate out-of-scope behavior.

Assign each requirement a unique ID:

```yaml
requirements:
  - id: "REQ-{story-id}-AC1"
    source: "Acceptance Criteria"
    description: "{AC text}"
    type: "functional"
    priority: "P0 | P1 | P2 | P3"

  - id: "REQ-{story-id}-NFR1"
    source: "Story / PRD"
    description: "{NFR text}"
    type: "non-functional"
    priority: "P1"

  - id: "REQ-{story-id}-EDGE1"
    source: "Dev Notes / Test Design"
    description: "{Edge case description}"
    type: "edge-case"
    priority: "P2"
```

### 2. Inventory Test Cases

Scan the project test files to identify all tests related to this story:

- Search test directories for files matching the story's module names.
- Search test file contents for references to story ID, AC identifiers, or feature names.
- Parse each test file to extract:
  - Test suite names (describe/context blocks).
  - Individual test case names (it/test blocks).
  - Assertions made (what each test verifies).
  - Test level (unit/integration/e2e based on file location or naming).

Build a test inventory:

```yaml
test_inventory:
  - test_id: "TEST-001"
    file: "{test-file-path}"
    suite: "{describe block name}"
    name: "{test case name}"
    level: "unit | integration | e2e"
    assertions:
      - "{what is asserted}"
    related_source: "{source file being tested}"
```

### 3. Map Requirements to Tests

For each requirement, find the test cases that validate it:

```yaml
mapping:
  - requirement_id: "REQ-{story-id}-AC1"
    description: "{AC text}"
    test_mappings:
      - test_id: "TEST-001"
        test_file: "{file path}"
        test_name: "{test case name}"
        given: "{What state/data the test sets up}"
        when: "{What action the test performs}"
        then: "{What the test asserts}"
        coverage: "full | partial"
        notes: "{Any mapping notes}"

      - test_id: "TEST-005"
        test_file: "{file path}"
        test_name: "{test case name}"
        given: "{precondition}"
        when: "{action}"
        then: "{assertion}"
        coverage: "integration"
        notes: ""
```

**Coverage classifications:**
- `full` -- The test completely validates the requirement.
- `partial` -- The test validates some aspect but not the entire requirement.
- `unit` -- Covered only at the unit test level (no integration or e2e).
- `integration` -- Covered only at the integration test level.
- `none` -- No test coverage found.

**Mapping rules:**
- A requirement is "fully covered" if at least one test with `full` coverage exists.
- A requirement is "partially covered" if only `partial` mappings exist.
- A requirement is "level-restricted" if covered at only one level (note if this is acceptable).
- A requirement is "uncovered" if no test mappings exist.

**Given-When-Then for documentation, not code:**
The Given/When/Then descriptions document WHAT each test validates for traceability purposes. They describe the test's intent in business terms, not the implementation. Actual test code follows the project's testing standards.

### 4. Analyze Coverage

Calculate overall coverage metrics:

```yaml
coverage_analysis:
  total_requirements: {count}
  fully_covered: {count}
  partially_covered: {count}
  uncovered: {count}
  coverage_percentage: "{fully / total * 100}%"
  by_type:
    functional: {covered}/{total}
    non_functional: {covered}/{total}
    edge_cases: {covered}/{total}
  by_priority:
    p0: {covered}/{total}
    p1: {covered}/{total}
    p2: {covered}/{total}
    p3: {covered}/{total}
```

### 5. Identify and Document Gaps

For each uncovered or partially covered requirement, document the gap:

```yaml
coverage_gaps:
  - requirement_id: "REQ-{story-id}-AC3"
    description: "{requirement text}"
    gap: "{What is not tested}"
    severity: "high | medium | low"
    impact: "{What could go wrong without this test}"
    suggested_test:
      type: "unit | integration | e2e | performance | security"
      description: "{What the test should verify}"
      estimated_effort: "low | medium | high"
```

Gap severity guidelines:
- **High:** P0 requirement with no coverage, or security/data-integrity requirement untested.
- **Medium:** P1 requirement with only partial coverage, or missing edge case for a critical feature.
- **Low:** P2/P3 requirement without coverage, or minor edge case not tested.

### 6. Cross-Reference with Test Design

If a test design document exists (from `qa-test-design`):

- Verify that every P0 scenario from the test design has a corresponding test.
- Check that the actual test distribution matches the planned distribution.
- Note any planned scenarios that were not implemented.
- Note any implemented tests that were not in the original plan (determine if they are valuable additions or out-of-scope).

### 7. Assess Orphan Tests

Identify tests that do not map to any requirement:

```yaml
orphan_tests:
  - test_id: "TEST-042"
    file: "{test-file-path}"
    name: "{test name}"
    assessment: "valuable (keep) | redundant (consider removing) | out-of-scope (review)"
```

Orphan tests are not necessarily bad -- they may test important edge cases not in the ACs. But they should be reviewed to ensure they add value.

### 8. Produce Traceability Report

Generate the full report following the output format below.

## Output Format

### Output 1: Traceability Report

Save to: `{qa-location}/assessments/{story-id}-trace-{YYYYMMDD}.md`

```markdown
# Requirements Traceability Matrix

## Story: {story-id} - {title}

Date: {date}
Tracer: @qa

### Coverage Summary

- Total Requirements: {count}
- Fully Covered: {count} ({percentage}%)
- Partially Covered: {count} ({percentage}%)
- Not Covered: {count} ({percentage}%)

### Traceability Matrix

| Requirement | Description | Test IDs | Coverage | Level |
|-------------|------------|----------|----------|-------|
| REQ-{story-id}-AC1 | {description} | TEST-001, TEST-005 | Full | Unit + Integration |
| REQ-{story-id}-AC2 | {description} | TEST-003 | Partial | Unit only |
| REQ-{story-id}-AC3 | {description} | -- | None | -- |

### Detailed Mappings

#### REQ-{story-id}-AC1: {Acceptance Criterion 1}

**Coverage: FULL**

- **Unit Test**: `{test-file}::{test-name}`
  - Given: {precondition}
  - When: {action}
  - Then: {expected outcome}

- **Integration Test**: `{test-file}::{test-name}`
  - Given: {precondition}
  - When: {action}
  - Then: {expected outcome}

#### REQ-{story-id}-AC2: {Acceptance Criterion 2}

**Coverage: PARTIAL**

[Continue for all requirements...]

### Coverage Gaps

| Requirement | Gap | Severity | Suggested Test |
|-------------|-----|----------|---------------|
| REQ-{story-id}-AC3 | {what is missing} | High | {suggested test description} |

### Orphan Tests

| Test | File | Assessment |
|------|------|-----------|
| {test-name} | {file} | {valuable/redundant/out-of-scope} |

### Risk Assessment

- **High Risk**: Requirements with no coverage
- **Medium Risk**: Requirements with only partial coverage
- **Low Risk**: Requirements with full unit + integration coverage

### Recommendations

1. {Actionable recommendation based on gaps}
2. {Actionable recommendation based on coverage distribution}
```

### Output 2: Gate YAML Block

Generate for inclusion in quality gate under `trace`:

```yaml
trace:
  totals:
    requirements: {count}
    full: {count}
    partial: {count}
    none: {count}
  coverage_percentage: "{percentage}%"
  planning_ref: "{qa-location}/assessments/{story-id}-test-design-{YYYYMMDD}.md"
  uncovered:
    - ac: "{AC reference}"
      reason: "{Why no test exists}"
  orphan_tests: {count}
  notes: "See {qa-location}/assessments/{story-id}-trace-{YYYYMMDD}.md"
```

**Gate integration:**
- Critical gaps (P0 uncovered) -> FAIL
- Minor gaps (P1 partial) -> CONCERNS
- Missing P0 tests from test-design -> CONCERNS
- Full coverage -> PASS contribution

### Output 3: Story Hook Line

Print for the review task to quote:

```
Trace matrix: {qa-location}/assessments/{story-id}-trace-{YYYYMMDD}.md
Coverage: {fully-covered}/{total} requirements ({percentage}%)
```

## Error Handling

- **No test files found:** Report 0% coverage for all requirements. Generate the full gap analysis as a recommended action list for @dev. This is a valid (though concerning) traceability result, not an error.
- **Story has no ACs:** Halt and inform the user. Traceability requires defined requirements. Suggest reviewing with @po.
- **Test files unparseable:** Skip the unparseable file, log a warning with the file path and error. Continue with remaining files. Note the skipped file in the report.
- **Cannot determine test-to-requirement mapping:** Mark the requirement as `partial` with a note explaining the ambiguity. Recommend adding AC references to test names for clarity.
- **Test design document not found:** Proceed without cross-referencing. Note in the report that design-to-implementation comparison was not performed.
- **Circular references in test helpers:** Trace only the top-level test cases, not their helper functions. Note if helper functions contain significant assertions.
- **Large number of test files:** If more than 100 test files are relevant, batch the analysis and present a summary first, then offer detailed review per module.
- **Stale test references:** If tests reference files or functions that no longer exist, flag them as broken tests in the orphan test section.

## Examples

### Example: Traceability for a User Registration Story

Requirements extracted:
- REQ-3.2-AC1: Valid email and password creates account.
- REQ-3.2-AC2: Duplicate email returns error.
- REQ-3.2-AC3: Password stored as hash, never plaintext.
- REQ-3.2-EDGE1: Email case-insensitive comparison.

Traceability matrix:

| Requirement | Test IDs | Coverage |
|-------------|----------|----------|
| REQ-3.2-AC1 | TEST-001, TEST-002, TEST-010 | Full |
| REQ-3.2-AC2 | TEST-003 | Full |
| REQ-3.2-AC3 | TEST-004 | Full |
| REQ-3.2-EDGE1 | -- | None |

Gap: REQ-3.2-EDGE1 (email case sensitivity) has no test. Severity: Medium. Suggested: Unit test comparing `user@example.com` and `User@Example.COM`.

## Quality Indicators

Good traceability shows:
- Every AC has at least one test.
- Critical paths have multiple test levels.
- Edge cases are explicitly covered.
- NFRs have appropriate test types.
- Clear Given-When-Then for each test.

## Red Flags

Watch for:
- ACs with no test coverage.
- Tests that do not map to requirements.
- Vague test descriptions.
- Missing edge case coverage.
- NFRs without specific tests.

## Acceptance Criteria

- [ ] Every AC in the story is listed as a requirement in the matrix.
- [ ] Each requirement has a coverage classification (full, partial, none).
- [ ] Test-to-requirement mappings include Given/When/Then descriptions.
- [ ] Coverage gaps are documented with severity and suggested remediation.
- [ ] Orphan tests are identified and assessed.
- [ ] Coverage percentage is calculated accurately.
- [ ] Traceability report is saved to the correct location.
- [ ] Gate YAML block is generated.
- [ ] P0 requirements with no coverage are flagged as high-severity gaps.

## Notes

- Traceability is about confidence, not perfection. 100% coverage is desirable but not always practical. The goal is to ensure nothing important is missed.
- Given-When-Then in this context documents the test's INTENT for traceability. It does not prescribe BDD-style test code. Actual tests follow the project's testing conventions.
- Run this task after `qa-generate-tests` to validate the generated tests cover all requirements.
- The traceability matrix integrates with `qa-gate` to inform the quality gate decision. Critical gaps contribute to a FAIL verdict; minor gaps contribute to CONCERNS.
- This task reads but does not modify test files or implementation code.
- Revisit traceability if the story scope changes or new ACs are added during development.
- For PRD-level traceability (FR/NFR to stories), a separate cross-story traceability analysis may be needed at the epic level.
