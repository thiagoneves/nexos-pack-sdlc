---
task: spec-research-dependencies
agent: analyst
workflow: spec-pipeline (phase 3)
inputs: [requirements.json, complexity assessment]
outputs: [research findings document]
skip_conditions: [complexity class is SIMPLE (unless forced)]
---

# Research Dependencies

## Purpose

Research external dependencies, APIs, libraries, technical patterns, and security
considerations that inform the specification. This phase validates that the proposed
technical approach is feasible, identifies verified dependencies with documentation
and code examples, and flags any unverified claims or risks.

The research output becomes a critical input for the spec writer (phase 4) and the
critique reviewer (phase 5), ensuring that the final specification is grounded in
verified technical reality rather than assumptions.

---

## Prerequisites

- Requirements document from phase 1 is available.
- Complexity assessment from phase 2 is available and class is STANDARD or COMPLEX.
- If complexity class is SIMPLE, this task should be skipped entirely (unless forced).
- The executing agent has access to the project codebase for existing dependency checks.
- Access to documentation sources (web, package registries, API docs) is available.

---

## Skip Conditions

This phase can be skipped under the following conditions:

| Condition | Reason | Action |
|-----------|--------|--------|
| Complexity class is SIMPLE | Simple tasks use existing patterns | Generate minimal output noting "no research needed" |
| No external dependencies | Pure internal implementation | Generate output noting "no external dependencies" |
| Force flag provided | Override skip for SIMPLE class | Execute full research regardless of class |

When skipped, create a minimal research document stating the reason for skipping,
so downstream phases have a consistent input structure.

---

## Steps

### Step 1: Verify Applicability

Check whether this phase should execute.

**Substeps:**

1. Load the complexity assessment.
2. Check the complexity class:
   - If `SIMPLE` and no force flag: Skip. Inform user. Generate minimal output.
   - If `STANDARD` or `COMPLEX`: Proceed with research.
3. If skipping, create minimal output and hand off to phase 4.

---

### Step 2: Extract Research Targets

Parse the requirements and complexity assessment to identify what needs research.

**Substeps:**

1. **Identify libraries and frameworks:**
   - Parse requirements for explicit library mentions.
   - Check constraints for technology mandates.
   - Examples: "zustand", "tanstack-query", "zod", "prisma"

2. **Identify APIs and services:**
   - Parse requirements for external service mentions.
   - Check for authentication, payment, messaging integrations.
   - Examples: "OAuth", "Stripe API", "SendGrid", "Twilio"

3. **Identify technical concepts:**
   - Parse requirements for patterns or approaches that need research.
   - Examples: "real-time sync", "optimistic updates", "CRDT", "event sourcing"

4. **Identify infrastructure components:**
   - Parse requirements for infrastructure needs.
   - Examples: "Redis", "PostgreSQL", "Vercel", "Docker", "message queue"

5. **Compile research target list:**
   - For each target: name, type (library/api/concept/infrastructure), and
     which requirement(s) mention it.

**Output:** List of research targets with types and requirement references.

---

### Step 3: Check Existing Codebase

Before external research, check what already exists in the project.

**Substeps:**

1. **Check package manifest:**
   - Look in package.json, requirements.txt, Cargo.toml, go.mod, etc.
   - Determine if the dependency is already installed and which version.

2. **Check imports and usage:**
   - Search for existing imports of the target library.
   - Find usage examples in the codebase.
   - Note file paths and patterns used.

3. **Find similar implementations:**
   - Search for patterns similar to what the requirements describe.
   - Check if the project has existing utilities or wrappers.

4. **Record findings:**
   - For each target: installed (yes/no), current version, usage locations.

---

### Step 4: Research External Documentation

For each research target not fully covered by the codebase check:

**Substeps:**

1. **For libraries:**
   - Look up official documentation.
   - Find getting-started guides and setup instructions.
   - Extract code examples relevant to the use case.
   - Check version compatibility with the project's stack.
   - Check maintenance status (active, deprecated, abandoned).
   - Check license compatibility.

2. **For APIs:**
   - Find official API documentation.
   - Check authentication requirements.
   - Review rate limits, pricing, and SLA information.
   - Check API versioning and deprecation status.
   - Find SDKs or client libraries available.

3. **For technical concepts:**
   - Research industry best practices.
   - Find implementation patterns and examples.
   - Identify common pitfalls and anti-patterns.
   - Check for relevant design patterns.

