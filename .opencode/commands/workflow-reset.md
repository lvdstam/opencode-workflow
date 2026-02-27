---
description: Reset a phase to start fresh (human override)
agent: orchestrator
---

# Override: Reset Phase

Human override to reset a workflow phase.

**Arguments:** $ARGUMENTS

## Argument Parsing

Parse the arguments as space-separated values:
- **First argument**: Feature slug (required)
- **Second argument**: Phase name (optional, e.g., "01-requirements", "02-architecture")

Example usages:
- `/workflow-reset user-auth` - Reset current phase of user-auth workflow
- `/workflow-reset user-auth 02-architecture` - Reset specific phase
- `/workflow-reset user-auth all` - Reset entire workflow

## Input Validation (REQUIRED FIRST STEP)

Before proceeding, validate all inputs:

1. **Check Arguments Provided**
   - Parse `$ARGUMENTS` into feature-slug and optional phase
   - If no arguments provided, STOP with error:
     ```
     Error: No feature slug provided.
     Usage: /workflow-reset <feature-slug> [phase]
     
     Examples:
       /workflow-reset user-auth              # Reset current phase
       /workflow-reset user-auth 02-architecture  # Reset specific phase
       /workflow-reset user-auth all          # Reset entire workflow
     ```

2. **Validate Feature Slug**
   - Must match pattern: `^[a-z0-9][a-z0-9-]*[a-z0-9]$` or single char `^[a-z0-9]$`
   - Must NOT contain: `..`, `/`, `\`, spaces, or null bytes
   - Maximum 50 characters

3. **Validate Phase Name (if provided)**
   - Must be one of: `01-requirements`, `02-architecture`, `03-implementation`, `04-testing`, `05-documentation`, `all`
   - If invalid phase, STOP with error:
     ```
     Error: Invalid phase name.
     Valid phases: 01-requirements, 02-architecture, 03-implementation, 04-testing, 05-documentation, all
     ```

4. **Verify Workflow Exists**
   - Check if `workflow/<slug>/workflow-state.json` exists
   - If not found, STOP with helpful error

## Your Tasks

1. **Load Current State**
   Read `workflow/<slug>/workflow-state.json`

2. **Display Confirmation Prompt**
   Before resetting, show the human:
   ```
   ═══════════════════════════════════════════════════════════════
   CONFIRM RESET
   ═══════════════════════════════════════════════════════════════
   
   Feature:      <slug>
   Phase:        <phase to reset> (or "ALL PHASES" if resetting all)
   Iterations:   <N> completed
   
   This will:
   - Archive existing reviews to reviews/archived-<timestamp>/
   - Reset iteration count to 0
   - Clear current feedback
   - Restart the creator/reviewer cycle
   
   ⚠️  WARNING: This action cannot be undone!
   
   Are you sure you want to reset? (yes/no)
   ```
   
   Wait for explicit confirmation before proceeding. If the user says "no", stop.

3. **Reset Phase State**
   Update `workflow/<slug>/<phase>/status.json`:
   ```json
   {
     "phase": "<phase>",
     "status": "pending",
     "iterations": 0,
     "max_iterations": 4,
     "current_feedback": null,
     "history": ["Reset by human at <timestamp>"]
   }
   ```

4. **Archive Old Reviews**
   Move existing reviews to `reviews/archived-<timestamp>/`

5. **Update Workflow State**
   - Set current_phase to the reset phase
   - Update phase status in phases object
   - Clear any escalation for this phase

6. **Begin Fresh**
   Start the creator/reviewer cycle from scratch

## Phase Argument Behavior

- If phase argument is not provided, reset the current phase (from workflow-state.json)
- If phase argument is "all", reset all phases (start workflow from beginning)
