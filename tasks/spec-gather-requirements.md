---
task: spec-gather-requirements
agent: pm
workflow: spec-pipeline (phase 1)
inputs: [user input, existing docs, project context]
outputs: [requirements.json or structured requirements document]
skip_conditions: never (this phase is always mandatory)
---

# Gather Requirements

## Purpose

Conduct a structured, interactive requirements gathering session to capture functional
requirements, non-functional requirements, constraints, domain model entities,
user interactions, edge cases, terminology, and assumptions from the user.
This phase transforms informal descriptions into formal, categorized, traceable
requirements that serve as the foundation for all subsequent spec pipeline phases.

This phase is **mandatory** and never skipped, regardless of complexity class.

---

## Prerequisites

- The user has a feature, project, or change they want specified.
- Access to any existing project documentation (PRD, architecture docs, prior specs).
- This task is always the first phase of the spec pipeline.
- The executing agent has read access to the project repository and docs directory.

---

## Steps

### Step 1: Establish Context

Before gathering requirements, understand the current landscape.

**Substeps:**

1. **Check for existing documentation:**
   - Look for PRD files in the project docs directory.
   - Check for existing architecture documentation.
   - Look for prior specs or requirement documents.

2. **Identify project context:**
   - Determine the project's technology stack and constraints.
   - Identify target users and stakeholders.
   - Understand the current state of the codebase (greenfield vs brownfield).

3. **Determine requirement source:**
   - `prd` -- Requirements will be extracted from an existing PRD document.
   - `user` -- Requirements will be elicited interactively from the user.
   - `existing` -- Requirements will be refined from an existing spec.

4. **Present context summary:**
   - Show the user what documentation was found.
   - Confirm the requirement source.
   - Ask the user to correct or supplement the context.

**Output of this step:** Confirmed context and requirement source.

---

### Step 2: Elicitation Session (if source = user)

**CRITICAL: This phase requires user interaction. Do NOT skip or auto-generate.**

Structure questions into 9 categories. For each category, ask the main question,
then follow up as needed for clarity.

#### Category 1: Functional Requirements (FR)

- **Main question:** What should the system DO? What are the core features?
- **Follow-ups:**
  - Who are the users of this functionality?
  - What triggers or initiates each action?
  - What are the inputs and outputs for each feature?
  - What are the business rules and logic?
- **Assign:** `FR-{n}` identifiers

#### Category 2: Constraints (CON)

- **Main question:** Are there technical or business CONSTRAINTS?
- **Examples to probe:**
  - Maximum response time requirements
  - Mandatory integrations with existing systems
  - Technology stack limitations or mandates
  - Budget or timeline constraints
  - Regulatory or legal constraints
  - Team skill constraints
- **Assign:** `CON-{n}` identifiers

#### Category 3: Non-Functional Requirements (NFR)

- **Main question:** What are the important NON-FUNCTIONAL requirements?
- **Examples to probe:**
  - Performance (latency, throughput, response times)
  - Security (authentication, authorization, encryption)
  - Scalability (users, data volume, concurrent connections)
  - Availability and uptime requirements
  - Accessibility standards (WCAG levels)
  - Reliability and fault tolerance
- **Assign:** `NFR-{n}` identifiers

#### Category 4: Acceptance Criteria (AC)

- **Main question:** How do we know it is DONE? What are the acceptance criteria?
- **Preferred format:** Given/When/Then (Gherkin-style)
- **Example:**
  ```
  Given a user on the login page
  When they click "Login with Google"
  Then they are redirected to Google OAuth
  And after authorization, they are logged into the system
  ```
- **Link each AC** to one or more FR-* items.

#### Category 5: Assumptions (ASM)

- **Main question:** What ASSUMPTIONS are we making?
- **Follow-ups:**
  - What happens if this assumption is wrong?
  - Does this assumption need validation before implementation?
- **Assign:** `ASM-{n}` identifiers
- **Note:** Document for posterior validation.

#### Category 6: Domain Model (DM)

