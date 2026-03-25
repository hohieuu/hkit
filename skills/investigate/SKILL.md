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

**AskUserQuestion constraints:** max 4 questions/call · 2–4 options each · header ≤12 chars · use preview for code evidence.

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

Gather information:

- **Issue type** (single): Error/crash / Wrong behavior / Performance / Flaky/intermittent
- **Timeline** (single): After a change / Always broken / Gradual / Unknown

Then autonomously:
- Read error logs, stack traces, or relevant output the user provided
- Attempt to reproduce by reading the code path
- Check recent git history if "after a change" was selected

Present findings and confirm: **Confirm** (single): Yes, exactly / Partially / No, different

- If "Partially" or "No", ask a follow-up to get more details.

**TaskUpdate**: Mark task 1 as `completed`.

---

### [2. Narrow] — Narrow Down the Scope

**TaskUpdate**: Mark task 2 as `in_progress`.

Autonomously explore:
- Trace the code execution path
- Check related files, configs, dependencies
- Look for similar patterns in the codebase

Present candidates: **Scope** (multi, dynamic): \<File/module A\> / \<File/module B\> / \<File/module C\> / None of these

- If "None of these", ask user for hints and re-explore.
- If specific areas selected, deep-dive into those.

**TaskUpdate**: Mark task 2 as `completed`.

---

### [3. Root Cause] — Identify the Root Cause

**TaskUpdate**: Mark task 3 as `in_progress`.

Deep-dive into the narrowed scope. Read code thoroughly, trace data flow, check edge cases.

Present root cause with evidence in preview:

**Root cause** (single, with preview showing buggy code + impact):
- Yes, that's it
- Not convinced → widen scope, repeat from [2. Narrow]

- If "Not convinced", widen scope and repeat from [2. Narrow].

**TaskUpdate**: Mark task 3 as `completed`.

---

### [4. Route] — Confirm Fix Strategy

**TaskUpdate**: Mark task 4 as `in_progress`.

**Fix** (single): Quick fix (Recommended) / Proper refactor / Workaround / Just document

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
