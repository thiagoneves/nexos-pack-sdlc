---
task: generate-ui-prompt
agent: ux-designer
inputs:
  - ui_spec (required, string, path to UI/UX specification document)
  - architecture_doc (optional, string, path to frontend or full-stack architecture document)
  - system_architecture (optional, string, path to system architecture for API contracts context)
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - prompt_text (string, the complete AI frontend prompt)
  - created_file (string, path to the saved prompt file)
---

# Generate AI Frontend Prompt

## Purpose
Generate a comprehensive, optimized prompt that can be used with any AI-driven frontend development tool (e.g., Vercel v0, Lovable.ai, or similar) to scaffold or generate significant portions of a frontend application. Synthesizes UI/UX specs, architecture docs, and design requirements into a structured, copy-pasteable prompt.

## Prerequisites
- Completed UI/UX specification document (front-end-spec.md or equivalent)
- Frontend architecture document or full-stack architecture document (recommended)
- System architecture document for API contracts and tech stack context (optional)

## Steps

### 1. Understand Core Prompting Principles

Apply these principles when generating the prompt:

- **Be Explicit and Detailed:** Provide as much detail and context as possible. Vague requests lead to generic or incorrect outputs.
- **Iterate, Do Not Expect Perfection:** Frame the prompt for generating one component or section at a time, building upon results.
- **Provide Context First:** Start with tech stack, existing code snippets, and overall project goals.
- **Mobile-First Approach:** Describe the mobile layout first, then provide separate instructions for tablet and desktop adaptation.

### 2. Apply the Structured Prompting Framework

Every generated prompt must follow this four-part framework:

**Part 1: High-Level Goal**
- Clear, concise summary of the overall objective
- Example: "Create a responsive user registration form with client-side validation and API integration."

**Part 2: Detailed, Step-by-Step Instructions**
- Granular, numbered list of actions
- Break complex tasks into smaller sequential steps
- Example: "1. Create RegistrationForm component. 2. Use React hooks for state. 3. Add styled inputs for Name, Email, Password..."

**Part 3: Code Examples, Data Structures, and Constraints**
- Include relevant existing code snippets
- Provide API contracts and data structures
- State what NOT to do explicitly
- Specify styling framework (e.g., "Use Tailwind CSS for all styling")

**Part 4: Define a Strict Scope**
- Explicitly define which files to create or modify
- Specify which files to leave untouched
- Prevent unintended changes across the codebase

### 3. Assemble the Master Prompt

**Gather Foundational Context:**
- Read the UI/UX spec for component requirements, user flows, and design system
- Read the architecture doc for tech stack, component structure, and state management
- Read the system architecture for API endpoints and data models

**Describe the Visuals:**
- If design files exist (Figma, etc.), include links or reference screenshots
- If not, describe: color palette, typography, spacing, overall aesthetic

**Build the Prompt:**
- Apply the four-part framework
- Include all gathered context
- Organize by component or page section

### 4. Present and Refine

- Output the complete prompt in a clear, copy-pasteable format (code block)
- Explain the structure and why certain information was included
- Remind the user that all AI-generated code requires careful human review, testing, and refinement for production readiness

### 5. Review and Iterate

- Gather user feedback on the prompt
- Refine sections that are too broad or too narrow
- Adjust tech stack specifics or design requirements as needed
- Produce the final version

## Error Handling
- **UI spec not found:** Exit with clear error, list available spec files
- **Architecture doc not found:** Proceed with available information, note gaps in the prompt
- **Missing tech stack information:** Ask user to specify the tech stack manually
- **Prompt too long for target tool:** Split into multiple smaller prompts, organized by component or page
- **Conflicting information between docs:** Flag discrepancies, ask user to resolve before generating
