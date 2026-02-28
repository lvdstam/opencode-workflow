---
description: Start a new feature workflow with gated development phases
agent: orchestrator
---

# Start New Feature Workflow

Initialize a new gated development workflow for the following feature:

**Feature Description:**
$ARGUMENTS

## Tool Configuration Check (REQUIRED FIRST STEP)

Before starting the workflow, verify that project tools are configured:

1. **Check for `.tools/bin/` directory**
   - If missing, STOP and inform user:
     ```
     Error: .tools/bin/ directory not found.
     
     This workflow system requires tool wrapper scripts to be configured.
     
     To initialize:
       /workflow-init
     
     Or manually create .tools/bin/ with these scripts:
       test.sh, build.sh, lint.sh, format.sh, 
       coverage.sh, install.sh, typecheck.sh, dev.sh
     
     See .tools/README.md for configuration examples.
     ```

2. **Check each script for configuration status**
   For each script in `.tools/bin/`:
   - Read the script content
   - If it contains `echo "ERROR:.*not configured` → mark as "unconfigured"
   - If that pattern is NOT found → mark as "configured"
   - If script is missing → mark as "missing"

3. **Display configuration summary**
   ```
   Tool Configuration Status
   =========================
   
   [✓] test.sh      - Configured
   [✗] build.sh     - Not configured
   [✓] lint.sh      - Configured
   [✗] format.sh    - Not configured
   [✗] coverage.sh  - Not configured
   [✓] install.sh   - Configured
   [✗] typecheck.sh - Not configured
   [!] dev.sh       - Missing
   
   Configured: 3/8 | Unconfigured: 4/8 | Missing: 1/8
   ```

4. **Warn and ask for confirmation if any scripts are unconfigured**
   ```
   Warning: Some tool scripts are not configured.
   
   The following phases may be affected:
   - 03-implementation: needs build.sh, lint.sh, format.sh, typecheck.sh
   - 04-testing: needs test.sh, coverage.sh
   
   Recommendations:
   - Configure at least: test.sh, build.sh, lint.sh
   - Edit scripts in .tools/bin/ and uncomment your tool commands
   - See .tools/README.md for configuration examples
   
   Proceed anyway? [y/n]
   (The workflow can be paused later to configure tools)
   ```
   
   Wait for user confirmation before proceeding.
   If user declines, STOP with message about how to configure tools.

## Input Validation (REQUIRED SECOND STEP)

Before proceeding, validate all inputs:

1. **Check Arguments Provided**
   - If `$ARGUMENTS` is empty or contains only whitespace, STOP and inform the user:
     ```
     Error: No feature description provided.
     Usage: /workflow-start <feature description>
     Example: /workflow-start Add user authentication with email/password
     ```

2. **Validate Feature Description**
   - Must be at least 5 characters (to ensure meaningful description)
   - Must not exceed 500 characters
   - If invalid, inform the user with requirements

3. **Slug Validation Rules**
   When creating the slug, enforce:
   - Only lowercase alphanumeric characters and hyphens allowed
   - No leading/trailing hyphens
   - No consecutive hyphens
   - Maximum 64 characters
   - Must not be a reserved name: `workflow`, `all`, `status`, `list`, `help`
   - Pattern: `^[a-z0-9][a-z0-9-]{0,62}[a-z0-9]$` (or single char `^[a-z0-9]$`)

4. **Path Traversal Prevention**
   - The slug must NOT contain: `..`, `/`, `\`, or null bytes
   - Verify the constructed path stays within `workflow/` directory
   - If any path component fails validation, STOP with error

5. **Check for Existing Workflow**
   - Check if `workflow/<slug>/` already exists
   - If it exists, inform the user and suggest alternatives:
     ```
     Error: Workflow '<slug>' already exists.
     Options:
       - Use a different feature name
       - Continue existing: /workflow-continue <slug>
       - Check status: /workflow-status <slug>
     ```

## Your Tasks

1. **Create Feature Slug**
   - Convert the feature title to a URL-safe slug (lowercase, hyphens)
   - Example: "User Authentication Flow" → "user-authentication-flow"

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/<slug>
   ```

3. **Create Directory Structure**
   Create the following directories under `workflow/<slug>/`:
   ```
   workflow/<slug>/
   ├── 00-feature/
   ├── 01-requirements/
   │   └── reviews/
   ├── 02-architecture/
   │   ├── diagrams/
   │   └── reviews/
   ├── 03-implementation/
   │   └── reviews/
   ├── 04-testing/
   │   └── reviews/
   └── 05-documentation/
       └── reviews/
   ```

