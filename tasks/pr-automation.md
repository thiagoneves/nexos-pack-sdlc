---
task: pr-automation
agent: devops
inputs:
  - story_path (optional, path to story file for context)
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - pr_url (string, URL of created pull request)
  - pr_title (string, generated PR title)
  - base_branch (string, target branch for the PR)
---

# Pull Request Automation

## Purpose
Automate PR creation from story context using GitHub CLI, working with any repository. Generates PR titles based on configurable formats (conventional commits, story-first, or branch-based) and populates PR descriptions with story metadata.

## Prerequisites
- GitHub CLI (`gh`) installed and authenticated
- Feature branch pushed to remote
- Repository context detected (valid git repository with remote)
- Story file (optional but recommended for richer PR metadata)

## Steps

### 1. Detect Repository Context
Verify the current directory is a valid git repository with a remote origin configured.

```bash
git remote get-url origin
```

If no remote is found, abort with a clear error message.

### 2. Get Current Branch

```bash
git branch --show-current
```

Verify the branch is not `main` or `master`. PRs should be created from feature branches.

### 3. Extract Story Information
If a story path is provided, parse the story file to extract:
- Story ID (from path or content, e.g., `6.17`)
- Title
- Whether acceptance criteria exist

If no story path is provided, proceed without story context.

### 4. Generate PR Title (Configurable Format)

The PR title format is driven by project configuration. Check `core-config.yaml` for `github.pr.title_format`:

| Format | Example Output |
|--------|---------------|
| `conventional` | `feat: user auth [Story 6.17]` |
| `story-first` | `[Story 6.17] User Auth` |
| `branch-based` | `User Auth [Story 6.17]` |

**Conventional format logic:**
- Detect commit type from branch prefix (`feature/` -> `feat`, `fix/` -> `fix`, `docs/` -> `docs`)
- Extract scope from branch name if present (e.g., `feat/auth/login` -> scope=`auth`)
- Build: `{type}({scope}): {description} [Story {id}]`

**Story-first format logic:**
- Build: `[Story {id}] {title}`
- Fallback to branch-name-as-title if no story

**Branch-based format logic:**
- Convert branch name to title case
- Optionally append story ID

### 5. Generate PR Description

Build a structured PR description containing:
- Summary section with story reference
- Changes section (placeholder for author to fill)
- Testing checklist (unit, integration, manual)
- Quality checklist (code standards, tests, docs, quality gates)
- Repository and package metadata

### 6. Determine Base Branch

```bash
git symbolic-ref refs/remotes/origin/HEAD
```

Default to `main` if detection fails.

### 7. Create PR via GitHub CLI

```bash
gh pr create \
  --title "{title}" \
  --body "{description}" \
  --base {baseBranch} \
  --head {currentBranch}
```

### 8. Assign Reviewers (Optional)

Based on story type, assign appropriate review teams:
- Feature -> dev team
- Bugfix -> QA team
- Docs -> tech writers
- Security -> security team

## Error Handling
- **Repository not detected:** Verify you are inside a git repository with a configured remote
- **Branch is main/master:** Abort with message to create a feature branch first
- **GitHub CLI not authenticated:** Run `gh auth login` before retrying
- **PR already exists:** Show existing PR URL and ask whether to update it
- **Story file not found:** Proceed without story context, use branch-based title

## Configuration Reference

Add to your project's configuration file:

```yaml
github:
  pr:
    title_format: conventional  # conventional | story-first | branch-based
    include_story_id: true
    conventional_commits:
      enabled: true
      branch_type_map:
        feature/: feat
        fix/: fix
        docs/: docs
      default_type: feat
```

## Semantic-Release Integration

When `title_format: conventional` is configured, PRs merged via "Squash and merge" use the PR title as the commit message, which can trigger semantic-release:

| Branch Pattern | Generated Title | Release |
|---------------|-----------------|---------|
| `feature/user-auth` | `feat: user auth` | Minor |
| `fix/cli-parsing` | `fix: cli parsing` | Patch |
| `docs/readme-update` | `docs: readme update` | None |

For breaking changes, manually edit the PR title to include `!`:
- `feat!: redesign authentication API [Story 7.1]`
