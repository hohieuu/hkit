---
name: decide
description: >-
  Decision-making framework for architectural, technology, and design choices.
  Use when facing multiple valid options with trade-offs. Structures the decision
  with criteria, scoring, and side-by-side previews. Produces a decision record.
  Chains to: brainstorming, implement, or investigate.
---

# Decide — Structured Decision Making

**Skill identity:** Prefix every text response with `⚖️ [decide]` so the user always knows which skill is active.

When there are multiple valid paths, don't just pick one — structure the decision so the user can make an informed choice.

**AskUserQuestion constraints:** max 4 questions/call · 2–4 options each · header ≤12 chars · use preview for side-by-side comparisons.

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

- **Type** (single): Technology / Architecture / Approach / Trade-off
- **Criteria** (multi): Simplicity / Performance / Extensibility / Team familiarity

**TaskUpdate**: Mark task 1 as `completed`.

---

### [2. Research] — Explore Options

**TaskUpdate**: Mark task 2 as `in_progress`.

Autonomously:
- Explore the codebase for existing patterns and conventions
- Check dependencies already in use
- Look at similar decisions made elsewhere in the project
- If technology choice: check compatibility with existing stack

Present findings, then confirm: **Options** (multi, dynamic): \<Option A\> / \<Option B\> / \<Option C\> / These are complete

**TaskUpdate**: Mark task 2 as `completed`.

---

### [3. Compare] — Side-by-Side with Previews

**TaskUpdate**: Mark task 3 as `in_progress`.

**Pick** (single, each option has a preview with star ratings per criteria + pros/cons):
- Option A (Recommended) — best balance of \<top criteria\>
- Option B — best \<secondary criteria\>
- Option C — most \<other criteria\>

**TaskUpdate**: Mark task 3 as `completed`.

---

### [4. Record & Route] — Document and Move Forward

**TaskUpdate**: Mark task 4 as `in_progress`.

Summarize the decision in 3–5 lines:
- **Decision:** What was chosen
- **Why:** Key criteria that drove the choice
- **Alternatives considered:** What was rejected and why
- **Implications:** What this means for implementation

**Next** (single): Implement (Recommended) / Brainstorm details / Save as ADR / Done

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
