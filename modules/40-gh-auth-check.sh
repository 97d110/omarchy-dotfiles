#!/usr/bin/env bash
# gh auth login is an interactive browser flow and can't be scripted safely.
# Just check the state and print what to run if something's missing.
set -uo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "gh not installed - skipping auth check"
  exit 0
fi

if ! gh auth status >/dev/null 2>&1; then
  cat <<EOF
Not logged into gh. Run:

  gh auth login --hostname github.com --git-protocol ssh --web
EOF
  exit 0
fi

if ! gh auth status 2>&1 | grep -q "admin:ssh_signing_key"; then
  cat <<EOF
gh token is missing the signing-key scope. Run:

  gh auth refresh -h github.com -s admin:ssh_signing_key --web
EOF
else
  echo "gh auth OK"
fi
