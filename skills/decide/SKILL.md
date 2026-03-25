---
name: decide
description: >-
  Decision-making framework for architectural, technology, and design choices.
  Use when facing multiple valid options with trade-offs. Structures the decision
  with criteria, scoring, and side-by-side previews. Produces a decision record.
  Chains to: brainstorming, implement, or investigate.
---

# Decide — Structured Decision Making

When there are multiple valid paths, don't just pick one — structure the decision so the user can make an informed choice.

## Tool Reference

| Tool | Usage |
|------|-------|
| **TaskCreate** | Create 4 tasks: Frame → Research → Compare → Record |
| **TaskUpdate** | Track decision-making progress |
| **AskUserQuestion** | Frame the decision, gather criteria, present comparisons with preview |

## Process

### Initialization

Create 4 tasks using **TaskCreate**:

1. `subject`: "Frame the decision" / `activeForm`: "Framing decision"
2. `subject`: "Research options" / `activeForm`: "Researching options"
3. `subject`: "Compare & choose" / `activeForm`: "Comparing options"
4. `subject`: "Record decision & route" / `activeForm`: "Recording decision"

Set sequential dependencies.

---

### [1. Frame] — Define What We're Deciding

**TaskUpdate**: Mark task 1 as `in_progress`.

```
AskUserQuestion({
  questions: [
    {
      question: "What type of decision is this?",
      header: "Type",
      options: [
        { label: "Technology", description: "Choosing a library, framework, tool, or service" },
        { label: "Architecture", description: "Design pattern, data flow, system structure" },
        { label: "Approach", description: "How to implement something (strategy, algorithm)" },
        { label: "Trade-off", description: "Balancing competing concerns (speed vs quality, etc.)" }
      ],
      multiSelect: false
    },
    {
      question: "What criteria matter most for this decision?",
      header: "Criteria",
      options: [
        { label: "Simplicity", description: "Easiest to implement and maintain" },
        { label: "Performance", description: "Fastest, most efficient at scale" },
        { label: "Extensibility", description: "Easiest to extend or modify later" },
        { label: "Team familiarity", description: "What the team already knows" }
      ],
      multiSelect: true
    }
  ]
})
```

**TaskUpdate**: Mark task 1 as `completed`.

---

### [2. Research] — Explore Options

**TaskUpdate**: Mark task 2 as `in_progress`.

Autonomously:
- Explore the codebase for existing patterns and conventions
- Check dependencies already in use
- Look at similar decisions made elsewhere in the project
- If technology choice: check compatibility with existing stack

Present findings briefly, then confirm the options to compare:

```
AskUserQuestion({
  questions: [{
    question: "I've identified these options. Are there others to consider?",
    header: "Options",
    options: [
      { label: "<Option A>", description: "<What it is and why it's a candidate>" },
      { label: "<Option B>", description: "<What it is and why it's a candidate>" },
      { label: "<Option C>", description: "<What it is and why it's a candidate>" },
      { label: "These are complete", description: "No other options to add" }
    ],
    multiSelect: true
  }]
})
```

**TaskUpdate**: Mark task 2 as `completed`.

---

### [3. Compare] — Side-by-Side with Previews

**TaskUpdate**: Mark task 3 as `in_progress`.

Present the comparison using **preview** for visual side-by-side:

```
AskUserQuestion({
  questions: [{
    question: "Based on your criteria, which option do you prefer?",
    header: "Pick",
    options: [
      {
        label: "Option A (Recommended)",
        description: "Best balance of <top criteria>",
        preview: "## Option A: <Name>\n\n**Simplicity:** ★★★★☆\n**Performance:** ★★★☆☆\n**Extensibility:** ★★★★★\n**Team familiarity:** ★★★★☆\n\n### How it works\n```go\n// Example implementation sketch\ntype Handler struct {\n    cache Cache\n}\n\nfunc (h *Handler) Process(ctx context.Context, req Request) (*Response, error) {\n    // Simple, clean API\n    return h.cache.GetOrSet(req.Key, h.compute)\n}\n```\n\n### Pros\n- Clean API, easy to test\n- Aligns with existing patterns\n\n### Cons\n- Slightly slower than Option B"
      },
      {
        label: "Option B",
        description: "Best <secondary criteria>",
        preview: "## Option B: <Name>\n\n**Simplicity:** ★★☆☆☆\n**Performance:** ★★★★★\n**Extensibility:** ★★★☆☆\n**Team familiarity:** ★★☆☆☆\n\n### How it works\n```go\n// Example implementation sketch\ntype Pipeline struct {\n    stages []Stage\n    pool   *WorkerPool\n}\n\nfunc (p *Pipeline) Execute(ctx context.Context, items []Item) error {\n    // High performance, more complex\n    return p.pool.FanOut(items, p.stages...)\n}\n```\n\n### Pros\n- 3x faster at scale\n- Built-in concurrency\n\n### Cons\n- Steeper learning curve\n- More moving parts"
      },
      {
        label: "Option C",
        description: "Most <other criteria>",
        preview: "## Option C: <Name>\n\n**Simplicity:** ★★★☆☆\n**Performance:** ★★★★☆\n**Extensibility:** ★★★★☆\n**Team familiarity:** ★★★☆☆\n\n### How it works\n```go\n// Example implementation sketch  \n```\n\n### Pros\n- Balanced approach\n\n### Cons\n- Jack of all trades"
      }
    ],
    multiSelect: false
  }]
})
```

**TaskUpdate**: Mark task 3 as `completed`.

---

### [4. Record & Route] — Document and Move Forward

**TaskUpdate**: Mark task 4 as `in_progress`.

Summarize the decision in 3–5 lines:
- **Decision:** What was chosen
- **Why:** Key criteria that drove the choice
- **Alternatives considered:** What was rejected and why
- **Implications:** What this means for implementation

Then route:

```
AskUserQuestion({
  questions: [{
    question: "Decision recorded. What should we do next?",
    header: "Next",
    options: [
      { label: "Implement (Recommended)", description: "Start implementing the chosen approach via /implement" },
      { label: "Brainstorm details", description: "Flesh out the design before implementing via /brainstorming" },
      { label: "Save as ADR", description: "Write an Architecture Decision Record file" },
      { label: "Done", description: "Decision is recorded, no further action" }
    ],
    multiSelect: false
  }]
})
```

#### Chaining

| User picks | Action |
|-----------|--------|
| Implement | Invoke skill **implement** |
| Brainstorm details | Invoke skill **brainstorming** |
| Save as ADR | Write ADR markdown file to `docs/adr/` or project convention |
| Done | Exit |

**TaskUpdate**: Mark task 4 as `completed`.

## Key Principles

- **Never decide for the user** — present options, let them choose.
- **Criteria first** — always establish what matters before comparing.
- **Preview everything** — use side-by-side previews with star ratings and code sketches.
- **Record decisions** — always summarize the decision so it can be referenced later.
- **Max 3 options** — more than 3 causes decision paralysis. Group or eliminate.
