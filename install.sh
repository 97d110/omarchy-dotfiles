#!/usr/bin/env bash
# Index script: runs every modules/*.sh in numeric order.
#
# Modules are idempotent - safe to rerun any time (after cloning fresh, or
# after adding a new module). Genuinely interactive/secret steps (SSH key
# passphrase, gh browser login) are never auto-run; their modules only check
# state and print instructions.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
status=0

for module in "$REPO_DIR"/modules/*.sh; do
  echo "==> $(basename "$module")"
  if ! bash "$module"; then
    echo "    FAILED: $module"
    status=1
  fi
done

exit "$status"
