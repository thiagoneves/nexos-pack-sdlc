---
task: qa-review-proposal
agent: qa
workflow: collaborative-modification (review)
inputs:
  - proposal-id (required, string)
  - action (optional: approve, reject, request-changes, comment)
  - comment (optional, text)
  - conditions (optional, text for conditional approval)
  - suggestions (optional, file path with suggested changes)
  - priority (optional: low, medium, high, critical)
  - assignees (optional, comma-separated user list)
  - fast-review (optional, boolean - skip detailed analysis)
outputs:
  - review record (file: .aios/proposals/reviews/{reviewId}.json)
  - updated proposal status
  - notifications to relevant parties
---

# Review Proposal

## Purpose
Review and provide feedback on modification proposals submitted through the collaborative modification system. Performs code quality analysis, impact assessment, conflict detection, test coverage evaluation, and security scanning before rendering a review decision.

## Prerequisites
- Proposal exists and is accessible at `.aios/proposals/{proposal-id}.json`
- Proposal index exists at `.aios/proposals/index.json`
- Reviewer has appropriate permissions
- Reviewer is not the proposal creator (in production)

## Steps

### 1. Parse and Validate Parameters
Parse the command input to extract proposal ID and options.

**Valid actions:** approve, reject, request-changes, comment

**Command pattern:**
```
*review-proposal <proposal-id> [options]
```

**Options:**
- `--action <action>`: Review action
- `--comment <text>`: Review comment or feedback
- `--conditions <text>`: Conditions for approval
- `--suggestions <file>`: File containing suggested changes
- `--priority <level>`: Update proposal priority
- `--assignees <users>`: Add/change assignees
- `--fast-review`: Skip detailed analysis

### 2. Load Proposal
Load the proposal JSON file from `.aios/proposals/{proposal-id}.json`.

Display proposal summary including: ID, title, component path, modification type, priority, status, creator, creation date, assignees, tags, and description.

For specific modification types, display additional context:
- **Deprecation:** Target removal date
- **Enhancement:** New capabilities
- **Refactor:** Breaking changes indicator

### 3. Analyze Proposal (unless fast-review)
Perform detailed analysis across five dimensions:

**Code Quality Analysis:**
- Complexity calculation (functions, methods, conditionals, loops)
- Maintainability assessment (comments, JSDoc, error handling, modular structure)
- Documentation check (JSDoc, markdown headers, param/returns/example annotations)
- Code style review (tabs vs spaces, line length, strict mode)

**Impact Analysis:**
- Affected components count
- Risk level assessment

**Conflict Detection:**
- Check for other pending proposals on the same component
- Identify approved proposals that may conflict

**Test Coverage Analysis:**
- Check if component has unit tests
- Check if component has integration tests
- Recommend adding tests if absent

**Security Scan:**
- Check for eval() and dynamic code execution
- Check for innerHTML XSS vectors
- Check for external process execution
- Check for file system operations in enhancements

### 4. Get Review Details
If action was not provided via command options, interactively prompt for:
1. Review action (approve, reject, request-changes, comment)
2. Review comment (using editor for detailed feedback)
3. Conditions for approval (if approving)
4. Priority update (if desired)
5. Additional reviewers (if requesting changes)

Load suggestions from file if `--suggestions` was provided.

### 5. Process Review
Create review record with:
- Unique review ID
- Proposal reference
- Action and resulting status
- Reviewer identity and timestamp
- Comment, conditions, and suggestions
- Metadata (review duration, whether analysis was performed)

Store review at `.aios/proposals/reviews/{reviewId}.json`.

### 6. Update Proposal Status
Update proposal status based on review action:
- **approve** -> status: `approved`
- **reject** -> status: `rejected`
- **request-changes** -> status: `changes_requested`
- **comment** -> no status change

Update priority and assignees if changed. Increment metadata version. Save updated proposal and update index.

### 7. Notify Relevant Parties
Send notifications:
- Notify proposal creator of review outcome
- If requesting changes, notify all assignees with the review comment
- Log notification count

## Status Transitions
```
Draft -> Pending Review (on submission)
Pending Review -> Approved / Rejected / Changes Requested
Changes Requested -> Pending Review (on update)
Approved -> In Progress (on implementation start)
In Progress -> Completed (on implementation finish)
```

## Validation Rules
- Proposal must exist and be accessible
- Review action must be valid (approve, reject, request-changes, comment)
- Reviewer must have appropriate permissions
- Cannot review own proposals (in production)
- Cannot approve high-risk changes without conditions
- All reviews must include comments
- Rejections must include reasons
- Change requests should include specific feedback

## Recommendations Generation
Based on analysis results, automatically generate recommendations:
- High complexity: "Consider refactoring to reduce code complexity"
- Poor documentation: "Add comprehensive documentation and JSDoc comments"
- Poor maintainability: "Improve code maintainability with better structure and error handling"
- No tests: "Add unit tests before approving this modification"
- Security issues: "Address security concerns before approval"
- Conflicts detected: "Resolve conflicts with other pending proposals"

## Next Steps by Action
- **Approve:** Proposal ready for implementation; assignees notified; ensure conditions met if any
- **Reject:** Proposal rejected; creator should address feedback before resubmission
- **Request Changes:** Changes requested; creator should address feedback and resubmit
- **Comment:** Comment added; no status change, review still pending

## Error Handling
- **Proposal not found:** Throw error with proposal ID for identification
- **Invalid action:** Throw error listing valid actions
- **Dependency initialization failure:** Throw error with details about which dependency failed
- **Notification failure:** Log warning but do not block the review process
- **Index update failure:** Log warning but review is still saved
- **Suggestions file not found:** Log warning and continue without suggestions
