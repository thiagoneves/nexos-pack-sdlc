---
task: version-management
agent: devops
inputs:
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - new_version (string, the new semantic version)
  - bump_type (string, MAJOR|MINOR|PATCH)
  - changelog (string, generated changelog entries)
  - git_tag (string, created git tag name)
---

# Semantic Version Management

## Purpose
Analyze commit history since the last release, recommend an appropriate semantic version bump, update `package.json`, create a git tag, and generate changelog entries. Works with any repository using conventional commits.

## Prerequisites
- Git repository with commit history
- `package.json` with a current version field
- Understanding of semantic versioning (MAJOR.MINOR.PATCH)

## Steps

### 1. Detect Repository Context

Verify the repository and read the current package version from `package.json`.

```bash
cat package.json | grep '"version"'
```

### 2. Get Last Git Tag

```bash
git describe --tags --abbrev=0
```

If no tags exist, use `v0.0.0` as the baseline.

### 3. Analyze Commits Since Last Tag

```bash
git log {last-tag}..HEAD --oneline
```

Parse each commit message using conventional commit keywords:

**Breaking Changes (MAJOR):**
- `BREAKING CHANGE:` in commit body
- `BREAKING:` prefix
- `!` in commit type (e.g., `feat!:`)

**New Features (MINOR):**
- `feat:` or `feature:` prefix

**Bug Fixes (PATCH):**
- `fix:`, `bugfix:`, or `hotfix:` prefix

### 4. Recommend Version Bump

Apply semantic versioning logic:
1. If `breakingChanges > 0` -> MAJOR bump
2. Else if `features > 0` -> MINOR bump
3. Else if `fixes > 0` -> PATCH bump
4. Else -> No version bump needed

### 5. User Confirmation

Present the recommendation:

```
Version Analysis
==================================
Current version:  v4.31.0
Recommended:      v4.32.0 (MINOR)

Changes since v4.31.0:
  Breaking changes: 0
  New features:     3
  Bug fixes:        2

Reason: New features detected (backward compatible)

Proceed with version v4.32.0? (Y/n)
```

### 6. Update package.json

Write the new version to `package.json` while preserving formatting.

### 7. Create Git Tag

```bash
git tag -a v{newVersion} -m "Release v{newVersion}"
```

### 8. Generate Changelog

Extract commits since the last tag and format them:

```markdown
## [{newVersion}] - {date}

### Added
- New feature A
- New feature B

### Fixed
- Bug fix 1
- Bug fix 2
```

## Error Handling
- **No git tags found:** Use `v0.0.0` as baseline, inform user
- **No commits since last tag:** Report no changes, skip version bump
- **Invalid version in package.json:** Abort with clear error, suggest manual fix
- **Git tag already exists:** Abort, suggest using a different version or deleting the existing tag
- **User cancels confirmation:** Exit gracefully without changes

## Validation
- Version bump follows semantic versioning rules
- User confirms the version change before applying
- Git tag is created successfully
- `package.json` is updated correctly
- Does NOT push to remote (pushing is a separate operation)
