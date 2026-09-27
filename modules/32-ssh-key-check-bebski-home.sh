#!/usr/bin/env bash
# Deliberately does NOT auto-generate the SSH key: passphrase entry must stay
# interactive and private. Just checks the expected key exists and is
# actually passphrase-protected, and tells you what to run if not.
#
# This key is for bebski-go -> bebski-home LAN access (browsing/copying files
# from the home server), kept separate from id_ed25519_github on purpose.
set -uo pipefail

KEY="$HOME/.ssh/id_ed25519_bebski_home"

if [ ! -f "$KEY" ]; then
  cat <<EOF
No SSH key at $KEY. Generate one yourself:

  ssh-keygen -t ed25519 -C "bebski-go -> bebski-home access" -f $KEY

Set a real passphrase when prompted, then move the .pub into this repo so it
gets tracked and symlinked back into place:

  mv $KEY.pub $HOME/Work/omarchy-dotfiles/files/ssh/id_ed25519_bebski_home.pub
  $HOME/Work/omarchy-dotfiles/install.sh

Then add that public key to ~/.ssh/authorized_keys on bebski-home (see
modules/83-ssh-authorized-keys-bebski-home.sh - it does this automatically
once the .pub is tracked here and this repo is pulled on bebski-home).
EOF
  exit 0
fi

if ssh-keygen -y -f "$KEY" -P "" >/dev/null 2>&1; then
  echo "WARNING: $KEY has no passphrase set. Fix with: ssh-keygen -p -f $KEY"
else
  echo "SSH key OK: $KEY (passphrase-protected)"
fi
