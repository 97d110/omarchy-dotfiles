#!/usr/bin/env bash
# The DualSense controller's touchpad shows up to libinput as a regular
# pointer device, so moving a thumb across it drags the mouse cursor around
# the desktop - including while a game is reading the touchpad directly for
# its own purposes. A udev rule tagging that specific HID interface with
# LIBINPUT_IGNORE_DEVICE=1 makes libinput ignore it, without touching the
# controller's separate gamepad/motion-sensor interfaces on the same device.
#
# This file lives outside $HOME, so it can't go through the files/ + symlink
# convention in 00-link-files.sh - it's copied into place with sudo instead.
set -uo pipefail

SRC="$(dirname "${BASH_SOURCE[0]}")/../files/etc/udev/rules.d/91-dualsense-touchpad-no-mouse.rules"
DEST="/etc/udev/rules.d/91-dualsense-touchpad-no-mouse.rules"

if [[ -f "$DEST" ]] && cmp -s "$SRC" "$DEST"; then
  echo "DualSense touchpad udev rule OK: $DEST matches repo"
  exit 0
fi

if sudo -n true 2>/dev/null || [ -t 0 ]; then
  sudo install -m 644 "$SRC" "$DEST" && sudo udevadm control --reload
  echo "Installed DualSense touchpad udev rule to $DEST"
  echo "Replug the controller (or reboot) for it to take effect if it's already connected"
else
  echo "DualSense touchpad udev rule needs installing - run:"
  echo "  sudo install -m 644 \"$SRC\" \"$DEST\""
  echo "  sudo udevadm control --reload"
  exit 0
fi
