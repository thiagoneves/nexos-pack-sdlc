---
task: qa-backlog-add-followup
agent: qa
workflow: qa-loop (support)
inputs: [QA review findings marked as deferred, story file]
outputs: [backlog items for follow-up, updated story QA results]
---

# Add QA Follow-Up to Backlog

## Purpose

Create follow-up backlog items for issues found during QA that were deferred rather than fixed in the current iteration. This covers MEDIUM and LOW severity findings that did not block approval but represent technical debt, improvements, or minor bugs that should be tracked and addressed in future work.

## Prerequisites

- A QA review has been completed with an APPROVE or CONCERNS verdict.
- Deferred findings exist (MEDIUM/LOW items not fixed during the QA loop).
- The story file and QA review report are accessible.
- The backlog file or tracking system is accessible.

## Steps

### 1. Collect Deferred Findings

Gather all findings that were not addressed during the QA loop:

- Read the QA review report(s) from all iterations of the loop.
- Filter for MEDIUM and LOW severity items that were not fixed.
- Include any HIGH items that were explicitly documented as tech debt during fixes.
- Cross-reference with the story's Dev Notes for any debt items noted during implementation.

If no deferred findings exist, report that no follow-up items are needed and stop.

### 2. Classify Each Finding

Categorize each deferred finding into one of these types:

| Category | Description | Examples |
|----------|-------------|----------|
| **tech-debt** | Code quality issue to address later | Suboptimal pattern, missing abstraction, hardcoded config |
| **improvement** | Enhancement opportunity | Better error message, performance optimization, UX polish |
| **bug** | Minor defect not blocking current story | Edge case not handled, incorrect fallback behavior |
| **documentation** | Missing or outdated docs | Undocumented API, stale README section, missing JSDoc |

### 3. Create Backlog Items

For each deferred finding, create a structured backlog item:

```yaml
backlog-item:
  title: "Clear, actionable title describing the issue"
  type: "follow-up"
  source-story: "{story-id}"
  severity: MEDIUM | LOW
  category: tech-debt | improvement | bug | documentation
  description: |
    What was found and why it was deferred.
  recommendation: |
    Suggested approach for fixing or improving.
  files:
    - "path/to/relevant/file"
  found-date: "{date}"
  found-by: "@qa"
  qa-iteration: {n}
```

Guidelines for backlog item titles:
- Start with an action verb (Fix, Add, Refactor, Update, Improve).
- Reference the specific component or area affected.
- Keep under 80 characters.

### 4. Check for Duplicates

Before finalizing each item:
- Search the existing backlog for items with similar titles or descriptions.
- Check the stories directory for open stories covering the same area.
- If a duplicate exists, merge the new finding into the existing item. Add a note referencing the current story as an additional source.
- If a near-duplicate exists, link the two items and note the relationship.

### 5. Organize by Priority

Group the finalized backlog items:

1. **HIGH-deferred** -- Items that were HIGH severity but deferred due to scope constraints. These should be addressed soon.
2. **MEDIUM** -- Standard technical debt and improvements. Schedule in upcoming iterations.
3. **LOW** -- Minor items. Address opportunistically or batch together.

Within each group, order by estimated impact (higher impact first).

### 6. Update Story QA Results (Optional)

If the story has a QA Results section, add a reference to the created backlog items:

- Append follow-up references to the QA Results section.
- Example: `**Follow-up Created:** [Backlog Item {id}] - {title}`
- If QA Results section does not exist, log a warning and skip the story update.

### 7. Present Summary

Report the results to the user:
- Total number of backlog items created.
- Breakdown by category (tech-debt, improvement, bug, documentation).
- Breakdown by severity.
- List each item with its title and source story reference.
- Note any items that were merged with existing backlog entries.

If any items are HIGH-deferred, flag them for immediate attention.

### 8. Delegate Prioritization

If backlog items were created:
- Suggest that @po review and prioritize the new items within the product backlog.
- Provide the list in a format suitable for backlog grooming.
- Note any items that may affect upcoming stories in the same epic.

## QA-Specific Rules

1. **Type is always follow-up** -- QA creates follow-ups from review findings, not ad-hoc tech debt.
2. **Related story is required** -- All QA follow-up items must be linked to the reviewed story.
3. **Priority guidance:**
   - Critical: Security issue, data corruption risk, blocking bug discovered after approval.
   - High: Important test gap, significant edge case, deferred HIGH finding.
   - Medium: Nice-to-have test improvement, minor code quality gap.
   - Low: Optional improvement, cosmetic concern.
4. **Story update recommended** -- Keep follow-ups visible in the story file for audit trail.

## Error Handling

- **No deferred findings:** Report that no follow-up items are needed. This is a normal outcome and not an error.
- **Duplicate backlog item found:** Merge with existing item. Add a note in both the existing item and the QA report referencing the merge.
- **Cannot determine severity:** Default to MEDIUM. Add a note requesting severity assessment during backlog grooming.
- **QA review report missing:** Warn the user and attempt to reconstruct deferred items from the story's Dev Notes and tech debt sections. If insufficient data, halt and request the QA report.
- **Backlog storage location unclear:** Create items in the story's Dev Notes section as a fallback and inform the user to move them to the proper backlog location.
- **Category ambiguous:** If a finding fits multiple categories, choose the primary category and note the secondary in the description.
- **Story not found:** Show similar story names and allow retry. Do not create orphan follow-ups without a linked story.
- **QA Results section missing in story:** Log warning, skip story update, but still create backlog items.

## Examples

### Example: Follow-Up Items from Story 3.2

```
Follow-Up Items Created: 3

1. [MEDIUM] Refactor validation logic to shared utility
   - Category: tech-debt
   - Source: Story 3.2, QA iteration 2
   - File: src/services/auth.ts

2. [MEDIUM] Add rate limiting to registration endpoint
   - Category: improvement
   - Source: Story 3.2, QA iteration 1
   - File: src/api/auth-routes.ts

3. [LOW] Update API documentation for error response codes
   - Category: documentation
   - Source: Story 3.2, QA iteration 2
   - File: docs/api/auth.md

Next: @po reviews and prioritizes in backlog grooming.
```

## Acceptance Criteria

- [ ] All deferred MEDIUM and LOW findings from the QA review are captured as backlog items.
- [ ] Each backlog item has: title, type, source story, severity, category, description, and recommendation.
- [ ] Duplicate check is performed before creating each item.
- [ ] Items are organized by priority (HIGH-deferred first, then MEDIUM, then LOW).
- [ ] Summary is presented with counts by category and severity.
- [ ] Story QA Results section is updated with backlog references (when applicable).
- [ ] HIGH-deferred items are flagged for immediate attention.

## Notes

- This task creates tracking items for deferred work. It does not fix anything.
- Follow-up items should be clear enough that any developer can understand and address them without needing the full QA review context.
- The value of this task is in preventing deferred findings from being forgotten. Every deferred item should be tracked somewhere.
- If the same finding appears across multiple stories, this may indicate a systemic issue that deserves its own story rather than repeated backlog items.
- Follow-up items created here feed into @po's backlog grooming process for prioritization and scheduling.
