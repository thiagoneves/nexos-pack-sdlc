---
task: ux-user-research
agent: ux-designer
inputs:
  - research objectives
  - target user description
  - available resources (budget, access to users, existing data)
outputs:
  - research summary
  - personas (2-4)
  - user journey maps
  - actionable insights (5-10)
---

# User Research and Needs Analysis

## Purpose

Conduct comprehensive user research to understand target users, their pain points, goals, and behaviors. Produce evidence-based personas, user journey maps, and actionable insights that drive design and development decisions. This task ensures that product design is grounded in real user needs rather than assumptions.

## Prerequisites

- A general understanding of who the target users are (even if informal).
- The product or feature area to be researched is identified.
- At minimum, one research method is feasible given available time and resources.
- No prior research is required -- this task establishes the baseline.

## Steps

### 1. Define Research Objectives

Establish what the research aims to discover. Present the following objective categories:

| Objective | Description | Typical Methods |
|-----------|-------------|-----------------|
| Understand user needs | Discover what users want to accomplish | Interviews, contextual inquiry |
| Validate concept | Test whether a product idea resonates | Interviews, surveys |
| Improve existing UX | Find pain points in current experience | Analytics review, interviews |
| Identify opportunities | Discover unmet needs or underserved segments | Interviews, competitor analysis |
| Compare against competitors | Understand the competitive landscape | Competitor analysis, surveys |
| Create user personas | Build evidence-based user archetypes | Interviews, surveys, analytics |

Select 1-3 objectives and gather follow-up context:
- Who are the target users? (Roles, demographics, tech proficiency.)
- What is the timeline? (Days, weeks, or months available for research.)
- What resources exist? (Budget, access to users, existing data.)
- What is already known? (Existing data, assumptions, prior research.)

### 2. Select Research Methods

Based on the objectives, recommend and confirm the research methods:

#### Method 1: User Interviews
- **When to use:** Deep qualitative insights, early discovery, understanding "why."
- **Participants:** 5-10 representative users.
- **Duration:** 30-60 minutes per interview.
- **Output:** Interview transcripts, key quotes, themes.
- **Effort:** 2-3 weeks (recruiting + conducting + synthesis).

#### Method 2: Surveys
- **When to use:** Quantitative validation, large sample, measuring preferences.
- **Participants:** 50+ users.
- **Duration:** 10-15 minutes per respondent.
- **Output:** Statistical data, usage patterns, preference distributions.
- **Effort:** 1-2 weeks (design + distribution + analysis).

#### Method 3: Analytics Review
- **When to use:** Understanding behavioral patterns in existing products.
- **Source:** Web analytics, product analytics, heatmaps.
- **Output:** Usage patterns, drop-off points, popular features, conversion funnels.
- **Effort:** 3-5 days.

#### Method 4: Competitor Analysis
- **When to use:** Understanding market context, identifying best practices and gaps.
- **Scope:** 3-5 direct competitors.
- **Output:** Feature comparison matrix, UX pattern inventory, opportunity gaps.
- **Effort:** 3-5 days.

#### Method 5: Contextual Inquiry
- **When to use:** Observing users in their natural environment.
- **Duration:** 2-4 hours per session.
- **Output:** Workflow observations, environment insights, workaround documentation.
- **Effort:** 1-2 weeks.

### 3. Prepare Research Materials

For each selected method, prepare the necessary materials:

**For interviews -- create an interview script:**

Structure the script with 10-15 open-ended questions:

```
Section 1: Warm-Up (2-3 questions)
- Tell me about your role and what a typical day looks like.
- How did you come to be doing {relevant_activity}?

Section 2: Current Experience (4-5 questions)
- Walk me through how you currently {do_task_X}.
- What tools or processes do you rely on for {task_X}?
- What works well about your current approach?
- What is the most frustrating part of {task_X}?
- When was the last time {task_X} went poorly? What happened?

Section 3: Needs and Goals (3-4 questions)
- What would an ideal solution for {task_X} look like?
- If you had a magic wand, what one thing would you change?
- How do you measure success for {task_X}?
- What have you tried that did not work?

Section 4: Wrap-Up (1-2 questions)
- Is there anything else you think I should know?
- Who else should I talk to about this?
```

