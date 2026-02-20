---
task: qa-test-design
agent: qa
workflow: story-development-cycle (pre-implementation or testing phase)
inputs: [story file, risk profile (optional), PRD/epic context]
outputs: [test design document, gate YAML block, trace references]
---

# Test Design

## Purpose

Design a complete test strategy for a story implementation by identifying what to test, at which level (unit, integration, e2e), and why. This task produces a structured test design document with prioritized test scenarios, test pyramid distribution, and edge case inventory. It ensures efficient test coverage without redundancy while maintaining appropriate test boundaries.

## Prerequisites

- Story file exists with clear acceptance criteria.
- Story is in `Ready` or `InProgress` status.
- Access to the PRD or epic context for business understanding.
- Risk profile (from `qa-risk-profile`) is available, OR the agent will assess risk inline.

## Steps

### 1. Analyze Story Requirements

Read the story file and break down each acceptance criterion into testable scenarios:

For each AC:
- **Identify the core functionality** being validated.
- **Determine data variations** needed (valid inputs, invalid inputs, boundary values).
- **Consider error conditions** (what can go wrong, how the system should respond).
- **Note edge cases** (empty inputs, concurrent access, large datasets, special characters).
- **Identify implicit requirements** (performance expectations, security constraints, accessibility).

Document the analysis:

```yaml
ac_analysis:
  - ac_id: "AC1"
    description: "{AC text}"
    core_functionality: "{what is being validated}"
    data_variations:
      - "{variation 1}"
      - "{variation 2}"
    error_conditions:
      - "{error scenario 1}"
      - "{error scenario 2}"
    edge_cases:
      - "{edge case 1}"
      - "{edge case 2}"
    implicit_requirements:
      - "{implicit req 1}"
```

### 2. Apply Test Level Framework

Assign each testable scenario to the appropriate test level using these criteria:

#### Unit Test Level
Assign when:
- Testing pure logic, algorithms, or calculations with no external dependencies.
- Validating input parsing, format checking, or data transformation.
- Verifying business rules that depend only on input data.
- Testing error handling for known error types.
- Function has deterministic output for a given input.

#### Integration Test Level
Assign when:
- Testing interactions between two or more components.
- Validating database operations (CRUD, queries, transactions).
- Verifying API endpoint request/response contracts.
- Testing service orchestration where multiple modules collaborate.
- Validating event handling across module boundaries.

#### E2E Test Level
Assign when:
- Testing critical user journeys that span the full stack.
- Validating compliance or regulatory requirements.
- Verifying multi-step workflows that depend on system state.
- Testing behavior that can only be observed from the user's perspective.
- Validating third-party integrations in a realistic context.

#### Test Level Decision Rules
- **Shift left:** Prefer unit over integration, integration over e2e.
- **No duplication:** If a behavior is fully verified at the unit level, do not repeat it at integration.
- **Critical paths:** Critical business flows may warrant coverage at multiple levels.
- **Cost awareness:** E2e tests are slowest and most fragile; use sparingly for maximum value.

### 3. Assign Priorities

Classify each test scenario by business priority:

| Priority | Criteria | Examples |
|----------|----------|----------|
| **P0** | Revenue-critical, security, compliance, data integrity | Payment processing, authentication, PII handling |
| **P1** | Core user journeys, frequently used features | Login flow, main CRUD operations, search |
| **P2** | Secondary features, admin functions, less common paths | Settings pages, bulk operations, export |
| **P3** | Nice-to-have, rarely used, cosmetic behaviors | Tooltip text, animation timing, sort preferences |

Priority assignment rules:
- Any scenario mitigating a CRITICAL or HIGH risk from the risk profile is automatically P0.
- Any scenario covering a security-related AC is at least P1.
- Any scenario testing an AC marked as "must have" in the story is at least P1.
- Edge cases for P0 scenarios are P1; edge cases for P1 scenarios are P2.

### 4. Design Test Scenarios

For each identified test need, create a structured scenario:

