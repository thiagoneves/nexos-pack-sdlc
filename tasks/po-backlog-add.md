---
task: po-backlog-add
agent: po
inputs:
  - type (required, string, F|T|E for Follow-up/TechDebt/Enhancement)
  - title (required, string, 10-100 characters)
  - description (optional, string, max 500 characters)
  - priority (optional, string, Critical|High|Medium|Low, default: Medium)
  - related_story (optional, string, related story ID)
  - tags (optional, string, comma-separated tags)
  - estimated_effort (optional, string, e.g. "2 hours", "1 day", default: TBD)
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - item_id (string, assigned backlog item ID)
  - backlog_updated (boolean, whether the backlog file was updated)
---

# Add Backlog Item

## Purpose
Add a new item to the story backlog. Supports three item types: follow-up actions from completed stories, technical debt items, and enhancement requests. Each item is categorized, prioritized, and linked to related stories for traceability.

## Prerequisites
- `docs/stories/backlog.md` exists (or will be created)
- Write permissions to the backlog file

## Steps

### 1. Elicit Item Details

Gather from user:

**Type of item:**
- F: Follow-up - Post-story action item
- T: Technical Debt - Code quality or architecture improvement
- E: Enhancement - Feature improvement or optimization

**Title:** 1-line description (10-100 characters)

**Detailed Description** (optional): Up to 500 characters

**Priority:**
- Critical
- High
- Medium (default)
- Low

**Related Story ID** (optional): Must reference an existing story file if provided

**Tags** (optional): Comma-separated list (e.g., "testing, performance, security")

**Estimated Effort** (optional): Free text (e.g., "2 hours", "1 day", "1 week")

### 2. Validate Input

- Verify the related story file exists (if a story ID was provided)
- If multiple story files match, use the first match and log a warning
- Parse comma-separated tags into a clean array
- Validate title length and priority value

### 3. Add Item to Backlog

Generate a unique item ID and add the item to the backlog data store with:
- Type, title, description
- Priority
- Related story reference
- Creator attribution
- Tags
- Estimated effort
- Creation timestamp

### 4. Regenerate Backlog File

Regenerate the `docs/stories/backlog.md` file with all items:
- Group items by type (Follow-ups, Technical Debt, Enhancements)
- Sort within each group by priority
- Include item metadata (ID, priority, tags, effort, related story)

### 5. Summary Output

```markdown
## Backlog Item Added

**ID:** {item_id}
**Type:** {type_name}
**Title:** {title}
**Priority:** {priority}
**Related Story:** {related_story or 'None'}
**Estimated Effort:** {effort}
**Tags:** {tags or 'None'}

**Next Steps:**
- Review in backlog: docs/stories/backlog.md
- Prioritize with *backlog-prioritize {item_id}
- Schedule with *backlog-schedule {item_id}
```

## Error Handling
- **Story not found:** Warn user, allow proceeding without related story link
- **Invalid type:** Show valid options (F, T, E) and re-prompt
- **Invalid priority:** Default to Medium with a warning
- **Backlog file locked:** Retry 3 times with 1-second delay between attempts
- **Backlog file missing:** Create it with header and the new item
- **Duplicate title:** Warn user but allow adding (different items may have similar titles)
