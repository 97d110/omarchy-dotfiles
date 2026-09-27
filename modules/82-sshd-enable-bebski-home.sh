#!/usr/bin/env bash
# Enable and start the system SSH daemon so bebski-go can reach this machine
# over the LAN (browsing/copying files, e.g. qBittorrent's `software`
# category save path). bebski-home only - the dev laptop has no reason to
# accept inbound SSH.
set -euo pipefail

if [ "$(hostname)" != "bebski-home" ]; then
  exit 0
fi

sudo systemctl enable --now sshd.service
echo "sshd.service enabled and running"
