#!/usr/bin/env bash
# docker.service is socket-activated by default (docker.socket enabled,
# docker.service itself not) - nothing touches the socket at boot on its
# own, so on machines running docker workloads unattended (e.g.
# bebski-home's docker/bebski-home stack, or the poll-and-deploy service
# in personal-configurations) dockerd never actually starts after a
# reboot, and none of the `restart: unless-stopped` containers come back.
# Confirmed on bebski-home: containers stayed down ~2 minutes after boot
# until an unrelated `docker` command happened to hit the socket.
set -uo pipefail

if ! systemctl list-unit-files docker.service >/dev/null 2>&1; then
  exit 0   # docker not installed on this machine - nothing to check
fi

if systemctl is-enabled --quiet docker.service 2>/dev/null; then
  echo "docker.service OK: enabled directly (not relying on socket activation)"
else
  cat <<EOF
docker.service is not enabled - it only starts via socket activation, which
means it may not start automatically after a reboot until something happens
to touch /run/docker.sock. Fix:

  sudo systemctl enable docker.service
EOF
fi
