#!/usr/bin/env bash
# Heroic Games Launcher (heroic-games-launcher-bin): install the package
# itself. bebski-go only - it's the gaming laptop; bebski-home doesn't game
# and shouldn't get a gaming-specific package pulled in.
#
# Runs before 42 (which wires every installed Heroic game's dwt toggle via
# beforeLaunchScriptPath/afterLaunchScriptPath) since installing the package
# should logically precede configuring it, even though 42 already tolerates
# Heroic being absent.
#
# `omarchy install gaming heroic` is the canonical path here, same reasoning
# as modules/10-zed-editor.sh: it wraps `pacman -S` in Omarchy's own
# idempotent pkg-add helper and also pulls in the gpu-lib32 drivers Heroic
# needs, which a bare `pacman -S heroic-games-launcher-bin` would skip. It
# also launches Heroic once when it finishes, so this is gated on the
# package being absent - never rerun once installed.
set -uo pipefail

if [ "$(hostname)" != "bebski-go" ]; then
  exit 0
fi

if pacman -Qi heroic-games-launcher-bin >/dev/null 2>&1; then
  echo "heroic-games-launcher-bin OK: installed"
  exit 0
fi

if ! command -v omarchy >/dev/null 2>&1; then
  echo "heroic-games-launcher-bin not installed and omarchy is absent - install it manually:"
  echo "  sudo pacman -S --needed heroic-games-launcher-bin"
  exit 0
fi

# Installing needs root. Only attempt it when privileges are actually
# obtainable: passwordless sudo, or a terminal that can answer the prompt.
# Otherwise (cron, a CI run, an agent session) print the command instead of
# hanging on a prompt nobody can see.
if sudo -n true 2>/dev/null || [ -t 0 ]; then
  echo "heroic-games-launcher-bin not installed - installing via omarchy (needs sudo; also pulls in gpu-lib32 drivers and launches Heroic once when done)"
  if omarchy install gaming heroic; then
    if pacman -Qi heroic-games-launcher-bin >/dev/null 2>&1; then
      echo "heroic-games-launcher-bin installed"
    else
      echo "omarchy reported success but heroic-games-launcher-bin is still missing"
      exit 1
    fi
  else
    echo "FAILED to install heroic-games-launcher-bin. Retry with:"
    echo "  omarchy install gaming heroic"
    exit 1
  fi
else
  echo "heroic-games-launcher-bin not installed, and this session cannot prompt for sudo. Install with:"
  echo "  omarchy install gaming heroic"
fi
