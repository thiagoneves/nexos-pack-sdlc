---
task: qa-false-positive-detection
agent: qa
workflow: story-development-cycle (qa-gate, phase 5.3)
inputs:
  - story_id (required, string)
  - issue_type (optional: bug_fix, feature - auto-detected if omitted)
  - claimed_fix (optional, string description of what was fixed)
outputs:
  - verification_report (file: docs/stories/{story-id}/qa/false_positive_check.md)
  - confidence_score (number, 0.0 - 1.0)
  - verified (boolean)
---

# False Positive Detection

## Purpose
Critical thinking checklist to prevent confirmation bias and false positive approvals. Ensures that bug fixes genuinely address the root cause and that features actually deliver the claimed functionality, rather than appearing to work due to coincidence, timing, or incomplete testing.

## Prerequisites
- Story file exists with acceptance criteria
- Commits exist for the story
- Code changes (diff) are available
- New or modified tests are available for review

## The Problem: Confirmation Bias in QA

Common false positive scenarios:
- **Placebo Fix:** Change looks like it fixes the bug but does not actually address root cause (e.g., adding try-catch that swallows the error)
- **Timing Coincidence:** Bug disappeared due to unrelated change or timing (e.g., race condition stopped due to added logging)
- **Environment Dependency:** Works in dev but fails in prod due to environment differences (e.g., hardcoded localhost URL)
- **Incomplete Fix:** Fix addresses one case but not all edge cases (e.g., null check added but undefined still causes crash)
- **Self-Healing Bug:** Bug that intermittently resolves itself (e.g., cache-related bug that clears after restart)

## Steps

### 1. Collect Context
Gather all relevant information:
- Story file and acceptance criteria
- Commits for this story
- Code changes (diff)
- New/modified tests
- Claimed fix (from parameter or extracted from commits)

### 2. Run Verification Checklist

#### Assumptions Verification
| Check | What to Verify | Red Flag |
|---|---|---|
| Assumptions explicit | List each assumption made about the fix | Implicit assumptions without evidence |
| Assumptions verified | Link to test, log, or documentation for each | Assumptions taken for granted |
| Alternatives considered | List other possible causes that were ruled out | Only one explanation considered |

#### Causation Tests
| Test | How to Verify | Pass | Fail |
|---|---|---|---|
| Remove test | Revert the fix, reproduce original bug, re-apply fix, confirm bug is gone | Bug returns when fix removed, disappears when applied | Bug behavior unchanged by fix |
| Old code fails | Test case showing failure before fix | Have concrete evidence of failure | Assumed failure without verification |
| New code succeeds | Test case showing success after fix | Have concrete evidence of success | Assumed success without verification |
| Not self-healing | Wait reasonable time, restart services, clear caches, confirm bug still fixed | Bug stays fixed through various conditions | Bug fix is timing-dependent |

#### Confirmation Bias Checks
| Check | What to Verify | Pass | Fail |
|---|---|---|---|
| Negative cases tested | List scenarios where the code SHOULD fail/reject | Negative cases defined and tested | Only happy path tested |
| Independent verification | Reproduction steps clear enough for another person | Steps are complete and reproducible | Requires original developer's environment/knowledge |
| Mechanism explained | Explain WHY the fix works: root cause, how change addresses it, why it will not regress | Clear causal explanation | Only know THAT it works, not WHY |

#### Edge Case Verification

**For bug fixes:** Null/undefined inputs, empty strings/arrays, maximum/minimum values, concurrent access, network failures, timeout conditions.

**For features:** First time use, repeated use, invalid input, permission denied, rate limiting, offline mode.

### 3. Calculate Confidence Score

| Factor | Weight |
|---|---|
| Assumptions verified | 0.20 |
| Remove test passed | 0.25 (most important) |
| Old code fails | 0.15 |
| New code succeeds | 0.15 |
| Not self-healing | 0.10 |
| Negative cases tested | 0.10 |
| Mechanism explained | 0.05 |

**Thresholds:**
- High confidence (>= 0.85): Approve with confidence
- Medium confidence (>= 0.65): Approve with notes
- Low confidence (< 0.65): Require additional verification or reject

### 4. Generate Report
Create `false_positive_check.md` with:
- Claimed fix description
- Verification results table (assumptions, causation, bias checks)
- Red flags identified
- Confidence calculation breakdown
- Recommendation: VERIFIED, NEEDS_MORE_EVIDENCE, or LIKELY_FALSE_POSITIVE
- Next steps

## Red Flags Quick Reference
- Fix only tested on happy path
- Cannot reproduce original bug
- Fix works but mechanism unclear
- Depends on specific timing/environment
- No test added to prevent regression
- Similar code elsewhere not checked
- Assumptions not documented
- Only one explanation considered

## Command
```
*false-positive-check {story-id} [--claimed-fix "description"]
```

## Integration with QA Review
**Trigger:** During `*review-build` Phase 5.3 for bug fixes and security PRs.

**Decision rules:**
- Confidence >= 0.85: No impact on decision
- Confidence >= 0.65: Add note to review
- Confidence < 0.65: Strong consideration for REJECT

## Error Handling
- **Story file not found:** Proceed with limited context, note missing story in report, lower confidence ceiling to 0.7
- **No commits found:** Cannot run remove test or diff analysis; mark causation tests as SKIP, lower confidence
- **Claimed fix not provided:** Extract from commit messages; if not possible, prompt for description
- **Automated verification not possible:** Fall back to manual checklist prompts, document as manual verification
