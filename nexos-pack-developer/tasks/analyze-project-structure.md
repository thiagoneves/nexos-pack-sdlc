---
task: analyze-project-structure
agent: architect
inputs:
  - feature_description (required, string, description of the feature to add)
  - project_path (optional, string, project directory path, default: current working directory)
  - mode (optional, string, yolo|interactive|comprehensive, default: interactive)
outputs:
  - project_analysis (markdown, saved to docs/architecture/project-analysis.md)
  - recommended_approach (markdown, saved to docs/architecture/recommended-approach.md)
  - service_inventory (array, list of detected services and their metadata)
---

# Analyze Project Structure

## Purpose
Analyze an existing project to understand its structure, services, patterns, and provide recommendations for implementing new features. This is a read-only analysis phase that scans the codebase, identifies existing patterns, and generates recommendations for how to add new functionality in a way that is consistent with the project's established conventions.

## Prerequisites
- Project directory is accessible and readable
- Project has an identifiable structure (configuration directory, package manifest, etc.)

## Steps

### 1. Gather Requirements

Present prompts to the user:
1. "What feature/service needs to be added?" (required text input)
2. "Does this feature require external API integration?" (Yes / No / Unsure)
3. "Will this feature need database changes?" (Yes / No / Unsure)

Store responses for recommendation generation.

### 2. Project Structure Scan

Scan the following locations:
- Configuration directory (project config, agent definitions, task definitions)
- Services directory (infrastructure/services/)
- Data directory
- Project root (package.json, tsconfig.json, etc.)

For each location, identify:
- Whether the directory exists
- Files and subdirectories present
- Key configuration files

**Service Inventory:**
For each service found:
1. Service name (directory name)
2. Language (TypeScript vs JavaScript - check for `.ts` files)
3. Has tests (check for `__tests__/` or `*.test.*` files)
4. Has README (check for `README.md`)
5. Entry point (`index.ts` or `index.js`)

### 3. Pattern Analysis

#### 3.1 Language Usage
- Count TypeScript vs JavaScript files
- Calculate the ratio to determine primary language

#### 3.2 Testing Approach
- Detect testing framework (Jest, Vitest, Mocha, etc.)
- Check for test files (`.test.ts`, `.spec.ts`)
- Assess test coverage configuration

#### 3.3 Documentation Style
- Count README files across the project
- Check for JSDoc annotations
- Detect documentation generators (TypeDoc, etc.)

#### 3.4 Configuration Patterns
- Check for environment variable usage (`.env.example`, `.env.local`)
- Identify configuration file formats (YAML, JSON, JS)
- Detect environment variable prefixes in code

### 4. Generate Recommendations

**Service Type Recommendation:**

| User Response | Recommendation |
|---------------|----------------|
| External API = Yes | API Integration Service |
| External API = No, DB = Yes | Utility Service |
| Unsure | Utility Service (default) |

**File Structure Suggestion** based on existing service patterns:

```
infrastructure/services/{service-name}/
  README.md
  index.ts
  client.ts        (if API integration)
  types.ts
  errors.ts
  __tests__/
    index.test.ts
  package.json
  tsconfig.json
```

**Agent Assignment:**

| Service Type | Primary Agent | Support Agent |
|--------------|---------------|---------------|
| API Integration | dev | qa |
| Utility Service | dev | architect |
| Database-heavy | data-engineer | dev |

### 5. Generate Output Documents

**Project Analysis Document** (`docs/architecture/project-analysis.md`):
- Project structure overview (framework, primary language, service count, testing framework)
- Existing services table (name, type, language, tests, README)
- Language distribution statistics
- Testing and configuration pattern summary

**Recommended Approach Document** (`docs/architecture/recommended-approach.md`):
- Feature requirements summary
- Service type recommendation with rationale
- Suggested file structure
- Implementation steps
- Agent assignment
- Dependencies list
- Next steps

### 6. Present Results

Display a summary:
```
=== Project Analysis Complete ===

Project: {projectName}
Services Found: {serviceCount}
Primary Language: {primaryLanguage}
Testing: {testFramework}

=== Recommendation ===

Feature: {feature_name}
Service Type: {serviceType}
Primary Agent: @{primaryAgent}

Documents Generated:
  1. docs/architecture/project-analysis.md
  2. docs/architecture/recommended-approach.md

Next Steps:
  1. Review the recommended approach
  2. Scaffold the new service
  3. Begin implementation
```

## Error Handling
- **Project directory not found:** Exit with clear error suggesting to check the path
- **No services found:** Proceed with minimal analysis, note "No existing services" in output
- **Permission denied on directories:** Skip inaccessible areas, note in analysis, continue with accessible files
- **No project manifest found:** Warn that some analysis may be incomplete, proceed with available data
- **Analysis timeout (large projects):** Return partial results with a note about incomplete areas
