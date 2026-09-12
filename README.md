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

## Cross-repo services tracked here

Some `modules/` entries exist only to register machine-level plumbing for a
service whose actual logic lives in a different repo. Currently:

- **`personal-configurations`'s tag-poll/redeploy loop** (`bebski-home`
  only — the always-on deploy target, not this laptop). The poll script
  itself (`deploy/poll-and-deploy.sh`) and the tag-cutting script
  (`deploy/cut-release.sh`) live in that repo; see its `CLAUDE.md` ->
  "Deploy mechanism" for the full pipeline. What's tracked here instead:
  - `files/config/systemd/user/personal-configurations-deploy.service` —
    the systemd **unit** (a thin `ExecStart` pointer at the script above,
    no embedded poll logic), symlinked to `~/.config/systemd/user/` by
    `modules/00-link-files.sh`.
  - `modules/80-personal-configs-deploy.sh` — registers the unit
    (`systemctl --user enable`) on `bebski-home` only; **does not start
    it**. A one-time `systemctl --user start personal-configurations-deploy`
    on `bebski-home` is required before any tag actually triggers a
    redeploy — easy to forget, and it fails silently (no error, no Discord
    message) if skipped.
  - `modules/90-docker-boot-check.sh` — unrelated to the above directly,
    but flags a docker-socket-activation issue that can make a redeploy
    look like a no-op even when the poll loop itself is running correctly.
  - `files/home/.bashrc` — the `deploy-config` alias for
    `personal-configurations/deploy/cut-release.sh`.

## What's intentionally NOT tracked

- Private SSH key (`~/.ssh/id_ed25519_github`) — secret.
- `~/.config/gh/hosts.yml` — holds the gh OAuth token.
- `~/.ssh/known_hosts*` — machine noise, not authored config.
- `~/.claude/CLAUDE.md` — machine-local; module 70 only appends a pointer to it.
  Shared rules belong in `files/home/.claude/rules/` instead.
