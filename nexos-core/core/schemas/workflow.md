# Workflow File Format Specification

> Version 1.0.0 | nexos Schema

## Overview

A workflow is a multi-phase process that connects tasks and agents into a structured sequence with decision points. Workflows define the "how" of complex processes.

## File Format

Workflow files are **YAML**. File extension: `.yaml`

## Required Fields

```yaml
workflow:
  id: workflow-identifier        # Lowercase, hyphenated. Unique within pack.
  name: Human Readable Name      # Display name.
  description: >                 # What this workflow accomplishes.
    One or two sentences.

phases:                          # Ordered list of phases.
  - id: phase-identifier         # Unique within this workflow.
    name: Phase Name             # Human-readable name.
    agent: agent-id              # Which agent executes this phase.
    task: task-filename.md       # Which task file to follow.
    next: next-phase-id          # Default next phase (or "done").
```

## Optional Phase Fields

```yaml
phases:
  - id: phase-id
    name: Phase Name
    agent: agent-id
    task: task-file.md
    next: next-phase-id

    # Decision point — overrides 'next' based on outcome
    decision:
      OUTCOME_A: phase-id-a      # Go to this phase on outcome A
      OUTCOME_B: phase-id-b      # Go to this phase on outcome B

    # Execution modes (if the task supports multiple)
    modes: [mode-a, mode-b, mode-c]

    # Conditions for skipping this phase
    skip_if: "condition description"

    # Whether this phase can run in parallel with others
    parallel_with: [other-phase-id]
```

## Optional Workflow Fields

```yaml
workflow:
  id: ...
  name: ...
  description: ...
  domain: pack-domain            # Which pack this belongs to.
  triggers: [list]               # What initiates this workflow.
  config:                        # Workflow-level configuration.
    max_iterations: 5
    timeout_minutes: 60

flow: |                          # Optional ASCII flow diagram.
  @agent1 phase1 -> @agent2 phase2 -> @agent3 phase3
```

## Example

```yaml
workflow:
  id: story-development-cycle
  name: Story Development Cycle
  description: >
    4-phase workflow for all development: Create story, validate,
    implement, and QA review.

phases:
  - id: create
    name: Story Creation
    agent: sm
    task: create-next-story.md
    next: validate

  - id: validate
    name: Story Validation
    agent: po
    task: validate-next-story.md
    decision:
      GO: implement
      NO-GO: create
    next: implement

  - id: implement
    name: Implementation
    agent: dev
    task: dev-develop-story.md
    modes: [yolo, interactive, preflight]
    next: review

  - id: review
    name: QA Gate
    agent: qa
    task: qa-gate.md
    decision:
      PASS: done
      CONCERNS: done
      FAIL: implement
      WAIVED: done

flow: |
  @sm create -> @po validate -> @dev implement -> @qa review
                     |                                 |
                   NO-GO -> @sm                   FAIL -> @dev
```

## Validation Rules

1. `id` must be unique within a pack
2. `id` must match the filename (e.g., `story-development-cycle.yaml`)
3. All `agent` references must be valid agent ids
4. All `task` references must be valid task filenames in the same pack
5. All `next` and decision target values must reference valid phase ids or "done"
6. No circular references without explicit max_iterations config
7. Target line count: 40-80 lines
