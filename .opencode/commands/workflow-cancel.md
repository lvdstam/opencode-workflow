---
description: Cancel and abandon a feature workflow
agent: orchestrator
---

# Cancel Workflow

Cancel and abandon the workflow for: **$ARGUMENTS**

## Input Validation (REQUIRED FIRST STEP)

Before proceeding, validate all inputs:

1. **Check Arguments Provided**
   - If `$ARGUMENTS` is empty, STOP with error:
     ```
     Error: No feature slug provided.
     Usage: /workflow-cancel <feature-slug>
     ```

2. **Validate Slug Format**
   - Must match pattern: `^[a-z0-9][a-z0-9-]*[a-z0-9]$` or single char `^[a-z0-9]$`
   - Must NOT contain: `..`, `/`, `\`, spaces, or null bytes
   - Maximum 50 characters

3. **Verify Workflow Exists**
   - Check if `workflow/$ARGUMENTS/workflow-state.json` exists
   - If not found, STOP with error:
     ```
     Error: Workflow '$ARGUMENTS' not found.
     
     To see available workflows: /workflow-list
     ```

## Your Tasks

1. **Load Current State**
   Read `workflow/$ARGUMENTS/workflow-state.json`

2. **Display Confirmation Prompt**
   Before cancelling, show the human:
   ```
   ═══════════════════════════════════════════════════════════════
   CONFIRM CANCELLATION
   ═══════════════════════════════════════════════════════════════
   
   Feature:       <slug>
   Branch:        <branch>
   Current Phase: <phase>
   Iterations:    <N> total across all phases
   
   This will:
   - Mark the workflow as "abandoned"
   - Keep all artifacts for reference
   - NOT delete the feature branch
   - NOT delete any files
   
   ⚠️  WARNING: This workflow will be marked as cancelled and will 
                not appear in active workflow lists.
   
   To restore a cancelled workflow, manually edit workflow-state.json
   and set status back to "in_progress".
   
   Are you sure you want to cancel this workflow? (yes/no)
   ```
   
   Wait for explicit "yes" confirmation before proceeding. If the user says anything else, stop.

3. **Update Workflow State**
   Update `workflow/$ARGUMENTS/workflow-state.json`:
   ```json
   {
     "status": "abandoned",
     "cancelled_at": "<ISO8601 timestamp>",
     "cancelled_reason": "User requested cancellation"
   }
   ```

4. **Update Current Phase Status**
   Update the current phase's `status.json`:
   ```json
   {
     "status": "cancelled",
     "history": [...existing, "Cancelled by user at <timestamp>"]
   }
   ```

5. **Create Cancellation Record**
   Create `workflow/$ARGUMENTS/cancellation.md`:
   ```markdown
   # Workflow Cancelled
   
   **Date:** <ISO8601 timestamp>
   **Phase at cancellation:** <phase>
   **Iterations completed:** <total across all phases>
   
   ## Progress Summary
   
   | Phase | Status | Iterations |
   |-------|--------|------------|
   | 01-requirements | <status> | <N> |
   | 02-architecture | <status> | <N> |
   | 03-implementation | <status> | <N> |
   | 04-testing | <status> | <N> |
   | 05-documentation | <status> | <N> |
   
   ## Artifacts Preserved
   
   All workflow artifacts remain in `workflow/<slug>/` for reference.
   
   ## Restoring This Workflow
   
   To resume this workflow:
   1. Edit `workflow/<slug>/workflow-state.json`
   2. Set `status` to `"in_progress"`
   3. Remove `cancelled_at` and `cancelled_reason`
   4. Run `/workflow-continue <slug>`
   ```

6. **Inform the Human**
   ```
   Workflow '<slug>' has been cancelled.
   
   All artifacts have been preserved in workflow/<slug>/
   The feature branch '<branch>' still exists.
   
   To restore: manually edit workflow-state.json and set status to "in_progress"
   ```

## Notes

- This command does NOT delete any files or branches
- The workflow can be restored by manually editing the state file
- Cancelled workflows do not appear in `/workflow-list` by default
- Use this when a feature is no longer needed or needs to start completely fresh
