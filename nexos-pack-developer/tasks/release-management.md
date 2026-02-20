---
task: release-management
agent: devops
inputs:
  - repository path
  - release type (auto | major | minor | patch | prerelease)
  - release branch (default: main)
  - changelog format (default: conventional-commits)
  - package registries (auto-detect from project type)
  - dry run flag (default: false)
  - prerelease tag (alpha | beta | rc)
  - skip CI flag (default: false, emergency only)
outputs:
  - new version tag
  - changelog update
  - GitHub release with release notes
  - published packages (optional)
  - release report with rollback instructions
---

# Release Management

## Purpose

Automate the complete software release lifecycle: analyze commits to determine the appropriate version bump, generate a changelog from commit history, update version files, create Git tags, publish GitHub Releases with release notes, and optionally publish packages to registries (npm, PyPI, Docker Hub, etc.). The result is a fully documented, reproducible release with minimal manual intervention.

This task handles the entire release process end-to-end, from pre-release validation to post-release verification.

## Prerequisites

- Git repository with a GitHub remote configured.
- GitHub CLI authenticated with sufficient permissions.
- On the release branch (usually `main` or `master`).
- No uncommitted changes.
- CI checks are passing (unless explicitly skipped for emergency releases).
- At least one new commit since the last release.
- Commits follow Conventional Commits format for automatic versioning.

## Steps

### Phase 1: Pre-Release Validation

#### 1.1 Validate Repository State

Check that the repository is ready for release:
- On the release branch (configurable, default: `main`).
- No uncommitted changes: `git status --porcelain` returns empty.
- Branch is up-to-date with remote: `git fetch && git status` shows no divergence.
- CI status is passing (check via `gh run list` or `gh api`).

If any check fails:
- Report the specific issue.
- Suggest resolution (e.g., "Commit or stash changes", "Pull latest from remote").
- Halt unless `--skip-ci` is explicitly set (for emergency hotfixes only).

#### 1.2 Validate Tag Reachability

Verify that existing version tags are reachable from the current HEAD:
- Find the most recent version tag: `git describe --tags --abbrev=0`.
- Verify it is an ancestor of HEAD: `git merge-base --is-ancestor {tag} HEAD`.
- If NO tags are reachable (e.g., after history rewrite with `git filter-repo`):
  - Warn: semantic-release will create v1.0.0.
  - Suggest creating a baseline tag at the current version:
    ```bash
    git tag v$(node -p "require('./package.json').version")
    git push origin v$(node -p "require('./package.json').version")
    ```

#### 1.3 Analyze Commits Since Last Release

Gather all commits since the last version tag:
- Get the last version tag.
- List commits: `git log {last_tag}..HEAD --oneline`.
- Parse each commit message per Conventional Commits specification.
- Categorize commits:
  - **Breaking Changes:** `BREAKING CHANGE:` footer or `!` after type.
  - **Features:** `feat:` prefix.
  - **Bug Fixes:** `fix:` prefix.
  - **Performance:** `perf:` prefix.
  - **Documentation:** `docs:` prefix.
  - **Refactoring:** `refactor:` prefix.
  - **Tests:** `test:` prefix.
  - **Chores:** `chore:` prefix.

If no eligible commits are found (only `chore:` or `docs:` with no features/fixes):
- Report: "No releasable commits found since {last_tag}."
- Halt (nothing to release) unless the user specifies a manual release type.

#### 1.4 Determine Version Bump

Based on commits and configuration:

| Condition | Bump Type | Example |
|-----------|-----------|---------|
| `BREAKING CHANGE` in any commit | **major** | 2.1.3 -> 3.0.0 |
| `feat:` commits present | **minor** | 2.1.3 -> 2.2.0 |
| `fix:` or `perf:` commits only | **patch** | 2.1.3 -> 2.1.4 |
| Manual override: `--type major` | **major** | as specified |
| Manual override: `--type prerelease --tag beta` | **prerelease** | 2.1.3 -> 2.1.4-beta.1 |

If automatic detection suggests a minor bump but breaking changes are present, warn the user and recommend a major bump.

### Phase 2: Changelog Generation

#### 2.1 Generate Changelog Content

Group commits by type and generate formatted changelog:

