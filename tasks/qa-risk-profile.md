---
task: qa-risk-profile
agent: qa
workflow: story-development-cycle (pre-implementation or testing phase)
inputs: [story file, implementation code (optional), PRD/epic context]
outputs: [risk profile report, gate YAML block, risk-based test recommendations]
---

# Risk Profile

## Purpose

Generate a comprehensive risk assessment for a story implementation using a structured probability-times-impact framework. This task identifies, classifies, and prioritizes risks across six categories (technical, security, performance, data, business, operational), provides mitigation strategies for each risk, and produces risk-based testing recommendations. The output feeds directly into test design prioritization and quality gate decisions.

## Prerequisites

- Story file exists with acceptance criteria and scope defined.
- Story is in `Ready`, `InProgress`, or `InReview` status.
- Access to the PRD or epic context for business understanding.
- Implementation code is available if the story is already in progress (enables deeper technical risk analysis).

## Steps

### 1. Gather Risk Context

Read the story file and supporting documents to understand the risk landscape:

- **Story scope:** What is being built, changed, or modified.
- **Affected components:** Which parts of the system are touched.
- **Dependencies:** External services, libraries, APIs, databases involved.
- **User impact:** Who is affected and how (end users, admins, integrations).
- **Data handling:** What data is processed, stored, or transmitted.
- **Deployment context:** How the change will be deployed and to which environments.
- **Historical context:** Previous issues with similar components or features (from prior QA reports if available).

### 2. Identify Risks by Category

Systematically assess each risk category. For each category, evaluate whether the story introduces, increases, or is exposed to risks.

**Category Prefixes for Risk IDs:**

- `TECH`: Technical Risks
- `SEC`: Security Risks
- `PERF`: Performance Risks
- `DATA`: Data Risks
- `BUS`: Business Risks
- `OPS`: Operational Risks

#### Technical Risks (TECH)
Evaluate:
- Architecture complexity introduced or modified.
- Integration challenges with existing components.
- Technical debt created or exposed.
- Scalability implications.
- System dependency brittleness.
- New technology or unfamiliar patterns.

#### Security Risks (SEC)
Evaluate:
- Authentication and authorization changes.
- Data exposure and privacy implications.
- Injection attack surfaces (SQL, XSS, command).
- Session management changes.
- Cryptographic usage.
- Input validation requirements.
- Third-party dependency vulnerabilities.

#### Performance Risks (PERF)
Evaluate:
- Response time impact on existing flows.
- Throughput and concurrency implications.
- Resource consumption (memory, CPU, disk, network).
- Database query efficiency.
- Caching effectiveness.
- Payload sizes and data transfer volumes.

#### Data Risks (DATA)
Evaluate:
- Data loss potential during operations.
- Data corruption scenarios.
- Privacy and PII handling.
- Compliance requirements (GDPR, HIPAA, SOC2, etc.).
- Backup and recovery implications.
- Data migration or transformation risks.

#### Business Risks (BUS)
Evaluate:
- Feature-market fit and user expectation alignment.
- Revenue and conversion impact.
- Reputation and trust implications.
- Regulatory and legal compliance.
- Competitive and market timing factors.

#### Operational Risks (OPS)
Evaluate:
- Deployment complexity and rollback readiness.
- Monitoring and observability gaps.
- Incident response preparedness.
- Documentation and knowledge transfer needs.
- On-call and support implications.

### 3. Score Each Risk

For each identified risk, assign probability and impact scores:

**Probability Levels:**

| Level | Score | Description |
|-------|-------|-------------|
| High | 3 | Likely to occur (>70% chance based on evidence) |
| Medium | 2 | Possible occurrence (30-70% chance) |
| Low | 1 | Unlikely to occur (<30% chance) |

**Impact Levels:**

| Level | Score | Description |
|-------|-------|-------------|
| High | 3 | Severe: data breach, system outage, major financial loss, regulatory violation |
| Medium | 2 | Moderate: degraded performance, minor data issues, user friction |
| Low | 1 | Minor: cosmetic issues, slight inconvenience, internal-only impact |

**Risk Score = Probability x Impact**

| Score | Classification | Color | Action |
|-------|---------------|-------|--------|
| 9 | Critical | Red | Must mitigate before deployment |
| 6 | High | Orange | Should mitigate before deployment |
| 3-4 | Medium | Yellow | Mitigate or accept with monitoring |
| 1-2 | Low | Green | Accept with documentation |

Document each risk:

```yaml
risk:
  id: "{CATEGORY}-{SEQ}"  # e.g., "SEC-001", "PERF-002"
  category: "{category}"
  title: "{short description}"
  description: "{detailed description with evidence}"
  affected_components:
    - "{component or file}"
  probability: "{High (3) | Medium (2) | Low (1)}"
  impact: "{High (3) | Medium (2) | Low (1)}"
  score: {number}
  classification: "{Critical | High | Medium | Low}"
  detection_method: "{How this risk was identified}"
```