4. **For infrastructure:**
   - Research setup and configuration requirements.
   - Check compatibility with existing infrastructure.
   - Review operational requirements (monitoring, scaling).
   - Check pricing and resource requirements.

**Research depth by complexity class:**
- **STANDARD:** Focused research on direct dependencies and key technical decisions.
  Verify feasibility and find basic patterns.
- **COMPLEX:** Deep research including alternative approaches, proof-of-concept
  recommendations, risk mitigation strategies, and fallback options.

---

### Step 5: Check Technical Preferences

Validate research findings against project technical preferences.

**Substeps:**

1. Check if the project has a documented technical preferences file.
2. For each dependency:
   - Is it in the preferred list? (preferred = true)
   - Are there preferred alternatives? (list them)
   - Any known conflicts with existing dependencies?
3. Flag any dependency that conflicts with project preferences.
4. Suggest alternatives when a non-preferred dependency is needed.

---

### Step 6: Evaluate Findings Against Requirements

Map research findings back to specific requirements.

**Substeps:**

1. For each FR/NFR/CON, confirm the research supports or impacts it.
2. Identify requirements that cannot be met as stated (with explanation).
3. Note any new constraints discovered during research.
4. Flag requirements that may need revision based on findings.
5. Document any unverified claims (things stated in requirements but not
   confirmed by research).

---

### Step 7: Compile Research Document

Structure the findings into a research output document.

**Required sections:**

```
{
  "project": "{project-name}",
  "date": "{YYYY-MM-DD}",
  "researcher": "@analyst",
  "complexity_class": "{SIMPLE|STANDARD|COMPLEX}",

  "dependencies": [
    {
      "name": "{dependency name}",
      "type": "{library|api|service|infrastructure}",
      "version": "{recommended version}",
      "verified": true,
      "source": "{documentation|codebase|web search}",

      "existing": {
        "installed": false,
        "current_version": null,
        "usage_locations": []
      },

      "documentation": {
        "url": "{docs URL}",
        "relevant_sections": ["{section names}"]
      },

      "patterns": [
        {
          "name": "{pattern name}",
          "description": "{when to use}",
          "code_example": "{code snippet}"
        }
      ],

      "compatibility": {
        "preferred": true,
        "alternatives": ["{alt libraries}"],
        "conflicts": ["{known conflicts}"]
      }
    }
  ],

  "unverified_claims": [
    {
      "claim": "{statement from requirements}",
      "reason": "{why not verified}",
      "action": "{needs_validation|acceptable_risk|blocked}"
    }
  ],

  "recommendations": [
    {
      "type": "{prefer|avoid|consider}",
      "subject": "{dependency or approach}",
      "rationale": "{why}"
    }
  ],

  "new_constraints": [
    {
      "id": "CON-NEW-{n}",
      "description": "{constraint discovered during research}",
      "source": "{research finding that revealed it}"
    }
  ],

  "requirement_impacts": [
    {
      "requirement_id": "{FR-001}",
      "impact": "{how research affects this requirement}",
      "action": "{confirm|revise|remove}"
    }
  ],

  "research_notes": "{additional context and observations}"
}
```

Save to the project's docs or spec directory.

---

### Step 8: Present Summary and Handoff

Present findings to the user before handing off to phase 4.

**Substeps:**

1. **Key findings summary:** 2-5 bullet points of the most important discoveries.
2. **Requirements that need revision:** List any requirements affected by findings.
3. **New constraints:** Any constraints discovered during research.
4. **Risks identified:** With recommended mitigations.
5. **Unverified items:** Anything that could not be confirmed.
6. **Confirm:** Ask user to review findings before proceeding.
7. **Handoff:** Next step is `spec-write-spec` (phase 4).

---

## Pipeline Integration

```yaml
pipeline:
  phase: research
  previous_phase: assess
  next_phase: spec

  requires:
    - requirements.json
    - complexity assessment

  pass_to_next:
    - research findings
    - requirements.json
    - complexity assessment

  skip_conditions:
    - "complexity class is SIMPLE and no force flag"
```

---

## Error Handling

