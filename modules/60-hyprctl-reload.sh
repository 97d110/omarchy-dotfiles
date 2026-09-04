#!/usr/bin/env bash
# On a fresh clone the hypr config files were just created (not "saved" via
# an editor), so Hyprland's autoreload-on-save never fired. Force it once.
set -uo pipefail

if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors >/dev/null 2>&1; then
  hyprctl reload
  errors="$(hyprctl configerrors)"
  if [ -n "$errors" ] && [ "$errors" != "ok" ]; then
    echo "hyprctl configerrors reported issues:"
    echo "$errors"
    exit 1
  fi
  echo "hyprland config reloaded cleanly"
else
  echo "hyprctl not available (not running Hyprland?) - skipping reload"
fi
