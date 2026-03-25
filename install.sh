#!/usr/bin/env bash
# hkit install script
# Creates symlinks from ~/.claude/ to hkit, merges skill-router hook into settings.json
# Safe to run multiple times (idempotent).

set -euo pipefail

HKIT_DIR="$( cd "$(dirname "$0")" && pwd )"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
DATE=$(date +%Y%m%d)

# ─── helpers ────────────────────────────────────────────────────────────────

info()    { echo "  [hkit] $*"; }
success() { echo "✓ [hkit] $*"; }
skip()    { echo "- [hkit] $* (skipped — already set up)"; }
warn()    { echo "! [hkit] $*"; }

symlink() {
  local src="$1" dst="$2" label="$3"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    skip "$label symlink exists"
    return
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    info "Backing up existing $label → ${dst}.bak.${DATE}"
    mv "$dst" "${dst}.bak.${DATE}"
  elif [ -L "$dst" ]; then
    info "Replacing stale symlink for $label"
    rm "$dst"
  fi
  ln -s "$src" "$dst"
  success "$label → $src"
}

# ─── pre-flight ─────────────────────────────────────────────────────────────

if ! command -v jq &>/dev/null; then
  warn "jq not found — settings.json merge will be skipped."
  warn "Install jq (brew install jq) and re-run to complete setup."
  JQ_AVAILABLE=false
else
  JQ_AVAILABLE=true
fi

echo ""
echo "Installing hkit from: $HKIT_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# ─── 1. skills directory ────────────────────────────────────────────────────

symlink "$HKIT_DIR/skills" "$CLAUDE_DIR/skills" "skills/"

# ─── 2. skill-router hook ───────────────────────────────────────────────────

mkdir -p "$CLAUDE_DIR/hooks"
symlink "$HKIT_DIR/hooks/skill-router.sh" "$CLAUDE_DIR/hooks/skill-router.sh" "hooks/skill-router.sh"

# ─── 3. brainstorm command ──────────────────────────────────────────────────

mkdir -p "$CLAUDE_DIR/commands"
symlink "$HKIT_DIR/commands/brainstorm.md" "$CLAUDE_DIR/commands/brainstorm.md" "commands/brainstorm.md"

# ─── 4. merge skill-router into settings.json ───────────────────────────────

SETTINGS="$CLAUDE_DIR/settings.json"

if [ "$JQ_AVAILABLE" = true ]; then
  # Build the hook entry with the real hkit path
  HOOK_ENTRY=$(jq -n \
    --arg cmd "$HKIT_DIR/hooks/skill-router.sh" \
    '{hooks: [{type: "command", command: $cmd}]}')

  if [ ! -f "$SETTINGS" ]; then
    info "No settings.json found — creating one."
    echo '{}' > "$SETTINGS"
  fi

  # Check if skill-router is already present
  EXISTING=$(jq --arg cmd "$HKIT_DIR/hooks/skill-router.sh" \
    '[.hooks.UserPromptSubmit[]?.hooks[]? | select(.command == $cmd)] | length' \
    "$SETTINGS" 2>/dev/null || echo "0")

  if [ "$EXISTING" -gt 0 ]; then
    skip "skill-router already in settings.json"
  else
    cp "$SETTINGS" "${SETTINGS}.bak.${DATE}"
    jq --argjson entry "$HOOK_ENTRY" \
      '.hooks.UserPromptSubmit = ((.hooks.UserPromptSubmit // []) + [$entry])' \
      "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
    success "Merged skill-router hook into settings.json"
  fi
fi

# ─── 5. CLAUDE.md reminder ──────────────────────────────────────────────────

echo ""
echo "─────────────────────────────────────────────────────────"
echo "One manual step: add this line to ~/.claude/CLAUDE.md:"
echo ""
echo "  @$HKIT_DIR/CLAUDE.md"
echo ""
echo "This loads the skill workflow rules into every Claude session."
echo "─────────────────────────────────────────────────────────"
echo ""
success "hkit install complete."
