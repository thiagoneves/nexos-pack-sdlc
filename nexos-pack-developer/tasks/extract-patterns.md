---
task: extract-patterns
agent: analyst
inputs:
  - subcommand (optional, string, extract|json|save|merge, default: extract)
  - root (optional, string, project root path, default: ".")
  - output (optional, string, custom output file path)
  - category (optional, string, extract only a specific category)
  - quiet (optional, boolean, suppress console output, default: false)
outputs:
  - patterns_markdown (string, generated patterns file at .aios/patterns.md)
  - patterns_json (object, JSON representation of detected patterns)
  - summary (object, pattern count summary by category)
---

# Extract Patterns

## Purpose
Analyze the codebase to detect and document common code patterns used in the project. Generates a `patterns.md` file that serves as a reference for maintaining consistency when implementing new features. Supports multiple output formats (Markdown, JSON) and incremental updates through the merge command.

## Prerequisites
- Project root is a valid codebase (contains `package.json` or similar project manifest)
- At least one code file exists (`.ts`, `.tsx`, `.js`, `.jsx`)
- Read access to the project directory

## Steps

### 1. Check Help Flag
If `--help` is passed, display usage documentation and exit.

### 2. Initialize Pattern Extractor
Set up the pattern extractor with the specified project root path. Configure excluded directories (`node_modules`, `.git`, `dist`, `build`).

### 3. Detect Patterns

Scan the codebase for patterns across these categories:

| Category | What to Detect |
|----------|---------------|
| State Management | Zustand stores, Redux slices, React Context |
| API Calls | SWR hooks, fetch wrappers, React Query |
| Error Handling | try-catch patterns, ErrorBoundary components, toast notifications |
| Components | Memoized components, compound components, conditional class utilities |
| Hooks | Custom hooks, useEffect cleanup patterns |
| Data Access | Prisma queries, fs.promises usage |
| Testing | Jest/Vitest structure, mock patterns |
| Utilities | Class-based utilities, functional helpers |

For each detected pattern, capture:
- Pattern name and description
- When to use it
- Code example from the actual codebase
- Files using this pattern
- Confidence score

### 4. Execute Subcommand

**extract** (default): Generate Markdown output
- If `--output` provided, write to specified file
- Otherwise, output to console

**json**: Generate JSON output
- Structured format with categories, patterns, metadata
- If `--output` provided, write to file

**save**: Save to default location (`.aios/patterns.md`)

**merge**: Merge newly detected patterns with existing patterns file
- Preserve manually added annotations
- Update pattern counts and file references
- Add newly detected patterns

### 5. Display Summary

```text
Scanning patterns in: /path/to/project
Patterns saved to: .aios/patterns.md

Total patterns detected: 12
  State Management: 3
  API Calls: 2
  Error Handling: 2
  Components: 2
  Hooks: 1
  Data Access: 1
  Testing: 1
```

## Error Handling
- **Project root not found:** Exit with message to use `--root` to specify correct path
- **No code files found:** Exit with message to ensure project has code files
- **Permission denied:** Log error, suggest checking directory permissions
- **Invalid category name:** Show available categories from help text
- **Merge conflict with existing patterns:** Preserve existing, append new patterns with review markers

## Output Formats

### Markdown Format
```markdown
# Project Patterns

> Auto-generated from codebase analysis
> Last updated: {timestamp}

## State Management

### Zustand Store with Persist

\`\`\`typescript
// Example from actual codebase
\`\`\`

**When to use:** Any domain state that needs persistence across sessions.
**Files using this pattern:** authStore.ts, userStore.ts
```

### JSON Format
```json
{
  "generated": "{timestamp}",
  "rootPath": "/path/to/project",
  "totalPatterns": 12,
  "categories": {
    "State Management": [
      {
        "name": "Zustand Store with Persist",
        "description": "...",
        "whenToUse": "...",
        "example": "...",
        "filesUsing": ["store.ts"],
        "confidence": 0.95
      }
    ]
  }
}
```
