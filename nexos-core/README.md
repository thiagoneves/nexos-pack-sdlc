# nexos

AI Agent Framework — Multi-tool, pack-based platform for orchestrating AI agents.

## What is nexos?

nexos is a declarative framework (Markdown + YAML, no runtime) for defining AI agents, tasks, and workflows. It works across multiple AI CLI tools and uses a pack system for domain-specific content.

**Supported tools:**
- Claude Code (Anthropic)
- Gemini CLI (Google)
- Antigravity (Google)

**Key concepts:**
- **Agents** — Specialized AI personas with defined roles, principles, and authority
- **Tasks** — Sequential instructions agents follow to accomplish objectives
- **Workflows** — Multi-phase processes connecting tasks and agents
- **Packs** — Domain-specific collections (e.g., software-dev, content-creation)

## Quick Start

```bash
# 1. Install nexos
curl -fsSL https://raw.githubusercontent.com/thiagoneves/nexos/main/install.sh | bash

# 2. Initialize your project
cd your-project
nexos init --tool claude-code

# 3. Install a pack
nexos install thiagoneves/nexos-pack-software-dev

# 4. Start using agents
# In Claude Code: @dev *develop story-1
```

## How It Works

```
                 nexos core
                     │
          ┌──────────┼──────────┐
          │          │          │
       Pack A     Pack B     Pack C
    (software)  (content)  (finance)
          │          │          │
          └──────────┼──────────┘
                     │
              ┌──────┼──────┐
              │      │      │
           Claude  Gemini  Anti-
           Code    CLI     gravity
```

1. **Define once** — Write agents, tasks, and workflows in the nexos format
2. **Install packs** — Add domain-specific packs to your project
3. **Generate** — nexos generates tool-specific config files automatically
4. **Use** — Agents work natively in your chosen AI CLI tool

## Commands

| Command | Description |
|---------|-------------|
| `nexos init --tool <tool>` | Initialize project for an AI CLI tool |
| `nexos install <repo>` | Install a pack from GitHub or local path |
| `nexos generate` | Regenerate tool-specific files |
| `nexos list` | List installed packs |
| `nexos remove <name>` | Remove an installed pack |
| `nexos update` | Update all packs |
| `nexos validate` | Validate pack files against schemas |
| `nexos create-pack <name>` | Create a new pack from template |

## Creating Packs

See [docs/creating-packs.md](docs/creating-packs.md) for the full guide.

Quick version:

```bash
nexos create-pack my-pack
cd my-pack
# Add agents, tasks, workflows
# Edit pack.yaml
```

## Directory Structure

```
nexos/
├── bin/nexos           # CLI tool
├── core/schemas/        # Format specifications (agent, task, workflow, pack)
├── templates/           # All templates (agent, task, workflow, pack scaffold, config)
├── agents/              # 4 maintenance agents (skill-creator, squad-creator, etc.)
├── adapters/            # Tool-specific generators (claude-code, gemini-cli, antigravity)
└── docs/                # Documentation
```

## Maintenance Agents

nexos includes 4 built-in agents for managing the framework itself:

| Agent | Purpose |
|-------|---------|
| @skill-creator | Creates new agents, tasks, and skills |
| @squad-creator | Designs team compositions |
| @pack-creator | Scaffolds new packs |
| @schema-validator | Validates files against schemas |

## License

MIT
