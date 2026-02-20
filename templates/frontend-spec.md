# Frontend Specification

**Project:** {project_name}
**Author:** @ux-designer
**Date:** {date}
**Framework:** {React / Vue / Angular / etc.}
**Context:** {Brownfield Discovery | Standalone Assessment}

---

## 1. Current State Overview

### Technology Stack

| Category | Technology | Version | Notes |
|----------|-----------|---------|-------|
| Framework | {tech} | {ver} | {notes} |
| State Management | {tech} | {ver} | {notes} |
| Styling | {tech} | {ver} | {notes} |
| Routing | {tech} | {ver} | {notes} |
| Build Tool | {tech} | {ver} | {notes} |

### Architecture Pattern
{Component-based / MVC / Atomic Design / etc. — describe the current organization}

---

## 2. Component Inventory

### Page Components

| Component | Route | Responsibility | Complexity |
|-----------|-------|---------------|------------|
| {component} | {/path} | {what it does} | {Simple/Medium/Complex} |

### Shared Components

| Component | Used By | Props | State |
|-----------|---------|-------|-------|
| {component} | {list of consumers} | {key props} | {local/global/none} |

### Component Tree *(optional)*
```
{ASCII diagram showing component hierarchy}
```

---

## 3. Design System Assessment

### Colors & Tokens

| Token | Value | Usage | Consistency |
|-------|-------|-------|-------------|
| {token} | {value} | {where used} | {Consistent/Inconsistent/Missing} |

### Typography

| Level | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| H1 | {font} | {size} | {weight} | {where} |
| Body | {font} | {size} | {weight} | {where} |

### Spacing & Layout
{Grid system, spacing scale, breakpoints}

### Icons & Assets
{Icon library, image optimization, asset management approach}

---

## 4. User Flows

### {flow_name}

```
{Step-by-step flow diagram or description}
{screen_1} → {action} → {screen_2} → {action} → {screen_3}
```

**Happy Path:** {description}
**Error States:** {how errors are handled}
**Edge Cases:** {unusual scenarios}

---

## 5. Accessibility Audit

### Current Status

| Criterion | Standard | Status | Notes |
|-----------|----------|--------|-------|
| Keyboard Navigation | WCAG 2.1 AA | {Pass/Fail/Partial} | {details} |
| Screen Reader | WCAG 2.1 AA | {Pass/Fail/Partial} | {details} |
| Color Contrast | WCAG 2.1 AA | {Pass/Fail/Partial} | {details} |
| Focus Management | WCAG 2.1 AA | {Pass/Fail/Partial} | {details} |
| ARIA Labels | WCAG 2.1 AA | {Pass/Fail/Partial} | {details} |
| Responsive Design | — | {Pass/Fail/Partial} | {details} |

### Critical Issues
- {accessibility issue that must be fixed}

---

## 6. Performance Metrics

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| First Contentful Paint | {seconds} | {target} | {Good/Needs Work/Poor} |
| Largest Contentful Paint | {seconds} | {target} | {status} |
| Cumulative Layout Shift | {score} | < 0.1 | {status} |
| Time to Interactive | {seconds} | {target} | {status} |
| Bundle Size | {KB/MB} | {target} | {status} |

### Performance Issues
- {issue and recommendation}

---

## 7. State Management

### Current Approach
{How state is managed — global store, context, local state, URL state}

### State Map

| State | Location | Scope | Consumers |
|-------|----------|-------|-----------|
| {state_name} | {store/context/local} | {global/page/component} | {who reads/writes} |

### Data Flow
```
{Diagram showing data flow between components and state}
```

---

## 8. API Integration

### Endpoints Consumed

| Endpoint | Method | Component | Caching | Error Handling |
|----------|--------|-----------|---------|---------------|
| {path} | {GET/POST/etc.} | {component} | {strategy} | {approach} |

### Data Fetching Pattern
{REST / GraphQL / tRPC — fetching library, loading states, error boundaries}

---

## 9. Technical Debt

| # | Issue | Severity | Location | Recommendation |
|---|-------|----------|----------|---------------|
| 1 | {issue} | {Critical/High/Medium/Low} | {component/file} | {fix} |

---

## 10. Recommendations

### Immediate Actions
1. {action}

### Improvements
1. {action}

### Future Considerations
1. {action}
