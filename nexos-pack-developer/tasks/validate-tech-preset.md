---
task: validate-tech-preset
agent: architect
inputs:
  - preset_path (optional, string, full path to preset file)
  - name (optional, string, preset name without extension)
  - strict (optional, boolean, treat warnings as errors, default: false)
  - fix (optional, boolean, create story for fixes, default: false)
  - all (optional, boolean, validate all presets in directory, default: false)
outputs:
  - validation_result (object, { valid, errors, warnings, suggestions })
  - report (string, formatted report for display)
  - story_path (string, path to created fix story if --fix and errors found)
---

# Validate Tech Preset

## Purpose
Validate a tech preset file against the required structure and metadata fields. Checks metadata completeness, required section presence, and content quality. Optionally generates a fix story for any issues found.

## Prerequisites
- Tech preset file exists at the specified path or can be resolved by name
- Preset files follow the expected markdown format with YAML metadata blocks

## Steps

### 1. Resolve Preset Path

- If a full path is provided, use it directly
- If a name is provided, resolve to `{data-directory}/tech-presets/{name}.md`
- If `--all` is specified, scan all `.md` files in the presets directory (excluding `_template.md`)

### 2. Parse Preset File

- Extract the YAML metadata block (between YAML fences)
- Parse markdown sections (level 2 headers)
- Build a validation context with all extracted data

### 3. Metadata Validation

Check the YAML metadata block for required fields:

| Field | Required | Validation |
|-------|----------|------------|
| `id` | Yes | kebab-case identifier |
| `name` | Yes | Display name, non-empty |
| `version` | Yes | Semver format (X.Y.Z) |
| `description` | Yes | When to use this preset |
| `technologies` | Yes | Non-empty array of technology names |
| `suitable_for` | Yes | Non-empty array of project types |
| `not_suitable_for` | Warning | Array (recommended but not required) |

### 4. Required Sections Validation

| Section | Required | What to Check |
|---------|----------|---------------|
| Design Patterns | Yes | At least 1 pattern documented |
| Project Structure | Yes | Contains folder structure |
| Tech Stack | Yes | Contains technology table |
| Coding Standards | Yes | Contains naming conventions |
| Testing Strategy | Yes | Contains test approach |
| File Templates | No | Warning if missing |
| Error Handling | No | Warning if missing |
| Performance Guidelines | No | Warning if missing |

### 5. Content Quality Checks

- **Design Patterns:** Must have Purpose, Scores, and Code Example for each pattern
- **Tech Stack:** Table must have Category, Technology, Version, and Purpose columns
- **Coding Standards:** Must include Good/Bad code examples

### 6. Format and Display Results

```
Validating tech preset: {name}.md

Metadata:
  [pass] id: {id}
  [pass] name: {name}
  [pass] version: {version}
  [pass] technologies: [{list}]
  [pass] suitable_for: defined
  [warn] not_suitable_for: missing

Sections:
  [pass] Design Patterns (3 patterns)
  [pass] Project Structure
  [pass] Tech Stack
  [pass] Coding Standards
  [pass] Testing Strategy
  [warn] Error Handling: missing
  [warn] Performance Guidelines: missing

Errors: 0
Warnings: 3

Result: VALID (with warnings)
```

### 7. Fix Story Generation (If Requested)

When `--fix` is used and issues are found:
- Prompt user to confirm story creation
- Generate a story file with:
  - Objective: Fix validation issues in the preset
  - Acceptance criteria generated from errors and warnings
  - Task list with one task per error/warning
  - Reference to the preset file

## Error Handling

| Code | Severity | Description |
|------|----------|-------------|
| `PRESET_NOT_FOUND` | Error | Preset file not found at path |
| `METADATA_MISSING` | Error | No YAML metadata block found |
| `METADATA_PARSE_ERROR` | Error | YAML syntax error in metadata |
| `FIELD_MISSING` | Error | Required metadata field missing |
| `FIELD_INVALID` | Error | Field value invalid (e.g., bad semver) |
| `SECTION_MISSING` | Error | Required section not found |
| `PATTERN_INCOMPLETE` | Error | Design pattern missing required fields |
| `NOT_SUITABLE_MISSING` | Warning | `not_suitable_for` not defined |
| `SECTION_RECOMMENDED` | Warning | Recommended section missing |
| `EXAMPLE_MISSING` | Warning | Good/Bad example missing |

- **Preset not found:** Exit with clear error, list available presets
- **YAML parse error:** Show line number and syntax issue
- **Strict mode:** All warnings are promoted to errors
- **Multiple presets (--all):** Validate each independently, aggregate results
