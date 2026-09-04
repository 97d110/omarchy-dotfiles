#!/usr/bin/env bash
# Registers this repo's Claude Code skill globally, and points the global
# CLAUDE.md at it, so any session on this machine (not just ones opened
# inside this repo) follows the omarchy-dotfiles workflow.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/.claude/skills"
ln -sfn "$REPO_DIR/.claude/skills/omarchy-dotfiles" "$HOME/.claude/skills/omarchy-dotfiles"
echo "skill linked: ~/.claude/skills/omarchy-dotfiles -> $REPO_DIR/.claude/skills/omarchy-dotfiles"

MARKER="<!-- omarchy-dotfiles -->"
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude"
touch "$GLOBAL_CLAUDE_MD"

if ! grep -qF "$MARKER" "$GLOBAL_CLAUDE_MD"; then
  {
    echo ""
    echo "$MARKER"
    echo "This machine's Omarchy/Hyprland/shell/git/ssh/gh config is tracked in"
    echo "~/Work/omarchy-dotfiles. Use the omarchy-dotfiles skill whenever making"
    echo "a persistent config change on this machine."
  } >> "$GLOBAL_CLAUDE_MD"
  echo "pointer added to $GLOBAL_CLAUDE_MD"
else
  echo "pointer already present in $GLOBAL_CLAUDE_MD"
fi
