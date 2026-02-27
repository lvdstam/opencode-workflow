# OpenCode Workflow Project

A structured, multi-phase development workflow with gated reviews using OpenCode.

## Features

- **5 Sequential Phases**: Requirements → Architecture → Implementation → Testing → Documentation
- **Creator/Reviewer Agents**: Each phase has a dedicated creator and critical reviewer
- **Gated Progress**: Max 4 iterations per phase before human escalation
- **Git Integration**: Feature branches, automatic commits, PR creation
- **Human Control**: Override, approve, or reset at any point

## Quick Start

1. **Install OpenCode** (if not already installed):
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

2. **Configure your model provider** in OpenCode

3. **Start a workflow**:
   ```
   /workflow-start Add user authentication with email/password and OAuth
   ```

4. **Monitor progress**:
   ```
   /workflow-status <feature-slug>
   ```

5. **Continue after interruption**:
   ```
   /workflow-continue <feature-slug>
   ```

## Commands

| Command | Description |
|---------|-------------|
| `/workflow-start <desc>` | Start new feature workflow |
| `/workflow-continue <slug>` | Resume existing workflow |
| `/workflow-status <slug>` | Show workflow status |
| `/workflow-list` | List all workflows |
| `/workflow-approve <slug>` | Force approve current phase |
| `/workflow-reset <slug>` | Reset current phase |

## Architecture

```
.opencode/
├── opencode.json           # Configuration
├── agents/                 # 11 specialized agents
│   ├── orchestrator.md     # Primary workflow coordinator
│   ├── *-creator.md        # Phase creators (5)
│   └── *-reviewer.md       # Phase reviewers (5)
├── commands/               # 6 workflow commands
└── skills/
    └── workflow-state/     # State management instructions

workflow/
└── <feature>/              # Per-feature artifacts
    ├── 00-feature/
    ├── 01-requirements/
    ├── 02-architecture/
    ├── 03-implementation/
    ├── 04-testing/
    └── 05-documentation/
```

## Workflow Lifecycle

```
/workflow-start "Feature X"
        │
        ▼
┌─────────────────────────────────┐
│  01-requirements                │
│  ┌──────────┐    ┌──────────┐  │
│  │ Creator  │───►│ Reviewer │  │
│  └──────────┘    └──────────┘  │
│       ▲              │         │
│       └──────────────┘         │
│       (max 4 iterations)       │
└─────────────┬───────────────────┘
              │ APPROVED
              ▼
┌─────────────────────────────────┐
│  02-architecture                │
│  (same creator/reviewer cycle)  │
└─────────────┬───────────────────┘
              │
              ▼
        ... continues through all phases ...
              │
              ▼
┌─────────────────────────────────┐
│  Create PR for human review     │
└─────────────────────────────────┘
```

## Documentation

See [AGENTS.md](./AGENTS.md) for detailed workflow documentation.

## Customization

- **Modify review criteria**: Edit `.opencode/agents/*-reviewer.md`
- **Adjust iteration limits**: Change `max_iterations` in agent prompts
- **Add new phases**: Create new creator/reviewer agent pairs
- **Change models**: Update `.opencode/opencode.json`

## License

MIT
