#!/usr/bin/env bash
# Enable (but don't start) the personal-configurations tag-poll/redeploy
# service. Not auto-started here: it points at
# ~/Work/personal-configurations/deploy/poll-and-deploy.sh, which only
# exists once that repo's deploy branch is merged to main. Once it is,
# start it yourself: systemctl --user start personal-configurations-deploy
set -euo pipefail

systemctl --user daemon-reload
systemctl --user enable personal-configurations-deploy.service
echo "personal-configurations-deploy.service enabled (not started yet — see comment above)"
