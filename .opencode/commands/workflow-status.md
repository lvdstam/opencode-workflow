---
description: Show the current status of a feature workflow
agent: plan
subtask: true
---

# Workflow Status

Display the current status of the workflow for: **$ARGUMENTS**

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
