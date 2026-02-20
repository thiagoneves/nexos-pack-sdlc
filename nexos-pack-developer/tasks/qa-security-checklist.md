---
task: qa-security-checklist
agent: qa
workflow: story-development-cycle (security review) or qa-loop (review phase)
inputs: [story file, modified files (from git diff or File List), severity threshold]
outputs: [security scan report, issue list, gate integration block]
---

# Security Checklist

## Purpose

Perform an automated security vulnerability scan of story implementation code using pattern-based detection for common security anti-patterns. This task checks for OWASP Top 10 vulnerability classes including code injection, cross-site scripting, hardcoded secrets, SQL injection, missing input validation, and insecure configuration. It produces a structured report with severity-classified findings, false positive analysis, and fix recommendations.

## Prerequisites

- Story implementation code exists and is readable.
- Files to scan are identifiable from the story's File List, git diff, or explicit file list.
- Story is in `InProgress` or `InReview` status.

## Steps

### 1. Collect Files to Scan

Determine which files to analyze:

- **From story File List:** Extract all source files listed in the story.
- **From git diff:** Run `git diff --name-only` to identify modified files.
- **From explicit list:** Use provided file paths if specified.

Filter files by relevance:
- **Include:** `.js`, `.ts`, `.jsx`, `.tsx`, `.py`, `.mjs`, `.cjs`, `.go`, `.java`, `.rb`, `.php`
- **Exclude by default:** Test files (`*.test.*`, `*.spec.*`, `__tests__/*`), documentation (`.md`), configuration (`.json`, `.yaml` -- unless checking for secrets), generated files, `node_modules/`, `vendor/`.
- **Always scan:** Configuration files if checking for hardcoded secrets (`.env.example`, config files).

If no files match after filtering, halt and inform the user.

### 2. Execute Security Pattern Checks

Run all 8 security checks against the collected files. For each check, search for the specified patterns and evaluate matches in context.

#### Check 1: Code Injection (eval / exec / dynamic code execution)

**Severity:** CRITICAL
**Applies to:** JavaScript, TypeScript, Python

Patterns to detect:
- `eval(` -- Direct eval calls.
- `new Function(` -- Dynamic function construction.
- `setTimeout("string")` or `setInterval("string")` -- String-based timer callbacks.
- `exec(` (Python) -- Dynamic code execution.
- `compile(` (Python) -- Dynamic compilation.

**Risk:** Remote Code Execution (RCE). Attacker-controlled input in eval/exec enables arbitrary code execution.

**Recommended fix:** Use safe alternatives. For data parsing, use `JSON.parse()`. For expression evaluation, use a sandboxed parser library. Avoid dynamic code entirely in production.

#### Check 2: DOM-based XSS (innerHTML / document.write)

**Severity:** CRITICAL
**Applies to:** JavaScript, TypeScript

Patterns to detect:
- `.innerHTML =` -- Direct innerHTML assignment.
- `.outerHTML =` -- Direct outerHTML assignment.
- `document.write(` -- Document write calls.
- `document.writeln(` -- Document writeln calls.

**Risk:** Cross-Site Scripting (XSS). Unsanitized user input rendered as HTML enables script injection.

**Recommended fix:** Use `textContent` for text, `createElement` for DOM construction, or sanitization libraries (DOMPurify) before innerHTML.

#### Check 3: React XSS (dangerouslySetInnerHTML)

**Severity:** CRITICAL
**Applies to:** JavaScript, TypeScript (React/JSX)

Patterns to detect:
- `dangerouslySetInnerHTML` -- React's escape hatch for raw HTML.

**Risk:** XSS in React applications. Bypasses React's built-in XSS protection.

**Recommended fix:** Avoid entirely if possible. If required, sanitize input with DOMPurify before use.

**Exception:** If `DOMPurify.sanitize()` is called on the input within the same component or function, classify as MEDIUM rather than CRITICAL.

#### Check 4: Command Injection (shell execution)

**Severity:** CRITICAL
**Applies to:** Python, JavaScript/TypeScript (child_process)

Patterns to detect:
- `subprocess.*shell=True` (Python) -- Shell execution enabled.
- `os.system(` (Python) -- Direct shell command.
- `os.popen(` (Python) -- Shell command via popen.
- `child_process.exec(` with string argument (JS) -- Shell command execution.
- Template literals with user input in exec/spawn context (JS).

**Risk:** Command Injection. User-controlled input in shell commands enables arbitrary command execution.

