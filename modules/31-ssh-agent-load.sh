#!/usr/bin/env bash
# Load the GitHub SSH key into the systemd ssh-agent (enabled by
# 20-ssh-agent-socket.sh) once per login, so git/ssh operations don't
# re-prompt for the passphrase on every use. Never auto-enters the
# passphrase itself - if the key isn't loaded yet, this just prints the
# command to run.
set -uo pipefail

KEY="$HOME/.ssh/id_ed25519_github"

if [ ! -f "$KEY" ]; then
  exit 0
fi

if ! command -v ssh-add >/dev/null 2>&1; then
  echo "ssh-add not found - skipping agent check"
  exit 0
fi

FINGERPRINT="$(ssh-keygen -lf "$KEY.pub" 2>/dev/null | awk '{print $2}')"

if [ -n "$FINGERPRINT" ] && ssh-add -l 2>/dev/null | grep -q "$FINGERPRINT"; then
  echo "ssh-agent: $KEY already loaded"
else
  cat <<EOF
$KEY is not loaded into the ssh-agent yet. Load it once per login with:

  ssh-add $KEY

You'll be prompted for its passphrase once; the systemd ssh-agent.socket
keeps it available until you log out, so you won't be asked again until
next login.
EOF
fi
