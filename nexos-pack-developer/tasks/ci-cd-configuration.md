---
task: ci-cd-configuration
agent: devops
inputs:
  - repository_path (required, string, local path or GitHub URL)
  - ci_provider (optional, string, github-actions|gitlab-ci|circleci|jenkins, default: github-actions)
  - project_type (required, string, nodejs|python|fullstack|monorepo)
  - testing_framework (optional, string, auto-detected from project files)
  - deployment_target (optional, string, vercel|netlify|aws|none, default: none)
  - enable_coderabbit (optional, boolean, default: true)
  - branch_protection (optional, boolean, default: true)
  - required_checks (optional, array of strings, default: [lint, test, build])
outputs:
  - workflow_files (array, created workflow/config file paths)
  - branch_protection_rules (object, applied branch protection settings)
  - coderabbit_config (object, CodeRabbit configuration if enabled)
  - pipeline_url (string, URL to view pipeline runs)
---

# Configure CI/CD Pipeline

## Purpose
Set up a complete, production-ready CI/CD pipeline for a repository, including linting, testing, building, automated code review (CodeRabbit), and deployment automation. Supports GitHub Actions (primary), GitLab CI/CD, CircleCI, and Jenkins.

## Prerequisites
- Valid git repository with a remote origin
- `package.json` or equivalent project manifest at root
- GitHub CLI (`gh`) installed and authenticated (for GitHub Actions)
- Repository admin access (for branch protection rules)

## Steps

### 1. Repository Analysis and Validation (Phase 1)

**Validate Repository:**
- Confirm valid git repository with remote origin
- Check CI provider compatibility

**Detect Project Structure:**
- Auto-detect project type if not provided (scan for `package.json`, `requirements.txt`, `pom.xml`)
- Identify testing framework from project files
- Identify build commands

**Check Existing CI Configuration:**
- Look for existing workflow files
- Warn if overwriting: create backup of existing config

### 2. CodeRabbit Setup (Phase 2)

CodeRabbit Free provides automated code review at no cost for public repositories.

**Install CodeRabbit GitHub App:**
- Guide user to https://github.com/apps/coderabbitai
- Wait for user confirmation of installation
- Verify installation via GitHub API

**Create CodeRabbit Configuration (`.coderabbit.yaml`):**

```yaml
language: "en-US"
reviews:
  profile: "chill"
  request_changes_workflow: false
  high_level_summary: true
  auto_review:
    enabled: true
    ignore_title_keywords:
      - "WIP"
      - "DO NOT REVIEW"
chat:
  auto_reply: true
focus:
  - security
  - performance
  - best_practices
  - testing
  - documentation
ignore:
  - "**/*.min.js"
  - "**/*.min.css"
  - "**/dist/**"
  - "**/build/**"
  - "**/node_modules/**"
```

### 3. GitHub Actions Workflow Creation (Phase 3)

**Create CI Workflow (`.github/workflows/ci.yml`):**

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
```

**Create Deployment Workflow** (if `deployment_target` provided):
- Generate `.github/workflows/deploy.yml` targeting the specified platform
- Configure environment secrets
- Trigger on push to `main` branch only

### 4. Branch Protection Rules (Phase 4)

If `branch_protection` is enabled, configure rules on `main`:
- Require pull request reviews (1 approval)
- Require status checks to pass: `lint`, `test`, `build`
- Require linear history
- Disallow force pushes
- Disallow branch deletions

Store any provided secrets using GitHub CLI:

```bash
gh secret set {SECRET_NAME} --body="{value}"
```

### 5. Documentation and Testing (Phase 5)

**Update README.md** with:
- CI/CD status badges
- Pipeline stages description
- CodeRabbit usage commands
- Branch protection summary
- Setup instructions for contributors

**Create Test PR:**
- Create a test branch with a trivial change
- Push and create PR to verify:
  - CI workflow triggers correctly
  - All checks run successfully
  - CodeRabbit reviews the PR
  - Branch protection is enforced
- Close test PR after validation

**Generate Setup Report:**
- Document all configured items
- List created workflow files
- Show pipeline URL
- Confirm CodeRabbit status
- List recommended next steps

## Error Handling
- **Not a git repository:** Exit with clear message
- **CI provider not supported:** List supported providers, suggest alternative
- **No project manifest found:** Ask user to specify `project_type` manually
- **CodeRabbit setup fails:** Continue without it, document for manual setup later
- **Branch protection API fails:** Log error, provide manual setup instructions
- **Secrets storage fails:** Warn user, provide manual `gh secret set` commands
- **Test PR fails checks:** Report which checks failed, suggest fixes
