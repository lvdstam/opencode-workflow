---
description: Reset a phase to start fresh (human override)
agent: orchestrator
---

# Override: Reset Phase

Human override to reset a phase for: **$1** (feature slug)

Phase to reset: **$2** (phase name like "01-requirements")

## Your Tasks

1. **Load Current State**
   Read `workflow/$1/workflow-state.json`

2. **Confirm Reset**
   Tell the human:
   - Which phase will be reset
   - Current iteration count
   - What will be preserved vs deleted

3. **Reset Phase State**
   Update `workflow/$1/$2/status.json`:
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

## Options

If $2 is not provided, reset the current phase.
If $2 is "all", reset all phases (start workflow over).
