---
task: execute-checklist
agent: qa
workflow: validation
inputs:
  - checklist (string, optional) - Name or path of checklist to execute
  - mode (string, optional) - Execution mode: "yolo" | "interactive" | "pre-flight", default "interactive"
  - parameters (object, optional) - Additional task parameters
outputs:
  - execution_result (object) - Checklist validation results with pass/fail per item
  - logs (array) - Execution logs
---

# Checklist Validation

## Purpose
Validate documentation and artifacts against structured checklists. Provides systematic, thorough validation with configurable execution modes for different levels of interactivity.

## Prerequisites
- Checklists are available in the checklists directory
- Required documents/artifacts referenced by the checklist are accessible
- Task parameters are valid if provided

## Steps

### 1. Initial Assessment
1. If user provides a checklist name:
   - Try fuzzy matching (e.g., "architecture checklist" matches "architect-checklist")
   - If multiple matches found, ask user to clarify
   - Load the appropriate checklist from the checklists directory
2. If no checklist specified:
   - Present available checklist options from the checklists folder
   - Ask the user to select one
3. Confirm execution mode:
   - **Interactive** (section by section, time consuming but thorough)
   - **YOLO** (all at once, recommended for checklists, summary at end)

### 2. Document and Artifact Gathering
1. Read the checklist header to identify required documents/artifacts
2. Follow the checklist's specific instructions for what to gather
3. Generally resolve files from the docs folder
4. If a required file cannot be found or is unclear, halt and ask the user for clarification

### 3. Checklist Processing

**Interactive mode:**
- Work through each section one at a time
- For each section:
  - Review all items following embedded instructions
  - Check each item against relevant documentation/artifacts
  - Present summary highlighting warnings, errors, and N/A items with rationale
  - Get user confirmation before proceeding to next section
  - Determine if any major finding requires corrective action before continuing

**YOLO mode:**
- Process all sections at once
- Create a comprehensive report of all findings
- Present the complete analysis to the user

### 4. Validate Each Checklist Item
For each item:
1. Read and understand the requirement
2. Look for evidence in the documentation (explicit mentions and implicit coverage)
3. Follow all embedded LLM instructions in the checklist
4. Mark items as:
   - **PASS** - Requirement clearly met
   - **FAIL** - Requirement not met or insufficient coverage
   - **PARTIAL** - Some aspects covered but needs improvement
   - **N/A** - Not applicable (with justification)

### 5. Section Analysis
For each section:
1. Calculate pass rate (think step by step)
2. Identify common themes in failed items
3. Provide specific recommendations for improvement
4. In interactive mode, discuss findings with user
5. Document any user decisions or explanations

### 6. Final Report
Prepare a summary that includes:
- Overall checklist completion status
- Pass rates by section
- List of failed items with context
- Specific recommendations for improvement
- Any sections or items marked as N/A with justification

## Execution Modes

| Mode | Prompts | Best For |
|------|---------|----------|
| YOLO | 0-1 | Simple, deterministic tasks |
| Interactive | 5-10 | Learning, complex decisions |
| Pre-Flight | 10-15 | Ambiguous requirements, critical work |

## Error Handling
- **Checklist not found:** List available checklists, suggest similar names.
- **Invalid parameters:** Validate against task definition, provide parameter template.
- **Execution timeout:** Optimize task or increase timeout; kill, cleanup, log state.
- **Required document missing:** Halt and ask user for file location or alternative.

## Acceptance Criteria
- All checklist sections processed
- Every item has a clear PASS/FAIL/PARTIAL/N/A verdict
- Final report generated with pass rates and recommendations
- Side effects documented
