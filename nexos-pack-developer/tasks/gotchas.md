---
task: gotchas
agent: dev
workflow: knowledge-management
inputs:
  - category (enum, optional) - Filter by: build | test | lint | runtime | integration | security
  - severity (enum, optional) - Filter by: info | warning | critical
  - unresolved (boolean, optional) - Show only unresolved gotchas, default false
  - stats (boolean, optional) - Show statistics only, default false
  - query (string, optional) - Search gotchas by keyword
outputs:
  - gotchas_list (array) - Filtered list of gotchas
  - statistics (object, optional) - Gotcha statistics if --stats flag used
---

# List Gotchas

## Purpose
List and search known gotchas (issues and workarounds) from the project's gotchas memory to help developers avoid known pitfalls.

## Prerequisites
- Gotchas memory storage is accessible (gotchas.json)

## Steps

### 1. Load Gotchas
Load all gotchas from the gotchas.json file via the gotchas memory system.

### 2. Apply Filters
Apply filters based on provided options:
- If `--category` is set: filter by the specified category
- If `--severity` is set: filter by the specified severity level
- If `--unresolved` is set: exclude resolved gotchas
- If `search {query}` is provided: filter by keyword match across title, description, and tags

### 3. Display Results

**Default list view** - For each gotcha show:
- `[SEVERITY]` Title
- Category
- Description (truncated if long)
- Workaround (if exists)
- Related files (if any)
- Status (resolved/unresolved)
- Footer with totals: Total | Critical | Warning | Info

**Statistics view** (`--stats`) - Show:
- Total count, unresolved count, resolved count
- Breakdown by category (build, test, lint, runtime, integration, security)
- Breakdown by severity (critical, warning, info)
- Breakdown by source (manual, auto_detected)

## Categories Reference

| Category | Description | Keywords |
|----------|-------------|----------|
| build | Build/compile issues | webpack, vite, tsc, bundle |
| test | Testing issues | jest, vitest, mock, coverage |
| lint | Linting/formatting | eslint, prettier, stylelint |
| runtime | Runtime errors | TypeError, null, undefined |
| integration | API/DB issues | fetch, cors, postgres, prisma |
| security | Security issues | xss, csrf, auth, injection |

## Usage Examples

```bash
# List all gotchas
*gotchas

# Filter by category
*gotchas --category build

# Filter by severity
*gotchas --severity critical

# Show only unresolved
*gotchas --unresolved

# Show statistics
*gotchas --stats

# Search by keyword
*gotchas search fetch
```

## Error Handling
- **No gotchas found:** Display message that no gotchas match the current filters.
- **Invalid category:** Show list of valid categories.
- **Invalid severity:** Show list of valid severity levels.
- **Storage read failure:** Report error with details.

## Related Tasks
- `gotcha` - Add a new gotcha
- `gotcha-context` - Get relevant gotchas for current task

## Acceptance Criteria
- All gotchas are loaded and displayed correctly
- Filters work independently and in combination
- Statistics accurately reflect the gotchas data
- Search matches against title, description, and tags
- Output is well-formatted and readable
