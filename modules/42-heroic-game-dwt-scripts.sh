#!/usr/bin/env bash
# Wires every installed Heroic game up to toggle touchpad dwt (disable-while-
# typing) around its play session, via Heroic's native beforeLaunchScriptPath/
# afterLaunchScriptPath per-game hooks.
#
# Why: dwt (Hyprland's default, palm-rejection while typing) blocks touchpad
# camera-look in games whenever WASD is held. Rather than turning dwt off
# permanently (files/config/hypr/input.lua keeps Hyprland's default: enabled),
# heroic-game-start/heroic-game-end (files/local/bin/, linked by
# 00-link-files.sh into ~/.local/bin) flip it off/on live for the duration of
# whatever game Heroic is running.
#
# Heroic doesn't pass any game-identifying info to these scripts, so a single
# shared pair works for every game; this module points every installed game's
# config at that shared pair.
#
# Idempotent and GUI-safe: a game config is only touched when BOTH script
# fields are currently empty. If the user has customized either field
# (through Heroic's own GUI or otherwise), this module leaves that game alone
# forever after - it never overwrites a value it didn't set.
set -uo pipefail

GAMES_CONFIG_DIR="$HOME/.config/heroic/GamesConfig"
START_SCRIPT="$HOME/.local/bin/heroic-game-start"
END_SCRIPT="$HOME/.local/bin/heroic-game-end"

if [ ! -d "$GAMES_CONFIG_DIR" ]; then
  echo "no $GAMES_CONFIG_DIR - Heroic not installed/used yet, nothing to do"
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found - cannot edit Heroic game configs, skipping"
  exit 0
fi

shopt -s nullglob
configs=("$GAMES_CONFIG_DIR"/*.json)
shopt -u nullglob

if [ "${#configs[@]}" -eq 0 ]; then
  echo "no *.json files in $GAMES_CONFIG_DIR - no games installed yet"
  exit 0
fi

updated=0
skipped=0
status=0

for config in "${configs[@]}"; do
  app_name="$(basename "$config" .json)"
  file="$(basename "$config")"

  if ! jq -e --arg app "$app_name" 'has($app)' "$config" >/dev/null 2>&1; then
    echo "skipped $file: no \"$app_name\" key (unexpected shape)"
    skipped=$((skipped + 1))
    continue
  fi

  before="$(jq -r --arg app "$app_name" '.[$app].beforeLaunchScriptPath // ""' "$config")"
  after="$(jq -r --arg app "$app_name" '.[$app].afterLaunchScriptPath // ""' "$config")"

  if [ -n "$before" ] || [ -n "$after" ]; then
    echo "skipped $file: already customized (beforeLaunchScriptPath/afterLaunchScriptPath not both empty)"
    skipped=$((skipped + 1))
    continue
  fi

  tmp="$config.tmp.$$"
  if jq --arg app "$app_name" --arg start "$START_SCRIPT" --arg end "$END_SCRIPT" \
      '.[$app].beforeLaunchScriptPath = $start | .[$app].afterLaunchScriptPath = $end' \
      "$config" > "$tmp" && chmod --reference="$config" "$tmp" && mv "$tmp" "$config"; then
    echo "updated $file: wired to heroic-game-start/heroic-game-end"
    updated=$((updated + 1))
  else
    echo "FAILED to update $file"
    rm -f "$tmp"
    status=1
  fi
done

echo "heroic dwt scripts: $updated updated, $skipped skipped (already customized)"
exit "$status"