| Error | Condition | Action | Blocking |
|-------|-----------|--------|----------|
| Documentation unavailable | Cannot find docs for a dependency | Mark as unverified, add to unverified_claims | NO |
| Conflicting dependency | Dependency conflicts with existing stack | Add to recommendations with "avoid" type, suggest alternative | NO |
| All research sources fail | Cannot access any documentation source | Generate minimal output with manual research flag | NO |
| Dependency deprecated | Target library is deprecated or abandoned | Flag in recommendations, suggest actively maintained alternative | NO |
| License incompatible | Dependency license conflicts with project | Add to recommendations with "avoid" type, find compatible alternative | NO |
| API docs outdated | API documentation does not match current API | Mark as unverified, recommend testing before commitment | NO |
| Scope expanding | Research reveals much larger scope than expected | Stay within requirement boundaries, note out-of-scope discoveries for future | NO |
| Blocking issue found | Research uncovers a fundamental blocker | Flag immediately, do not wait until end to report | YES |
| Version conflict | Required version conflicts with existing dependency | Document the conflict, research resolution approaches | NO |

---

## Examples

### Example 1: Library Research (STANDARD)

**Target:** zustand (state management library)

**Research process:**
1. Check codebase: Not installed, no existing state management.
2. Documentation lookup: Official docs found at pmnd.rs/zustand.
3. Pattern extraction: createStore, middleware, devtools integration.
4. Compatibility: Works with React 18+, no conflicts found.

**Output entry:**
```json
{
  "name": "zustand",
  "type": "library",
  "version": "^4.5.0",
  "verified": true,
  "source": "documentation",
  "existing": { "installed": false },
  "documentation": {
    "url": "https://docs.pmnd.rs/zustand/",
    "relevant_sections": ["Getting Started", "Middleware", "TypeScript"]
  },
  "patterns": [{
    "name": "createStore",
    "description": "Basic store creation with set/get",
    "code_example": "const useStore = create((set) => ({ count: 0, inc: () => set(s => ({ count: s.count + 1 })) }))"
  }],
  "compatibility": {
    "preferred": true,
    "alternatives": ["jotai", "recoil", "redux-toolkit"],
    "conflicts": []
  }
}
```

### Example 2: API Research (COMPLEX)

**Target:** Google OAuth 2.0 integration

**Research process:**
1. Check codebase: No existing OAuth implementation.
2. API docs: Google Identity Services documentation reviewed.
3. Security: PKCE flow recommended for SPAs, server-side flow for SSR.
4. Rate limits: 10,000 requests/100 seconds per project.
5. SDK: google-auth-library for Node.js, verified active maintenance.

**Unverified claim:**
```json
{
  "claim": "Google OAuth response time < 500ms",
  "reason": "Depends on Google's servers, network latency, user's consent flow",
  "action": "acceptable_risk"
}
```

### Example 3: Skipped Research (SIMPLE)

**Input:** Complexity class is SIMPLE (total score 6).

**Minimal output:**
```json
{
  "project": "my-project",
  "date": "2026-02-20",
  "researcher": "@analyst",
  "complexity_class": "SIMPLE",
  "dependencies": [],
  "unverified_claims": [],
  "recommendations": [],
  "research_notes": "Research phase skipped: complexity class SIMPLE. Existing codebase patterns sufficient."
}
```

---

## Acceptance Criteria for This Task

- [ ] Applicability check performed (SIMPLE = skip, STANDARD/COMPLEX = proceed).
- [ ] All research targets extracted from requirements and listed with types.
- [ ] Existing codebase checked for each target (installed, version, usage).
- [ ] Each target researched through available documentation sources.
- [ ] Findings mapped back to specific requirements (FR/NFR/CON).
- [ ] Unverified claims documented with reason and action.
- [ ] Recommendations provided for each dependency (prefer/avoid/consider).
- [ ] Technical preferences checked for compatibility.
- [ ] New constraints discovered are documented.
- [ ] Research document saved to docs or spec directory.
- [ ] Summary presented to user with key findings and risks.

---

## Notes

- Research should be evidence-based. Distinguish verified facts from assumptions.
  Always note the source of information.
- When multiple options exist for a dependency, present alternatives with trade-offs.
  Do not make the choice for the user unless preferences are clear.
- Research depth should match complexity class. Do not over-research STANDARD items
  or under-research COMPLEX items.
- The research document is used by the spec writer (phase 4) to ground the technical
  approach in verified reality. Unverified items become risks in the spec.
- If a blocking issue is discovered during research (a fundamental requirement that
  cannot be met), flag it immediately. Do not wait until the end to report blockers.
- Keep research focused on the requirements. Note out-of-scope discoveries for future
  consideration, but do not expand the research scope beyond what the requirements need.
- When documentation is unavailable or incomplete, this is itself a finding worth
  documenting. Poor documentation is a risk factor for implementation.