**Recommended fix:** Use parameterized execution (`subprocess.run()` with list args and `shell=False` in Python; `child_process.execFile()` or `spawn()` with array args in JS).

#### Check 5: Hardcoded Secrets

**Severity:** CRITICAL
**Applies to:** All languages

Patterns to detect:
- API keys: `api_key = "..."`, `apiKey: "..."` (string values 10+ characters).
- Passwords: `password = "..."`, `passwd = "..."`, `pwd = "..."`.
- Tokens: `token = "..."`, `secret = "..."`, `bearer ...` (20+ character tokens).
- AWS credentials: `AKIA[0-9A-Z]{16}`, `aws_secret_access_key`.
- Private keys: `-----BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----`.
- Connection strings with embedded credentials.

**Risk:** Credential Exposure. Secrets in source code are exposed via version control, logs, and build artifacts.

**Recommended fix:** Use environment variables, secrets manager, or `.env` files (never committed). Reference `process.env.*` or equivalent.

**Exception:** Test files with obviously fake values (e.g., `test-api-key`, `password123` in test fixtures) may be false positives.

#### Check 6: SQL Injection

**Severity:** CRITICAL
**Applies to:** JavaScript, TypeScript, Python

Patterns to detect:
- Template literals in query: `` query(`...${variable}...`) ``
- String concatenation in query: `query("..." + variable + "...")`
- Python format strings in execute: `execute(f"...{variable}...")`, `execute("..." % variable)`

**Risk:** SQL Injection. User input in SQL strings enables arbitrary query execution, data exfiltration, and data manipulation.

**Recommended fix:** Use parameterized queries (prepared statements), ORM query builders, or stored procedures. Never concatenate user input into SQL strings.

#### Check 7: Missing Input Validation

**Severity:** HIGH
**Applies to:** JavaScript, TypeScript (Express/Fastify/Koa patterns)

Patterns to detect:
- `req.body.{property}` without validation middleware or optional chaining.
- `req.query.{property}` without validation.
- `req.params.{property}` without validation.

**Risk:** Input validation bypass, type confusion, prototype pollution. Unvalidated input can cause unexpected behavior, crashes, or security bypasses.

**Recommended fix:** Use validation libraries (Zod, Joi, express-validator) or validation middleware before accessing request properties.

**Exception:** If validation middleware is applied at the route level (e.g., `router.post('/path', validate(schema), handler)`), this is a false positive.

#### Check 8: Insecure CORS Configuration

**Severity:** HIGH
**Applies to:** JavaScript, TypeScript

Patterns to detect:
- `origin: "*"` -- Allow all origins.
- `Access-Control-Allow-Origin: *` -- Wildcard CORS header.
- `cors()` without configuration -- Default CORS (allows all).

**Risk:** Cross-origin attacks. Unrestricted CORS allows any website to make authenticated requests to the API.

**Recommended fix:** Specify allowed origins explicitly. Use a whitelist approach.

### 3. Analyze Context for False Positives

For each pattern match, evaluate whether it is a true vulnerability or a false positive:

**False positive indicators:**
- Match is inside a code comment (single-line `//` or `#`, multi-line `/* */`).
- Match is inside a test file used for testing the vulnerability pattern itself.
- Match is inside documentation or example code.
- Match has sanitization applied nearby (within the same function or block).
- Match is in a configuration file with safe defaults (e.g., development-only CORS).
- Match uses a variable from environment (`process.env`, `os.environ`), not a hardcoded string.

For each potential false positive:
- Record the match.
- Document why it may be a false positive.
- Classify it as `confirmed_vulnerability`, `likely_false_positive`, or `needs_review`.

### 4. Generate Finding Details

For each confirmed or needs-review finding, produce a structured issue:

```yaml
finding:
  id: "SEC-{SEQ}"  # e.g., "SEC-001"
  check: "{CHECK_NAME}"  # e.g., "EVAL_USAGE", "HARDCODED_SECRET"
  severity: "CRITICAL | HIGH | MEDIUM"
  file: "{file-path}"
  line: {line-number}
  column: {column-number}
  code: "{matching code line}"
  context:
    before: ["{2 lines before}"]
    after: ["{2 lines after}"]
  risk: "{Description of the specific risk in this context}"
  fix:
    description: "{What to change}"
    suggestion: "{Example of the corrected code}"
    references: ["{OWASP or documentation links}"]
  false_positive_analysis:
    in_comment: {true|false}
    in_test: {true|false}
    has_sanitization: {true|false}
    classification: "confirmed | likely_false_positive | needs_review"
```

