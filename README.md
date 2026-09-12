# omarchy-dotfiles

Source of truth for how this Omarchy machine is configured. Two kinds of
content, handled differently on purpose:

- **`files/`** — plain config files (Hyprland, git, gh, shell rc, desktop
  entries, SSH allowed-signers/public key). `modules/00-link-files.sh`
  symlinks each one into its real `$HOME` location. Editing the live file
  *is* editing the repo — `git status` here shows exactly what changed.
- **`modules/`** — numbered, idempotent shell scripts for imperative,
  non-file setup (enabling a systemd unit, shimming a CLI binary). Safe to
  rerun any time. Anything genuinely interactive or secret (SSH key
  passphrase, `gh auth login`) is never auto-run — its module only checks
  state and prints the command to run yourself.

Modeled on how Omarchy installs itself (`/usr/share/omarchy/install/*/all.sh`
running numbered scripts via `run_logged`).

## Usage

```
./install.sh
```

Runs every `modules/*.sh` in order. Safe to rerun after every change, and
on a fresh machine after cloning this repo.

## Claude Code

Two things here are registered globally, so every session on this machine picks
them up — not only sessions opened inside this repo:

- **The `omarchy-dotfiles` skill** — `modules/70-claude-integration.sh` links it
  into `~/.claude/skills/` and points `~/.claude/CLAUDE.md` at this repo.
- **Always-on rules** — `files/home/.claude/rules/*.md`, symlinked to
  `~/.claude/rules/`, which Claude Code reads at the start of every session in
  every project. `modules/71-claude-rules.sh` proves each one is live and clears
  links left behind by a renamed rule.

To add a rule, drop a numbered `NN-topic.md` into `files/home/.claude/rules/`
and run `./install.sh`. There is nothing else to register.

## Adding a new piece of config

- **A file** (new Hyprland setting, another dotfile): move the live file into
  `files/<mirrored path>` (drop the leading dot: `~/.config/x` → `files/config/x`,
  `~/.bashrc` → `files/home/.bashrc`), then run `./install.sh` to relink it.
- **An imperative action** (install a package, enable a service, add a CLI
  shim): add a new `modules/NN-description.sh`, idempotent, numbered after
  whatever it depends on.

Then `git add -A && git commit`. See the `omarchy-dotfiles` skill
(`.claude/skills/omarchy-dotfiles/SKILL.md`) for the full workflow — it's
registered globally by `modules/70-claude-integration.sh`, which symlinks it
into `~/.claude/skills/` and points `~/.claude/CLAUDE.md` at this repo, so
any Claude Code session on this machine follows this workflow automatically,
not just sessions opened inside this repo.

## What's intentionally NOT tracked

- Private SSH key (`~/.ssh/id_ed25519_github`) — secret.
- `~/.config/gh/hosts.yml` — holds the gh OAuth token.
- `~/.ssh/known_hosts*` — machine noise, not authored config.
- `~/.claude/CLAUDE.md` — machine-local; module 70 only appends a pointer to it.
  Shared rules belong in `files/home/.claude/rules/` instead.
