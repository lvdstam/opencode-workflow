---
description: Continue an existing workflow from its current state
agent: orchestrator
---

# Continue Existing Workflow

Continue the workflow for feature: **$ARGUMENTS**

## Your Tasks

1. **Load Workflow State**
   Read `workflow/$ARGUMENTS/workflow-state.json` to understand current state.

2. **Determine Current Phase and Status**
   - Which phase is current?
   - What is the phase status? (in_progress, in_review, escalated)
   - How many iterations have occurred?
   - Is there pending feedback?

3. **Resume Appropriately**

   **If status is `in_progress`:**
   - Invoke the creator agent for the current phase
   - Then invoke the reviewer

   **If status is `in_review`:**
   - There should be feedback in the status file
   - Invoke the creator with that feedback
   - Then invoke the reviewer

   **If status is `escalated`:**
   - Ask the human what to do:
     - Override and approve the current artifact
     - Provide specific guidance for the creator
     - Reset iterations and try again
     - Abandon this phase/workflow

   **If status is `approved`:**
   - Move to the next phase
   - If all phases approved, create PR

4. **Handle Human Override**
   If the human provides direction that contradicts normal flow:
   - Follow human instructions
   - Document the override in workflow-state.json
   - Continue from the new state

5. **Complete Workflow**
   When all phases are approved:
   - Ensure all changes are committed
   - Push to remote: `git push -u origin <branch>`
   - Create PR: `gh pr create --title "<title>" --body "<body>"`
   - Update pr_url in workflow-state.json
   - Inform the human

## Context to Provide Agents

When invoking creator agents, always include:
1. Original feature description from `00-feature/description.md`
2. All approved artifacts from previous phases
3. Current reviewer feedback (if any)

When invoking reviewer agents, always include:
1. The artifact just created
2. Original feature description
3. Approved artifacts from previous phases
4. Current iteration number

## Status Updates

After every action, update:
- `workflow-state.json` - overall status and current_phase
- `<phase>/status.json` - phase-specific status and iterations
