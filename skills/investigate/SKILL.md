---
name: investigate
description: >-
  Structured investigation and debugging skill. Use when the user reports a bug,
  unexpected behavior, error, or wants to understand why something is happening.
  Guides through systematic diagnosis with interactive checkpoints.
  Chains to: implement (fix found), clarify (still unclear), or decide (multiple root causes).
---

# Investigate — Structured Debugging & Root Cause Analysis

**Skill identity:** Prefix every text response with `🔍 [investigate]` so the user always knows which skill is active.

Systematically investigate bugs, errors, and unexpected behavior with user checkpoints at every stage. Never guess at root causes — prove them.

<HARD-GATE>
Do NOT apply fixes until the investigation is complete and the user has confirmed the root cause.
Do NOT skip steps — even if the answer seems obvious, verify it.
</HARD-GATE>

## Tool Reference

| Tool | Usage |
|------|-------|
| **TaskCreate** | Create 4 tasks: Reproduce → Narrow → Root cause → Route |
| **TaskUpdate** | Track progress, mark completed after user confirms each step |
| **AskUserQuestion** | Checkpoints — confirm reproduction, narrow scope, verify root cause, pick fix strategy |
| **EnterPlanMode** | If fix requires multi-step implementation |

## Process

### Initialization

Create 4 tasks using **TaskCreate**:

1. `subject`: "Reproduce & understand symptoms" / `activeForm`: "Reproducing issue"
2. `subject`: "Narrow down scope" / `activeForm`: "Narrowing scope"
3. `subject`: "Identify root cause" / `activeForm`: "Finding root cause"
4. `subject`: "Confirm & route to fix" / `activeForm`: "Confirming root cause"

Set sequential dependencies via `addBlockedBy`.

---

### [1. Reproduce] — Understand the Symptoms

**TaskUpdate**: Mark task 1 as `in_progress`.

First, gather information about the problem:

```
AskUserQuestion({
  questions: [
    {
      question: "What type of issue are you seeing?",
      header: "Issue type",
      options: [
        { label: "Error/crash", description: "Application throws an error, panic, or crashes" },
        { label: "Wrong behavior", description: "It runs but produces incorrect results" },
        { label: "Performance", description: "It works but is too slow or uses too many resources" },
        { label: "Flaky/intermittent", description: "Sometimes works, sometimes doesn't" }
      ],
      multiSelect: false
    },
    {
      question: "When did this start happening?",
      header: "Timeline",
      options: [
        { label: "After a change", description: "Started after a specific commit, deploy, or config change" },
        { label: "Always broken", description: "Never worked correctly as far as I know" },
        { label: "Gradual", description: "Got worse over time" },
        { label: "Unknown", description: "Not sure when it started" }
      ],
      multiSelect: false
    }
  ]
})
```

Then autonomously:
- Read error logs, stack traces, or relevant output the user provided
- Attempt to reproduce by reading the code path
- Check recent git history if "after a change" was selected

Present findings and confirm:

```
AskUserQuestion({
  questions: [{
    question: "I found the following. Does this match what you're seeing?",
    header: "Confirm",
    options: [
      { label: "Yes, exactly", description: "That's the issue I'm experiencing" },
      { label: "Partially", description: "Some of it matches but there's more to it" },
      { label: "No, different", description: "That's not what I'm seeing" }
    ],
    multiSelect: false
  }]
})
```

- If "Partially" or "No", ask a follow-up to get more details.

**TaskUpdate**: Mark task 1 as `completed`.

---

### [2. Narrow] — Narrow Down the Scope

**TaskUpdate**: Mark task 2 as `in_progress`.

Autonomously explore:
- Trace the code execution path
- Check related files, configs, dependencies
- Look for similar patterns in the codebase

Present what you found as candidates:

```
AskUserQuestion({
  questions: [{
    question: "I've narrowed it down to these areas. Which seem most relevant?",
    header: "Scope",
    options: [
      // Dynamically generated, max 4
      { label: "<File/module A>", description: "<Why it's suspicious — specific line or pattern>" },
      { label: "<File/module B>", description: "<Why it's suspicious>" },
      { label: "<File/module C>", description: "<Why it's suspicious>" },
      { label: "None of these", description: "I think it's somewhere else" }
    ],
    multiSelect: true
  }]
})
```

- If "None of these", ask user for hints and re-explore.
- If specific areas selected, deep-dive into those.

**TaskUpdate**: Mark task 2 as `completed`.

---

### [3. Root Cause] — Identify the Root Cause

**TaskUpdate**: Mark task 3 as `in_progress`.

Deep-dive into the narrowed scope. Read code thoroughly, trace data flow, check edge cases.

Present the root cause with evidence using **preview** for code comparison:

```
AskUserQuestion({
  questions: [{
    question: "I believe I found the root cause. Does this look right?",
    header: "Root cause",
    options: [
      {
        label: "Yes, that's it",
        description: "This explains the behavior I'm seeing",
        preview: "## Root Cause\n\n**File:** `path/to/file.go:42`\n\n```go\n// BUG: This returns nil when input is empty\nfunc process(input string) *Result {\n    if input == \"\" {\n        return nil  // ← caller doesn't check for nil\n    }\n}\n```\n\n**Impact:** Nil pointer dereference when empty input is passed"
      },
      {
        label: "Not convinced",
        description: "I don't think that's the real cause",
        preview: "## What I found\n\n<same evidence>\n\n**If this isn't it**, I'll widen the search and check:\n- Upstream callers\n- Config/env differences\n- Race conditions"
      }
    ],
    multiSelect: false
  }]
})
```

- If "Not convinced", widen scope and repeat from [2. Narrow].

**TaskUpdate**: Mark task 3 as `completed`.

---

### [4. Route] — Confirm Fix Strategy

**TaskUpdate**: Mark task 4 as `in_progress`.

```
AskUserQuestion({
  questions: [{
    question: "How should we fix this?",
    header: "Fix",
    options: [
      { label: "Quick fix (Recommended)", description: "Minimal targeted fix for the root cause" },
      { label: "Proper refactor", description: "Fix the root cause and improve the surrounding code" },
      { label: "Workaround", description: "Patch the symptom, deal with root cause later" },
      { label: "Just document", description: "Known issue — document it and move on" }
    ],
    multiSelect: false
  }]
})
```

#### Chaining

| User picks | Action |
|-----------|--------|
| Quick fix | Execute the fix directly (small change) or invoke skill **implement** (multi-file) |
| Proper refactor | Invoke skill **brainstorming** to design the refactor |
| Workaround | Execute directly with a TODO comment |
| Just document | Write a comment or doc note, done |

**TaskUpdate**: Mark task 4 as `completed`.

## Key Principles

- **Prove, don't guess** — always show evidence (file, line, data flow) before claiming root cause.
- **Checkpoint every step** — user confirms before moving forward.
- **Use preview for code** — show the buggy code and explain why it's wrong.
- **Max 2 loops** — if narrowing fails twice, ask user for more context rather than going in circles.
