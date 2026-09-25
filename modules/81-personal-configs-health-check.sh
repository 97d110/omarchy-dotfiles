#!/usr/bin/env bash
# Enable (but don't start) the personal-configurations health-check/self-heal
# timer. bebski-home only: it checks/heals docker/bebski-home, the dev
# laptop doesn't run that stack - see root CLAUDE.md in
# personal-configurations for the machine split. Not auto-started here
# either way: start it yourself once ready:
# systemctl --user start personal-configurations-health-check.timer
set -euo pipefail

if [ "$(hostname)" != "bebski-home" ]; then
  exit 0
fi

systemctl --user daemon-reload
systemctl --user enable personal-configurations-health-check.timer
echo "personal-configurations-health-check.timer enabled (not started yet — see comment above)"
