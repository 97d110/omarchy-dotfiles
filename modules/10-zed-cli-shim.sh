#!/usr/bin/env bash
# The Arch `zed` package ships its CLI as /usr/bin/zeditor. Shim it to `zed`
# so `zed <path>` works, matching upstream Zed's convention.
set -euo pipefail

if ! command -v zeditor >/dev/null 2>&1; then
  echo "zeditor not installed (pacman -Q zed) - skipping zed shim"
  exit 0
fi

mkdir -p "$HOME/.local/bin"
ln -sf /usr/bin/zeditor "$HOME/.local/bin/zed"
echo "zed -> /usr/bin/zeditor shimmed at ~/.local/bin/zed"
