#!/usr/bin/env bash
# Symlinks every file under files/ into its mirrored path under $HOME.
# Safe to rerun: skips paths that are already the correct symlink, and
# backs up any real (non-symlink) file before replacing it.
#
# files/config/hypr/bindings.lua  -> ~/.config/hypr/bindings.lua
# files/home/.bashrc              -> ~/.bashrc
# files/ssh/allowed_signers       -> ~/.ssh/allowed_signers
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILES_DIR="$REPO_DIR/files"

live_path_for() {
  local repo_rel="$1"
  case "$repo_rel" in
    home/*)   echo "$HOME/${repo_rel#home/}" ;;
    config/*) echo "$HOME/.${repo_rel}" ;;
    local/*)  echo "$HOME/.${repo_rel}" ;;
    ssh/*)    echo "$HOME/.${repo_rel}" ;;
    *)        echo "$HOME/${repo_rel}" ;;
  esac
}

while IFS= read -r -d '' src; do
  repo_rel="${src#"$FILES_DIR"/}"
  live="$(live_path_for "$repo_rel")"

  if [ -L "$live" ] && [ "$(readlink "$live")" = "$src" ]; then
    continue
  fi

  mkdir -p "$(dirname "$live")"

  if [ -e "$live" ] && [ ! -L "$live" ]; then
    backup="$live.bak.$(date +%s)"
    echo "backing up existing file: $live -> $backup"
    mv "$live" "$backup"
  elif [ -L "$live" ]; then
    rm "$live"
  fi

  ln -s "$src" "$live"
  echo "linked: $live -> $src"
done < <(find "$FILES_DIR" -type f -print0)
