# Task File Format Specification

> Version 1.0.0 | nexos Schema

## Overview

A task is a set of sequential instructions that an agent follows to accomplish a specific objective. Tasks are the atomic units of work within workflows.

## File Format

Task files are **Markdown** with **YAML frontmatter**. File extension: `.md`

## Required Frontmatter Fields

```yaml
---
task: task-identifier          # Lowercase, hyphenated. Unique within pack.
agent: agent-id                # Default executor agent.
workflow: workflow-id (phase)  # Optional. Which workflow phase this belongs to.
inputs: [list of inputs]       # What the task needs to start.
outputs: [list of outputs]     # What the task produces.
---
```

## Required Sections

### 1. Header

```markdown
# {Task Name}
```

Human-readable name matching the task purpose.

### 2. Purpose

1-2 sentences explaining what this task accomplishes and why.

```markdown
## Purpose

Create the next logical story from the epic using the story template.
```

### 3. Prerequisites

What must be true before this task can start.

```markdown
## Prerequisites

- Config file exists with required settings
- Previous story is completed (status: Done)
```

### 4. Steps

Sequential, numbered steps with clear instructions. Each step should be actionable by the AI agent.

```markdown
## Steps

### 1. Load Configuration
Read `.nexos/config.yaml` and extract relevant settings.

### 2. Identify Target
Determine what needs to be created or modified.

### 3. Execute
Perform the main operation.

### 4. Verify
Check that outputs are correct and complete.
```

### 5. Error Handling

What to do when things go wrong.

```markdown
## Error Handling

- **Config missing:** HALT, inform user to create config.
- **Dependency not met:** List missing dependencies, suggest resolution.
- **Partial completion:** Save progress, report what was completed.
```

## Optional Sections

### Decision Points

For tasks with branching logic.

```markdown
## Decision Points

### At Step 3
- If condition A: proceed to Step 4
- If condition B: skip to Step 6
- If condition C: HALT and escalate
```

### Acceptance Criteria

How to verify the task was completed correctly.

```markdown
## Acceptance Criteria

- [ ] Output file exists and is well-formed
- [ ] All required sections are populated
- [ ] No validation errors
```

## Example

```markdown
---
task: create-next-story
agent: sm
workflow: story-development-cycle (phase 1)
inputs: [epic context, config.yaml]
outputs: ["{epicNum}.{storyNum}.story.md"]
---

# Create Next Story

## Purpose

Identify the next logical story from the epic and create a story file
using the standard template.

## Prerequisites

- `.nexos/config.yaml` exists with `stories.location` setting
- Epic file exists with remaining stories to implement

## Steps

### 1. Load Configuration
Read `.nexos/config.yaml`. Extract `stories.location` and `prd` settings.

### 2. Identify Next Story
Check existing stories in the configured location. Find the highest
`{epicNum}.{storyNum}.story.md`. Announce the next story number.

### 3. Gather Context
Extract requirements from the epic file. Review previous story completion notes.

### 4. Create Story File
Use the story template. Fill in title, story statement, acceptance criteria.
Save to the configured stories location.

### 5. Verify
Confirm all sections are populated. Report: file created, status Draft.

## Error Handling

- **Config missing:** HALT, tell user to run `nexos init`.
- **Epic not found:** HALT, tell user which epic file is expected.
- **Template missing:** HALT, tell user to install the pack.
```

## Validation Rules

1. `task` must be unique within a pack
2. `task` must match the filename (e.g., `create-next-story.md` has `task: create-next-story`)
3. `agent` must reference a valid agent id from the same pack or nexos core
4. All 5 required sections must be present
5. Steps must be numbered sequentially
6. Target line count: 60-150 lines
