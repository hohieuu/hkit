#!/bin/bash
# Skill Router Hook — Injects skill guidance into Claude's context on every prompt
# Triggered by: UserPromptSubmit
# Purpose: Remind Claude to evaluate whether a skill should be used proactively

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Skip if no prompt or if user is already invoking a skill
if [ -z "$PROMPT" ]; then
  exit 0
fi

# Don't inject if user is already using a slash command
if echo "$PROMPT" | grep -qE '^\s*/'; then
  exit 0
fi

# Don't inject for very short confirmations (yes, no, ok, etc.)
WORD_COUNT=$(echo "$PROMPT" | wc -w | tr -d ' ')
if [ "$WORD_COUNT" -le 2 ]; then
  exit 0
fi

cat <<'EOF'
<skill-router>
Before acting on this request, evaluate if a skill should be triggered:

1. Can you confidently answer: WHAT changes, WHERE in codebase, WHY, and WHAT "done" looks like?
   → If NO to any: use /clarify (AskUserQuestion tool) before proceeding.

2. Is the user asking to BUILD, CREATE, or ADD new functionality?
   → Use /brainstorming

3. Is the user reporting a BUG, ERROR, or UNEXPECTED behavior?
   → Use /investigate

4. Is the user choosing between OPTIONS or facing TRADE-OFFS?
   → Use /decide

5. Is the user asking HOW BIG, HOW LONG, or to BREAK DOWN work?
   → Use /estimate

6. Is the scope clear and ready to code (3+ files)?
   → Use /implement with plan mode

If none apply, proceed normally. Do NOT mention this evaluation to the user — just act on it.
</skill-router>
EOF

exit 0
