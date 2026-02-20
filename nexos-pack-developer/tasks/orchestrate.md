---
task: orchestrate
agent: master
workflow: support
inputs: [user command, workflow context, project state]
outputs: [workflow execution or agent delegation, state files, progress reports]
---

# Orchestrate

## Purpose

Central orchestration task for the @master agent. Routes user requests to the
appropriate workflow or agent, manages workflow state, and handles cross-agent
coordination. This is the primary entry point for all user commands that require
multi-step execution or delegation.

The orchestrator acts as a traffic controller: it parses intent, selects the
right workflow, initializes state, launches the first phase, and monitors
execution through phase transitions. It does NOT execute work itself -- it
delegates to the specialized agents and tasks that own each capability.

---

## Prerequisites

- Active project with configured workflows
- Agent definitions available in the pack
- Story directory accessible (for status and resume operations)
- Configuration file (`config.yaml`) present with project paths
- At least one workflow definition available (SDC, Spec Pipeline, Brownfield, QA Loop)

---

## Execution Modes

### 1. Autopilot Mode -- Fast, Autonomous (0-1 prompts)

- Route to the most likely workflow without confirmation
- Auto-select default options at every decision point
- Log all routing decisions in `orchestration-log-{timestamp}.md`
- Skip ambiguity resolution -- use best-match heuristics
- **Best for:** Experienced teams, well-defined commands, CI/CD triggers

### 2. Interactive Mode -- Balanced, Educational (3-8 prompts) **[DEFAULT]**

- Confirm workflow selection with the user before starting
- Present options as numbered lists when ambiguity exists
- Explain what each workflow does when the user is unfamiliar
- Confirm before delegating to agents with exclusive authority
- **Best for:** Standard operations, new team members, complex routing

### 3. Pre-Flight Mode -- Comprehensive Analysis

- Analyze the full request before any action
- Map the request to all possible workflows with pros/cons
- Show the complete execution plan (phases, agents, estimated time)
- Present dependency analysis and risk factors
- Require explicit user approval before starting
- **Best for:** Large initiatives, multi-workflow orchestrations, high-risk operations

**Default mode:** Interactive

---

## Steps

### 1. Parse User Request

Determine the intent of the incoming command. Classify into one of these
categories:

| Category | Signal Words / Patterns |
|----------|------------------------|
| Start Workflow | "start", "begin", "create", "develop", "implement", "spec", "assess" |
| Delegate to Agent | "@agent-name", agent-specific commands |
| Check Status | "status", "progress", "where are we", "show" |
| Resume Workflow | "resume", "continue", "pick up", "restart" |
| Epic Operations | "epic", "plan", "breakdown", "initiative" |
| Backlog Operations | "backlog", "prioritize", "review stories" |

**Intent resolution rules:**

1. If the command starts with `@agent-name`, treat as agent delegation
2. If the command references a specific story ID, check its status to determine context
3. If the command matches multiple categories, rank by specificity (most specific wins)
4. If the intent is ambiguous, ask the user a single clarifying question before proceeding

**Example ambiguity resolution:**
```
User: "work on the login feature"
-> Could be: Start SDC? Create spec? Create epic?
-> Ask: "Would you like to (1) develop an existing story, (2) create a spec
   for this feature, or (3) plan an epic for the login feature?"
```

### 2. Identify Appropriate Workflow

Match the request to one of the primary workflows:

| Request Pattern | Workflow | Entry Point |
|-----------------|----------|-------------|
| New story, implement feature, develop | Story Development Cycle (SDC) | Phase 1: @sm creates story |
| Spec, requirements, plan feature | Spec Pipeline | Phase 1: @pm gathers requirements |
| Assess existing codebase, tech debt | Brownfield Discovery | Phase 1: @architect system analysis |
| Review issues, fix loop, QA iteration | QA Loop | @qa review entry |
| Create epic, plan initiative, breakdown | Epic Creation | @pm create-epic task |
| Manage backlog, prioritize, review | Backlog Management | @po po-manage-backlog task |

If no workflow matches, treat the request as a direct agent delegation.

### 3. Validate Preconditions

Before starting any workflow, verify its prerequisites:

**For Story Development Cycle:**
- [ ] Stories directory exists
- [ ] At least one story in Ready status (or a Draft to be validated first)
- [ ] Target story file is parseable

**For Spec Pipeline:**
- [ ] Requirements input available (user conversation or PRD reference)
- [ ] Spec output directory configured

**For Brownfield Discovery:**
- [ ] Source code accessible
- [ ] Architecture output directory configured

**For QA Loop:**
- [ ] Target story is in InProgress or InReview status
- [ ] Previous QA results available (or this is the first pass)

**For Epic Creation:**
- [ ] Epics directory exists (or can be created)
- [ ] User has context to provide (goals, scope, constraints)

If prerequisites fail, report exactly what is missing and suggest how to fix it.

### 4. Initialize Workflow State

When a workflow is identified and preconditions are met:

