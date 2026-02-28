---
name: workflow-state
description: Manages workflow state files and phase transitions for gated development
license: MIT
compatibility: opencode
metadata:
  audience: agents
  workflow: development
---

# Workflow State Management

This skill provides instructions for managing the gated development workflow state.

## State Management Responsibilities

**Orchestrator Agent**: Responsible for ALL state file updates
- Creates initial workflow-state.json and status.json files
- Updates state after each creator/reviewer cycle
- Manages phase transitions
- Handles escalation state

**Creator/Reviewer Agents**: Read-only access to state
- May read state files to understand context
- Must NOT modify state files
- Report their output to orchestrator who updates state

## File Locations

- **Workflow root:** `workflow/<feature-slug>/`
- **Feature description:** `workflow/<feature>/00-feature/description.md`
- **Feature log:** `workflow/<feature>/00-feature/features.md` (seeded from `docs/features.md`)
- **Workflow state:** `workflow/<feature>/workflow-state.json` (PRIMARY source of truth)
- **Phase status:** `workflow/<feature>/<phase>/status.json` (per-phase detail)
- **Reviews:** `workflow/<feature>/<phase>/reviews/review-<N>.md`

### Source of Truth Hierarchy

1. **`workflow-state.json`** is the PRIMARY source of truth for:
   - Overall workflow status (`in_progress`, `completed`, `escalated`, etc.)
   - Current phase being worked on
   - High-level phase status summaries
   - Escalation history and PR URL

2. **`<phase>/status.json`** provides DETAILED per-phase information:
   - Iteration count and history
   - Current reviewer feedback
   - Detailed action history

When reconciling conflicts, `workflow-state.json` takes precedence. The orchestrator 
should keep both files in sync, but if they diverge, trust `workflow-state.json`.

## Workflow State Schema (`workflow-state.json`)

```json
{
  "feature": "feature-slug",
  "feature_title": "Human Readable Title",
  "branch": "feature/feature-slug",
  "created_at": "2026-02-27T10:00:00Z",
  "updated_at": "2026-02-27T10:30:00Z",
  "current_phase": "01-requirements",
  "status": "in_progress",
  "phases": {
    "01-requirements": {
      "status": "user_review",
      "iterations": 2,
      "started_at": "2026-02-27T10:00:00Z",
      "completed_at": null,
      "escalation_reason": null
    },
    "02-architecture": {
      "status": "pending",
      "iterations": 0,
      "started_at": null,
      "completed_at": null,
      "escalation_reason": null
    },
    "03-implementation": {
      "status": "pending",
      "iterations": 0,
      "started_at": null,
      "completed_at": null,
      "escalation_reason": null
    },
    "04-testing": {
      "status": "pending",
      "iterations": 0,
      "started_at": null,
      "completed_at": null,
      "escalation_reason": null
    },
    "05-documentation": {
      "status": "pending",
      "iterations": 0,
      "started_at": null,
      "completed_at": null,
      "escalation_reason": null
    }
  },
  "escalations": [],
  "pr_url": null,
  "pr_number": null,
  "last_reviewed_at": null
}
```

Note the new fields compared to earlier versions:
- `pr_number` — needed for GitHub API calls to read review comments
- `last_reviewed_at` — timestamp of last processed PR review, used to filter new comments

## Phase Status Schema (`status.json`)

```json
{
  "phase": "01-requirements",
  "status": "in_progress",
  "iterations": 2,
  "max_iterations": 4,
  "current_feedback": "Reviewer feedback from last iteration...",
  "history": [
    {
      "iteration": 1,
      "action": "created",
      "timestamp": "2026-02-27T10:00:00Z",
      "result": "NEEDS_REVISION"
    },
    {
      "iteration": 2,
      "action": "revised",
      "timestamp": "2026-02-27T10:15:00Z",
      "result": "APPROVED"
    }
  ]
}
```

## Status Values

### Workflow Status
- `in_progress` - Actively being worked on
- `completed` - All phases done, PR created
- `finalized` - Docs published to `docs/`, workspace deleted (terminal state)
- `escalated` - Waiting for human intervention
- `abandoned` - Workflow cancelled (legacy, use `cancelled`)
- `cancelled` - Workflow explicitly cancelled by user

### Phase Status
- `pending` - Not yet started
- `in_progress` - Creator working on artifact
- `in_review` - Internal reviewer evaluating artifact
- `user_review` - Internal review passed, waiting for human review on GitHub PR
- `approved` - Passed both internal and user review, complete
- `escalated` - Hit max iterations, needs human

## State Transitions

```
pending → in_progress (when phase starts)
in_progress → in_review (when creator completes artifact)
in_review → in_progress (when reviewer requests revision)
in_review → user_review (when internal reviewer approves — pushed to PR)
in_review → escalated (when iterations >= max_iterations, i.e., after 4th iteration)
user_review → approved (when human approves on GitHub with no unresolved comments)
user_review → in_progress (when human leaves PR comments requesting changes)
approved → in_progress (phase regression: human commented on earlier phase's files)
escalated → in_progress (when human provides guidance)
escalated → approved (when human overrides)
```

### Workflow-Level Transitions

```
in_progress → completed (all 5 phases approved, PR created)
completed → finalized (docs published to docs/, workspace deleted via /workflow-finalize)
in_progress → escalated (phase hits max iterations)
escalated → in_progress (human provides guidance)
in_progress → cancelled (user runs /workflow-cancel)
```

