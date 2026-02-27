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

## File Locations

- **Workflow root:** `workflow/<feature-slug>/`
- **Feature description:** `workflow/<feature>/00-feature/description.md`
- **Workflow state:** `workflow/<feature>/workflow-state.json`
- **Phase status:** `workflow/<feature>/<phase>/status.json`
- **Reviews:** `workflow/<feature>/<phase>/reviews/review-<N>.md`

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
      "status": "approved",
      "iterations": 2,
      "started_at": "2026-02-27T10:00:00Z",
      "completed_at": "2026-02-27T10:30:00Z",
      "escalation_reason": null
    },
    "02-architecture": {
      "status": "in_progress",
      "iterations": 0,
      "started_at": "2026-02-27T10:30:00Z",
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
  "escalations": [
    {
      "phase": "01-requirements",
      "iteration": 4,
      "timestamp": "2026-02-27T11:00:00Z",
      "reason": "Creator and reviewer could not agree on scope",
      "resolution": "Human approved with modifications"
    }
  ],
  "pr_url": null
}
```

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
- `escalated` - Waiting for human intervention
- `abandoned` - Workflow cancelled

### Phase Status
- `pending` - Not yet started
- `in_progress` - Creator working on artifact
- `in_review` - Reviewer evaluating artifact
- `approved` - Passed review, complete
- `escalated` - Hit max iterations, needs human

## State Transitions

```
pending → in_progress (when phase starts)
in_progress → in_review (when creator completes artifact)
in_review → in_progress (when reviewer requests revision)
in_review → approved (when reviewer approves)
in_review → escalated (when iterations >= max_iterations)
escalated → in_progress (when human provides guidance)
escalated → approved (when human overrides)
```

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

### After Reviewer Approves
```json
{
  "status": "approved",
  "completed_at": "<timestamp>",
  "current_feedback": null
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
- `status` (string, one of: in_progress, completed, escalated, abandoned)
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
