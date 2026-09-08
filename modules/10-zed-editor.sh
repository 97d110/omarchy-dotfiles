#!/usr/bin/env bash
# Zed Editor: install it via Omarchy, then expose it on PATH as `zed`.
#
# Zed is load-bearing here, not optional: the SUPER+SHIFT+Z binding, the
# "Edit .bashrc" Omarchy menu entry, the bashme.desktop launcher and the
# `bashme` shell alias all invoke `zed`. Without it they silently do nothing.
#
# `omarchy install editor zed` is the canonical path - it installs the `zed`
# and `omazed` packages and runs `omazed setup` to apply the current Omarchy
# theme, which a bare `pacman -S zed` would not do. Note it also launches the
# Zed GUI once when it finishes; that only happens on a genuinely fresh
# install, since this is guarded on the binary being absent.
#
# The Arch `zed` package ships its CLI as /usr/bin/zeditor, so the shim below
# is still needed afterwards - Omarchy does not create a `zed` name itself.
set -uo pipefail

BIN_DIR="$HOME/.local/bin"

shim_zed() {
  mkdir -p "$BIN_DIR"
  ln -sf /usr/bin/zeditor "$BIN_DIR/zed"
  echo "zed -> /usr/bin/zeditor shimmed at $BIN_DIR/zed"
}

if command -v zeditor >/dev/null 2>&1; then
  shim_zed
  exit 0
fi

if ! command -v omarchy >/dev/null 2>&1; then
  echo "zed not installed and omarchy is absent - install it manually:"
  echo "  sudo pacman -S --needed zed omazed"
  exit 0
fi

# Installing needs root. Only attempt it when privileges are actually
# obtainable: passwordless sudo, or a terminal that can answer the prompt.
# Otherwise (cron, a CI run, an agent session) print the command instead of
# hanging on a prompt nobody can see.
if sudo -n true 2>/dev/null || [ -t 0 ]; then
  echo "zed not installed - installing via omarchy (needs sudo; opens Zed once when done)"
  if omarchy install editor zed; then
    if command -v zeditor >/dev/null 2>&1; then
      shim_zed
    else
      echo "omarchy reported success but /usr/bin/zeditor is still missing"
      exit 1
    fi
  else
    echo "FAILED to install zed. Retry with:"
    echo "  omarchy install editor zed"
    exit 1
  fi
else
  echo "zed not installed, and this session cannot prompt for sudo. Install with:"
  echo "  omarchy install editor zed"
fi
