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

if command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -q "^Status: active"; then
  if sudo ufw status | grep -qE "^22(/tcp)?\s"; then
    echo "ufw: port 22 already allowed"
  else
    sudo ufw allow 22/tcp comment 'ssh (LAN access from bebski-go)'
    echo "ufw: opened port 22/tcp"
  fi
fi
