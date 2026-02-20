---
task: create-suite
agent: dev
workflow: component-creation
inputs:
  - name (required, string - lowercase, kebab-case)
  - options (optional, object - configuration for suite type)
  - force (optional, boolean, default: false - overwrite existing)
outputs:
  - created_file (string, file system path)
  - validation_report (object)
  - success (boolean)
---

# Create Component Suite

## Purpose
Create multiple related components in a single batch operation with dependency resolution and transaction support. Supports creating agent packages, workflow suites, task collections, and custom component groupings while ensuring correct creation order and manifest consistency.

## Prerequisites
- Template system is configured
- team-manifest.yaml exists
- Target does not already exist (unless --force is used)
- Required inputs provided
- File system permissions granted

## Steps

### 1. Suite Type Selection
Choose from predefined suite types or custom:
- Agent package
- Workflow suite
- Task collection
- Custom

**Validation:** Ensure suite type is supported.

### 2. Configure Components
Gather configuration for each component in the suite:
- Component names and types
- Component-specific options
- Relationships between components

**Validation:** Validate naming conventions (lowercase, kebab-case) and dependencies.

### 3. Analyze Dependencies
Build dependency graph between components:
- Map which components depend on which
- Determine creation order

**Validation:** Check for circular dependencies. If found, report and halt.

### 4. Preview Suite
Display a preview of all components to be created:
- File paths and locations
- Component configurations
- Dependency order
- Estimated changes

**Validation:** User confirmation required before proceeding.

### 5. Create Components
Create components in dependency order (atomic operation):
- Process each component according to its template
- Validate each component immediately after creation
- If any creation fails, offer rollback of the entire transaction

**Transaction support:** All-or-nothing creation. Transaction log enables rollback.

### 6. Update Manifest
Update team-manifest.yaml with all new components:
- Add component entries
- Update relationships
- Record creation metadata

**Validation:** Manifest must remain valid YAML after update.

## Output
Upon completion, provide:
- Success/failure status for each component
- Transaction ID for potential rollback
- Updated manifest with all new components
- Summary of created files and locations

## Security Considerations
- All generated code is validated for security
- File paths are sanitized to prevent traversal
- Transaction log is write-protected

## Error Handling
- **Resource Already Exists:** Use force flag or choose different name; prompt user for alternative name or force overwrite
- **Invalid Input:** Input name contains invalid characters or format; validate against naming rules (kebab-case, lowercase, no special chars); sanitize input or reject with clear error message
- **Permission Denied:** Check file system permissions; suggest permission fix
- **Missing Dependencies:** Prompt to create or select existing components
- **Name Conflicts:** Show existing components and suggest alternatives
- **Creation Failures:** Offer rollback of entire transaction
- **Manifest Errors:** Show diff and allow manual correction
- **Circular Dependencies:** Report the cycle and halt creation

## Notes
- Supports atomic creation (all or nothing)
- Transaction log enables rollback functionality
- Dependency resolution ensures correct creation order
- Preview functionality helps prevent mistakes
