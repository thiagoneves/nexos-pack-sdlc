---
task: validate-next-story
agent: po
inputs:
  - story file (Draft status)
  - PRD / epic context
  - architecture documentation
  - story template
outputs:
  - validated story with GO/NO-GO verdict
  - validation-result.md report
---

# Validate Next Story

## Purpose

Comprehensively validate a story draft before implementation begins, ensuring it is complete, accurate, traceable to source documents, and provides sufficient context for successful development. This task identifies gaps, inaccuracies, and hallucinations, preventing issues that would be costly to fix during implementation.

The validator acts as a quality gate between story creation (@sm) and story implementation (@dev). A GO verdict means the story is ready for development. A NO-GO verdict means the story must return to @sm for corrections.

This task is Phase 2 of the Story Development Cycle (SDC).

## Prerequisites

- [ ] The story file exists and is in `Draft` status.
- [ ] The PRD and/or epic documentation is accessible for cross-reference.
- [ ] The story was created using the standard story template.
- [ ] The project `config.yaml` is accessible for configuration lookups.
- [ ] Architecture documentation is available for anti-hallucination verification.

## Execution Modes

### 1. Autopilot Mode -- Fast, Autonomous (0-1 prompts)

- Runs all 10 checklist items automatically with strict scoring.
- Issues the verdict without user confirmation.
- **Best for:** Well-structured stories from an established @sm process. Batch validations.
- **User interaction:** None unless borderline score (exactly 7/10).

### 2. Interactive Mode -- Balanced, Deliberative (3-5 prompts) **[DEFAULT]**

- Presents each checklist item result with explanation.
- Asks for user input on subjective criteria (items 7, 8).
- Confirms the verdict before applying status changes.
- **Best for:** Standard validation where human judgment improves accuracy.

### 3. Pre-Flight Mode -- Deep Analysis (5-10 prompts)

- Performs detailed analysis upfront: architecture alignment, full anti-hallucination scan, cross-story dependency analysis, technical feasibility assessment.
- Presents comprehensive findings before scoring begins.
- **Best for:** Complex or high-risk stories. First validation in a new project.

## Steps

### Step 0: Load Configuration and Inputs

Read the project `config.yaml` and determine stories directory, architecture location, PRD location.

Load the following inputs:
- **Story file:** The draft story to validate.
- **Parent epic:** The epic containing this story's requirements.
- **Architecture documents:** Based on configuration format.
- **Story template:** For completeness validation.

If any critical input is missing, HALT with a clear message.

### Step 1: Pre-Validation Checks

#### 1.1 Status Check

- Verify the story is in `Draft` status.
- If `Ready` or beyond, ask whether to re-validate.

#### 1.2 Template Completeness Check

- Load the story template and extract all required section headings.
- Compare story sections against template sections.
- Check for unfilled placeholders (`{placeholder}`, `[TODO]`, `TBD`, etc.).
- Verify structural formatting matches the template.

#### 1.3 Story Metadata Validation

- [ ] Story has a valid ID matching `{epicNum}.{storyNum}` pattern.
- [ ] Status field is present and set to `Draft`.
- [ ] Epic reference is present and valid.
- [ ] Executor and Quality Gate agents are assigned.
- [ ] Complexity estimate is present.

### Step 2: Load Reference Documents

#### 2.1 Epic Context

Load the epic file for scope, story breakdown, and requirements reference.

#### 2.2 PRD Context

Load the PRD and identify functional requirements (FR-*) and non-functional requirements (NFR-*) that map to this story.

#### 2.3 Architecture Context

Load relevant architecture documents based on story type. This is needed for anti-hallucination checks in Step 4.

### Step 3: Run the 10-Point Validation Checklist

Evaluate the story against each criterion. Score each item as PASS (1) or FAIL (0).

#### Item 1: Clear and Objective Title
- Title describes a specific deliverable, is action-oriented, concise (under 80 chars), and distinguishes this story from others.

#### Item 2: Complete Description
- Problem or need is explained with sufficient context. The "why" is clear. Story statement follows "As a / I want / So that" format.

#### Item 3: Testable Acceptance Criteria (CRITICAL)
- Each AC is specific, measurable, uses Given/When/Then where possible, has clear success/failure conditions. Edge cases and error scenarios are covered.

#### Item 4: Well-Defined Scope (CRITICAL)
- Both IN and OUT sections present. IN items specific enough to implement. OUT items prevent scope creep. No overlap with other stories.

#### Item 5: Dependencies Mapped
- Prerequisite stories identified. External dependencies listed. No hidden or circular dependencies.

#### Item 6: Complexity Estimate
- Point estimate or T-shirt size present. Reasonable for the described scope.

#### Item 7: Business Value Clear
- Benefit to user/business is stated. Understandable to non-technical stakeholders.

#### Item 8: Risks Documented
- Potential problems identified. Unknowns acknowledged. Mitigations or contingencies suggested.

#### Item 9: Criteria of Done
- Clear definition of when story is complete. Includes code, testing, documentation, and review expectations.

