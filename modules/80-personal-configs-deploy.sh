#!/usr/bin/env bash
# Enable (but don't start) the personal-configurations tag-poll/redeploy
# service. bebski-home only: it's the deploy target (runs
# docker/bebski-home), the dev laptop isn't - see root CLAUDE.md in
# personal-configurations for the machine split. Not auto-started here
# either way: start it yourself once ready:
# systemctl --user start personal-configurations-deploy
set -euo pipefail

if [ "$(hostname)" != "bebski-home" ]; then
  echo "not bebski-home - skipping personal-configurations deploy service"
  exit 0
fi

if systemctl --user daemon-reload && systemctl --user enable personal-configurations-deploy.service; then
  echo "personal-configurations-deploy.service enabled (not started yet — see comment above)"
else
  echo "FAILED to enable personal-configurations-deploy.service - see systemctl output above" >&2
  exit 1
fi
