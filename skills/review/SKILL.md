---
name: review
description: >-
  Generic interactive review skill. Adapts to what's being reviewed — code,
  spec, design, plan, or config. Builds the task list based on review type.
  For code: scoring + checklist + fix suggestions + commit wrap-up.
  For non-code: completeness, clarity, feasibility checks + action items.
---

# Review — Interactive Review

**Skill identity:** Prefix every text response with `👀 [review]` so the user always knows which skill is active.

Adapts the review process based on *what* is being reviewed. Ask first, build tasks second.

**AskUserQuestion constraints:** max 4 questions/call · 2–4 options each · header ≤12 chars · use preview for before/after comparisons.

---

## Step 0 — Identify Review Type

**First question, always:**

- **Type** (single): Code changes / Spec or design / Plan or tasks / Config or infra

Then branch into the matching flow below.

---

## Path A — Code Review

### Initialization

Ask:
- **Scope** (single): Unstaged changes (Recommended) / Staged changes / Last commit / Specific files
- **Focus** (multi): All (Recommended) / Correctness only / Security / Performance

Create tasks:
- "Review correctness"
- "Review security" *(if selected)*
- "Review performance" *(if selected)*
- "Score & present findings"
- "Wrap-up"

---

### [A1] Analyze Categories

For each review category task:
1. **TaskUpdate** → `in_progress`
2. Read all changed files thoroughly
3. Analyze against the checklist for that category
4. Collect findings
5. **TaskUpdate** → `completed`

---

### [A2] Score — Code Approval Score

Compute a **Code Approval Score (0–100%)** using this checklist:

#### Correctness
- [ ] No logic bugs or off-by-one errors
- [ ] Error paths handled and propagated correctly
- [ ] Nil / null / zero-value edge cases handled
- [ ] No silent failures (errors swallowed without log)
- [ ] Interface contracts satisfied (all methods implemented)

#### Security
- [ ] No injection vectors (SQL, shell, template)
- [ ] No secrets or credentials in code
- [ ] No unsafe type assertions or unchecked casts
- [ ] External input validated at system boundaries

#### Performance
- [ ] No unnecessary allocations in hot paths
- [ ] No N+1 query patterns
- [ ] No blocking calls without timeout/context

#### Code quality
- [ ] No dead code or unused variables/imports
- [ ] Naming consistent with codebase conventions
- [ ] No premature abstraction or over-engineering

Output the score and rationale.

**⛔ SCORE < 90% (REJECTED):**
- List specific issues
- Output: "⚠️ High risk of rejection by human reviewers."
- STOP — wait for user acknowledgement before proceeding

**✅ SCORE ≥ 90% (APPROVED):**
- List minor improvements to reach 100%
- Proceed to [A3]

---

### [A3] Findings — Present with Previews

**TaskUpdate** → `in_progress` on "Score & present findings"

Group by severity. Use **preview** for before/after code:

**Critical** (multi, each with preview): Fix: \<issue\> / Fix all critical

**Suggestions** (multi, each with preview): \<suggestion\> / Apply all / Skip all

If nothing found: **Clean** (single): Run tests (Recommended) / Done

---

### [A4] Apply Fixes

For each selected fix: read → apply → show diff.

After all fixes:

**Next** (single): Run tests (Recommended) / Review again / Done

| User picks | Action |
|-----------|--------|
| Run tests | Run `make test` or equivalent, report results |
| Review again | Loop back to [A1] |
| Done | Proceed to [A5] |

**TaskUpdate** → `completed`

---

### [A5] Wrap-up — Continue or Commit?

**What's next?** (single): Continue coding / Commit changes

- **Continue coding** → end skill, return control to user
- **Commit changes** → remind user to run `/commit` for quality gate + conventional commit

---

## Path B — Spec / Design Review

### Initialization

Create tasks:
- "Review completeness"
- "Review clarity"
- "Review feasibility"
- "Present findings"
- "Wrap-up"

---

### [B1] Analyze

For each task:
1. **TaskUpdate** → `in_progress`
2. Read the spec/design document or description
3. Analyze against checklist:

#### Completeness
- [ ] All requirements/goals stated
- [ ] Edge cases and failure modes addressed
- [ ] Dependencies and integrations identified
- [ ] Out-of-scope explicitly listed

#### Clarity
- [ ] Unambiguous language — no "should", "might", "could"
- [ ] Diagrams or examples where needed
- [ ] Definitions for domain terms

#### Feasibility
- [ ] Technically achievable with current stack
- [ ] No hidden complexity bombs
- [ ] Reasonable scope for stated timeline

4. **TaskUpdate** → `completed`

---

### [B2] Findings

Present issues grouped:

**Blockers** (must resolve before work starts): \<issue\> / Fix all blockers

**Clarifications** (ambiguity to resolve): \<item\> / Resolve all / Skip

If clean: **Clean** (single): Approve / Request changes

---

### [B3] Wrap-up

**What's next?** (single): Continue refining spec / Hand off to implement

- **Continue refining** → end skill
- **Hand off** → remind user to run `/implement`

---

## Path C — Plan / Tasks Review

### Initialization

Create tasks:
- "Review task coverage"
- "Review ordering & dependencies"
- "Present findings"
- "Wrap-up"

---

### [C1] Analyze

#### Coverage checklist
- [ ] All known requirements have at least one task
- [ ] No orphaned tasks (tasks with no clear requirement)
- [ ] Definition of done is clear for each task

#### Order & dependencies
- [ ] Blocking dependencies are sequenced correctly
- [ ] No circular dependencies
- [ ] Critical path is identifiable

---

### [C2] Findings + Wrap-up

Present gaps and misordering. After fixes:

**What's next?** (single): Start implementing / Revise plan

---

## Path D — Config / Infra Review

### Initialization

Create tasks:
- "Review correctness & completeness"
- "Review security"
- "Present findings"
- "Wrap-up"

---

### [D1] Analyze

#### Config correctness
- [ ] No missing required fields
- [ ] Values match expected environment (dev/staging/prod)
- [ ] No hardcoded secrets or tokens
- [ ] Defaults are safe

#### Security
- [ ] Least-privilege principle applied
- [ ] No public exposure of internal endpoints
- [ ] Credentials managed via env/secrets manager

---

### [D2] Findings + Wrap-up

Present issues. After fixes:

**What's next?** (single): Continue / Deploy

---

## Key Principles

- **Ask type first** — never assume code review; branch on what's actually being reviewed.
- **Task list matches the type** — don't create code tasks for a spec review.
- **Score only for code** — checklist scoring is code-path only.
- **Checklist-driven** — justify findings with checklist items, not gut feeling.
- **Preview for code** — always show before/after in preview fields for code fixes.
- **Severity matters** — blockers/critical vs suggestions, always separate.
- **Always wrap up** — every path ends with a "what's next?" question.
- **User decides** — never auto-fix or auto-approve. Present, let user choose.