```markdown
## [{new_version}] - {release_date}

### Breaking Changes
- {breaking_change_description} ({commit_hash})

### Features
- {feature_description} ({commit_hash})

### Bug Fixes
- {fix_description} ({commit_hash})

### Performance
- {perf_description} ({commit_hash})

### Documentation
- {docs_description} ({commit_hash})

### Other Changes
- {refactor/test/chore_description} ({commit_hash})
```

- Include issue/PR references from commit messages (e.g., `#42`, `Closes #38`).
- Include commit short hashes for traceability.
- Omit empty sections.

#### 2.2 Update CHANGELOG.md

- If `CHANGELOG.md` exists, prepend the new version section after the header.
- If it does not exist, create it with the standard header and first version section.
- Preserve existing changelog content below the new section.

#### 2.3 Generate Release Notes

Create formatted release notes for the GitHub Release:
- Highlights: top 3 most impactful changes.
- Full changelog grouped by type.
- Breaking changes section with migration guide (if applicable).
- Contributor credits (from commit authors).
- Installation instructions for the new version.
- Links to full changelog diff and documentation.

**Release Notes Template:**

```markdown
# Release v{new_version}

**Date**: {release_date}
**Type**: {release_type} ({major|minor|patch})

## Highlights

{top_3_most_impactful_changes}

## What's Changed

{changelog_content}

## Breaking Changes

{breaking_changes_section if any}

### Migration Guide

{migration_steps if breaking changes}

## Contributors

Thank you to all contributors who made this release possible:

{contributor_list with GitHub handles}

## Install

```bash
npm install {package_name}@{new_version}
# or
pip install {package_name}=={new_version}
```

## Links

- [Full Changelog]({compare_url})
- [Documentation]({docs_url})
- [Issues]({issues_url})
```

### Phase 3: Version Bumping

#### 3.1 Update Version Files

Update version numbers in project files based on project type:

| Project Type | Files to Update |
|-------------|----------------|
| Node.js | `package.json`, `package-lock.json` |
| Python | `pyproject.toml`, `setup.py`, `__version__.py` |
| Go | `VERSION` file, version constant |
| Rust | `Cargo.toml` |
| Docker | Dockerfile labels |
| Generic | `VERSION` file |

Only update files that exist. Do not create version files that are not already part of the project.

#### 3.2 Commit Version Changes

Create a version bump commit:
- Stage updated version files and CHANGELOG.md.
- Commit message: `chore(release): {new_version}`.
- Do NOT push yet (push happens after tagging).

### Phase 4: Git Tagging and Release

#### 4.1 Create Git Tag

Create an annotated Git tag:
```
git tag -a v{new_version} -m "Release v{new_version}"
```
- Include a brief summary of the release in the tag message.
- Use the `v` prefix convention (configurable).

#### 4.2 Push to Remote

Push the version bump commit and tag:
```
git push origin {release_branch}
git push origin v{new_version}
```
- Wait for the remote to accept both pushes.
- Verify the tag exists on the remote: `git ls-remote --tags origin | grep v{new_version}`.

#### 4.3 Create GitHub Release

Create a GitHub Release using the generated release notes:
```bash
gh release create v{new_version} \
  --title "Release v{new_version}" \
  --notes-file {release_notes_file} \
  --latest
```

For prerelease versions:
```bash
gh release create v{new_version} \
  --title "Release v{new_version}" \
  --notes-file {release_notes_file} \
  --prerelease
```

Attach build artifacts if applicable (binaries, archives, etc.).

### Phase 5: Package Publishing (Optional)

#### 5.1 Publish to Package Registries

If configured, publish to the appropriate registries:

| Registry | Publish Command | Authentication |
|----------|----------------|----------------|
| npm | `npm publish --access public` | `NPM_TOKEN` |
| GitHub Packages | `npm publish --registry=https://npm.pkg.github.com` | `GITHUB_TOKEN` |
| PyPI | `python -m build && twine upload dist/*` | `TWINE_USERNAME/PASSWORD` |
| Docker Hub | `docker build && docker push` | `DOCKER_USERNAME/PASSWORD` |

For each registry:
1. Verify authentication credentials are available.
2. Build the package if needed.
3. Publish with appropriate flags.
4. Verify publication: check that the new version appears in the registry.

#### 5.2 Verify Publication

After publishing, verify each package:
- npm: `npm view {package_name}@{new_version}`.
- Docker: `docker pull {image}:{new_version}`.
- PyPI: `pip install {package_name}=={new_version} --dry-run`.

Report verification results.

