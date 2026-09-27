#!/usr/bin/env bash
# Authorize bebski-go's dedicated access key (files/ssh/id_ed25519_bebski_home.pub,
# tracked in this repo once generated - see modules/32-ssh-key-check-bebski-home.sh)
# to log in here over SSH. bebski-home only, idempotent.
set -euo pipefail

if [ "$(hostname)" != "bebski-home" ]; then
  exit 0
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBKEY_FILE="$REPO_DIR/files/ssh/id_ed25519_bebski_home.pub"

if [ ! -f "$PUBKEY_FILE" ]; then
  echo "No $PUBKEY_FILE yet - generate the key on bebski-go first (see modules/32-ssh-key-check-bebski-home.sh), push, then pull here."
  exit 0
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

PUBKEY="$(cat "$PUBKEY_FILE")"

if grep -qF "$PUBKEY" "$HOME/.ssh/authorized_keys" 2>/dev/null; then
  echo "authorized_keys: bebski-go access key already present"
else
  echo "$PUBKEY" >> "$HOME/.ssh/authorized_keys"
  echo "authorized_keys: added bebski-go access key"
fi
