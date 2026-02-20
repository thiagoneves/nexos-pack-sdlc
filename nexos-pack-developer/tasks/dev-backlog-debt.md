---
task: dev-backlog-debt
agent: dev
workflow: backlog-management
inputs:
  - title (string, required) - Short description, 10-100 chars
  - description (string, required) - Detailed description, max 500 chars
  - priority (enum, optional) - Critical | High | Medium | Low, default Medium
  - relatedStory (string, optional) - Story ID where debt was identified
  - tags (array, optional) - Comma-separated tags for categorization
  - estimatedEffort (string, optional) - Rough effort estimate, default "TBD"
  - impactArea (string, optional) - Which part of codebase is affected
  - mode (string, optional) - Execution mode: "yolo" | "interactive" | "pre-flight", default "interactive"
outputs:
  - execution_result (object) - Registered debt item with ID
  - backlog_file (file) - Updated docs/stories/backlog.md
---

# Register Technical Debt

## Purpose
Register technical debt items to the project backlog for tracking, prioritization, and future resolution.

## Prerequisites
- Backlog file exists at `docs/stories/backlog.md`
- Task parameters are valid if provided

## Steps

### 1. Elicit Technical Debt Details
Gather the following interactively:

1. **Title** (required, 10-100 chars)
   - Example: "Refactor authentication logic to use dependency injection"

2. **Detailed Description** (required, max 500 chars)
   - Describe what needs improvement and why it is considered tech debt
   - Example: "Current authentication logic has tight coupling to database layer. Should use DI pattern to improve testability and maintainability. Impacts: auth.js, user-service.js, session-manager.js"

3. **Priority** (default: Medium)
   - Critical - Severe code smell, security risk, or blocking future work
   - High - Significant maintainability issue
   - Medium - Quality improvement
   - Low - Nice-to-have refactoring

4. **Related Story ID** (optional)
   - Link to story where debt was identified or introduced
   - Example: "6.1.2.6"

5. **Tags** (optional, comma-separated)
   - Suggestions: refactoring, architecture, testing, performance, security, duplication, coupling, naming, documentation

6. **Estimated Effort** (optional, default: "TBD")
   - Examples: "4 hours", "2 days", "1 week"

7. **Impact Area** (optional)
   - Which part of codebase is affected
   - Example: "authentication, user management"

### 2. Validate Input
1. If a related story was provided, verify the story file exists at `docs/stories/**/*{relatedStory}*.md`
2. If not found, log a warning and proceed without the story link
3. If multiple story matches, use the first match and log the alternatives
4. Parse tags from comma-separated input
5. If impact area is provided, add it as an `area:{impactArea}` tag

### 3. Add to Backlog
1. Load the backlog manager from `docs/stories/backlog.md`
2. Create a new Technical Debt entry (type: "T") with:
   - title, description, priority
   - relatedStory (or null)
   - createdBy: "@dev"
   - tags, estimatedEffort
3. Log the registered item ID

### 4. Regenerate Backlog
1. Regenerate the backlog file to include the new entry
2. Verify the updated file at `docs/stories/backlog.md`

### 5. Summary Output
Display a summary with:
- Item ID, type (Technical Debt), title
- Priority with severity level
- Related story (if any)
- Estimated effort, impact area, tags
- Description
- Next steps: review in backlog, prioritize, address in dedicated story or alongside related work
- If Critical priority: warn that it should be addressed soon to prevent blocking

## When to Register Technical Debt

**DO register:**
- Code duplication across 3+ files
- Missing test coverage for critical paths
- Hard-coded values that should be configurable
- Poor naming that obscures intent
- Tight coupling preventing testability
- Performance bottlenecks
- Security anti-patterns

**DON'T register:**
- Nitpicky style preferences
- Premature optimizations
- "I would have done it differently"
- Normal complexity of business logic

## Error Handling
- **Story not found:** Log warning, proceed without link.
- **Invalid priority:** Default to Medium.
- **Backlog locked:** Retry 3 times with 1-second delay.
- **No description:** Require at least the title.
- **Invalid parameters:** Provide parameter template, reject execution.

## Acceptance Criteria
- Technical debt item appears in the Technical Debt section of backlog.md
- Priority sorting is correct
- Tags are displayed properly
- Related story link works (if provided)
- Backlog JSON has type "T" and createdBy "@dev"
- All fields are populated correctly
