# omarchy-dotfiles

This repo is the source of truth for this machine's Omarchy/Hyprland/shell/
git/ssh/gh configuration. `files/` holds real config content, symlinked into
`$HOME` by `modules/00-link-files.sh`; `modules/` holds numbered, idempotent
scripts for everything that isn't a file. Run `./install.sh` to apply
everything; it's safe to rerun.

Any config change made on this machine that should survive a reinstall (a
Hyprland/git/gh setting, a shell dotfile, a systemd unit enabled, a CLI
shim) must be reflected here before the task is done — either by tracking
the file (if it's not already a symlink into this repo) or by adding/
updating a module script (if it's an imperative action). See the
`omarchy-dotfiles` skill for the exact workflow.
