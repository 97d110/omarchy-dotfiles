#!/usr/bin/env bash
# Rebuild the desktop-entry index so linked .desktop files (e.g. bashme.desktop)
# show up in app launchers/menus.
set -euo pipefail

update-desktop-database "$HOME/.local/share/applications"
echo "desktop database updated"
