---
description: Finalize a completed workflow — publish docs to central docs/ and clean up workspace
agent: orchestrator
---

# Finalize Feature Workflow

Finalize the workflow for the given feature slug, publishing updated documentation
to the central `docs/` directory and removing the temporary workspace.

**Feature Slug:**
$ARGUMENTS

## Input Validation (REQUIRED FIRST STEP)

1. **Check Arguments Provided**
   - If `$ARGUMENTS` is empty or contains only whitespace, STOP and inform the user:
     ```
     Error: No feature slug provided.
     Usage: /workflow-finalize <feature-slug>
     Example: /workflow-finalize user-authentication
     ```

2. **Slug Validation**
   - Only lowercase alphanumeric characters and hyphens allowed
   - No path traversal characters (`..`, `/`, `\`, null bytes)
   - Maximum 64 characters
   - Pattern: `^[a-z0-9][a-z0-9-]{0,62}[a-z0-9]$` (or single char `^[a-z0-9]$`)

3. **Workflow Exists**
   - Check that `workflow/<slug>/workflow-state.json` exists
   - If not, STOP:
     ```
     Error: Workflow '<slug>' not found.
     Use /workflow-list to see available workflows.
     ```

## Pre-Finalization Checks (REQUIRED)

Before finalizing, verify the workflow is ready:

1. **All Phases Approved**
   Read `workflow/<slug>/workflow-state.json` and verify that ALL five phases have
   `"status": "approved"`:
   - `01-requirements`
   - `02-architecture`
   - `03-implementation`
   - `04-testing`
   - `05-documentation`

   If any phase is not approved, STOP:
   ```
   Error: Cannot finalize — not all phases are approved.

   Phase Status:
     01-requirements:  approved
     02-architecture:  approved
     03-implementation: approved
     04-testing:       in_progress  <-- NOT APPROVED
     05-documentation: pending      <-- NOT APPROVED

   Complete the workflow first with /workflow-continue <slug>
   ```

2. **Workflow Status is "completed"**
   The overall workflow `status` must be `completed` (meaning all phases done and PR created).
   If status is anything else, STOP with an appropriate message.

3. **PR Exists**
   Verify `pr_url` is set in `workflow-state.json`.
   If not, STOP:
   ```
   Error: Cannot finalize — no PR has been created yet.
   The workflow must be completed (all phases approved + PR created) before finalizing.
   Use /workflow-continue <slug> to finish the workflow.
   ```

4. **Confirm with User**
   Display what will happen and ask for confirmation:
   ```
   Ready to finalize workflow '<slug>'.

   This will:
   1. Copy updated docs from workspace to central docs/:
      - features.md
      - requirements.md
      - architecture.md
      - diagrams/*
      - user-docs.md → user-guide.md
      - api-docs.md → api-reference.md
   2. Delete the entire workflow/<slug>/ directory
   3. Commit and push the changes
   4. The PR will then contain only source code, tests, and updated docs/

   Proceed? [y/n]
   ```

   Wait for user confirmation. If declined, STOP.

## Finalization Steps

### Step 1: Publish Documentation to Central Docs

Create `docs/` directory if it doesn't exist, then copy workspace docs:

| Source (workspace)                                    | Destination (central)      |
|-------------------------------------------------------|----------------------------|
| `workflow/<slug>/00-feature/features.md`              | `docs/features.md`         |
| `workflow/<slug>/01-requirements/requirements.md`     | `docs/requirements.md`     |
| `workflow/<slug>/02-architecture/architecture.md`     | `docs/architecture.md`     |
| `workflow/<slug>/02-architecture/diagrams/*`          | `docs/diagrams/`           |
| `workflow/<slug>/05-documentation/user-docs.md`       | `docs/user-guide.md`       |
| `workflow/<slug>/05-documentation/api-docs.md`        | `docs/api-reference.md`    |

**Important notes:**
- Only copy files that exist in the workspace (some may not have been created)
- For `docs/diagrams/`, create the directory if it doesn't exist
- These copies **overwrite** the central docs (the workspace version is the latest)

### Step 2: Delete Workflow Workspace

Remove the entire `workflow/<slug>/` directory:
```bash
rm -rf workflow/<slug>/
```

This deletes all process artifacts:
- `workflow-state.json`
- All `status.json` files
- All `reviews/` directories
- Implementation `plan.md` and `changes.md`
- Test `test-plan.md` and `coverage-report.md`
- Feature `description.md`

These artifacts only had value during development and review. The meaningful
outputs (docs, source code, tests) survive in the project tree.

### Step 3: Commit and Push

```bash
git add docs/ workflow/
git commit -m "[workflow] finalize: Publish docs and clean up <slug> workspace"
git push
```

### Step 4: Update State (Final)

Since the `workflow-state.json` has been deleted with the workspace, there is no
state file to update. The workflow is fully finalized.

Inform the user:
```
Workflow '<slug>' finalized successfully.

Published to docs/:
  - docs/features.md
  - docs/requirements.md
  - docs/architecture.md
  - docs/diagrams/
  - docs/user-guide.md
  - docs/api-reference.md

Workspace workflow/<slug>/ has been removed.
The PR now contains only source code, tests, and updated central docs.
```

## Error Handling

### Partial Copy Failure
If a file copy fails mid-way:
1. Do NOT delete the workspace
2. Report which files were copied successfully and which failed
3. Let the user fix the issue and retry

### Git Errors
If the commit or push fails:
1. The docs have been copied but workspace not yet deleted
2. Report the git error
3. Suggest manual resolution
4. Do NOT delete the workspace until commit succeeds

### Workspace Already Deleted
If `workflow/<slug>/` doesn't exist but was expected:
1. Check if `docs/` has recent changes (maybe finalize was partially done)
2. Inform the user of the situation
3. Suggest checking git log for recent finalization commits
