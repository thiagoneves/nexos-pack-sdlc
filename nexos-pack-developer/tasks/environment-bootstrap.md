---
task: environment-bootstrap
agent: devops
workflow: project-setup (phase 0)
inputs: [project name, project path, github org/user, options]
outputs: [configured environment, git repository, environment report]
---

# Environment Bootstrap

## Purpose

Perform a complete development environment bootstrap for a new project. This includes verifying and installing required CLI tools, authenticating external services, initializing a Git repository with GitHub remote, scaffolding the initial project structure, and validating that the environment is ready for development work.

This task should be the FIRST step in any new project setup, executed before any product requirements, architecture decisions, or development work begins.

## Prerequisites

- Operating system is macOS, Linux, or Windows (with appropriate shell).
- Internet connection is available for tool installation and service authentication.
- User has sufficient permissions to install software (admin/sudo may be required for some tools).
- A project name has been decided.

## Execution Modes

### Autopilot Mode (autonomous)

- 0-1 prompts. Install all essential tools, use sensible defaults.
- Skip optional tools.
- Create private GitHub repository under the user's default account.
- Best for: experienced developers, quick setup, automation scripts.

### Interactive Mode (default)

- 5-10 prompts at key decision points.
- Explain each tool's purpose before installation.
- Let user choose optional tools.
- Confirm GitHub repository settings.
- Best for: first-time setup, team onboarding, learning.

### Pre-Flight Mode (plan-first)

- Full environment analysis upfront before any installation.
- Present a complete setup plan with every tool, configuration, and action.
- User approves the plan before any changes are made.
- Execute the approved plan sequentially.
- Best for: enterprise environments, strict change policies, audit trails.

## Steps

### 1. Detect Operating System

Identify the current OS, architecture, and available package managers:
- **OS:** macOS, Linux (distribution), or Windows.
- **Architecture:** x64, arm64.
- **Package manager:** Homebrew (macOS), apt/dnf/pacman (Linux), winget/chocolatey/scoop (Windows).
- **Shell:** bash, zsh, PowerShell, fish.

Store this information for subsequent steps (installation commands differ per OS).

**Agent Guidance:**
- On macOS/Linux: use bash/zsh commands.
- On Windows: use PowerShell commands.
- Never mix shell syntax between platforms.
- Simple version checks work cross-platform: `git --version`, `node --version`, etc.

### 2. CLI Tools Audit

Check all required and optional CLI tools, presenting a comprehensive status table.

**Essential Tools (required):**

| Tool | Check Command | Minimum Version | Purpose | Install (macOS) | Install (Linux/apt) | Install (Windows) |
|------|--------------|-----------------|---------|-----------------|--------------------|--------------------|
| `git` | `git --version` | 2.x | Version control | `xcode-select --install` | `sudo apt install git` | `winget install --id Git.Git` |
| `gh` | `gh --version` | 2.x | GitHub CLI | `brew install gh` | `sudo apt install gh` | `winget install --id GitHub.cli` |
| `node` | `node --version` | 18.x or 20.x | JavaScript runtime | `brew install node@20` | See NodeSource setup | `winget install --id OpenJS.NodeJS.LTS` |
| `npm` | `npm --version` | 10.x | Package management | (installed with Node) | (installed with Node) | (installed with Node) |

**Recommended Tools (suggested):**

| Tool | Check Command | Purpose | Install (macOS) | Install (Linux) | Install (Windows) |
|------|--------------|---------|-----------------|----------------|--------------------|
| `docker` | `docker --version` | Containerization | `brew install --cask docker` | See Docker docs | `winget install --id Docker.DockerDesktop` |

**Optional Tools (user choice):**

| Tool | Check Command | Purpose | Install |
|------|--------------|---------|---------|
| `pnpm` | `pnpm --version` | Faster alternative to npm | `npm install -g pnpm` |
| `bun` | `bun --version` | Ultra-fast JS runtime | `curl -fsSL https://bun.sh/install \| bash` |
| `yarn` | `yarn --version` | Alternative package manager | `npm install -g yarn` |

Present the audit results as a status table showing: tool name, status (OK/MISSING/OUTDATED), current version, required version.

**Update Detection:**
For installed but outdated tools, display the current version, latest version, and the update command for the detected platform:

| Tool | Check Latest | Update (macOS) | Update (Linux) | Update (Windows) |
|------|-------------|----------------|----------------|------------------|
| `gh` | `gh api repos/cli/cli/releases/latest --jq .tag_name` | `brew upgrade gh` | `gh upgrade` | `winget upgrade GitHub.cli` |
| `node` | `npm view node version` | `brew upgrade node` | Use nvm/fnm | `winget upgrade OpenJS.NodeJS.LTS` |

