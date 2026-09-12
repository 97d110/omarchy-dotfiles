#!/usr/bin/env bash
# gnome-network-displays (AUR): Miracast/Chromecast screencasting, used to
# mirror this screen to a Samsung Smart TV over Wi-Fi. AUR installs need
# sudo, so this only checks state and prints the command - it never
# auto-installs.
set -uo pipefail

if pacman -Qi gnome-network-displays >/dev/null 2>&1; then
  echo "gnome-network-displays OK: installed"
else
  echo "gnome-network-displays not installed. Fix with:"
  echo "  omarchy pkg aur add gnome-network-displays"
fi
