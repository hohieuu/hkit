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

## Tool Reference

This skill uses the following Claude tools. Respect their constraints:

| Tool | Constraints | Usage |
|------|------------|-------|
| **TaskCreate** | `subject` (imperative), `description`, optional `activeForm` (present continuous) | Create one task per brainstorming step for progress tracking |
| **TaskUpdate** | `status`: pending → in_progress → completed | Mark each step as in_progress when starting, completed when done |
| **AskUserQuestion** | Max **4 questions** per call, **2–4 options** per question, `header` max 12 chars. "Other" option auto-added. `preview` only for single-select. | All user interactions — context gathering, resource selection, clarifications, proposals, next steps |
| **EnterPlanMode** | Requires user approval to enter | Used in Path B/C to transition from brainstorming to implementation planning |
| **ExitPlanMode** | Reads plan from plan file, signals ready for review | Used after writing the implementation plan in plan mode |

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

**Call 1 — 3 questions:**

```
AskUserQuestion({
  questions: [
    {
      question: "What is the current state or situation right now?",
      header: "Current",
      options: [
        { label: "Greenfield", description: "Starting from scratch, no existing implementation" },
        { label: "Existing code", description: "Building on or modifying existing functionality" },
        { label: "Broken/buggy", description: "Something exists but isn't working correctly" }
      ],
      multiSelect: false
    },
    {
      question: "What is the desired outcome or objective?",
      header: "Objective",
      options: [
        { label: "New feature", description: "Add entirely new functionality" },
        { label: "Improvement", description: "Enhance or optimize existing behavior" },
        { label: "Fix/resolve", description: "Fix a bug, incident, or compliance issue" }
      ],
      multiSelect: false
    },
    {
      question: "Who will own this task and what is their role?",
      header: "Owner",
      options: [
        { label: "Me (dev)", description: "I'm implementing this myself" },
        { label: "My team", description: "Shared ownership across a team" },
        { label: "Handoff", description: "I'm designing for someone else to implement" }
      ],
      multiSelect: false
    }
  ]
})
```

**Call 2 — 2 questions (after user replies to Call 1):**

```
AskUserQuestion({
  questions: [
    {
      question: "What format or structure should the output take?",
      header: "Output",
      options: [
        { label: "Design doc", description: "Written spec with architecture details" },
        { label: "Diagram", description: "Visual diagram (sequence, flowchart, etc.)" },
        { label: "Code plan", description: "Step-by-step implementation plan" },
        { label: "All of above", description: "Comprehensive output with doc, diagram, and plan" }
      ],
      multiSelect: true
    },
    {
      question: "What limits or constraints should be respected?",
      header: "Constraints",
      options: [
        { label: "Time-boxed", description: "Must be completed within a tight deadline" },
        { label: "Tech stack", description: "Must use specific technologies or patterns" },
        { label: "Backward compat", description: "Must not break existing behavior" },
        { label: "Minimal scope", description: "Keep it as simple as possible (YAGNI)" }
      ],
      multiSelect: true
    }
  ]
})
```

After both replies, summarize context in 1–2 lines.

**TaskUpdate**: Mark task 1 as `completed`.

---

### [1. Spike] — Spike & Gather Context

**TaskUpdate**: Mark task 2 as `in_progress`.

- Autonomously explore the project: scan files, docs, recent commits, existing patterns, modules, APIs, configs.
- Compile a list of relevant existing resources.
- Present findings as a structured list (related modules, similar features, relevant configs, API contracts).
- Ask the user which resources to reference or explore deeper:

```
AskUserQuestion({
  questions: [{
    question: "Which of these existing resources should we reference or explore deeper?",
    header: "Resources",
    options: [
      // Dynamically generated from spike findings, max 4 options
      // Group related resources if more than 4 found
      { label: "<Resource group 1>", description: "<What it contains>" },
      { label: "<Resource group 2>", description: "<What it contains>" },
      { label: "All of them", description: "Reference everything found" },
      { label: "None needed", description: "Proceed without referencing existing resources" }
    ],
    multiSelect: true
  }]
})
```

- If user picks specific resources, dig into those before continuing.
- If user picks "None needed", proceed with findings as baseline context.

**TaskUpdate**: Mark task 2 as `completed`.

---

### [2. Clarify] — Asking Clarifying Questions

**TaskUpdate**: Mark task 3 as `in_progress`.

