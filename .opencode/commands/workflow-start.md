---
description: Start a new feature workflow with gated development phases
agent: orchestrator
---

# Start New Feature Workflow

Initialize a new gated development workflow for the following feature:

**Feature Description:**
$ARGUMENTS

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
     "pr_url": null
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

7. **Begin Requirements Phase**
   - Invoke `@requirements-creator` with the feature description
   - After creation, invoke `@requirements-reviewer` to review
   - Handle the creator/reviewer cycle (max 4 iterations)
   - Update status files after each iteration
   - Commit on approval and proceed to next phase

## Important

- Always update `workflow-state.json` when changing phases
- Create review files in the `reviews/` subdirectory
- Commit after each phase approval with message: `[workflow] <phase>: <summary>`
- If 4 iterations pass without approval, escalate to human
