---
task: qa-generate-tests
agent: qa
workflow: story-development-cycle (testing phase)
inputs: [story file, implementation code, acceptance criteria, test-design output]
outputs: [test suite files, test generation report, coverage estimate]
---

# Generate Tests

## Purpose

Generate comprehensive test suites for a story implementation based on its acceptance criteria, risk profile, and test design. This task produces executable test files covering unit, integration, and end-to-end scenarios with appropriate assertions, mocks, and edge case coverage. The generated tests validate that the implementation meets all documented requirements.

## Prerequisites

- Story is in `InProgress` or `InReview` status with implementation complete.
- Implementation code exists and is readable for all files in the story's File List.
- Acceptance criteria are clearly defined in the story file.
- The test design document exists (produced by `qa-test-design`), OR the agent will generate a lightweight test plan inline.
- The project's test framework is identifiable from existing test files or configuration (e.g., `package.json`, `pytest.ini`, test directories).

## Steps

### 1. Analyze Implementation Context

Read the story file and all implementation files:

- Extract all acceptance criteria (ACs) with their Given/When/Then mappings if present.
- Identify every file in the story's File List and categorize:
  - **Source files:** Files containing business logic, services, utilities.
  - **Configuration files:** Files with settings, constants, environment setup.
  - **API/Route files:** Files defining endpoints, controllers, handlers.
  - **UI/Component files:** Files defining user-facing components.
- For each source file, identify:
  - Exported functions and classes.
  - Input parameters and return types.
  - External dependencies (imports from other modules or packages).
  - Error handling paths (try/catch, error returns, validation).
  - Side effects (file I/O, network calls, database operations, state mutations).

### 2. Detect Project Test Conventions

Discover the project's existing test setup:

- **Test framework:** Scan `package.json` (or equivalent) for test runner configuration (`jest`, `vitest`, `mocha`, `pytest`, etc.).
- **Test file pattern:** Examine existing test files for naming convention (`*.test.ts`, `*.spec.ts`, `*_test.py`, etc.).
- **Test directory structure:** Check for `__tests__/`, `tests/`, `test/`, or co-located test files.
- **Assertion style:** Identify `expect()`, `assert`, `should` patterns from existing tests.
- **Mocking approach:** Detect `jest.mock()`, `vi.mock()`, `unittest.mock`, `sinon`, or similar.
- **Setup/teardown patterns:** Note `beforeAll`, `beforeEach`, `setUp`, `fixture` usage.
- **Coverage configuration:** Check for coverage thresholds in config files.

If no existing tests are found, use sensible defaults and inform the user of the conventions chosen.

### 3. Build Test Plan

For each acceptance criterion, determine which test levels are needed:

#### Unit Tests
Generate for:
- Pure functions with deterministic inputs/outputs.
- Validation logic (input parsing, format checking, boundary values).
- Business rules and calculations.
- Error handling paths.
- State transformations.

Each unit test should:
- Test one behavior per test case.
- Include at least one happy path and one error path.
- Cover boundary values and edge cases.
- Mock all external dependencies.

#### Integration Tests
Generate for:
- Service-to-service interactions within the story scope.
- Database operations (CRUD, queries, transactions).
- API endpoint behavior (request/response cycle).
- Module composition (multiple units working together).

Each integration test should:
- Test the contract between components.
- Use realistic but controlled test data.
- Mock only external boundaries (third-party APIs, file system if appropriate).
- Verify side effects (database state, event emission).

#### End-to-End Tests
Generate for:
- Critical user journeys mapped to ACs.
- Multi-step workflows that cross component boundaries.
- Scenarios requiring full system behavior.

Each e2e test should:
- Simulate real user actions.
- Verify the complete flow from input to visible output.
- Include setup and teardown of test state.
- Be independent and idempotent.

### 4. Generate Test Files

For each planned test file:

