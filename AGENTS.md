# Gated Development Workflow

This project uses a structured, multi-phase development workflow with automated creator/reviewer cycles and human gating.

## Overview

Features are developed through 5 sequential phases:
1. **Requirements** - Analyze feature and document requirements
2. **Architecture** - Design technical architecture
3. **Implementation** - Write code with structured planning
4. **Testing** - Create and run tests
5. **Documentation** - Write user and API docs

Each phase has:
- A **creator agent** that produces artifacts
- A **reviewer agent** that evaluates quality
- Up to **4 iterations** before human escalation
- **Git commits** after each phase approval
- A **PR** created when all phases complete

## Quick Start

### Start a New Feature
```
/workflow-start <feature description>
```

Example:
```
/workflow-start Add user authentication with email/password login and OAuth support
```

### Check Status
```
/workflow-status <feature-slug>
```

Or list all workflows:
```
/workflow-list
```

### Continue a Workflow
```
/workflow-continue <feature-slug>
```

### Human Overrides
```
/workflow-approve <feature-slug>   # Force approve current phase
/workflow-reset <feature-slug>     # Reset current phase
/workflow-cancel <feature-slug>    # Cancel and abandon workflow
```

## Directory Structure

```
workflow/
└── <feature-slug>/
    ├── 00-feature/
    │   └── description.md          # Original feature request
    ├── 01-requirements/
    │   ├── requirements.md         # Requirements document
    │   ├── reviews/                # Review history
    │   └── status.json             # Phase status
    ├── 02-architecture/
    │   ├── architecture.md         # Architecture design
    │   ├── diagrams/               # Technical diagrams
    │   ├── reviews/
    │   └── status.json
    ├── 03-implementation/
    │   ├── plan.md                 # Implementation plan
    │   ├── changes.md              # Change summary
    │   ├── reviews/
    │   └── status.json
    ├── 04-testing/
    │   ├── test-plan.md            # Test strategy
    │   ├── coverage-report.md      # Test results
    │   ├── reviews/
    │   └── status.json
    ├── 05-documentation/
    │   ├── user-docs.md            # User documentation
    │   ├── api-docs.md             # API documentation
    │   ├── reviews/
    │   └── status.json
    └── workflow-state.json         # Overall workflow state
```

## Agents

### Primary Agent
- **orchestrator** - Coordinates the workflow, manages phase transitions

### Phase Agents (Subagents)
| Phase | Creator | Reviewer |
|-------|---------|----------|
| Requirements | `requirements-creator` | `requirements-reviewer` |
| Architecture | `architecture-creator` | `architecture-reviewer` |
| Implementation | `coding-creator` | `coding-reviewer` |
| Testing | `testing-creator` | `testing-reviewer` |
| Documentation | `docs-creator` | `docs-reviewer` |

## Workflow Rules

### Creator/Reviewer Cycle
1. Creator produces artifact
2. Reviewer evaluates with APPROVED or NEEDS_REVISION
3. If NEEDS_REVISION: Creator revises based on feedback
4. Maximum 4 iterations before escalating to human
5. On APPROVED: Commit and advance to next phase

### Review Standards
- **Consistent throughout** - Same rigor for all iterations
- **CRITICAL issues** - Must be fixed before approval
- **MAJOR issues** - Should be fixed (max 2 allowed)
- **MINOR issues** - Nice to fix, won't block

### Git Protocol
- All work on feature branch: `feature/<slug>`
- Commit after each phase: `[workflow] <phase>: <summary>`
- PR created when documentation phase completes
- Human reviews PR before merge

### Human Escalation
After 4 iterations without approval:
- Workflow pauses
- Human receives summary of disagreement
- Human can: approve, provide guidance, or reset

## Customization

### Adjust Iteration Limit
Edit the phase `status.json` or modify agents to change `max_iterations`.

### Add Phases
1. Create new phase directory (e.g., `06-deployment/`)
2. Create creator and reviewer agents
3. Update orchestrator to include new phase

### Modify Review Criteria
Edit the reviewer agent markdown files in `.opencode/agents/`.

## Troubleshooting

### Workflow Stuck
Check `workflow-state.json` for current status. Use `/workflow-continue` to resume or `/workflow-reset` to start fresh.

### Escalation Loop
If the same phase keeps escalating, review the creator/reviewer feedback to identify the disagreement. Use `/workflow-approve` to override.

### Git Conflicts
Resolve conflicts manually, then `/workflow-continue` to resume.

### Corrupted State Files
If `workflow-state.json` or `status.json` is corrupted:
1. The orchestrator will attempt to reconstruct state from artifacts and git history
2. If reconstruction fails, use `/workflow-reset <slug> all` to restart
3. Or manually edit the JSON files to fix issues

### Input Validation Errors
All commands validate inputs before execution:
- Slugs must be lowercase alphanumeric with hyphens only
- Slugs cannot contain path traversal characters (`..`, `/`, `\`)
- Maximum slug length is 50 characters
- Phase names must be valid (e.g., `01-requirements`)

### Command Not Found
Ensure you're using the correct command syntax:
```
/workflow-start <description>      # Start new workflow
/workflow-continue <slug>          # Resume workflow
/workflow-status <slug>            # Check status
/workflow-list                     # List all workflows
/workflow-approve <slug>           # Force approve
/workflow-reset <slug> [phase]     # Reset phase(s)
/workflow-cancel <slug>            # Cancel workflow
```

### Restoring Cancelled Workflows
To restore a cancelled workflow:
1. Edit `workflow/<slug>/workflow-state.json`
2. Change `"status": "abandoned"` to `"status": "in_progress"`
3. Remove `cancelled_at` and `cancelled_reason` fields
4. Run `/workflow-continue <slug>`
