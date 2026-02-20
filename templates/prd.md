# {project_name} — Product Requirements Document

**Version:** {version}
**Author:** @pm
**Status:** Draft
**Created:** {date}
**Project Brief:** {path_to_brief or "N/A"}

## Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| {date} | 0.1 | Initial draft | @pm |

---

## 1. Goals

- {goal_1}
- {goal_2}
- {goal_3}

## 2. Background Context

{1-2 paragraphs: what problem this solves, why now, current landscape}

---

## 3. Functional Requirements

| ID | Description | Priority | Source |
|----|-------------|----------|--------|
| FR-1 | {requirement} | Must | {brief/interview/discovery} |
| FR-2 | {requirement} | Must | {source} |
| FR-3 | {requirement} | Should | {source} |
| FR-4 | {requirement} | Could | {source} |

## 4. Non-Functional Requirements

| ID | Category | Description | Target |
|----|----------|-------------|--------|
| NFR-1 | Performance | {requirement} | {metric} |
| NFR-2 | Security | {requirement} | {metric} |
| NFR-3 | Scalability | {requirement} | {metric} |

## 5. Constraints

| ID | Description | Rationale |
|----|-------------|-----------|
| CON-1 | {constraint} | {why this limit exists} |
| CON-2 | {constraint} | {rationale} |

---

## 6. User Interface Design Goals *(optional)*

### UX Vision
{high-level interaction model and design philosophy}

### Core Screens
- {screen_1}: {purpose}
- {screen_2}: {purpose}

### Accessibility
{WCAG level or N/A}

### Branding
{known style guides, color palettes, or "TBD"}

### Target Platforms
{Web Responsive | Mobile Only | Desktop Only | Cross-Platform}

---

## 7. Technical Assumptions

### Repository Structure
{Monorepo | Polyrepo} — {rationale}

### Service Architecture
{Monolith | Microservices | Serverless} — {rationale}

### Testing Requirements
{Unit Only | Unit + Integration | Full Testing Pyramid}

### Key Technology Preferences *(optional)*
- {language/framework preference and why}
- {database preference and why}

### Additional Assumptions
- {assumption_1}
- {assumption_2}

---

## 8. Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| {risk} | {Low/Medium/High} | {Low/Medium/High} | {mitigation} |
| {risk} | {probability} | {impact} | {mitigation} |

---

## 9. Epic List

| # | Epic Title | Goal | Stories |
|---|-----------|------|---------|
| 1 | {title} | {one-sentence goal} | {count} |
| 2 | {title} | {one-sentence goal} | {count} |

---

## 10. Epic Details

### Epic {epicNum}: {epicTitle}

**Goal:** {2-3 sentences describing objective and value}

#### Story {epicNum}.1: {storyTitle}

**As a** {role},
**I want** {action},
**so that** {benefit}.

**Acceptance Criteria:**
1. **Given** {context}, **When** {action}, **Then** {expected result}
2. **Given** {context}, **When** {action}, **Then** {expected result}

**Dependencies:** {prerequisite stories or "None"}

#### Story {epicNum}.2: {storyTitle}

**As a** {role},
**I want** {action},
**so that** {benefit}.

**Acceptance Criteria:**
1. **Given** {context}, **When** {action}, **Then** {expected result}
2. **Given** {context}, **When** {action}, **Then** {expected result}

**Dependencies:** {prerequisite stories or "None"}

---

## 11. Review Checklist

| # | Check | Status |
|---|-------|--------|
| 1 | All FRs traceable to a goal | {pass/fail} |
| 2 | All NFRs have measurable targets | {pass/fail} |
| 3 | Epics are logically sequential | {pass/fail} |
| 4 | Stories are vertical slices with clear ACs | {pass/fail} |
| 5 | No cross-cutting concerns left as final stories | {pass/fail} |
| 6 | Dependencies between stories mapped | {pass/fail} |
| 7 | Constraints documented with rationale | {pass/fail} |
| 8 | Risks identified with mitigations | {pass/fail} |

**Reviewer:** {who reviewed}
**Verdict:** {Approved | Needs Revision}
**Notes:** {observations}

---

## 12. Next Steps

### Architect Prompt
{Brief instruction to hand off to @architect for architecture document creation, referencing this PRD}

### UX Prompt *(optional)*
{Brief instruction to hand off to @ux-designer if UI is significant}
