#!/usr/bin/env bash
# ASUS ROG Strix G16 (G614FR): the Realtek ALC294 codec exposes separate
# Headphone/Speaker/Master ALSA mixer controls underneath PipeWire's own
# per-sink volume. Out of the box, Headphone and Speaker ship muted at 0%,
# and Master defaults well below 100% - so PipeWire showing "100%" was
# still passing through roughly -37dB of attenuation baked into the ALSA
# layer underneath it, making the aux/headphone output silent-to-soft no
# matter where the PipeWire slider sat.
#
# Pinning Master/Headphone/Speaker to 100% unmuted makes PipeWire's own
# sink volume the only attenuation point. Re-applied every run rather than
# relying on `alsactl store`/asound.state, since that file is root-owned,
# needs sudo to write, and may not exist at all on a fresh install.
set -uo pipefail

# shellcheck source=lib/hardware.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/hardware.sh"

if ! is_asus_laptop; then
  echo "not an ASUS laptop - skipping ALC294 headphone volume fix"
  exit 0
fi

CARD=Generic
CONTROLS=(Master Headphone Speaker)

if ! amixer -c "$CARD" sget "${CONTROLS[0]}" >/dev/null 2>&1; then
  echo "ALC294 (card '$CARD') not present - skipping headphone volume fix"
  exit 0
fi

changed=0
for ctrl in "${CONTROLS[@]}"; do
  current="$(amixer -c "$CARD" sget "$ctrl" 2>/dev/null | grep -oP '\[\K[0-9]+(?=%\])' | head -1)"
  muted="$(amixer -c "$CARD" sget "$ctrl" 2>/dev/null | grep -oP '\[\K(on|off)(?=\])' | head -1)"
  if [ "$current" != "100" ] || [ "$muted" = "off" ]; then
    amixer -c "$CARD" sset "$ctrl" 100% unmute >/dev/null
    echo "ALC294 $ctrl: ${current:-?}% (${muted:-?}) -> 100% (on)"
    changed=1
  fi
done

if [ "$changed" -eq 0 ]; then
  echo "ALC294 headphone volume OK: Master/Headphone/Speaker at 100% unmuted"
fi

# The codec resets Headphone/Speaker to muted on every boot, so re-apply
# this fix via a post-boot hook instead of relying on a manual ./install.sh
# rerun after each reboot.
HOOK_SRC="$(dirname "${BASH_SOURCE[0]}")/hooks/38-alc294-headphone-volume.hook"
HOOK_DEST="$HOME/.config/omarchy/hooks/post-boot.d/$(basename "$HOOK_SRC")"
if [[ ! -f $HOOK_DEST ]] || ! cmp -s "$HOOK_SRC" "$HOOK_DEST"; then
  omarchy hook install post-boot "$HOOK_SRC"
fi
