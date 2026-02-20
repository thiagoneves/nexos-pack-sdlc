---
task: setup-github
agent: devops
workflow: project-setup (phase 1)
inputs: [project path, project type, configuration options]
outputs: [GitHub Actions workflows, code review config, branch protection, secrets, setup report]
---

# Setup GitHub

## Purpose

Configure complete GitHub DevOps infrastructure for a project. This includes installing GitHub Actions CI/CD workflows, configuring automated code review, setting up branch protection rules, and managing repository secrets. The result is a fully operational CI/CD pipeline that enforces quality standards on every pull request and automates release workflows.

This task should be executed AFTER `environment-bootstrap`, when the Git repository is already initialized and pushed to GitHub.

## Prerequisites

- Git repository exists locally (`.git` directory present).
- GitHub remote is configured (`git remote get-url origin` returns a valid URL).
- GitHub CLI is authenticated (`gh auth status` succeeds).
- The repository exists on GitHub (`gh repo view` succeeds).
- At least one commit has been pushed to the remote.

## Execution Modes

### Autopilot Mode (autonomous)

- 0-1 prompts. Install all recommended workflows with sensible defaults.
- Auto-detect project type from project files.
- Install CI workflow + PR automation workflow.
- Skip branch protection (may require paid plan for private repos).
- Skip secrets (no way to auto-detect secret values).
- Best for: standard projects, quick setup.

### Interactive Mode (default)

- 5-10 prompts at key decision points.
- Confirm project type detection.
- Let user select which workflows to install.
- Configure code review profile interactively.
- Guide through branch protection setup.
- Walk through secrets configuration.
- Best for: first-time setup, custom requirements, team onboarding.

### Pre-Flight Mode (plan-first)

- Full analysis of current repository configuration.
- Present complete DevOps setup plan with every component.
- User approves the plan before any changes.
- Execute approved plan sequentially.
- Best for: enterprise environments, existing CI/CD to preserve, audit requirements.

## Steps

### 1. Verify Pre-Conditions

Check all prerequisites before proceeding:
- `.git` directory exists.
- GitHub remote is configured and reachable.
- GitHub CLI is authenticated with sufficient permissions.
- Repository exists on GitHub.
- Check for existing DevOps configuration (idempotency):
  - If `.github/workflows/` exists with workflow files, warn and ask whether to overwrite or merge.
  - If a setup report already exists, inform user of previous setup.

If any blocking pre-condition fails, halt with a clear error message and suggested resolution.

### 2. Detect Project Type

Analyze project files to determine the technology stack:

| Indicator | Detected Type |
|-----------|--------------|
| `package.json` | Node.js |
| `tsconfig.json` or TypeScript devDependency | TypeScript |
| `requirements.txt` or `pyproject.toml` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| Multiple indicators | Mixed |

Also detect:
- **Test framework:** Jest, Vitest, Mocha, pytest, go test, cargo test.
- **Linting tools:** ESLint, Prettier, pylint, golint, clippy.
- **Build tools:** webpack, vite, rollup, tsc, go build, cargo build.
- **Package manager:** npm, yarn, pnpm, pip, cargo.

**Detection logic (Node.js example):**
- Read `package.json` and check `devDependencies` for:
  - `typescript` -- marks TypeScript project
  - `jest` or `vitest` -- test framework
  - `eslint` -- linting
  - `prettier` -- formatting

**Interactive/Pre-Flight Mode:** Present detection results and ask for confirmation. Allow manual override.

**Autopilot Mode:** Use detected type without confirmation.

### 3. Install GitHub Actions Workflows

Create or update workflow files in `.github/workflows/`:

**Available Workflows:**

| Workflow | File | Purpose | Recommended |
|----------|------|---------|-------------|
| CI | `ci.yml` | Lint, typecheck, test on PRs and pushes | Yes (always) |
| PR Automation | `pr-automation.yml` | Quality summary comments, coverage reports | Yes |
| Release | `release.yml` | Automated releases on version tags | Optional |

**CI Workflow (`ci.yml`) -- template variables:**

```yaml
name: CI
on:
  pull_request:
    branches: [{default_branch}]
  push:
    branches: [{default_branch}]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4      # or setup-python, etc.
        with:
          node-version: "{node_version}"  # from detection
      - run: {install_command}            # npm ci, pip install, etc.
      - run: {lint_command}               # npm run lint
      - run: {typecheck_command}          # npm run typecheck (if applicable)
      - run: {test_command}               # npm test
```

**Template variables by project type:**

| Variable | Node.js | Python | Go | Rust |
|----------|---------|--------|----|------|
| setup action | `setup-node@v4` | `setup-python@v5` | `setup-go@v5` | `dtolnay/rust-toolchain@stable` |
| install | `npm ci` | `pip install -r requirements.txt` | `go mod download` | `cargo build` |
| lint | `npm run lint` | `pylint src/` | `golangci-lint run` | `cargo clippy` |
| typecheck | `npm run typecheck` | `mypy src/` | (built-in) | (built-in) |
| test | `npm test` | `pytest` | `go test ./...` | `cargo test` |