- **Main question:** What ENTITIES and RELATIONSHIPS exist in this domain?
- **Follow-ups:**
  - What are the main domain objects?
  - How do they relate to each other?
  - What attributes are mandatory?
- **Examples:**
  - User has many Orders
  - Product belongs to Category
  - Invoice references Order
- **Assign:** `DM-{n}` identifiers

#### Category 7: Interactions and UX (INT)

- **Main question:** How does the USER INTERACT with the system?
- **Follow-ups:**
  - What is the main flow (happy path)?
  - What screens or components are involved?
  - Are there loading, error, or empty states to consider?
- **Examples:**
  - User clicks button -> modal opens -> form submits -> success toast
  - Page loads -> fetches data -> displays list or empty state
- **Assign:** `INT-{n}` identifiers

#### Category 8: Edge Cases (EC)

- **Main question:** What happens when something GOES WRONG?
- **Follow-ups:**
  - What if the network fails?
  - What if the user lacks permission?
  - What if the data is invalid?
  - What if an external service is unavailable?
- **Examples:**
  - Timeout after 30s -> automatic retry -> fallback to cache
  - Validation fails -> show inline errors -> do not submit
- **Assign:** `EC-{n}` identifiers

#### Category 9: Terminology (TERM)

- **Main question:** Is there a GLOSSARY or domain-specific terminology?
- **Follow-ups:**
  - Does any term have a specific meaning in this context?
  - Are there synonyms that need to be standardized?
- **Examples:**
  - "Client" vs "User" vs "Account" -- which to use?
  - "Order" means purchase order or service request in this context?
- **Note:** Terminology inconsistency causes bugs and confusion.

---

### Step 3: PRD Extraction (if source = prd)

When requirements come from an existing PRD document:

**Substeps:**

1. **Load the PRD** from the specified path.
2. **Extract sections:**
   - User stories -> map to functional requirements (FR-*).
   - Acceptance criteria -> map to acceptance array.
   - Technical constraints -> map to constraints (CON-*).
   - Non-functional requirements -> map to NFR-*.
   - Domain entities -> map to domain model (DM-*).
3. **Validate extraction:**
   - Ensure all extracted items have clear descriptions (>= 10 characters).
   - Flag ambiguous requirements for clarification.
   - Cross-reference with PRD goals to ensure nothing is missed.
4. **Present to user** for confirmation and gap-filling.

---

### Step 4: Existing Spec Refinement (if source = existing)

When iterating on an existing specification:

**Substeps:**

1. **Load the existing spec** and parse its requirements.
2. **Identify gaps** by comparing against the 9-category framework.
3. **Present gaps** to the user and ask targeted questions.
4. **Merge** new information with existing requirements.
5. **Increment** the elicitation version number.

---

### Step 5: Clarify and Prioritize

For each requirement gathered:

**Substeps:**

1. **Remove ambiguity:**
   - Ask clarifying questions for any requirement with description < 10 characters.
   - Ensure each requirement is testable and specific.

2. **Assign priority:**
   - Use MoSCoW: MUST, SHOULD, COULD, WONT.
   - Or use P0 (critical), P1 (important), P2 (nice-to-have).

3. **Confirm understanding:**
   - Read back each requirement to the user.
   - Ask explicit confirmation before recording.

4. **Identify dependencies:**
   - External dependencies (APIs, services, libraries).
   - Internal dependencies (other stories, modules).
   - Stakeholders who should review the requirements.

---

### Step 6: Compile Requirements Document

Structure the output as a requirements document.

**Required sections and their identifiers:**

| Section | ID Pattern | Description |
|---------|-----------|-------------|
| Functional Requirements | FR-{n} | What the system must do |
| Non-Functional Requirements | NFR-{n} | Quality attributes |
| Constraints | CON-{n} | Boundaries and limitations |
| Assumptions | ASM-{n} | Documented assumptions |
| Domain Model | DM-{n} | Entities and relationships |
| Interactions | INT-{n} | User flows and UX states |
| Edge Cases | EC-{n} | Failure scenarios and handling |
| Terminology | TERM-{n} | Domain glossary entries |
| Open Questions | OQ-{n} | Unresolved items |

