# Adapter Reference

## Overview

Adapters translate pack content into tool-specific configuration files. Each AI CLI tool has its own adapter.

## Claude Code

**Generated files:**

| File | Purpose |
|------|---------|
| `.claude/CLAUDE.md` | Main project instructions |
| `.claude/rules/*.md` | Rule files (copied from pack) |

**How it works:**
1. Reads all agents from installed packs
2. Generates CLAUDE.md with agent list, activation syntax, and framework structure
3. Copies rule files from pack `rules/` to `.claude/rules/`
4. Agent activation: `@agent-name` reads the full agent file from `.nexos/packs/`

## Gemini CLI

**Generated files:**

| File | Purpose |
|------|---------|
| `GEMINI.md` | Main project instructions |
| `.gemini/settings.json` | Context file configuration |

**How it works:**
1. Generates GEMINI.md with agent descriptions and `@import` directives for rules
2. Configures `.gemini/settings.json` to read both `AGENTS.md` and `GEMINI.md`
3. Rules are imported via `@path/to/rule.md` syntax

## Antigravity

**Generated files:**

| File | Purpose |
|------|---------|
| `.agent/rules/rules.md` | Merged rules from all packs |
| `.agent/skills/{agent-id}/SKILL.md` | One skill per agent |
| `.agent/workflows/{id}.md` | One file per workflow |

**How it works:**
1. Merges all pack rules into single `.agent/rules/rules.md`
2. Creates an Antigravity skill for each agent (maps agent → skill)
3. Copies workflows as Antigravity workflow files

## Universal: AGENTS.md

**Always generated** at project root, regardless of tool.

Contains tool-agnostic information:
- Project overview
- Installed packs and their agents
- Used by tools that support the AGENTS.md standard (Cursor, Codex, etc.)
