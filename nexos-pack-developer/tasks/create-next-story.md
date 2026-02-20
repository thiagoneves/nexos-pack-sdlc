---
task: create-next-story
agent: sm
inputs:
  - config.yaml (project configuration)
  - epic context (PRD shards, epic files)
  - architecture documentation
  - story template
outputs:
  - "{epicNum}.{storyNum}.story.md"
---

# Create Next Story

## Purpose

Identify the next logical story in an epic based on project progress, then generate a comprehensive, self-contained, and actionable story file using the standard story template. The story must be enriched with all necessary technical context, requirements, and acceptance criteria so that a developer agent can implement it with minimal need for additional research or context discovery.

This task is Phase 1 of the Story Development Cycle (SDC).

## Prerequisites

- [ ] An epic exists with defined scope and a story breakdown.
- [ ] PRD or epic documentation is available with requirements to draw from.
- [ ] The story template exists at `templates/story.md` (pack or project level).
- [ ] The project `config.yaml` is accessible and defines the stories directory location.
- [ ] Architecture documentation is available (sharded or monolithic) for technical context.
- [ ] If resuming an epic, the previous story is in `Done` status or the user has explicitly approved continuing.

## Execution Modes

### 1. Autopilot Mode -- Fast, Autonomous (0-1 prompts)

- Reads epic/PRD, identifies the next story, and creates it autonomously.
- Makes all decisions (scope boundaries, AC granularity, task breakdown) without prompting.
- Logs all decisions for transparency.
- **Best for:** Sequential stories in a well-defined epic where the story breakdown is detailed.

### 2. Interactive Mode -- Balanced, Collaborative (3-7 prompts) **[DEFAULT]**

- Presents the identified next story and its extracted requirements for user review.
- Asks for confirmation at key decision points (epic selection, scope boundaries, AC completeness, task breakdown).
- **Best for:** Standard story creation where some judgment calls are needed.

### 3. Pre-Flight Mode -- Comprehensive Upfront Planning (5-10 prompts)

- Analyzes the epic and architecture docs first, then presents a questionnaire covering scope, technical approach, constraints, AC preferences, risk priorities, and task breakdown depth.
- After all answers are collected, generates the story in one pass.
- **Best for:** Complex stories, stories spanning multiple systems, first story in a new epic.

## Steps

### Step 0: Load Project Configuration

Read the project `config.yaml` to determine:
- The stories directory path (e.g., `docs/stories/`).
- The current epic being worked on.
- Naming conventions or numbering schemes.
- Architecture documentation location and format (sharded vs monolithic).
- `devLoadAlwaysFiles` -- context files to consult during creation.

**Fallback order:**
1. `config.yaml` (project root)
2. `.aios/config.yaml`
3. `aios.config.js`

If no configuration is found, HALT and inform the user.

### Step 1: Identify the Target Epic

#### 1.1 Epic Selection

- If user specified an epic ID, use that epic.
- If an epic execution context exists, use the current epic.
- If ambiguous, list available epics with their status and ask the user to select.

#### 1.2 Load Epic Context

Load the epic file and extract:
- Epic ID, title, and description.
- Story breakdown / planned stories list.
- Epic-level acceptance criteria and scope.
- Sequential dependencies between stories.
- Business goals and success metrics.

### Step 2: Find the Next Story Number

#### 2.1 Scan Existing Stories

Scan the stories directory for files matching pattern `{epicNum}.{N}.story.md`. Find the highest N currently in use.

#### 2.2 Determine Next Story

- Next story number is N + 1.
- If no stories exist for this epic, start at 1.

#### 2.3 Validate Against Epic Breakdown

**If the highest story exists but is NOT in Done status:**
- Alert the user with the incomplete story details.
- Only proceed if the user explicitly confirms.

**If the epic is complete (all planned stories are Done):**
- Inform the user and present options: begin next epic, select specific epic/story, or cancel.
- NEVER automatically skip to another epic. User MUST explicitly choose.

**If the next story is NOT in the epic breakdown:**
- Warn the user but proceed if they confirm.

#### 2.4 Announce Identified Story

Inform the user: `Identified next story for preparation: {epicNum}.{storyNum} -- {Story Title from Epic}`

### Step 3: Gather Story Requirements and Previous Context

#### 3.1 Extract Story Requirements from Epic/PRD

Extract for this specific story:
- **Title:** Clear, concise, action-oriented.
- **Description:** The problem or need with context.
- **Acceptance Criteria:** Testable criteria in Given/When/Then format when possible.
- **Scope IN:** What is explicitly included.
- **Scope OUT:** What is explicitly excluded.
- **Dependencies:** Prerequisite stories, external resources, APIs.
- **Complexity Estimate:** Points or T-shirt size.
- **Business Value:** How this story contributes to the epic goal.
- **Risks:** Potential problems or unknowns.

**CRITICAL:** All information MUST come from the PRD and architecture docs. NEVER invent requirements, libraries, patterns, or standards not in source documents.

#### 3.2 Review Previous Story Context

If a previous story exists, review its Dev Agent Record for:
- Completion notes and lessons learned.
- Implementation deviations from the original plan.
- Technical decisions affecting subsequent stories.
- Challenges encountered and workarounds applied.
- Debt items or follow-up work.

### Step 4: Gather Architecture Context

#### 4.1 Determine Architecture Reading Strategy

- **Sharded architecture:** Read the index file, then follow structured reading order.
- **Monolithic architecture:** Read the single architecture document, locate relevant sections.

#### 4.2 Read Architecture Documents Based on Story Type

**For ALL Stories:** tech stack, project structure, coding standards, testing strategy.

