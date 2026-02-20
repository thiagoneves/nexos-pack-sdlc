---
task: po-close-story
agent: po
inputs:
  - story_path (required, string, path to the story file relative to docs/stories/)
  - pr_number (optional, number, PR number associated with the merge)
  - commit_sha (optional, string, merge commit SHA, 7+ characters)
  - notes (optional, string, additional changelog notes)
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - story_updated (boolean, whether the story file was updated)
  - epic_updated (boolean, whether the epic index was updated)
  - next_story_suggestion (object, suggested next story from the same epic or backlog)
---

# Close Story

## Purpose
Close a completed story after implementation, testing, and merge. Updates story status to Done, adds a changelog entry with merge/PR info, updates the epic index with completion progress, and suggests the next story to work on.

## Prerequisites
- Story file exists at the provided path
- Story is not already marked as Done (warning if it is)
- Epic index file exists in the same directory (optional, for epic-level updates)

## Steps

### 1. Elicit Story and Merge Info

Gather from user:
- **Story path** (relative to `docs/stories/`): must point to an existing file
- **PR number** (optional): numeric value
- **Merge commit SHA** (optional): 7+ hex characters
- **Additional notes** (optional): free text for the changelog entry

### 2. Read and Parse Story

Load the story file and extract metadata:
- Story ID (e.g., "PRO-5")
- Epic ID (e.g., "PRO" from the directory structure)
- Current status
- Existing changelog entries

Verify the story is not already marked as Done. If it is, log a warning but continue to update other fields.

### 3. Update Story Status and Changelog

**Update the Status field** from its current value to `Done`.

**Add a changelog entry** with:
- Today's date
- Next version number
- PR and commit reference
- User-provided notes
- Author attribution

### 4. Update Epic Index (If Applicable)

If the story belongs to an epic and an epic index file exists:
- Update the story's status in the epic table to Done
- Count remaining pending stories vs total stories
- If all stories are done, update epic status to Complete
- Otherwise, update epic status to show progress (e.g., "3/5 stories done")

### 5. Suggest Next Story

If the story belongs to an epic:
- Find the next pending story in the epic index
- Display its ID, title, status, owner, and file path
- Provide quick action commands for validation and viewing

If all stories in the epic are done:
- Announce epic completion
- Suggest reviewing the backlog or starting a new epic

### 6. Update Backlog Statistics (Optional)

If a `docs/stories/backlog.md` file exists:
- Increment the completed stories count
- Update the last-updated date
- Add to resolved items if the story was tracked in the backlog

### 7. Summary Output

Display a structured summary:
- Story ID and title
- Final status (Done)
- PR and commit references
- Changelog version added
- Epic progress (X/Y stories complete)
- Next story suggestion or epic completion message

## Error Handling
- **Story not found:** Show available stories in the directory
- **Epic index not found:** Update story only, skip epic updates
- **PR not found:** Allow closing without PR info (manual merge scenario)
- **Write permission denied:** Show manual update instructions
- **Story already Done:** Warn but allow re-processing for changelog/epic updates
