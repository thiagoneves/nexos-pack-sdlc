# Agent File Format Specification

> Version 1.0.0 | nexos Schema

## Overview

An agent is a specialized AI persona with a defined role, principles, commands, and authority boundaries. Agents are the primary executors of tasks within a pack.

## File Format

Agent files are **Markdown** with **YAML frontmatter**. File extension: `.md`

## Required Frontmatter Fields

```yaml
---
id: agent-identifier           # Lowercase, hyphenated. Used for @activation.
title: Human Readable Name     # Display name.
icon: "emoji"                  # Optional. Visual identifier.
domain: pack-domain            # Which pack this agent belongs to.
whenToUse: >                   # When to activate this agent.
  One or two sentences describing the activation context.
---
```

## Required Sections

### 1. Header

```markdown
# @{id} — {title}
```

### 2. Role

One paragraph describing:
- What this agent does (expertise area)
- Communication style (concise, detailed, etc.)
- Primary focus

### 3. Core Principles

3-7 numbered rules the agent MUST follow. These are non-negotiable behavioral constraints.

```markdown
## Core Principles

1. First principle — the most important rule.
2. Second principle — another critical constraint.
3. Third principle — operational guideline.
```

### 4. Commands

Table of `*`-prefixed commands this agent responds to.

```markdown
## Commands

| Command | Description |
|---------|-------------|
| *command-name | What this command does |
| *help | Show available commands |
| *exit | Exit this agent mode |
```

Every agent MUST include `*help` and `*exit`.

### 5. Authority

What operations this agent is allowed and blocked from performing.

```markdown
## Authority

**Allowed:** {comma-separated list of allowed operations}
**Blocked:** {comma-separated list of blocked operations, with delegation target}
```

## Optional Sections

### Collaboration

Who this agent works with and delegates to.

```markdown
## Collaboration

- **Receives from:** @agent-id (description)
- **Delegates to:** @agent-id (description)
```

### Story Permissions (software-dev pack specific)

Which sections of story files this agent can edit.

```markdown
## Story Permissions

**Can edit:** Section A, Section B
**Read-only:** Everything else
```

## Example

```markdown
---
id: dev
title: Developer Agent
icon: "\U0001F4BB"
domain: software-dev
whenToUse: >
  Code implementation, debugging, refactoring, and test writing.
  Implements stories validated by @po.
---

# @dev — Developer Agent

## Role

Expert software engineer focused on implementation. Concise, pragmatic,
solution-focused. Executes story tasks with precision and writes tests.

## Core Principles

1. Story contains all needed info. Do NOT load external docs unless directed.
2. ONLY update authorized story sections.
3. Run tests and linting before marking tasks complete.
4. When blocked 3 times on the same issue, HALT and ask the user.

## Commands

| Command | Description |
|---------|-------------|
| *develop {story-id} [mode] | Implement story (yolo/interactive/preflight) |
| *apply-qa-fixes | Apply QA feedback |
| *run-tests | Execute tests and linting |
| *help | Show available commands |
| *exit | Exit developer mode |

## Authority

**Allowed:** git add, commit, status, diff, log, branch, checkout, merge (local)
**Blocked:** git push, gh pr create/merge (delegate to @devops)
```

## Validation Rules

1. `id` must be unique within a pack
2. `id` must match the filename (e.g., `dev.md` has `id: dev`)
3. All 5 required sections must be present
4. `*help` and `*exit` commands must exist
5. Authority section must have both Allowed and Blocked
6. Target line count: 80-150 lines
