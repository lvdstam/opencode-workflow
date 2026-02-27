---
description: Approve the current phase and move to the next (human override)
agent: orchestrator
---

# Override: Approve Current Phase

Human override to approve the current phase for: **$ARGUMENTS**

## Your Tasks

1. **Load Current State**
   Read `workflow/$ARGUMENTS/workflow-state.json`

2. **Confirm Current Phase**
   Tell the human which phase will be approved and its current iteration count

3. **Mark Phase Approved**
   - Update `<phase>/status.json` with status: "approved"
   - Update `workflow-state.json` with phase completion

4. **Create Override Record**
   Add to the reviews directory:
   ```markdown
   # Human Override

   **Date:** <timestamp>
   **Action:** Manual approval
   **Phase:** <phase>
   **Iterations at override:** <N>
   **Reason:** Human decision to proceed
   ```

5. **Commit Changes**
   ```bash
   git add .
   git commit -m "[workflow] <phase>: approved (human override)"
   ```

6. **Proceed to Next Phase**
   - Update current_phase in workflow-state.json
   - Begin the next phase's creator/reviewer cycle
   - Or create PR if this was the last phase
