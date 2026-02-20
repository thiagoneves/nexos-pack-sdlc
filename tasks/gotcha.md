---
task: gotcha
agent: dev
workflow: knowledge-management
inputs:
  - title (string, required) - Short title for the gotcha
  - description (string, optional) - Detailed description (provided after " - " separator)
  - category (enum, optional) - build | test | lint | runtime | integration | security, default auto-detect
  - severity (enum, optional) - info | warning | critical, default "warning"
  - workaround (string, optional) - Solution or workaround text
  - files (array, optional) - Comma-separated list of related files
outputs:
  - gotcha_entry (object) - Created gotcha with ID, title, category, severity
  - gotchas_file (file) - Updated gotchas.json and gotchas.md
---

# Add Gotcha

## Purpose
Add a gotcha (known issue or workaround) manually to the project's gotchas memory so it can be surfaced when working on related tasks.

## Prerequisites
- Gotchas memory storage is accessible (gotchas.json, gotchas.md)
- Title is not empty

## Steps

### 1. Parse Input
1. Extract the title from the input
2. Extract the description if provided (text after " - " separator)
3. Parse any flags: `--category`, `--severity`, `--workaround`, `--files`
4. Validate that the title is not empty

### 2. Auto-detect Category
If category is not provided, analyze the title and description for keywords:

| Category | Keywords |
|----------|----------|
| build | build, compile, webpack, vite, bundle, tsc |
| test | test, jest, vitest, mock, coverage |
| lint | lint, eslint, prettier, stylelint |
| runtime | TypeError, null, undefined, crash, error |
| integration | api, http, fetch, database, cors, postgres |
| security | xss, csrf, auth, injection, token |

### 3. Create Gotcha Entry
Create the gotcha using the gotchas memory system:
```json
{
  "title": "parsed title",
  "description": "parsed description",
  "category": "detected or provided category",
  "severity": "provided or default warning",
  "workaround": "provided or null",
  "relatedFiles": ["provided files or empty array"]
}
```

### 4. Confirm Creation
Display confirmation with:
- Gotcha ID
- Title
- Category (note if auto-detected)
- Severity
- Message: "This gotcha will be shown when working on related tasks."

## Usage Examples

```bash
# Simple - title only
*gotcha Always check fetch response.ok

# With description
*gotcha Zustand persist needs type annotation - Without explicit type, TypeScript cannot infer store type

# With all options
*gotcha Protected files need full read --category build --severity critical --workaround "Read without limit/offset"

# With related files
*gotcha API endpoint CORS issue --files "src/api/client.ts,src/lib/fetch.ts"
```

## Error Handling
- **Empty title:** Reject and prompt for a title.
- **Invalid category:** Fall back to auto-detection.
- **Invalid severity:** Default to "warning".
- **Storage write failure:** Retry, then report error with details.

## Related Tasks
- `gotchas` - List all gotchas
- `gotcha-context` - Get relevant gotchas for current task

## Acceptance Criteria
- Gotcha is persisted in gotchas.json and gotchas.md
- Auto-detection correctly categorizes common keywords
- Gotcha ID is returned for reference
- Gotcha is surfaced in future related task contexts
