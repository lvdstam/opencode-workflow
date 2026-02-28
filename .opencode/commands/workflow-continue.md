---
description: Continue an existing workflow from its current state
agent: orchestrator
---

# Continue Existing Workflow

Continue the workflow for feature: **$ARGUMENTS**

## Input Validation (REQUIRED FIRST STEP)

Before proceeding, validate all inputs:

1. **Check Arguments Provided**
   - If `$ARGUMENTS` is empty or contains only whitespace, STOP and inform the user:
     ```
     Error: No feature slug provided.
     Usage: /workflow-continue <feature-slug>
     
     To see available workflows: /workflow-list
     ```

2. **Validate Slug Format**
   - Must match pattern: `^[a-z0-9][a-z0-9-]*[a-z0-9]$` or single char `^[a-z0-9]$`
   - Must NOT contain: `..`, `/`, `\`, spaces, or null bytes
   - Maximum 64 characters
   - If invalid format, STOP with error:
     ```
     Error: Invalid feature slug format.
     Slugs must be lowercase alphanumeric with hyphens only.
     ```

3. **Verify Workflow Exists**
   - Check if `workflow/$ARGUMENTS/workflow-state.json` exists
   - If not found, STOP with error:
     ```
     Error: Workflow '$ARGUMENTS' not found.
     
     To see available workflows: /workflow-list
     To start a new workflow: /workflow-start <description>
     ```

4. **Validate State File**
   - Attempt to read and parse `workflow-state.json`
   - If JSON is malformed, STOP with error:
     ```
     Error: Workflow state file is corrupted.
     The file workflow/$ARGUMENTS/workflow-state.json contains invalid JSON.
     Consider manual inspection or /workflow-reset $ARGUMENTS
     ```

## Your Tasks

1. **Load Workflow State**
   Read `workflow/$ARGUMENTS/workflow-state.json` to understand current state.

2. **Check for Terminal States**

   **If workflow status is `abandoned` or `cancelled`:**
   - STOP and inform the user:
     ```
     Error: Workflow '$ARGUMENTS' has been cancelled.
     
     To restore this workflow:
       1. Edit workflow/$ARGUMENTS/workflow-state.json
       2. Change "status" to "in_progress"
       3. Remove "cancelled_at" and "cancelled_reason" fields
       4. Run /workflow-continue $ARGUMENTS
     
     Or start fresh: /workflow-start <new description>
     ```

   **If workflow status is `completed`:**
   - STOP and inform the user:
     ```
     Workflow '$ARGUMENTS' is already complete. All phases approved.
     
     Next steps:
     - Merge the PR: <pr_url>
     - Then run: /workflow-finalize $ARGUMENTS
     ```

3. **Handle Escalated State**

   **If workflow status is `escalated`:**
   - Ask the human what to do:
     - Override and approve the current artifact
     - Provide specific guidance for the creator
     - Reset iterations and try again
     - Abandon this phase/workflow

4. **Handle In-Progress Internal Review**

   **If current phase status is `in_progress` or `in_review`:**
   The internal creator/reviewer cycle was interrupted. Resume it:
   - If `in_progress` with feedback: invoke creator with that feedback, then reviewer
   - If `in_progress` without feedback: invoke creator, then reviewer
   - If `in_review`: the reviewer was interrupted, re-invoke reviewer
   - After internal approval: commit, push, set to `user_review`, STOP
   - Handle escalation if iterations >= 4

5. **Handle User Review Phase (PRIMARY FLOW)**

   **If current phase status is `user_review`:**
   This is the main continuation path. Read PR feedback from GitHub and decide
   what to do.

   ### Step 5a: Read PR Review State

   Fetch the latest PR state using the GitHub API:

   ```bash
   # Get top-level reviews (APPROVED / CHANGES_REQUESTED / COMMENTED)
   gh api repos/{owner}/{repo}/pulls/<pr_number>/reviews
   ```

   ```bash
   # Get file-level review comments with file paths
   gh api repos/{owner}/{repo}/pulls/<pr_number>/comments
   ```

   Use `pr_number` from `workflow-state.json`. Filter comments by `created_at`
   against `last_reviewed_at` to find new comments since last `/workflow-continue`.

   ### Step 5b: Check for Unresolved Comments

   Map each file-level comment to a phase using its `path` field:
   - `workflow/<slug>/01-requirements/*` → `01-requirements`
   - `workflow/<slug>/02-architecture/*` → `02-architecture`
   - `workflow/<slug>/03-implementation/*` → `03-implementation`
   - `workflow/<slug>/04-testing/*` → `04-testing`
   - `workflow/<slug>/05-documentation/*` → `05-documentation`
   - Source code files (outside `workflow/`) → `03-implementation`

   ### Step 5c: Process Based on Review State

   **Case 1: User submitted "Request changes" or has unresolved PR comments**
   
   Determine the EARLIEST phase that has comments.

   - If the earliest commented phase is the current phase:
     - Set phase status to `in_progress`
     - Set `current_feedback` to the aggregated user comments
     - Run the **full** internal creator/reviewer cycle with user feedback
       (the internal reviewer must approve before returning to user review)
     - **Important**: Instruct the creator to preserve each user comment in the
       artifact with a response explaining how it was addressed. The user will
       review these responses and resolve their own comments on the PR.
     - After internal approval: commit, push, set to `user_review`
     - Update `last_reviewed_at` in workflow-state.json
     - STOP — wait for user to re-review and resolve their comments

   - If the earliest commented phase is EARLIER than the current phase (REGRESSION):
     - Follow the Phase Regression Protocol (see below)

   **Case 2: User submitted "APPROVED" review AND no unresolved comments**
   
   The current phase passes user review:
   - Mark current phase as `approved`, set `completed_at`
   - If more phases remain:
     - Advance `current_phase` to the next phase
     - Run the internal creator/reviewer cycle for the next phase
     - After internal approval: commit, push, set to `user_review`
     - Update `last_reviewed_at`
     - STOP — inform user:
       ```
       Phase <completed> approved. Phase <next> complete (internal review passed).
       
       Review the latest changes on the PR, then:
       - Leave comments on any issues
       - Approve when satisfied
       - Run /workflow-continue <slug>
       ```
   - If ALL phases are now approved:
     - Set workflow status to `completed`
     - Commit and push
     - STOP — inform user:
       ```
       All 5 phases complete and approved!
       
       Next steps:
       1. Merge the PR: <pr_url>
       2. After merge, run: /workflow-finalize <slug>
       ```

   **Case 3: No review submitted (no approval, no comments)**
   
   STOP — remind the user:
   ```
   Waiting for your review on the PR: <pr_url>
   
   Current phase: <phase> (status: user_review)
   
   Please review the changes and either:
   - Submit "Request changes" with file-level comments for issues
   - Submit "Approve" when satisfied
   Then run /workflow-continue <slug>
   ```

   ### Phase Regression Protocol

   When user comments target a phase N earlier than the current phase M:

   1. Set `current_phase` to phase N
   2. Set phase N status to `in_progress` with user comments as `current_feedback`
   3. Set ALL phases after N (N+1 through M) status to `pending`, reset their
      `iterations` to 0, clear `started_at` and `completed_at`
   4. Run the **full** internal creator/reviewer cycle for phase N with user feedback
      (internal reviewer must approve before returning to user review)
   5. After internal approval: commit, push, set to `user_review`
   6. Update `last_reviewed_at`
   7. STOP — inform user:
      ```
      Regressed to phase <N> based on your comments.
      Phases <N+1> through <M> have been reset and will be re-run after
      you approve the reworked phase <N>.
      
      Your original comments have been preserved in the artifact with
      responses explaining how each was addressed. Please review the
      changes, resolve your comments if satisfied, then approve and
      /workflow-continue.
      ```

6. **Handle Already-Approved Phase**

   **If current phase status is `approved`:**
   This can happen if the status was set externally (e.g., `/workflow-approve`).
   Advance to the next phase and run it.

## Context to Provide Agents

When invoking creator agents, always include:
1. Original feature description from `00-feature/description.md`
2. All approved artifacts from previous phases
3. Current feedback (internal reviewer feedback OR user PR comments)

When invoking reviewer agents, always include:
1. The artifact just created
2. Original feature description
3. Approved artifacts from previous phases
4. Current iteration number

## Status Updates

After every action, update:
- `workflow-state.json` - overall status, current_phase, last_reviewed_at
- `<phase>/status.json` - phase-specific status, iterations, current_feedback
- Always push after commits so the PR reflects the latest state