#### Item 10: Alignment with PRD/Epic (CRITICAL)
- Content traceable to source documents. No invented requirements. Correctly sequenced within the epic.

### Step 4: Anti-Hallucination Verification

#### 4.1 Source Verification
- Every technical claim in Dev Notes must be traceable to a source document.
- Verify `[Source: ...]` references are present and accurate.

#### 4.2 Architecture Alignment
- Dev Notes content must match architecture specifications.
- File paths must match project structure documentation.
- Technology choices must align with tech stack documentation.

#### 4.3 Fact Checking
- Cross-reference API specs, data models, and component details against architecture docs.
- Verify library/framework references match what is in the project.

#### 4.4 Report Findings
Categorize as: Invented Content, Inaccurate References, Unverifiable Claims, Missing Sources.

### Step 5: File Structure and Implementation Readiness

#### 5.1 File Paths Validation
- New/existing files clearly specified. Paths consistent with project structure.

#### 5.2 Task Sequence Validation
- Logical implementation order. Dependencies clear. Tasks appropriately sized and actionable. Full coverage of requirements.

#### 5.3 Dev Agent Readiness
- Can the story be implemented without reading external docs? Are steps unambiguous? Are all required technical details present?

### Step 6: Calculate Score and Verdict

#### 6.1 Scoring

| Score | Verdict | Condition |
|-------|---------|-----------|
| 8-10 | GO | Story is ready for development. |
| 7 | Conditional GO | GO if no CRITICAL criteria (3, 4, 10) failed. Otherwise NO-GO. |
| 0-6 | NO-GO | Story requires fixes before development. |

#### 6.2 Confidence Assessment

| Level | Meaning |
|-------|---------|
| High | Implementable with minimal questions. |
| Medium | Implementable but some clarifications would help. |
| Low | Technically valid but risks mid-development blocks. |

### Step 7: Generate Validation Report

Produce a structured report using `templates/validation-result.md` containing:
- Checklist results (10-point scoring table with notes).
- Template compliance issues.
- Critical issues (must fix -- story blocked).
- Should-fix issues (important quality improvements).
- Nice-to-have improvements.
- Anti-hallucination findings.
- Final assessment: Score, Verdict, Confidence.

### Step 8: Present Results and Confirm

Display results to the user: checklist items with PASS/FAIL, total score, verdict, anti-hallucination findings.

In Interactive and Pre-Flight modes, ask for user confirmation of the verdict.

### Step 9: Apply Verdict

#### 9.1 GO Verdict

1. Update story Status from `Draft` to `Ready`.
2. Add Change Log entry: `| {date} | @po | Validated: GO ({score}/10). Status: Draft -> Ready. |`
3. Save story file and validation report.

**A story left in Draft after a GO verdict is a process violation.**

#### 9.2 Conditional GO (score = 7, no CRITICAL failures)

Present conditions, ask user to apply GO with conditions or treat as NO-GO.

#### 9.3 NO-GO Verdict

1. Do NOT change story status (remains `Draft`).
2. Add Change Log entry with required fixes.
3. Save story file and validation report.
4. Inform user of required fixes and next steps.

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| Story not found | Invalid ID or missing file | List available stories. Ask for correct ID. |
| Story not in Draft | Already Ready, InProgress, or Done | Warn. Ask if re-validation intended. |
| Config not found | No config.yaml | HALT. Inform of expected locations. |
| Epic not found | Parent epic file missing | Warn. Score item 10 as PASS with caveat. |
| PRD not found | Referenced PRD unavailable | Warn. Note alignment check is limited. |
| Architecture docs missing | Files not found | Warn. Note anti-hallucination check is limited. |
| Template not found | Story template unavailable | Warn. Skip template completeness check. |
| Status update fails | File write error after GO | Report error. Instruct manual update. |
| Ambiguous score | Borderline score (7) with subjective criteria | Prompt user. Present assessment transparently. |

## Acceptance Criteria

- [ ] All 10 checklist items evaluated with PASS/FAIL scores.
- [ ] Anti-hallucination verification performed.
- [ ] Clear GO or NO-GO verdict issued with numeric score.
- [ ] On GO: story status updated from `Draft` to `Ready`.
- [ ] On NO-GO: story remains `Draft` with required fixes listed.
- [ ] Change Log entry added to story file.
- [ ] Validation report generated.
- [ ] User informed of verdict and next steps.

## Notes

- **Status Ownership:** The `Draft -> Ready` transition is EXCLUSIVELY @po's responsibility.
- **Anti-Hallucination Priority:** This is the primary defense against invented requirements reaching development.
- **Critical Criteria:** Items 3, 4, and 10 are weighted higher because failures are most costly during implementation.
- **Scope of Edits:** During validation, @po may only edit Status and Change Log. Content changes must be done by @sm.
- **Re-Validation:** A story can be re-validated at any time. New results replace previous ones.
- **Template Compliance:** Minor formatting differences should not cause a FAIL. Focus on content quality.