Note: `finalized` is a terminal state. The `workflow-state.json` file is deleted
during finalization, so this status only exists briefly before the file is removed.
The finalized state is recorded in the git commit history.

## Documentation Mapping

The workflow uses a **copy-edit-publish** pattern for documentation files:

### Seeding (workflow-start)

Central docs are copied into the workspace as starting points:

| Central (source)         | Workspace (destination)                              |
|--------------------------|------------------------------------------------------|
| `docs/features.md`      | `workflow/<slug>/00-feature/features.md`              |
| `docs/requirements.md`  | `workflow/<slug>/01-requirements/requirements.md`    |
| `docs/architecture.md`  | `workflow/<slug>/02-architecture/architecture.md`    |
| `docs/diagrams/*`       | `workflow/<slug>/02-architecture/diagrams/`           |
| `docs/user-guide.md`    | `workflow/<slug>/05-documentation/user-docs.md`      |
| `docs/api-reference.md` | `workflow/<slug>/05-documentation/api-docs.md`       |

If `docs/` doesn't exist (first workflow), creators start from their templates.

### Finalization (workflow-finalize)

Updated workspace docs are published back to central:

| Workspace (source)                                    | Central (destination)      |
|-------------------------------------------------------|----------------------------|
| `workflow/<slug>/00-feature/features.md`              | `docs/features.md`         |
| `workflow/<slug>/01-requirements/requirements.md`     | `docs/requirements.md`     |
| `workflow/<slug>/02-architecture/architecture.md`     | `docs/architecture.md`     |
| `workflow/<slug>/02-architecture/diagrams/*`          | `docs/diagrams/`           |
| `workflow/<slug>/05-documentation/user-docs.md`       | `docs/user-guide.md`       |
| `workflow/<slug>/05-documentation/api-docs.md`        | `docs/api-reference.md`    |

After publishing, the entire `workflow/<slug>/` directory is deleted.

## Update Patterns

### Starting a Phase
```json
{
  "status": "in_progress",
  "iterations": 0,
  "started_at": "<timestamp>",
  "current_feedback": null
}
```

### After Creator Produces Artifact
```json
{
  "status": "in_review",
  "iterations": 1
}
```

### After Reviewer Requests Revision
```json
{
  "status": "in_progress",
  "iterations": 2,
  "current_feedback": "<feedback from reviewer>"
}
```

### After Internal Reviewer Approves
```json
{
  "status": "user_review",
  "current_feedback": null
}
```

### After User Approves on GitHub
```json
{
  "status": "approved",
  "completed_at": "<timestamp>",
  "current_feedback": null
}
```

### After User Requests Changes (PR comments)
```json
{
  "status": "in_progress",
  "current_feedback": "<aggregated user comments from PR>"
}
```

### Phase Regression (user commented on earlier phase)
When user comments on files belonging to phase N while current phase is M (M > N):
```json
// Phase N:
{
  "status": "in_progress",
  "current_feedback": "<user comments from PR>"
}

// Phases N+1 through M: reset to pending
{
  "status": "pending",
  "iterations": 0,
  "started_at": null,
  "completed_at": null
}

// workflow-state.json:
{
  "current_phase": "<phase N>"
}
```

### On Escalation
```json
{
  "status": "escalated",
  "escalation_reason": "<why escalated>"
}
```

## Phase Order

Phases must be completed in order:
1. `01-requirements`
2. `02-architecture`
3. `03-implementation`
4. `04-testing`
5. `05-documentation`

Never skip phases. Never run phases in parallel.

## Commit Messages

Use this format for commits:
- `[workflow] <phase>: <brief summary>`
- Example: `[workflow] 01-requirements: Define user auth requirements`
- Example: `[workflow] 03-implementation: Add authentication endpoints`

## When to Update State

Always update state files:
1. When starting a new phase
2. After each creator/reviewer iteration
3. When escalating to human
4. When human provides override
5. When workflow completes

## State File Error Handling

### Reading State Files

When reading `workflow-state.json` or `status.json`:
1. First verify the file exists
2. Attempt to parse as JSON
3. If parsing fails, the file is corrupted - do NOT proceed
4. Validate required fields are present

### Corrupted State Recovery

If state file is corrupted or invalid:

**For `workflow-state.json`:**
1. Check if `00-feature/description.md` exists (proves valid workflow)
2. Scan phase directories for `status.json` files
3. Reconstruct workflow state from phase statuses
4. Check git log for commit history:
   ```
   git log --oneline --grep="\[workflow\]"
   ```
5. Present reconstructed state to human for confirmation

**For `status.json`:**
1. Check for review files in `reviews/` directory
2. Count reviews to determine iteration count
3. Check last review for approval status
4. Reconstruct status from available evidence

### State Validation Rules

A valid `workflow-state.json` must have:
- `feature` (string, non-empty)
- `current_phase` (string, valid phase name)
- `status` (string, one of: in_progress, completed, finalized, escalated, abandoned, cancelled)
- `phases` (object with all 5 phases)

A valid `status.json` must have:
- `phase` (string, matches directory name)
- `status` (string, valid status value)
- `iterations` (number, 0-4)
- `max_iterations` (number, typically 4)

### Atomic State Updates

To prevent partial writes:
1. Read existing state file
2. Create updated state in memory
3. Validate new state before writing
4. Write complete new state (not partial updates)
5. Verify write succeeded by re-reading

### Race Condition Prevention

If multiple operations could modify state:
1. Read state at start of operation
2. Perform operation
3. Re-read state before writing
4. If state changed during operation, reconcile or abort
5. Write reconciled state
