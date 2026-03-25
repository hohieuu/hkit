#!/usr/bin/env bash
# Unit tests for install.sh
# Mocks ~/.claude/ to tests/mock_claude/ — never touches your real config.

set -euo pipefail

HKIT_DIR="$( cd "$(dirname "$0")/.." && pwd )"
TEST_DIR="$HKIT_DIR/tests"
MOCK_CLAUDE="$TEST_DIR/mock_claude"

# ─── helpers ────────────────────────────────────────────────────────────────

PASS=0; FAIL=0

pass() { echo "  PASS  $*"; (( PASS++ )) || true; }
fail() { echo "  FAIL  $*"; (( FAIL++ )) || true; }

assert_symlink() {
  local path="$1" expected_target="$2" label="$3"
  if [ -L "$path" ] && [ "$(readlink "$path")" = "$expected_target" ]; then
    pass "$label is symlinked correctly"
  else
    fail "$label — expected symlink to $expected_target, got: $(readlink "$path" 2>/dev/null || echo 'not a symlink')"
  fi
}

assert_file_exists() {
  local path="$1" label="$2"
  if [ -f "$path" ]; then
    pass "$label exists"
  else
    fail "$label not found at $path"
  fi
}

assert_json_contains() {
  local file="$1" query="$2" expected="$3" label="$4"
  local actual
  actual=$(jq -r "$query" "$file" 2>/dev/null || echo "")
  if [ "$actual" = "$expected" ]; then
    pass "$label"
  else
    fail "$label — expected '$expected', got '$actual'"
  fi
}

# ─── setup ──────────────────────────────────────────────────────────────────

setup() {
  rm -rf "$MOCK_CLAUDE"
  mkdir -p "$MOCK_CLAUDE/hooks" "$MOCK_CLAUDE/commands"
  # Simulate an existing settings.json with another hook (e.g. RTK)
  cat > "$MOCK_CLAUDE/settings.json" <<'JSON'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "/usr/local/bin/rtk-rewrite.sh"}]
      }
    ]
  }
}
JSON
}

teardown() {
  rm -rf "$MOCK_CLAUDE"
}

# ─── tests ──────────────────────────────────────────────────────────────────

test_fresh_install() {
  echo ""
  echo "── test: fresh install ──────────────────────────────────────"
  setup

  CLAUDE_DIR="$MOCK_CLAUDE" bash "$HKIT_DIR/install.sh" > /dev/null 2>&1

  assert_symlink "$MOCK_CLAUDE/skills"              "$HKIT_DIR/skills"                    "skills/"
  assert_symlink "$MOCK_CLAUDE/hooks/skill-router.sh" "$HKIT_DIR/hooks/skill-router.sh"   "hooks/skill-router.sh"
  assert_symlink "$MOCK_CLAUDE/commands/brainstorm.md" "$HKIT_DIR/commands/brainstorm.md" "commands/brainstorm.md"

  assert_file_exists "$MOCK_CLAUDE/settings.json" "settings.json"
  assert_json_contains "$MOCK_CLAUDE/settings.json" \
    ".hooks.UserPromptSubmit[0].hooks[0].command" \
    "$HKIT_DIR/hooks/skill-router.sh" \
    "skill-router registered in UserPromptSubmit"
  assert_json_contains "$MOCK_CLAUDE/settings.json" \
    ".hooks.PreToolUse[0].hooks[0].command" \
    "/usr/local/bin/rtk-rewrite.sh" \
    "existing PreToolUse hook preserved"
}

test_idempotent() {
  echo ""
  echo "── test: idempotent (run twice) ─────────────────────────────"
  setup

  CLAUDE_DIR="$MOCK_CLAUDE" bash "$HKIT_DIR/install.sh" > /dev/null 2>&1
  CLAUDE_DIR="$MOCK_CLAUDE" bash "$HKIT_DIR/install.sh" > /dev/null 2>&1

  assert_symlink "$MOCK_CLAUDE/skills" "$HKIT_DIR/skills" "skills/ still correct after second run"

  local hook_count
  hook_count=$(jq '.hooks.UserPromptSubmit | length' "$MOCK_CLAUDE/settings.json")
  if [ "$hook_count" -eq 1 ]; then
    pass "skill-router not duplicated in settings.json (count=$hook_count)"
  else
    fail "skill-router duplicated — expected 1 entry, got $hook_count"
  fi
}

test_backup_existing_skills() {
  echo ""
  echo "── test: backs up existing skills/ dir ─────────────────────"
  setup
  mkdir -p "$MOCK_CLAUDE/skills/old-skill"
  echo "old" > "$MOCK_CLAUDE/skills/old-skill/SKILL.md"

  CLAUDE_DIR="$MOCK_CLAUDE" bash "$HKIT_DIR/install.sh" > /dev/null 2>&1

  assert_symlink "$MOCK_CLAUDE/skills" "$HKIT_DIR/skills" "skills/ replaced with symlink"

  local backup
  backup=$(ls "$MOCK_CLAUDE" | grep "skills.bak" || true)
  if [ -n "$backup" ]; then
    pass "backup created: $backup"
  else
    fail "no backup found for existing skills/ dir"
  fi
}

test_no_existing_settings() {
  echo ""
  echo "── test: no existing settings.json ─────────────────────────"
  rm -rf "$MOCK_CLAUDE"
  mkdir -p "$MOCK_CLAUDE/hooks" "$MOCK_CLAUDE/commands"
  # No settings.json

  CLAUDE_DIR="$MOCK_CLAUDE" bash "$HKIT_DIR/install.sh" > /dev/null 2>&1

  assert_file_exists "$MOCK_CLAUDE/settings.json" "settings.json created from scratch"
  assert_json_contains "$MOCK_CLAUDE/settings.json" \
    ".hooks.UserPromptSubmit[0].hooks[0].command" \
    "$HKIT_DIR/hooks/skill-router.sh" \
    "skill-router registered in new settings.json"
}

# ─── run all ────────────────────────────────────────────────────────────────

echo ""
echo "hkit install.sh tests"
echo "HKIT_DIR: $HKIT_DIR"
echo "MOCK_CLAUDE: $MOCK_CLAUDE"

test_fresh_install
test_idempotent
test_backup_existing_skills
test_no_existing_settings

teardown

echo ""
echo "────────────────────────────────"
echo "Results: $PASS passed, $FAIL failed"
echo "────────────────────────────────"
echo ""

[ "$FAIL" -eq 0 ]