**Minimum viable output:** At least 1 functional requirement (FR-1).

---

### Step 7: Confirm and Handoff

Present the complete requirements summary to the user:

**Substeps:**

1. **Summary statistics:**
   - Total count of FR, NFR, CON, ASM, DM, INT, EC, TERM items.
   - Count of open questions.
   - Count of blocking vs non-blocking open questions.

2. **Highlight risks:**
   - Any blocking open questions.
   - High-risk assumptions.
   - Unresolved ambiguities.

3. **Confirm completeness:**
   - Ask the user to confirm the requirements are complete.
   - Note any deferred items for future consideration.

4. **Handoff:**
   - Save the output to the project's docs or spec directory.
   - Inform the user that the next step is `spec-assess-complexity` (phase 2).

---

## Output Format

The output should be a structured requirements document (JSON or YAML).

Reference template: `templates/requirements-template.json`

**Key fields:**

```
{
  "project": "{project-name}",
  "date": "{YYYY-MM-DD}",
  "gathered_by": "@pm",
  "source": "{prd|user|existing}",

  "functional_requirements": [
    {
      "id": "FR-001",
      "description": "{requirement description}",
      "priority": "{MUST|SHOULD|COULD|WONT}",
      "rationale": "{why this is needed}",
      "acceptance": ["{AC in Given/When/Then format}"]
    }
  ],

  "non_functional_requirements": [
    {
      "id": "NFR-001",
      "category": "{performance|security|scalability|usability|reliability}",
      "description": "{requirement}",
      "metric": "{measurable criteria}"
    }
  ],

  "constraints": [
    {
      "id": "CON-001",
      "type": "{technical|business|regulatory}",
      "description": "{constraint}",
      "impact": "{how it affects the solution}"
    }
  ],

  "assumptions": [
    {
      "id": "ASM-001",
      "description": "{assumption}",
      "risk_if_wrong": "{impact if assumption is invalid}",
      "validation_needed": true
    }
  ],

  "domain_model": [
    {
      "id": "DM-001",
      "entity": "{entity name}",
      "attributes": ["{attr1}", "{attr2}"],
      "relationships": [
        { "type": "{has_many|belongs_to|has_one}", "target": "{other entity}" }
      ]
    }
  ],

  "interactions": [
    {
      "id": "INT-001",
      "trigger": "{user action}",
      "flow": ["{step1}", "{step2}", "{step3}"],
      "states": {
        "loading": "{loading behavior}",
        "error": "{error behavior}",
        "empty": "{empty state}"
      }
    }
  ],

  "edge_cases": [
    {
      "id": "EC-001",
      "scenario": "{what goes wrong}",
      "handling": "{how to handle}",
      "severity": "{critical|high|medium|low}"
    }
  ],

  "terminology": [
    {
      "term": "{term}",
      "definition": "{meaning in this context}",
      "synonyms": ["{alt1}", "{alt2}"],
      "avoid": ["{terms to avoid}"]
    }
  ],

  "open_questions": [
    {
      "id": "OQ-001",
      "question": "{question}",
      "blocking": true,
      "assigned_to": "@{agent}"
    }
  ],

  "dependencies": ["{external dependency 1}", "{external dependency 2}"]
}
```

---

## Pipeline Integration

```yaml
pipeline:
  phase: gather
  next_phase: assess
  pass_to_next:
    - requirements.json
  skip_conditions: []  # Gather is always required
```

---

## Error Handling