### 5. Classify and Summarize

Produce the scan summary:

```yaml
scan_summary:
  timestamp: "{timestamp}"
  story_id: "{story-id}"
  files_scanned: {count}
  patterns_checked: 8
  findings:
    critical: {count}
    high: {count}
    medium: {count}
    total: {count}
  false_positives_filtered: {count}
  blocking: {true|false}
  recommendation: "{BLOCK | WARN | PASS}"
```

**Blocking determination:**
- Any CRITICAL finding with `confirmed` or `needs_review` classification: BLOCK.
- Any HIGH finding with `confirmed` classification: WARN.
- No CRITICAL or confirmed HIGH findings: PASS.

### 6. Generate Security Report

Produce the report following the output format below.

### 7. Integrate with QA Review

If this task is run as part of `qa-review-story` or `qa-gate`:
- Merge findings into the overall review findings.
- Contribute to Check 6 (Security) of the 7 quality checks.
- CRITICAL security findings should result in Check 6 = FAIL.
- HIGH findings should result in Check 6 = CONCERN.

## Output Format

### Output 1: Security Scan Report

Save to: `{qa-location}/assessments/{story-id}-security-{YYYYMMDD}.md`

```markdown
# Security Scan: Story {story-id}

Date: {date}
Scanner: @qa
Severity Threshold: {threshold}

## Executive Summary

- Files Scanned: {count}
- Security Checks Run: 8
- Vulnerabilities Found: {count}
- Critical: {count}
- High: {count}
- Medium: {count}
- False Positives Filtered: {count}
- **Recommendation: {BLOCK | WARN | PASS}**

## Findings

### SEC-{SEQ}: {Check Name}

**Severity:** {CRITICAL | HIGH | MEDIUM}
**File:** `{file-path}:{line}`
**Risk:** {risk description}

**Code:**
```{language}
{code with context}
```

**Fix:**
{fix description}

```{language}
{suggested fix}
```

**References:**
- {OWASP or documentation link}

---

[Repeat for each finding...]

## Checks Performed

| Check | Pattern | Files | Findings | Status |
|-------|---------|-------|----------|--------|
| 1. Code Injection | eval/exec/Function | {count} | {count} | {PASS/FAIL} |
| 2. DOM XSS | innerHTML/write | {count} | {count} | {PASS/FAIL} |
| 3. React XSS | dangerouslySetInnerHTML | {count} | {count} | {PASS/FAIL} |
| 4. Command Injection | shell/system/exec | {count} | {count} | {PASS/FAIL} |
| 5. Hardcoded Secrets | keys/passwords/tokens | {count} | {count} | {PASS/FAIL} |
| 6. SQL Injection | concatenation in queries | {count} | {count} | {PASS/FAIL} |
| 7. Input Validation | req.body/query/params | {count} | {count} | {PASS/FAIL} |
| 8. CORS Config | wildcard origins | {count} | {count} | {PASS/FAIL} |

## False Positives Excluded

| Finding | File | Reason |
|---------|------|--------|
| {pattern match} | {file} | {reason for exclusion} |

## Scan Coverage

- Source files analyzed: {count}
- Lines of code analyzed: {count}
- File types: {list}
- Files excluded: {count} (tests, docs, generated)
```

### Output 2: Gate YAML Block

Generate for inclusion in quality gate under security check:

```yaml
security_scan:
  timestamp: "{timestamp}"
  checks_run: 8
  findings:
    critical: {count}
    high: {count}
    medium: {count}
  blocking: {true|false}
  recommendation: "{BLOCK | WARN | PASS}"
  report: "{qa-location}/assessments/{story-id}-security-{YYYYMMDD}.md"
```

### Output 3: JSON Report (Machine-Readable)

Optionally save to: `{qa-location}/assessments/{story-id}-security-{YYYYMMDD}.json`

```json
{
  "timestamp": "{timestamp}",
  "story_id": "{story-id}",
  "summary": {
    "critical": 0,
    "high": 0,
    "medium": 0,
    "total": 0,
    "blocking": false
  },
  "issues": [],
  "scan_coverage": {
    "files_scanned": 0,
    "patterns_checked": 8,
    "lines_analyzed": 0
  },
  "recommendation": "PASS"
}
```

