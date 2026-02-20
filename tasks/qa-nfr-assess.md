---
task: qa-nfr-assess
agent: qa
workflow: story-development-cycle (qa-gate)
inputs:
  - story_id (required, format: "{epic}.{story}")
  - story_path (from core config devStoryLocation)
  - architecture_refs (optional, from core config)
  - technical_preferences (optional, from core config)
  - acceptance_criteria (optional, from story file)
outputs:
  - nfr_validation YAML block for gate file
  - assessment report (qa/assessments/{epic}.{story}-nfr-{YYYYMMDD}.md)
  - story update line referencing assessment
  - gate integration line for nfr_validation section
---

# NFR Assessment

## Purpose
Quick non-functional requirements validation focused on the core four: security, performance, reliability, and maintainability. Generates a YAML block for the gate file's `nfr_validation` section and a brief markdown assessment report.

## Prerequisites
- Story file exists and is accessible
- Validation rules are loaded and target is available for validation
- Architecture references and technical preferences are available (optional but recommended)

## Steps

### 0. Fail-Safe for Missing Inputs
If `story_path` or story file cannot be found:
- Still create the assessment file with note: "Source story not found"
- Set all selected NFRs to CONCERNS with notes: "Target unknown / evidence missing"
- Continue with assessment to provide value

### 1. Elicit Scope
**Interactive mode:** Ask which NFRs to assess:

```text
Which NFRs should I assess? (Enter numbers or press Enter for default)
[1] Security (default)
[2] Performance (default)
[3] Reliability (default)
[4] Maintainability (default)
[5] Usability
[6] Compatibility
[7] Portability
[8] Functional Suitability

> [Enter for 1-4]
```

**Non-interactive mode:** Default to core four (security, performance, reliability, maintainability).

### 2. Check for Thresholds
Look for NFR requirements in:
- Story acceptance criteria
- `docs/architecture/*.md` files
- `docs/technical-preferences.md`

**Interactive mode:** Ask for missing thresholds.

**Non-interactive mode:** Mark as CONCERNS with "Target unknown".

**Unknown targets policy:** If a target is missing and not provided, mark status as CONCERNS with notes: "Target unknown".

### 3. Quick Assessment
For each selected NFR, check:
- Is there evidence it is implemented?
- Can we validate it?
- Are there obvious gaps?

### 4. Generate Outputs

**Output 1: Gate YAML Block**

Generate ONLY for NFRs actually assessed (no placeholders):

```yaml
nfr_validation:
  _assessed: [security, performance, reliability, maintainability]
  security:
    status: CONCERNS
    notes: 'No rate limiting on auth endpoints'
  performance:
    status: PASS
    notes: 'Response times < 200ms verified'
  reliability:
    status: PASS
    notes: 'Error handling and retries implemented'
  maintainability:
    status: CONCERNS
    notes: 'Test coverage at 65%, target is 80%'
```

**Output 2: Brief Assessment Report**

Save to: `qa/assessments/{epic}.{story}-nfr-{YYYYMMDD}.md`

Include: Summary per NFR, critical issues with risk and fix recommendations, and quick wins.

**Output 3: Story Update Line**

```
NFR assessment: qa/assessments/{epic}.{story}-nfr-{YYYYMMDD}.md
```

**Output 4: Gate Integration Line**

```
Gate NFR block ready -> paste into qa/gates/{epic}.{story}-{slug}.yml under nfr_validation
```

## Deterministic Status Rules

- **FAIL**: Any selected NFR has critical gap or target clearly not met
- **CONCERNS**: No FAILs, but any NFR is unknown/partial/missing evidence
- **PASS**: All selected NFRs meet targets with evidence

## Quality Score Calculation

```
quality_score = 100
- 20 for each FAIL attribute
- 10 for each CONCERNS attribute
Floor at 0, ceiling at 100
```

If `technical-preferences.md` defines custom weights, use those instead.

## Assessment Criteria

### Security
- **PASS:** Authentication implemented, authorization enforced, input validation present, no hardcoded secrets
- **CONCERNS:** Missing rate limiting, weak encryption, incomplete authorization
- **FAIL:** No authentication, hardcoded credentials, SQL injection vulnerabilities

### Performance
- **PASS:** Meets response time targets, no obvious bottlenecks, reasonable resource usage
- **CONCERNS:** Close to limits, missing indexes, no caching strategy
- **FAIL:** Exceeds response time limits, memory leaks, unoptimized queries

### Reliability
- **PASS:** Error handling present, graceful degradation, retry logic where needed
- **CONCERNS:** Some error cases unhandled, no circuit breakers, missing health checks
- **FAIL:** No error handling, crashes on errors, no recovery mechanisms

### Maintainability
- **PASS:** Test coverage meets target, code well-structured, documentation present
- **CONCERNS:** Test coverage below target, some code duplication, missing documentation
- **FAIL:** No tests, highly coupled code, no documentation

## Quick Reference

```yaml
security:
  - Authentication mechanism
  - Authorization checks
  - Input validation
  - Secret management
  - Rate limiting

performance:
  - Response times
  - Database queries
  - Caching usage
  - Resource consumption

reliability:
  - Error handling
  - Retry logic
  - Circuit breakers
  - Health checks
  - Logging

maintainability:
  - Test coverage
  - Code structure
  - Documentation
  - Dependencies
```

## ISO 25010 Reference

All 8 Quality Characteristics (for assessments beyond the core four):
1. **Functional Suitability**: Completeness, correctness, appropriateness
2. **Performance Efficiency**: Time behavior, resource use, capacity
3. **Compatibility**: Co-existence, interoperability
4. **Usability**: Learnability, operability, accessibility
5. **Reliability**: Maturity, availability, fault tolerance
6. **Security**: Confidentiality, integrity, authenticity
7. **Maintainability**: Modularity, reusability, testability
8. **Portability**: Adaptability, installability

## Error Handling
- **Validation Criteria Missing:** Ensure validation criteria loaded from config; use default validation rules and log warning
- **Invalid Schema:** Update schema or fix target structure; provide detailed validation error report
- **Dependency Missing:** Install missing dependencies; abort with clear dependency list
- **Story Not Found:** Create assessment with "Source story not found" note; set all NFRs to CONCERNS

## Key Principles
- Focus on the core four NFRs by default
- Quick assessment, not deep analysis
- Gate-ready output format
- Brief, actionable findings
- Skip what does not apply
- Deterministic status rules for consistency
- Unknown targets lead to CONCERNS, not guesses