| Error | Condition | Action | Blocking |
|-------|-----------|--------|----------|
| No requirements | Functional array is empty after elicitation | Re-prompt user for at least one functional requirement | YES |
| Ambiguous requirement | Description < 10 characters | Ask for clarification | NO |
| Missing acceptance criteria | FR has no acceptance criteria | Generate suggested criteria for user review | NO |
| Vague requirements | User provides unclear descriptions | Ask specific follow-up questions; do NOT guess or invent | NO |
| Conflicting requirements | Two requirements contradict each other | Flag the conflict, present both sides, ask user to resolve | YES |
| Scope creep | Items expand beyond original scope | Note expanded items, suggest deferring to a separate story | NO |
| Contradictory docs | Existing docs disagree with each other | Present contradiction, ask which source is authoritative | NO |
| Early session end | User ends session before completion | Save progress, note incomplete sections, inform how to resume | NO |
| PRD not found | source=prd but file path is invalid | Ask user for correct path or switch to user elicitation | YES |

---

## Examples

### Example 1: Interactive User Elicitation

**Input:** "I want to add login with Google"

**Elicitation session:**

```
Category 1 - Functional Requirements:
Q: What should the system DO?
A: Allow users to log in using their Google account.

Category 2 - Constraints:
Q: Are there technical constraints?
A: Must use OAuth 2.0. Must not store passwords.

Category 3 - Non-Functional:
Q: Non-functional requirements?
A: Login must complete in < 3 seconds.

Category 4 - Acceptance Criteria:
Q: How do we know it is done?
A: Given a user on the login page
   When they click "Login with Google"
   Then they are redirected to Google OAuth
   And after authorization, they are logged into the system

Category 6 - Domain Model:
Q: What entities and relationships?
A: User entity needs a google_id field. User has one AuthProvider.

Category 7 - Interactions:
Q: How does the user interact?
A: Click "Login with Google" -> redirect to Google -> consent screen ->
   redirect back -> logged in dashboard

Category 8 - Edge Cases:
Q: What happens if something goes wrong?
A: If Google is down, show "Service temporarily unavailable" message.
   If user denies consent, return to login page with explanation.
```

**Output:** `docs/specs/{feature-name}/requirements.json` with 1 FR, 1 NFR, 1 CON,
1 DM, 1 INT, 2 EC items.

### Example 2: PRD Extraction

**Input:** `--source=prd --prd=docs/prd/feature-auth.md`

**Process:**
1. Load PRD from specified path.
2. Extract 5 user stories -> FR-001 through FR-005.
3. Extract 3 constraints -> CON-001 through CON-003.
4. Extract 2 NFRs -> NFR-001 and NFR-002.
5. Present summary to user for confirmation.
6. User confirms, output saved.

### Example 3: Preflight Mode

**Input:** User provides a brain dump of all requirements at once.

**Process:**
1. Present all 9 categories as a structured form.
2. User fills in all categories in a single response.
3. Parse and categorize all items.
4. Assign IDs and priorities.
5. Present structured output for confirmation.
6. User confirms, output saved.

---

## Acceptance Criteria for This Task

- [ ] At least 1 functional requirement is captured (FR-1 minimum).
- [ ] Each FR has a description >= 10 characters.
- [ ] Priority is assigned to every FR (MUST/SHOULD/COULD/WONT or P0/P1/P2).
- [ ] All 9 elicitation categories are covered (some may be empty if not applicable).
- [ ] Open questions are documented with blocking status.
- [ ] Output document is saved to the project's docs or spec directory.
- [ ] User has confirmed the requirements are complete.
- [ ] The requirement source (prd/user/existing) is recorded.
- [ ] No requirements are invented -- all trace to user input or existing documents.

---

## Notes

- The 9-category elicitation framework is inspired by the GitHub Spec-Kit taxonomy
  and the Spec-Driven Development (SDD) methodology.
- Categories 6-9 (Domain Model, Interactions, Edge Cases, Terminology) were added
  to improve spec quality and reduce implementation ambiguity.
- When eliciting interactively, present numbered options when asking the user to choose.
- Use language the user is comfortable with. Do not force English if the user
  communicates in another language.
- The requirements document is the single source of truth for all downstream phases.
  Every statement in the spec (phase 4) must trace back to an item in this document.
- If the user wants to add requirements after this phase completes, re-run this task
  with `source=existing` to merge new requirements with the existing document.