1. Generate a unique execution ID: `{workflow-type}-{date}-{sequence}`
2. Create a state record with:
   ```yaml
   execution_id: {id}
   workflow: {workflow type}
   started_at: {timestamp}
   current_phase: 1
   current_agent: {first agent}
   status: active
   phases_completed: []
   context: {relevant inputs from user}
   ```
3. Save state for resume capability (in memory or project state directory)
4. Log the workflow start in the orchestration log

### 5. Handle Workflow Execution

Launch the first phase of the identified workflow:

1. Identify the responsible agent for Phase 1
2. Verify the agent has authority for the operation (per agent-authority rules)
3. Pass the user's request and workflow context to the agent's task
4. Wait for phase completion

**Phase transition protocol:**
```
Phase N completes -> Validate phase output -> Update state ->
  Identify Phase N+1 agent -> Verify agent authority ->
  Pass context + Phase N output -> Start Phase N+1
```

**Cross-agent handoff format:**
```
Handoff: {Phase N agent} -> {Phase N+1 agent}
Context: {summary of what Phase N produced}
Input: {specific artifacts passed}
Expected output: {what Phase N+1 should produce}
```

### 6. Handle Agent Delegation

When routing directly to a specific agent (not a workflow):

1. Verify the agent exists and is defined in the pack
2. Check the agent has authority for the requested operation:
   - @devops: git push, PR creation, CI/CD operations
   - @pm: epic orchestration, requirements, spec writing
   - @po: story validation, backlog prioritization
   - @sm: story creation
   - @dev: implementation, local git operations
   - @qa: review, quality gates
   - @architect: design decisions, complexity assessment
3. Pass the user's request and any relevant context to the agent
4. Monitor for completion or escalation

**If authority violation detected:**
```
BLOCK: @{requesting_agent} cannot perform {operation}.
This operation requires @{authorized_agent}.
Delegating to @{authorized_agent}...
```

### 7. Handle Status Request

Delegate to the `orchestrate-status` task:
- Pass current workflow state (if any active workflow)
- Pass list of known active stories and their statuses
- Request the template from `templates/status-report.md`

### 8. Handle Resume Request

Delegate to the `orchestrate-resume` task:
- Pass any saved workflow state information
- Pass current project state for validation
- Let the resume task handle user confirmation

### 9. Monitor Execution

Throughout workflow execution, the orchestrator maintains awareness of:

**Progress tracking:**
- Phase transitions: log each transition with timestamp
- Agent handoffs: log the handoff with context passed
- Decision points: log decisions and their rationale (especially in Autopilot mode)

**Health monitoring:**
- Agent completion: did the agent finish its phase?
- Escalation requests: did any agent request help?
- Timeout detection: is a phase taking unusually long?

**User communication:**
- Report phase transitions to the user
- Summarize what each phase produced before starting the next
- Highlight any warnings or concerns raised during execution

### 10. Handle Workflow Completion

When all phases of a workflow complete:

1. Compile a completion summary:
   - Workflow type and execution ID
   - Phases completed with timestamps
   - Artifacts produced (files created/modified)
   - Quality gate results (if applicable)
   - Next recommended actions
2. Update state to `completed`
3. Present the summary to the user
4. Suggest follow-up actions based on the workflow type

---

## Output Format

### Workflow Start Confirmation

```
=== Orchestrator: Starting {Workflow Name} ===
Execution ID: {id}
Mode: {Autopilot / Interactive / Pre-Flight}

Phase Plan:
  1. {phase} -- @{agent} -- {task}
  2. {phase} -- @{agent} -- {task}
  ...

Starting Phase 1: {description}...
```

### Phase Transition Report

```
--- Phase {N} Complete ---
Agent: @{agent}
Result: {summary of output}
Duration: {time}

-> Starting Phase {N+1}: {description}
  Agent: @{next_agent}
  Input: {what is being passed}
```

### Workflow Completion Summary

```
=== Workflow Complete: {Workflow Name} ===
Execution ID: {id}
Duration: {total time}
Phases: {completed}/{total}

Artifacts:
  - {file 1}: {description}
  - {file 2}: {description}

Results:
  - {key result 1}
  - {key result 2}

Recommended Next Steps:
  1. {action 1}
  2. {action 2}
```

---

## Workflow Quick Reference

### Story Development Cycle (SDC)

| Phase | Agent | Task | Output |
|-------|-------|------|--------|
| 1. Create | @sm | create-next-story | Story file (Draft) |
| 2. Validate | @po | validate-next-story | Validated story (Ready) |
| 3. Implement | @dev | dev-develop-story | Code + tests (InProgress) |
| 4. QA Gate | @qa | qa-gate | QA verdict (InReview -> Done) |

### Spec Pipeline

