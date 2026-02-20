---
task: facilitate-brainstorming
agent: analyst
inputs:
  - topic (required, string, min 20 characters, the challenge or question to brainstorm)
  - session_goal (optional, string, ideation|solution|strategy, default: ideation)
  - participating_agents (optional, array of strings, agent IDs to invite)
  - time_limit (optional, number, session duration in minutes, range: 10-60, default: 30)
  - output_format (optional, string, categorized|prioritized|actionable, default: categorized)
  - context_documents (optional, array of strings, file paths for additional context)
outputs:
  - ideas (array, all generated ideas with metadata)
  - categories (array, ideas grouped by theme)
  - prioritized_recommendations (array, top 5-10 ideas with next steps)
  - session_summary (object, session metadata and insights)
---

# Facilitate Brainstorming Session

## Purpose
Conduct a structured brainstorming session with multiple AI agents to generate, categorize, and prioritize ideas for features, solutions, or strategic decisions. Uses a multi-round approach (divergent thinking followed by convergent analysis) to produce actionable recommendations.

## Prerequisites
- Topic is well-defined and specific (at least 20 characters)
- Session goal is valid (ideation, solution, or strategy)
- If specified, participating agent IDs must be valid

## Steps

### 1. Setup and Context Loading (Phase 1, ~5 min)

**Load Context:**
- If context documents are provided, read and summarize key points
- Extract relevant constraints, requirements, or goals

**Select Participating Agents:**
- If agents are not specified, analyze the topic and auto-select 3-5 appropriate agents based on domain relevance
- Log the selected participants

**Define Session Structure** based on session goal:
- **Ideation:** Divergent thinking - generate maximum ideas
- **Solution:** Convergent thinking - evaluate and refine approaches
- **Strategy:** Structured frameworks (SWOT, OKRs, etc.)

### 2. Divergent Thinking - Idea Generation (Phase 2, ~10-15 min)

**Round 1: Initial Ideas (~5 min)**
- Prompt each agent: "Generate 3-5 ideas for: {topic}"
- Collect all responses
- No evaluation at this stage (pure brainstorming)

**Round 2: Build on Ideas (~5 min)**
- Share all ideas across agents
- Prompt: "Build on or remix existing ideas. Generate 2-3 new ideas inspired by what you see."
- Collect responses

**Round 3: Wild Cards (~2 min)**
- Prompt: "Generate 1-2 unconventional or 'what if' ideas"
- Encourage creative risk-taking

### 3. Convergent Thinking - Categorization (Phase 3, ~5-10 min)

**Categorize Ideas:**
- Identify themes and patterns across all generated ideas
- Group ideas into 3-7 categories (e.g., "Quick Wins", "Big Bets", "Research Needed", "Technical Solutions", "UX Improvements")

**Deduplicate and Merge:**
- Identify similar or overlapping ideas
- Merge related concepts while preserving unique aspects

### 4. Evaluation and Prioritization (Phase 4, ~5-10 min)

If output format is `prioritized` or `actionable`:

**Score Ideas** using these criteria:
- **Value:** Impact on users/business (1-10)
- **Effort:** Development complexity (1-10)
- **ROI:** Value/Effort ratio
- **Alignment:** Fits strategy/goals (1-10)

**Select Top Ideas:**
- Identify top 5-10 ideas based on aggregate scores
- For each, generate:
  - **Rationale:** Why this idea is valuable
  - **Next Steps:** Concrete actions to pursue it

### 5. Documentation (Phase 5, ~5 min)

**Create Session Report:**

```markdown
# Brainstorming Session: {topic}

**Date:** {date}
**Duration:** {duration} minutes
**Participants:** {agents}
**Goal:** {session_goal}

## Context
{context_summary}

## Ideas Generated
**Total:** {count}

### By Category
#### {category_name} ({count} ideas)
- {idea} (by {agent})

## Top Recommendations
### 1. {idea}
**Value Score:** {score}/10
**Effort Estimate:** {score}/10
**ROI:** {ratio}
**Why this matters:** {rationale}
**Next Steps:**
- {step}

## Key Insights
{insights}
```

## Error Handling
- **Topic too vague:** Request a more specific question or challenge (must include actionable context)
- **Agent not found:** Skip unavailable agent, continue with remaining participants
- **Insufficient ideas generated (< 10):** Extend session with additional rounds or add more agents
- **Context document not found:** Log warning, proceed without that context
- **Session timeout:** Save partial results, generate report with available ideas
