# Story Lifecycle Rules

## Status Progression

```
Draft → Ready → InProgress → InReview → Done
```

| Status | Trigger | Agent | Action |
|--------|---------|-------|--------|
| Draft | @sm creates story | @sm | Story file created |
| Ready | @po validates (GO) | @po | **MUST update status field from Draft to Ready** |
| InProgress | @dev starts implementation | @dev | Update status field |
| InReview | @dev completes, @qa reviews | @qa | Update status field |
| Done | @qa PASS, @devops pushes | @devops | Update status field |

**CRITICAL:** The `Draft → Ready` transition is @po's responsibility during `*validate`. When verdict is GO, @po MUST update the story's Status field to `Ready` and log the transition in the Change Log. A story left in `Draft` after a GO verdict is a process violation.

## Story Development Cycle (4 Phases)

### Phase 1: Create (@sm)
- **Task:** `create-next-story.md`
- **Output:** `{epicNum}.{storyNum}.story.md` (Draft)

### Phase 2: Validate (@po)
- **Task:** `validate-next-story.md`
- **10-point checklist** (score: GO >=7, NO-GO <7)
- **On GO:** Status Draft → Ready

### Phase 3: Implement (@dev)
- **Task:** `dev-develop-story.md`
- **Modes:** Autopilot (autonomous), Interactive (default), Pre-Flight (plan-first)
- **Status:** Ready → InProgress

### Phase 4: QA Gate (@qa)
- **Task:** `qa-gate.md`
- **7 quality checks**
- **Decision:** PASS / CONCERNS / FAIL / WAIVED
- **Status:** InProgress → InReview → Done

## Story File Edit Rules

| Section | Who Can Edit |
|---------|-------------|
| Title, Description, AC, Scope | @po only |
| File List, Dev Notes, checkboxes, Dev Agent Record | @dev only |
| QA Results | @qa only |
| Change Log | Any agent (append only) |
| Status | Agent responsible for the transition |
