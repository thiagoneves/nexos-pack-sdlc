---
task: po-stories-index
agent: po
inputs:
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
  - action (optional, string, yes|preview, default: prompted interactively)
outputs:
  - index_file (string, path to generated index file)
  - total_stories (number, count of stories found)
  - stories_by_epic (object, story counts grouped by epic)
  - stories_by_status (object, story counts grouped by status)
---

# Regenerate Story Index

## Purpose
Scan the `docs/stories/` directory to regenerate a comprehensive story index file. Produces a structured overview of all stories grouped by epic and status, with links and metadata for quick navigation.

## Prerequisites
- `docs/stories/` directory exists
- At least one story file exists in the directory tree
- Write permissions to `docs/stories/index.md`

## Steps

### 1. Confirm Regeneration

Present the user with options:
- **yes**: Proceed with full regeneration
- **preview**: Show current stats without writing any files
- **no**: Cancel the operation

### 2. Scan Stories Directory

Recursively scan `docs/stories/` for all story files (`.md` files matching story naming patterns).

For each story file found:
- Extract story ID from the filename or frontmatter
- Extract title
- Extract status (Draft, Ready, InProgress, InReview, Done)
- Extract priority
- Determine the parent epic (from directory structure)

### 3. Group and Organize

- Group stories by epic
- Within each epic, sort stories by ID
- Calculate statistics:
  - Total story count
  - Stories per epic
  - Stories per status
  - Completion percentages

### 4. Generate Index File

Write `docs/stories/index.md` with:

```markdown
# Story Index

**Total Stories:** {count}
**Last Updated:** {date}

## Stories by Epic

### {Epic Name} ({count} stories)
| ID | Title | Status | Priority |
|----|-------|--------|----------|
| {id} | [{title}]({path}) | {status} | {priority} |

## Stories by Status

| Status | Count | Percentage |
|--------|-------|------------|
| Done | {n} | {%} |
| InProgress | {n} | {%} |
| Ready | {n} | {%} |
| Draft | {n} | {%} |
```

### 5. Preview Mode

If `preview` was selected:
- Display the same statistics to the console
- Do not write any files
- Suggest running with `yes` to generate the index

### 6. Display Summary

```
Story Index Updated
===================
Total Stories: {count}
Output File: docs/stories/index.md

Stories by Epic:
- Epic 6.1 AIOS Migration: 45 stories
- Epic 3 Gap Remediation: 20 stories
- Unassigned: 5 stories

Stories by Status:
- Done: 30
- InProgress: 10
- Ready: 15
- Draft: 15

Next Steps:
- Review index: docs/stories/index.md
- Use *backlog-review to see backlog items
- Use *create-story to add new stories
```

## Error Handling
- **No stories found:** Warn user, create empty index with a note
- **Invalid story metadata:** Log warnings for malformed stories, skip them in the index
- **Permission denied:** Check file permissions on `docs/stories/`
- **Write failed:** Verify `docs/stories/` directory exists, create if needed
- **Duplicate story IDs:** Log warning, include both with disambiguation note
