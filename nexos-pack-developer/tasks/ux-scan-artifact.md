---
task: ux-scan-artifact
agent: ux-designer
inputs:
  - system-architecture.md (from brownfield phase 1)
  - frontend source code (components, stylesheets, assets, routes)
outputs:
  - frontend-spec.md (comprehensive UX and component inventory)
---

# UX Scan Artifact

## Purpose

Scan the existing frontend codebase to produce a comprehensive UX and component inventory. This is the third phase of brownfield discovery and produces a frontend specification document (`frontend-spec.md`) covering component inventory, design patterns, design token extraction, accessibility assessment, and prioritized UX findings.

The scan follows Atomic Design methodology (atoms, molecules, organisms) to categorize components and identifies design system maturity, pattern redundancy, and build recommendations for design system consolidation.

## Prerequisites

- System architecture document from phase 1 (`system-architecture.md`) is available.
- A frontend layer exists in the project (detected during phase 1).
- Access to frontend source code: components, styles, assets, routes.
- If no frontend is detected, skip this task entirely and proceed to the next phase.

## Steps

### 1. Verify Frontend Existence

Check the architecture document for frontend detection:
- If no frontend was found, skip this task. Inform the user: "No frontend detected. Skipping UX scan."
- If a frontend exists, identify:
  - Framework: React, Vue, Angular, Svelte, vanilla HTML/CSS, etc.
  - Styling approach: Tailwind, CSS Modules, styled-components, SASS, vanilla CSS, etc.
  - Component library: Material UI, Shadcn, Radix, Chakra, Ant Design, Bootstrap, etc.
  - State management: Redux, Zustand, MobX, Pinia, Context API, etc.
  - Routing: Next.js App Router, React Router, Vue Router, etc.

### 2. Inventory Components

Scan the frontend code to catalog all UI components.

#### 2a. Page-Level Components

- List all pages/routes with their file paths.
- Note the routing structure and navigation hierarchy.
- Identify page-level layout patterns (sidebar + content, full-width, dashboard grid).

#### 2b. Shared Components

- Catalog reusable components used in multiple places.
- Record for each: name, file path, usage count, props/API surface.
- Identify component variants (e.g., Button with primary, secondary, outline variants).

#### 2c. One-Off Components

- List components used only once.
- Note which might be candidates for generalization.

#### 2d. Third-Party UI Components

- Identify all third-party UI libraries in use.
- List which components are imported from each library.
- Note if multiple UI libraries are used simultaneously (a finding).

#### 2e. Component Statistics

Compile totals:

| Category | Count |
|----------|-------|
| Pages/routes | {count} |
| Shared components | {count} |
| One-off components | {count} |
| Third-party components | {count} |
| Total unique components | {count} |

### 3. Extract Design Tokens

Analyze stylesheets, theme files, and component styles to extract the design token vocabulary actually in use.

#### 3a. Color Tokens

- Extract all color values from stylesheets and theme config.
- Cluster similar colors (within 5% HSL distance).
- Identify primary, secondary, neutral, accent, and semantic (success, warning, error, info) color groups.
- Count usage frequency for each color.
- Record actual values found, not just theme variable names.

Example output:
```
colors:
  primary:
    - "#3B82F6" (used 42 times)
    - "#2563EB" (used 18 times)
  secondary:
    - "#10B981" (used 23 times)
  neutral:
    - "#F3F4F6" (used 67 times - backgrounds)
    - "#6B7280" (used 45 times - text)
    - "#1F2937" (used 38 times - headings)
```

#### 3b. Typography Tokens

- **Font families:** All typefaces in use, their roles (heading, body, code).
- **Font sizes:** All sizes found, mapped to their usage context.
- **Font weights:** Weights in use (400, 500, 600, 700, etc.).
- **Line heights:** Common line-height values.
- **Letter spacing:** If used, common values.

#### 3c. Spacing Tokens

- Extract all padding, margin, and gap values.
- Normalize to a base unit (typically 4px or 8px).
- Identify the most-used spacing values.
- Note if a consistent spacing scale exists or values are ad-hoc.

#### 3d. Other Tokens

- **Border radius:** All values in use and their frequency.
- **Shadows:** Box-shadow values and their usage context.
- **Breakpoints:** Responsive breakpoint values.
- **Z-index:** Z-index values and their stacking context.
- **Transitions/animations:** Common timing and easing values.

### 4. Classify Components (Atomic Design)

Categorize discovered components into Atomic Design levels:

#### Atoms (fundamental building blocks)

Small, self-contained UI elements that cannot be broken down further:
- Buttons (with all variants)
- Inputs (text, email, password, number, search, etc.)
- Labels, Icons, Badges/Tags, Avatars, Spinners/Loaders, Dividers

For each atom, record: name, variant count, instance count across the app, and style properties.

#### Molecules (simple combinations)