### 4. Define Mitigation Strategies

For each risk with score >= 3, provide a mitigation strategy:

```yaml
mitigation:
  risk_id: "{RISK-ID}"
  strategy: "preventive | detective | corrective"
  actions:
    - "{Specific action 1}"
    - "{Specific action 2}"
  testing_requirements:
    - "{Specific test scenario needed}"
  residual_risk: "{Risk remaining after mitigation}"
  owner: "{dev | qa | architect | devops | pm}"
  timeline: "{Before implementation | During implementation | Before deployment | Post-deployment}"
```

**Mitigation strategy types:**
- **Preventive:** Eliminates or reduces the probability of the risk occurring. (e.g., input validation prevents injection attacks.)
- **Detective:** Does not prevent the risk but enables early detection. (e.g., monitoring alerts for performance degradation.)
- **Corrective:** Enables recovery after the risk materializes. (e.g., rollback procedures for failed deployments.)

### 5. Calculate Overall Story Risk Score

Compute the aggregate risk score for the story:

```
Base Score = 100
For each risk:
  - Critical (9): Deduct 20 points
  - High (6): Deduct 10 points
  - Medium (3-4): Deduct 5 points
  - Low (1-2): Deduct 2 points

Final Score = max(0, Base Score - deductions)
```

| Score Range | Assessment |
|-------------|-----------|
| 80-100 | Low risk -- Standard development practices sufficient |
| 60-79 | Moderate risk -- Additional review and testing recommended |
| 40-59 | High risk -- Enhanced testing, phased rollout recommended |
| 0-39 | Critical risk -- Architecture review, comprehensive testing, staged deployment required |

### 6. Generate Risk-Based Test Recommendations

For each risk, recommend specific test approaches:

**Critical risks (score 9):**
- Mandatory dedicated test scenarios.
- Recommend both unit and integration tests covering the risk.
- Include in P0 test priority.
- Consider security testing or load testing if applicable.

**High risks (score 6):**
- Recommended dedicated test scenarios.
- Include in P0 or P1 test priority.
- Integration test at minimum.

**Medium risks (score 3-4):**
- Consider test scenarios if effort is low.
- Include in P2 test priority.
- Unit test coverage may be sufficient.

**Low risks (score 1-2):**
- Document for awareness.
- Standard test coverage is sufficient.
- No dedicated test scenarios needed.

### 7. Produce Risk Profile Report

Generate the full report following the output format below.

## Output Format

### Output 1: Risk Profile Report

Save to: `{qa-location}/assessments/{story-id}-risk-{YYYYMMDD}.md`

```markdown
# Risk Profile: Story {story-id}

Date: {date}
Assessor: @qa

## Executive Summary

- Total Risks Identified: {count}
- Critical: {count}
- High: {count}
- Medium: {count}
- Low: {count}
- Overall Risk Score: {score}/100

## Risk Matrix

| Risk ID | Category | Title | Probability | Impact | Score | Classification |
|---------|----------|-------|-------------|--------|-------|---------------|
| {id} | {category} | {title} | {prob} | {impact} | {score} | {class} |

## Critical Risks Requiring Immediate Attention

### {RISK-ID}: {Title}

**Score: {score} (Critical)**
**Probability:** {level} -- {reasoning}
**Impact:** {level} -- {potential consequences}

**Mitigation:**
- {action 1}
- {action 2}

**Testing Focus:** {specific test scenarios needed}

## Risk Distribution

### By Category
- Technical: {count} risks ({critical-count} critical)
- Security: {count} risks ({critical-count} critical)
- Performance: {count} risks ({critical-count} critical)
- Data: {count} risks ({critical-count} critical)
- Business: {count} risks ({critical-count} critical)
- Operational: {count} risks ({critical-count} critical)

### By Affected Component
- {Component 1}: {count} risks
- {Component 2}: {count} risks

## Detailed Risk Register

[Full table of all risks with descriptions, scores, and mitigations]

## Risk-Based Testing Strategy

### Priority 1: Critical Risk Tests
{Test scenarios for critical risks}

### Priority 2: High Risk Tests
{Integration test scenarios and edge case coverage}

### Priority 3: Medium/Low Risk Tests
{Standard functional tests and regression suite}

## Deployment Recommendations

- {Phased rollout if high risk}
- {Feature flags for risky features}
- {Rollback procedures}
- {Monitoring setup}

## Risk Acceptance

### Must Fix Before Production
- All critical risks (score 9)
- High risks affecting security or data integrity

### Deploy with Mitigation
- Medium risks with compensating controls
- Low risks with monitoring in place

### Accepted Risks
- {Any risks the team accepts with justification}

## Monitoring Requirements

Post-deployment monitoring for:
- Performance metrics for PERF risks
- Security alerts for SEC risks
- Error rates for operational risks
- Business KPIs for business risks

## Risk Review Triggers

Review and update risk profile when:
- Architecture changes significantly
- New integrations added
- Security vulnerabilities discovered
- Performance issues reported
- Regulatory requirements change
```

