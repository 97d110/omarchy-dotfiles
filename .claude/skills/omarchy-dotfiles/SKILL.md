---
name: omarchy-dotfiles
description: Keep ~/Work/omarchy-dotfiles in sync whenever a persistent Omarchy/Hyprland/shell/git/ssh/gh config change is made on this machine. Use whenever editing files under ~/.config/hypr, ~/.config/omarchy, ~/.config/git, ~/.config/gh, ~/.bashrc, ~/.ssh (non-secret), ~/.local/share/applications, or running an imperative one-off setup command (systemctl enable, a CLI shim, a package install) that should survive a reinstall.
---

# omarchy-dotfiles

`~/Work/omarchy-dotfiles` is this machine's single source of truth for
Omarchy/Hyprland/shell/git/ssh/gh configuration. Whenever you make (or are
asked to make) a persistent config change on this machine, follow this
workflow before considering the task done.

## 1. Is the touched file already tracked?

Check whether the live path is a symlink into the repo:

```bash
readlink ~/.config/hypr/bindings.lua
# -> /home/bebskihome/Work/omarchy-dotfiles/files/config/hypr/bindings.lua  = tracked, nothing else to do
```

If it's already a symlink into the repo, your edit already changed the repo.
Nothing further is needed beyond the normal `git add -A && git commit` in
`~/Work/omarchy-dotfiles` (confirm with the user before committing/pushing,
per normal git-safety rules).

## 2. If it's a real file, not yet tracked

Move it into the repo and relink it, mirroring the live path with the
leading dot stripped from the first segment:

| Live path | Repo path |
|---|---|
| `~/.config/X` | `files/config/X` |
| `~/.local/Y` | `files/local/Y` |
| `~/.ssh/Z` | `files/ssh/Z` |
| `~/.bashrc`, other `~/.foo` | `files/home/.foo` |

```bash
mkdir -p ~/Work/omarchy-dotfiles/files/config/hypr
mv ~/.config/hypr/newfile.lua ~/Work/omarchy-dotfiles/files/config/hypr/
~/Work/omarchy-dotfiles/install.sh   # relinks it (00-link-files.sh)
```

Never track secrets this way — private keys, tokens, `gh`'s `hosts.yml`.
Check `.gitignore` and the README's "intentionally NOT tracked" list first.

## 3. If the change is imperative, not a file

Package installs, `systemctl enable`, CLI shims, one-off registrations
(e.g. `gh ssh-key add`) don't live in a file `git status` can see. Add or
update a numbered script under `modules/`:

- Number it after whatever it depends on (e.g. a service that needs a file
  from `00-link-files.sh` already in place goes at `2x` or later).
- It MUST be idempotent — safe to run every time `install.sh` runs, not just
  once. Check state before acting (`command -v`, `systemctl is-enabled`,
  file existence) rather than assuming a clean machine.
- NEVER auto-run something that needs a passphrase, an interactive browser
  login, or otherwise handles a secret. Check state and print the command
  for the user to run themselves instead (see `modules/30-ssh-key-check.sh`
  and `modules/40-gh-auth-check.sh` for the pattern).

Then run `~/Work/omarchy-dotfiles/install.sh` to confirm it's clean, and
mention the new/changed module in your summary to the user.

## 4. Commit

`git add -A && git commit` in the repo, same as any other change — confirm
with the user first, don't push without asking.
