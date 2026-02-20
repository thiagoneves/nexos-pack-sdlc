# Spec: {title}

**Story ID:** {epicNum}.{storyNum}
**Generated:** {date}
**Author:** @pm
**Complexity:** {SIMPLE | STANDARD | COMPLEX} (score: {score}/25)
**Pipeline Phases:** {phases_executed}

---

## 1. Overview

### Summary
{1-2 paragraphs: what this spec covers and why}

### Goals
- {goal_1}
- {goal_2}

### Non-Goals
- {non_goal_1}
- {non_goal_2}

---

## 2. Requirements

### Functional Requirements

| ID | Description | Priority | Acceptance Criteria | PRD Trace |
|----|-------------|----------|---------------------|-----------|
| FR-1 | {requirement} | {Must/Should/Could} | {how to verify} | {PRD FR-ID} |
| FR-2 | {requirement} | {Must/Should/Could} | {how to verify} | {PRD FR-ID} |

### Non-Functional Requirements

| ID | Category | Requirement | Target | PRD Trace |
|----|----------|-------------|--------|-----------|
| NFR-1 | {category} | {requirement} | {metric} | {PRD NFR-ID} |

### Constraints
| ID | Description | Source |
|----|-------------|--------|
| CON-1 | {constraint} | {PRD CON-ID or new} |

### Assumptions
- {assumption}

---

## 3. Technical Approach

### Architecture Overview
{How this feature fits into the existing system architecture — reference architecture.md sections}

### Key Decisions

| Decision | Options Considered | Chosen | Rationale |
|----------|-------------------|--------|-----------|
| {decision} | {option_a, option_b} | {chosen} | {why} |

### Patterns to Use
- **{pattern}:** {how it applies to this feature}

### Implementation Strategy
{Step-by-step approach for implementation, ordered by dependency}

1. {step_1}
2. {step_2}
3. {step_3}

---

## 4. Dependencies

### External Dependencies

| Name | Version | Purpose | Verified | Notes |
|------|---------|---------|----------|-------|
| {name} | {version} | {purpose} | {yes/no} | {license, size, etc.} |

### Internal Dependencies
- `{path}`: {purpose} — {will it be modified?}

### Unverified Claims *(optional)*
- {claim} — {reason unverified, who should verify}

---

## 5. Files to Modify/Create

### New Files

| File | Purpose | Estimated Size |
|------|---------|---------------|
| `{path}` | {purpose} | {small/medium/large} |

### Modified Files

| File | Changes | Impact |
|------|---------|--------|
| `{path}` | {what changes} | {low/medium/high} |

### Deleted Files *(optional)*

| File | Reason |
|------|--------|
| `{path}` | {why it's being removed} |

---

## 6. Testing Strategy

### Unit Tests

| Test | Target | Coverage |
|------|--------|----------|
| {test_description} | {function/module} | {what it validates} |

### Integration Tests

| Test | Components | Setup Required |
|------|-----------|----------------|
| {test_description} | {what integrates} | {test doubles, fixtures, etc.} |

### E2E Tests *(optional)*

| Test | User Flow | Prerequisites |
|------|-----------|---------------|
| {test_description} | {user journey} | {environment setup} |

### Manual Verification
- [ ] {verification_step}
- [ ] {verification_step}

---

## 7. Risks & Mitigations

| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| {risk} | {Low/Medium/High} | {Low/Medium/High} | {mitigation} | {who handles} |

---

## 8. Open Questions *(optional)*

| # | Question | Context | Owner | Status |
|---|----------|---------|-------|--------|
| Q1 | {question} | {context} | {who should answer} | {Open/Resolved} |

---

## 9. Traceability Matrix

| Spec Requirement | PRD Source | Architecture Reference | Story AC |
|-----------------|-----------|----------------------|----------|
| FR-1 | PRD FR-{id} | Architecture §{section} | AC-{num} |
| FR-2 | PRD FR-{id} | Architecture §{section} | AC-{num} |

---

## Metadata

```yaml
spec:
  version: "1.0"
  generatedBy: spec-pipeline
  complexity:
    score: {score}
    class: "{SIMPLE | STANDARD | COMPLEX}"
    dimensions:
      scope: {1-5}
      integration: {1-5}
      infrastructure: {1-5}
      knowledge: {1-5}
      risk: {1-5}
inputs:
  requirements: docs/stories/{storyId}/spec/requirements.json
  complexity: docs/stories/{storyId}/spec/complexity.json
  research: docs/stories/{storyId}/spec/research.json
status: "{draft | approved | needs_revision}"
critique_verdict: "{APPROVED | NEEDS_REVISION | BLOCKED}"
```
