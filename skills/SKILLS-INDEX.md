# Skills Index — Chaining & Workflow Map

## Available Skills

| Skill | Slash Command | Purpose |
|-------|--------------|---------|
| **clarify** | `/clarify` | Disambiguate vague requests before acting |
| **brainstorming** | `/brainstorming` | Design exploration before code |
| **investigate** | `/investigate` | Structured debugging & root cause analysis |
| **decide** | `/decide` | Structured decision-making with trade-offs |
| **estimate** | `/estimate` | Effort estimation & task breakdown |
| **implement** | `/implement` | Guarded code implementation with checkpoints |
| **review** | `/review` | Interactive code review with fix suggestions |
| **commit** | `/commit` | Quality gate & atomic commits |
| **mr** | `/mr` | Create merge request |
| **simplify** | `/simplify` | Review changed code for quality |

## Chaining Map

```
                    ┌──────────┐
                    │ /clarify │ ← Start here when request is vague
                    └────┬─────┘
                         │
            ┌────────────┼────────────┬──────────────┐
            ▼            ▼            ▼              ▼
    ┌──────────────┐ ┌──────────┐ ┌─────────────┐  Just
    │/brainstorming│ │/implement│ │/investigate  │  do it
    └──────┬───────┘ └────┬─────┘ └──────┬───────┘
           │              │              │
           │         ┌────┘         ┌────┘
           ▼         ▼              ▼
    ┌──────────┐ ┌────────┐  ┌──────────┐
    │ /decide  │ │/review │  │ /decide  │
    └────┬─────┘ └───┬────┘  └────┬─────┘
         │           │            │
         ▼           ▼            ▼
    ┌──────────┐ ┌────────┐  ┌──────────┐
    │/implement│ │/commit │  │/implement│
    └────┬─────┘ └───┬────┘  └────┬─────┘
         │           │            │
         ▼           ▼            ▼
    ┌────────┐  ┌────────┐  ┌────────┐
    │/review │  │  /mr   │  │/review │
    └───┬────┘  └────────┘  └───┬────┘
        │                       │
        ▼                       ▼
    ┌────────┐              ┌────────┐
    │/commit │              │/commit │
    └───┬────┘              └───┬────┘
        │                       │
        ▼                       ▼
    ┌────────┐              ┌────────┐
    │  /mr   │              │  /mr   │
    └────────┘              └────────┘


    ┌──────────┐
    │/estimate │ ← Standalone entry point
    └────┬─────┘
         │
    ┌────┼──────────┬──────────┐
    ▼    ▼          ▼          ▼
 /impl /brainstorm /decide  Export
```

## Tool Usage by Skill

| Skill | AskUserQuestion | TaskCreate | TaskUpdate | EnterPlanMode | ExitPlanMode | Preview |
|-------|:-:|:-:|:-:|:-:|:-:|:-:|
| clarify | 3 rounds | 3 tasks | yes | — | — | — |
| brainstorming | 7+ calls | 5 tasks | yes | yes | yes | Step 3 |
| investigate | 5+ calls | 4 tasks | yes | — | — | Root cause |
| decide | 4 calls | 4 tasks | yes | — | — | Comparison |
| estimate | 3 calls | 3 tasks | yes | — | — | Breakdown |
| implement | 3+ calls | per-file | yes | yes | yes | — |
| review | 3+ calls | per-category | yes | — | — | Before/After |

## When to Use Which Skill

| Signal | Skill |
|--------|-------|
| Vague request, multiple interpretations | `/clarify` |
| "Build X", "Add Y", new feature | `/brainstorming` |
| "It's broken", "Why does X happen" | `/investigate` |
| "Should we use A or B" | `/decide` |
| "How big is this", "Break this down" | `/estimate` |
| Ready to code, scope is clear | `/implement` |
| Code is written, check quality | `/review` |
| Ready to commit | `/commit` |
| Ready to push and create MR | `/mr` |
