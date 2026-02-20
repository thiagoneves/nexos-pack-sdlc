---
task: create-service
agent: dev
workflow: scaffolding
inputs:
  - service_name (string, required) - kebab-case name, pattern ^[a-z][a-z0-9-]*$
  - service_type (enum, required) - "api-integration" | "utility" | "agent-tool", default "utility"
  - has_auth (boolean, optional) - Whether service requires authentication, default false
  - description (string, required) - Non-empty, max 200 characters
  - env_vars (array, optional) - Environment variable names, default []
outputs:
  - service_directory (directory) - Generated service at infrastructure/services/{service_name}/
  - files_created (array) - List of generated files
---

# Create Service

## Purpose
Create a new service using standardized Handlebars templates. Generates consistent TypeScript service structures with proper configuration, testing, and documentation.

## Prerequisites
- Service templates exist at the templates directory (service-template/)
- Service name is unique (no existing service with same name)
- Service name follows kebab-case pattern: `^[a-z][a-z0-9-]*$`

## Steps

### 1. Elicit Service Configuration
Gather the following from the user interactively:

1. **Service Name** - kebab-case identifier (e.g., "github-api", "file-processor")
   - Validate: `^[a-z][a-z0-9-]*$`
   - Check: must be unique (directory must not already exist)

2. **Service Type** - one of:
   - `api-integration` - External API client with rate limiting and auth
   - `utility` - Internal helper/utility service
   - `agent-tool` - Tool for agents

3. **Authentication Required** - yes/no (default: no)
   - If yes: include auth configuration and secure headers

4. **Description** - Brief description (max 200 chars, appears in README and JSDoc)

5. **Environment Variables** - Comma-separated list or "none"
   - Examples: API_KEY, BASE_URL, TIMEOUT_MS
   - Generates .env.example entries

### 2. Validate Inputs
```javascript
// Validate service_name
const namePattern = /^[a-z][a-z0-9-]*$/;
if (!namePattern.test(serviceName)) {
  throw new Error(`Invalid service name: ${serviceName}. Use kebab-case.`);
}

// Check uniqueness
const targetDir = `infrastructure/services/${serviceName}/`;
if (fs.existsSync(targetDir)) {
  throw new Error(`Service '${serviceName}' already exists.`);
}
```

### 3. Load Templates
Load the following template files:
- `README.md.hbs`
- `index.ts.hbs`
- `types.ts.hbs`
- `errors.ts.hbs`
- `package.json.hbs`
- `tsconfig.json` (static)
- `jest.config.js` (static)
- `__tests__/index.test.ts.hbs`
- `client.ts.hbs` (only for api-integration type)

### 4. Prepare Template Context
```javascript
const context = {
  serviceName: serviceName,              // kebab-case
  pascalCase: toPascalCase(serviceName), // PascalCase
  camelCase: toCamelCase(serviceName),   // camelCase
  description: description,
  isApiIntegration: serviceType === 'api-integration',
  hasAuth: hasAuth,
  envVars: envVars.map(v => ({
    name: v,
    description: `${v} environment variable`
  })),
  createdAt: new Date().toISOString().split('T')[0]
};
```

### 5. Generate Files
1. Create target directory and `__tests__/` subdirectory
2. For each template file:
   - If `.hbs` extension: compile with Handlebars and write rendered output
   - If static: copy file directly
3. Use atomic generation - rollback on failure (delete target directory if partially created)

### 6. Post-Generation Verification
```bash
cd infrastructure/services/{service_name}/
npm install
npm run build
npm test
```

## Handlebars Helpers Required
- `pascalCase` - Convert kebab-case to PascalCase
- `camelCase` - Convert kebab-case to camelCase
- `kebabCase` - Convert PascalCase/camelCase to kebab-case
- `upperCase` - Convert to UPPER_SNAKE_CASE

## Error Handling
- **Service name exists:** Prompt for a different name.
- **Template not found:** Error - templates must be installed first.
- **npm install fails:** Warning, continue without dependencies.
- **Build fails:** Warning, show TypeScript errors, continue.
- **Invalid name format:** Re-prompt with validation error.
- **Partial generation failure:** Rollback by deleting target directory.

## Acceptance Criteria
- All template files generated successfully in the target directory
- TypeScript compiles without errors
- Tests pass
- Service directory contains: README.md, index.ts, types.ts, errors.ts, package.json, tsconfig.json, jest.config.js, __tests__/index.test.ts
- If api-integration: client.ts is also generated
