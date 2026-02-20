---
task: repository-cleanup
agent: devops
inputs:
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
  - stale_days (optional, number, default: 30, threshold for stale branch detection)
outputs:
  - stale_branches (array, list of deleted stale branches)
  - temp_files (array, list of deleted temporary files)
  - cleanup_report (object, summary of cleanup actions)
---

# Repository Cleanup

## Purpose
Identify and remove stale branches and temporary files from any repository. Provides a safe, interactive cleanup workflow with user confirmation before any destructive operations.

## Prerequisites
- Valid git repository
- GitHub CLI for remote branch operations
- Repository context detected

## Steps

### 1. Identify Stale Branches

Stale branches are defined as merged branches older than the configured threshold (default: 30 days).

```bash
# Get all merged branches
git branch --merged

# For each merged branch, check last commit date
git log -1 --format=%ct {branch}
```

Filter results:
- Exclude `main`, `master`, and the current branch
- Only include branches where the last commit is older than the stale threshold
- Collect branch name, last commit date, and age in days

### 2. Identify Temporary Files

Scan for common temporary files that should not be in the repository:

```
**/.DS_Store
**/Thumbs.db
**/*.tmp
**/*.log
**/.eslintcache
```

Exclude `node_modules/` and `.git/` directories from the scan.

### 3. Present Cleanup Suggestions

Display a summary to the user:

```
Repository Cleanup Suggestions
===============================

Repository: {repositoryUrl}

Stale Branches (merged, >{stale_days} days old):
  - feature/story-3.1-dashboard (45 days old)
  - bugfix/memory-leak (60 days old)

Total: {count} stale branches

Temporary Files:
  - .DS_Store (5 files)
  - .eslintcache
  - debug.log

Total: {count} temporary files

Proceed with cleanup? (Y/n)
```

### 4. Execute Cleanup

After user confirmation:

**Delete stale branches:**
- Delete local branch: `git branch -d {branch}`
- Attempt to delete remote branch: `git push origin --delete {branch}`
- Log success or failure for each branch

**Delete temporary files:**
- Remove each identified temporary file
- Log success or failure for each file

### 5. Safety Checks

The following safety rules are enforced at all times:
- Never delete `main` or `master` branch
- Never delete the current branch
- Never delete unmerged branches (unless explicit `--force` flag provided)
- Always require user confirmation before executing deletions
- Support dry-run mode to preview changes without executing

## Error Handling
- **Not a git repository:** Exit with clear message
- **No stale branches found:** Report clean state, skip branch cleanup
- **Remote branch deletion fails:** Log warning, continue with remaining branches
- **Permission denied on file deletion:** Log warning, skip file, continue
- **Unmerged branch detected:** Skip with warning, suggest manual review
