---
name: estimate
description: >-
  Effort estimation skill with structured task breakdown and user input.
  Use when the user asks how big a change is, how to break it down, or needs
  to scope work for planning. Produces a task breakdown with effort levels.
  Chains to: implement, brainstorming, or decide.
---

# Estimate — Effort Estimation & Task Breakdown

Break work down into estimatable units, score them, and produce a scoped plan.

## Tool Reference

| Tool | Usage |
|------|-------|
| **TaskCreate** | Create 3 tasks: Analyze → Break down → Confirm estimate |
| **TaskUpdate** | Track estimation progress |
| **AskUserQuestion** | Gather context, confirm breakdown, present estimate with previews |

## Process

### Initialization

Create 3 tasks using **TaskCreate**:

1. `subject`: "Analyze scope" / `activeForm`: "Analyzing scope"
2. `subject`: "Break down into units" / `activeForm`: "Breaking down tasks"
3. `subject`: "Confirm estimate & route" / `activeForm`: "Confirming estimate"

Set sequential dependencies.

---

### [1. Analyze] — Understand What We're Estimating

**TaskUpdate**: Mark task 1 as `in_progress`.

```
AskUserQuestion({
  questions: [
    {
      question: "What are we estimating?",
      header: "What",
      options: [
        { label: "Feature", description: "New functionality to build" },
        { label: "Bug fix", description: "Issue to investigate and fix" },
        { label: "Refactor", description: "Restructuring existing code" },
        { label: "Migration", description: "Moving data, upgrading deps, changing infra" }
      ],
      multiSelect: false
    },
    {
      question: "What estimation unit do you prefer?",
      header: "Unit",
      options: [
        { label: "T-shirt sizes", description: "XS, S, M, L, XL — relative effort" },
        { label: "Story points", description: "Fibonacci: 1, 2, 3, 5, 8, 13" },
        { label: "Time (hours)", description: "Rough hours of focused work" },
        { label: "Tasks only", description: "Just break it down, no scoring" }
      ],
      multiSelect: false
    }
  ]
})
```

Then autonomously explore the codebase:
- Identify files and modules that would be touched
- Check complexity of existing code
- Look for existing tests that need updating
- Identify dependencies and integration points

**TaskUpdate**: Mark task 1 as `completed`.

---

### [2. Break Down] — Decompose into Units

**TaskUpdate**: Mark task 2 as `in_progress`.

Present the breakdown using **preview** for a structured view:

```
AskUserQuestion({
  questions: [{
    question: "Here's the breakdown. Does this capture everything?",
    header: "Breakdown",
    options: [
      {
        label: "Looks complete (Recommended)",
        description: "All tasks accounted for",
        preview: "## Task Breakdown\n\n| # | Task | Files | Effort | Risk |\n|---|------|-------|--------|------|\n| 1 | Update data model | models/user.go | S | Low |\n| 2 | Add service logic | services/user.go | M | Med |\n| 3 | Add API endpoint | handlers/user.go | S | Low |\n| 4 | Update tests | *_test.go (3 files) | M | Low |\n| 5 | Add migration | migrations/ | XS | Med |\n\n**Total: M-L** (estimated 6-10 hours)\n\n**Risks:**\n- Migration needs downtime window\n- Service logic has edge cases to handle"
      },
      {
        label: "Missing tasks",
        description: "There are things not captured here"
      },
      {
        label: "Over-scoped",
        description: "Some of these tasks aren't needed"
      }
    ],
    multiSelect: false
  }]
})
```

- If "Missing tasks", ask what's missing and update.
- If "Over-scoped", ask what to remove and update.
- Loop until "Looks complete".

**TaskUpdate**: Mark task 2 as `completed`.

---

### [3. Confirm & Route] — Final Estimate

**TaskUpdate**: Mark task 3 as `in_progress`.

Present the final estimate:

```
AskUserQuestion({
  questions: [{
    question: "Estimate confirmed. What should we do with it?",
    header: "Next",
    options: [
      { label: "Start implementing (Recommended)", description: "Create task list from breakdown and start via /implement" },
      { label: "Brainstorm first", description: "Design the solution before implementing via /brainstorming" },
      { label: "Need to decide", description: "There's a decision to make first via /decide" },
      { label: "Export only", description: "Save the estimate as a document, don't implement" }
    ],
    multiSelect: false
  }]
})
```

#### Chaining

| User picks | Action |
|-----------|--------|
| Start implementing | Invoke skill **implement** (pass breakdown as initial task list) |
| Brainstorm first | Invoke skill **brainstorming** |
| Need to decide | Invoke skill **decide** |
| Export only | Write estimate to markdown file or present in conversation |

**TaskUpdate**: Mark task 3 as `completed`.

## Key Principles

- **Break down, then estimate** — never estimate a blob. Decompose first.
- **Show the breakdown visually** — use preview with tables for structured comparison.
- **Include risk** — every task gets an effort AND a risk level.
- **User confirms** — never finalize an estimate without user sign-off.
- **Don't over-precision** — ranges are better than exact numbers. "M-L" beats "7.5 hours".
