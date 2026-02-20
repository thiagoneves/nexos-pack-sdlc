# Getting Started with nexos

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/thiagoneves/nexos/main/install.sh | bash
source ~/.zshrc  # or ~/.bashrc
```

## Initialize a Project

Navigate to your project and choose your AI CLI tool:

```bash
cd your-project
nexos init --tool claude-code
```

This creates:
- `.nexos/config.yaml` — project configuration
- `AGENTS.md` — universal agent descriptions

## Install a Pack

Packs provide domain-specific agents, tasks, and workflows:

```bash
# From GitHub
nexos install thiagoneves/nexos-pack-software-dev

# From a local directory
nexos install ./my-local-pack
```

This downloads the pack and generates tool-specific files:
- Claude Code: `.claude/CLAUDE.md` + `.claude/rules/`
- Gemini CLI: `GEMINI.md` + `.gemini/settings.json`
- Antigravity: `.agent/rules/` + `.agent/skills/` + `.agent/workflows/`

## Using Agents

After installing a pack, activate agents in your AI CLI:

```
@dev *develop 1.1     # Start implementing story 1.1
@qa *qa-gate 1.1      # Run QA review
@architect *review     # Architecture review
```

## Switching Tools

If you want to switch from Claude Code to Gemini CLI:

```bash
nexos init --tool gemini-cli
nexos generate
```

Your packs stay the same — only the generated config files change.

## Next Steps

- [Creating Packs](creating-packs.md) — Build your own domain-specific pack
- [Adapter Reference](adapter-reference.md) — How each tool adapter works
- [Schema Reference](schema-reference.md) — Agent, task, workflow, and pack formats
