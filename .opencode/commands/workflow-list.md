---
description: List all feature workflows and their status
agent: plan
subtask: true
---

# List All Workflows

Display all feature workflows and their current status.

## Tasks

1. **Scan Workflow Directory**
   Look for all directories under `workflow/` that contain `workflow-state.json`

2. **Load Each Workflow State**
   For each workflow found, read its state file

3. **Display Summary Table**

## Output Format

```
═══════════════════════════════════════════════════════════════
WORKFLOWS
═══════════════════════════════════════════════════════════════

Feature                  │ Status      │ Phase            │ Iterations │ Updated
─────────────────────────┼─────────────┼──────────────────┼────────────┼──────────
user-auth-flow           │ in_progress │ 03-implementation│ 1/4        │ 2 hours ago
payment-integration      │ escalated   │ 02-architecture  │ 4/4        │ 1 day ago
dashboard-redesign       │ completed   │ PR #123          │ -          │ 3 days ago

Total: 3 workflows
  In Progress: 1
  Escalated: 1
  Completed: 1
```

If no workflows exist:
```
No workflows found. Start one with:
  /workflow-start <feature description>
```