1. **Create the file** at the correct location following project conventions.
2. **Write the imports** for test framework, source module, and mocking utilities.
3. **Write the describe/context blocks** organized by feature or AC.
4. **Write individual test cases** with:
   - Descriptive test name explaining the expected behavior.
   - Arrange: Set up test data, mocks, and preconditions.
   - Act: Call the function or trigger the action under test.
   - Assert: Verify the expected outcome with specific assertions.
5. **Add edge case tests:**
   - Null/undefined inputs.
   - Empty collections.
   - Boundary values (zero, max, negative).
   - Concurrent operations (if applicable).
   - Timeout and retry scenarios (if applicable).
6. **Add error scenario tests:**
   - Invalid input types and formats.
   - Missing required fields.
   - Network/service failures (for integration tests).
   - Permission/authorization failures.

### 5. Generate Mocks and Fixtures

Create supporting test infrastructure:

- **Mock modules:** For each external dependency, create appropriate mocks that return controlled data.
- **Test fixtures:** Create reusable test data objects that represent valid and invalid states.
- **Factory functions:** For complex test data, create builder/factory functions.
- **Shared setup:** Extract common setup into shared `beforeEach` or helper functions.

Place mocks and fixtures according to project conventions:
- `__mocks__/` directory for module-level mocks.
- `fixtures/` or `__fixtures__/` for test data.
- Co-located helper files for test-specific utilities.

### 6. Validate Generated Tests

Before finalizing, verify each generated test file:

- [ ] Syntax is valid for the target language and test framework.
- [ ] All imports reference existing modules or properly mocked dependencies.
- [ ] Test names are descriptive and follow project naming conventions.
- [ ] No duplicate test names within a describe block.
- [ ] Assertions use the correct matchers for the assertion style.
- [ ] Async tests properly use `async/await` or equivalent.
- [ ] Mocks are properly set up and cleaned up (no leak between tests).
- [ ] Each AC has at least one corresponding test case.

### 7. Run Generated Tests

Execute the generated test files to verify they work:

```
{test-command} {generated-test-paths}
```

- If tests pass: Record success in the report.
- If tests fail due to implementation bugs: Document as findings (these are valid test catches).
- If tests fail due to test code errors: Fix the test code and re-run (up to 3 iterations).
- If tests fail due to missing mocks: Add the missing mocks and re-run.

### 8. Produce Test Generation Report

Create a summary report documenting what was generated:

```yaml
test-generation:
  storyId: "{story-id}"
  date: "{date}"
  generator: "@qa"
  summary:
    total_test_files: {count}
    total_test_cases: {count}
    by_level:
      unit: {count}
      integration: {count}
      e2e: {count}
    by_ac:
      - ac: "AC1"
        tests: {count}
        coverage: "full | partial"
      - ac: "AC2"
        tests: {count}
        coverage: "full | partial"
  coverage_estimate:
    target: "{percentage}%"
    estimated: "{percentage}%"
    gaps: []
  files_generated:
    - path: "{test-file-path}"
      type: "unit | integration | e2e"
      test_count: {count}
      status: "passing | failing | error"
  edge_cases_covered:
    - "Null input handling"
    - "Empty collection processing"
    - "Boundary value at maximum"
  mocks_created:
    - module: "{module-name}"
      location: "{mock-file-path}"
  notes: "{any observations or recommendations}"
```

### 9. Update Story File

Add the generated test information to the story:

- Add new test files to the File List section.
- Add a Change Log entry: `[{date}] @qa -- Test suite generated. {total} tests across {files} files. Coverage estimate: {percentage}%.`
- Note any ACs with partial coverage in Dev Notes for follow-up.

## Output Format

### Primary Output: Test Files

Test files written to the project's test directory following existing conventions. Each file is self-contained with proper imports, setup, and teardown.

### Secondary Output: Generation Report

Saved to `{qa-location}/assessments/{story-id}-test-generation-{YYYYMMDD}.md` with the YAML summary above rendered as a readable Markdown document.

### Tertiary Output: Gate YAML Block

Generate for inclusion in the quality gate:

