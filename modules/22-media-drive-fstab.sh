#!/usr/bin/env bash
# The external WD media drive (/mnt/media-drive, NTFS) can end up marked
# "dirty" after an unclean USB disconnect. ntfs3 then refuses to mount it
# via a plain fstab entry ("bad superblock") until either chkdsk clears the
# dirty flag or the mount is forced. `force` lets it keep auto-mounting at
# boot without manual intervention after a drive dropout.
set -uo pipefail

FSTAB=/etc/fstab
LINE_PATTERN='UUID=8670B7AC70B7A17B[[:space:]]+/mnt/media-drive[[:space:]]+ntfs3'

if ! grep -qE "$LINE_PATTERN" "$FSTAB"; then
  exit 0   # media-drive fstab entry not present on this machine
fi

if grep -E "$LINE_PATTERN" "$FSTAB" | grep -q 'force'; then
  echo "media-drive fstab entry OK: force option present"
else
  cat <<EOF
/mnt/media-drive fstab entry is missing the "force" mount option, so a
future unclean disconnect (dirty NTFS volume) will fail to auto-mount at
boot. Fix: edit /etc/fstab and add "force" to the options for
UUID=8670B7AC70B7A17B /mnt/media-drive, e.g.:

  sudo sed -i \\
    's/\\(UUID=8670B7AC70B7A17B[[:space:]]\\+\\/mnt\\/media-drive[[:space:]]\\+ntfs3[[:space:]]\\+\\)defaults,nofail,/\\1defaults,nofail,force,/' \\
    /etc/fstab
EOF
fi
