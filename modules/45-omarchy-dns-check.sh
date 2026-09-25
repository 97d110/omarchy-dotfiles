#!/usr/bin/env bash
# omarchy-dns Custom requires an interactive stdin prompt and root, so this
# only checks state and prints the fix - same pattern as the ssh-key/gh-auth
# checks above. Never auto-runs it.
#
# 172.19.93.8 is this host's own LAN IP, running Pi-hole for the
# bebski-home docker stack (see ~/Work/personal-configurations/docker/bebski-home).
# Pi-hole has local DNS overrides for every *.bebski-home.work subdomain
# pointed at that same IP. Without this, this host's own DNS resolves those
# subdomains via the public Cloudflare-proxied answer and round-trips
# through the tunnel to reach a container running on itself.
set -uo pipefail

EXPECTED_DNS="172.19.93.8"

if ! command -v omarchy-dns >/dev/null 2>&1; then
  echo "omarchy-dns not installed - skipping DNS provider check"
  exit 0
fi

provider=$(omarchy-dns 2>/dev/null || true)
current_dns=$(awk -F= '/^[[:space:]]*DNS[[:space:]]*=/ { v=$0; sub(/^[^=]*=/,"",v); print v; exit }' /etc/systemd/resolved.conf 2>/dev/null || true)

if [[ $provider == "Custom" && $current_dns == "$EXPECTED_DNS" ]]; then
  echo "omarchy-dns OK: Custom -> $EXPECTED_DNS (Pi-hole)"
else
  cat <<EOF
omarchy-dns is set to '$provider' (DNS=$current_dns), not Pi-hole. This
means *.bebski-home.work subdomains resolve via the public tunnel instead
of directly on the LAN. Fix:

  sudo omarchy-dns Custom

When prompted, enter: $EXPECTED_DNS
EOF
fi
