---
task: sync-documentation
agent: pm
workflow: documentation
inputs:
  - component (string, optional) - Path to specific component to sync
  - all (boolean, optional) - Sync all registered components
  - check (boolean, optional) - Check status without updating
  - strategies (array, optional) - Sync strategies: jsdoc, markdown, schema, api, examples
  - auto-sync (boolean, optional) - Enable automatic sync monitoring
  - report (string, optional) - Output path for sync report
  - force (boolean, optional) - Force sync even if up-to-date
  - interactive (boolean, optional) - Review changes interactively
  - mode (string, optional) - Execution mode: "yolo" | "interactive" | "preflight", default "interactive"
outputs:
  - execution_result (object) - Sync status, components synced, changes applied
  - logs (array) - Execution logs
---

# Sync Documentation

## Purpose
Automatically synchronize documentation with code changes to ensure documentation stays up-to-date with implementation.

## Prerequisites
- Documentation synchronizer module is available and initialized
- Registered components have linked documentation files
- File paths provided (if any) are valid

## Steps

### 1. Parse Parameters
1. Parse command-line options: `--component`, `--all`, `--check`, `--strategies`, `--auto-sync`, `--report`, `--force`, `--interactive`
2. Validate sync strategies against allowed values: jsdoc, markdown, schema, api, examples
3. Set default values for unspecified options
4. Validate file paths if provided

### 2. Initialize Dependencies
1. Load the DocumentationSynchronizer module
2. Initialize synchronizer with the project root path
3. Set up event listeners for sync and error events
4. Verify all dependencies are available

### 3. Execute Requested Action

Determine the action based on parameters and execute:

**Check mode** (`--check`):
1. Iterate all registered components
2. Compare file modification time against last sync time
3. Display out-of-sync components with details (path, doc path, last modified, last sync)
4. Display up-to-date components
5. Show summary: total components, out of sync, up to date

**Sync single component** (`--component <path>`):
1. Resolve full path
2. Run synchronization with configured strategies
3. Display applied changes
4. If interactive, show change previews

**Sync all components** (`--all`):
1. Iterate all registered components
2. Skip up-to-date components (unless `--force`)
3. Apply sync strategies to each out-of-date component
4. Track results: synced, skipped, failed, total changes
5. Display summary

**Auto-sync** (`--auto-sync`):
1. Enable automatic sync monitoring with 1-minute interval
2. Watch for file changes and trigger sync automatically
3. Log detected changes in real-time
4. Run until manually stopped (Ctrl+C)

**Generate report** (`--report <file>`):
1. Generate comprehensive sync report
2. Include sync results and history
3. Save as JSON to specified path
4. Display summary: total components, documentation count, sync history

**Default** (no flags):
1. Show current sync status
2. Display registered components and documentation file counts
3. List active sync strategies
4. Show recent synchronization history (last 5 entries)
5. Display available commands

## Synchronization Workflow

### Detection Phase
1. Monitor file changes
2. Identify linked documentation
3. Detect content differences
4. Calculate sync requirements
5. Prioritize updates

### Analysis Phase
1. Parse code changes
2. Extract documentation elements
3. Compare with existing docs
4. Identify gaps and conflicts
5. Generate sync plan

### Update Phase
1. Apply sync strategies
2. Update documentation files
3. Preserve formatting
4. Validate changes
5. Record sync history

## Sync Strategies

| Strategy | Description |
|----------|-------------|
| JSDoc | Sync code comments with markdown documentation |
| Markdown | Update documentation sections from code |
| Schema | Sync YAML/JSON schemas with documentation |
| API | Update API documentation from endpoints |
| Examples | Validate and update code examples |

## Error Handling
- **Synchronizer initialization failure:** Halt with descriptive error message.
- **Invalid sync strategy:** Reject with list of valid strategies.
- **Component path not found:** Warn and skip or halt depending on mode.
- **File write failure:** Log error, continue with remaining components.
- **Timeout during sync:** Optimize or increase timeout; cleanup and log state.

## Best Practices
- Keep docs near code
- Use consistent naming conventions
- Link documentation explicitly
- Maintain clear sections
- Update examples regularly
- Validate after sync
- Test code examples
- Check API accuracy
- Monitor sync history
- Handle conflicts gracefully

## Acceptance Criteria
- Documentation synchronization completes without critical errors
- Sync status is accurately reported
- Out-of-date documentation is identified or updated as requested
- Reports are generated in valid JSON format
- Side effects documented