Components composed of 2-3 atoms working together:
- Form fields (label + input + helper text / error)
- Search bars (input + icon + button)
- Cards (border + padding + shadow)
- Navigation items (icon + label + badge)
- Stat displays (label + value + trend indicator)
- Dropdowns (trigger + menu)

For each molecule, record: composition (which atoms), instance count, and common pattern.

#### Organisms (complex sections)

Larger components composed of molecules and/or atoms:
- Headers (logo + navigation + search + profile)
- Forms (multiple fields + validation + submit)
- Data tables (headers + rows + pagination + actions)
- Modals/Dialogs (overlay + header + body + footer)
- Sidebars, List views

For each organism, record: composition, instance count, complexity level (LOW/MEDIUM/HIGH).

### 5. Analyze Design Patterns

#### 5a. Layout Patterns
- Grid systems in use (CSS Grid, Flexbox, framework grid).
- Responsive breakpoints and mobile-first vs. desktop-first approach.
- Container widths and page margin patterns.
- Common layout compositions (sidebar + content, header + body + footer).

#### 5b. Navigation Patterns
- Primary navigation style (sidebar, top nav, bottom nav, hamburger).
- Secondary navigation (breadcrumbs, tabs, step indicators).
- Routing structure depth and complexity.
- Active state and transition patterns.

#### 5c. Form Patterns
- Input styling and validation display approach.
- Form state management (controlled/uncontrolled, form library).
- Error message presentation style.
- Submit button placement and loading states.

#### 5d. Feedback Patterns
- Loading states: skeletons, spinners, progress bars.
- Error states: inline errors, error pages, error boundaries.
- Success feedback: toasts, banners, inline confirmations.
- Empty states: placeholder content, illustrations, CTAs.

#### 5e. Data Display Patterns
- Tables: sorting, filtering, pagination approaches.
- Lists: virtualization, infinite scroll, load-more.
- Cards: grid vs. list layout, information density.
- Detail views: layout, section organization, back navigation.

### 6. Evaluate Design Consistency

Assess the design system maturity level:

| Maturity Level | Description | Indicators |
|---------------|-------------|------------|
| **Ad-hoc** | No system; styles applied per-component | Inconsistent colors, no theme, mixed patterns |
| **Emerging** | Some patterns forming | Theme file exists, some shared components, but inconsistencies |
| **Established** | Clear design system | Consistent tokens, component library, documentation |
| **Mature** | Comprehensive system | Full token set, automated enforcement, versioned components |

Check for consistency across:
- Colors: defined palette vs. ad-hoc hex values?
- Typography: consistent font families, sizes, and weights?
- Spacing: consistent spacing system or arbitrary pixel values?
- Component styling: single consistent approach or mixed?
- Icon usage: single icon library or mixed sources?
- Interactive states: consistent hover, focus, active, disabled patterns?

### 7. Accessibility Audit

Review for WCAG 2.1 AA compliance basics:

| Check | What to Look For | Severity if Failed |
|-------|-----------------|-------------------|
| **Semantic HTML** | Proper headings, landmarks, lists, button vs. div | HIGH |
| **Alt text** | Images have meaningful alt attributes | HIGH |
| **Keyboard navigation** | Interactive elements keyboard-accessible, logical tab order | CRITICAL |
| **Color contrast** | Text meets minimum contrast ratios (4.5:1 normal, 3:1 large) | HIGH |
| **ARIA attributes** | Proper use of aria-label, aria-describedby, roles | MEDIUM |
| **Focus management** | Focus visible indicator, logical focus flow | HIGH |
| **Form labels** | All inputs have associated labels | HIGH |
| **Skip navigation** | Skip-to-content link present | MEDIUM |
| **Responsive text** | Text readable at 200% zoom | MEDIUM |
| **Touch targets** | Interactive elements at least 44x44px on mobile | MEDIUM |

### 8. Calculate Pattern Redundancy

Analyze redundancy across discovered patterns:

For each component type (buttons, inputs, cards, etc.):
- Count total instances across the application.
- Count unique visual variations.
- Determine optimal set (minimum variants to cover all use cases).
- Calculate reduction percentage: `(unique_variations - optimal_set) / unique_variations * 100`.

For design tokens (colors, spacing, typography):
- Count total unique values found.
- Count values after clustering/normalization.
- Calculate reduction percentage.

Example:
```
Pattern: Buttons
  Total instances: 47
  Unique variations: 12
  Optimal set: 3 (primary, secondary, outline)
  Reduction: 75% (12 -> 3)

Pattern: Colors
  Total colors: 89 hex values
  After clustering (5% HSL threshold): 18 distinct
  Optimal token set: 12
  Reduction: 86.5% (89 -> 12)
```

### 9. Produce Frontend Specification

Write `frontend-spec.md` with the following structure:

