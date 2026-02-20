---
task: story-checkpoint
agent: po
inputs:
  - completed story file
  - implementation summary
  - quality gate result
  - PR URL (optional)
outputs:
  - user decision (GO / PAUSE / REVIEW / ABORT)
  - workflow state update
---

# Story Checkpoint

## Purpose

Pause the development workflow between stories to present a summary of the completed story and request a human decision on what to do next. This task ensures the user maintains control over the development cycle and can choose to continue, pause, review details, or stop the epic entirely.

This task always requires human interaction. It cannot be fully automated.

## Prerequisites

- A story has completed the development and QA phases (or the user has explicitly requested a checkpoint).
- The story file is available with its final status.
- Implementation details (files created/modified, tests) are available.
- Quality gate results are available (verdict and score).

## Steps

### 1. Gather Completion Summary

Collect data from the completed story and its associated workflow phases:

**From the story file:**
- Story ID and title.
- Final status.
- Number of task checkboxes completed versus total.

**From the implementation phase:**
- Number of files created.
- Number of files modified.
- Number of tests added or updated.
- Key implementation decisions (if a decision log exists).

**From the quality gate:**
- Verdict (PASS, CONCERNS, FAIL, WAIVED).
- Score (e.g., 7/7 checks passed).
- Notable findings or observations.

**From the push phase (if applicable):**
- PR URL (if a PR was created).
- PR status (open, merged, draft).

If any data is unavailable, use "N/A" and proceed. The checkpoint should never fail due to missing optional data.

### 2. Display Completion Summary

Present the summary in a clear, structured format:

```
================================================================
                    STORY CHECKPOINT
================================================================

Story Completed: {story_id} - {story_title}
----------------------------------------------------------------

Implementation Summary:
   Files Created:  {files_created_count}
   Files Modified: {files_modified_count}
   Tests Added:    {tests_added_count}

Quality Gate: {verdict} ({score})

PR: {pr_url or "Not created yet"}

================================================================
```

Keep the summary concise. The user can request details via the REVIEW action.

### 3. Present Decision Options

Display the four available actions and request the user's choice:

```
What would you like to do next?

  [1] GO     - Continue to the next story
  [2] PAUSE  - Save state and stop for now
  [3] REVIEW - Show detailed summary of what was done
  [4] ABORT  - Stop working on this epic

Enter your choice (1-4):
```

Wait for the user's input. If no response is received within 30 minutes, default to PAUSE and save state.

### 4. Execute the Chosen Action

Based on the user's decision, execute one of the following action paths:

---

#### Action: GO -- Continue to Next Story

**Step 4a-1: Find the next story.**
- Read the epic file or backlog to determine the story sequence.
- Identify the current story's position.
- Find the next story with status `Draft` or `Ready`.
- If no more stories remain, report: "All stories in this epic are complete. The epic is finished."

**Step 4a-2: Validate the next story is ready.**
Check that the next story:
- Has been created (file exists).
- Has a status of `Draft` or `Ready`.
- Has no unmet dependencies (predecessor stories are complete).

If the story is in `Draft`, note that it needs validation before development can begin.

**Step 4a-3: Confirm with the user.**
```
Next story: {next_story_id} - {next_story_title}
Status: {status}
Dependencies: {met | unmet: list}

Start development? (Y/n):
```

**Step 4a-4: Transition.**
If confirmed:
- Update the workflow state to point to the next story.
- Reset the workflow phase to the beginning (validation or development, depending on story status).
- Continue execution.

If not confirmed, return to the decision menu.

---

#### Action: PAUSE -- Save State and Stop

**Step 4b-1: Save workflow state.**
Persist the current workflow state to a state file:

```yaml
workflow: story-development-cycle
current_story: "{story_id}"
current_phase: "checkpoint"
paused_at: "{timestamp}"
epic_id: "{epic_id}"
epic_progress:
  completed_stories:
    - "{story_1_id}"
    - "{story_2_id}"
  next_story: "{next_story_id}"
  remaining_count: {n}
context:
  last_verdict: "{qa_verdict}"
  last_pr: "{pr_url}"
```

Save to: `{project_root}/.nexos/workflow-state/{epic_id}-state.yaml`

**Step 4b-2: Confirm state saved.**
```
Workflow state saved.

To resume later:
  *resume-workflow {epic_id}

Or start the next story directly:
  *validate-next-story {next_story_id}
```

**Step 4b-3: Exit the workflow.**
End execution with status: `paused`.

---

#### Action: REVIEW -- Show Detailed Summary

**Step 4c-1: Gather detailed data.**
Collect comprehensive information:
- Full file list (created, modified, deleted) with paths.
- Git diff summary (lines added, lines removed).
- Complete test results (passed, failed, skipped).
- All quality gate check results with notes.
- PR details and review status.
- Any tech debt items documented during development.
- Decision log entries (if available).

