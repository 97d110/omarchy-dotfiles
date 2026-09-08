#!/usr/bin/env bash
# Shared hardware predicates for machine-specific modules.
#
# This repo is shared between an ASUS ROG laptop and a non-ASUS desktop, so
# modules that drive laptop-only hardware must gate on the hardware actually
# being present rather than assuming.
#
# Not sourced by install.sh: it lives in modules/lib/, and install.sh globs
# modules/*.sh, which does not recurse.

# True only on an ASUS *laptop*. asus-nb-wmi is the notebook WMI driver, so it
# binds on ROG/ASUS laptops but not on ASUS desktop boards - which is exactly
# the distinction needed here. The DMI vendor check alone would wrongly match
# an ASUS motherboard in a desktop.
is_asus_laptop() {
  [ -d /sys/devices/platform/asus-nb-wmi ]
}

# True when asusd is available to service firmware writes.
has_asusd() {
  command -v asusctl >/dev/null 2>&1 && systemctl is-active --quiet asusd
}
