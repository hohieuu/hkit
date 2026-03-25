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

**AskUserQuestion constraints:** max 4 questions/call · 2–4 options each · header ≤12 chars.

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

**Round 1 — Intent & Scope:**
- **Intent** (single): \<Interpretation A\> / \<Interpretation B\> / \<Interpretation C\>
- **Scope** (single): Single file / One module / Cross-cutting / Not sure yet

**Round 2 — Constraints & Priority** (if still unclear):
- **Constraints** (multi): Don't break API / Minimal change / Performance / No constraints
- **Priority** (single): Quick fix / Do it right / Exploratory

**Round 3 — Edge Cases** (only if needed):
- **Edge case** (single): \<Option A\> / \<Option B\> / Ignore for now

**TaskUpdate**: Mark task 2 as `completed`.

---

### [3. Confirm & Route] — Summarize and Chain

**TaskUpdate**: Mark task 3 as `in_progress`.

Summarize understanding in 2–3 lines, then:

**Next step** (single): Start implementing / Brainstorm first / Investigate first / Just do it

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
