#!/usr/bin/env bash
# Keeps the always-on Claude Code rules in files/home/.claude/rules/ live.
#
# Claude Code loads every *.md in ~/.claude/rules/ at the start of every
# session, in every project ("user-level rules"). So the rule files are plain
# config: 00-link-files.sh symlinks them into ~/.claude/rules/, and that
# symlink IS the activation. Nothing needs importing or registering.
#
# What still needs doing imperatively:
#   1. Prove the activation happened. A rule that silently fails to load looks
#      exactly like a rule Claude is ignoring, which is very hard to diagnose.
#   2. Drop stale links. 00-link-files.sh creates links but never removes them,
#      so a renamed or deleted rule leaves a dangling symlink behind that
#      Claude Code would still try to read.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULES_DIR="$REPO_DIR/files/home/.claude/rules"
LIVE_DIR="$HOME/.claude/rules"

if [ ! -d "$RULES_DIR" ]; then
  echo "no rules directory at $RULES_DIR - nothing to activate"
  exit 0
fi

# The glob is already lexicographic, which is the order the numbered filenames
# are meant to be read in.
shopt -s nullglob
rules=()
for path in "$RULES_DIR"/*.md; do
  rules+=("$(basename "$path")")
done

# A dangling link whose target is inside this repo was left by an earlier
# install, when the rule still existed under that name. Anything pointing
# elsewhere is not this module's to touch.
for live in "$LIVE_DIR"/*; do
  [ -L "$live" ] || continue
  [ -e "$live" ] && continue
  target="$(readlink "$live")"
  case "$target" in
    "$REPO_DIR"/*)
      rm -f "$live"
      echo "removed stale rule link: ~/.claude/rules/$(basename "$live") (target gone: $target)"
      ;;
  esac
done
shopt -u nullglob

if [ "${#rules[@]}" -eq 0 ]; then
  echo "no rule files in $RULES_DIR - nothing to activate"
  exit 0
fi

status=0
for rule in "${rules[@]}"; do
  live="$LIVE_DIR/$rule"
  if [ -L "$live" ] && [ "$(readlink "$live")" = "$RULES_DIR/$rule" ]; then
    echo "active: ~/.claude/rules/$rule"
  else
    echo "NOT ACTIVE: ~/.claude/rules/$rule - not linked; rerun 00-link-files.sh"
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  echo "${#rules[@]} rule(s) load in every session - confirm with /context"
fi

exit "$status"