### Phase 6: Post-Release

#### 6.1 Update Documentation

If applicable:
- Update version badges in README.
- Update installation instructions with new version.
- If docs are versioned, note that a new version doc may be needed.

#### 6.2 Generate Release Report

Produce a comprehensive release report:

```yaml
release-report:
  timestamp: "{timestamp}"
  version: "{new_version}"
  previous_version: "{previous_version}"
  release_type: "{major|minor|patch|prerelease}"
  release_branch: "{branch}"
  git_tag: "v{new_version}"
  release_url: "{github_release_url}"
  changelog_summary:
    breaking_changes: {count}
    features: {count}
    bug_fixes: {count}
    other: {count}
  commits_included: {count}
  contributors: ["{contributor1}", "{contributor2}"]
  packages_published:
    - registry: "{registry_name}"
      package: "{package_name}"
      version: "{version}"
      url: "{package_url}"
      verified: true | false
  validation:
    tag_exists: true | false
    release_created: true | false
    packages_verified: true | false
  rollback_instructions:
    - "Delete the GitHub Release: gh release delete v{new_version} --yes"
    - "Delete the Git tag: git push --delete origin v{new_version} && git tag -d v{new_version}"
    - "Revert the version commit: git revert HEAD"
    - "Unpublish package (if within 72h for npm): npm unpublish {package}@{version}"
```

#### 6.3 Report Results

Inform the user:
- Release version and type.
- GitHub Release URL.
- Changelog highlights.
- Published packages (if any).
- Contributor credits.
- Rollback instructions (in case something goes wrong post-release).
- Suggested next steps:
  - Announce the release (team communication channels).
  - Monitor for issues in the new version.
  - Plan the next release cycle.

## Conventional Commits Reference

For automatic versioning, commits should follow this format:
```
{type}({scope}): {subject}

{body}

{footer}
```

**Types that trigger version bumps:**
- `feat:` -- New feature (minor bump).
- `fix:` -- Bug fix (patch bump).
- `perf:` -- Performance improvement (patch bump).
- `feat!:` or `BREAKING CHANGE:` footer -- Breaking change (major bump).

**Types that do NOT trigger version bumps (but appear in changelog):**
- `docs:` -- Documentation only.
- `style:` -- Code style changes.
- `refactor:` -- Code refactoring.
- `test:` -- Adding or updating tests.
- `chore:` -- Maintenance tasks.

## Error Handling

- **Not on release branch:** Halt with message: "Not on release branch ({expected_branch}). Switch branches first."
- **Uncommitted changes:** Halt with message: "Uncommitted changes detected. Commit or stash before releasing."
- **CI not passing:** Halt with message: "CI checks are failing. Fix before releasing." Unless `--skip-ci` is set with explicit justification.
- **No new commits:** Halt with message: "No new commits since last release ({last_tag}). Nothing to release."
- **No tags reachable:** Warn and suggest creating a baseline tag. Offer to create one automatically at the current version.
- **Tag already exists:** Halt with message: "Tag v{version} already exists. Choose a different version or delete the existing tag."
- **GitHub Release creation fails:** Log the error. The tag still exists, so the release can be created manually. Provide the manual command.
- **Package publish fails:** Log the error. Do NOT delete the tag or GitHub Release. Note the publish failure in the report. Provide instructions for manual publishing.
- **Push rejected (branch protection):** Report the protection rules that blocked the push. Suggest creating a PR instead.
- **Changelog generation fails:** Generate a minimal changelog with commit hashes only. Warn that the changelog may need manual editing.
- **Dry-run mode:** When `--dry-run` is set, execute all analysis and generation steps but do NOT push, tag, release, or publish. Show exactly what would happen.

## Notes

- Releases are a high-stakes operation. Prefer interactive oversight for production releases.
- The Conventional Commits standard is assumed for automatic version detection. If commits do not follow this format, manual version specification is required.
- For monorepos with multiple packages, consider running this task per package with appropriate scoping.
- Rollback instructions are included in every release report. Test rollback procedures periodically.
- Package unpublishing has time limits (e.g., npm allows unpublish within 72 hours). Act quickly if a bad release is published.
- This task pairs with `pre-push-quality-gate` (run quality gate before starting a release) and `setup-github` (which configures the release workflow in GitHub Actions).
- For automated releases via CI, use the `release.yml` workflow configured by `setup-github` rather than running this task manually.