**For surveys -- draft the questionnaire:**
- Screening questions (2-3): confirm participant is in the target audience.
- Multiple choice (5-8): quantify preferences and behaviors.
- Likert scale (3-5): measure sentiment and satisfaction (1-5 scale).
- Ranking (1-2): prioritize features or pain points.
- Open-ended (2-3): discover unexpected insights.
- Keep total completion time under 15 minutes.

**For analytics -- define the analysis framework:**
- Key metrics to review (e.g., DAU, retention, feature adoption, funnel conversion).
- Date range for analysis.
- Segments to compare (e.g., new vs. returning, free vs. paid).

**For competitor analysis -- define the evaluation framework:**
- List 3-5 competitors to evaluate.
- Define comparison dimensions (features, UX patterns, pricing, positioning).
- Prepare a comparison matrix template.

### 4. Conduct Research

Execute the selected methods. Document everything.

**Interview best practices:**
- Build rapport in the first 5 minutes before diving into questions.
- Ask open-ended questions ("Tell me about..." not "Do you like...").
- Probe deeper on interesting responses ("Why is that important to you?").
- Stay neutral -- do not lead responses or validate assumptions.
- Record key quotes verbatim (with participant permission).
- Note non-verbal cues (hesitation, enthusiasm, confusion).

**Survey best practices:**
- Test with 2-3 people before full distribution.
- Use clear, unbiased language.
- Avoid double-barreled questions (asking about two things at once).
- Provide a "Not applicable" option where relevant.
- Set a clear deadline for responses.

**Analytics best practices:**
- Look for patterns, not individual data points.
- Compare segments to find meaningful differences.
- Focus on behavior (what users do) not just demographics (who they are).
- Document drop-off points and unexpected patterns.

**Competitor analysis best practices:**
- Use the product as a real user would.
- Document the onboarding experience in detail.
- Note both strengths and weaknesses.
- Capture screenshots or notes for reference.

### 5. Analyze and Synthesize Findings

Process all collected data into structured insights:

**Step 5a: Organize raw data**
- Compile all interview transcripts, survey responses, analytics exports.
- Label each data point with its source and participant.

**Step 5b: Extract key observations**
- Pull out notable quotes, statistics, and behavioral patterns.
- Write each observation as a discrete statement.

**Step 5c: Affinity mapping**
- Group related observations into clusters.
- Name each cluster with a descriptive theme.
- Identify relationships between themes.

**Step 5d: Prioritize by frequency and impact**
- Count how many participants or data points support each theme.
- Assess the impact of each theme on the user experience.
- Rank themes by a combination of frequency and impact.

**Step 5e: Identify patterns**
- Look for recurring behaviors across participants.
- Identify common workarounds or pain points.
- Note any surprising or counter-intuitive findings.

### 6. Create Personas

Build 2-4 evidence-based personas representing the key user segments:

**Persona template:**

```markdown
## Persona: {Name}

### Demographics
- **Age range:** {range}
- **Role:** {job title or description}
- **Tech proficiency:** {Beginner | Intermediate | Advanced | Expert}
- **Context:** {relevant environmental details}

### Goals
- {Primary goal -- the main thing they want to accomplish}
- {Secondary goal -- an additional objective}
- {Aspirational goal -- what success looks like long-term}

### Pain Points
- {Pain 1 -- specific frustration with evidence}
- {Pain 2 -- another friction point}
- {Pain 3 -- another issue}

### Behaviors
- {How they currently solve this problem}
- {Tools and processes they use}
- {Typical workflow or routine}

### Key Quote
> "{A memorable, representative quote from research}"

### Needs from Product
- {Need 1 -- what the product must provide}
- {Need 2 -- what would make the product valuable}
- {Need 3 -- what would delight this persona}
```

**Guidelines:**
- Each persona should represent a meaningfully distinct user segment.
- Base personas on actual research data, not assumptions.
- Identify one primary persona (the most important user to design for).
- Avoid making personas too generic -- specific details make them useful.

### 7. Document User Journey Maps

For each primary persona, map their journey through the key use case:

**Journey map structure:**

```markdown
## Journey: {Persona Name} - {Use Case}

### Stage 1: {Stage Name} (e.g., Discovery)
- **Actions:** {What the user does}
- **Thoughts:** "{What they are thinking}"
- **Emotion:** {Positive | Neutral | Negative}
- **Pain Points:** {Friction encountered}
- **Opportunities:** {Where the product can improve}

### Stage 2: {Stage Name} (e.g., Evaluation)
...

### Stage 3: {Stage Name} (e.g., First Use)
...

### Stage 4: {Stage Name} (e.g., Regular Use)
...

### Stage 5: {Stage Name} (e.g., Advocacy or Churn)
...
```