## Severity Mapping

| Check | Default Severity | Blocking |
|-------|-----------------|----------|
| eval() / exec() | CRITICAL | Yes |
| innerHTML / XSS | CRITICAL | Yes |
| dangerouslySetInnerHTML | CRITICAL | Yes |
| shell=True / os.system | CRITICAL | Yes |
| Hardcoded Secrets | CRITICAL | Yes |
| SQL Injection | CRITICAL | Yes |
| Missing Input Validation | HIGH | Recommended |
| Insecure CORS | HIGH | Recommended |

## Suppression Mechanism

Developers can suppress specific findings by adding a comment on the line before or on the same line:

```javascript
// security-ignore: SEC-001 -- sanitized via DOMPurify before assignment
```

```python
# security-ignore: SEC-004 -- shell=False enforced by wrapper function
```

Suppressed findings:
- Are excluded from the blocking determination.
- Are included in the report under "Suppressed Findings" for audit.
- Require a reason after the `--` to be valid. Suppressions without reasons are treated as active findings.

## Error Handling

- **No files to scan:** Halt and inform the user. Check that the story has a File List or that there are uncommitted changes.
- **File not readable:** Skip the file, log a warning, continue with remaining files. Note the skipped file in the report.
- **Pattern produces too many matches (>50 for one check):** Summarize the first 10 matches in detail, then provide a count for the remainder. Suggest a broader code review for that pattern.
- **Cannot determine language for a file:** Skip language-specific checks, run only universal checks (hardcoded secrets). Note in the report.
- **Git not available:** Scan only explicitly provided files or files from the story File List. Note that diff-based file selection was not available.
- **Security suppression comment found:** Respect `security-ignore: SEC-{ID}` comments. Exclude the suppressed finding from the blocking count but include it in the report as "suppressed."
- **All findings are false positives:** Report PASS with a note that all detected patterns were analyzed and determined to be safe. Include the false positive analysis for audit purposes.

## Examples

### Example: Scan Finding for Hardcoded API Key

```markdown
### SEC-001: Hardcoded Secret

**Severity:** CRITICAL
**File:** `src/config/api.ts:12`
**Risk:** API key exposed in source code. Any user with repository access
can extract the key. If committed, the key is in version history permanently.

**Code:**
```typescript
// Line 11: // API configuration
// Line 12: const API_KEY = 'sk-live-abc123def456ghi789';
// Line 13: const BASE_URL = 'https://api.service.com';
```

**Fix:**
Use environment variable instead of hardcoded value.

```typescript
const API_KEY = process.env.API_KEY;
if (!API_KEY) {
  throw new Error('API_KEY environment variable is required');
}
```

**References:**
- https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/
```

## Acceptance Criteria

- [ ] All 8 security checks are executed against the relevant files.
- [ ] Each finding includes: ID, severity, file, line, code, risk description, and fix recommendation.
- [ ] False positive analysis is performed for every match.
- [ ] CRITICAL findings are classified as blocking.
- [ ] Scan summary includes file count, pattern count, and findings by severity.
- [ ] Security report is saved to the correct location.
- [ ] Gate YAML block is generated with correct counts.
- [ ] Suppressed findings are handled correctly (excluded from blocking, included in report).
- [ ] Files are filtered appropriately (test files excluded from most checks, secrets check applied broadly).
- [ ] Recommendation (BLOCK/WARN/PASS) accurately reflects the findings.

## Notes

- This task is a pattern-based scan, not a comprehensive penetration test. It catches common anti-patterns but does not replace a full security review for critical applications.
- The 8 checks cover the most common vulnerability patterns in web applications. For specialized applications (mobile, IoT, embedded), additional checks may be needed.
- This task can be run standalone or as part of `qa-review-story` and `qa-gate`. When integrated, it provides the data for Check 6 (Security).
- False positive analysis is essential. A scan that reports 50 false positives erodes trust. Take time to evaluate context before reporting.
- Security findings should be treated seriously regardless of the story's business criticality. A low-priority feature with a SQL injection is still a critical security issue.
- When in doubt about whether a match is a vulnerability, classify it as `needs_review` rather than dismissing it. A false positive is less costly than a missed vulnerability.
- The suppression mechanism exists for informed acceptance of risk, not for silencing the scanner. Each suppression should have a clear justification.
- Keep the security patterns updated as new vulnerability classes emerge. The 8 checks are a baseline, not an exhaustive list.