```yaml
test_scenario:
  id: "{story-id}-{LEVEL}-{SEQ}"  # e.g., "1.3-UNIT-001"
  requirement: "{AC reference}"
  priority: "P0 | P1 | P2 | P3"
  level: "unit | integration | e2e"
  description: "{What is being tested}"
  justification: "{Why this level was chosen}"
  mitigates_risks: ["{RISK-ID}"]  # If risk profile exists
  preconditions: "{Required system state}"
  test_data: "{Description of test data needed}"
  expected_outcome: "{What a passing test verifies}"
```

Naming convention for scenario IDs:
- `{story-id}-UNIT-{SEQ}` for unit test scenarios.
- `{story-id}-INT-{SEQ}` for integration test scenarios.
- `{story-id}-E2E-{SEQ}` for end-to-end test scenarios.

Sequence numbers start at 001 within each level.

### 5. Validate Coverage

Before finalizing, verify the test design is complete:

- [ ] Every AC has at least one test scenario.
- [ ] No duplicate coverage across test levels for the same behavior.
- [ ] Critical paths (P0) have coverage at the appropriate level.
- [ ] Risk mitigations from the risk profile are addressed by specific scenarios.
- [ ] Edge cases are explicitly listed (not assumed).
- [ ] Error handling scenarios are present for each AC that involves user input or external calls.
- [ ] The test pyramid is balanced (more unit than integration, more integration than e2e).

If gaps are found, add scenarios to address them. If over-testing is detected (same behavior tested at multiple levels without justification), remove the redundant scenario and note why.

### 6. Define Recommended Execution Order

Specify the order in which tests should be executed for fastest feedback:

1. **P0 unit tests** -- Fail fast on broken business logic.
2. **P0 integration tests** -- Verify critical component interactions.
3. **P0 e2e tests** -- Validate critical user journeys.
4. **P1 tests** in level order (unit, integration, e2e).
5. **P2+ tests** as time permits.

This order maximizes the chance of catching the most important issues first.

### 7. Document the Test Design

Produce the test design document following the output format below.

## Output Format

### Output 1: Test Design Document

Save to: `{qa-location}/assessments/{story-id}-test-design-{YYYYMMDD}.md`

```markdown
# Test Design: Story {story-id}

Date: {date}
Designer: @qa

## Test Strategy Overview

- Total test scenarios: {count}
- Unit tests: {count} ({percentage}%)
- Integration tests: {count} ({percentage}%)
- E2E tests: {count} ({percentage}%)
- Priority distribution: P0: {count}, P1: {count}, P2: {count}, P3: {count}

## Test Scenarios by Acceptance Criteria

### AC1: {description}

#### Scenarios

| ID | Level | Priority | Test | Justification |
|----|-------|----------|------|---------------|
| {story-id}-UNIT-001 | Unit | P0 | {description} | {reason for this level} |
| {story-id}-INT-001 | Integration | P0 | {description} | {reason for this level} |
| {story-id}-E2E-001 | E2E | P1 | {description} | {reason for this level} |

### AC2: {description}

[Continue for all ACs...]

## Edge Cases Inventory

| ID | Related AC | Description | Level | Priority |
|----|-----------|-------------|-------|----------|
| {story-id}-UNIT-{SEQ} | AC1 | {edge case description} | Unit | P2 |

## Risk Coverage

| Risk ID | Risk Description | Test Scenario IDs | Coverage |
|---------|-----------------|-------------------|----------|
| {RISK-ID} | {description} | {scenario-ids} | Full/Partial |

[Include only if risk profile exists]

## Recommended Execution Order

1. P0 Unit tests (fail fast)
2. P0 Integration tests
3. P0 E2E tests
4. P1 tests in order
5. P2+ as time permits

## Test Data Requirements

- {Description of test data needed for scenarios}
- {Fixtures or factories required}
- {External data dependencies}

## Mock Strategy

- {What to mock at unit level}
- {What to mock at integration level}
- {What remains real at e2e level}
```

### Output 2: Gate YAML Block

Generate for inclusion in quality gate:

