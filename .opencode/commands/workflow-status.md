---
description: Show the current status of a feature workflow
agent: plan
subtask: true
---

# Workflow Status

Display the current status of the workflow for: **$ARGUMENTS**

## Input Validation (REQUIRED FIRST STEP)

Before proceeding, validate all inputs:

1. **Check Arguments Provided**
   - If `$ARGUMENTS` is empty or contains only whitespace, STOP and inform the user:
     ```
     Error: No feature slug provided.
     Usage: /workflow-status <feature-slug>
     
     To see all workflows: /workflow-list
     ```

2. **Validate Slug Format**
   - Must match pattern: `^[a-z0-9][a-z0-9-]*[a-z0-9]$` or single char `^[a-z0-9]$`
   - Must NOT contain: `..`, `/`, `\`, spaces, or null bytes
   - Maximum 50 characters
   - If invalid format, STOP with error message

3. **Verify Workflow Exists**
   - Check if `workflow/$ARGUMENTS/workflow-state.json` exists
   - If not found, STOP with error:
     ```
     Error: Workflow '$ARGUMENTS' not found.
     
     Available workflows:
     [List any existing workflows or "No workflows found"]
     
     To start a new workflow: /workflow-start <description>
     ```

4. **Validate State File**
   - If JSON is malformed, display warning but attempt partial display:
     ```
     Warning: Workflow state file may be corrupted.
     Displaying available information...
     ```

## Tasks

1. **Load Workflow State**
   Read `workflow/$ARGUMENTS/workflow-state.json`

2. **Display Summary**
   Show:
   - Feature name and title
   - Branch name
   - Overall status
   - Current phase
   - Created/updated timestamps

3. **Phase Details**
   For each phase, show:
   - Status (pending/in_progress/in_review/approved/escalated)
   - Iteration count
   - Started/completed timestamps
   - Latest review decision (if any)

4. **Recent Activity**
   Show the last 3 review files and their decisions

5. **Escalations**
   If any escalations exist, summarize them

6. **Next Steps**
   Based on current state, recommend:
   - If in_progress: Continue with `/workflow-continue $ARGUMENTS`
   - If escalated: Describe what needs human decision
   - If completed: Show PR URL or suggest PR creation

## Output Format

```
═══════════════════════════════════════════════════════════════
WORKFLOW STATUS: <feature-title>
═══════════════════════════════════════════════════════════════

Feature:    <slug>
Branch:     <branch>
Status:     <status>
Created:    <date>
Updated:    <date>

PHASES
───────────────────────────────────────────────────────────────
[✓] 01-requirements    │ approved    │ 2 iterations │ <date>
[→] 02-architecture    │ in_review   │ 1 iteration  │ <date>
[ ] 03-implementation  │ pending     │ -            │ -
[ ] 04-testing         │ pending     │ -            │ -
[ ] 05-documentation   │ pending     │ -            │ -

CURRENT PHASE: 02-architecture
───────────────────────────────────────────────────────────────
Status: in_review
Iterations: 1 of 4 max
Last review: NEEDS_REVISION (review-1.md)

RECENT REVIEWS
───────────────────────────────────────────────────────────────
• 02-architecture/reviews/review-1.md: NEEDS_REVISION
• 01-requirements/reviews/review-2.md: APPROVED
• 01-requirements/reviews/review-1.md: NEEDS_REVISION

NEXT STEPS
───────────────────────────────────────────────────────────────
Run: /workflow-continue <slug>
```