For each workflow:
1. Load the template (from `templates/` directory if available, or generate from project type).
2. Substitute variables based on detected project type and configuration.
3. Write to `.github/workflows/{filename}`.
4. Validate the YAML syntax.

**Interactive Mode:** Present available workflows and let user select. Show a preview of each workflow before writing.

**Autopilot Mode:** Install CI and PR Automation by default.

### 4. Configure Code Review

Set up automated code review configuration:

**Review Profile Options:**

| Profile | Description | Best For |
|---------|-------------|----------|
| `chill` | Minimal feedback, only critical issues | Solo developers, fast iteration |
| `balanced` | Moderate feedback, important issues and suggestions | Most teams (recommended) |
| `assertive` | Comprehensive feedback, strict standards | Enterprise, regulated environments |

Generate the code review configuration file (e.g., `.coderabbit.yaml` or equivalent):
- Set the review profile based on user choice.
- Configure path-specific review instructions based on project structure:

```yaml
# Path-specific instructions
path_instructions:
  - path: "src/**"
    instructions: |
      Focus on code quality, performance, and security.
      Check for proper error handling and input validation.
  - path: "**/*.test.*"
    instructions: |
      Ensure test coverage and edge cases.
      Verify mock implementations are correct.
  - path: "docs/**"
    instructions: |
      Check clarity and completeness of documentation.
```

- Configure review scope (which file types to review, which to skip).

**Interactive Mode:** Let user choose profile and customize path instructions.

**Autopilot Mode:** Use `balanced` profile with auto-detected path instructions.

Remind user that the code review service may need a GitHub App installed separately (e.g., `https://github.com/apps/coderabbitai`).

### 5. Configure Branch Protection

Set up branch protection rules for the default branch (usually `main`):

**Protection Rules:**

| Rule | Description | Default |
|------|-------------|---------|
| Required status checks | CI must pass before merge | lint, typecheck, test |
| Require PR reviews | PRs must be reviewed before merge | 1 reviewer |
| Dismiss stale reviews | Re-request review after new commits | Enabled |
| Require conversation resolution | All comments must be resolved | Enabled |
| Prevent force pushes | Protect commit history | Enabled |
| Prevent branch deletion | Protect default branch | Enabled |

**Implementation via GitHub API:**

```bash
# Get repository info
REPO_INFO=$(gh repo view --json owner,name)
OWNER=$(echo $REPO_INFO | jq -r '.owner.login')
REPO=$(echo $REPO_INFO | jq -r '.name')

# Configure branch protection for main
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/$OWNER/$REPO/branches/main/protection \
  -f "required_status_checks[strict]=true" \
  -f "required_status_checks[contexts][]=lint" \
  -f "required_status_checks[contexts][]=typecheck" \
  -f "required_status_checks[contexts][]=test" \
  -f "enforce_admins=false" \
  -f "required_pull_request_reviews[required_approving_review_count]=1" \
  -f "required_pull_request_reviews[dismiss_stale_reviews]=true" \
  -f "restrictions=null" \
  -f "allow_force_pushes=false" \
  -f "allow_deletions=false"
```

- Handle the case where branch protection requires a paid GitHub plan for private repos.
- If the API call fails due to plan limitations, warn the user and provide manual setup instructions via Settings > Branches.

**Interactive Mode:** Let user choose which rules to enable and number of required reviewers.

**Autopilot Mode:** Skip branch protection (may require paid plan). Note in report.

**Pre-Flight Mode:** Include in plan with a note about plan requirements.

### 6. Secrets Configuration Wizard

Guide the user through configuring repository secrets for GitHub Actions:

**Common Secrets by Project Type:**

| Secret | Purpose | When Needed |
|--------|---------|-------------|
| `CODECOV_TOKEN` | Coverage reporting | If using Codecov |
| `NPM_TOKEN` | Package publishing | If publishing to npm |
| `VERCEL_TOKEN` | Frontend deployment | If deploying to Vercel |
| `RAILWAY_TOKEN` | Backend deployment | If deploying to Railway |
| `DATABASE_URL` | Database connection | If CI needs database |
| `DOCKER_USERNAME` / `DOCKER_PASSWORD` | Container registry | If publishing Docker images |

For each secret the user wants to configure:
1. Explain what the secret is used for.
2. Prompt for the secret value (masked input).
3. Set the secret via `gh secret set {name}`.
4. Verify the secret was set successfully.

**Autopilot Mode:** Skip secrets configuration (no way to auto-detect values). Note in report.

**Interactive Mode:** Present relevant secrets for the project type. User selects which to configure.

### 7. Generate Setup Report

Create a comprehensive DevOps setup report:

