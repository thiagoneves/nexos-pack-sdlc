---
task: create-research-prompt
agent: analyst
inputs:
  - topic (optional, string, research topic or question)
  - input_document (optional, string, path to project brief, brainstorming results, or market research)
  - research_focus (optional, number, 1-9 corresponding to research type)
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - research_prompt (string, the complete research prompt document)
  - created_file (string, path to the saved prompt file)
---

# Create Deep Research Prompt

## Purpose
Generate well-structured research prompts that define clear objectives, specify appropriate methodologies, outline expected deliverables, and guide systematic investigation of complex topics. Can process inputs from brainstorming sessions, project briefs, market research, or standalone research questions.

## Prerequisites
- A research topic, question, or input document to drive prompt creation
- Target output location is writable

## Steps

### 1. Select Research Focus

Present these research focus options to the user:

1. **Product Validation Research** - Validate product hypotheses and market fit, test assumptions, assess feasibility
2. **Market Opportunity Research** - Analyze market size, growth potential, segments, entry strategies
3. **User and Customer Research** - Deep dive into personas, jobs-to-be-done, pain points, customer journeys
4. **Competitive Intelligence Research** - Competitor analysis, feature comparisons, business model analysis
5. **Technology and Innovation Research** - Technology trends, technical approaches, build vs. buy analysis
6. **Industry and Ecosystem Research** - Value chains, key players, regulatory factors, partnerships
7. **Strategic Options Research** - Strategic directions, business model alternatives, go-to-market strategies
8. **Risk and Feasibility Research** - Risk assessment, implementation challenges, resource requirements
9. **Custom Research Focus** - User-defined research objectives

### 2. Process Input Documents

Depending on what input is provided:

**If Project Brief provided:**
- Extract key product concepts and goals
- Identify target users and use cases
- Note technical constraints and preferences
- Highlight uncertainties and assumptions

**If Brainstorming Results provided:**
- Synthesize main ideas and themes
- Identify areas needing validation
- Extract hypotheses to test
- Note creative directions to explore

**If Market Research provided:**
- Build on identified opportunities
- Deepen specific market insights
- Validate initial findings
- Explore adjacent possibilities

**If Starting Fresh:**
- Gather essential context through questions
- Define the problem space
- Clarify research objectives
- Establish success criteria

### 3. Develop Research Objectives

Collaborate with the user to articulate:
- Primary research goal and purpose
- Key decisions the research will inform
- Success criteria for the research
- Constraints and boundaries

### 4. Develop Research Questions

**Core Questions:**
- Central questions that must be answered
- Priority ranking of questions
- Dependencies between questions

**Supporting Questions:**
- Additional context-building questions
- Nice-to-have insights
- Future-looking considerations

### 5. Define Research Methodology

**Data Collection Methods:**
- Secondary research sources to use
- Primary research approaches (if applicable)
- Data quality requirements
- Source credibility criteria

**Analysis Frameworks:**
- Specific frameworks to apply (SWOT, Porter's Five Forces, etc.)
- Comparison criteria
- Evaluation methodologies

### 6. Generate the Research Prompt

Assemble the complete prompt using this structure:

```markdown
## Research Objective
[Clear statement of what this research aims to achieve]

## Background Context
[Relevant information from inputs]

## Research Questions

### Primary Questions (Must Answer)
1. [Specific, actionable question]

### Secondary Questions (Nice to Have)
1. [Supporting question]

## Research Methodology

### Information Sources
- [Source types and priorities]

### Analysis Frameworks
- [Frameworks to apply]

### Data Requirements
- [Quality, recency, credibility needs]

## Expected Deliverables

### Executive Summary
- Key findings, critical implications, recommended actions

### Detailed Analysis
[Sections based on research type]

### Supporting Materials
- Data tables, comparison matrices, source documentation

## Success Criteria
[How to evaluate if research achieved its objectives]

## Timeline and Priority
[Time constraints or phasing if applicable]
```

### 7. Review and Refine

1. Present the complete research prompt
2. Explain key elements and rationale
3. Highlight assumptions made
4. Gather user feedback on objectives, questions, scope, and output requirements
5. Incorporate feedback and refine as needed

### 8. Provide Next Steps Guidance

**Execution Options:**
1. Use with an AI research assistant
2. Guide human research efforts
3. Hybrid approach combining AI and human research

**Integration Points:**
- How findings will feed into next phases
- Who should review results
- How to validate findings
- When to revisit or expand the research

## Error Handling
- **No topic or input provided:** Guide user through topic definition with structured questions
- **Input document not found:** Exit with clear error, suggest checking the path
- **Research focus out of range:** Show valid options (1-9) and re-prompt
- **Incomplete objectives:** Flag gaps and ask targeted questions to fill them
- **Prompt too broad:** Suggest narrowing the scope by focusing on specific aspects
