#!/usr/bin/env bash
# Enable (but don't start) the personal-configurations tag-poll/redeploy
# service. bebski-home only: it's the deploy target (runs
# docker/bebski-home), the dev laptop isn't - see root CLAUDE.md in
# personal-configurations for the machine split. Not auto-started here
# either way: start it yourself once ready:
# systemctl --user start personal-configurations-deploy
set -euo pipefail

if [ "$(hostname)" != "bebski-home" ]; then
  exit 0
fi

systemctl --user daemon-reload
systemctl --user enable personal-configurations-deploy.service
echo "personal-configurations-deploy.service enabled (not started yet — see comment above)"
