# omarchy-dotfiles

This repo is the source of truth for this machine's Omarchy/Hyprland/shell/
git/ssh/gh and Claude Code configuration. `files/` holds real config content,
symlinked into `$HOME` by `modules/00-link-files.sh`; `modules/` holds numbered,
idempotent scripts for everything that isn't a file. Run `./install.sh` to apply
everything; it's safe to rerun.

## Two machines share this repo

An ASUS ROG Strix G16 laptop (user `bebskigo`) and an older non-ASUS desktop
(user `bebskihome`). Everything tracked here therefore has to work on both:

- **Never hardcode `/home/<user>`.** Use `~` where the consumer expands it
  (git path options do; `core.sshCommand` already relies on it) or `$HOME`
  where a shell evaluates it (Hyprland `exec`, Omarchy menu actions). A
  `.desktop` `Exec=` does *no* expansion, so it needs `sh -c '... "$HOME" ...'`.
- **Never pin a tool's versioned path.** Call it by name and let PATH resolve
  it, or a mise/pacman upgrade breaks the other machine.
- **Gate hardware-specific modules.** Source `modules/lib/hardware.sh` and
  return early unless `is_asus_laptop`. Modules 35-37 (ROG GPU tools,
  NumberPad, ROG Deck) all do this; without it they hand the desktop install
  instructions for hardware it does not have.
- Machine-local Hyprland files (`monitors.lua`, `looknfeel.lua`,
  `hyprland.lua`, `autostart.lua`, `hyprsunset.conf`, `xdph.conf`) are
  deliberately **not** tracked - displays and layout differ per machine. Only
  `input.lua` and `bindings.lua` are shared.

Any config change made on this machine that should survive a reinstall (a
Hyprland/git/gh setting, a shell dotfile, a systemd unit enabled, a CLI
shim, an always-on Claude Code rule) must be reflected here before the task is
done — either by tracking the file (if it's not already a symlink into this
repo) or by adding/updating a module script (if it's an imperative action).
See the `omarchy-dotfiles` skill for the exact workflow.