**Step 4c-2: Display detailed summary.**
```
================================================================
                    DETAILED SUMMARY
================================================================

Story: {story_id} - {story_title}
Duration: {start_time} to {end_time}

----------------------------------------------------------------
FILES CHANGED
----------------------------------------------------------------

Created:
  + {file_1}
  + {file_2}

Modified:
  ~ {file_3}
  ~ {file_4}

----------------------------------------------------------------
TEST RESULTS
----------------------------------------------------------------

  Passed:  {n}
  Failed:  {n}
  Skipped: {n}

----------------------------------------------------------------
QUALITY GATE
----------------------------------------------------------------

  Verdict: {verdict}
  Score:   {score}

  Check Results:
  - Code Review:          {PASS | CONCERN | FAIL}
  - Unit Tests:           {PASS | CONCERN | FAIL}
  - Acceptance Criteria:  {PASS | CONCERN | FAIL}
  - No Regressions:       {PASS | CONCERN | FAIL}
  - Performance:          {PASS | CONCERN | FAIL}
  - Security:             {PASS | CONCERN | FAIL}
  - Documentation:        {PASS | CONCERN | FAIL}

  Observations:
  - {finding_1}
  - {finding_2}

----------------------------------------------------------------
TECH DEBT
----------------------------------------------------------------

  - {debt_item_1}
  - {debt_item_2}

================================================================
```

**Step 4c-3: Return to decision menu.**
After displaying the detailed summary, present the decision options again (Step 3). The user may now choose GO, PAUSE, or ABORT with full context.

---

#### Action: ABORT -- Stop the Epic

**Step 4d-1: Confirm the abort.**
This is a significant action. Require explicit confirmation:

```
Are you sure you want to stop working on this epic?

This will:
  - Stop the development cycle for this epic.
  - Save all current progress.
  - NOT affect already completed stories or merged PRs.

Type "abort" to confirm, or anything else to cancel:
```

If the user does not confirm, return to the decision menu.

**Step 4d-2: Save final state.**
Save the workflow state with `aborted` status:

```yaml
workflow: story-development-cycle
current_story: "{story_id}"
current_phase: "checkpoint"
status: "aborted"
aborted_at: "{timestamp}"
epic_id: "{epic_id}"
epic_progress:
  completed_stories: [...]
  aborted_at_story: "{story_id}"
  remaining_stories: [...]
abort_reason: "User requested abort at checkpoint."
```

Save to: `{project_root}/.nexos/workflow-state/{epic_id}-state.yaml`

**Step 4d-3: Report abort.**
```
Epic development stopped.

Progress saved. Completed stories are unaffected.

To review progress:
  *backlog-status {epic_id}

To restart from where you left off:
  *resume-workflow {epic_id}
```

**Step 4d-4: Exit the workflow.**
End execution with status: `aborted`.

### 5. Log the Checkpoint Decision

Regardless of which action was chosen, log the decision:
- Record: timestamp, story ID, decision (GO/PAUSE/REVIEW/ABORT), next story (if GO).
- Append to the epic's Change Log or the workflow state file.

## Error Handling

- **No next story found (for GO action):** Display "All stories in this epic are complete. The epic is done." Offer PAUSE or ABORT as alternatives.
- **Next story has unmet dependencies:** Display which dependencies are unmet. Suggest completing them first or choosing a different story.
- **State file save fails:** Retry 3 times. If still failing, display the state data to the user and ask them to save it manually. Do not silently lose state.
- **User input timeout (30 minutes):** Default to PAUSE. Save state and exit with a message: "No response received. Workflow paused. State saved."
- **Story file not found or unreadable:** Display what information is available (from workflow context). Warn about the missing file but still allow the checkpoint to proceed.
- **Quality gate data missing:** Display "Quality gate: Not yet run" and proceed. The checkpoint does not require QA to have completed.
- **Epic file not found (for GO action):** Cannot determine next story automatically. Ask the user to specify the next story manually.

## Notes

- This task is the human control point in an otherwise automated workflow. Its purpose is to prevent runaway automation and give the user a moment to assess progress.
- The REVIEW action is informational only -- it does not change any state. Users can review as many times as they want before choosing a final action.
- If the user selects REVIEW, the detailed summary is displayed and then the decision menu is shown again. This loop continues until the user selects GO, PAUSE, or ABORT.
- State files enable resuming workflows across sessions. They should contain enough context to reconstruct the workflow position without re-reading all artifacts.
- For automated CI/CD pipelines where human interaction is not feasible, consider using a pre-configured decision (e.g., "auto-GO if QA passed") instead of this interactive checkpoint.
