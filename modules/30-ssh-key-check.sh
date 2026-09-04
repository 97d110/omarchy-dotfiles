#!/usr/bin/env bash
# Deliberately does NOT auto-generate the SSH key: passphrase entry must stay
# interactive and private. Just checks the expected key exists and is
# actually passphrase-protected, and tells you what to run if not.
set -uo pipefail

KEY="$HOME/.ssh/id_ed25519_github"

if [ ! -f "$KEY" ]; then
  cat <<EOF
No SSH key at $KEY. Generate one yourself:

  ssh-keygen -t ed25519 -C "\$(git config --global user.email)" -f $KEY

Set a real passphrase when prompted, then re-run this installer.
EOF
  exit 0
fi

if ssh-keygen -y -f "$KEY" -P "" >/dev/null 2>&1; then
  echo "WARNING: $KEY has no passphrase set. Fix with: ssh-keygen -p -f $KEY"
else
  echo "SSH key OK: $KEY (passphrase-protected)"
fi