| Phase | Agent | Task | Output |
|-------|-------|------|--------|
| 1. Gather | @pm | spec-gather-requirements | requirements data |
| 2. Assess | @architect | spec-assess-complexity | complexity analysis |
| 3. Research | @analyst | spec-research-dependencies | research findings |
| 4. Write | @pm | spec-write-spec | spec document |
| 5. Critique | @qa | spec-critique | critique verdict |

### Brownfield Discovery

| Phase | Agent | Task | Output |
|-------|-------|------|--------|
| 1. Architecture | @architect | document-project | system architecture |
| 2. Database | @data-engineer | db-schema-audit | schema audit |
| 3. Frontend | @ux-expert | ux-scan-artifact | frontend spec |
| 4-10. | Various | (assessment, review, report) | technical debt assessment |

### QA Loop

```
@qa review -> verdict ->
  APPROVE -> Done
  REJECT  -> @dev fixes -> @qa re-review (max 5 iterations)
  BLOCKED -> Escalate
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success -- workflow completed |
| 1 | Pipeline failed -- phase error |
| 2 | Pipeline blocked -- gate failure |
| 3 | Invalid arguments or unknown command |

---

## Error Handling

- **Unknown command** -- Present the list of available workflows and agent commands. Ask the user to rephrase. If in Autopilot mode, log the failure and halt.

- **Agent unavailable** -- Suggest an alternative agent if one exists, or escalate to the user with options. Example: "The @analyst agent is not configured. You can (1) skip the research phase or (2) handle research manually."

- **Workflow conflict** -- If multiple workflows could apply, present the options with a brief explanation and let the user choose. In Autopilot mode, select the most specific match.

- **Missing inputs** -- List the required inputs that are missing and ask the user to provide them before proceeding. Be specific: "The Spec Pipeline requires requirements input. Please describe the feature you want to spec, or point to an existing PRD."

- **Phase failure** -- Log the failure with full context. Offer three options: (1) retry the phase, (2) skip with documented justification, (3) abort the workflow.

- **Agent escalation** -- When an agent reports it cannot complete its phase, capture the reason, present it to the user, and offer to (1) provide additional context, (2) reassign to a different agent, or (3) abort.

- **Authority violation** -- Block the operation immediately. Report which agent has authority and offer to delegate. Never silently bypass authority rules.

- **State corruption** -- If workflow state becomes inconsistent, report the inconsistency, offer to restart from the last known good phase, or clean up and start fresh.

---

## Examples

### Example 1: Starting a Story Development Cycle

```
User: "I want to develop the user authentication feature"

Orchestrator (Interactive mode):
  -> Parses intent: "develop" + "feature" -> SDC workflow
  -> Checks for existing stories matching "user authentication"
  -> Found: story 3.2 "User Authentication Flow" (status: Ready)
  -> Confirms: "I found story 3.2 'User Authentication Flow' in Ready status.
    Shall I start the Story Development Cycle for this story?"
  -> User: "Yes"
  -> Starts SDC Phase 3 (story already created and validated)
  -> Delegates to @dev with dev-develop-story task
```

### Example 2: Handling Ambiguous Request

```
User: "Let's work on payments"

Orchestrator (Interactive mode):
  -> Parses intent: ambiguous -- could be SDC, Spec, or Epic
  -> No existing stories found for "payments"
  -> Asks: "I don't see existing stories for payments. Would you like to:
    1. Create an epic to plan the payments feature
    2. Start a spec pipeline to define requirements
    3. Something else?"
  -> User: "1"
  -> Delegates to @pm with create-epic task
```

### Example 3: Agent Delegation

```
User: "@qa review story 5.1"

Orchestrator:
  -> Parses intent: agent delegation to @qa
  -> Verifies @qa authority for review operations: OK
  -> Passes to @qa with qa-review-story task and story ID 5.1
```

---

## Notes

- The orchestrator NEVER performs implementation work. It routes, coordinates, and monitors.
- In Autopilot mode, all routing decisions are logged for auditability.
- The orchestrator respects agent authority boundaries at all times. See `agent-authority` rules.
- When a workflow is interrupted (session end, user command, error), state is preserved for the `orchestrate-resume` task to pick up.
- The orchestrator uses `templates/status-report.md` when generating status reports.
- For epic-level orchestration, delegate to the `create-epic` or epic execution tasks rather than handling epics inline.
- Phase timeout defaults: 30 minutes for automated phases, no timeout for interactive phases.

---

## Related Tasks

| Task | Relationship |
|------|-------------|
| `orchestrate-status` | Delegated for status queries |
| `orchestrate-resume` | Delegated for resume operations |
| `create-epic` | Delegated for epic creation requests |
| `create-next-story` | SDC Phase 1 |
| `validate-next-story` | SDC Phase 2 |
| `dev-develop-story` | SDC Phase 3 |
| `qa-gate` | SDC Phase 4 |
| `po-manage-backlog` | Backlog management delegation |

## Related Templates

| Template | Usage |
|----------|-------|
| `templates/status-report.md` | Status report format |
| `templates/epic.md` | Epic document format |
| `templates/story.md` | Story document format |