### Output 2: Gate YAML Block

Generate for inclusion in quality gate under `risk_summary`:

```yaml
risk_summary:
  overall_score: {score}  # 0-100
  totals:
    critical: {count}
    high: {count}
    medium: {count}
    low: {count}
  highest:
    id: "{RISK-ID}"
    score: {score}
    title: "{title}"
  recommendations:
    must_fix:
      - "{action}"
    monitor:
      - "{what to monitor}"
```

**Output rules:**
- Only include assessed risks; do not emit placeholders.
- Sort risks by score (descending) when emitting highest and any tabular lists.
- If no risks: totals all zeros, omit highest, keep recommendations arrays empty.

**Gate mapping:**
- Any risk with score >= 9 contributes to gate FAIL (unless waived).
- Any risk with score >= 6 contributes to gate CONCERNS.
- All risks with score < 6 contribute to gate PASS.

### Output 3: Story Hook Line

Print for the review task to quote:

```
Risk profile: {qa-location}/assessments/{story-id}-risk-{YYYYMMDD}.md
Overall score: {score}/100 | Critical: {count} | High: {count}
```

## Error Handling

- **Story has no scope defined:** Proceed with AC-based analysis only. Note in the report that scope-based risk assessment was limited. Recommend adding scope to the story.
- **No implementation code available:** Assess risks based on story description and ACs only. Mark technical risks as "estimated" rather than "verified." Note that the profile should be updated when code is available.
- **Cannot assess a risk category:** Skip the category and document why (e.g., "No database operations in this story -- DATA category not applicable"). Do not fabricate risks.
- **Too many risks identified:** If more than 20 risks are identified, consolidate related risks within the same category. Ensure no critical or high risks are merged away. Present the top 10 in the executive summary.
- **Conflicting risk assessments:** If probability and impact are ambiguous, use the higher score (conservative approach). Document the ambiguity.
- **No prior QA history available:** Assess based on current story context only. Note that historical risk patterns could not be evaluated.
- **Risk requires domain expertise:** Flag the risk as "requires domain review" and recommend a stakeholder assessment. Assign a provisional score based on available evidence.

## Examples

### Example: Risk Profile for a Payment Integration Story

| Risk ID | Category | Title | Prob | Impact | Score |
|---------|----------|-------|------|--------|-------|
| SEC-001 | Security | PCI data exposure in logs | High (3) | High (3) | 9 |
| PERF-001 | Performance | Payment gateway timeout under load | Medium (2) | High (3) | 6 |
| DATA-001 | Data | Transaction record loss on failure | Low (1) | High (3) | 3 |
| TECH-001 | Technical | SDK version incompatibility | Medium (2) | Medium (2) | 4 |
| BUS-001 | Business | Conversion drop from extra step | Low (1) | Medium (2) | 2 |

Overall Score: 100 - 20 - 10 - 5 - 5 - 2 = 58/100 (High Risk)

Recommendations: Enhanced testing for SEC-001 (security audit of log outputs), load testing for PERF-001, idempotency testing for DATA-001.

## Acceptance Criteria

- [ ] All six risk categories are evaluated (or explicitly marked as not applicable).
- [ ] Each identified risk has probability, impact, and score assigned.
- [ ] Risk IDs follow the naming convention `{CATEGORY}-{SEQ}`.
- [ ] Critical and high risks have mitigation strategies defined.
- [ ] Overall story risk score is calculated.
- [ ] Risk-based testing recommendations are provided.
- [ ] Gate YAML block is generated with correct risk counts.
- [ ] Risk profile report is saved to the correct location.
- [ ] Risks are sorted by score (descending) in the risk matrix.
- [ ] No fabricated or speculative risks without evidence.

## Notes

- The risk profile should be created early in the story lifecycle (Ready or early InProgress). It becomes more accurate as implementation details emerge.
- This task assesses risks; it does not fix them. Mitigation actions are recommendations for @dev, @architect, or @devops.
- The risk profile feeds into `qa-test-design` for priority assignment and into `qa-gate` for verdict decisions.
- Risk profiles should be updated if the story scope changes significantly during implementation.
- Be honest about uncertainty. A risk scored as "Medium probability" with a note about limited evidence is more useful than a confidently wrong score.
- Not every story will have risks in every category. A simple UI change may have no security or data risks. Document this explicitly rather than forcing risks into empty categories.
- The overall risk score is a communication tool, not a precision instrument. Use it to convey the general risk posture to stakeholders, not as a threshold gate.
