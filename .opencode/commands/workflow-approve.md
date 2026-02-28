---
description: Approve the current phase and move to the next (human override)
agent: orchestrator
---

# Override: Approve Current Phase

Human override to approve the current phase for: **$ARGUMENTS**

## Input Validation (REQUIRED FIRST STEP)

Before proceeding, validate all inputs:

1. **Check Arguments Provided**
   - If `$ARGUMENTS` is empty, STOP with error:
     ```
     Error: No feature slug provided.
     Usage: /workflow-approve <feature-slug>
     ```

2. **Validate Slug Format**
   - Must match pattern: `^[a-z0-9][a-z0-9-]*[a-z0-9]$` or single char `^[a-z0-9]$`
   - Must NOT contain: `..`, `/`, `\`, spaces, or null bytes
   - Maximum 50 characters

3. **Verify Workflow Exists**
   - Check if `workflow/$ARGUMENTS/workflow-state.json` exists
   - If not found, STOP with helpful error

4. **Verify Phase Can Be Approved**
   - Check current phase status is not already "approved"
   - If already approved, inform user:
     ```
     Current phase is already approved. 
     Use /workflow-continue $ARGUMENTS to proceed.
     ```
   - This command works when phase status is:
     - `user_review` — skips waiting for GitHub PR review
     - `in_review` — skips remaining internal review
     - `in_progress` — skips current iteration
     - `escalated` — overrides escalation

## Your Tasks

1. **Load Current State**
   Read `workflow/$ARGUMENTS/workflow-state.json`

2. **Display Confirmation Prompt**
   Before approving, show the human:
   ```
   ═══════════════════════════════════════════════════════════════
   CONFIRM APPROVAL
   ═══════════════════════════════════════════════════════════════
   
   Feature:    <slug>
   Phase:      <current phase>
   Iterations: <N> of 4
   Status:     <current status>
   
   This will:
   - Mark the phase as APPROVED
   - Create an override record
   - Commit changes to git
   - Proceed to the next phase
   
   Are you sure you want to approve this phase? (yes/no)
   ```
   
   Wait for explicit confirmation before proceeding. If the user says "no", stop.

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
   - If more phases remain:
     - Begin the next phase's internal creator/reviewer cycle
     - After internal approval: commit, push, set to `user_review`
     - STOP — wait for user review on PR
   - If this was the last phase:
     - Set workflow status to `completed`
     - Inform user to merge PR and run `/workflow-finalize`