### 3. Interactive Installation

Based on the audit results, offer to install missing tools:

**Autopilot Mode:** Install all missing essential tools automatically using the detected package manager. Skip optional tools.

**Interactive Mode:** Present options:
1. Install all missing essential + recommended tools.
2. Install essential tools only.
3. Custom selection (choose which tools to install).
4. Skip installation (not recommended if essentials are missing).

For each tool to install:
- Use the platform-appropriate package manager.
- Verify installation after each tool.
- Refresh PATH if needed.
- If installation fails, provide manual installation instructions and continue.

### 4. Service Authentication

Authenticate with required external services:

**GitHub CLI (required):**
1. Check current auth status: `gh auth status`.
2. If not authenticated, initiate login: `gh auth login`.
3. Verify authentication succeeded.
4. Check organization access if applicable.

**Additional services (if configured in project):**
- Prompt for each service that requires authentication.
- Check existing auth status before re-authenticating.
- Store auth tokens securely (use each tool's native credential storage).

If authentication fails for a non-essential service, warn and continue.

### 5. Git Repository Initialization

Set up the local and remote Git repository:

**Elicitation Point (Interactive/Pre-Flight):**
1. Create NEW repository on GitHub (recommended for new projects).
2. Link to EXISTING GitHub repository.
3. Local only (initialize git without GitHub).
4. Skip git initialization entirely.

**For new repository:**
- Prompt for: repository name (default: {project_name}), visibility (public/private), description, GitHub org/username.
- Initialize local git: `git init`.
- Create `.gitignore` appropriate for the project type.
- Create initial `README.md` with project name and basic structure.
- Create initial commit BEFORE creating GitHub repo (required for `--push` flag):
  ```
  git add .
  git commit -m "chore: initial project setup"
  ```
- Create GitHub repository: `gh repo create {name} --private --source . --remote origin --push`.
- Verify the remote is properly configured.

**For existing repository:**
- Prompt for the repository URL.
- Clone or add remote as appropriate.
- Verify connectivity.

**Error recovery:**
- If `gh repo create --push` fails (common issue: no commits exist), create the initial commit first, then retry.
- If GitHub repository creation fails entirely, fall back to creating the repo first and then pushing manually:
  ```
  gh repo create {name} --private --source . --remote origin
  git push -u origin main
  ```

**Default .gitignore contents:**
```
# Dependencies
node_modules/
.pnpm-store/

# Build outputs
dist/
build/
.next/
out/

# Environment files
.env
.env.local
.env.*.local

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Logs
logs/
*.log
npm-debug.log*

# Testing
coverage/
.nyc_output/

# Temporary files
tmp/
temp/
*.tmp
```

### 6. Project Structure Scaffold

Create the initial project directory structure:

```
{project_name}/
  docs/              # Documentation
    stories/         # User stories
    architecture/    # Architecture docs
    guides/          # Developer guides
  src/               # Source code
  tests/             # Test files
  .gitignore         # Git ignore rules
  README.md          # Project readme
  package.json       # Package configuration (if Node.js)
```

- Only create directories that do not already exist.
- Only create `package.json` if it does not exist and the project is Node.js-based.
- Use templates from the `templates/` directory when available.
- Do NOT overwrite existing files.

### 7. Generate Environment Report

Collect all environment information and produce a structured report:

```yaml
environment-report:
  generated_at: "{timestamp}"
  project_name: "{project_name}"
  system:
    os: "{os_name} {os_version}"
    architecture: "{arch}"
    shell: "{shell}"
    user: "{username}"
  cli_tools:
    git:
      installed: true | false
      version: "{version}"
      path: "{path}"
    gh:
      installed: true | false
      version: "{version}"
      authenticated: true | false
    node:
      installed: true | false
      version: "{version}"
    npm:
      installed: true | false
      version: "{version}"
    # ... additional tools
  repository:
    initialized: true | false
    remote_url: "{url}"
    branch: "{branch}"
  project_structure:
    directories_created: ["{dir1}", "{dir2}"]
    files_created: ["{file1}", "{file2}"]
  validation:
    essential_tools_complete: true | false
    authentication_complete: true | false
    repository_ready: true | false
    ready_for_development: true | false
```

Save the report to the project configuration directory.

### 8. Final Validation and Summary

Run final validation checks:
- All essential CLI tools are installed and accessible.
- GitHub CLI is authenticated.
- Git repository is initialized with a remote.
- Project structure is scaffolded.
- Environment report is generated.

**Validation Checklist:**
- [ ] Operating system detected correctly
- [ ] All essential CLIs installed (git, gh, node, npm)
- [ ] GitHub CLI authenticated
- [ ] Git repository initialized
- [ ] GitHub remote repository created
- [ ] .gitignore configured
- [ ] Project structure created
- [ ] Environment report generated
- [ ] Initial commit pushed to GitHub

Present a completion summary:
- Project name and repository URL.
- CLI tools status (installed, versions, authentication).
- Project structure overview.
- Next steps for the user:
  - Start creating product requirements or architecture docs.
  - Begin story-driven development.
  - Reference to the project workflow documentation.

## Output Format

The primary output is the configured environment itself, plus the environment report saved to the project.

## Error Handling

- **OS not detected:** Halt with message: "Unable to detect operating system. Manual setup required."
- **No package manager available:** Provide direct download URLs for each tool. Suggest installing a package manager first.
- **CLI installation fails:** Provide manual installation instructions. Log the failure. Continue with remaining tools.
- **GitHub authentication fails:** Offer to retry. If still failing, provide manual authentication steps. Allow continuing without GitHub (local-only mode).
- **Permission denied during installation:** Suggest running with elevated privileges or using user-scoped installation. Do not retry with sudo automatically.
- **Repository creation fails:** Fall back to local-only git initialization. Provide instructions for manual GitHub repo creation.
- **Internet not available:** Halt with message: "Internet connection required for tool installation and authentication. Check connectivity and retry."
- **Project directory is not empty:** Warn the user. Ask whether to proceed (scaffold around existing files) or abort.
- **Environment report write fails:** Warn and continue. The environment is still set up even if the report cannot be written.

## Examples

**Example 1: Fresh macOS setup**
```
Project: my-app
Mode: Interactive
Result: Installed gh, node 20. Authenticated GitHub. Created private repo.
        Scaffolded project structure. Environment ready in 4 minutes.
```

**Example 2: Existing tools, new project**
```
Project: api-service
Mode: Autopilot
Result: All tools already installed. Created GitHub repo.
        Scaffolded structure. Environment ready in 45 seconds.
```

**Example 3: Enterprise environment**
```
Project: enterprise-platform
Mode: Pre-Flight
Result: Full plan generated. User approved tool installations.
        Corporate proxy configured. GitHub Enterprise org used.
        Environment ready in 8 minutes.
```

## Acceptance Criteria

- [ ] OS and architecture are correctly detected.
- [ ] All essential CLI tools (git, gh, node, npm) are installed and verified.
- [ ] GitHub CLI is authenticated and can access the target org/user.
- [ ] Git repository is initialized locally with a proper `.gitignore`.
- [ ] GitHub remote repository is created and linked (unless local-only was chosen).
- [ ] Initial commit is pushed to the remote.
- [ ] Project directory structure is scaffolded without overwriting existing files.
- [ ] Environment report is generated and saved.
- [ ] The user's execution mode preference is respected throughout.
- [ ] All failures are handled gracefully with recovery suggestions.

## Troubleshooting

### winget not recognized (Windows)
- Update Windows to latest version (winget requires Windows 10 1809+).
- Or install App Installer from Microsoft Store.
- Or use alternative: `choco install gh` or `scoop install gh`.

### gh auth login fails
- Check internet connection.
- If behind corporate proxy: `gh config set http_proxy http://proxy:port`.
- Try token-based auth: `gh auth login --with-token`.

### Permission denied creating repository
- Re-authenticate with correct scopes: `gh auth login --scopes repo,workflow`.
- Check if organization requires SSO: `gh auth login --hostname github.com`.

### Docker not starting
- macOS: Open Docker.app and wait for it to start.
- Linux: `sudo systemctl start docker`.
- Windows: Ensure Docker Desktop is running.

## Rollback

To undo the environment bootstrap:
1. Remove local git: `rm -rf .git`.
2. Remove scaffolded files (if created by this task).
3. Delete GitHub repository: `gh repo delete {repo-name} --yes` (caution: irreversible).
4. Uninstall tools manually if desired.

## Notes

- This task is idempotent when re-run: it will skip already-completed steps (tools already installed, repo already created) and only perform missing actions.
- For Windows users, be aware that some tools may require WSL or specific shell configurations. The task should detect and guide accordingly.
- If the project uses a monorepo structure, the scaffold step should adapt to place files in the correct locations.
- This task should be run ONCE per project. Subsequent environment updates can be handled by running individual steps manually.
- The environment report serves as documentation for other team members setting up the same project.
- After this task completes, the next step is typically creating product requirements or architecture documentation, followed by story-driven development.
