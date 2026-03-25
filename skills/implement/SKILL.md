---
name: implement
description: >-
  Pre-implementation guard skill. Use before writing any non-trivial code.
  Confirms scope, approach, and files to change with the user before touching code.
  Uses Plan mode for multi-file changes. Tracks progress with tasks.
  Chains from: brainstorming, clarify, investigate. Chains to: review.
---

# Implement — Guarded Code Implementation

**Skill identity:** Prefix every text response with `🔨 [implement]` so the user always knows which skill is active.

Never write code blindly. Confirm what, where, and how before touching anything.

<HARD-GATE>
Do NOT write code until:
1. The user has confirmed the scope and approach
2. A task list is created for tracking
3. For multi-file changes: a plan is approved via EnterPlanMode/ExitPlanMode
</HARD-GATE>

## Tool Reference

| Tool | Usage |
|------|-------|
| **TaskCreate** | Create tasks for each implementation unit (file or logical change) |
| **TaskUpdate** | Mark in_progress when starting a file, completed when done |
| **AskUserQuestion** | Confirm scope, approach, and review checkpoints |
| **EnterPlanMode** | For multi-file changes, enter plan mode for user approval |
| **ExitPlanMode** | Present the plan for review before implementing |

## Process

### Initialization — Assess Scope

First, analyze the task and present scope:

```
AskUserQuestion({
  questions: [
    {
      question: "Here's what I plan to change. Does this scope look right?",
      header: "Scope",
      options: [
        { label: "Looks right", description: "Proceed with this scope" },
        { label: "Too broad", description: "I want a smaller, more focused change" },
        { label: "Too narrow", description: "There's more that needs to change" },
        { label: "Wrong files", description: "You're looking at the wrong area" }
      ],
      multiSelect: false
    },
    {
      question: "What's the change size?",
      header: "Size",
      options: [
        { label: "Small (1-2 files)", description: "Quick change, no plan needed" },
        { label: "Medium (3-5 files)", description: "Plan mode recommended" },
        { label: "Large (6+ files)", description: "Plan mode required, break into phases" }
      ],
      multiSelect: false
    }
  ]
})
```

#### Routing by size

| Size | Action |
|------|--------|
| Small | Skip plan mode, create tasks directly, implement |
| Medium | **EnterPlanMode** → write plan → **ExitPlanMode** for approval → implement |
| Large | **EnterPlanMode** → write phased plan → **ExitPlanMode** → implement phase by phase |

---

### [Plan Mode] — For Medium/Large Changes

Call **EnterPlanMode**.

In plan mode:
- Explore the codebase to understand existing patterns
- Write the implementation plan with:
  - Files to create/modify (with line ranges)
  - Order of changes
  - Dependencies between changes
  - Test strategy

Call **ExitPlanMode** when plan is ready. Wait for user approval.

---

### [Execute] — Implementation with Task Tracking

Create one **TaskCreate** per logical unit of work:

```
// Example for a 3-file change
TaskCreate({ subject: "Update model struct", activeForm: "Updating model", description: "Add new field to User model in models/user.go" })
TaskCreate({ subject: "Update service logic", activeForm: "Updating service", description: "Handle new field in services/user_service.go" })
TaskCreate({ subject: "Add tests", activeForm: "Writing tests", description: "Add unit tests for new field handling" })
```

Set dependencies: tests blocked by service, service blocked by model.

For each task:
1. **TaskUpdate** → `in_progress`
2. Read the file first (always)
3. Make the change
4. **TaskUpdate** → `completed`

---

### [Checkpoint] — Mid-Implementation Review

After completing 50% of tasks (or after any risky change), checkpoint with the user:

```
AskUserQuestion({
  questions: [{
    question: "I've completed <N>/<Total> changes. Quick checkpoint — should I continue?",
    header: "Checkpoint",
    options: [
      { label: "Continue", description: "Changes look good, keep going" },
      { label: "Pause & review", description: "I want to review what's been done so far" },
      { label: "Change approach", description: "I see an issue, let's adjust" }
    ],
    multiSelect: false
  }]
})
```

- If "Pause & review", show a diff summary and wait.
- If "Change approach", ask what to adjust and update remaining tasks.

---

### [Done] — Completion & Chain to Review

After all tasks are completed:

```
AskUserQuestion({
  questions: [{
    question: "Implementation complete. What's next?",
    header: "Next",
    options: [
      { label: "Review code (Recommended)", description: "Run /review to check quality and correctness" },
      { label: "Run tests", description: "Execute the test suite to verify changes" },
      { label: "Done", description: "No further action — commit and push manually when ready" },
      { label: "Done", description: "No further action needed" }
    ],
    multiSelect: false
  }]
})
```

#### Chaining

| User picks | Action |
|-----------|--------|
| Review code | Invoke skill **review** |
| Run tests | Run `make test` or equivalent, report results |
| Done | Remind user to commit and push manually when ready |

## Key Principles

- **Read before write** — always read a file before modifying it.
- **One task per logical change** — granular tracking, not one giant task.
- **Plan for multi-file** — EnterPlanMode is mandatory for 3+ files.
- **Checkpoint at 50%** — catch course corrections early.
- **Chain to review** — always offer /review after implementation.
