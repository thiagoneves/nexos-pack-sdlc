# Creating Packs

## Overview

A pack is a domain-specific collection of agents, tasks, workflows, templates, and rules. Packs are distributed as Git repositories.

## Quick Start

```bash
nexos create-pack my-pack-name
cd my-pack-name
```

This creates the standard pack structure:

```
my-pack-name/
├── pack.yaml           # Pack manifest
├── README.md
├── agents/             # Agent definitions
├── tasks/              # Task instructions
├── workflows/          # Workflow definitions
├── templates/          # File templates
└── rules/              # Rule files
```

## Step-by-Step

### 1. Define your pack.yaml

Edit `pack.yaml` with your pack metadata:

```yaml
pack:
  name: my-pack
  version: 1.0.0
  description: My custom domain pack
  author: your-github-username
  domain: my-domain

  agents:
    - agents/agent-a.md
    - agents/agent-b.md

  tasks:
    - tasks/task-a.md

  workflows:
    - workflows/workflow-a.yaml

  templates:
    - templates/template-a.md

  rules:
    - rules/rule-a.md
```

### 2. Create Agents

Follow the [agent schema](../core/schemas/agent.md):

```markdown
---
id: my-agent
title: My Agent
domain: my-domain
whenToUse: When to activate this agent.
---

# @my-agent — My Agent

## Role
What this agent does.

## Core Principles
1. First rule.

## Commands
| Command | Description |
|---------|-------------|
| *do-thing | Does the thing |
| *help | Show commands |
| *exit | Exit agent |

## Authority
**Allowed:** operations
**Blocked:** other operations
```

### 3. Create Tasks

Follow the [task schema](../core/schemas/task.md):

```markdown
---
task: my-task
agent: my-agent
inputs: [input-a]
outputs: [output-a]
---

# My Task

## Purpose
What this task does.

## Prerequisites
- What must be true.

## Steps
### 1. First Step
Do this.

## Error Handling
- What to do on error.
```

### 4. Create Workflows

Follow the [workflow schema](../core/schemas/workflow.md):

```yaml
workflow:
  id: my-workflow
  name: My Workflow
  description: What it does.

phases:
  - id: step-one
    agent: my-agent
    task: my-task.md
    next: done
```

### 5. Validate

```bash
nexos install ./my-pack-name
nexos validate
```

### 6. Publish

Push to GitHub and install from anywhere:

```bash
cd my-pack-name
git init && git add . && git commit -m "Initial pack"
gh repo create my-pack-name --public --push

# Now anyone can install it:
nexos install your-username/my-pack-name
```

## Tips

- Keep agents focused: one clear role per agent
- Tasks should be 60-150 lines — if longer, split into subtasks
- Reference the schemas in `nexos/core/schemas/` for format details
- Use `nexos validate` before publishing