```yaml
devops-setup-report:
  timestamp: "{timestamp}"
  project_type: "{type}"
  repository:
    url: "{remote_url}"
    owner: "{owner}"
    name: "{repo_name}"
  workflows_installed:
    - name: "CI"
      file: ".github/workflows/ci.yml"
      triggers: ["pull_request", "push to {default_branch}"]
      checks: ["{lint}", "{typecheck}", "{test}"]
    - name: "PR Automation"
      file: ".github/workflows/pr-automation.yml"
  code_review:
    configured: true | false
    profile: "{profile}"
    config_file: "{config_file_path}"
  branch_protection:
    enabled: true | false
    branch: "{default_branch}"
    required_checks: ["{check1}", "{check2}"]
    required_reviewers: {count}
    notes: "{any_limitations}"
  secrets_configured:
    - "{secret_name_1}"
    - "{secret_name_2}"
  validation:
    workflows_valid: true | false
    protection_active: true | false
  next_steps:
    - "description of next step"
```

Save the report to the project configuration directory.

### 8. Commit and Push Configuration

After all configuration is complete:
1. Stage all new DevOps files: `.github/`, code review config, report.
2. Create a commit: `chore: add DevOps configuration`.
3. Inform the user that files are ready to push.
4. Do NOT push automatically -- that is a separate action delegated to the devops agent's push workflow.

### 9. Final Summary

Present a completion summary:
- Repository URL and detected project type.
- Installed workflows with their triggers and checks.
- Code review configuration status.
- Branch protection status.
- Secrets configured.
- Next steps:
  - Install the code review GitHub App (if applicable, with URL).
  - Create a test PR to verify the CI pipeline works.
  - Push the DevOps configuration: `git push`.
  - Review branch protection settings in GitHub Settings.

## Output Format

The primary outputs are:
1. GitHub Actions workflow files in `.github/workflows/`.
2. Code review configuration file.
3. Branch protection rules (applied via API).
4. Repository secrets (set via `gh secret set`).
5. DevOps setup report.

## Error Handling

- **Git repository not found:** Halt with message: "Git repository not found. Run environment-bootstrap first."
- **GitHub remote not configured:** Halt with message: "GitHub remote not configured. Run environment-bootstrap first."
- **GitHub CLI not authenticated:** Halt with message: "GitHub CLI not authenticated. Run `gh auth login`."
- **Repository not found on GitHub:** Halt with message: "Repository not found on GitHub. Push your code first."
- **Branch protection API returns 403:** Warn: "Branch protection requires GitHub Pro for private repos. Skipping. Set up manually via Settings > Branches." Continue without protection.
- **Workflow file conflict:** Ask user: overwrite, backup existing, or skip. Default: backup existing file as `{name}.backup.yml`.
- **Secrets permission denied:** Re-authenticate with `gh auth login --scopes repo,admin:repo_hook`. If still failing, provide manual instructions.
- **Invalid YAML in generated workflow:** Validate before writing. If invalid, report the error and do not write the file.
- **Project type not detected:** Ask user to specify manually. Default to a minimal CI workflow.

## Troubleshooting

### Branch protection API returns 403
- For private repos on free tier, branch protection requires GitHub Pro.
- Re-authenticate with correct scopes: `gh auth login --scopes repo,admin:repo_hook`.
- Manual setup via GitHub UI: Settings > Branches > Add branch protection rule.

### Workflow validation fails
- Validate YAML syntax: `yamllint .github/workflows/ci.yml`.
- Check for tab characters (use spaces only).
- Verify action versions are valid.

### Code review not reviewing PRs
- Verify GitHub App is installed (e.g., `https://github.com/apps/coderabbitai`).
- Check the app has access to the repository.
- Verify the config file is in the default branch.

## Examples

**Example 1: Standard Node.js project**
```
Project type: Node.js/TypeScript
Mode: Interactive
Result: Installed ci.yml and pr-automation.yml. Code review configured (balanced).
        Branch protection enabled (1 reviewer). CODECOV_TOKEN configured.
```

**Example 2: Quick setup for new project**
```
Project type: Node.js (auto-detected)
Mode: Autopilot
Result: Installed ci.yml and pr-automation.yml with defaults.
        Branch protection skipped. Secrets skipped.
```

**Example 3: Enterprise Python project**
```
Project type: Python
Mode: Pre-Flight
Result: Full plan presented with 3 workflows, assertive review profile,
        strict branch protection, 5 secrets. User approved. All configured.
```

## Acceptance Criteria

- [ ] At least the CI workflow is installed and contains valid YAML.
- [ ] Workflows are customized for the detected project type (correct language, commands).
- [ ] Code review configuration is created with appropriate path instructions.
- [ ] Branch protection is configured (or gracefully skipped with documentation).
- [ ] Repository secrets are set for user-selected values.
- [ ] A DevOps setup report documents all configurations.
- [ ] Existing files are not silently overwritten (backup or confirmation required).
- [ ] The user's execution mode preference is respected throughout.
- [ ] All pre-conditions are verified before proceeding.
- [ ] The configuration is committed locally and ready to push.

## Notes

- This task is designed to be idempotent. Running it again will detect existing configuration and offer to update or skip.
- Branch protection on free-tier private GitHub repos is limited. The task handles this gracefully.
- The code review service configuration is separate from the GitHub App installation. Remind users to install the App after configuration.
- Secrets are stored encrypted in GitHub and never logged or displayed in the report.
- For monorepos, workflow triggers may need path-based filtering. The Interactive mode allows customization.
- This task pairs with `environment-bootstrap` (run bootstrap first, then this task).