```yaml
test_generation:
  total_tests: {count}
  by_level:
    unit: {count}
    integration: {count}
    e2e: {count}
  passing: {count}
  failing: {count}
  coverage_estimate: "{percentage}%"
  ac_coverage:
    full: {count}
    partial: {count}
    none: {count}
```

## Error Handling

- **No test framework detected:** Halt and ask the user to specify the test framework and conventions. Do not assume a framework.
- **Implementation file not found:** Skip the missing file, log a warning, continue with available files. Note the gap in the report.
- **Cannot determine function signatures:** Generate tests based on AC descriptions rather than code analysis. Mark these tests as "AC-driven" in the report and note they may need manual adjustment.
- **Generated tests fail repeatedly:** After 3 fix iterations on a test file, mark it as needing manual review. Include the error output in the report.
- **Circular dependencies in mocks:** Simplify the mock to return static data rather than attempting to replicate the dependency chain. Document the simplification.
- **No ACs in story:** Halt and inform the user that test generation requires acceptance criteria. Suggest running `qa-test-design` first.
- **Conflicting test patterns:** If the project has inconsistent test patterns across files, ask the user which pattern to follow (Interactive/Preflight modes) or use the most recent pattern (Autopilot mode).
- **Test framework version mismatch:** If generated test syntax does not match the installed framework version, adjust to the detected version's API.

## Examples

### Example 1: Unit Test Generation for a Validation Module

Given a story implementing input validation for user registration:

```
AC1: Given invalid email format, When registration is submitted, Then return validation error.
AC2: Given password shorter than 8 characters, When registration is submitted, Then return password length error.
```

Generated unit test file (`validation.test.ts`):

```
describe('UserRegistration Validation', () => {
  describe('AC1: Email validation', () => {
    it('should reject email without @ symbol', ...)
    it('should reject email without domain', ...)
    it('should accept valid email format', ...)
  })
  describe('AC2: Password length', () => {
    it('should reject password with 7 characters', ...)
    it('should accept password with exactly 8 characters', ...)
    it('should accept password with more than 8 characters', ...)
  })
  describe('Edge cases', () => {
    it('should handle null email input', ...)
    it('should handle empty string password', ...)
    it('should handle unicode characters in email', ...)
  })
})
```

### Example 2: Integration Test for API Endpoint

Given a story implementing a REST endpoint:

```
AC1: Given authenticated user, When GET /api/profile is called, Then return user profile data.
```

Generated integration test file (`profile-api.integration.test.ts`):

```
describe('GET /api/profile', () => {
  describe('AC1: Authenticated access', () => {
    it('should return 200 with profile data for valid token', ...)
    it('should return 401 for missing token', ...)
    it('should return 401 for expired token', ...)
    it('should return 403 for insufficient permissions', ...)
  })
})
```

## Acceptance Criteria

- [ ] Every AC in the story has at least one corresponding test case.
- [ ] Test files follow the project's existing naming and structural conventions.
- [ ] Unit tests mock all external dependencies.
- [ ] Integration tests verify component interaction contracts.
- [ ] Edge cases are covered for null/empty/boundary inputs.
- [ ] Error scenarios have explicit test cases.
- [ ] All generated tests are syntactically valid.
- [ ] Test generation report documents coverage by AC.
- [ ] Generated test files are added to the story's File List.
- [ ] Mocks and fixtures are reusable and properly organized.

## Notes

- This task generates the test code itself. For test strategy and planning, use `qa-test-design` first.
- For mapping requirements to generated tests, run `qa-trace-requirements` after this task.
- Generated tests are a starting point. Complex scenarios may require manual refinement by @dev.
- Prefer generating more focused tests over fewer broad tests. Each test should fail for exactly one reason.
- Test generation should not modify implementation code. If implementation bugs are discovered, document them as findings rather than fixing them.
- The test pyramid principle applies: generate more unit tests than integration tests, and more integration tests than e2e tests.
- When in doubt about a test's value, include it. Removing unnecessary tests is easier than discovering missing coverage later.
