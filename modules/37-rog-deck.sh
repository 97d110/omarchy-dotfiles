#!/usr/bin/env bash
# ROG Deck - the local web dashboard that replaces Armoury Crate on this
# machine (fan curves, power limits, GPU mux, Aura, Slash bar, NumberPad).
#
# The project lives in its own repo; this module only makes sure it is present
# and running. Its own install.sh needs no root, so it is safe to invoke here -
# unlike the numberpad driver in 36-, which needs interactive sudo.
set -uo pipefail

# shellcheck source=lib/hardware.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/hardware.sh"

if ! is_asus_laptop; then
  echo "not an ASUS laptop - skipping ROG Deck"
  exit 0
fi

REPO="$HOME/Work/rog-deck"
SERVICE="rog-deck.service"
URL="http://127.0.0.1:8737"

if [ ! -d "$REPO" ]; then
  echo "ROG Deck source not found at $REPO. Clone it with:"
  echo "  git clone https://github.com/97d110/rog-deck $REPO"
  exit 0
fi

if ! systemctl --user is-enabled "$SERVICE" >/dev/null 2>&1; then
  echo "ROG Deck not installed. Installing (no root required)..."
  if "$REPO/install.sh" >/dev/null 2>&1; then
    echo "ROG Deck installed -> $URL"
  else
    echo "ROG Deck install failed. Run it directly to see why:"
    echo "  $REPO/install.sh"
  fi
  exit 0
fi

if systemctl --user is-active "$SERVICE" >/dev/null 2>&1; then
  echo "ROG Deck OK: running at $URL"
else
  echo "ROG Deck enabled but not running. Start it with:"
  echo "  systemctl --user start $SERVICE"
fi