```markdown
# Frontend Specification -- {Project Name}

## Overview
{Framework, styling approach, and general UX assessment}

## Technology Stack
{Frontend framework, UI library, styling approach, state management, routing}

## Design System Maturity
{Ad-hoc / Emerging / Established / Mature with evidence}

## Design Tokens
### Colors
### Typography
### Spacing
### Other Tokens

## Component Inventory
### Pages ({count})
### Atoms ({count} types, {total} instances)
### Molecules ({count} types, {total} instances)
### Organisms ({count} types, {total} instances)
### Third-Party Components

## Design Patterns
{Layout, navigation, forms, feedback, data display patterns}

## Pattern Redundancy Analysis
{Redundancy calculations per component type and token category}

## Accessibility Assessment
{WCAG 2.1 AA compliance findings by check}

## UX Issues
{Categorized list by severity: CRITICAL, HIGH, MEDIUM, LOW}

## Build Recommendations
### Component Priority Matrix
{HIGH / MEDIUM / LOW priority components to build or consolidate}

### Recommended Build Order
{Phased plan: atoms first, then molecules, then organisms}

## Recommendations
{Prioritized improvements for UX quality and design system maturity}
```

Save to the project's docs directory.

### 10. Handoff

Present the scan summary to the user:
- Component count and breakdown by Atomic Design level.
- Design system maturity assessment.
- Design token summary (number of colors, typography scales, spacing values).
- Redundancy reduction opportunities.
- Top accessibility concerns.
- Top UX issues by severity.
- Suggested next step (e.g., technical debt assessment by architect).

## Token Extraction Algorithms

### Color Clustering (HSL-based, 5% threshold)
1. Extract all hex colors from artifact.
2. Convert to HSL (Hue, Saturation, Lightness).
3. Cluster colors within 5% HSL distance.
4. Select most-used color from each cluster as token.
5. Name tokens by category (primary, secondary, neutral, accent).

### Spacing Normalization (4px base)
1. Extract all px values from padding, margin, gap.
2. Round to nearest 4px multiple.
3. Count frequency of each value.
4. Select top 8 most-used values as tokens.
5. Name tokens: xs, sm, md, lg, xl, 2xl, 3xl.

### Component Similarity Detection
1. Extract element structure (tag + classes + children).
2. Extract styles (computed CSS).
3. Calculate similarity score (0-100%).
4. Group components with >85% similarity.
5. Identify most common variant as base.

## Supported Artifact Types

| Type | Formats | Analysis Method | Speed |
|------|---------|----------------|-------|
| HTML Files | .html, .htm | Parse DOM, extract styles | Fast (< 5s) |
| React Components | .jsx, .tsx | AST parsing, prop extraction | Fast (< 10s) |
| Screenshots | .png, .jpg | Visual pattern recognition (AI vision) | Moderate (10-30s) |
| Live URLs | https://... | Fetch + parse, full DOM analysis | Moderate (15-45s) |

## Limitations

- **HTML/React Files:** Can parse structure and styles, but cannot see rendered visual or detect dynamic behavior.
- **Screenshots:** Can see visual appearance and detect colors/spacing, but cannot extract code structure or identify interactive states.
- **Live URLs:** Can fetch full page HTML and styles, but may be blocked by CORS/auth and cannot access private pages.
- **Code-based scan:** Analyzes source code, not rendered output. Actual contrast ratios, animation behavior, and responsive layout at specific breakpoints may require browser-based tools.

## Error Handling

| Situation | Action |
|-----------|--------|
| **No frontend detected** | Skip entirely. Report skip reason and proceed. |
| **Compiled/minified frontend only** | Note limited analysis. Document what can be inferred from HTML structure and class names. |
| **Multiple frontend apps (microfrontends)** | Scan each separately within the same document. Note shared vs. app-specific components. |
| **Cannot determine UI framework** | Analyze raw HTML/CSS/JS patterns. Note uncertainty in the report. |
| **Very large frontend (100+ components)** | Focus on pages and shared components. Create an appendix for components needing deeper review. |
| **No styling system detected** | Document as a HIGH finding. Recommend establishing a design system. |
| **Mixed styling approaches** | Document all approaches with their prevalence. Flag as a consistency issue. |
| **Third-party library dominates** | Focus on customizations and overrides rather than cataloging the library itself. |
| **Server-rendered HTML only** | Adapt the scan to focus on HTML patterns, CSS analysis, and page structure. |

## Notes

- This task is SKIPPED entirely if no frontend was detected in the architecture phase.
- For projects using a third-party component library extensively (e.g., Shadcn, MUI), focus the inventory on customizations, overrides, and app-specific components.
- The Atomic Design classification is a guideline for organizing the inventory. Some components may not fit neatly into one level -- classify by primary purpose and note dual usage.
- Redundancy analysis provides the data foundation for design system consolidation efforts.
- This document should be updated whenever significant frontend changes occur or a design system initiative begins.
