#!/usr/bin/env bash
# Installs and applies the One Dark Pro theme, which is third-party: it isn't
# one of the themes shipped in $OMARCHY_PATH/themes, so a fresh machine has to
# clone it before it can be set.
#
# `omarchy theme install` rm -rf's an existing theme directory and re-clones it,
# then applies it. That makes it wrong to call unconditionally from an installer
# that reruns: it would re-clone on every run and discard any local overlay in
# the theme directory. So the clone is guarded on the directory being absent,
# and applying the theme is a separate, cheap check.
set -uo pipefail

THEME_SLUG="one-dark-pro"
THEME_REPO="https://github.com/sc0ttman/omarchy-one-dark-pro-theme.git"
THEME_PATH="$HOME/.config/omarchy/themes/$THEME_SLUG"

if ! command -v omarchy >/dev/null 2>&1; then
  echo "omarchy not installed - skipping theme setup"
  exit 0
fi

# The slug omarchy derives from the repo URL (strip a leading omarchy- and a
# trailing -theme) has to match THEME_SLUG, or the clone would land elsewhere
# and the theme set below would not find it.
if [ ! -d "$THEME_PATH" ]; then
  echo "installing theme $THEME_SLUG from $THEME_REPO"
  # This also applies the theme, so there's nothing left to do afterwards.
  if ! omarchy theme install "$THEME_REPO"; then
    echo "FAILED to install theme $THEME_SLUG (network? repo moved?)"
    exit 1
  fi
  echo "theme $THEME_SLUG installed and applied"
  exit 0
fi

# Compare slugs rather than display names: `omarchy theme current` prints the
# display name ("One Dark Pro"), while the slug is what names the directory.
current="$(omarchy theme current 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

if [ "$current" = "$THEME_SLUG" ]; then
  echo "theme OK: $THEME_SLUG already current"
  exit 0
fi

echo "switching theme: ${current:-<unknown>} -> $THEME_SLUG"
if ! omarchy theme set "$THEME_SLUG"; then
  echo "FAILED to set theme $THEME_SLUG"
  exit 1
fi
echo "theme $THEME_SLUG applied"
