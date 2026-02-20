# Agent Authority Rules

## Delegation Matrix

### @devops — EXCLUSIVE Authority

| Operation | Exclusive? | Other Agents |
|-----------|-----------|--------------|
| `git push` / `git push --force` | YES | BLOCKED |
| `gh pr create` / `gh pr merge` | YES | BLOCKED |
| CI/CD pipeline management | YES | BLOCKED |
| Release management | YES | BLOCKED |

### @pm — Epic Orchestration

| Operation | Exclusive? |
|-----------|-----------|
| `*execute-epic` / `*create-epic` | YES |
| Requirements gathering | YES |
| Spec writing (spec pipeline) | YES |

### @po — Story Validation

| Operation | Exclusive? |
|-----------|-----------|
| `*validate` (10-point checklist) | YES |
| Story context tracking | YES |
| Backlog prioritization | YES |

### @sm — Story Creation

| Operation | Exclusive? |
|-----------|-----------|
| `*create` / `*draft` (from epic/PRD) | YES |
| Story template selection | YES |

### @dev — Implementation

| Allowed | Blocked |
|---------|---------|
| `git add`, `git commit`, `git status` | `git push` (delegate to @devops) |
| `git branch`, `git checkout`, `git merge` (local) | `gh pr create/merge` (delegate to @devops) |
| `git stash`, `git diff`, `git log` | Story structure edits (AC, scope, title) |
| Story file: checkboxes, File List, Dev Agent Record | — |

### @architect — Design Authority

| Owns | Delegates To |
|------|-------------|
| System architecture decisions | — |
| Technology selection | — |
| High-level data architecture | @data-engineer (detailed DDL) |
| Integration patterns | @data-engineer (query optimization) |

### @data-engineer — Database

| Owns (delegated from @architect) | Does NOT Own |
|----------------------------------|-------------|
| Schema design (detailed DDL) | System architecture |
| Query optimization, RLS policies | Application code |
| Index strategy, migrations | Git remote operations |

### @master — Framework Governance

| Capability | Details |
|-----------|---------|
| Execute ANY task directly | No restrictions |
| Override agent boundaries | When necessary for framework health |

## Cross-Agent Flows

```
Git Push:      ANY agent → @devops *push
Schema:        @architect → @data-engineer (implements DDL)
Story:         @sm *create → @po *validate → @dev *develop → @qa *qa-gate → @devops *push
Epic:          @pm *create-epic → @sm *create (per story)
```

## Escalation Rules

1. Agent cannot complete task → Escalate to @master
2. Quality gate fails → Return to @dev with specific feedback
3. Agent boundary conflict → @master mediates
