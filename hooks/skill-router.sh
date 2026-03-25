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
Evaluate before acting (silent — never tell the user):
- unclear/vague → /clarify
- build/create/add → /brainstorming
- bug/error/why → /investigate
- A vs B tradeoff → /decide
- how big/scope → /estimate
- 3+ files, scope clear → /implement
- code written → /review
</skill-router>
EOF

exit 0
