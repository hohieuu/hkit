## Skill Workflow — Proactive Usage Rules

Before acting on any user request, evaluate whether a skill should be triggered:

| Signal | Action |
|--------|--------|
| Request is vague, ambiguous, or has multiple interpretations | **MUST** invoke `/clarify` before doing anything else |
| Request is to build, create, or add new functionality | **MUST** invoke `/brainstorming` before writing code |
| Request reports a bug, error, or unexpected behavior | **SHOULD** invoke `/investigate` for structured diagnosis |
| Request involves choosing between options or trade-offs | **SHOULD** invoke `/decide` for structured comparison |
| Request asks "how big", "how long", or "break this down" | **SHOULD** invoke `/estimate` |
| Ready to write non-trivial code (3+ files) | **SHOULD** invoke `/implement` with plan mode |
| Code has been written, before committing | **SHOULD** offer `/review` |

**Clarification gate:** If you cannot confidently answer ALL of these about a request, invoke `/clarify`:
1. What exactly needs to change?
2. Where in the codebase?
3. Why (what problem does it solve)?
4. What does "done" look like?

Reference: `~/.claude/skills/SKILLS-INDEX.md` for full chaining map.