Map the complete journey from awareness through regular use. Highlight the moments of highest frustration and highest satisfaction -- these are the key design opportunities.

### 8. Generate Actionable Insights

Distill the research into 5-10 ranked insights:

**Insight structure:**

```markdown
## Insight #{n}: {One-sentence summary}

**Evidence:**
- {Data point or statistic}
- "{Direct quote from participant}"
- "{Another supporting quote}"

**Impact:** {HIGH | MEDIUM | LOW}

**Frequency:** Reported by {n} of {total} participants

**Design Implications:**
- {How this should influence the product design}
- {Specific feature or behavior change this suggests}

**Recommended Actions:**
1. {Specific, actionable next step}
2. {Another action}
```

Rank insights by impact (HIGH first). Ensure each insight is:
- Evidence-based (linked to specific data).
- Actionable (leads to a clear next step).
- Specific (not vague or overly broad).

### 9. Compile Research Deliverables

Save all research artifacts to the output directory:

**Required deliverables:**
1. `research-summary.md` -- executive summary of findings, key statistics, and top recommendations.
2. `personas.md` -- 2-4 complete persona profiles with evidence.
3. `user-journeys.md` -- journey maps for each primary persona.
4. `insights.md` -- 5-10 ranked, actionable insights.

**Optional deliverables (based on methods used):**
5. `interview-script.md` -- the interview guide used.
6. `survey-questions.md` -- the survey instrument.
7. `analytics-summary.md` -- analytics review findings.
8. `competitor-analysis.md` -- competitive landscape assessment.
9. `raw-data/` -- interview notes, survey exports (anonymized).
10. `affinity-map.md` -- theme clusters from synthesis.

Save to: `{output_directory}/ux-research/{project_name}/`

### 10. Present Results

Inform the user:
- Number of participants or data sources analyzed.
- Number of personas created and their names.
- Top 3 insights by impact.
- Key design opportunities identified.
- Location of all deliverables.
- Suggested next steps:
  - Create wireframes informed by personas and insights: `*create-wireframe`.
  - Create frontend specifications referencing user needs.
  - Share personas with the development team for implementation context.

## Common Pitfalls

1. **Leading questions** -- Do not ask "Don't you think X is better?" Ask "How do you compare X and Y?"
2. **Too small sample** -- 1-2 interviews is not enough. Aim for 5-10 minimum.
3. **Confirmation bias** -- Do not only talk to happy users. Include frustrated users.
4. **No synthesis** -- Do not just collect data. Find patterns and themes.
5. **Ignoring context** -- Do not just ask questions. Observe actual behavior when possible.

## Error Handling

- **No access to real users:** Proceed with desk research (competitor analysis, analytics, domain knowledge). Generate provisional personas labeled as "assumption-based" with a recommendation to validate with real users.
- **Too few interview participants (<3):** Warn that findings may not be representative. Proceed but label all insights as "preliminary."
- **Survey response rate too low (<20 responses):** Warn that quantitative findings lack statistical significance. Present as directional data, not conclusions.
- **Conflicting data between methods:** Document the conflict transparently. Present both perspectives and recommend follow-up research to resolve.
- **Research objectives too broad:** Suggest narrowing to 1-2 objectives. Help the user prioritize.
- **Timeline too short for recommended methods:** Suggest the fastest feasible alternative (e.g., 5 guerrilla interviews instead of 10 formal ones, analytics review instead of survey).
- **No existing product data for analytics:** Skip analytics method. Note the gap and recommend establishing baseline metrics post-launch.

## Notes

- Quality of insights depends on quality of questions. Invest time in preparing good interview scripts and survey questions.
- Five well-conducted interviews often reveal more than 100 poorly designed survey responses. Depth beats breadth for discovery research.
- Always protect participant privacy. Anonymize data in deliverables and raw data exports.
- Personas are living documents. Update them as new research data becomes available.
- Avoid confirmation bias: actively seek out users who disagree with your assumptions or have had negative experiences.
- Research is not a one-time event. Schedule periodic check-ins with users to validate that the product continues to meet their needs.
