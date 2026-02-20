---
task: qa-browser-console-check
agent: qa
workflow: story-development-cycle (qa-gate, phase 4.2)
inputs:
  - story_id (required, string)
  - pages (optional, array - auto-detected from changes if omitted)
  - dev_server_url (optional, string, default: http://localhost:3000)
outputs:
  - console_report (file: docs/stories/{story-id}/qa/console_errors.json)
  - has_errors (boolean)
  - blocking (boolean)
---

# Browser Console Check

## Purpose
Automated browser console error detection for frontend changes. Visits pages affected by code changes, captures console errors, warnings, uncaught exceptions, unhandled rejections, and failed network requests, then generates a report with severity classification and a blocking recommendation.

## Prerequisites
- Project has frontend/UI components
- Dev server can be started (npm run dev, yarn dev, or pnpm dev)
- Playwright is available for automated browser interaction

## Steps

### 1. Detect Pages to Test
Determine which pages to visit based on modified files:

**Next.js:**
- `app/**/page.tsx` maps to `/{path}`
- `pages/**/*.tsx` maps to `/{path}`

**React Router:**
- Extract routes from Route components

**Manual:**
- Use `--pages` parameter if provided

### 2. Start Dev Server
Start the development server and wait for readiness:

```bash
npm run dev  # or yarn dev / pnpm dev
```

Wait for one of: "ready", "compiled", or HTTP 200 on root URL. Timeout: 60 seconds.

### 3. Visit Each Page
For each detected page:
1. Navigate to page URL
2. Wait for page load (networkidle)
3. Collect console messages (errors and warnings)
4. Capture unhandled promise rejections
5. Record failed network requests
6. Take screenshot (optional)

### 4. Analyze Results
Categorize captured messages:
- Group by severity
- Deduplicate similar errors
- Identify root causes

Filter noise (known non-actionable messages):

**Third-party noise:**
- "Download the React DevTools"
- Google Analytics, Facebook Pixel messages
- HMR / Fast Refresh messages

**Dev-only messages:**
- "Warning: ReactDOM.render is no longer supported"
- "Compiled successfully"
- webpack-dev-server messages

**Known browser issues:**
- "ResizeObserver loop" (browser bug, not actionable)
- "Third-party cookie will be blocked" (browser privacy feature)

### 5. Generate Report
Create JSON report and markdown summary:

```json
{
  "timestamp": "...",
  "story_id": "...",
  "dev_server_url": "...",
  "summary": {
    "pages_checked": 5,
    "total_errors": 2,
    "total_warnings": 3,
    "failed_requests": 1,
    "blocking": true
  },
  "pages": [
    {
      "url": "/dashboard",
      "status": "loaded",
      "load_time_ms": 1250,
      "errors": [...],
      "warnings": [...],
      "failed_requests": [...],
      "screenshot": "screenshots/dashboard.png"
    }
  ],
  "recommendation": "..."
}
```

## Console Check Categories

| Category | Severity | Patterns | Action |
|---|---|---|---|
| Errors | CRITICAL | Uncaught Error, TypeError, ReferenceError, SyntaxError, ChunkLoadError, Failed to fetch, NetworkError | Block approval |
| Warnings | HIGH | Warning:, Deprecation, Invalid prop, unique key prop, Cannot update a component | Report, recommend fix |
| Failed Requests | HIGH | 4xx (except 404 for optional resources), 5xx | Report, investigate |
| Missing Resources | MEDIUM | 404 Not Found, Failed to load resource, net::ERR_ | Report |
| Performance | LOW | Violation, Long task, Layout shift | Note for optimization |

## Playwright Integration

```typescript
import { test, expect } from '@playwright/test';

test.describe('Console Error Check', () => {
  const pages = process.env.PAGES?.split(',') || ['/'];

  for (const pagePath of pages) {
    test(`No console errors on ${pagePath}`, async ({ page }) => {
      const errors: string[] = [];

      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });

      page.on('pageerror', err => {
        errors.push(err.message);
      });

      await page.goto(pagePath);
      await page.waitForLoadState('networkidle');

      expect(errors).toHaveLength(0);
    });
  }
});
```

## Command
```
*console-check {story-id} [--pages /path1,/path2] [--url http://localhost:3000]
```

## Integration with QA Review
**Trigger:** During `*review-build` Phase 4.2 (Browser Verification), conditional on UI files being modified.

**Decision rules:**
- Any console.error (non-ignored): CRITICAL -> Block
- Failed 5xx requests: HIGH -> Strong recommend fix
- React warnings: HIGH -> Recommend fix
- Performance violations: LOW -> Note only

## Error Handling
- **Dev server fails to start:** Report as blocking issue; suggest checking build errors first
- **Page navigation timeout:** Log timeout for specific page, continue with remaining pages
- **Playwright not available:** Skip automated check, recommend manual browser verification
- **No pages detected:** Check root URL only as fallback
- **Server port conflict:** Try alternative ports or prompt for correct URL
