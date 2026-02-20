---
task: waves
agent: dev
workflow: workflow-intelligence
inputs:
  - workflow (string, optional) - Workflow name to analyze, default auto-detect from context
  - visual (boolean, optional) - Show ASCII visualization of wave structure
  - json (boolean, optional) - Output as JSON format
outputs:
  - wave_analysis (object) - Waves, tasks per wave, optimization gain, critical path
  - visualization (string, optional) - ASCII wave diagram if --visual flag used
---

# Wave Analysis

## Purpose
Analyze workflow task dependencies to identify waves of tasks that can execute in parallel. Shows optimization opportunities and the critical path through the workflow.

## Prerequisites
- Workflow definitions are available and parseable
- The specified workflow (or auto-detected one) exists

## Steps

### 1. Resolve Workflow
1. If a workflow name is provided, use it directly
2. If no workflow specified, auto-detect from the current context (active story, current branch, etc.)
3. Load the workflow definition with its tasks and dependency graph

### 2. Analyze Dependencies
1. Parse all tasks and their dependency declarations
2. Build a directed acyclic graph (DAG) of task dependencies
3. Check for circular dependencies - if found, halt with error showing the cycle and a suggestion to break it

### 3. Compute Waves
1. Group tasks into waves using topological sorting:
   - **Wave 1**: Tasks with no dependencies (can start immediately)
   - **Wave 2**: Tasks that depend only on Wave 1 tasks
   - **Wave N**: Tasks that depend on tasks in earlier waves
2. Mark waves where multiple tasks can run in parallel

### 4. Calculate Optimization
1. Sum all task durations for sequential execution total
2. For parallel execution, take the max duration within each wave and sum across waves
3. Calculate optimization percentage: `(sequential - parallel) / sequential * 100`

### 5. Identify Critical Path
Trace the longest path through the dependency graph (the sequence of tasks that determines the minimum total duration).

### 6. Display Results

**Standard output:**
```
Wave Analysis: {workflow_name}

Wave 1 (parallel):
  - task-a
  - task-b

Wave 2:
  - task-c

Total Sequential: Xmin
Total Parallel:   Ymin
Optimization:     Z% faster

Critical Path: task-a -> task-c -> ...
```

**Visual output** (`--visual`):
```
Wave 1 --+-- task-a (5min)
         +-- task-b (2min)
              |
Wave 2 ------ task-c (30min)
              |
Wave 3 --+-- task-d (10min)
         +-- task-e (5min)
```

**JSON output** (`--json`):
```json
{
  "workflowId": "workflow_name",
  "totalTasks": 6,
  "waves": [
    {
      "waveNumber": 1,
      "tasks": ["task-a", "task-b"],
      "parallel": true,
      "dependsOn": [],
      "estimatedDuration": "5min"
    }
  ],
  "optimizationGain": "26%",
  "criticalPath": ["task-a", "task-c", "task-d"]
}
```

## Circular Dependency Handling
If circular dependencies are detected:
1. Display error with the full cycle path: `task-a -> task-b -> task-c -> task-a`
2. Suggest which dependency to remove to break the cycle
3. Exit with error code

## Integration with Next Command
The wave analysis integrates with workflow navigation to show wave context:
- Current wave number and total waves
- Tasks in the current wave (which can run in parallel)
- Tasks in the next wave (what comes after current wave completes)
- Optimization tip when parallel execution would save time

## Performance

| Workflow Size | Analysis Time |
|--------------|---------------|
| Small (5 tasks) | <10ms |
| Medium (20 tasks) | <30ms |
| Large (50 tasks) | <50ms |

## Error Handling
- **Workflow not found:** List available workflows, suggest similar names.
- **Circular dependency detected:** Show full cycle, suggest fix, halt.
- **No tasks in workflow:** Report empty workflow.
- **Auto-detect fails:** Ask user to specify workflow name explicitly.

## Acceptance Criteria
- All tasks are assigned to exactly one wave
- Parallel tasks within a wave have no inter-dependencies
- Optimization percentage is accurately calculated
- Critical path is the actual longest path through the DAG
- Circular dependencies are detected and reported clearly
- All three output formats (standard, visual, JSON) are correct
