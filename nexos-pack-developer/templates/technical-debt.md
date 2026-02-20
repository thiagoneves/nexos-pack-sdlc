# Technical Debt Assessment

**Project:** {project_name}
**Author:** @architect
**Date:** {date}
**Context:** Brownfield Discovery
**Reviewed by:** @qa (Phase 7), @data-engineer (Phase 5), @ux-designer (Phase 6)

---

## 1. Executive Summary

{2-3 paragraphs: overall health of the codebase, key findings, priority recommendations}

### Health Score

| Category | Score | Status |
|----------|-------|--------|
| Architecture | {1-5} | {Healthy/Acceptable/Concerning/Critical} |
| Code Quality | {1-5} | {status} |
| Testing | {1-5} | {status} |
| Security | {1-5} | {status} |
| Infrastructure | {1-5} | {status} |
| Documentation | {1-5} | {status} |
| **Overall** | **{average}** | **{status}** |

---

## 2. Architecture Debt

### Current Architecture
{Description of the current system architecture — what exists today}

### Architecture Diagram
```
{ASCII or Mermaid diagram of current architecture}
```

### Issues Found

| # | Issue | Severity | Impact | Effort |
|---|-------|----------|--------|--------|
| A-1 | {architecture issue} | {Critical/High/Medium/Low} | {what it affects} | {S/M/L/XL} |

### Recommendations
- {architecture improvement}

---

## 3. Code Quality Debt

### Metrics

| Metric | Current | Target | Gap |
|--------|---------|--------|-----|
| Code Duplication | {percentage} | < 5% | {gap} |
| Average Function Length | {lines} | < 30 lines | {gap} |
| Cyclomatic Complexity | {average} | < 10 | {gap} |
| Dead Code | {percentage} | 0% | {gap} |

### Issues Found

| # | Issue | Severity | Location | Effort |
|---|-------|----------|----------|--------|
| C-1 | {code quality issue} | {severity} | {file/module} | {effort} |

### Patterns to Address
- {anti-pattern found and how to fix}

---

## 4. Testing Debt

### Current Coverage

| Type | Coverage | Target | Gap |
|------|----------|--------|-----|
| Unit Tests | {percentage} | {target} | {gap} |
| Integration Tests | {percentage} | {target} | {gap} |
| E2E Tests | {percentage} | {target} | {gap} |

### Issues Found

| # | Issue | Severity | Impact |
|---|-------|----------|--------|
| T-1 | {testing issue — missing tests, flaky tests, etc.} | {severity} | {what's at risk} |

### Critical Untested Areas
- {area without test coverage that carries risk}

---

## 5. Security Debt

### Vulnerabilities

| # | Vulnerability | Severity | Category | Remediation |
|---|--------------|----------|----------|-------------|
| S-1 | {vulnerability} | {Critical/High/Medium/Low} | {OWASP category} | {how to fix} |

### Dependency Audit

| Dependency | Current | Latest | Vulnerabilities | Action |
|-----------|---------|--------|----------------|--------|
| {package} | {version} | {latest} | {count/none} | {Update/Replace/Monitor} |

---

## 6. Infrastructure Debt

### Issues Found

| # | Issue | Severity | Impact | Effort |
|---|-------|----------|--------|--------|
| I-1 | {infrastructure issue} | {severity} | {impact} | {effort} |

### CI/CD Assessment
{Current pipeline health, deployment frequency, failure rate}

### Environment Parity
{How similar are dev/staging/production environments}

---

## 7. Database Debt

{Summary from @data-engineer's DB Audit — reference full report}

### Key Findings
- {finding from db-audit.md}

### Critical Actions
- {action from db-audit.md}

**Full Report:** {path to db-audit.md}

---

## 8. Frontend Debt *(if applicable)*

{Summary from @ux-designer's Frontend Spec — reference full report}

### Key Findings
- {finding from frontend-spec.md}

### Critical Actions
- {action from frontend-spec.md}

**Full Report:** {path to frontend-spec.md}

---

## 9. Documentation Debt

| Document | Status | Action |
|----------|--------|--------|
| README | {Missing/Outdated/Current} | {action} |
| API Documentation | {status} | {action} |
| Architecture Docs | {status} | {action} |
| Setup Guide | {status} | {action} |
| Contributing Guide | {status} | {action} |

---

## 10. Prioritized Remediation Roadmap

### Phase 1 — Critical *(immediate)*

| # | Action | Category | Effort | Assigned To |
|---|--------|----------|--------|-------------|
| 1 | {action} | {category} | {effort} | {agent/role} |

### Phase 2 — High *(next sprint)*

| # | Action | Category | Effort | Assigned To |
|---|--------|----------|--------|-------------|
| 1 | {action} | {category} | {effort} | {agent/role} |

### Phase 3 — Medium *(planned)*

| # | Action | Category | Effort | Assigned To |
|---|--------|----------|--------|-------------|
| 1 | {action} | {category} | {effort} | {agent/role} |

### Phase 4 — Low *(backlog)*

| # | Action | Category | Effort |
|---|--------|----------|--------|
| 1 | {action} | {category} | {effort} |

---

## 11. Effort Estimation

| Priority | Items | Total Effort | Recommended Timeline |
|----------|-------|-------------|---------------------|
| Critical | {count} | {person-days} | Immediate |
| High | {count} | {person-days} | 1-2 sprints |
| Medium | {count} | {person-days} | 3-5 sprints |
| Low | {count} | {person-days} | Backlog |
| **Total** | **{count}** | **{person-days}** | — |

---

## Specialist Reviews

| Specialist | Review Date | Verdict | Report |
|-----------|-------------|---------|--------|
| @data-engineer | {date} | {Approved/Concerns} | {path to review} |
| @ux-designer | {date} | {Approved/Concerns} | {path to review} |
| @qa | {date} | {Approved/Needs Work} | {path to review} |
