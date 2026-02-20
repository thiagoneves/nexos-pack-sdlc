# Pack Manifest Format Specification

> Version 1.0.0 | nexos Schema

## Overview

A pack is a domain-specific collection of agents, tasks, workflows, templates, and rules. Packs are distributed as independent Git repositories and installed into projects via the nexos CLI.

## File Format

The pack manifest is **YAML**. Filename: `pack.yaml` (must be at the repository root).

## Required Fields

```yaml
pack:
  name: pack-name                # Lowercase, hyphenated. Unique identifier.
  version: 1.0.0                 # Semantic versioning.
  description: >                 # What this pack provides.
    Brief description of the pack's domain and purpose.
  author: author-name            # GitHub username or organization.
  domain: domain-identifier      # Domain category (e.g., software-dev, content-creation).
```

## Content Listings

List all files included in the pack. Paths are relative to the pack root.

```yaml
  agents:
    - agents/agent-a.md
    - agents/agent-b.md

  tasks:
    - tasks/task-a.md
    - tasks/task-b.md

  workflows:
    - workflows/workflow-a.yaml

  templates:
    - templates/template-a.md

  rules:
    - rules/rule-a.md
```

## Optional Fields

```yaml
  # Pack-specific config defaults (merged into .nexos/config.yaml on install)
  config:
    stories:
      location: docs/stories
    qa:
      coderabbit: true

  # Minimum nexos version required
  requires: ">=1.0.0"

  # Dependencies on other packs (auto-installed by nexos install)
  dependencies:
    - name: other-pack
      repo: user/nexos-pack-other    # GitHub repo (user/repo format)
      version: ">=1.0.0"            # Semver constraint

  # Lifecycle hooks (bash commands, run from pack directory)
  hooks:
    post-install: "scripts/setup.sh"       # After pack is installed
    post-generate: "scripts/validate.sh"   # After tool files are generated
    pre-remove: "scripts/cleanup.sh"       # Before pack is removed

  # Tags for discovery
  tags: [agile, scrum, quality-gates]

  # License
  license: MIT
```

## Dependencies

Packs can declare dependencies on other packs. When `nexos install` is run, dependencies are resolved recursively (max depth: 10). Circular dependencies are detected and blocked.

```yaml
  dependencies:
    - name: core-utils          # Pack name (as in pack.yaml name field)
      repo: user/nexos-pack-core-utils   # GitHub source
      version: ">=1.0.0"        # Minimum version
```

If a dependency is already installed, it is skipped. If not, it is cloned and installed automatically.

## Hooks

Hooks allow packs to run custom scripts at lifecycle events. Commands are executed from the pack directory using bash.

| Hook | Trigger | Use Case |
|------|---------|----------|
| `post-install` | After pack is copied to `.nexos/packs/` | Run setup, validate environment |
| `post-generate` | After adapter generates tool files | Validate output, add custom files |
| `pre-remove` | Before pack directory is deleted | Cleanup, remove generated artifacts |

If a hook fails (non-zero exit), a warning is logged but the operation continues.

## Lock File

After every `nexos install` or `nexos remove`, a lock file is written at `.nexos/lock.yaml`. It records the exact version, commit hash, and install timestamp of every pack. Use `nexos lock` to inspect it.

## Directory Structure

A pack repository MUST follow this structure:

```
pack-name/
├── pack.yaml           # Pack manifest (required, at root)
├── README.md           # Pack documentation (recommended)
├── agents/             # Agent definitions
│   └── *.md
├── tasks/              # Task definitions
│   └── *.md
├── workflows/          # Workflow definitions
│   └── *.yaml
├── templates/          # File templates
│   └── *.*
└── rules/              # Rule files
    └── *.md
```

## Example

```yaml
pack:
  name: software-dev
  version: 1.0.0
  description: >
    Agile software development pack with story-driven workflows,
    quality gates, and a full development team of 12 agents.
  author: thiagoneves
  domain: software-development
  license: MIT
  tags: [agile, scrum, quality-gates, story-driven]

  agents:
    - agents/dev.md
    - agents/qa.md
    - agents/architect.md
    - agents/pm.md
    - agents/po.md
    - agents/sm.md
    - agents/devops.md
    - agents/analyst.md
    - agents/data-engineer.md
    - agents/ux-designer.md
    - agents/master.md
    - agents/squad-creator.md

  tasks:
    - tasks/create-next-story.md
    - tasks/validate-next-story.md
    - tasks/dev-develop-story.md
    - tasks/qa-gate.md
    # ... (20 total)

  workflows:
    - workflows/story-development-cycle.yaml
    - workflows/spec-pipeline.yaml
    - workflows/brownfield-discovery.yaml
    - workflows/qa-loop.yaml

  templates:
    - templates/story.md

  rules:
    - rules/story-lifecycle.md
    - rules/workflow-execution.md
    - rules/agent-authority.md
    - rules/coderabbit-integration.md

  config:
    stories:
      location: docs/stories
    qa:
      coderabbit: true
      location: docs/qa

  # Optional: dependencies on other packs
  # dependencies:
  #   - name: core-utils
  #     repo: thiagoneves/nexos-pack-core-utils
  #     version: ">=1.0.0"

  # Optional: lifecycle hooks
  # hooks:
  #   post-install: "scripts/setup.sh"
  #   post-generate: "scripts/validate.sh"
  #   pre-remove: "scripts/cleanup.sh"

  requires: ">=1.0.0"
```

## Validation Rules

1. `pack.yaml` must exist at the repository root
2. `name` must be lowercase, hyphenated, and unique
3. `version` must follow semantic versioning (MAJOR.MINOR.PATCH)
4. All listed files must exist in the repository
5. All agent files must conform to the agent schema
6. All task files must conform to the task schema
7. All workflow files must conform to the workflow schema
8. `domain` should be consistent across all agent `domain` fields
