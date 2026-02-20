---
task: qa-library-validation
agent: qa
workflow: story-development-cycle (qa-gate, phase 6.0)
inputs:
  - story_id (required, format: "{epic}.{story}")
  - file_paths (optional, array - defaults to git diff)
  - skip_stdlib (optional, boolean, default: true)
outputs:
  - validation_report (object with library check results)
  - issues_found (number)
  - report_file (file: docs/stories/{story-id}/qa/library_validation.json)
---

# Library Validation

## Purpose
Validate third-party library usage against official documentation using Context7. Extracts imports from modified source files, resolves library identifiers, validates API usage for correctness, and flags deprecated methods or incorrect signatures.

## Prerequisites
- Context7 MCP is available (test with resolve-library-id query)
- Modified files exist (from git diff or explicit file list)
- At least one file to analyze

## Steps

### 1. Extract Imports
Get list of modified files:
```bash
git diff --name-only HEAD~1
# Or use provided --files list
```

For each file, extract imports using regex patterns:

**JavaScript/TypeScript:**
```
import ... from 'package-name'
require('package-name')
```

**Python:**
```
import package_name
from package_name import ...
```

Filter out:
- Relative imports (`./`, `../`)
- Standard library (unless `--include-stdlib` is set)
- Already validated in this session

### 2. Resolve Library IDs
For each unique library:
1. Call Context7 to resolve the library ID
2. Store the mapping (e.g., `"react-query"` -> `"/tanstack/react-query"`)
3. Log unresolved libraries for manual review

### 3. Validate API Usage
For each import usage in code:
1. Query Context7 for documentation of the specific API being used
2. Validate against actual usage:
   - **Signatures:** Function parameters match documentation
   - **Types:** Return types handled correctly
   - **Deprecated:** Check for deprecated API warnings
   - **Breaking Changes:** Check version-specific changes
3. Flag issues with severity, details, and suggested fix

### 4. Generate Report
Create validation report as JSON:

```json
{
  "timestamp": "...",
  "story_id": "...",
  "summary": {
    "libraries_checked": 12,
    "issues_found": 3,
    "unresolved": 1,
    "passed": 8
  },
  "issues": [...],
  "unresolved_libraries": [...],
  "recommendations": [...]
}
```

Save to `docs/stories/{story-id}/qa/library_validation.json`.

## Validation Checklist
For each library, validate:

**Signatures:**
- Function parameters match documentation
- Optional vs required parameters correct
- Default values understood

**Types:**
- Return types handled correctly
- Generic type parameters correct
- Null/undefined handling

**Lifecycle:**
- Initialization/setup correct
- Cleanup/disposal handled
- Async patterns correct

**Deprecation:**
- No deprecated APIs used
- Migration path available if deprecated

**Version:**
- API matches installed version
- Breaking changes addressed

## Issue Severity Mapping

| Issue Type | Severity | Action |
|---|---|---|
| Incorrect API signature | CRITICAL | Must fix |
| Deprecated API (removed in next major) | CRITICAL | Must fix |
| Deprecated API (still works) | MAJOR | Should fix |
| Suboptimal pattern | MINOR | Optional |
| Missing error handling | MAJOR | Should fix |
| Type mismatch | CRITICAL | Must fix |
| Version incompatibility | CRITICAL | Must fix |

## Command
```
*validate-libraries {story-id} [--files file1,file2] [--include-stdlib]
```

**Trigger:** Automatically called during `*review-build` (Phase 6.0).
**Manual:** Can be run standalone via `*validate-libraries`.

## Error Handling
- **Library Not Found in Context7:** Log as "unvalidated" and continue; recommend manual review
- **Context7 Rate Limit:** Batch requests and add delay; retry with exponential backoff
- **Import Parse Failure:** Log and skip; recommend manual inspection

## Exit Criteria
- All imports extracted from modified files
- Each library resolved via Context7 (or marked unresolved)
- API usage validated against documentation
- Deprecated methods flagged
- Report generated and saved
- Issues integrated into QA review