- Ask questions **one at a time** to refine the idea using **AskUserQuestion**.
- Prefer multiple choice options when possible; open-ended is fine too.
- Only **one question per message** (one AskUserQuestion call).
- Focus on: purpose, constraints, success criteria.
- Continue until you have enough clarity to propose solutions (typically 2–4 questions).

Example:
```
AskUserQuestion({
  questions: [{
    question: "How should errors be handled in this flow?",
    header: "Errors",
    options: [
      { label: "Fail fast", description: "Stop immediately and surface the error" },
      { label: "Retry + fallback", description: "Retry with exponential backoff, then fallback" },
      { label: "Silent log", description: "Log the error but continue processing" }
    ],
    multiSelect: false
  }]
})
```

**TaskUpdate**: Mark task 3 as `completed`.

---

### [3. Propose] — Evaluate Complexity & Propose Solutions

**TaskUpdate**: Mark task 4 as `in_progress`.

First, ask the user to evaluate complexity:

```
AskUserQuestion({
  questions: [{
    question: "How would you characterize this task's complexity?",
    header: "Complexity",
    options: [
      { label: "Complex", description: "Multiple valid approaches, architectural decisions, ambiguous scope" },
      { label: "Simple", description: "Clear requirements, single obvious path forward" }
    ],
    multiSelect: false
  }]
})
```

#### Complex tasks

Propose 2–3 solutions with trade-offs. Use the **`preview`** field to show architecture or code structure side-by-side so the user can visually compare approaches:

```
AskUserQuestion({
  questions: [{
    question: "Which solution approach do you prefer?",
    header: "Approach",
    options: [
      {
        label: "Option A (Recommended)",
        description: "Brief trade-off summary",
        preview: "## Architecture\n\n```\nComponent A → Service B → DB\n         ↘ Cache Layer\n```\n\n**Pros:** Fast, simple\n**Cons:** Cache invalidation complexity"
      },
      {
        label: "Option B",
        description: "Brief trade-off summary",
        preview: "## Architecture\n\n```\nComponent A → Queue → Worker → DB\n```\n\n**Pros:** Decoupled, resilient\n**Cons:** Added latency, more infra"
      },
      {
        label: "Option C",
        description: "Brief trade-off summary",
        preview: "## Architecture\n\n```\nComponent A → Event Bus → Multiple Consumers\n```\n\n**Pros:** Scalable, extensible\n**Cons:** Eventual consistency, debugging harder"
      }
    ],
    multiSelect: false
  }]
})
```

#### Simple/clear tasks

- Summarize the single approach.
- Ask user to confirm:

```
AskUserQuestion({
  questions: [{
    question: "Does this approach look right, or do we need to revisit?",
    header: "Confirm",
    options: [
      { label: "Looks good", description: "Proceed with this approach" },
      { label: "Need changes", description: "Go back and clarify further" }
    ],
    multiSelect: false
  }]
})
```

- If "Need changes", loop back to [2. Clarify].

**TaskUpdate**: Mark task 4 as `completed`.

---

### [4. Final] — What's Next?

**TaskUpdate**: Mark task 5 as `in_progress`.

After user confirms a solution, ask them to pick next steps:

```
AskUserQuestion({
  questions: [{
    question: "What would you like to do with this design?",
    header: "Next steps",
    options: [
      { label: "Summary only", description: "Get a written summary of the solution, no code" },
      { label: "Implement", description: "Move to Plan mode and start implementation planning" },
      { label: "Both", description: "Get the summary first, then move to implementation" }
    ],
    multiSelect: false
  }]
})
```

#### Path A — Summary only

1. Write a concise text summary of the chosen solution.
2. Ask about diagram:

```
AskUserQuestion({
  questions: [{
    question: "Would you like a visual diagram of the solution?",
    header: "Diagram",
    options: [
      { label: "Sequence diagram", description: "Show the flow of interactions between components" },
      { label: "Flowchart", description: "Show the decision logic and process flow" },
      { label: "Architecture", description: "Show the high-level component relationships" },
      { label: "No diagram", description: "Text summary is sufficient" }
    ],
    multiSelect: false
  }]
})
```

- If a diagram type is selected, generate it following project diagram rules.
- If "No diagram", ask about export:

```
AskUserQuestion({
  questions: [{
    question: "Export the summary to a specific format?",
    header: "Export",
    options: [
      { label: "Markdown file", description: "Save as .md file in the project" },
      { label: "Notion", description: "Export to Notion page" },
      { label: "No thanks", description: "Keep it in the conversation only" }
    ],
    multiSelect: false
  }]
})
```

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
