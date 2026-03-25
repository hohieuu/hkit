---
name: review
description: >-
  Interactive code review skill. Use after implementation to check code quality,
  correctness, security, and patterns. Presents findings with previews for
  side-by-side before/after comparison. User confirms which issues to fix.
  Chains from: implement.
---

# Review — Interactive Code Review

**Skill identity:** Prefix every text response with `👀 [review]` so the user always knows which skill is active.

Review code changes with structured feedback. Present issues visually, let the user decide what to fix.

**AskUserQuestion constraints:** max 4 questions/call · 2–4 options each · header ≤12 chars · use preview for before/after code comparisons.

## Process

### Initialization

- **Scope** (single): Unstaged changes (Recommended) / Staged changes / Last commit / Specific files
- **Focus** (multi): All (Recommended) / Correctness only / Security / Performance

Create tasks based on focus areas selected:
- `subject`: "Review correctness" / `subject`: "Review security" / `subject`: "Review performance"
- `subject`: "Present findings & apply fixes" / `activeForm`: "Applying fixes"

---

### [Review] — Analyze Each Category

For each review category task:

1. **TaskUpdate** → `in_progress`
2. Read all changed files thoroughly
3. Analyze against the category criteria
4. Collect findings
5. **TaskUpdate** → `completed`

---

### [Findings] — Present Issues with Previews

**TaskUpdate**: Mark findings task as `in_progress`.

If issues found, present them grouped by severity. Use **preview** for before/after code comparison:

#### Critical Issues (must fix)

**Critical** (multi, each option has preview with before/after code): Fix: \<issue description\> / Fix all critical

#### Suggestions (nice to have)

**Suggestions** (multi, each option has preview with before/after code): \<Suggestion\> / Apply all suggestions / Skip all

If NO issues found:

**Clean** (single): Run tests (Recommended) / Done

---

### [Apply] — Fix Selected Issues

For each selected fix:
1. Read the file
2. Apply the fix
3. Show the diff briefly

After all fixes applied:

**Next** (single): Run tests (Recommended) / Review again / Done

#### Chaining

| User picks | Action |
|-----------|--------|
| Run tests | Run `make test` or equivalent, report results |
| Review again | Loop back to [Review] |
| Done | Remind user to commit and push manually when ready |

**TaskUpdate**: Mark findings task as `completed`.

## Key Principles

- **Preview is king** — always show before/after code in preview fields for fixes.
- **Severity matters** — separate critical (must fix) from suggestions (nice to have).
- **User decides** — never auto-fix. Present options, let user choose.
- **Group by file** — if multiple issues in one file, group them to minimize context switching.
- **Max 4 options per question** — if more than 4 issues, batch into "Fix all critical" + individual picks.
