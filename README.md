# dotfiles

My macOS setup: Fish, Ghostty, Rex, Neovim, and Pi,
with Catppuccin Macchiato and Geist Mono.

## Setup

Review [packages/](packages/) and back up existing configs first.
Install [Rex](https://www.superlogical.com/rex/docs/installation) manually if you use it.

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles
./dot init --profile personal  # Or: --profile work
```

Homebrew owns apps and standalone tools; Mise owns runtimes; chezmoi owns
configuration in [home/](home/). Skills and plugins use their native installers.
Sign-ins, licences, and macOS permissions remain manual, as do Microsoft apps,
Zoom, and Chrome.

## Profiles

| Scope | Includes |
| --- | --- |
| [Base](packages/Brewfile.base) | Shared apps, runtimes, configs, Pi packages, agent skills, and Cua |
| [Personal](packages/Brewfile.personal) | Extra apps, GitHub CLI/MCP, REA with Ghidra, and research MCP servers |
| [Work](packages/Brewfile.work) | Base only; only Cua MCP is managed, with no Pi provider/model defaults |

Personal installs **Base + Personal**; Work installs **Base + Work**.
The selection lives in `${XDG_CONFIG_HOME:-~/.config}/chezmoi/chezmoi.json`.
Automatic profile switching and uninstallation are refused.

## Commands

```sh
./dot diff             # Preview config changes
./dot apply            # Apply config only
./dot init             # Install dependencies and apply config
./dot init --upgrade   # Also allow Homebrew upgrades
./dot status           # Show pending config changes
./dot doctor           # Check without installing
./dot package list     # List packages by scope
```

Add `--verbose` to `init` or `apply` for detailed output.
Review the diff before applying: `--force` skips prompts and makes no backups.
Credentials, sessions, and local-only data stay unmanaged. Git identity and
unrelated Pi/MCP settings are preserved; back up same-name managed MCP entries.
Profiles are not a security boundary, and Personal leftovers are not removed on Work.
Tmux is no longer installed or configured by dotfiles. Existing installations,
`~/.tmux.conf`, and plugins are left alone; remove them manually only if no longer needed.
To roll back, restore previous sources or backups, preview, and apply explicitly.

## Agent skills

Edit [packages/skills.json](packages/skills.json): each entry has a `scope`
(`base`, `personal`, or `work`), installer `source`, selected `skills` (`["*"]`
means all), and optional `package` URL. `dot init` installs these globally for Pi;
`dot doctor` checks their recorded source and files, not upstream freshness.

The installer owns `~/.agents/skills` and its local lock. Back up local edits
before refreshing; removing a manifest entry does not uninstall a skill.
Cua and REA keep their separate skill setup.
