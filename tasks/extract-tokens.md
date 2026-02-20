---
task: extract-tokens
agent: ux-designer
inputs:
  - consolidation_state (optional, string, path to .state.yaml with consolidation data)
  - export_formats (optional, array, yaml|json|css|tailwind|scss|dtcg|all, default: all)
  - output_dir (optional, string, output directory for token files)
  - naming_convention (optional, string, kebab-case|camelCase, default: kebab-case)
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - tokens_yaml (string, path to tokens.yaml source of truth)
  - tokens_dtcg (string, path to W3C DTCG-compliant JSON)
  - tokens_json (string, path to JavaScript/TypeScript import format)
  - tokens_css (string, path to CSS custom properties file)
  - tokens_tailwind (string, path to Tailwind v4 config)
  - tokens_scss (string, path to SCSS variables file)
  - coverage_report (string, path to coverage analysis report)
---

# Extract Design Tokens

## Purpose
Generate a design token system from consolidated UI patterns. Produces a 3-layer token architecture (core primitives, semantic aliases, component mappings) with OKLCH color values, W3C DTCG-compliant JSON, and companion exports (YAML, JSON, CSS custom properties, Tailwind config, SCSS variables).

## Prerequisites
- Consolidation phase completed (previous audit/consolidation task run successfully)
- State file (`.state.yaml`) contains consolidation data
- Consolidated pattern files exist (color clusters, spacing, typography, button patterns)

## Steps

### 1. Review Consolidation Results

- Display consolidation summary (colors, buttons, spacing, typography)
- Confirm token generation from these patterns
- Ask for naming preferences (kebab-case default)

### 2. Select Export Formats

- Ask which formats to export (YAML, JSON, CSS, Tailwind, SCSS, DTCG JSON, or all)
- Confirm output directory
- Check for existing token files (warn before overwriting)

### 3. Load Consolidation Data

- Read `.state.yaml` consolidation section
- Load consolidated pattern files (color clusters, spacing, typography, buttons)
- Validate that consolidation phase was completed

### 4. Extract Color Tokens

- Read color cluster data
- Generate semantic names (primary, primary-dark, error, success, etc.)
- Detect relationships (hover states, light/dark variants)
- Express colors in OKLCH format with hex fallbacks
- Create 3-layer color token structure

### 5. Extract Spacing Tokens

- Read spacing consolidation data
- Map spacing values to semantic scale: xs, sm, md, lg, xl, 2xl, 3xl
- Generate both padding and margin token sets
- Establish base unit (e.g., 4px)

### 6. Extract Typography Tokens

- Read typography consolidation data
- Create font-family tokens
- Create font-size tokens with semantic names
- Create font-weight tokens
- Calculate and create line-height tokens from sizes

### 7. Extract Button Tokens

- Read button consolidation data
- Generate button variant tokens (primary, secondary, destructive)
- Generate button size tokens (sm, md, lg)
- Map references to color and spacing tokens

### 8. Generate tokens.yaml (Source of Truth)

Create the master YAML file with:
- Metadata: version, generation timestamp, DTCG spec version, color space
- 3 layers:
  - **core**: Primitive values (raw colors, spacing units, font sizes)
  - **semantic**: Aliases with meaning (primary, background, foreground)
  - **component**: Component-specific mappings (button.primary.background)

```yaml
metadata:
  version: "1.0.0"
  dtcg_spec: "2025.10"
  color_space: "oklch"

layers:
  core:
    color:
      neutral-50:
        "$value": "oklch(0.97 0.01 235)"
      accent-primary:
        "$value": "oklch(0.59 0.19 238)"
    spacing:
      base-unit:
        "$value": "4px"
      md:
        "$value": "16px"
  semantic:
    color:
      primary:
        "$value": "{layers.core.color.accent-primary}"
      background:
        "$value": "{layers.core.color.neutral-50}"
  component:
    button:
      primary:
        background:
          "$value": "{layers.semantic.color.primary}"
```

### 9. Export to W3C DTCG JSON

- Convert YAML layers to `tokens.dtcg.json`
- Inject `$type`, `$value`, `$description`, and reference syntax
- Validate against W3C DTCG specification

### 10. Export to JSON

- Convert tokens to flat JSON for JavaScript/TypeScript imports
- Provide both nested and flattened structures

### 11. Export to CSS Custom Properties

- Generate `tokens.css` with `:root` and `[data-theme="dark"]` scopes
- Map semantic tokens to CSS variables (`--color-primary`, `--space-md`)

### 12. Export to Tailwind Config

- Generate `tokens.tailwind.js` with Tailwind v4 compatible structure
- Map tokens to `@theme` variables

### 13. Export to SCSS Variables

- Generate `tokens.scss` with `$token-name` variables
- Include comments for component usage

### 14. Validate Token Coverage

- Calculate how many original patterns are covered by tokens
- Target: >95% coverage with dark mode parity
- Report any gaps with remediation suggestions

### 15. Update State File

- Add tokens section to `.state.yaml`
- Record token counts, export formats, validator results, coverage metrics
- Update phase to "tokenize_complete"

## Error Handling
- **No consolidation data:** Exit with message to run the consolidation step first
- **Invalid consolidated patterns:** Log which patterns failed, continue with valid ones
- **Export format error:** Validate syntax for each format, report errors, fix or skip
- **Low coverage (<95%):** Warn user, suggest additional consolidation passes
- **DTCG validation failed:** Provide validator output, attempt to regenerate with fixed references
- **Missing OKLCH support:** Document browser constraints, include hex fallbacks

## Output Summary

| File | Description |
|------|-------------|
| `tokens.yaml` | Layered source of truth (core / semantic / component) |
| `tokens.dtcg.json` | W3C Design Tokens export |
| `tokens.json` | JavaScript/TypeScript import format |
| `tokens.css` | CSS custom properties (light + dark) |
| `tokens.tailwind.js` | Tailwind v4 @theme helper |
| `tokens.scss` | SCSS variables format |
| `token-coverage-report.txt` | Coverage analysis |

## Guidelines
- `tokens.yaml` is the single source of truth -- all exports are generated from it
- Prefer semantic naming over descriptive naming (use "primary" not "blue-500")
- Hover states are auto-detected by "-dark" or "-hover" suffixes
- Coverage below 95% means some patterns were not consolidated
- All export formats stay in sync -- update `tokens.yaml` and regenerate all
