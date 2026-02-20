---
task: audit-codebase
agent: ux-designer
inputs:
  - scan_path (required, string, path to scan, e.g., ./src, ./app, ./components)
  - framework (optional, string, auto-detected or specified: react|vue|html)
  - output_dir (optional, string, output directory for reports)
  - depth (optional, number, analysis depth 0-3, default: 1)
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - pattern_inventory (object, JSON with all pattern counts and redundancy factors)
  - state_file (object, YAML state for handoff to next task)
  - console_summary (string, key metrics for immediate review)
---

# Audit Codebase for UI Pattern Redundancy

## Purpose
Scan a codebase to detect UI pattern redundancies (buttons, colors, spacing, typography, forms) and quantify technical debt with hard metrics. Produces a structured inventory of all UI patterns with redundancy factors to identify consolidation opportunities.

## Prerequisites
- Codebase with UI code (React, Vue, HTML, or vanilla CSS)
- Shell access with standard utilities available
- Read access to the scan path

## Steps

### 1. Gather Scan Parameters

- Ask for scan path (e.g., `./src`, `./app`, `./components`)
- Detect frameworks automatically or ask for confirmation
- Confirm output directory
- Count total files to scan
- Estimate scan time (~2 min per 100k lines of code)
- Show scan plan summary and ask for confirmation

### 2. Validate Environment

- Check scan path exists and is readable
- Verify read permissions
- Create output directory structure
- Confirm at least one UI file type is found

### 3. Detect Frameworks

- Count React/JSX files (`.jsx`, `.tsx`)
- Count Vue files (`.vue`)
- Count HTML files (`.html`)
- Count CSS files (`.css`, `.scss`, `.sass`)

### 4. Scan Button Patterns

- Detect button elements (`<button`, `<Button`, `className="btn"`)
- Count total button instances across all files
- Extract unique button class names and patterns
- Calculate redundancy factor: total instances / unique patterns

### 5. Scan Color Usage

- Extract hex colors (`#RGB`, `#RRGGBB`)
- Extract `rgb()`/`rgba()` colors
- Count unique color values
- Count total color usage instances
- Identify top 10 most-used colors
- Calculate redundancy factor

### 6. Scan Spacing Patterns

- Extract padding values (`padding: Npx`)
- Extract margin values (`margin: Npx`)
- Count unique spacing values
- Identify most common patterns

### 7. Scan Typography

- Extract `font-family` declarations
- Extract `font-size` values
- Extract `font-weight` values
- Count unique typography patterns

### 8. Scan Form Patterns

- Count input elements and unique input class patterns
- Count form elements and unique form patterns

### 9. Generate Inventory Report

Create `pattern-inventory.json` with all metrics:

```json
{
  "scan_metadata": {
    "timestamp": "...",
    "scan_path": "./src",
    "total_files": 487,
    "frameworks_detected": {
      "react": true,
      "vue": false,
      "html": false
    }
  },
  "patterns": {
    "buttons": {
      "unique_patterns": 47,
      "total_instances": 327,
      "redundancy_factor": 6.96
    },
    "colors": {
      "unique_hex": 82,
      "unique_rgb": 7,
      "total_unique": 89,
      "total_instances": 1247,
      "redundancy_factor": 14.01
    },
    "spacing": {
      "unique_padding": 19,
      "unique_margin": 15
    },
    "typography": {
      "unique_font_families": 4,
      "unique_font_sizes": 15,
      "unique_font_weights": 6
    },
    "forms": {
      "input_instances": 189,
      "unique_input_patterns": 23,
      "form_instances": 45,
      "unique_form_patterns": 12
    }
  }
}
```

### 10. Create State File

Generate a `.state.yaml` for handoff to the next task (consolidation or tokenization):
- Record all pattern counts and metrics
- Log scan history
- Set phase to "audit_complete"

### 11. Display Console Summary

```
Files found:
  - React/JSX: 234
  - CSS/SCSS: 89
  - TOTAL: 323

BUTTONS:
  - Total instances: 327
  - Unique patterns: 47
  - Redundancy factor: 7.0x

COLORS:
  - Unique hex values: 82
  - Total usage instances: 1247
  - Redundancy factor: 15.2x

Inventory saved: {output_dir}/pattern-inventory.json
State saved: {output_dir}/.state.yaml
```

## Error Handling
- **Scan path does not exist:** Exit with clear error, suggest valid paths
- **No UI files found:** Warn user, suggest checking the path or file types
- **Permission denied:** Explain which directory needs read access
- **Partial scan failure:** Log which files failed, continue with remaining files, report incomplete data in summary
- **Large codebase timeout:** Return partial results, note which areas were not scanned

## Interpretation Guidelines
- Redundancy factor > 3x indicates significant technical debt
- Colors > 50 unique values = major consolidation opportunity
- Buttons > 20 variations = serious pattern explosion
- Run this audit periodically to prevent pattern regression

## Security Considerations
- Read-only access to codebase (no writes during scan)
- No code execution during pattern detection
- Validate file paths to prevent directory traversal
- Handle malformed files gracefully (invalid CSS/JSX)
- Skip binary files and large non-text files
