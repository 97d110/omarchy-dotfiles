#!/usr/bin/env bash
# ASUS ROG Strix G16 (G614FR): NumberPad 2.0 - the illuminated numeric keypad
# drawn on the touchpad, activated by holding the top-right corner. There is no
# in-kernel driver; it needs the userspace asus-numberpad-driver, which drives
# the touchpad over /dev/i2c-*.
#
# Layout for this machine is g533: our touchpad (04F3:3275 / ASUE1416) is
# reported with the g533 layout by ~80 users across ROG Strix G16/G18 models,
# and the G614FR DMI id maps to g533 as well.
#
# The upstream installer needs interactive sudo and asks several questions, so
# this module only reports install state and prints what to run - it never
# installs. It DOES enforce the config values below, which need no privileges.
#
# Note: the AUR package (asus-numberpad-driver-g533-git) is deliberately NOT
# used. Its shipped unit leaves $XDG_RUNTIME_DIR, $CONFIG_FILE_DIR_PATH and
# $LOG_ENV_LINE unsubstituted, so it does not work on Wayland.
set -uo pipefail

# shellcheck source=lib/hardware.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/hardware.sh"

if ! is_asus_laptop; then
  echo "not an ASUS laptop - skipping NumberPad setup"
  exit 0
fi

SRC_DIR="$HOME/.local/src/asus-numberpad-driver"
INSTALL_DIR="/usr/share/asus-numberpad-driver"
DRIVER="$INSTALL_DIR/numberpad.py"
CFG="$INSTALL_DIR/numberpad_dev"
SERVICE="asus_numberpad_driver@$USER.service"

if [ ! -f "$DRIVER" ]; then
  echo "ASUS NumberPad driver not installed."
  if [ -d "$SRC_DIR" ]; then
    echo "  Source tree is ready (telemetry calls stubbed). Install with:"
    echo "    cd $SRC_DIR && LAYOUT_NAME=g533 bash install.sh"
  else
    echo "  Get it and install with:"
    echo "    git clone https://github.com/asus-linux-drivers/asus-numberpad-driver $SRC_DIR"
    echo "    cd $SRC_DIR && git checkout v7.2.3 && LAYOUT_NAME=g533 bash install.sh"
  fi
  exit 0
fi

echo "ASUS NumberPad driver OK: $DRIVER"

# The installer's defaults fight each other on this machine. Omarchy sets
# Hyprland's input:numlock_by_default = true, so system NumLock is always on.
# With sys_numlock_enables_numpad=1 the driver slaves the NumberPad to system
# NumLock (numberpad.py:2398) and force-activates it; with
# numpad_disables_sys_numlock=1 every deactivation sends KEY_NUMLOCK back, and
# the two settings ping-pong - the NumberPad switches itself on while typing
# and dies after a keypress or two. Decoupling both ends stops it.
#
# Safe to pin to 0: the driver only force-overrides sys_numlock_enables_numpad
# when the layout defines neither a Num_Lock key nor a top-right icon
# (numberpad.py:1994); g533 defines top_right_icon_width/height, so it sticks.
#
# top_left_icon_slide_func_activates_numpad=0: a slide starting at the top-LEFT
# corner would otherwise switch the NumberPad on, which fires during ordinary
# pointer movement.
# touchpad_disables_numpad=0: that feature is X11-only and merely logs failures
# under Wayland.
# top_right_icon_coactivator_key is deliberately EMPTY. The installer offers a
# co-activator (Shift/Control/Alt) that must be held while touching the corner;
# picking one made activation impossible here - every corner hold logged
# "Numlock activation blocked: co-activator key(s) not pressed: ['Shift']".
# Empty means no modifier is required: numberpad.py:2003 does .strip().split(),
# so "" becomes [], and are_modifier_keys_pressed([]) returns True
# (numberpad.py:592). The 1s deliberate hold is the guard against accidents.
declare -A WANT=(
  [sys_numlock_enables_numpad]=0
  [numpad_disables_sys_numlock]=0
  [top_left_icon_slide_func_activates_numpad]=0
  [touchpad_disables_numpad]=0
  [top_right_icon_coactivator_key]=""
)

if [ ! -w "$CFG" ]; then
  echo "NumberPad config not writable, skipping config check: $CFG"
else
  changed=0
  for key in "${!WANT[@]}"; do
    wanted="${WANT[$key]}"
    if grep -qE "^${key}[[:space:]]*=" "$CFG"; then
      present=1
      current="$(sed -n "s/^${key}[[:space:]]*=[[:space:]]*\(.*\)$/\1/p" "$CFG" | tail -1)"
    else
      present=0
      current=""
    fi

    if [ "$present" -eq 0 ]; then
      printf '%s = %s\n' "$key" "$wanted" >> "$CFG"
      echo "NumberPad config: $key unset -> ${wanted:-(empty)}"
      changed=1
    elif [ "$current" != "$wanted" ]; then
      sed -i "s|^${key}[[:space:]]*=.*$|${key} = ${wanted}|" "$CFG"
      echo "NumberPad config: ${key} ${current:-(empty)} -> ${wanted:-(empty)}"
      changed=1
    fi
  done

  if [ "$changed" -eq 1 ]; then
    echo "NumberPad config updated; restarting service"
    systemctl --user restart "$SERVICE" 2>/dev/null || true
  else
    echo "NumberPad config OK: numlock decoupled, stray activation gestures off"
  fi
fi

if systemctl --user is-enabled "$SERVICE" >/dev/null 2>&1; then
  echo "NumberPad service OK: $SERVICE enabled"
else
  echo "NumberPad service not enabled. Fix with:"
  echo "  systemctl --user enable --now $SERVICE"
fi

# The driver pokes the touchpad over i2c and synthesises keys via uinput, so
# these group memberships are load-bearing. They only take effect after a
# re-login, which is easy to miss right after installing.
missing_groups=()
for g in i2c input uinput numberpad; do
  id -nG "$USER" 2>/dev/null | grep -qw "$g" || missing_groups+=("$g")
done

if [ "${#missing_groups[@]}" -gt 0 ]; then
  echo "Current user missing groups needed by the NumberPad driver: ${missing_groups[*]}"
  echo "  sudo usermod -aG $(IFS=,; echo "${missing_groups[*]}") $USER   # then log out and back in"
else
  echo "NumberPad groups OK: i2c input uinput numberpad"
fi
