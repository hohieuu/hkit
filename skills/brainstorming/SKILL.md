---
name: brainstorming
description: >-
  Collaborative brainstorming that turns ideas into designs and specs before any
  code is written. MUST be used before any creative work — creating features,
  building components, adding functionality, or modifying behavior. Explores
  user intent, requirements, and design through structured dialogue. Use when
  the user wants to brainstorm, design, plan a feature, explore ideas, or
  before starting any new creative implementation.
---

# Brainstorming Ideas Into Designs

**Skill identity:** Prefix every text response with `🧠 [brainstorm]` so the user always knows which skill is active.

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by collecting context, spiking the project to discover existing resources, presenting them to the user for selection, asking clarifying questions, then deciding whether the task needs design proposals or can proceed directly to implementation planning.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have completed the brainstorming process. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

**AskUserQuestion constraints:** max 4 questions/call · 2–4 options each · header ≤12 chars · preview only on single-select.

## Process

### Initialization — Create Task List

Before starting any step, create all 5 tasks using **TaskCreate** so the user can see the full roadmap:

1. `subject`: "Gather context" / `activeForm`: "Gathering context"
2. `subject`: "Spike & explore project" / `activeForm`: "Exploring project"
3. `subject`: "Clarify requirements" / `activeForm`: "Clarifying requirements"
4. `subject`: "Evaluate complexity & propose solutions" / `activeForm`: "Proposing solutions"
5. `subject`: "Decide next steps" / `activeForm`: "Deciding next steps"

Set up sequential dependencies using **TaskUpdate** `addBlockedBy` so each task is blocked by the previous one.

---

### [0. Context] — Gather Context

**TaskUpdate**: Mark task 1 as `in_progress`.

Present 5 context questions across **two AskUserQuestion calls** (max 4 questions per call).

**Call 1** (3 questions):
- **Current** (single): Greenfield / Existing code / Broken/buggy
- **Objective** (single): New feature / Improvement / Fix/resolve
- **Owner** (single): Me (dev) / My team / Handoff

**Call 2** (2 questions, after Call 1 reply):
- **Output** (multi): Design doc / Diagram / Code plan / All of above
- **Constraints** (multi): Time-boxed / Tech stack / Backward compat / Minimal scope

After both replies, summarize context in 1–2 lines.

**TaskUpdate**: Mark task 1 as `completed`.

---

### [1. Spike] — Spike & Gather Context

**TaskUpdate**: Mark task 2 as `in_progress`.

- Autonomously explore the project: scan files, docs, recent commits, existing patterns, modules, APIs, configs.
- Compile a list of relevant existing resources.
- Present findings as a structured list (related modules, similar features, relevant configs, API contracts).
- Ask the user which resources to reference or explore deeper:

**Resources** (multi, dynamic — max 4, group if more): \<Resource group 1\> / \<Resource group 2\> / All of them / None needed

- If user picks specific resources, dig into those before continuing.
- If user picks "None needed", proceed with findings as baseline context.

**TaskUpdate**: Mark task 2 as `completed`.

---

### [2. Clarify] — Asking Clarifying Questions

**TaskUpdate**: Mark task 3 as `in_progress`.

One AskUserQuestion call per message. Prefer multiple choice. Focus on purpose, constraints, success criteria. Typically 2–4 questions total.

Example: **Errors** (single): Fail fast / Retry + fallback / Silent log

**TaskUpdate**: Mark task 3 as `completed`.

---

### [3. Propose] — Evaluate Complexity & Propose Solutions

**TaskUpdate**: Mark task 4 as `in_progress`.

Ask complexity: **Complexity** (single): Complex — multiple valid approaches / Simple — clear single path

**Complex:** Propose 2–3 solutions with trade-offs. Use preview for side-by-side architecture comparison.
**Approach** (single, with preview per option): Option A (Recommended) / Option B / Option C

**Simple:** Summarize the single approach, then confirm:
**Confirm** (single): Looks good / Need changes → loop back to [2. Clarify]

**TaskUpdate**: Mark task 4 as `completed`.

---

### [4. Final] — What's Next?

**TaskUpdate**: Mark task 5 as `in_progress`.

**Next steps** (single): Summary only / Implement / Both

#### Path A — Summary only

1. Write concise text summary.
2. **Diagram** (single): Sequence diagram / Flowchart / Architecture / No diagram
3. If no diagram: **Export** (single): Markdown file / Notion / No thanks

**TaskUpdate**: Mark task 5 as `completed`. → **Terminal state: "Done"**

#### Path B — Start implementation

- Call **EnterPlanMode** to transition into plan mode.
- In plan mode, write the implementation plan based on the brainstorming output.
- Call **ExitPlanMode** when the plan is ready for user approval.

**TaskUpdate**: Mark task 5 as `completed`. → **Terminal state: "EnterPlanMode"**

#### Path C — Both

- Complete Path A first (summary + optional diagram/export).
- Then proceed with Path B (EnterPlanMode).

**TaskUpdate**: Mark task 5 as `completed`.

---

## Terminal States

- **"Done"** — brainstorming ends with a summary (with or without diagram/export). Do NOT invoke any implementation skill or write any code.
- **"EnterPlanMode"** — brainstorming ends by calling `EnterPlanMode` to transition into implementation planning. Write the plan, then call `ExitPlanMode` for user approval.

## Key Principles

- **One question at a time** — don't overwhelm with multiple questions (except Step 0 context form).
- **Multiple choice preferred** — easier to answer than open-ended. Use `preview` for visual comparisons.
- **YAGNI ruthlessly** — remove unnecessary features from all designs.
- **Always confirm before proceeding** — complex tasks get 2–3 approaches; simple tasks get a summary to confirm.
- **Be flexible** — go back and clarify when something doesn't make sense.
- **Track progress** — always update task status so the user sees where they are in the process.

## Additional Resources

- For the full process flow diagram, see [process-flow.md](process-flow.md).
