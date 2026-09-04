#!/usr/bin/env bash
# Enable the systemd user socket for ssh-agent so it's available on demand
# and survives reboots, without needing a manual `eval $(ssh-agent)`.
set -euo pipefail

systemctl --user enable --now ssh-agent.socket
echo "ssh-agent.socket enabled"