**For Backend/API Stories, additionally:** data models, database schema, backend architecture, API specifications, external APIs.

**For Frontend/UI Stories, additionally:** frontend architecture, component library, core workflows, data models.

**For Full-Stack Stories:** Read both Backend and Frontend sections.

**File Fallback Strategy:**
```
tech-stack.md        -> [technology-stack.md, stack.md]
coding-standards.md  -> [code-standards.md, standards.md]
source-tree.md       -> [project-structure.md, directory-structure.md]
testing-strategy.md  -> [test-strategy.md, tests.md]
database-schema.md   -> [db-schema.md, schema.md]
```

When a fallback file is used, note it in Dev Notes. If no file is found in any fallback, note the missing file.

#### 4.3 Extract Story-Specific Technical Details

Extract ONLY information directly relevant to implementing the current story:
- Data models, schemas, or structures.
- API endpoints to implement or consume.
- Component specifications for UI elements.
- File paths and naming conventions.
- Testing requirements.
- Security or performance considerations.

**ALWAYS cite source documents:** `[Source: architecture/{filename}.md#{section}]`

### Step 5: Verify Project Structure Alignment

- Cross-reference story requirements with project structure documentation.
- Ensure file paths, component locations, and module names align with conventions.
- Document any structural conflicts in Dev Notes.

### Step 6: Populate and Write the Story File

#### 6.1 Load the Story Template

Load from (in order of precedence):
1. Project-level: `templates/story.md`
2. Pack-level: pack's `templates/story.md`
3. Built-in default.

If no template is found, HALT and inform the user.

#### 6.2 Populate Template Sections

- **Status:** Set to `Draft`.
- **Story ID:** `{epicNum}.{storyNum}`.
- **Title, Story statement, ACs, Scope, Dependencies, Risks:** From extraction.
- **Tasks / Subtasks:** Detailed, sequential list based on extracted requirements. Each task must reference relevant architecture documentation, include unit testing as explicit subtasks, and link to ACs (e.g., `Task 1 (AC: 1, 3)`).
- **Dev Notes:** ALL relevant technical context, organized by category:
  - **Previous Story Insights:** Key learnings.
  - **Data Models:** Schemas, validation rules, relationships `[with source refs]`.
  - **API Specifications:** Endpoint details, request/response formats `[with source refs]`.
  - **Component Specifications:** UI details, props, state management `[with source refs]`.
  - **File Locations:** Exact paths for new code.
  - **Testing Requirements:** Specific test cases from testing strategy.
  - **Technical Constraints:** Version requirements, performance rules, security needs.
  - If information for a category is not found, state: "No specific guidance found in architecture docs."
- **File List, Dev Agent Record, QA Results:** Leave empty (populated later).
- **Change Log:** Add creation entry.

#### 6.3 Write the Story File

Write to: `{storiesDir}/{epicNum}.{storyNum}.story.md`

### Step 7: Confirm Creation and Summarize

Display a completion summary including:
- File path, Story ID, Title, Status, Epic.
- Count of acceptance criteria, tasks, architecture sources, dependencies, risks.
- List of architecture files consulted.
- Next steps: review, then validate with @po.

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| Config not found | No config.yaml in expected locations | HALT. Inform user of expected locations and required fields. |
| Invalid config format | Malformed YAML/JSON | HALT. Display parsing error with line number. |
| Missing stories directory | Directory does not exist | HALT. Suggest creating directory or updating config. |
| Epic not found | Specified epic ID has no file | List available epics. Ask user to select or create. |
| Epic has no story breakdown | Epic file lacks planned stories | Warn. Proceed with manual story definition. |
| Template not found | No story template in expected locations | HALT. List expected template locations. |
| Story number conflict | Computed filename already exists | Increment. Warn user about conflict and new number. |
| Insufficient PRD content | Epic lacks detail for this story | Warn. Create with `[TODO: needs PRD input]` placeholders. |
| Architecture docs missing | Referenced docs not found | Warn. Note missing docs in Dev Notes, continue with available info. |
| Previous story incomplete | Last story not in Done status | Warn. Ask user to confirm proceeding despite risk. |
| All epic stories done | No more stories planned | Inform. Ask for next epic or custom story number. |

## Acceptance Criteria

- [ ] Story file exists at `{storiesDir}/{epicNum}.{storyNum}.story.md`.
- [ ] Story status is set to `Draft`.
- [ ] All template sections are populated (no unfilled placeholders except `[TODO]` markers).
- [ ] Acceptance criteria are testable and in Given/When/Then format where possible.
- [ ] Scope IN and OUT sections clearly delineate boundaries.
- [ ] Tasks are linked to acceptance criteria.
- [ ] Dev Notes contain ONLY information from architecture and PRD docs (no invented content).
- [ ] Source references are included for all technical details.
- [ ] Change Log has the creation entry.
- [ ] User has been informed of the next step: validation by @po.

## Notes

- **Anti-Hallucination:** Every technical detail MUST trace to a source document. If not found, state its absence rather than inventing details.
- **Story Numbering:** Stories are numbered within their epic: `{epicNum}.{storyNum}`.
- **Template Precedence:** Project-level templates override pack-level templates.
- **Status Flow:** This task ONLY creates stories in `Draft` status. The `Draft -> Ready` transition is exclusively handled by @po.
- **Epic Boundary:** NEVER create a story in a different epic without explicit user instruction.
- **IDS Principle:** Before creating tasks that build new components, check if reusable patterns exist (REUSE > ADAPT > CREATE).
- **Previous Story Review:** Always review the previous story's Dev Agent Record for lessons learned.
