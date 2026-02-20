---
task: create-doc
agent: pm
inputs:
  - name (required, string, document name in kebab-case)
  - template (optional, string, path to YAML template or template name)
  - options (optional, object, template-specific options)
  - force (optional, boolean, default: false, overwrite existing file)
  - mode (optional, yolo|interactive|pre-flight, default: interactive)
outputs:
  - created_file (string, path to the created document)
  - validation_report (object, template validation results)
---

# Create Document from Template

## Purpose
Create a new document from a YAML-driven template using an interactive, section-by-section workflow. Each template section is processed with user feedback, ensuring high-quality, collaborative document creation with elicitation at key decision points.

## Prerequisites
- YAML template available (either provided or discoverable in project templates directory)
- Target file path does not already exist (unless `force` is true)
- Write permissions to the target directory

## Steps

### 1. Template Discovery
If no template is provided, list all available templates from the project templates directory. Present them to the user for selection.

If a template name is provided, resolve it to the full path.

### 2. Parse YAML Template
Load the template metadata and sections. Each section may include:
- Section heading and instructions
- Whether elicitation is required (`elicit: true`)
- Agent permissions (owner, editors, readonly)
- Skip conditions

### 3. Set Preferences
- Confirm execution mode (Interactive is default)
- Confirm output file path
- Show template overview (section count, estimated time)

### 4. Process Each Section Sequentially

For each template section:

1. **Check skip conditions** - Skip if conditions are not met
2. **Check agent permissions** - Note if the section is restricted to specific agent roles
3. **Draft content** using the section instructions
4. **Present content with detailed rationale** explaining:
   - Trade-offs and choices made
   - Key assumptions
   - Decisions that may need user attention
   - Areas that might need validation

5. **If `elicit: true`** (mandatory interaction):
   - Present numbered options 1-9:
     - Option 1: "Proceed to next section"
     - Options 2-9: Elicitation methods (brainstorm, challenge assumptions, explore alternatives, etc.)
   - End with: "Select 1-9 or just type your question/feedback:"
   - Wait for user response before proceeding
   - If user selects an elicitation method (2-9), execute it, present results, then offer:
     1. Apply changes and update section
     2. Return to elicitation menu
     3. Ask questions or engage further

6. **Save progress** incrementally when possible

### 5. YOLO Mode Toggle
User can type `#yolo` at any point to switch to YOLO mode, which processes all remaining sections at once without elicitation stops.

### 6. Final Validation
After all sections are processed:
- Verify document structure completeness
- Check for missing required sections
- Validate cross-references
- Save the final document

## Error Handling
- **Resource already exists:** Prompt user for alternative name or use `--force` to overwrite
- **Invalid input format:** Validate against naming rules (kebab-case, lowercase, no special characters), suggest corrections
- **Permission denied:** Check file system permissions, suggest fix
- **Template not found:** List available templates, ask user to select or provide path
- **Incomplete section:** Save partial progress, allow resumption
