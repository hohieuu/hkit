---
name: clarify
description: >-
  Proactive clarification skill for vague or ambiguous instructions. Use when the
  user's request is unclear, has multiple interpretations, or is missing critical
  details. Asks structured questions to disambiguate before taking action.
  Chains to: brainstorming, implement, investigate, or decide.
---

# Clarify — Proactive Disambiguation

**Skill identity:** Prefix every text response with `❓ [clarify]` so the user always knows which skill is active.

Stop guessing. When a request is vague, ambiguous, or missing critical details, use this skill to ask structured questions before doing anything.

<HARD-GATE>
Do NOT start any implementation, exploration, or design until clarification is complete.
If any of these signals are present, trigger this skill:
- Request has multiple valid interpretations
- Scope is undefined ("make it better", "fix this", "add a feature")
- Missing: what, where, why, or how
- User references something ambiguous ("that thing", "the bug", "the page")
</HARD-GATE>

## Tool Reference

| Tool | Usage |
|------|-------|
| **TaskCreate** | Create 3 tasks: Identify gaps → Ask questions → Confirm & route |
| **TaskUpdate** | Track progress through each step |
| **AskUserQuestion** | All clarification interactions (max 4 Qs per call, 2–4 options each) |

## Process

### Initialization

Create 3 tasks using **TaskCreate**:

1. `subject`: "Identify ambiguity" / `activeForm`: "Analyzing request"
2. `subject`: "Ask clarifying questions" / `activeForm`: "Clarifying requirements"
3. `subject`: "Confirm understanding & route" / `activeForm`: "Confirming direction"

Set sequential dependencies via `addBlockedBy`.

---

### [1. Identify] — Spot the Gaps

**TaskUpdate**: Mark task 1 as `in_progress`.

Silently analyze the user's request. Identify:
- What is clear vs. ambiguous
- What interpretations are possible
- What critical information is missing

Do NOT ask the user anything yet. Prepare your questions.

**TaskUpdate**: Mark task 1 as `completed`.

---

### [2. Ask] — Structured Clarification

**TaskUpdate**: Mark task 2 as `in_progress`.

Ask up to **3 rounds** of questions. Each round is one **AskUserQuestion** call with 1–4 questions.

#### Round 1 — Intent & Scope

```
AskUserQuestion({
  questions: [
    {
      question: "What do you mean by '<ambiguous phrase from request>'?",
      header: "Intent",
      options: [
        { label: "<Interpretation A>", description: "<What this means concretely>" },
        { label: "<Interpretation B>", description: "<What this means concretely>" },
        { label: "<Interpretation C>", description: "<What this means concretely>" }
      ],
      multiSelect: false
    },
    {
      question: "What is the scope of this change?",
      header: "Scope",
      options: [
        { label: "Single file", description: "Change is localized to one file or function" },
        { label: "One module", description: "Change spans a module or package" },
        { label: "Cross-cutting", description: "Change touches multiple modules or layers" },
        { label: "Not sure yet", description: "Need to investigate first" }
      ],
      multiSelect: false
    }
  ]
})
```

#### Round 2 — Constraints & Priority (if still unclear)

```
AskUserQuestion({
  questions: [
    {
      question: "What constraints should I respect?",
      header: "Constraints",
      options: [
        { label: "Don't break API", description: "Backward compatibility is required" },
        { label: "Minimal change", description: "Smallest possible diff" },
        { label: "Performance", description: "Must not degrade performance" },
        { label: "No constraints", description: "Do whatever makes sense" }
      ],
      multiSelect: true
    },
    {
      question: "What's the priority here?",
      header: "Priority",
      options: [
        { label: "Quick fix", description: "Ship fast, clean up later" },
        { label: "Do it right", description: "Take time for a proper solution" },
        { label: "Exploratory", description: "Not sure yet, let's figure it out" }
      ],
      multiSelect: false
    }
  ]
})
```

#### Round 3 — Edge Cases (only if needed)

```
AskUserQuestion({
  questions: [{
    question: "How should we handle <specific edge case>?",
    header: "Edge case",
    options: [
      { label: "<Option A>", description: "<Behavior>" },
      { label: "<Option B>", description: "<Behavior>" },
      { label: "Ignore for now", description: "Handle it later or not at all" }
    ],
    multiSelect: false
  }]
})
```

**TaskUpdate**: Mark task 2 as `completed`.

---

### [3. Confirm & Route] — Summarize and Chain

**TaskUpdate**: Mark task 3 as `in_progress`.

Summarize what you understood in 2–3 lines, then ask where to go next:

```
AskUserQuestion({
  questions: [{
    question: "I now understand the task. What should we do next?",
    header: "Next step",
    options: [
      { label: "Start implementing", description: "Requirements are clear — proceed to /implement" },
      { label: "Brainstorm first", description: "Needs design exploration — proceed to /brainstorming" },
      { label: "Investigate first", description: "Need to dig into the code — proceed to /investigate" },
      { label: "Just do it", description: "Skip workflows, execute directly" }
    ],
    multiSelect: false
  }]
})
```

#### Chaining

| User picks | Action |
|-----------|--------|
| Start implementing | Invoke skill **implement** |
| Brainstorm first | Invoke skill **brainstorming** |
| Investigate first | Invoke skill **investigate** |
| Just do it | Exit skill, execute the task directly |

**TaskUpdate**: Mark task 3 as `completed`.

## Key Principles

- **Never guess** — if you're unsure, ask. One question now saves 10 minutes of rework.
- **Multiple choice first** — present your best guesses as options. "Other" is always available.
- **Max 3 rounds** — don't interrogate. If still unclear after 3 rounds, summarize what you know and proceed with caveats.
- **Show your interpretation** — always summarize before routing so the user can correct you.
