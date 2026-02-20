# Schema Reference

## Overview

nexos defines 4 schemas for framework content. All schemas are documented in `core/schemas/`.

## Quick Reference

| Schema | Format | Location |
|--------|--------|----------|
| [Agent](../core/schemas/agent.md) | Markdown + YAML frontmatter | `agents/*.md` |
| [Task](../core/schemas/task.md) | Markdown + YAML frontmatter | `tasks/*.md` |
| [Workflow](../core/schemas/workflow.md) | YAML | `workflows/*.yaml` |
| [Pack](../core/schemas/pack.md) | YAML | `pack.yaml` |

## Agent Schema Summary

```yaml
# Frontmatter (required)
id: lowercase-hyphenated    # Must match filename
title: Display Name
domain: pack-domain
whenToUse: When to activate

# Sections (required)
## Role                     # Expertise + style
## Core Principles          # 3-7 numbered rules
## Commands                 # Table with *commands
## Authority                # Allowed + Blocked
```

## Task Schema Summary

```yaml
# Frontmatter (required)
task: lowercase-hyphenated  # Must match filename
agent: executor-agent-id
inputs: [list]
outputs: [list]

# Sections (required)
## Purpose                  # 1-2 sentences
## Prerequisites            # What must be true
## Steps                    # Numbered steps
## Error Handling           # Recovery instructions
```

## Workflow Schema Summary

```yaml
workflow:
  id: lowercase-hyphenated  # Must match filename
  name: Display Name
  description: What it does
phases:
  - id: phase-id
    agent: agent-id
    task: task-file.md
    next: next-phase-id
    decision:               # Optional
      OUTCOME: target-phase
```

## Pack Schema Summary

```yaml
pack:
  name: lowercase-hyphenated
  version: semver
  description: What it provides
  author: github-username
  domain: domain-id
  agents: [file list]
  tasks: [file list]
  workflows: [file list]
  templates: [file list]
  rules: [file list]
```