4. **Save Feature Description**
   Create `workflow/<slug>/00-feature/description.md` with:
   ```markdown
   # Feature: <Title>

   ## Description
   <The feature description provided>

   ## Created
   <ISO8601 timestamp>

   ## Branch
   feature/<slug>
   ```

5. **Initialize Workflow State**
   Create `workflow/<slug>/workflow-state.json`:
   ```json
   {
     "feature": "<slug>",
     "feature_title": "<title>",
     "branch": "feature/<slug>",
     "created_at": "<ISO8601>",
     "updated_at": "<ISO8601>",
     "current_phase": "01-requirements",
     "status": "in_progress",
     "phases": {
       "01-requirements": { "status": "pending", "iterations": 0, "started_at": null, "completed_at": null },
       "02-architecture": { "status": "pending", "iterations": 0, "started_at": null, "completed_at": null },
       "03-implementation": { "status": "pending", "iterations": 0, "started_at": null, "completed_at": null },
       "04-testing": { "status": "pending", "iterations": 0, "started_at": null, "completed_at": null },
       "05-documentation": { "status": "pending", "iterations": 0, "started_at": null, "completed_at": null }
     },
     "escalations": [],
     "pr_url": null,
     "pr_number": null,
     "last_reviewed_at": null
   }
   ```

6. **Initialize Phase Status**
   Create `workflow/<slug>/01-requirements/status.json`:
   ```json
   {
     "phase": "01-requirements",
     "status": "in_progress",
     "iterations": 0,
     "max_iterations": 4,
     "current_feedback": null,
     "history": []
   }
   ```

7. **Seed Workspace from Central Docs**
   Copy existing central documentation into the workspace as starting points for creator agents.
   This ensures each workflow builds upon the current state of the project's documentation
   rather than creating documents from scratch.

   Copy the following files (skip any that don't exist yet):
   - `docs/features.md`     → `workflow/<slug>/00-feature/features.md`
   - `docs/requirements.md` → `workflow/<slug>/01-requirements/requirements.md`
   - `docs/architecture.md` → `workflow/<slug>/02-architecture/architecture.md`
   - `docs/diagrams/*`      → `workflow/<slug>/02-architecture/diagrams/`
   - `docs/user-guide.md`   → `workflow/<slug>/05-documentation/user-docs.md`
   - `docs/api-reference.md` → `workflow/<slug>/05-documentation/api-docs.md`

   If no `docs/` directory exists (first workflow), skip this step entirely — creators
   will start from their templates.

   **After seeding**, append the current feature to `workflow/<slug>/00-feature/features.md`.
   If the file was not seeded (first workflow), create it with a header first:

   ```markdown
   # Features

   Cumulative log of all features developed through the workflow.

   ---
   ```

   Then append this entry:

   ```markdown
   ## <Feature Title>

   - **Slug:** <slug>
   - **Branch:** feature/<slug>
   - **Created:** <ISO8601 timestamp>
   - **Status:** in_progress

   ### Description

   <The feature description provided>

   ---
   ```

8. **Run Requirements Phase (Internal Review Only)**
   - Invoke `@requirements-creator` with the feature description
   - After creation, invoke `@requirements-reviewer` to review
   - Handle the internal creator/reviewer cycle (max 4 iterations)
   - Update status files after each iteration
   - On internal approval: commit changes

9. **Push and Create PR**
   After the requirements phase passes internal review:
   - Push to remote: `git push -u origin feature/<slug>`
   - Create the PR using the template from the orchestrator's PR Body Template
   - Extract the PR number and URL from the created PR
   - Update `workflow-state.json` with `pr_url`, `pr_number`
   - Set phase 01 status to `user_review`

10. **STOP — Wait for Human Review**
    Inform the human:
    ```
    Requirements phase complete (internal review passed).
    
    PR created: <pr_url>
    
    Next steps:
    1. Review the requirements on the PR
    2. Leave file-level comments on any issues
    3. When satisfied, submit a review with "Approve"
    4. Then run: /workflow-continue <slug>
    ```
    
    Do NOT proceed to the architecture phase. Wait for the human to review
    and approve on GitHub, then continue via `/workflow-continue`.

## Important

- Always update `workflow-state.json` when changing phases
- Create review files in the `reviews/` subdirectory
- Commit after each phase's internal approval with message: `[workflow] <phase>: <summary>`
- Push after every commit — the PR updates automatically
- If 4 iterations pass without internal approval, escalate to human
- The workflow pauses after each phase for human review on the PR
