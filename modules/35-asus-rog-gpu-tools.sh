#!/usr/bin/env bash
# ASUS ROG Strix G16 (G614FR): asusd ships in the base Omarchy install, but
# the GUI, hybrid-GPU switching daemon, and NVIDIA's own control panel are
# optional deps that don't get pulled in automatically. Package installs and
# systemctl enable need sudo, so this only checks state and prints what to
# run - it never auto-installs or auto-enables.
set -uo pipefail

# shellcheck source=lib/hardware.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/hardware.sh"

if ! is_asus_laptop; then
  echo "not an ASUS laptop - skipping ASUS ROG / NVIDIA GUI tools"
  exit 0
fi

PACKAGES=(rog-control-center supergfxctl nvidia-settings)
missing=()
for pkg in "${PACKAGES[@]}"; do
  pacman -Qi "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Missing ASUS ROG / NVIDIA GUI packages: ${missing[*]}"
  echo "  sudo pacman -S ${missing[*]}"
else
  echo "ASUS ROG / NVIDIA GUI packages OK: ${PACKAGES[*]}"
fi

if systemctl is-enabled supergfxd >/dev/null 2>&1; then
  echo "supergfxd service OK: enabled"
else
  echo "supergfxd service not enabled. Fix with: sudo systemctl enable --now supergfxd"
fi
