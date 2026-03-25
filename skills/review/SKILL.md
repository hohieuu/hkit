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

## Tool Reference

| Tool | Usage |
|------|-------|
| **TaskCreate** | Create tasks for each review category |
| **TaskUpdate** | Track review progress |
| **AskUserQuestion** | Present findings, get user decisions on fixes. Use `preview` for code comparisons |

## Process

### Initialization

Determine what to review:

```
AskUserQuestion({
  questions: [
    {
      question: "What should I review?",
      header: "Scope",
      options: [
        { label: "Unstaged changes (Recommended)", description: "Review all uncommitted changes (git diff)" },
        { label: "Staged changes", description: "Review only staged changes (git diff --staged)" },
        { label: "Last commit", description: "Review the most recent commit" },
        { label: "Specific files", description: "I'll tell you which files" }
      ],
      multiSelect: false
    },
    {
      question: "What aspects should I focus on?",
      header: "Focus",
      options: [
        { label: "All (Recommended)", description: "Correctness, security, performance, style" },
        { label: "Correctness only", description: "Logic bugs, edge cases, error handling" },
        { label: "Security", description: "Injection, auth, data exposure, OWASP top 10" },
        { label: "Performance", description: "N+1 queries, memory leaks, unnecessary allocations" }
      ],
      multiSelect: true
    }
  ]
})
```

Create tasks based on focus areas selected:

```
TaskCreate({ subject: "Review correctness", activeForm: "Reviewing correctness" })
TaskCreate({ subject: "Review security", activeForm: "Reviewing security" })
TaskCreate({ subject: "Review performance", activeForm: "Reviewing performance" })
TaskCreate({ subject: "Present findings & apply fixes", activeForm: "Applying fixes" })
```

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

```
AskUserQuestion({
  questions: [{
    question: "Found <N> critical issue(s). Which should I fix?",
    header: "Critical",
    options: [
      {
        label: "Fix: nil check missing",
        description: "services/user.go:42 — potential nil pointer dereference",
        preview: "## Before\n```go\nresult := repo.Find(id)\nreturn result.Name // panic if nil\n```\n\n## After\n```go\nresult := repo.Find(id)\nif result == nil {\n    return \"\", ErrNotFound\n}\nreturn result.Name, nil\n```"
      },
      {
        label: "Fix: SQL injection",
        description: "stores/query.go:18 — string concatenation in query",
        preview: "## Before\n```go\nquery := \"SELECT * FROM users WHERE name = '\" + name + \"'\"\n```\n\n## After\n```go\nquery := \"SELECT * FROM users WHERE name = ?\"\ndb.Raw(query, name)\n```"
      },
      {
        label: "Fix all critical",
        description: "Apply all critical fixes at once"
      }
    ],
    multiSelect: true
  }]
})
```

#### Suggestions (nice to have)

```
AskUserQuestion({
  questions: [{
    question: "Found <N> suggestion(s). Want me to apply any?",
    header: "Suggestions",
    options: [
      {
        label: "Rename variable",
        description: "processor.go:15 — 'x' should be 'itemCount' for clarity",
        preview: "## Before\n```go\nx := len(items)\nfor i := 0; i < x; i++ {\n```\n\n## After\n```go\nitemCount := len(items)\nfor i := 0; i < itemCount; i++ {\n```"
      },
      {
        label: "Apply all suggestions",
        description: "Apply all non-critical improvements"
      },
      {
        label: "Skip all",
        description: "No suggestions needed, code is fine as-is"
      }
    ],
    multiSelect: true
  }]
})
```

If NO issues found:

```
AskUserQuestion({
  questions: [{
    question: "Code looks clean — no issues found. What's next?",
    header: "Clean",
    options: [
      { label: "Run tests (Recommended)", description: "Run test suite to double-check before committing" },
      { label: "Done", description: "No further action — commit manually when ready" }
    ],
    multiSelect: false
  }]
})
```

---

### [Apply] — Fix Selected Issues

For each selected fix:
1. Read the file
2. Apply the fix
3. Show the diff briefly

After all fixes applied:

```
AskUserQuestion({
  questions: [{
    question: "All selected fixes applied. What's next?",
    header: "Next",
    options: [
      { label: "Run tests (Recommended)", description: "Verify fixes don't break anything before committing" },
      { label: "Review again", description: "Re-review the fixed code" },
      { label: "Done", description: "No further action — commit manually when ready" }
    ],
    multiSelect: false
  }]
})
```

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