```yaml
test_design:
  scenarios_total: {count}
  by_level:
    unit: {count}
    integration: {count}
    e2e: {count}
  by_priority:
    p0: {count}
    p1: {count}
    p2: {count}
    p3: {count}
  coverage_gaps: []  # List any ACs without tests
  risk_scenarios: {count}  # Scenarios linked to risk profile
```

### Output 3: Trace Reference

Print for use by `qa-trace-requirements`:

```
Test design matrix: {qa-location}/assessments/{story-id}-test-design-{YYYYMMDD}.md
P0 tests identified: {count}
```

## Error Handling

- **Story has no acceptance criteria:** Halt and inform the user that test design requires ACs. Suggest reviewing the story with @po.
- **ACs are vague or untestable:** Document the vague ACs as gaps. Provide suggestions for making them testable (e.g., add specific values, define expected behavior). Continue with the remaining ACs.
- **Risk profile not available:** Proceed without risk mapping. Note in the report that risk-based prioritization was not applied. Recommend running `qa-risk-profile` for complete analysis.
- **Cannot determine test level:** Default to integration for ambiguous scenarios. Document the ambiguity and recommend team discussion.
- **Too many scenarios generated:** If the scenario count exceeds 50, group related scenarios and recommend phased implementation. P0 and P1 scenarios should be implemented first.
- **Conflicting priorities between ACs:** Prioritize based on the AC that has higher business impact. Document the conflict and the resolution rationale.
- **No existing test patterns to reference:** Document the recommended conventions explicitly in the test design so that `qa-generate-tests` can follow them.

## Examples

### Example: Test Design for a Login Feature

Story AC: "Given valid credentials, When user submits login form, Then user is authenticated and redirected to dashboard."

| ID | Level | Priority | Test | Justification |
|----|-------|----------|------|---------------|
| 2.1-UNIT-001 | Unit | P0 | Validate credential format | Pure validation logic |
| 2.1-UNIT-002 | Unit | P0 | Hash comparison returns true for matching password | Deterministic logic |
| 2.1-UNIT-003 | Unit | P1 | Reject empty email | Edge case for validation |
| 2.1-UNIT-004 | Unit | P1 | Reject empty password | Edge case for validation |
| 2.1-INT-001 | Integration | P0 | Authentication service authenticates valid user | Service + DB interaction |
| 2.1-INT-002 | Integration | P0 | Authentication service rejects invalid password | Error path across components |
| 2.1-INT-003 | Integration | P1 | Session created after successful authentication | Side effect verification |
| 2.1-E2E-001 | E2E | P0 | User logs in and sees dashboard | Critical user journey |
| 2.1-E2E-002 | E2E | P1 | User sees error message for wrong password | User-visible error handling |

## Quality Checklist

Before finalizing, verify:

- [ ] Every AC has test coverage.
- [ ] Test levels are appropriate (not over-testing).
- [ ] No duplicate coverage across levels.
- [ ] Priorities align with business risk.
- [ ] Test IDs follow naming convention.
- [ ] Scenarios are atomic and independent.

## Acceptance Criteria

- [ ] Every AC has at least one test scenario.
- [ ] Test levels are appropriately assigned (not over-testing at higher levels).
- [ ] No duplicate coverage across test levels for the same behavior.
- [ ] Priorities align with business risk and AC importance.
- [ ] Scenario IDs follow the naming convention `{story-id}-{LEVEL}-{SEQ}`.
- [ ] Scenarios are atomic (each tests one thing) and independent (no ordering dependency).
- [ ] Edge cases are explicitly listed, not assumed.
- [ ] Test design document is saved to the correct location.
- [ ] Gate YAML block is generated.

## Notes

- This task designs the test strategy. For generating the actual test code, use `qa-generate-tests` after this task.
- The test design should be created before or during implementation, not only after. Early test design helps @dev write more testable code.
- Revisit the test design if the story scope changes during implementation.
- The test design document serves as the contract between @qa and @dev for what "fully tested" means.
- Test scenarios should describe WHAT is tested and WHY, not HOW the test is written. Implementation details belong in `qa-generate-tests`.
- Key principle: test once at the right level. A behavior tested at the unit level does not need an integration test unless the integration itself adds risk.
