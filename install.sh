#!/usr/bin/env bash
set -euo pipefail

HKIT_DIR="$( cd "$(dirname "$0")" && pwd )"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
FORCE=false

for arg in "$@"; do
  [ "$arg" = "--force" ] && FORCE=true
done

info()    { echo "  [hkit] $*"; }
success() { echo "✓ [hkit] $*"; }
skip()    { echo "- [hkit] $* (skipped)"; }

symlink() {
  local src="$1" dst="$2" label="$3"
  if [ "$FORCE" = false ] && [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    skip "$label symlink"
    return
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    rm -rf "$dst"
  elif [ -L "$dst" ]; then
    rm "$dst"
  fi
  ln -s "$src" "$dst"
  success "$label → $src"
}

echo ""
echo "Installing hkit from: $HKIT_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

symlink "$HKIT_DIR/skills" "$CLAUDE_DIR/skills" "skills"

echo ""
success "hkit install complete."
